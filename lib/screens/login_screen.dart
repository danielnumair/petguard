import 'package:flutter/material.dart';
import '../database/usuario_dao.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _carregando = false;

  final FocusNode _loginFocus = FocusNode();
  final FocusNode _senhaFocus = FocusNode();

  Future<void> _login() async {
    if (_carregando) return;

    final login = _loginController.text.trim();
    final senha = _senhaController.text.trim();

    if (login.isEmpty || senha.isEmpty) {
      return mostrarDialogoPersonalizado(
        context,
        titulo: 'Atenção',
        mensagem: 'Preencha login e senha.',
      );
    }

    setState(() => _carregando = true);

    final usuario = await UsuarioDAO().login(login, senha);

    setState(() => _carregando = false);

    if (usuario != null) {
      Navigator.pushReplacementNamed(context, '/home', arguments: usuario.id);
    } else {
      mostrarDialogoPersonalizado(
        context,
        titulo: 'Erro',
        mensagem: 'Login ou senha inválidos.',
      );
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _senhaController.dispose();
    _loginFocus.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // oculta teclado
      child: Scaffold(
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
                    CustomInput(
                      label: 'Login: ',
                      hint: 'Digite seu nome ou e-mail',
                      controller: _loginController,
                      focusNode: _loginFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_senhaFocus);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Senha:',
                      hint: 'Digite sua senha',
                      controller: _senhaController,
                      obscure: true,
                      focusNode: _senhaFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 24),
                    if (_carregando)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login, color: Colors.grey, size: 28),
                        label: Text(
                          'Entrar',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'Criar conta',
                        style: TextStyle(
                            fontFamily: 'Montserrat',fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/recuperar'),
                      child: Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                            fontFamily: 'Montserrat',fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
