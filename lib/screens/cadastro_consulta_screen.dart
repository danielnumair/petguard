import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consulta.dart';
import '../models/pet.dart';
import '../database/consulta_dao.dart';
import '../database/pet_dao.dart';
import '../widgets/cadastro_input.dart';
import 'package:flutter/services.dart';

class CadastroConsultaScreen extends StatefulWidget {
  final int usuarioId;
  final Consulta? consulta;

  const CadastroConsultaScreen({
    super.key,
    required this.usuarioId,
    this.consulta,
  });

  @override
  State<CadastroConsultaScreen> createState() => _CadastroConsultaScreenState();
}

class _CadastroConsultaScreenState extends State<CadastroConsultaScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Pet> pets = [];
  Pet? petSelecionado;

  final motivoController = TextEditingController();
  final veterinarioController = TextEditingController();
  final crmvController = TextEditingController();
  final pesoController = TextEditingController();
  final tratamentoController = TextEditingController();

  DateTime? dataConsulta;
  DateTime? dataProxima;

  // Focus nodes
  final FocusNode motivoFocus = FocusNode();
  final FocusNode veterinarioFocus = FocusNode();
  final FocusNode crmvFocus = FocusNode();
  final FocusNode pesoFocus = FocusNode();
  final FocusNode tratamentoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _carregarPets();

    if (widget.consulta != null) {
      motivoController.text = widget.consulta!.motivo;
      veterinarioController.text = widget.consulta!.veterinario;
      crmvController.text = widget.consulta!.crmv;
      pesoController.text = widget.consulta!.peso.toString();
      tratamentoController.text = widget.consulta!.tratamento;
      dataConsulta = widget.consulta!.data;
      dataProxima = widget.consulta!.proxima;
    }
  }

  Future<void> _carregarPets() async {
    final lista = await PetDAO().getByUsuario(widget.usuarioId);
    setState(() {
      pets = lista;
      if (widget.consulta != null) {
        petSelecionado = pets.firstWhere(
              (pet) => pet.id == widget.consulta!.petId,
          orElse: () => pets.isNotEmpty ? pets.first : throw Exception('Nenhum pet encontrado'),
        );
      }
    });
  }

  Future<void> _selecionarData(BuildContext context, bool ehDataConsulta) async {
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
    if (selecionada != null) {
      setState(() {
        if (ehDataConsulta) {
          dataConsulta = selecionada;
        } else {
          dataProxima = selecionada;
        }
      });
    }
  }

  void _salvarConsulta() async {
    if (!_formKey.currentState!.validate()) return;

    if (dataConsulta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE6E6E6),
          content: Text(
            'Selecione a data da consulta',
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
      final consulta = Consulta(
        id: widget.consulta?.id,
        petId: petSelecionado!.id!,
        motivo: motivoController.text,
        veterinario: veterinarioController.text,
        crmv: crmvController.text,
        peso: double.tryParse(pesoController.text.replaceAll(',', '.')) ?? 0,
        data: dataConsulta!,
        proxima: dataProxima,
        tratamento: tratamentoController.text,
      );

      if (widget.consulta == null) {
        await ConsultaDAO().insert(consulta);
      } else {
        await ConsultaDAO().update(consulta);
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
              widget.consulta == null
                  ? 'Consulta cadastrada com sucesso!'
                  : 'Consulta atualizada com sucesso!',
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
              'Ocorreu um erro ao salvar a consulta:\n$e',
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
    motivoController.dispose();
    veterinarioController.dispose();
    crmvController.dispose();
    pesoController.dispose();
    tratamentoController.dispose();

    motivoFocus.dispose();
    veterinarioFocus.dispose();
    crmvFocus.dispose();
    pesoFocus.dispose();
    tratamentoFocus.dispose();

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
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
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
                                'CADASTRO DE CONSULTAS',
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
                                hint: 'Motivo',
                                icon: Icons.info,
                                controller: motivoController,
                                focusNode: motivoFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(veterinarioFocus);
                                },
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Informe o motivo' : null,
                              ),
                              CadastroInput(
                                hint: 'Veterinário',
                                icon: Icons.person,
                                controller: veterinarioController,
                                focusNode: veterinarioFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(crmvFocus);
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CadastroInput(
                                      hint: 'CRMV',
                                      icon: Icons.badge,
                                      controller: crmvController,
                                      focusNode: crmvFocus,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(pesoFocus);
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: CadastroInput(
                                      hint: 'Peso (kg)',
                                      icon: Icons.monitor_weight,
                                      controller: pesoController,
                                      focusNode: pesoFocus,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(tratamentoFocus);
                                      },
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+[,|.]?\d{0,2}'))
                                      ],
                                    ),
                                  ),
                                ],
                              ),

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
                                            text: dataConsulta != null
                                                ? DateFormat('dd/MM/yyyy').format(dataConsulta!)
                                                : '',
                                          ),
                                          validator: (value) {
                                            if (dataConsulta == null) {
                                              return 'Informe a data da consulta';
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
                                          icon: Icons.event_repeat,
                                          controller: TextEditingController(
                                            text: dataProxima != null
                                                ? DateFormat('dd/MM/yyyy').format(dataProxima!)
                                                : '',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              CadastroInput(
                                hint: 'Tratamento',
                                icon: Icons.medical_information,
                                controller: tratamentoController,
                                focusNode: tratamentoFocus,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                maxLines: 4,
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
                                      onPressed: _salvarConsulta,
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
                              const SizedBox(height: 20)
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

  Widget _buildDatePicker(String label, DateTime? date, bool ehDataConsulta) {
    return GestureDetector(
      onTap: () => _selecionarData(context, ehDataConsulta),
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
