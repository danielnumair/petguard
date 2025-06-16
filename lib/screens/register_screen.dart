import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/usuario_dao.dart';
import '../models/usuario.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final _nomeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _senhaFocus = FocusNode();

  final _emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
  );
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _nomeFocus.dispose();
    _emailFocus.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_carregando) return;

    setState(() => _carregando = true);

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      setState(() => _carregando = false);
      return mostrarDialogoPersonalizado(context,
        titulo: 'Atenção',
        mensagem: 'Preencha todos os campos.',
      );
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() => _carregando = false);
      return mostrarDialogoPersonalizado(context,
        titulo: 'E-mail inválido',
        mensagem: 'Informe um e-mail válido.',
      );
    }

    if (senha.length < 6) {
      setState(() => _carregando = false);
      return mostrarDialogoPersonalizado(context,
        titulo: 'Senha fraca',
        mensagem: 'A senha deve ter no mínimo 6 caracteres.',
      );
    }

    final existe = await UsuarioDAO().emailExiste(email);
    if (existe) {
      setState(() => _carregando = false);
      return mostrarDialogoPersonalizado(context,
        titulo: 'E-mail já cadastrado',
        mensagem: 'Esse e-mail já está em uso.',
      );
    }

    final usuario = Usuario(nome: nome, email: email, senha: senha);
    await UsuarioDAO().insert(usuario);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('usuario_nome', usuario.nome);
    prefs.setString('usuario_email', usuario.email);

    setState(() => _carregando = false);

    mostrarDialogoPersonalizado(
      context,
      titulo: 'Sucesso',
      mensagem: 'Usuário cadastrado com sucesso!',
      onOk: () => Navigator.pop(context),
    );
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _cancelar,
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/background.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
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
                        'Tutor, crie sua conta:',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomInput(
                        label: 'Nome: ',
                        hint: 'Digite seu nome',
                        controller: _nomeController,
                        focusNode: _nomeFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocus);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: 'E-mail:',
                        hint: 'Digite seu e-mail',
                        controller: _emailController,
                        focusNode: _emailFocus,
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
                        onFieldSubmitted: (_) => _salvar(),
                      ),
                      const SizedBox(height: 16),
                      if (_carregando)
                        const CircularProgressIndicator()
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _cancelar,
                              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                              label: const Text(
                                'Voltar',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: _salvar,
                              icon: const Icon(Icons.save, color: Colors.black, size: 28),
                              label: const Text(
                                'Salvar',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
