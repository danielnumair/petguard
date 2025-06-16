import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vermifugo.dart';
import '../models/pet.dart';
import '../database/vermifugo_dao.dart';
import '../database/pet_dao.dart';
import 'cadastro_vermifugo_screen.dart';
import '../widgets/cadastro_input.dart';

class VermifugosScreen extends StatefulWidget {
  final int usuarioId;

  const VermifugosScreen({super.key, required this.usuarioId});

  @override
  State<VermifugosScreen> createState() => _VermifugosScreenState();
}

class _VermifugosScreenState extends State<VermifugosScreen> {
  List<Vermifugo> vermifugos = [];
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
    _carregarVermifugos();
  }

  Future<void> _carregarVermifugos() async {
    final lista = await VermifugoDAO().getByUsuario(widget.usuarioId);

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
      vermifugos = lista;
    });
  }


  void _incluir() async {
    final cadastrado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroVermifugoScreen(usuarioId: widget.usuarioId),
      ),
    );
    if (cadastrado == true) _carregarVermifugos();
  }

  void _editar(Vermifugo item) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroVermifugoScreen(
          usuarioId: widget.usuarioId,
          vermifugo: item,
        ),
      ),
    );
    if (atualizado == true) _carregarVermifugos();
  }

  void _confirmarExclusao(Vermifugo item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6E6E6),
        title: const Text('Confirmar exclusão', style: TextStyle(fontFamily: 'Montserrat')),
        content: Text(
          'Deseja excluir o vermífugo de ${DateFormat('dd/MM/yyyy').format(item.data)}?',
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: () async {
              await VermifugoDAO().delete(item.id!);
              Navigator.pop(context);
              _carregarVermifugos();
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

    final todos = await VermifugoDAO().getByUsuario(widget.usuarioId);

    final filtrados = todos.where((v) {
      String petNome;
      try {
        petNome = pets.firstWhere((p) => p.id == v.petId).nome.toLowerCase();
      } catch (_) {
        petNome = 'desconhecido';
      }

      final mapa = {
        'pet': petNome,
        'produto': v.produto.toLowerCase(),
        'dose': v.dose.toLowerCase(),
        'data': DateFormat('dd/MM/yyyy').format(v.data).toLowerCase(),
        'proxima': v.proxima != null
            ? DateFormat('dd/MM/yyyy').format(v.proxima!).toLowerCase()
            : '',
      };
      return mapa[campo]?.contains(valor) ?? false;
    }).toList();

    filtrados.sort((a, b) {
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
      vermifugos = filtrados;
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
            'VERMÍFUGOS',
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
                DropdownMenuItem(value: 'Produto', child: Text('Produto')),
                DropdownMenuItem(value: 'Dose', child: Text('Dose')),
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
                onPressed: _incluir,
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

  Widget _buildLista() {
    return Expanded(
      child: Container(
        color: Colors.black12,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: vermifugos.length,
          itemBuilder: (context, index) {
            final v = vermifugos[index];
            String petNome;
            try {
              petNome = pets.firstWhere((p) => p.id == v.petId).nome;
            } catch (e) {
              petNome = 'Desconhecido';
            }
            return _buildCard(v, petNome);
          },
        ),
      ),
    );
  }

  Widget _buildCard(Vermifugo v, String petNome) {
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
                  DateFormat('dd/MM/yyyy').format(v.data),
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/editar.png', width: 36, height: 36),
                      onPressed: () => _editar(v),
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
            Text('Produto: ${v.produto}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Peso: ${v.peso.toStringAsFixed(1)} kg', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Dose: ${v.dose}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text(
              'Próxima: ${v.proxima != null ? DateFormat('dd/MM/yyyy').format(v.proxima!) : '-'}',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
            ),

          ],
        ),
      ),
    );
  }
}
