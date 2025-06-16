import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/cadastro_input.dart';
import '../models/pet.dart';
import '../database/pet_dao.dart';

class CadastroPetScreen extends StatefulWidget {
  final int usuarioId;
  final Pet? pet;
  const CadastroPetScreen({super.key, required this.usuarioId, this.pet});

  @override
  State<CadastroPetScreen> createState() => _CadastroPetScreenState();
}

class _CadastroPetScreenState extends State<CadastroPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final especieController = TextEditingController();
  final racaController = TextEditingController();
  final sexoController = TextEditingController();
  final obsController = TextEditingController();

  DateTime? dataNascimento;

  final FocusNode nomeFocus = FocusNode();
  final FocusNode especieFocus = FocusNode();
  final FocusNode racaFocus = FocusNode();
  final FocusNode obsFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.pet != null) {
      final pet = widget.pet!;
      nomeController.text = pet.nome;
      especieController.text = pet.especie;
      racaController.text = pet.raca;
      sexoController.text = pet.sexo;
      dataNascimento = pet.dataNascimento;
      obsController.text = pet.observacoes;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    especieController.dispose();
    racaController.dispose();
    sexoController.dispose();
    obsController.dispose();

    nomeFocus.dispose();
    especieFocus.dispose();
    racaFocus.dispose();
    obsFocus.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
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
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dataNascimento = picked;
      });
    }
  }

  void _salvarCadastro() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pet = Pet(
          id: widget.pet?.id,
          nome: nomeController.text,
          especie: especieController.text,
          raca: racaController.text,
          sexo: sexoController.text,
          dataNascimento: dataNascimento,
          observacoes: obsController.text,
          usuarioId: widget.usuarioId,
        );

        if (widget.pet == null) {
          await PetDAO().insert(pet);
        } else {
          await PetDAO().update(pet);
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
                widget.pet == null
                    ? 'Pet cadastrado com sucesso!'
                    : 'Pet atualizado com sucesso!',
                style: TextStyle(
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
                  color: Colors.red, // Título em vermelho
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Text(
                'Ocorreu um erro ao salvar o pet:\n$e',
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
  }

  @override
  Widget build(BuildContext context) {
    final int usuarioId = widget.usuarioId;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/cadastro_background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery
                            .of(context)
                            .viewInsets
                            .bottom),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/logo_cinza.png',
                                    height: 250,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'CADASTRO DE PETS',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F4F4F),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              CadastroInput(
                                hint: 'Nome do pet',
                                icon: Icons.badge,
                                controller: nomeController,
                                focusNode: nomeFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(especieFocus);
                                },
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Informe o nome' : null,
                              ),

                              // Espécie
                              CadastroInput(
                                hint: 'Espécie',
                                icon: Icons.pets,
                                controller: especieController,
                                focusNode: especieFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(racaFocus);
                                },
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Informe a espécie' : null,
                              ),

                              // Raça
                              CadastroInput(
                                hint: 'Raça',
                                icon: Icons.adb,
                                controller: racaController,
                                focusNode: racaFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Informe a raça' : null,
                              ),

                              // Sexo + Data de Nascimento
                              Row(
                                children: [
                                  Expanded(
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: const Color(0xFFE6E6E6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 12, right: 6),
                                        child: DropdownButtonFormField<String>(
                                          value: sexoController.text.isNotEmpty ? sexoController.text : null,
                                          validator: (value) => value == null || value.isEmpty ? 'Informe o sexo' : null,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xFFE6E6E6),
                                            prefixIcon: const Icon(Icons.transgender, color: Colors.black54),
                                            hintText: 'Sexo',
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
                                            errorStyle: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                                            DropdownMenuItem(value: 'Femea', child: Text('Fêmea')),
                                          ],
                                          onChanged: (value) {
                                            sexoController.text = value ?? '';
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _selectDate,
                                      child: AbsorbPointer(
                                        child: CadastroInput(
                                          hint: 'Nascimento',
                                          icon: Icons.calendar_month,
                                          controller:TextEditingController(
                                            text: dataNascimento != null
                                                ? DateFormat('dd/MM/yyyy').format(dataNascimento!)
                                                : '',
                                          ),
                                          validator: (value) {
                                            if (value != null && !value.isEmpty) {
                                              try {
                                                final data = DateFormat(
                                                    'dd/MM/yyyy').parseStrict(
                                                    value);
                                                if (data.isAfter(
                                                    DateTime.now())) {
                                                  return 'Data futura inválida';
                                                }
                                              } catch (_) {
                                                return 'Data inválida';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Observações
                              CadastroInput(
                                hint: 'Observações',
                                icon: Icons.note_alt,
                                controller: obsController,
                                focusNode: obsFocus,
                                maxLines: 4,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                },
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _salvarCadastro,
                                      icon: const Icon(Icons.save, color: Colors.black),
                                      label: const Text(
                                        'Salvar',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
