import 'package:drawtesis/utils/input_validators.dart';
import 'package:flutter/material.dart';
import 'draw_screen.dart';
import 'package:drawtesis/models/user_data.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Hombre';
  String _handUsed = 'Derecha';
  bool _isDominantHand = false;

  void _navigateToDrawScreen() {
    if (_formKey.currentState!.validate()) {
      //_formKey.currentState!.save();
      final user = UserData(
        firstName: InputValidators.sanitizeName(_firstNameController.text),
        lastName: InputValidators.sanitizeName(_lastNameController.text),
        age: int.parse(_ageController.text.trim()),
        gender: _gender,
        handUsed: _handUsed,
        isDominantHand: _isDominantHand,
      );

      // Navega a la pantalla de dibujo, pasando los datos como argumentos
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrawScreen(user: user),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Image.asset('assets/logo.png', height: 40),
                ],
              ),
            ),
            // --- Form Content ---
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'REGISTRO DE DATOS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Por favor, completa la siguiente información.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildTextFormField(
                          controller: _firstNameController,
                          label: 'Nombres*',
                          validator: (value) => InputValidators.validateNameOrSurname(value, fieldName: 'nombre'),
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          controller: _lastNameController,
                          label: 'Apellidos*',
                           validator: (value) => InputValidators.validateNameOrSurname(value, fieldName: 'apellido'),
                        ),
                        const SizedBox(height: 20),
                         _buildTextFormField(
                          controller: _ageController,
                          label: 'Edad*',
                          keyboardType: TextInputType.number,
                           validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu edad';
                            final age = int.tryParse(value);
                            if (age == null || age < 5 || age > 120) {
                              return 'Edad no válida (5–120)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownFormField(
                          label: 'Género*',
                          value: _gender,
                          items: ['Hombre', 'Mujer'],
                          // --- FIX: Check if value is not null before assigning ---
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _gender = value);
                            }
                          },                        ),
                        const SizedBox(height: 20),
                        _buildDropdownFormField(
                          label: 'Mano dominante*',
                          value: _handUsed,
                          items: ['Derecha', 'Izquierda'],
                          // --- FIX: Check if value is not null before assigning ---
                          onChanged: (value) {
                             if (value != null) {
                              setState(() => _handUsed = value);
                            }
                          },                        ),
                        const SizedBox(height: 24),
                        _buildSwitchTile(
                          title: '¿Usarás tu mano dominante para la prueba?',
                          value: _isDominantHand,
                          onChanged: (value) => setState(() => _isDominantHand = value),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _navigateToDrawScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('GUARDAR Y CONTINUAR', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, TextInputType keyboardType = TextInputType.text, required FormFieldValidator<String> validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownFormField({required String label, String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Por favor selecciona una opción' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(title, style: TextStyle(fontSize: 16, color: Colors.black54))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6A1B9A),
          ),
        ],
      ),
    );
  }
} 

/*
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(labelText: 'Nombre'),
                        validator: (value) =>
                            InputValidators.validateNameOrSurname(value,
                                fieldName: 'nombre'),
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(labelText: 'Apellido'),
                        validator: (value) =>
                            InputValidators.validateNameOrSurname(value,
                                fieldName: 'apellido'),
                      ),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(labelText: 'Edad'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Ingresa tu edad';
                          final age = int.tryParse(value);
                          if (age == null || age < 5 || age > 120) {
                            return 'Edad no válida (5–120)';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: ['Hombre', 'Mujer'].map((String gender) {
                          return DropdownMenuItem(
                              value: gender, child: Text(gender));
                        }).toList(),
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      DropdownButtonFormField<String>(
                        value: _handUsed,
                        items: ['Derecha', 'Izquierda'].map((String hand) {
                          return DropdownMenuItem(
                              value: hand, child: Text(hand));
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _handUsed = value!),
                      ),
                      SwitchListTile(
                        title: Text('¿Es la mano dominante?'),
                        value: _isDominantHand,
                        onChanged: (value) =>
                            setState(() => _isDominantHand = value),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _navigateToDrawScreen,
                          child: Text('Guardar y Dibujar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}*/
