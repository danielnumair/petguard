import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/config_dao.dart';
import '../models/config.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  late int usuarioId;

  bool lembreteConsulta = false;
  bool lembreteVacina = false;
  bool lembreteVermifugo = false;

  final diasConsultaController = TextEditingController(text: '0');
  final diasVacinaController = TextEditingController(text: '0');
  final diasVermifugoController = TextEditingController(text: '0');

  final FocusNode _consultaFocus = FocusNode();
  final FocusNode _vacinaFocus = FocusNode();
  final FocusNode _vermifugoFocus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    usuarioId = ModalRoute.of(context)!.settings.arguments as int;
    _carregarConfiguracoes();
  }

  @override
  void dispose() {
    diasConsultaController.dispose();
    diasVacinaController.dispose();
    diasVermifugoController.dispose();
    _consultaFocus.dispose();
    _vacinaFocus.dispose();
    _vermifugoFocus.dispose();
    super.dispose();
  }

  Future<void> _carregarConfiguracoes() async {
    final config = await ConfigDAO().getByUsuario(usuarioId);

    setState(() {
      lembreteConsulta = config?.lembreteConsulta ?? false;
      lembreteVacina = config?.lembreteVacina ?? false;
      lembreteVermifugo = config?.lembreteVermifugo ?? false;
      diasConsultaController.text = (config?.diasConsulta ?? 0).toString();
      diasVacinaController.text = (config?.diasVacina ?? 0).toString();
      diasVermifugoController.text = (config?.diasVermifugo ?? 0).toString();
    });
  }

  Future<void> _salvarConfiguracoes() async {
    final temPermissao = await _verificarPermissaoNotificacoes();

    if (!temPermissao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de notificações não concedida.')),
      );
      return;
    }

    final config = Config(
      usuarioId: usuarioId,
      lembreteConsulta: lembreteConsulta,
      lembreteVacina: lembreteVacina,
      lembreteVermifugo: lembreteVermifugo,
      diasConsulta: int.tryParse(diasConsultaController.text) ?? 0,
      diasVacina: int.tryParse(diasVacinaController.text) ?? 0,
      diasVermifugo: int.tryParse(diasVermifugoController.text) ?? 0,
    );

    await ConfigDAO().salvar(config);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<bool> _verificarPermissaoNotificacoes() async {
    var status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      final abriuConfiguracoes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permissão necessária'),
          content: const Text(
            'Para ativar os lembretes, permita notificações nas configurações do sistema.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await openAppSettings();
                Navigator.pop(ctx, true);
              },
              child: const Text('Abrir Configurações'),
            ),
          ],
        ),
      );

      if (abriuConfiguracoes == true) {
        await Future.delayed(const Duration(seconds: 1));
        status = await Permission.notification.status;
        return status.isGranted;
      }

      return false;
    }

    final request = await Permission.notification.request();
    return request.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 170),
                    const Text(
                      'NOTIFICAÇÕES:',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLinhaNotificacao(
                      checked: lembreteConsulta,
                      onChanged: (value) {
                        setState(() => lembreteConsulta = value ?? false);
                      },
                      texto: 'Lembrete de consultas',
                      controller: diasConsultaController,
                      focusNode: _consultaFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_vacinaFocus);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLinhaNotificacao(
                      checked: lembreteVacina,
                      onChanged: (value) {
                        setState(() => lembreteVacina = value ?? false);
                      },
                      texto: 'Lembrete de vacinas',
                      controller: diasVacinaController,
                      focusNode: _vacinaFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_vermifugoFocus);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLinhaNotificacao(
                      checked: lembreteVermifugo,
                      onChanged: (value) {
                        setState(() => lembreteVermifugo = value ?? false);
                      },
                      texto: 'Lembrete de vermífugos',
                      controller: diasVermifugoController,
                      focusNode: _vermifugoFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: _salvarConfiguracoes,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
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
    );
  }

  Widget _buildLinhaNotificacao({
    required bool checked,
    required ValueChanged<bool?> onChanged,
    required String texto,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: onChanged,
          activeColor: Colors.black,
          checkColor: Colors.white,
          side: const BorderSide(color: Colors.black),
        ),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'dias',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
