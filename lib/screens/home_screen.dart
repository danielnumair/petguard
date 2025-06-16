import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildBotao({
    required String texto,
    required String assetIcon,
    required VoidCallback onTap,
    bool pequeno = false,
  }) {
    return SizedBox(
      width: pequeno ? 180 : 300,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: pequeno ? 16 : 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetIcon,
              height: pequeno ? 22 : 36,
              width: pequeno ? 22 : 36,
            ),
            const SizedBox(width: 12),
            Text(
              texto,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int usuarioId = ModalRoute.of(context)!.settings.arguments as int;
    return Scaffold(
      resizeToAvoidBottomInset: false, // 🔥 Mantém os botões fixos, sem interferência do teclado
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 220),
                  _buildBotao(
                    texto: 'MEUS PETS',
                    assetIcon: 'assets/icons/pet.png',
                    onTap: () => Navigator.pushNamed(context, '/pets', arguments: usuarioId),
                  ),
                  const SizedBox(height: 16),
                  _buildBotao(
                    texto: 'CONSULTAS',
                    assetIcon: 'assets/icons/consulta.png',
                    onTap: () => Navigator.pushNamed(context, '/consultas', arguments: usuarioId),
                  ),
                  const SizedBox(height: 16),
                  _buildBotao(
                    texto: 'VACINAS',
                    assetIcon: 'assets/icons/vacina.png',
                    onTap: () => Navigator.pushNamed(context, '/vacinas', arguments: usuarioId),
                  ),
                  const SizedBox(height: 16),
                  _buildBotao(
                    texto: 'VERMÍFUGO',
                    assetIcon: 'assets/icons/vermifugo.png',
                    onTap: () => Navigator.pushNamed(context, '/vermifugos', arguments: usuarioId),
                  ),
                  const SizedBox(height: 24),
                  _buildBotao(
                    texto: 'SAIR',
                    assetIcon: 'assets/icons/sair.png',
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    pequeno: true,
                  ),
                ],
              ),
            ),
          ),

          // 🔧 Botão de configurações no canto inferior direito
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/configuracoes',arguments: usuarioId),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x26000000),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/config.png',
                  width: 48,
                  height: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
