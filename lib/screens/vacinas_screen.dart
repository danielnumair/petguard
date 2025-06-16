import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vacina.dart';
import '../models/pet.dart';
import '../database/vacina_dao.dart';
import '../database/pet_dao.dart';
import '../widgets/cadastro_input.dart';
import 'cadastro_vacina_screen.dart';

class VacinasScreen extends StatefulWidget {
  final int usuarioId;
  const VacinasScreen({super.key, required this.usuarioId});

  @override
  State<VacinasScreen> createState() => _VacinasScreenState();
}

class _VacinasScreenState extends State<VacinasScreen> {
  List<Vacina> vacinas = [];
  List<Pet> pets = [];

  String filtroCampoSelecionado = 'Pet';
  final filtroValorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    pets = await PetDAO().getByUsuario(widget.usuarioId);
    _carregarVacinas();
  }

  Future<void> _carregarVacinas() async {
    final lista = await VacinaDAO().getByUsuario(widget.usuarioId);

    lista.sort((a, b) {
      final dataCompare = a.dataAplicacao.compareTo(b.dataAplicacao);
      if (dataCompare != 0) return dataCompare;

      final petA = pets.firstWhere(
            (p) => p.id == a.petId,
        orElse: () => Pet(
          id: 0,
          nome: '',
          especie: '',
          raca: '',
          sexo: '',
          dataNascimento: DateTime(2000, 1, 1),
          observacoes: '',
          usuarioId: widget.usuarioId,
        ),
      );

      final petB = pets.firstWhere(
            (p) => p.id == b.petId,
        orElse: () => Pet(
          id: 0,
          nome: '',
          especie: '',
          raca: '',
          sexo: '',
          dataNascimento: DateTime(2000, 1, 1),
          observacoes: '',
          usuarioId: widget.usuarioId,
        ),
      );

      return petA.nome.toLowerCase().compareTo(petB.nome.toLowerCase());
    });

    setState(() {
      vacinas = lista;
    });
  }

  void _incluirVacina() async {
    final cadastrado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroVacinaScreen(usuarioId: widget.usuarioId),
      ),
    );
    if (cadastrado == true) _carregarVacinas();
  }

  void _editarVacina(Vacina vacina) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroVacinaScreen(
          usuarioId: widget.usuarioId,
          vacina: vacina,
        ),
      ),
    );
    if (atualizado == true) _carregarVacinas();
  }

  void _confirmarExclusao(Vacina vacina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6E6E6),
        title: const Text('Confirmar exclusão', style: TextStyle(fontFamily: 'Montserrat')),
        content: Text(
          'Deseja excluir a vacina "${vacina.vacina}"?',
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: () async {
              await VacinaDAO().delete(vacina.id!);
              Navigator.pop(context);
              _carregarVacinas();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontFamily: 'Montserrat')),
          ),
        ],
      ),
    );
  }

  void _aplicarFiltro() async {
    final campo = filtroCampoSelecionado.toLowerCase();
    final valor = filtroValorController.text.toLowerCase();

    final todas = await VacinaDAO().getByUsuario(widget.usuarioId);

    final filtradas = todas.where((v) {
      String petNome;
      try {
        petNome = pets.firstWhere((p) => p.id == v.petId).nome.toLowerCase();
      } catch (_) {
        petNome = 'desconhecido';
      }

      final mapa = {
        'pet': petNome,
        'vacina': v.vacina.toLowerCase(),
        'veterinário': v.veterinario.toLowerCase(),
        'lote': v.lote.toLowerCase(),
        'data': DateFormat('dd/MM/yyyy').format(v.dataAplicacao).toLowerCase(),
        'próxima': DateFormat('dd/MM/yyyy').format(v.proxima).toLowerCase(),
      };
      return mapa[campo]?.contains(valor) ?? false;
    }).toList();

    filtradas.sort((a, b) {
      final dataCompare = a.dataAplicacao.compareTo(b.dataAplicacao);
      if (dataCompare != 0) return dataCompare;

      final petA = pets.firstWhere(
            (p) => p.id == a.petId,
        orElse: () => Pet(
          id: 0,
          nome: '',
          especie: '',
          raca: '',
          sexo: '',
          dataNascimento: DateTime(2000, 1, 1),
          observacoes: '',
          usuarioId: widget.usuarioId,
        ),
      );

      final petB = pets.firstWhere(
            (p) => p.id == b.petId,
        orElse: () => Pet(
          id: 0,
          nome: '',
          especie: '',
          raca: '',
          sexo: '',
          dataNascimento: DateTime(2000, 1, 1),
          observacoes: '',
          usuarioId: widget.usuarioId,
        ),
      );

      return petA.nome.toLowerCase().compareTo(petB.nome.toLowerCase());
    });

    setState(() {
      vacinas = filtradas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/consulta_background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCabecalho(),
                _buildFiltros(),
                const Divider(thickness: 1.5, height: 1.5, color: Colors.black54),
                _buildLista(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho() {
    return Container(
      color: const Color(0xFFD9D9D9),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Image.asset('assets/icons/back.png', width: 32, height: 32),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'VACINAS',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF4F4F4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      color: const Color(0xFFF7931E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Theme(
            data: Theme.of(context).copyWith(canvasColor: const Color(0xFFE6E6E6)),
            child: DropdownButtonFormField<String>(
              value: filtroCampoSelecionado,
              onChanged: (value) => setState(() => filtroCampoSelecionado = value!),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE6E6E6),
                prefixIcon: const Icon(Icons.filter_alt, color: Colors.black54),
                hintText: 'Campo para filtrar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Pet', child: Text('Pet')),
                DropdownMenuItem(value: 'Vacina', child: Text('Vacina')),
                DropdownMenuItem(value: 'Veterinário', child: Text('Veterinário')),
                DropdownMenuItem(value: 'Lote', child: Text('Lote')),
                DropdownMenuItem(value: 'Data', child: Text('Data Aplicação')),
                DropdownMenuItem(value: 'Próxima', child: Text('Próxima Dose')),
              ],
            ),
          ),
          const SizedBox(height: 6),
          CadastroInput(
            hint: 'Valor para filtrar',
            icon: Icons.search,
            controller: filtroValorController,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => _aplicarFiltro(),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _incluirVacina,
                icon: const Icon(Icons.add, color: Colors.black, size: 20),
                label: const Text('Incluir', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _aplicarFiltro,
                icon: Image.asset('assets/icons/lupa.png', width: 28, height: 28),
                label: const Text('Pesquisar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return Expanded(
      child: Container(
        color: Colors.black12,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: vacinas.length,
          itemBuilder: (context, index) {
            final v = vacinas[index];
            String petNome;
            try {
              petNome = pets.firstWhere((p) => p.id == v.petId).nome;
            } catch (e) {
              petNome = 'Desconhecido';
            }
            return _buildCardVacina(v, petNome);
          },
        ),
      ),
    );
  }

  Widget _buildCardVacina(Vacina v, String petNome) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: const Color(0xFFE6E6E6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(v.dataAplicacao),
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/editar.png', width: 36, height: 36),
                      onPressed: () => _editarVacina(v),
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/excluir.png', width: 36, height: 36),
                      onPressed: () => _confirmarExclusao(v),
                    ),
                  ],
                )
              ],
            ),
            Text('Pet: $petNome', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Vacina: ${v.vacina}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Veterinário: ${v.veterinario}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Lote: ${v.lote}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Peso: ${v.peso.toStringAsFixed(1)} kg', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Próxima: ${DateFormat('dd/MM/yyyy').format(v.proxima)}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
