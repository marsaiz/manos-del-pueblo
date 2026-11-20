import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/adaptive_app_bar.dart';

class _MaterialEntry {
  final TextEditingController nameController;
  final TextEditingController costController;

  _MaterialEntry({String name = '', String cost = ''})
      : nameController = TextEditingController(text: name),
        costController = TextEditingController(text: cost);

  void dispose() {
    nameController.dispose();
    costController.dispose();
  }
}

class _CalculationMetrics {
  final int units;
  final double materialsSubtotal;
  final double wasteAmount;
  final double laborHoursTotal;
  final double laborCost;
  final double toolsWearAmount;
  final double kilnCost;
  final double replacementCost;
  final double baseProductionCost;
  final double directProfitAmount;
  final double directSaleTotal;
  final double wholesaleSaleTotal;
  final double packagingAndShippingTotal;
  final double finalWithShippingTotal;

  const _CalculationMetrics({
    required this.units,
    required this.materialsSubtotal,
    required this.wasteAmount,
    required this.laborHoursTotal,
    required this.laborCost,
    required this.toolsWearAmount,
    required this.kilnCost,
    required this.replacementCost,
    required this.baseProductionCost,
    required this.directProfitAmount,
    required this.directSaleTotal,
    required this.wholesaleSaleTotal,
    required this.packagingAndShippingTotal,
    required this.finalWithShippingTotal,
  });

  double perUnit(double total) => units > 0 ? total / units : total;
}

class CostCalculatorScreen extends StatefulWidget {
  const CostCalculatorScreen({super.key});

