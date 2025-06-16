import 'package:flutter/material.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_dialog.dart';
import '../database/usuario_dao.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _recuperarSenha() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      mostrarDialogoPersonalizado(
        context,
        titulo: 'Atenção',
        mensagem: 'Informe seu e-mail.',
      );
      return;
    }

    final usuario = await UsuarioDAO().getByEmail(email);

    if (usuario != null) {
      mostrarDialogoPersonalizado(
        context,
        titulo: 'Sucesso',
        mensagem:
        'Sua senha é: "${usuario.senha}".\nRecomendamos que você altere após o login.',
      );
    } else {
      mostrarDialogoPersonalizado(
        context,
        titulo: 'Erro',
        mensagem: 'E-mail não encontrado.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  const Text(
                    'Recuperar Senha',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: 'E-mail:',
                    hint: 'Informe seu e-mail',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _recuperarSenha(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _recuperarSenha,
                    icon: const Icon(Icons.lock_reset, color: Colors.grey, size: 28),
                    label: const Text(
                      'Recuperar',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
