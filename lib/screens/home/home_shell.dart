import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../campanhas/campanhas_list_screen.dart';
import '../doacoes/minhas_doacoes_screen.dart';
import '../perfil/perfil_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // Cada aba é reconstruída do zero ao ser selecionada (em vez de um
  // IndexedStack), para que Campanhas/Doações sempre recarreguem dados
  // atuais da API — refletindo doações feitas em outras abas.
  Widget _buildScreen(int index) => switch (index) {
        0 => const CampanhasListScreen(),
        1 => const MinhasDoacoesScreen(),
        _ => const PerfilScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism_rounded, color: AppColors.accentPink),
            label: 'Campanhas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded, color: AppColors.accentPink),
            label: 'Doações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded, color: AppColors.accentPink),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