  @override
  State<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends State<CostCalculatorScreen> {
  static const Color _primaryBrown = Color(0xFF5D4037);
  static const Color _bgCream = Color(0xFFF5F5DC);
  static const Color _secondaryGray = Color(0xFF616161);

  static const String _keyHourlyRate = 'calc_hourly_rate';
  static const String _keyToolsPct = 'calc_tools_pct';
  static const String _keyKilnRate = 'calc_kiln_rate';
  static const String _keyProfitPct = 'calc_profit_pct';
  static const String _keyWholesalePct = 'calc_wholesale_pct';
  static const String _keySavedList = 'calc_saved_list';

  final GlobalKey _savedSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  // Módulo 1: Producto y Lote
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController(text: '1');

  // Módulo 2: Materiales y Merma
  final List<_MaterialEntry> _materials = [];
  double _wastePct = 0;

  // Módulo 3: Mano de Obra
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _workHoursController = TextEditingController(text: '1');
  final TextEditingController _workMinutesController = TextEditingController(text: '0');
  final TextEditingController _monthlyGoalController = TextEditingController();
  final TextEditingController _weeklyHoursController = TextEditingController(text: '30');

  // Módulo 4: Herramientas y Horno / Energía
  double _toolsPct = 10;
  bool _useKiln = false;
  final TextEditingController _kilnHoursController = TextEditingController(text: '0');
  final TextEditingController _kilnRateController = TextEditingController();

  // Módulo 5: Margen del Taller
  double _profitPct = 25;
  double _wholesalePct = 15;

  // Módulo 6: Embalaje y Envío
  bool _includeShipping = false;
  bool _isFragile = false;
  final TextEditingController _basicPackagingController = TextEditingController();
  final TextEditingController _extraProtectionController = TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();

  // Módulo 8: Cálculos guardados
  List<Map<String, dynamic>> _savedCalculations = [];
  String? _editingSavedId;

  @override
  void initState() {
    super.initState();
    _addMaterialRow();
    _loadPreferences();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _unitsController.dispose();
    for (final entry in _materials) {
      entry.dispose();
    }
    _hourlyRateController.dispose();
    _workHoursController.dispose();
    _workMinutesController.dispose();
    _monthlyGoalController.dispose();
    _weeklyHoursController.dispose();
    _kilnHoursController.dispose();
    _kilnRateController.dispose();
    _basicPackagingController.dispose();
    _extraProtectionController.dispose();
    _shippingCostController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hourlyRate = prefs.getDouble(_keyHourlyRate);
      final toolsPct = prefs.getDouble(_keyToolsPct);
      final kilnRate = prefs.getDouble(_keyKilnRate);
      final profitPct = prefs.getDouble(_keyProfitPct);
      final wholesalePct = prefs.getDouble(_keyWholesalePct);
      final savedRaw = prefs.getString(_keySavedList);

      List<Map<String, dynamic>> loadedList = [];
      if (savedRaw != null && savedRaw.isNotEmpty) {
        final decoded = jsonDecode(savedRaw);
        if (decoded is List) {
          loadedList = decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      if (!mounted) return;
      setState(() {
        if (hourlyRate != null && hourlyRate > 0) {
          _hourlyRateController.text = _formatInputNumber(hourlyRate);
        }
        if (toolsPct != null) _toolsPct = toolsPct.clamp(0, 30);
        if (kilnRate != null && kilnRate > 0) {
          _kilnRateController.text = _formatInputNumber(kilnRate);
        }
        if (profitPct != null) _profitPct = profitPct.clamp(0, 100);
        if (wholesalePct != null) _wholesalePct = wholesalePct.clamp(0, 60);
        _savedCalculations = loadedList;
      });
    } catch (e) {
      debugPrint('Error cargando preferencias de calculadora: $e');
    }
  }

  Future<void> _saveWorkshopDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyHourlyRate, _parseDouble(_hourlyRateController.text));
      await prefs.setDouble(_keyToolsPct, _toolsPct);
      await prefs.setDouble(_keyKilnRate, _parseDouble(_kilnRateController.text));
      await prefs.setDouble(_keyProfitPct, _profitPct);
      await prefs.setDouble(_keyWholesalePct, _wholesalePct);
    } catch (e) {
      debugPrint('Error guardando configuración de taller: $e');
    }
  }

  Future<void> _persistSavedCalculations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedList, jsonEncode(_savedCalculations));
    } catch (e) {
      debugPrint('Error guardando historial de cálculos: $e');
    }
  }

  double _parseDouble(String raw) {
    final cleaned = raw.trim().replaceAll(',', '.');
    final parsed = double.tryParse(cleaned) ?? 0.0;
    return parsed < 0 ? 0.0 : parsed;
  }

  int _parseUnits() {
    final parsed = int.tryParse(_unitsController.text.trim()) ?? 1;
    return parsed < 1 ? 1 : parsed;
  }

  String _formatInputNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final reverseIndex = intPart.length - i;
      if (i > 0 && reverseIndex % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }
    if (decPart == '00') {
      return '\$${buffer.toString()}';
    }
    return '\$${buffer.toString()},$decPart';
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} $hour:$min';
  }

  void _addMaterialRow({String name = '', String cost = ''}) {
    _materials.add(_MaterialEntry(name: name, cost: cost));
  }

  void _removeMaterialRow(int index) {
    if (_materials.length <= 1) return;
    setState(() {
      final removed = _materials.removeAt(index);
      removed.dispose();
    });
  }

  void _adjustUnits(int delta) {
    final next = (_parseUnits() + delta).clamp(1, 99999);
    setState(() {
      _unitsController.text = next.toString();
    });
  }

  double? _suggestedHourlyRate() {
    final goal = _parseDouble(_monthlyGoalController.text);
    final weeklyHours = _parseDouble(_weeklyHoursController.text);
    if (goal <= 0 || weeklyHours <= 0) return null;
    return goal / (weeklyHours * 4.33);
  }

  _CalculationMetrics _calculate() {
    final units = _parseUnits();

    double materialsSubtotal = 0;
    for (final entry in _materials) {
      materialsSubtotal += _parseDouble(entry.costController.text);
    }

    final wasteAmount = materialsSubtotal * (_wastePct / 100.0);

    final hours = _parseDouble(_workHoursController.text);
    final minutes = _parseDouble(_workMinutesController.text);
    final laborHoursTotal = hours + (minutes / 60.0);
    final hourlyRate = _parseDouble(_hourlyRateController.text);
    final laborCost = laborHoursTotal * hourlyRate;

    // Desgaste de herramientas aplicado sobre el subtotal de materiales + mano de obra
    final toolsWearAmount = (materialsSubtotal + laborCost) * (_toolsPct / 100.0);

    final kilnCost = _useKiln
        ? _parseDouble(_kilnHoursController.text) *
            _parseDouble(_kilnRateController.text)
        : 0.0;

    final replacementCost =
        materialsSubtotal + wasteAmount + kilnCost + toolsWearAmount;
    final baseProductionCost = replacementCost + laborCost;

    final directProfitAmount = baseProductionCost * (_profitPct / 100.0);
    final directSaleTotal = baseProductionCost + directProfitAmount;
    final wholesaleSaleTotal =
        baseProductionCost * (1.0 + _wholesalePct / 100.0);

    double packagingAndShippingTotal = 0;
    if (_includeShipping) {
      packagingAndShippingTotal +=
          _parseDouble(_basicPackagingController.text) +
              _parseDouble(_shippingCostController.text);
      if (_isFragile) {
        packagingAndShippingTotal +=
            _parseDouble(_extraProtectionController.text);
      }
    }

    final finalWithShippingTotal = directSaleTotal + packagingAndShippingTotal;

    return _CalculationMetrics(
      units: units,
      materialsSubtotal: materialsSubtotal,
      wasteAmount: wasteAmount,
      laborHoursTotal: laborHoursTotal,
      laborCost: laborCost,
      toolsWearAmount: toolsWearAmount,
      kilnCost: kilnCost,
      replacementCost: replacementCost,
      baseProductionCost: baseProductionCost,
      directProfitAmount: directProfitAmount,
      directSaleTotal: directSaleTotal,
      wholesaleSaleTotal: wholesaleSaleTotal,
      packagingAndShippingTotal: packagingAndShippingTotal,
      finalWithShippingTotal: finalWithShippingTotal,
    );
  }

  void _clearCurrentCalculation({bool showMessage = true}) {
    setState(() {
      _editingSavedId = null;
      _productNameController.clear();
      _unitsController.text = '1';
      for (final entry in _materials) {
        entry.dispose();
      }
      _materials.clear();
      _addMaterialRow();
      _wastePct = 0;
      _workHoursController.text = '1';
      _workMinutesController.text = '0';
      _useKiln = false;
      _kilnHoursController.text = '0';
      _includeShipping = false;
      _isFragile = false;
      _basicPackagingController.clear();
      _extraProtectionController.clear();
      _shippingCostController.clear();
    });
    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Formulario limpio. Se conservaron tus valores base del taller.',
          ),
        ),
      );
    }
  }

  Future<void> _saveCurrentCalculation(_CalculationMetrics m) async {
    final name = _productNameController.text.trim().isNotEmpty
        ? _productNameController.text.trim()
        : 'Artesanía sin nombre';
    final nowIso = DateTime.now().toIso8601String();
    final id = _editingSavedId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final record = <String, dynamic>{
      'id': id,
      'name': name,
      'updatedAt': nowIso,
      'units': m.units,
      'materials': _materials
          .map((e) => {
                'name': e.nameController.text.trim(),
                'cost': _parseDouble(e.costController.text),
              })
          .toList(),
      'wastePct': _wastePct,
      'hourlyRate': _parseDouble(_hourlyRateController.text),
      'workHours': _parseDouble(_workHoursController.text),
      'workMinutes': _parseDouble(_workMinutesController.text),
      'toolsPct': _toolsPct,
      'useKiln': _useKiln,
      'kilnHours': _parseDouble(_kilnHoursController.text),
      'kilnRate': _parseDouble(_kilnRateController.text),
      'profitPct': _profitPct,
      'wholesalePct': _wholesalePct,
      'includeShipping': _includeShipping,
      'isFragile': _isFragile,
      'basicPackaging': _parseDouble(_basicPackagingController.text),
      'extraProtection': _parseDouble(_extraProtectionController.text),
      'shippingCost': _parseDouble(_shippingCostController.text),
      'unitDirectPrice': m.perUnit(m.directSaleTotal),
      'totalDirectPrice': m.directSaleTotal,
    };

    setState(() {
      _editingSavedId = id;
      final existingIdx = _savedCalculations.indexWhere((c) => c['id'] == id);
      if (existingIdx >= 0) {
        _savedCalculations[existingIdx] = record;
      } else {
        _savedCalculations.insert(0, record);
      }
    });

    await _saveWorkshopDefaults();
    await _persistSavedCalculations();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$name" guardado en tu dispositivo.'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  void _loadSavedCalculation(Map<String, dynamic> data) {
    setState(() {
      _editingSavedId = data['id'] as String?;
      _productNameController.text = (data['name'] ?? '').toString();
      _unitsController.text = ((data['units'] as num?)?.toInt() ?? 1).toString();

      for (final entry in _materials) {
        entry.dispose();
      }
      _materials.clear();
      final mats = data['materials'];
      if (mats is List && mats.isNotEmpty) {
        for (final item in mats) {
          if (item is Map) {
            final mName = (item['name'] ?? '').toString();
            final mCost = (item['cost'] as num?)?.toDouble() ?? 0.0;
            _addMaterialRow(
              name: mName,
              cost: mCost > 0 ? _formatInputNumber(mCost) : '',
            );
          }
        }
      }
      if (_materials.isEmpty) {
        _addMaterialRow();
      }

      _wastePct = ((data['wastePct'] as num?)?.toDouble() ?? 0).clamp(0, 35);
      final hRate = (data['hourlyRate'] as num?)?.toDouble() ?? 0;
      _hourlyRateController.text = hRate > 0 ? _formatInputNumber(hRate) : '';
      _workHoursController.text =
          _formatInputNumber((data['workHours'] as num?)?.toDouble() ?? 1);
      _workMinutesController.text =
          _formatInputNumber((data['workMinutes'] as num?)?.toDouble() ?? 0);

      _toolsPct = ((data['toolsPct'] as num?)?.toDouble() ?? 10).clamp(0, 30);
      _useKiln = data['useKiln'] == true;
      _kilnHoursController.text =
          _formatInputNumber((data['kilnHours'] as num?)?.toDouble() ?? 0);
      final kRate = (data['kilnRate'] as num?)?.toDouble() ?? 0;
      _kilnRateController.text = kRate > 0 ? _formatInputNumber(kRate) : '';

      _profitPct = ((data['profitPct'] as num?)?.toDouble() ?? 25).clamp(0, 100);
      _wholesalePct =
          ((data['wholesalePct'] as num?)?.toDouble() ?? 15).clamp(0, 60);

      _includeShipping = data['includeShipping'] == true;
      _isFragile = data['isFragile'] == true;
      final bPack = (data['basicPackaging'] as num?)?.toDouble() ?? 0;
      final eProt = (data['extraProtection'] as num?)?.toDouble() ?? 0;
      final sCost = (data['shippingCost'] as num?)?.toDouble() ?? 0;
      _basicPackagingController.text = bPack > 0 ? _formatInputNumber(bPack) : '';
      _extraProtectionController.text = eProt > 0 ? _formatInputNumber(eProt) : '';
      _shippingCostController.text = sCost > 0 ? _formatInputNumber(sCost) : '';
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cálculo "${data['name']}" cargado para editar.')),
    );
  }

  Future<void> _deleteSavedCalculation(String id) async {
    setState(() {
      _savedCalculations.removeWhere((c) => c['id'] == id);
      if (_editingSavedId == id) _editingSavedId = null;
    });
    await _persistSavedCalculations();
  }

  Future<void> _confirmClearAllSavedData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar datos guardados'),
        content: const Text(
          '¿Deseas eliminar todos tus cálculos guardados y los valores base del taller almacenados en este dispositivo? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, borrar todo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHourlyRate);
    await prefs.remove(_keyToolsPct);
    await prefs.remove(_keyKilnRate);
    await prefs.remove(_keyProfitPct);
    await prefs.remove(_keyWholesalePct);
    await prefs.remove(_keySavedList);

    if (!mounted) return;
    setState(() {
      _savedCalculations.clear();
      _editingSavedId = null;
      _hourlyRateController.clear();
      _kilnRateController.clear();
      _toolsPct = 10;
      _profitPct = 25;
      _wholesalePct = 15;
    });
    _clearCurrentCalculation(showMessage: false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todos tus datos guardados fueron eliminados de este dispositivo.'),
      ),
    );
  }

  String _buildShareSummary(_CalculationMetrics m) {
    final name = _productNameController.text.trim().isNotEmpty
        ? _productNameController.text.trim()
        : 'Mi Artesanía';
    final buffer = StringBuffer();
    buffer.writeln('🏺 *Ficha de Costos — Manos del Pueblo*');
    buffer.writeln('📦 *Producto:* $name');
    if (m.units > 1) {
      buffer.writeln('🔢 *Lote:* ${m.units} unidades');
    }
    buffer.writeln('');
    buffer.writeln('📊 *Desglose del Taller (Total):*');
    buffer.writeln('• Materiales e insumos: ${_formatCurrency(m.materialsSubtotal)}');
    if (m.wasteAmount > 0) {
      buffer.writeln('• Merma / riesgo (${_wastePct.round()}%): ${_formatCurrency(m.wasteAmount)}');
    }
    if (m.kilnCost > 0) {
      buffer.writeln('• Horno / energía especial: ${_formatCurrency(m.kilnCost)}');
    }
    if (m.toolsWearAmount > 0) {
      buffer.writeln('• Desgaste herramientas (${_toolsPct.round()}%): ${_formatCurrency(m.toolsWearAmount)}');
    }
    buffer.writeln('➡️ *Costo de Reposición:* ${_formatCurrency(m.replacementCost)}');
    buffer.writeln('🖐️ *Tu Sueldo (Mano de Obra):* ${_formatCurrency(m.laborCost)}');
    buffer.writeln('🏗️ *Costo Base de Producción:* ${_formatCurrency(m.baseProductionCost)}');
    buffer.writeln('📈 *Ganancia del Taller (${_profitPct.round()}%):* ${_formatCurrency(m.directProfitAmount)}');
    buffer.writeln('');
    buffer.writeln('💰 *PRECIOS SUGERIDOS:*');
    if (m.units > 1) {
      buffer.writeln('• Venta Directa / Feria (c/u): ${_formatCurrency(m.perUnit(m.directSaleTotal))} (Lote: ${_formatCurrency(m.directSaleTotal)})');
      buffer.writeln('• Venta Mayorista (${_wholesalePct.round()}%, c/u): ${_formatCurrency(m.perUnit(m.wholesaleSaleTotal))} (Lote: ${_formatCurrency(m.wholesaleSaleTotal)})');
    } else {
      buffer.writeln('• Venta Directa / Feria: ${_formatCurrency(m.directSaleTotal)}');
      buffer.writeln('• Venta Mayorista (${_wholesalePct.round()}%): ${_formatCurrency(m.wholesaleSaleTotal)}');
    }
    if (_includeShipping) {
      buffer.writeln('• Embalaje y Envío${_isFragile ? ' (Frágil)' : ''}: ${_formatCurrency(m.packagingAndShippingTotal)}');
      buffer.writeln('🚚 *Total Final con Envío:* ${_formatCurrency(m.finalWithShippingTotal)}${m.units > 1 ? ' (${_formatCurrency(m.perUnit(m.finalWithShippingTotal))} c/u)' : ''}');
    }
    return buffer.toString().trim();
  }

  Future<void> _shareSummary(_CalculationMetrics m) async {
    await Share.share(_buildShareSummary(m));
  }

  Future<void> _copySummary(_CalculationMetrics m) async {
    await Clipboard.setData(ClipboardData(text: _buildShareSummary(m)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumen copiado al portapapeles.')),
    );
  }

  void _scrollToSaved() {
    final ctx = _savedSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    String? hintText,
    String? helperText,
    String? prefixText,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      helperMaxLines: 2,
      prefixText: prefixText,
      suffixText: suffixText,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBrown, width: 1.8),
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String explanation,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _primaryBrown.withValues(alpha: 0.12),
                  child: Icon(icon, color: _primaryBrown, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _primaryBrown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _bgCream.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.brown.shade100),
              ),
              child: Text(
                explanation,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: _secondaryGray,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String amount,
    String? subtitle,
    bool bold = false,
    Color? amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: bold ? 15 : 14,
                    fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _secondaryGray,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: bold ? 16 : 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: amountColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHighlightBox({
    required String title,
    required double totalAmount,
    required int units,
    required Color accentColor,
    String? subtitle,
  }) {
    final unitAmount = units > 0 ? totalAmount / units : totalAmount;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _secondaryGray),
                  ),
                if (units > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Total lote ($units u.): ${_formatCurrency(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _secondaryGray,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(unitAmount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              if (units > 1)
                const Text(
                  'por unidad',
                  style: TextStyle(fontSize: 11, color: _secondaryGray),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _calculate();
    final suggestedHourly = _suggestedHourlyRate();

    return Scaffold(
      appBar: const AdaptiveAppBar(
        title: Text('Calculadora de Costos'),
      ),
      body: SelectionArea(
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Barra superior de acciones rápidas
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _scrollToSaved,
                          icon: const Icon(Icons.bookmark_outline, size: 18),
                          label: Text(
                            'Mis Cálculos (${_savedCalculations.length})',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryBrown,
                            side: const BorderSide(color: _primaryBrown),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _clearCurrentCalculation,
                          icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                          label: const Text('Limpiar'),
                          style: TextButton.styleFrom(
                            foregroundColor: _primaryBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Módulo 1: Producto y Lote
                    _buildModuleCard(
                      icon: Icons.inventory_2_outlined,
                      title: '1. Producto y Modalidad (Pieza Única vs. Lote)',
                      explanation:
                          'Indica el nombre de tu creación y cuántas unidades obtienes. Si haces una pieza única (ej. luthería, carpintería, platería, cuero), deja 1. Si en una misma preparación u horneada produces varias piezas (ej. cerámica, jabones, velas), ingresa la cantidad total del lote para conocer el costo exacto por unidad.',
                      children: [
                        TextField(
                          controller: _productNameController,
                          onChanged: (_) => setState(() {}),
                          decoration: _fieldDecoration(
                            labelText: 'Nombre del producto o proyecto',
                            hintText: 'Ej: Cuenco de arcilla o Lote de 12 jabones',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _unitsController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) => setState(() {}),
                                decoration: _fieldDecoration(
                                  labelText: 'Unidades producidas (Lote)',
                                  helperText: '1 para pieza única, o total del lote',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.outlined(
                              tooltip: 'Restar unidad',
                              onPressed: () => _adjustUnits(-1),
                              icon: const Icon(Icons.remove),
                            ),
                            const SizedBox(width: 4),
                            IconButton.outlined(
                              tooltip: 'Sumar unidad',
                              onPressed: () => _adjustUnits(1),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Módulo 2: Materiales e Insumos + Merma
                    _buildModuleCard(
                      icon: Icons.category_outlined,
                      title: '2. Materiales e Insumos (+ Merma)',
                      explanation:
                          'Agrega los materiales utilizados (arcilla, madera, metal, cuero, cera, esmaltes, herrajes, pegamentos). Si trabajas con materiales reciclados sin costo de compra (caucho, vidrio, etc.), puedes poner \$0 en la materia prima base y cargar solo los insumos complementarios.',
                      children: [
                        ...List.generate(_materials.length, (index) {
                          final entry = _materials[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: entry.nameController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: _fieldDecoration(
                                      labelText: 'Insumo ${index + 1}',
                                      hintText: 'Ej: Arcilla, madera, cuero...',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: entry.costController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                    decoration: _fieldDecoration(
                                      labelText: 'Costo',
                                      prefixText: '\$ ',
                                      hintText: '0',
                                    ),
                                  ),
                                ),
                                if (_materials.length > 1)
                                  IconButton(
                                    tooltip: 'Quitar insumo',
                                    onPressed: () => _removeMaterialRow(index),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[700],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _addMaterialRow();
                              });
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar otro insumo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryBrown,
                              side: BorderSide(color: Colors.brown.shade300),
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Merma, desperdicio o riesgo de falla',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '${_wastePct.round()}% (${_formatCurrency(metrics.wasteAmount)})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Porcentaje adicional para cubrir material que se descarta en cortes/limado (madera, cuero, metal) o el riesgo de que una pieza falle o se raje durante el proceso (cerámica, vidrio).',
                          style: TextStyle(fontSize: 12, color: _secondaryGray),
                        ),
                        Slider(
                          value: _wastePct,
                          min: 0,
                          max: 35,
                          divisions: 35,
                          activeColor: _primaryBrown,
                          label: '${_wastePct.round()}%',
                          onChanged: (val) => setState(() => _wastePct = val),
                        ),
                        Wrap(
                          spacing: 6,
                          children: [0, 5, 10, 15, 20].map((pct) {
                            final selected = _wastePct.round() == pct;
                            return ChoiceChip(
                              label: Text('$pct%'),
                              selected: selected,
                              selectedColor: _primaryBrown.withValues(alpha: 0.2),
                              onSelected: (_) {
                                setState(() => _wastePct = pct.toDouble());
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // Módulo 3: Mano de Obra
                    _buildModuleCard(
                      icon: Icons.handyman_outlined,
                      title: '3. Mano de Obra ("Tu Tiempo Vale")',
                      explanation:
                          'Tu tiempo es el corazón de la artesanía. Incluye todas las etapas: recolectar y limpiar materiales (clave en reciclaje), preparar, modelar o ensamblar, lijar, pintar y dar terminación.',
                      children: [
                        TextField(
                          controller: _hourlyRateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) {
                            setState(() {});
                            _saveWorkshopDefaults();
                          },
                          decoration: _fieldDecoration(
                            labelText: 'Valor de tu hora de trabajo',
                            prefixText: '\$ ',
                            suffixText: '/ hora',
                            helperText:
                                'Se guarda automáticamente en este dispositivo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: _bgCream.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.brown.shade100),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            title: const Text(
                              '¿No sabes cuánto cobrar tu hora? Calcúlalo aquí',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _primaryBrown,
                              ),
                            ),
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _monthlyGoalController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                      decoration: _fieldDecoration(
                                        labelText: 'Meta mensual',
                                        prefixText: '\$ ',
                                        hintText: 'Ej: 600000',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _weeklyHoursController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                      decoration: _fieldDecoration(
                                        labelText: 'Horas/semana',
                                        hintText: 'Ej: 30',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (suggestedHourly != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Valor sugerido: ${_formatCurrency(suggestedHourly)} / hora',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _primaryBrown,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _hourlyRateController.text =
                                              _formatInputNumber(suggestedHourly);
                                        });
                                        _saveWorkshopDefaults();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryBrown,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Usar este valor hora'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _workHoursController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) => setState(() {}),
                                decoration: _fieldDecoration(
                                  labelText: 'Horas de trabajo',
                                  suffixText: 'hs',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _workMinutesController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) => setState(() {}),
                                decoration: _fieldDecoration(
                                  labelText: 'Minutos',
                                  suffixText: 'min',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Módulo 4: Herramientas, Energía y Horno / Maquinaria
                    _buildModuleCard(
                      icon: Icons.build_outlined,
                      title: '4. Herramientas, Energía y Horno / Maquinaria',
                      explanation:
                          'Las herramientas se desgastan con cada pieza (lijas, mechas, cuchillas de torno, pinceles, moldes) y el taller consume energía básica.',
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Desgaste de herramientas y gastos fijos',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${_toolsPct.round()}% (${_formatCurrency(metrics.toolsWearAmount)})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryBrown,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Se aplica sobre el subtotal de materiales + mano de obra.',
                          style: TextStyle(fontSize: 12, color: _secondaryGray),
                        ),
                        Slider(
                          value: _toolsPct,
                          min: 0,
                          max: 30,
                          divisions: 30,
                          activeColor: _primaryBrown,
                          label: '${_toolsPct.round()}%',
                          onChanged: (val) {
                            setState(() => _toolsPct = val);
                          },
                          onChangeEnd: (_) => _saveWorkshopDefaults(),
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: _primaryBrown,
                          title: const Text(
                            '¿Requiere horneado, fundición o maquinaria de alto consumo?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: _useKiln,
                          onChanged: (val) => setState(() => _useKiln = val),
                        ),
                        if (_useKiln) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Ideal para cocción en horno (cerámica, vitrofusión), fundición de metales o uso intensivo de máquinas eléctricas/gas.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _secondaryGray,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _kilnHoursController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  decoration: _fieldDecoration(
                                    labelText: 'Horas horno/máquina',
                                    suffixText: 'hs',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _kilnRateController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: (_) {
                                    setState(() {});
                                    _saveWorkshopDefaults();
                                  },
                                  decoration: _fieldDecoration(
                                    labelText: 'Energía/gas por hora',
                                    prefixText: '\$ ',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Subtotal horneado/energía: ${_formatCurrency(metrics.kilnCost)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryBrown,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Módulo 5: Margen del Taller y Reinversión
                    _buildModuleCard(
                      icon: Icons.trending_up,
                      title: '5. Margen del Taller y Reinversión',
                      explanation:
                          'Importante: tu Mano de Obra es el sueldo por tu tiempo trabajado, pero el taller necesita una ganancia adicional para crecer, comprar nuevas herramientas, reponer stock y cubrir imprevistos.',
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Ganancia Venta Directa / Feria',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${_profitPct.round()}% (${_formatCurrency(metrics.directProfitAmount)})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryBrown,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _profitPct,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          activeColor: _primaryBrown,
                          label: '${_profitPct.round()}%',
                          onChanged: (val) => setState(() => _profitPct = val),
                          onChangeEnd: (_) => _saveWorkshopDefaults(),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Margen Venta Mayorista / Reventa',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${_wholesalePct.round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryBrown,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _wholesalePct,
                          min: 0,
                          max: 60,
                          divisions: 12,
                          activeColor: _primaryBrown,
                          label: '${_wholesalePct.round()}%',
                          onChanged: (val) => setState(() => _wholesalePct = val),
                          onChangeEnd: (_) => _saveWorkshopDefaults(),
                        ),
                      ],
                    ),

                    // Módulo 6: Embalaje y Envío por Correo
                    _buildModuleCard(
                      icon: Icons.local_shipping_outlined,
                      title: '6. Embalaje y Envío por Correo (Especial Frágiles)',
                      explanation:
                          'Si despachas por correo o encomienda, el packaging y los recargos por fragilidad no deben descontarse de tu ganancia.',
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: _primaryBrown,
                          title: const Text(
                            '¿Incluir cálculo de embalaje y envío por correo?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: _includeShipping,
                          onChanged: (val) => setState(() => _includeShipping = val),
                        ),
                        if (_includeShipping) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _basicPackagingController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: _fieldDecoration(
                              labelText:
                                  'Embalaje básico (caja, bolsa, etiqueta, cinta)',
                              prefixText: '\$ ',
                              hintText: '0',
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: _primaryBrown,
                            title: const Text(
                              'Es un Producto Frágil (cerámica, vidrio, instrumentos, etc.)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: _isFragile,
                            onChanged: (val) => setState(() => _isFragile = val),
                          ),
                          if (_isFragile) ...[
                            const SizedBox(height: 8),
                            TextField(
                              controller: _extraProtectionController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => setState(() {}),
                              decoration: _fieldDecoration(
                                labelText:
                                    'Protección extra (pluribol/burbujas, viruta, doble caja)',
                                prefixText: '\$ ',
                                hintText: '0',
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          TextField(
                            controller: _shippingCostController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: _fieldDecoration(
                              labelText: _isFragile
                                  ? 'Costo de correo + plus/seguro por bulto frágil'
                                  : 'Costo de envío por correo / encomienda',
                              prefixText: '\$ ',
                              hintText: '0',
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Módulo 7: Tablero de Resultados Pedagógico
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: _primaryBrown, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: const BoxDecoration(
                              color: _primaryBrown,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.assessment_outlined,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    metrics.units > 1
                                        ? 'Resumen de Costos (Lote de ${metrics.units} u.)'
                                        : 'Resumen de Costos y Precios',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildResultRow(
                                  label: '1. Costo de Reposición',
                                  subtitle:
                                      'Dinero que debes reservar para reponer insumos (${_formatCurrency(metrics.materialsSubtotal)}), merma (${_formatCurrency(metrics.wasteAmount)}), energía/horno (${_formatCurrency(metrics.kilnCost)}) y herramientas (${_formatCurrency(metrics.toolsWearAmount)}).',
                                  amount: _formatCurrency(metrics.replacementCost),
                                ),
                                const Divider(),
                                _buildResultRow(
                                  label: '2. Tu Sueldo (Mano de Obra)',
                                  subtitle:
                                      'Lo que ganas por tu tiempo de trabajo (${metrics.laborHoursTotal.toStringAsFixed(2)} hs).',
                                  amount: _formatCurrency(metrics.laborCost),
                                ),
                                const Divider(),
                                _buildResultRow(
                                  label: '3. Costo Base Total de Producción',
                                  amount: _formatCurrency(
                                    metrics.baseProductionCost,
                                  ),
                                  bold: true,
                                ),
                                _buildResultRow(
                                  label:
                                      '4. Ganancia del Taller / Reinversión (${_profitPct.round()}%)',
                                  amount: _formatCurrency(
                                    metrics.directProfitAmount,
                                  ),
                                  amountColor: Colors.green[800],
                                ),
                                const SizedBox(height: 6),
                                _buildPriceHighlightBox(
                                  title: 'Precio Sugerido Venta Directa / Feria',
                                  subtitle: 'Sin envío incluido',
                                  totalAmount: metrics.directSaleTotal,
                                  units: metrics.units,
                                  accentColor: _primaryBrown,
                                ),
                                _buildPriceHighlightBox(
                                  title:
                                      'Precio Sugerido Mayorista / Comercio (+${_wholesalePct.round()}%)',
                                  subtitle: 'Sin envío incluido',
                                  totalAmount: metrics.wholesaleSaleTotal,
                                  units: metrics.units,
                                  accentColor: Colors.brown.shade700,
                                ),
                                if (_includeShipping)
                                  _buildPriceHighlightBox(
                                    title:
                                        'Precio Final con Embalaje y Envío',
                                    subtitle:
                                        'Incluye ${_formatCurrency(metrics.packagingAndShippingTotal)} de embalaje/envío${_isFragile ? ' frágil' : ''}',
                                    totalAmount: metrics.finalWithShippingTotal,
                                    units: metrics.units,
                                    accentColor: Colors.green[800]!,
                                  ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _saveCurrentCalculation(metrics),
                                    icon: const Icon(Icons.save_outlined),
                                    label: Text(
                                      _editingSavedId != null
                                          ? 'Actualizar cálculo guardado'
                                          : 'Guardar en mis cálculos',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryBrown,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _shareSummary(metrics),
                                        icon: const Icon(Icons.share_outlined, size: 18),
                                        label: const Text('Compartir resumen'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _primaryBrown,
                                          side: const BorderSide(
                                            color: _primaryBrown,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _copySummary(metrics),
                                        icon: const Icon(Icons.copy_outlined, size: 18),
                                        label: const Text('Copiar texto'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _primaryBrown,
                                          side: const BorderSide(
                                            color: _primaryBrown,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Módulo 8: Mis Cálculos Guardados
                    Container(
                      key: _savedSectionKey,
                      child: _buildModuleCard(
                        icon: Icons.bookmarks_outlined,
                        title: 'Mis Cálculos Guardados (en este dispositivo)',
                        explanation:
                            'Toca cualquier producto guardado para volver a cargarlo en la calculadora y actualizar sus costos cuando cambien los insumos o tarifas.',
                        children: [
                          if (_savedCalculations.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Todavía no guardaste cálculos en este dispositivo.',
                                  style: TextStyle(color: _secondaryGray),
                                ),
                              ),
                            )
                          else
                            ..._savedCalculations.map((item) {
                              final itemId = (item['id'] ?? '').toString();
                              final itemName =
                                  (item['name'] ?? 'Sin nombre').toString();
                              final itemUnits =
                                  (item['units'] as num?)?.toInt() ?? 1;
                              final unitPrice =
                                  (item['unitDirectPrice'] as num?)?.toDouble() ??
                                      0.0;
                              final updatedAt = _formatDate(
                                item['updatedAt']?.toString(),
                              );

                              return Card(
                                elevation: 0,
                                color: _bgCream.withValues(alpha: 0.45),
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.brown.shade100),
                                ),
                                child: ListTile(
                                  onTap: () => _loadSavedCalculation(item),
                                  title: Text(
                                    itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _primaryBrown,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${itemUnits > 1 ? 'Lote $itemUnits u. • ' : ''}Sugerido c/u: ${_formatCurrency(unitPrice)}${updatedAt.isNotEmpty ? ' • $updatedAt' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _secondaryGray,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Eliminar cálculo guardado',
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[700],
                                    ),
                                    onPressed: () =>
                                        _deleteSavedCalculation(itemId),
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _confirmClearAllSavedData,
                              icon: Icon(
                                Icons.delete_forever_outlined,
                                size: 18,
                                color: Colors.red[700],
                              ),
                              label: Text(
                                'Borrar todos mis datos guardados',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Módulo 9: Aviso Orientativo y de Privacidad
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown.shade200),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.privacy_tip_outlined,
                            color: _primaryBrown,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Aviso orientativo y de privacidad: Los valores calculados por esta herramienta son estimaciones de referencia para ayudar al artesano a organizar los costos de su taller y no constituyen asesoramiento contable, impositivo ni financiero oficial. Todos los datos que ingreses o guardes aquí se almacenan únicamente en la memoria interna de tu propio dispositivo de forma privada; Manos del Pueblo no recopila, transmite ni tiene acceso a tus costos.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: _secondaryGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
