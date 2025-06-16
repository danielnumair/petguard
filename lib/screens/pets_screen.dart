import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/pet_dao.dart';
import '../models/pet.dart';
import 'cadastro_pet_screen.dart';
import '../widgets/cadastro_input.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  late int usuarioId;
  List<Pet> pets = [];
  String filtroCampoSelecionado = 'Pet';
  final filtroValorController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    usuarioId = ModalRoute.of(context)!.settings.arguments as int;
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    final lista = await PetDAO().getByUsuario(usuarioId);
    lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    setState(() {
      pets = lista;
    });
  }

  void _editarPet(Pet pet) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPetScreen(usuarioId: usuarioId, pet: pet),
      ),
    );
    if (atualizado == true) _carregarPets();
  }

  void _incluirPet() async {
    final cadastrado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPetScreen(usuarioId: usuarioId),
      ),
    );
    if (cadastrado == true) _carregarPets();
  }

  void _aplicarFiltro() async {
    final campo = filtroCampoSelecionado.toLowerCase();
    final valor = filtroValorController.text.toLowerCase();
    final todosPets = await PetDAO().getByUsuario(usuarioId);
    final filtrados = todosPets.where((pet) {
      final mapa = {
        'pet': pet.nome.toLowerCase(),
        'espécie': pet.especie.toLowerCase(),
        'raça': pet.raca.toLowerCase(),
        'sexo': pet.sexo.toLowerCase(),
        'data de nascimento': pet.dataNascimento != null
            ? DateFormat('dd/MM/yyyy').format(pet.dataNascimento!).toLowerCase()
            : '',
      };
      return mapa[campo]?.contains(valor) ?? false;
    }).toList();
    setState(() {
      pets = filtrados;
    });
  }

  void _confirmarExclusao(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6E6E6),
        title: const Text('Confirmar exclusão', style: TextStyle(fontFamily: 'Montserrat')),
        content: Text('Deseja realmente excluir o pet "${pet.nome}"?', style: const TextStyle(fontFamily: 'Montserrat')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: () async {
              await PetDAO().delete(pet.id!);
              Navigator.pop(context);
              _carregarPets();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontFamily: 'Montserrat')),
          ),
        ],
      ),
    );
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
                Container(
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
                        'MEUS PETS',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF4F4F4F),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: const Color(0xFFF7931E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: const Color(0xFFE6E6E6),
                        ),
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
                            hintStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Pet', child: Text('Pet')),
                            DropdownMenuItem(value: 'Espécie', child: Text('Espécie')),
                            DropdownMenuItem(value: 'Raça', child: Text('Raça')),
                            DropdownMenuItem(value: 'Sexo', child: Text('Sexo')),
                            DropdownMenuItem(value: 'Data de Nascimento', child: Text('Data de Nascimento')),
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
                            onPressed: _incluirPet,
                            icon: const Icon(Icons.add, color: Colors.black, size: 20),
                            label: const Text('Incluir', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _aplicarFiltro,
                            icon: Image.asset('assets/icons/lupa.png', width: 28, height: 28),
                            label: const Text('Pesquisar', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
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
                ),
                const Divider(thickness: 1.5, height: 1.5, color: Colors.black54),
                Expanded(
                  child: Container(
                    color: Colors.black12,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return _buildCardPet(pet);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPet(Pet pet) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: const Color(0xFFE6E6E6),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF4F4F4F),
                      child: Text(pet.nome[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      pet.nome,
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/editar.png', width: 40, height: 40),
                      onPressed: () => _editarPet(pet),
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/excluir.png', width: 40, height: 40),
                      onPressed: () => _confirmarExclusao(pet),
                    ),
                  ],
                )
              ],
            ),
            Text('Espécie: ${pet.especie}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Raça: ${pet.raca}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text('Sexo: ${pet.sexo}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)),
            Text(
                'Nascimento: ${pet.dataNascimento != null ? DateFormat('dd/MM/yyyy').format(pet.dataNascimento!) : '-'}',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }
}
