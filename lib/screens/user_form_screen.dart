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
  Widget build(BuildContext context) {
    return Scaffold(
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
}
