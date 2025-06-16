import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vacina.dart';
import '../models/pet.dart';
import '../database/vacina_dao.dart';
import '../database/pet_dao.dart';
import '../widgets/cadastro_input.dart';

class CadastroVacinaScreen extends StatefulWidget {
  final int usuarioId;
  final Vacina? vacina;

  const CadastroVacinaScreen({
    super.key,
    required this.usuarioId,
    this.vacina,
  });

  @override
  State<CadastroVacinaScreen> createState() => _CadastroVacinaScreenState();
}

class _CadastroVacinaScreenState extends State<CadastroVacinaScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Pet> pets = [];
  Pet? petSelecionado;

  final vacinaController = TextEditingController();
  final veterinarioController = TextEditingController();
  final crmvController = TextEditingController();
  final pesoController = TextEditingController();
  final loteController = TextEditingController();

  DateTime? fabricacao;
  DateTime? vencimento;
  DateTime? dataAplicacao;
  DateTime? proxima;

  final focusVacina = FocusNode();
  final focusVeterinario = FocusNode();
  final focusCrmv = FocusNode();
  final focusPeso = FocusNode();
  final focusLote = FocusNode();

  @override
  void initState() {
    super.initState();
    _carregarPets();

    if (widget.vacina != null) {
      final v = widget.vacina!;
      vacinaController.text = v.vacina;
      veterinarioController.text = v.veterinario;
      crmvController.text = v.crmv;
      pesoController.text = v.peso.toString();
      loteController.text = v.lote;
      fabricacao = v.fabricacao;
      vencimento = v.vencimento;
      dataAplicacao = v.dataAplicacao;
      proxima = v.proxima;
    }
  }



  Future<void> _carregarPets() async {
    final lista = await PetDAO().getByUsuario(widget.usuarioId);
    setState(() {
      pets = lista;
      if (widget.vacina != null) {
        petSelecionado = pets.firstWhere(
              (pet) => pet.id == widget.vacina!.petId,
          orElse: () => pets.isNotEmpty ? pets.first : throw Exception('Nenhum pet encontrado'),
        );
      }
    });
  }

  Future<void> _selecionarData(
      BuildContext context, DateTime? dataAtual, Function(DateTime) onSelecionada) async {
    final DateTime? selecionada = await showDatePicker(
      locale: const Locale("pt", "BR"),
      context: context,
      initialDate: dataAtual ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black54, // Cor do header
              onPrimary: Colors.white, // Cor dos textos do header
              onSurface: Colors.black, // Cor dos textos dos dias
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Botões cancelar/ok
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionada != null) {
      onSelecionada(selecionada);
    }
  }

  void _salvarVacina() async {
    if (!_formKey.currentState!.validate()) return;

    if (dataAplicacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE6E6E6),
          content: Text(
            'Selecione a data de aplicação',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      );
      return;
    }

    if (proxima == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE6E6E6),
          content: Text(
            'Selecione a data da próxima dose',
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
      final novaVacina = Vacina(
        id: widget.vacina?.id,
        petId: petSelecionado!.id!,
        vacina: vacinaController.text,
        veterinario: veterinarioController.text,
        crmv: crmvController.text,
        peso: double.tryParse(pesoController.text.replaceAll(',', '.')) ?? 0,
        lote: loteController.text,
        fabricacao: fabricacao,
        vencimento: vencimento,
        dataAplicacao: dataAplicacao!,
        proxima: proxima!,
      );

      if (widget.vacina == null) {
        await VacinaDAO().insert(novaVacina);
      } else {
        await VacinaDAO().update(novaVacina);
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
              widget.vacina == null
                  ? 'Vacina cadastrada com sucesso!'
                  : 'Vacina atualizada com sucesso!',
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
              'Ocorreu um erro ao salvar a vacina:\n$e',
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
    focusVacina.dispose();
    focusVeterinario.dispose();
    focusCrmv.dispose();
    focusPeso.dispose();
    focusLote.dispose();

    vacinaController.dispose();
    veterinarioController.dispose();
    crmvController.dispose();
    pesoController.dispose();
    loteController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              Image.asset(
                                'assets/images/logo_cinza.png',
                                height: 200,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'CADASTRO DE VACINAS',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
                              CadastroInput(
                                hint: 'Vacina',
                                icon: Icons.vaccines,
                                controller: vacinaController,
                                focusNode: focusVacina,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(focusVeterinario);
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe a vacina';
                                  }
                                  return null;
                                },
                              ),
                              CadastroInput(
                                hint: 'Veterinário',
                                icon: Icons.person,
                                controller: veterinarioController,
                                focusNode: focusVeterinario,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(focusCrmv);
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe o veterinário';
                                  }
                                  return null;
                                },
                              ),
                              CadastroInput(
                                hint: 'CRMV',
                                icon: Icons.badge,
                                controller: crmvController,
                                focusNode: focusCrmv,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(focusPeso);
                                },
                              ),
                              // Linha Peso + Lote
                              Row(
                                children: [
                                  Expanded(
                                    child: CadastroInput(
                                      hint: 'Peso (kg)',
                                      icon: Icons.monitor_weight,
                                      controller: pesoController,
                                      focusNode: focusPeso,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(focusLote);
                                      },
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: CadastroInput(
                                      hint: 'Lote',
                                      icon: Icons.numbers,
                                      controller: loteController,
                                      focusNode: focusLote,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // Linha Fabricação + Vencimento
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selecionarData(context, fabricacao, (data) {
                                        setState(() => fabricacao = data);
                                      }),
                                      child: AbsorbPointer(
                                        child: CadastroInput(
                                          hint: 'Fabricação',
                                          icon: Icons.calendar_month,
                                          controller: TextEditingController(
                                            text: fabricacao != null
                                                ? DateFormat('dd/MM/yyyy').format(fabricacao!)
                                                : '',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selecionarData(context, vencimento, (data) {
                                        setState(() => vencimento = data);
                                      }),
                                      child: AbsorbPointer(
                                        child: CadastroInput(
                                          hint: 'Vencto',
                                          icon: Icons.calendar_month,
                                          controller: TextEditingController(
                                            text: vencimento != null
                                                ? DateFormat('dd/MM/yyyy').format(vencimento!)
                                                : '',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Linha Data de Aplicação + Próxima Dose
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selecionarData(context, dataAplicacao, (data) {
                                        setState(() => dataAplicacao = data);
                                      }),
                                      child: AbsorbPointer(
                                        child: CadastroInput(
                                          hint: 'Aplicação',
                                          icon: Icons.calendar_month,
                                          controller: TextEditingController(
                                            text: dataAplicacao != null
                                                ? DateFormat('dd/MM/yyyy').format(dataAplicacao!)
                                                : '',
                                          ),
                                          validator: (value) {
                                            if (dataAplicacao == null) {
                                              return 'Informe a aplicação';
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
                                      onTap: () => _selecionarData(context, proxima, (data) {
                                        setState(() => proxima = data);
                                      }),
                                      child: AbsorbPointer(
                                        child: CadastroInput(
                                          hint: 'Próxima',
                                          icon: Icons.calendar_month,
                                          controller: TextEditingController(
                                            text: proxima != null
                                                ? DateFormat('dd/MM/yyyy').format(proxima!)
                                                : '',
                                          ),
                                          validator: (value) {
                                            if (proxima == null) {
                                              return 'Informe a próxima dose';
                                            }
                                            return null;
                                          },
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
                                      onPressed: _salvarVacina,
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

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onChanged) {
    return GestureDetector(
      onTap: () => _selecionarData(context, date, onChanged),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black54, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.black.withOpacity(0.6)),
            const SizedBox(width: 12),
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
