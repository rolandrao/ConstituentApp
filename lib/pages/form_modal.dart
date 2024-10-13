import 'package:flutter/material.dart';

class FormModal extends StatefulWidget {
  @override
  _FormModalState createState() => _FormModalState();
}

class _FormModalState extends State<FormModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _zipCodeController = TextEditingController();
  final List<String> selectedPhoneTypes = [];
  final FocusNode _zipCodeFocusNode = FocusNode();

  @override
  void dispose() {
    _zipCodeController.dispose();
    _zipCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    // Focus the zip code field as soon as the modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _zipCodeFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),  // Dismiss keyboard on tap outside
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,  // Adjust for keyboard
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zip Code input with FocusNode
                TextFormField(
                  controller: _zipCodeController,
                  focusNode: _zipCodeFocusNode,  // Assign FocusNode
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Zip Code',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a ZIP code';
                    }
                    if (value.length != 5) {
                      return 'ZIP code should be 5 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Multi-select for Phone Type
                PhoneTypeMultiSelect(
                  onSelectionChanged: (selectedList) {
                    selectedPhoneTypes.clear();
                    selectedPhoneTypes.addAll(selectedList);
                  },
                ),
                SizedBox(height: 20),
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print('ZIP Code: ${_zipCodeController.text}');
                      print('Selected Phone Types: $selectedPhoneTypes');
                      Navigator.pop(context);  // Close the modal
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
