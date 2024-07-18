import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Adminscreen.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({Key? key}) : super(key: key);

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> items = [
    'Department', 'Digital Marketing', 'App Development', 'Web Development', 'Video Editor', 'Graphics', 'Admin'
  ];
  String? selectedDepartment = 'Department';
  DateTime? selectedDate;
  DateTime? selectedJoiningDate;
  File? selectedImage;
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController empIdController = TextEditingController();
  final TextEditingController empEmailIdController = TextEditingController();
  final TextEditingController empPhoneNumberController = TextEditingController();
  final TextEditingController empBloodGroupController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController dojController = TextEditingController();

  Future<void> _selectDate(BuildContext context, {required bool isDOB}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isDOB) {
          selectedDate = pickedDate;
          dobController.text = _formatDate(pickedDate);
        } else {
          selectedJoiningDate = pickedDate;
          dojController.text = _formatDate(pickedDate);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _addToFirestore() async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form fields

      setState(() {
        isLoading = true;
      });

      try {
        String? imagePath = ''; // Initialize imagePath as nullable
        if (selectedImage != null) {
          print('Uploading image...');
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

          UploadTask uploadTask = ref.putFile(selectedImage!);
          TaskSnapshot snapshot = await uploadTask;
          imagePath = await snapshot.ref.getDownloadURL();
          print('Image uploaded: $imagePath');
        }

        print('Adding document to Firestore...');
        await _firestore.collection('Employees').add({
          'department': selectedDepartment,
          'name': empNameController.text.trim(),
          'id': empIdController.text.trim(),
          'emailid': empEmailIdController.text.trim(),
          'phonenumber': empPhoneNumberController.text.trim(),
          'bloodgroup': empBloodGroupController.text.trim(),
          'dob': _formatDate(selectedDate!),
          'doj': _formatDate(selectedJoiningDate!),
          'Imageurl': imagePath // Use empty string if imagePath is null
        });

        setState(() {
          // Reset fields after successful submission
          selectedDepartment = 'Department';
          selectedDate = null;
          selectedJoiningDate = null;
          selectedImage = null;
          empNameController.clear();
          empIdController.clear();
          empEmailIdController.clear();
          empPhoneNumberController.clear();
          empBloodGroupController.clear();
          dobController.clear();
          dojController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data added to Firestore successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        print('Error adding data to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add data to Firestore. Please try again. Error: $e'),
            duration: Duration(seconds: 5),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text(
          "Add Employee",
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.home, size: 25, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Adminscreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: <Widget>[
                  selectedImage != null
                      ? Image.file(selectedImage!, width: 200, height: 200)
                      : Image.asset("assets/images/empty.png", width: 100, height: 100),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: ElevatedButton(
                        onPressed: () async {
                          ImagePicker imagePicker = ImagePicker();
                          XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                          if (file == null) return;
                          selectedImage = File(file.path);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        child: const Text(
                          "Select Image",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            width: 1,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      value: selectedDepartment,
                      items: items.map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: TextStyle(fontSize: 18)),
                      )).toList(),
                      onChanged: (item) => setState(() => selectedDepartment = item),
                      validator: (value) {
                        if (value == null || value.isEmpty || value == 'Department') {
                          return "Please select a department";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                      controller: empNameController,
                      decoration: InputDecoration(
                          labelText: ' Enter Your Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                      controller: empIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Enter Your Id',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your ID";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: empEmailIdController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Enter Your EmailID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.contains('@') || !value.contains('.com') || !value.contains('gmail')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: empPhoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Enter Your Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (value.length != 10) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: empBloodGroupController,
                      decoration: InputDecoration(
                          labelText: ' Enter Your Blood Group',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your blood group';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, isDOB: true);
                      },
                      controller: TextEditingController(
                        text: selectedDate == null
                            ? 'Select Date'
                            : 'Selected DOB: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                      ),
                      decoration: InputDecoration(
                        labelText: "DOB",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _selectDate(context, isDOB: true);
                          },
                          icon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, isDOB: false); // Change isDOB to false for DOJ
                      },
                      controller: TextEditingController(
                        text: selectedJoiningDate == null
                            ? 'Select Date'
                            : 'Selected DOJ: ${DateFormat('dd/MM/yyyy').format(selectedJoiningDate!)}',
                      ),
                      decoration: InputDecoration(
                        labelText: "DOJ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _selectDate(context, isDOB: false);
                          },
                          icon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select an image.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else {
                            _addToFirestore();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "Submit",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
