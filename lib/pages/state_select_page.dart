import 'package:flutter/material.dart';


class StateSelectPage extends StatefulWidget {

  final Function(String) onNavigate;

  StateSelectPage({super.key, required this.onNavigate});


  @override
  State createState() => _StateSelectPageState();
}

class _StateSelectPageState extends State<StateSelectPage> {


  final TextEditingController stateController = TextEditingController();
  String _selectedState = "";

  void _onSelected(String? state) {
    _selectedState = state!;
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Config Page')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 30),
            child: DropdownMenu<String>(
              initialSelection: '',
              controller: stateController,
              label: const Text('State'),
              onSelected: _onSelected,
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: "NY", label: "New York"),
                DropdownMenuEntry(value: "MA", label: "Massachussettes"),
              ],

            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                widget.onNavigate(_selectedState);
              },
              child: Text("Submit"),
              )
          )
        ]
      )
    );
  }
}

