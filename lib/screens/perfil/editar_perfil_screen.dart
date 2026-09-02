import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../services/doador_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DoadorService();

  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _enderecoController;
  late final TextEditingController _numeroController;
  late final TextEditingController _complementoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _cidadeController;
  late final TextEditingController _estadoController;
  late final TextEditingController _cepController;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final doador = context.read<AuthProvider>().doador!;
    _nomeController = TextEditingController(text: doador.nome);
    _telefoneController = TextEditingController(text: doador.telefone ?? '');
    _enderecoController = TextEditingController(text: doador.endereco ?? '');
    _numeroController = TextEditingController(text: doador.numero ?? '');
    _complementoController = TextEditingController(text: doador.complemento ?? '');
    _bairroController = TextEditingController(text: doador.bairro ?? '');
    _cidadeController = TextEditingController(text: doador.cidade ?? '');
    _estadoController = TextEditingController(text: doador.estado ?? '');
    _cepController = TextEditingController(text: doador.cep ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final atual = auth.doador!;
    final atualizado = atual.copyWith(
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      endereco: _enderecoController.text.trim(),
      numero: _numeroController.text.trim(),
      complemento: _complementoController.text.trim(),
      bairro: _bairroController.text.trim(),
      cidade: _cidadeController.text.trim(),
      estado: _estadoController.text.trim(),
      cep: _cepController.text.trim(),
    );

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final salvo = await _service.atualizar(atualizado);
      auth.updateDoador(salvo);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_error!, style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  label: 'Nome completo',
                  controller: _nomeController,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
                AppTextField(label: 'Telefone', controller: _telefoneController),
                const SizedBox(height: 24),
                const Text('Endereço',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                AppTextField(label: 'Rua/Avenida', controller: _enderecoController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: 'Número', controller: _numeroController)),
                    const SizedBox(width: 12),
                    Expanded(
                        flex: 2,
                        child:
                            AppTextField(label: 'Complemento', controller: _complementoController)),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(label: 'Bairro', controller: _bairroController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(flex: 2, child: AppTextField(label: 'Cidade', controller: _cidadeController)),
                    const SizedBox(width: 12),
                    Expanded(child: AppTextField(label: 'UF', controller: _estadoController)),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(label: 'CEP', controller: _cepController),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Salvar alterações', isLoading: _isLoading, onPressed: _salvar),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
