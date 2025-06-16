import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vermifugo.dart';
import '../models/pet.dart';
import '../database/vermifugo_dao.dart';
import '../database/pet_dao.dart';
import '../widgets/cadastro_input.dart';

class CadastroVermifugoScreen extends StatefulWidget {
  final int usuarioId;
  final Vermifugo? vermifugo;

  const CadastroVermifugoScreen({
    super.key,
    required this.usuarioId,
    this.vermifugo,
  });

  @override
  State<CadastroVermifugoScreen> createState() => _CadastroVermifugoScreenState();
}

class _CadastroVermifugoScreenState extends State<CadastroVermifugoScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Pet> pets = [];
  Pet? petSelecionado;

  final produtoController = TextEditingController();
  final pesoController = TextEditingController();
  final doseController = TextEditingController();

  DateTime? data;
  DateTime? proxima;

  // Adicionar FocusNode
  final focusProduto = FocusNode();
  final focusPeso = FocusNode();
  final focusDose = FocusNode();

  @override
  void initState() {
    super.initState();
    _carregarPets();

    if (widget.vermifugo != null) {
      produtoController.text = widget.vermifugo!.produto;
      pesoController.text = widget.vermifugo!.peso.toString();
      doseController.text = widget.vermifugo!.dose;
      data = widget.vermifugo!.data;
      proxima = widget.vermifugo!.proxima;
    }
  }

  Future<void> _carregarPets() async {
    final lista = await PetDAO().getByUsuario(widget.usuarioId);
    setState(() {
      pets = lista;
      if (widget.vermifugo != null) {
        petSelecionado = pets.firstWhere(
              (pet) => pet.id == widget.vermifugo!.petId,
          orElse: () => pets.isNotEmpty ? pets.first : throw Exception('Nenhum pet encontrado'),
        );
      }
    });
  }

  Future<void> _selecionarData(BuildContext context,bool ehDataAplicacao) async {
    final DateTime? selecionada = await showDatePicker(
      locale: const Locale("pt", "BR"),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black54,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionada != null) {
      setState(() {
        if (ehDataAplicacao) {
          data = selecionada;
        } else {
          proxima = selecionada;
        }
      });
    }
  }


  void _salvarVermifugo() async {
    if (!_formKey.currentState!.validate()) return;

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE6E6E6),
          content: Text(
            'Selecione a data da aplicação',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      );
      return;
    }

    if (petSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE6E6E6),
          content: Text(
            'Selecione um pet',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      );
      return;
    }

    try {
      final novoVermifugo = Vermifugo(
        id: widget.vermifugo?.id,
        petId: petSelecionado!.id!,
        produto: produtoController.text,
        peso: double.tryParse(pesoController.text.replaceAll(',', '.')) ?? 0,
        dose: doseController.text,
        data: data!,
        proxima: proxima, // aqui pode ser nulo sem problema
      );

      if (widget.vermifugo == null) {
        await VermifugoDAO().insert(novoVermifugo);
      } else {
        await VermifugoDAO().update(novoVermifugo);
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFE6E6E6),
            title: const Text(
              'Sucesso',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Text(
              widget.vermifugo == null
                  ? 'Vermífugo cadastrado com sucesso!'
                  : 'Vermífugo atualizado com sucesso!',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFE6E6E6),
            title: const Text(
              'Erro',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Text(
              'Ocorreu um erro ao salvar o vermífugo:\n$e',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }



  @override
  void dispose() {
    focusProduto.dispose();
    focusPeso.dispose();
    focusDose.dispose();

    produtoController.dispose();
    pesoController.dispose();
    doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/cadastro_background.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo_cinza.png', height: 200),
                      const SizedBox(height: 8),
                      const Text(
                        'CADASTRO DE VERMÍFUGO',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF4F4F4F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown de pets
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: const Color(0xFFE6E6E6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<Pet>(
                            value: petSelecionado,
                            validator: (value) =>
                            value == null ? 'Selecione o pet' : null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFE6E6E6),
                              prefixIcon: const Icon(Icons.pets, color: Colors.black54),
                              hintText: 'Selecione o Pet',
                              hintStyle: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              errorStyle: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            items: pets
                                .map(
                                  (pet) => DropdownMenuItem(
                                value: pet,
                                child: Text(
                                  pet.nome,
                                  style: const TextStyle(fontFamily: 'Montserrat'),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (Pet? value) {
                              setState(() {
                                petSelecionado = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CadastroInput(
                        hint: 'Produto',
                        icon: Icons.medication,
                        controller: produtoController,
                        focusNode: focusProduto,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(focusPeso);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o produto';
                          }
                          return null;
                        },
                      ),
                      CadastroInput(
                        hint: 'Peso (kg)',
                        icon: Icons.monitor_weight,
                        controller: pesoController,
                        keyboardType: TextInputType.number,
                        focusNode: focusPeso,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(focusDose);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o peso';
                          }
                          return null;
                        },
                      ),
                      CadastroInput(
                        hint: 'Dose',
                        icon: Icons.vaccines,
                        controller: doseController,
                        focusNode: focusDose,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a dose';
                          }
                          return null;
                        },
                      ),
                      // Datas
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selecionarData(context, true),
                              child: AbsorbPointer(
                                child: CadastroInput(
                                  hint: 'Data',
                                  icon: Icons.calendar_month,
                                  controller: TextEditingController(
                                    text: data != null
                                        ? DateFormat('dd/MM/yyyy').format(data!)
                                        : '',
                                  ),
                                  validator: (value) {
                                    if (data == null) {
                                      return 'Informe a data';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selecionarData(context, false),
                              child: AbsorbPointer(
                                child: CadastroInput(
                                  hint: 'Próxima',
                                  icon: Icons.calendar_month,
                                  controller: TextEditingController(
                                    text: proxima != null
                                        ? DateFormat('dd/MM/yyyy').format(proxima!)
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              label: const Text(
                                'Voltar',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _salvarVermifugo,
                              icon: const Icon(Icons.save, color: Colors.black),
                              label: const Text(
                                'Salvar',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
