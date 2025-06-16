import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consulta.dart';
import '../models/pet.dart';
import '../database/consulta_dao.dart';
import '../database/pet_dao.dart';
import 'cadastro_consulta_screen.dart';
import '../widgets/cadastro_input.dart';

class ConsultasScreen extends StatefulWidget {
  final int usuarioId;

  const ConsultasScreen({super.key, required this.usuarioId});

  @override
  State<ConsultasScreen> createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends State<ConsultasScreen> {
  List<Consulta> consultas = [];
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
    _carregarConsultas();
  }

  Future<void> _carregarConsultas() async {
    final lista = await ConsultaDAO().getByUsuario(widget.usuarioId);

    lista.sort((a, b) {
      final dataCompare = a.data.compareTo(b.data);
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
      consultas = lista;
    });
  }


  void _incluirConsulta() async {
    final cadastrado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroConsultaScreen(usuarioId: widget.usuarioId),
      ),
    );
    if (cadastrado == true) _carregarConsultas();
  }

  void _editarConsulta(Consulta consulta) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroConsultaScreen(
          usuarioId: widget.usuarioId,
          consulta: consulta,
        ),
      ),
    );
    if (atualizado == true) _carregarConsultas();
  }

  void _confirmarExclusao(Consulta consulta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6E6E6),
        title: const Text('Confirmar exclusão', style: TextStyle(fontFamily: 'Montserrat')),
        content: Text(
          'Deseja excluir a consulta de ${DateFormat('dd/MM/yyyy').format(consulta.data)}?',
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: () async {
              await ConsultaDAO().delete(consulta.id!);
              Navigator.pop(context);
              _carregarConsultas();
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

    final todasConsultas = await ConsultaDAO().getByUsuario(widget.usuarioId);

    final filtradas = todasConsultas.where((c) {
      String petNome;
      try {
        petNome = pets.firstWhere((p) => p.id == c.petId).nome.toLowerCase();
      } catch (_) {
        petNome = '';
      }

      final mapa = {
        'pet': petNome,
        'motivo': c.motivo.toLowerCase(),
        'veterinário': c.veterinario.toLowerCase(),
        'tratamento': c.tratamento.toLowerCase(),
        'data': DateFormat('dd/MM/yyyy').format(c.data).toLowerCase(),
        'próxima': c.proxima != null
            ? DateFormat('dd/MM/yyyy').format(c.proxima!).toLowerCase()
            : '',
      };
      return mapa[campo]?.contains(valor) ?? false;
    }).toList();

    filtradas.sort((a, b) {
      final dataCompare = a.data.compareTo(b.data);
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
      consultas = filtradas;
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
                _buildListaConsultas(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          IconButton(
            icon: Image.asset('assets/icons/back.png', width: 32, height: 32),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'CONSULTAS',
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
              onChanged: (value) {
                setState(() {
                  filtroCampoSelecionado = value!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE6E6E6),
                prefixIcon: const Icon(Icons.filter_alt, color: Colors.black54),
                hintText: 'Campo para filtrar',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Pet', child: Text('Pet')),
                DropdownMenuItem(value: 'Motivo', child: Text('Motivo')),
                DropdownMenuItem(value: 'Veterinário', child: Text('Veterinário')),
                DropdownMenuItem(value: 'Tratamento', child: Text('Tratamento')),
                DropdownMenuItem(value: 'Data', child: Text('Data')),
                DropdownMenuItem(value: 'Próxima', child: Text('Próxima')),
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
                onPressed: _incluirConsulta,
                icon: const Icon(Icons.add, color: Colors.black, size: 20),
                label: const Text(
                  'Incluir',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _aplicarFiltro,
                icon: Image.asset('assets/icons/lupa.png', width: 28, height: 28),
                label: const Text(
                  'Pesquisar',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                ),
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

  Widget _buildListaConsultas() {
    return Expanded(
      child: Container(
        color: Colors.black12,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: consultas.length,
          itemBuilder: (context, index) {
            final c = consultas[index];
            String petNome;
            try {
              petNome = pets.firstWhere((p) => p.id == c.petId).nome;
            } catch (e) {
              petNome = 'Desconhecido';
            }
            return _buildCardConsulta(c, petNome);
          },
        ),
      ),
    );
  }

  Widget _buildCardConsulta(Consulta c, String petNome) {
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
                  DateFormat('dd/MM/yyyy').format(c.data),
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/editar.png', width: 36, height: 36),
                      onPressed: () => _editarConsulta(c),
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/excluir.png', width: 36, height: 36),
                      onPressed: () => _confirmarExclusao(c),
                    ),
                  ],
                )
              ],
            ),
            Text('Pet: $petNome', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Motivo: ${c.motivo}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Veterinário: ${c.veterinario}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Tratamento: ${c.tratamento}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Peso: ${c.peso.toStringAsFixed(1)} kg', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text(
              'Próxima: ${c.proxima != null ? DateFormat('dd/MM/yyyy').format(c.proxima!) : '-'}',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
