import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoding/geocoding.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'form_modal.dart';

class MapPage extends StatefulWidget {
  final String? selectedState;
  MapPage({
    super.key,
    this.selectedState,
  });

  @override
  State createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? selectedState;
  late GoogleMapController mapController;
  List<dynamic> _voterData = [];
  List<dynamic> _filteredData = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> phoneTypes = [
    'Verified Cell',
    'Likely Cell',
    'Likely Not a Cell',
    'Not a Cell',
    'N/A'
  ];


  Set<Marker> _markers = {};
  LatLng? _mapCenter;
  bool _isLoading = true;
  LatLng _initialMapCenter = const LatLng(42, -75);
  List<String> _selectedPhoneType = [];
  String _selectedZipCode = '';
  CameraPosition centerPosition = CameraPosition(
    bearing: 0,
    target: LatLng(42, -75),
    tilt: 90,
    zoom: 6,
  );

  @override
  void initState() {
    super.initState();
    selectedState = widget.selectedState ?? 'No Value Passed';
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      print('Starting Data Load');
      String jsonString = await rootBundle.loadString('assets/data/voter_data_with_coords.json');

      final jsonData = jsonDecode(jsonString);

      print("Finished Data Load");
      _voterData = List<dynamic>.from(jsonData);
      _filteredData = _voterData.where((voter) {
        return voter['State'] == selectedState;
      }).toList();
      await _createMarkersFromData();

      setState(() {
        _isLoading = false;
      });
    } catch(e) {
      print('Error Loading JSON: $e');
    }
  }

  Future<void> writeJsonData() async {
    final file = File('assets/data/voter_data_with_coords_sliced.json');
    String jsonData = jsonEncode(_voterData);
    file.writeAsString(jsonData);
  }

  Future<void> _createMarkersFromData() async {
    _markers.clear();

    print('Starting Marker Creation');
    print(_markers);
    print(_filteredData);

    for (var voter in _filteredData){
      try{
        // if (voter['Latitude'] == null || voter['Longitude'] == null) {
        //   List<Location> locations = await locationFromAddress(
        //     voter['Address'] + ', ' + voter['City'] + ', ' + voter['State']
        //   ) as List<Location>;
        //   if (locations.isNotEmpty) {
        //     voter['Latitude'] = locations.first.latitude;
        //     voter['Longitude'] = locations.first.longitude;
        //   }
        // }else{
        //   String name = voter['EnvName'];
        //   print("Location already found for $name ");
        // }


        final String voterName = voter['EnvName'];
        final String city = voter['City'];
        final String state = voter['State'];
        final String address = voter['Address'];

        Marker marker = Marker(
          markerId: MarkerId(voter['Voter File VANID'].toString()),
          position: LatLng(voter['Latitude'], voter['Longitude']),
          infoWindow: InfoWindow(
            title: voterName,
            snippet: "$address, $city, $state",
          ),
        );

        _markers.add(marker);

      
      } catch(e) {
        print("Error getting location for ${voter['EnvName']}: $e");
      }
    }

    print('Finished Marker Creation');
    
    setState(() {
      _isLoading = false;
    });

  }

  void _turnOnLoading() {

    setState(() {
      _isLoading = true;
    });
  }

  Future<void> _filterData() async {
    print("FILTERING ON $_selectedZipCode, and $_selectedPhoneType and $selectedState");
    _filteredData = _voterData.where((voter) {
      bool matchesZip = voter['Zip5'] == int.parse(_selectedZipCode);
      bool matchesPhoneType = _selectedPhoneType.contains(voter['PhoneIsCell']);
      return voter['State'] == selectedState && matchesZip && matchesPhoneType;
    }).toList();
    print("FILTERED DATA: ");
    print(_filteredData);
    _turnOnLoading();
    await _createMarkersFromData();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  _showModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FormModal();
        // return SizedBox(
        //   height: 600,
        //   child: Center(
            
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       mainAxisSize: MainAxisSize.min,
        //       children: <Widget>[
        //         const Text('Filter'),
        //         Expanded(
        //           child: Form(
        //             key: _formKey,
        //             child: Column(
        //               children: <Widget> [
        //                 TextFormField(
        //                   onChanged: (value) => _selectedZipCode = value,
        //                   decoration: const InputDecoration(
        //                     hintText: 'Zip Code',
        //                   ),
        //                 ),

        //                 MultiSelectDialogField(
        //                   items: phoneTypes.map((e) => MultiSelectItem(e, e)).toList(),
        //                   listType: MultiSelectListType.CHIP,
        //                   onConfirm: (values){
        //                     _selectedPhoneType = values;
        //                   }

        //                 ),
                        
        //                 ElevatedButton(
        //                   child: const Text('Close BottomSheet'),
        //                   onPressed: () => {
        //                     Navigator.pop(context),
        //                     _filterData(),
        //                   }
        //                 ),

        //               ]
                      
        //             )

        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        // );
      },
    );
  }

  Future<void> _goToPosition1() async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(centerPosition));
  }

  Widget button(VoidCallback function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Maps Sample App'),
            backgroundColor: Colors.green[700],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('SelectedValue: $selectedState'),
                      ),
                      Expanded(
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: centerPosition,
                          markers: Set<Marker>.of(_markers),
                        )
                      )
                    ]
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align (
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: <Widget>[
                          button(_showModal, Icons.map),
                          // SizedBox(
                            // height: 16.0,
                          // ),
                          // button(writeJsonData() as VoidCallback, Icons.file_download),
                          SizedBox(
                            height: 16.0,
                          )
                        ]
                      )  
                    )
                  )
                ])
      )
    );
  }
}

