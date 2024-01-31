import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Clothes {
  String type;
  String color;
  String size;

  Clothes({required this.type, required this.color, required this.size});
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Clothes Manager',
      home: ClothesManager(),
    );
  }
}

class ClothesManager extends StatefulWidget {
  const ClothesManager({Key? key}) : super(key: key);

  @override
  _ClothesManagerState createState() => _ClothesManagerState();
}

class _ClothesManagerState extends State<ClothesManager> {
  final List<Clothes> _clothesList = [];
  final List<String> _clothesTypes = ['Shirt', 'Jeans', 'Hat', 'Coat'];
  final List<String> _clothesColors = ['Red', 'Blue', 'Green', 'Yellow', 'Black', 'White'];
  final List<String> _clothesSizes = ['S', 'M', 'L', 'XL'];
  late String _selectedType;
  late String _selectedColor;
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedType = _clothesTypes.first;
    _selectedColor = _clothesColors.first;
    _selectedSize = _clothesSizes.first;
  }

  void _addOrEditClothes({int? index}) {
    final isEditing = index != null;
    if (isEditing) {
      _selectedType = _clothesList[index].type;
      _selectedColor = _clothesList[index].color;
      _selectedSize = _clothesList[index].size;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Clothes' : 'Add Clothes', style: TextStyle(color: Colors.blue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown('Type', _selectedType, _clothesTypes, (val) => _selectedType = val!),
              _buildDropdown('Color', _selectedColor, _clothesColors, (val) => _selectedColor = val!),
              _buildDropdown('Size', _selectedSize, _clothesSizes, (val) => _selectedSize = val!),
            ],
          ),
          actions: [
            _buildActionButton('Cancel', () => Navigator.pop(context)),
            _buildActionButton(isEditing ? 'Save' : 'Add', () {
              if (isEditing) {
                _clothesList[index] = Clothes(type: _selectedType, color: _selectedColor, size: _selectedSize);
              } else {
                _clothesList.add(Clothes(type: _selectedType, color: _selectedColor, size: _selectedSize));
              }
              setState(() {});
              Navigator.pop(context);
            }),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.blue)),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
      child: Text(text, style: const TextStyle(color: Colors.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothes Manager', style: TextStyle(color: Colors.blue)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _addOrEditClothes(),
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: const Text('Add Clothes', style: TextStyle(color: Colors.red)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('All Clothes:', style: TextStyle(color: Colors.blue)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _clothesList.length,
              itemBuilder: (context, index) {
                final clothes = _clothesList[index];
                return ListTile(
                  title: Text('${clothes.type} - ${clothes.color} - ${clothes.size}', style: TextStyle(color: Colors.blue)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _addOrEditClothes(index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _clothesList.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}