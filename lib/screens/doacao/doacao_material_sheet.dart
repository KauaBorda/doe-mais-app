import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/campanha.dart';
import '../../models/categoria_doacao.dart';
import '../../models/item_doacao.dart';
import '../../providers/auth_provider.dart';
import '../../services/doacao_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class DoacaoMaterialSheet extends StatefulWidget {
  const DoacaoMaterialSheet({
    super.key,
    required this.campanha,
    required this.onDoacaoRealizada,
  });

  final CampanhaDetalhe campanha;
  final VoidCallback onDoacaoRealizada;

  @override
  State<DoacaoMaterialSheet> createState() => _DoacaoMaterialSheetState();
}

class _DoacaoMaterialSheetState extends State<DoacaoMaterialSheet> {
  final _service = DoacaoService();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _obsItemController = TextEditingController();

  List<CategoriaDoacao> _categorias = [];
  List<ItemDoacao> _itens = [];
  CategoriaDoacao? _categoriaSelecionada;
  ItemDoacao? _itemSelecionado;
  EstadoItem _estado = EstadoItem.novo;
  DateTime? _validade;

  final List<ItemDoacaoSelecionado> _itensAdicionados = [];

  bool _carregandoCategorias = true;
  bool _carregandoItens = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _observacoesController.dispose();
    _quantidadeController.dispose();
    _obsItemController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await _service.listarCategorias();
      if (!mounted) return;
      setState(() => _categorias = categorias);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _carregandoCategorias = false);
    }
  }

  Future<void> _selecionarCategoria(CategoriaDoacao? categoria) async {
    setState(() {
      _categoriaSelecionada = categoria;
      _itemSelecionado = null;
      _itens = [];
      _carregandoItens = categoria != null;
    });
    if (categoria == null) return;
    try {
      final itens = await _service.listarItensPorCategoria(categoria.idCategoria);
      if (!mounted) return;
      setState(() => _itens = itens);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _carregandoItens = false);
    }
  }

  void _adicionarItem() {
    final item = _itemSelecionado;
    final quantidade = double.tryParse(_quantidadeController.text.replaceAll(',', '.'));
    if (item == null || quantidade == null || quantidade <= 0) return;

    setState(() {
      _itensAdicionados.removeWhere((e) => e.item.idItem == item.idItem);
      _itensAdicionados.add(ItemDoacaoSelecionado(
        item: item,
        quantidade: quantidade,
        estado: _estado,
        validade: item.perecivel ? _validade : null,
        observacoes: _obsItemController.text.trim(),
      ));
      _itemSelecionado = null;
      _quantidadeController.text = '1';
      _estado = EstadoItem.novo;
      _validade = null;
      _obsItemController.clear();
    });
  }

  void _removerItem(int idItem) {
    setState(() => _itensAdicionados.removeWhere((e) => e.item.idItem == idItem));
  }

  Future<void> _confirmar() async {
    if (_itensAdicionados.isEmpty) {
      setState(() => _error = 'Adicione pelo menos um item');
      return;
    }
    if (_descricaoController.text.trim().isEmpty) {
      setState(() => _error = 'Informe uma descrição geral');
      return;
    }

    final auth = context.read<AuthProvider>();
    final idDoador = auth.session?.idDoador;
    if (idDoador == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _service.registrarMaterial(
        idDoador: idDoador,
        idOng: widget.campanha.idOng,
        idCampanha: widget.campanha.idCampanha,
        descricaoGeral: _descricaoController.text.trim(),
        observacoes: _observacoesController.text.trim(),
        itens: _itensAdicionados,
      );
      widget.onDoacaoRealizada();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doação material registrada! Obrigado pela contribuição.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarValidade() async {
    final now = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (data != null) setState(() => _validade = data);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.campanha.titulo,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Adicionar item',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _carregandoCategorias
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : DropdownButtonFormField<CategoriaDoacao>(
                              initialValue: _categoriaSelecionada,
                              decoration: const InputDecoration(labelText: 'Categoria'),
                              dropdownColor: AppColors.bgSecondary,
                              items: _categorias
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c.nome)))
                                  .toList(),
                              onChanged: _selecionarCategoria,
                            ),
                      if (_categoriaSelecionada != null) ...[
                        const SizedBox(height: 12),
                        _carregandoItens
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : DropdownButtonFormField<ItemDoacao>(
                                initialValue: _itemSelecionado,
                                decoration: const InputDecoration(labelText: 'Item'),
                                dropdownColor: AppColors.bgSecondary,
                                items: _itens
                                    .map((i) => DropdownMenuItem(
                                        value: i, child: Text('${i.nome} (${i.unidadeMedida})')))
                                    .toList(),
                                onChanged: (item) => setState(() => _itemSelecionado = item),
                              ),
                      ],
                      if (_itemSelecionado != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Quantidade',
                                controller: _quantidadeController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<EstadoItem>(
                                initialValue: _estado,
                                decoration: const InputDecoration(labelText: 'Estado'),
                                dropdownColor: AppColors.bgSecondary,
                                items: EstadoItem.values
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                                    .toList(),
                                onChanged: (e) => setState(() => _estado = e ?? EstadoItem.novo),
                              ),
                            ),
                          ],
                        ),
                        if (_itemSelecionado!.perecivel) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _selecionarValidade,
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Validade'),
                              child: Text(
                                _validade != null ? Formatters.date(_validade) : 'Selecionar data',
                                style: const TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Observação do item (opcional)',
                          controller: _obsItemController,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _adicionarItem,
                            icon: const Icon(Icons.add_rounded, color: AppColors.success),
                            label: const Text('Adicionar item',
                                style: TextStyle(color: AppColors.success)),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.success)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_itensAdicionados.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Itens adicionados (${_itensAdicionados.length})',
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ..._itensAdicionados.map((it) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${it.item.nome} · ${it.quantidade} ${it.item.unidadeMedida} · ${it.estado.label}',
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.danger, size: 18),
                              onPressed: () => _removerItem(it.item.idItem),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Descrição geral',
                  controller: _descricaoController,
                  hintText: 'Ex: Doação de roupas de inverno',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Observações (opcional)',
                  controller: _observacoesController,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Confirmar doação material',
                  icon: Icons.inventory_2_rounded,
                  isLoading: _isLoading,
                  onPressed: _itensAdicionados.isEmpty ? null : _confirmar,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
