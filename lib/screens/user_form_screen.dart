/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'draw_screen.dart';

class UserFormScreen extends StatefulWidget {
  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Hombre';
  String _handUsed = 'Derecha';
  int _age = 0;

  // Método para guardar los datos en Firestore
  void _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance.collection('users').add({
        'gender': _gender,
        'age': _age,
        'handUsed': _handUsed,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DrawScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _age = int.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu edad';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Hombre', 'Mujer'].map((String gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _handUsed,
                items: ['Derecha', 'Izquierda'].map((String hand) {
                  return DropdownMenuItem(value: hand, child: Text(hand));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _handUsed = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                child: Text('Guardar y Dibujar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'draw_screen.dart';

class UserFormScreen extends StatefulWidget {
  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _gender = 'Hombre';
  String _handUsed = 'Derecha';
  bool _isDominantHand = false;
  int _age = 0;

  void _navigateToDrawScreen() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Navega a la pantalla de dibujo, pasando los datos como argumentos
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrawScreen(
            userName: _name,
            gender: _gender,
            age: _age,
            handUsed: _handUsed,
            isDominant: _isDominantHand,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => _name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _age = int.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu edad';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Hombre', 'Mujer'].map((String gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
              DropdownButtonFormField<String>(
                value: _handUsed,
                items: ['Derecha', 'Izquierda'].map((String hand) {
                  return DropdownMenuItem(value: hand, child: Text(hand));
                }).toList(),
                onChanged: (value) => setState(() => _handUsed = value!),
              ),
              SwitchListTile(
                title: Text('¿Es la mano dominante?'),
                value: _isDominantHand,
                onChanged: (value) => setState(() => _isDominantHand = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToDrawScreen,
                child: Text('Guardar y Dibujar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
