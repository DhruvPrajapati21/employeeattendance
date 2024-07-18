import 'package:fbserviceauthentication/Admin/Admin.dart';
import 'package:fbserviceauthentication/Appdevelopment/Appdeveloper.dart';
import 'package:fbserviceauthentication/DIgitalmarketing/Digitalmarketing.dart';
import 'package:fbserviceauthentication/Graphics/Graphics.dart';
import 'package:fbserviceauthentication/Adminscreen.dart';
import 'package:fbserviceauthentication/Vidioeditor/Vidioeditor.dart';
import 'package:fbserviceauthentication/Webdevelopment/Webdeveloper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditAppdevelopmentscreen extends StatefulWidget {
  final String documentId;
  final String imageurl;

  const EditAppdevelopmentscreen({Key? key, required this.documentId, required this.imageurl})
      : super(key: key);

  @override
  _EditAppdevelopmentscreenState createState() => _EditAppdevelopmentscreenState();
}

class _EditAppdevelopmentscreenState extends State<EditAppdevelopmentscreen> {
  List<String> items = [
    'Department',
    'Digital Marketing',
    'App Development',
    'Web Development',
    'Video Editor',
    'Graphics',
    'Admin'
  ];
  String? selectedDepartment = 'Department';
  DateTime? selectedDate;
  DateTime? selectedDate2;
  File? selectedImage;
  final picker = ImagePicker();
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController empIdController = TextEditingController();
  final TextEditingController empEmailIdController = TextEditingController();
  final TextEditingController empPhoneNumberController = TextEditingController();
  final TextEditingController empBloodGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(widget.documentId)
          .get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      selectedDepartment = data['department'];
      empNameController.text = data['name'];
      empIdController.text = data['id'];
      empEmailIdController.text = data['emailid'];
      empPhoneNumberController.text = data['phonenumber'];
      empBloodGroupController.text = data['bloodgroup'];

      if (data['dob'] is String) {
        selectedDate = DateFormat('dd/MM/yyyy').parse(data['dob']);
      } else if (data['dob'] is Timestamp) {
        Timestamp timestamp = data['dob'] as Timestamp;
        selectedDate = timestamp.toDate();
      }

      if (data['doj'] is String) {
        selectedDate2 = DateFormat('dd/MM/yyyy').parse(data['doj']);
      } else if (data['doj'] is Timestamp) {
        Timestamp timestamp = data['doj'] as Timestamp;
        selectedDate2 = timestamp.toDate();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate2 ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate2) {
      setState(() {
        selectedDate2 = pickedDate;
      });
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
          'Admin_Images/${DateTime.now().toString()}');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
      return await storageSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  void _editAdmin() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? imageurl = widget.imageurl;

      if (selectedImage != null) {
        imageurl = await uploadImageToStorage(selectedImage!);
      }

      String formattedDOB = selectedDate != null ? DateFormat('dd/MM/yyyy')
          .format(selectedDate!) : '';
      String formattedDOJ = selectedDate2 != null ? DateFormat('dd/MM/yyyy')
          .format(selectedDate2!) : '';

      await FirebaseFirestore.instance.collection('Employees').doc(
          widget.documentId).update({
        'department': selectedDepartment,
        'name': empNameController.text.trim(),
        'id': empIdController.text.trim(),
        'emailid': empEmailIdController.text.trim(),
        'phonenumber': empPhoneNumberController.text.trim(),
        'bloodgroup': empBloodGroupController.text.trim(),
        'dob': formattedDOB,
        'doj': formattedDOJ,
        'Imageurl': imageurl,
      });

      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Data Updated Successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.cyan,
        textColor: Colors.white,
      );

      switch (selectedDepartment) {
        case 'Graphics':
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Graphics()));
          break;
        case 'Digital Marketing':
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Digitalmarketing()));
          break;
        case 'Admin':
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Admin()));
          break;
        case 'Web Development':
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Webdeveolper()));
          break;
        case 'Video Editor':
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => VidioEditor()));
          break;
        default:
          break;
      }
    } catch (e) {
      print("Failed to update document: $e");
      Fluttertoast.showToast(
        msg: 'Error updating data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Widget _buildDatePickerField2(String labelText, DateTime? selectedDate,
      Future<void> Function(BuildContext) onSelectDate) {
    TextEditingController dojcontroller = TextEditingController();
    if (selectedDate2 != null) {
      dojcontroller.text = DateFormat('dd/MM/yyyy').format(selectedDate2!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GestureDetector(
        onTap: () async {
          await onSelectDate(context);
          setState(() {
            dojcontroller.text =
            selectedDate2 != null ? 'Selected Date: ${DateFormat('dd/MM/yyyy')
                .format(selectedDate2!)}' : '';
          });
        },
        child: TextField(
          controller: dojcontroller,
          decoration: InputDecoration(
            labelText: 'DOJ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _selectDate2(context);
              },
              icon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text(
          "Edit App Data",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              selectedImage != null
                  ? Image.file(selectedImage!, width: 200, height: 200)
                  : Image.network(
                widget.imageurl,
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file != null) {
                        selectedImage = File(file.path);
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                    child: const Text(
                      "Select Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDepartment = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              _buildTextField(
                  empNameController, 'Employee Name', 'Enter Employee Name'),
              _buildTextField(
                  empIdController, 'Employee ID', 'Enter Employee ID'),
              _buildTextField(empEmailIdController, 'Employee Email ID',
                  'Enter Employee Email ID'),
              _buildTextField(empPhoneNumberController, 'Employee Phone Number',
                  'Enter Employee Phone Number'),
              _buildTextField(empBloodGroupController, 'Employee Blood Group',
                  'Enter Employee Blood Group'),
              _buildDatePickerField('Date of Birth', selectedDate, _selectDate),
              _buildDatePickerField2(
                  'Date of Joining', selectedDate2, _selectDate2),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _editAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      "Edit Data",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String labelText, DateTime? selectedDate,
      Future<void> Function(BuildContext) onSelectDate) {
    TextEditingController dateController = TextEditingController();
    if (selectedDate != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GestureDetector(
        onTap: () async {
          await onSelectDate(context);
          setState(() {
            dateController.text =
            selectedDate != null ? 'Selected Date: ${DateFormat('dd/MM/yyyy')
                .format(selectedDate!)}' : '';
          });
        },
        child: TextField(
          controller: dateController,
          decoration: InputDecoration(
            labelText: 'DOB',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _selectDate(context);
              },
              icon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }
}