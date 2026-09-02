import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/doador_service.dart';
import '../../widgets/loading_view.dart';
import '../auth/login_screen.dart';
import 'editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _doadorService = DoadorService();
  bool _enviandoFoto = false;

  Future<void> _trocarFoto() async {
    final auth = context.read<AuthProvider>();
    final idDoador = auth.session?.idDoador;
    if (idDoador == null) return;

    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (foto == null) return;

    setState(() => _enviandoFoto = true);
    try {
      final atualizado = await _doadorService.atualizarFoto(idDoador, File(foto.path));
      auth.updateDoador(atualizado);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _enviandoFoto = false);
    }
  }

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final doador = auth.doador;
          if (doador == null) return const LoadingView();

          final fotoUrl = ApiClient.resolveUrl(doador.fotoUrl);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.card,
                      backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
                      child: fotoUrl == null
                          ? const Icon(Icons.person_rounded, size: 48, color: AppColors.textSecondary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _enviandoFoto ? null : _trocarFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            gradient: AppColors.logoGradient,
                            shape: BoxShape.circle,
                          ),
                          child: _enviandoFoto
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                doador.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20),
              ),
              Text(
                doador.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              Card(
                child: Column(
                  children: [
                    _InfoTile(icon: Icons.badge_outlined, label: 'CPF/CNPJ', value: doador.cpfCnpj),
                    const Divider(height: 1, color: AppColors.border),
                    _InfoTile(icon: Icons.phone_outlined, label: 'Telefone', value: doador.telefone),
                    const Divider(height: 1, color: AppColors.border),
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Endereço',
                      value: [
                        doador.endereco,
                        doador.numero,
                        doador.cidade,
                        doador.estado,
                      ].where((e) => e != null && e.isNotEmpty).join(', '),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditarPerfilScreen()),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar perfil'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _sair,
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                label: const Text('Sair', style: TextStyle(color: AppColors.danger)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = (value == null || value!.isEmpty) ? 'Não informado' : value!;
    return ListTile(
      leading: Icon(icon, color: AppColors.accentPurple),
      title: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      subtitle: Text(display, style: const TextStyle(color: AppColors.textPrimary)),
    );
  }
}
