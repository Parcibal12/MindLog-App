import 'package:flutter/material.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';

class WidgetCatalogScreen extends StatefulWidget {
  const WidgetCatalogScreen({super.key});

  @override
  State<WidgetCatalogScreen> createState() => _WidgetCatalogScreenState();
}

class _WidgetCatalogScreenState extends State<WidgetCatalogScreen> {
  bool _switchVal1 = false;
  bool _switchVal2 = true;
  final TextEditingController _demoController = TextEditingController();

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Componentes"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader("1. BOTONES (MindLogButton)", isDark),
          const SizedBox(height: 12),
          MindLogButton(
            text: "Botón Primario Activo",
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          MindLogButton(
            text: "Botón Deshabilitado",
            backgroundColor: isDark ? AppColors.darkIndicatorInactive : Colors.grey.shade300,
            onPressed: null,
          ),
          
          const SizedBox(height: 32),
          _buildSectionHeader("2. CAMPOS DE TEXTO (MindLogTextField)", isDark),
          const SizedBox(height: 12),
          MindLogTextField(
            controller: _demoController,
            hintText: "Escribe algo aquí...",
            prefixIcon: Icons.edit_note_outlined,
          ),

          const SizedBox(height: 32),
          _buildSectionHeader("3. INTERRUPTORES (MindLogSwitch)", isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("Apagado: ", style: TextStyle(color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
              MindLogSwitch(
                value: _switchVal1,
                onChanged: (val) => setState(() => _switchVal1 = val),
              ),
              const SizedBox(width: 32),
              Text("Encendido: ", style: TextStyle(color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
              MindLogSwitch(
                value: _switchVal2,
                onChanged: (val) => setState(() => _switchVal2 = val),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionHeader("4. TARJETAS (MindLogCard)", isDark),
          const SizedBox(height: 12),
          MindLogCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Contenido Interno de una Tarjeta", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)
                ),
                const SizedBox(height: 4),
                Text(
                  "Este contenedor se adapta automáticamente al fondo del tema oscuro o claro sin romper el contraste.",
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader("5. CELDAS DE AJUSTES (MindLogSettingTile)", isDark),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
            ),
            child: Column(
              children: [
                MindLogSettingTile(
                  icon: Icons.security,
                  title: "Componente de Opción A",
                  trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
                ),
                MindLogSettingTile(
                  showTopDivider: true,
                  icon: Icons.palette_outlined,
                  title: "Componente de Opción B",
                  trailing: MindLogSwitch(value: true, onChanged: (_) {}),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader("6. TECLADO NUMÉRICO (MindLogNumPad)", isDark),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: MindLogNumPad(
              onDigitTap: (digit) {},
              onBackspaceTap: () {},
              onBiometricTap: () {},
              showBiometrics: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primaryGreen, width: 4)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}