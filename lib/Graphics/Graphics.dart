import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fbserviceauthentication/Employee/Empmodel.dart';
import 'package:fbserviceauthentication/Admin/EditAdminscreen.dart';
import 'package:fbserviceauthentication/Adminscreen.dart';

class Graphics extends StatefulWidget {
  @override
  _GraphicsState createState() => _GraphicsState();
}

class _GraphicsState extends State<Graphics> {
  Map<String, String?> imageCache = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Employees')
          .where('department', isEqualTo: 'Graphics')
          .get();

      for (var doc in querySnapshot.docs) {
        String? imageUrl = doc.get('Imageurl') as String?;
        imageCache[doc.id] = imageUrl;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching image URLs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text(
          'Graphics Data',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          : StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Employees')
            .where('department', isEqualTo: 'Graphics')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Firestore Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }

          // Update imageCache
          for (var doc in snapshot.data!.docs) {
            String? imageUrl = doc.get('Imageurl') as String?;
            imageCache[doc.id] = imageUrl;
          }

          List<Employee> employees = snapshot.data!.docs.map((doc) {
            return Employee.fromSnapshot(doc);
          }).toList();

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (BuildContext context, int index) {
              Employee employee = employees[index];

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Card(
                  color: Colors.white60,
                  margin: EdgeInsets.all(11.0),
                  child: ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Department: ${employee.department}',
                            style: TextStyle(color: Colors.black)),
                        Text('Name: ${employee.name}',
                            style: TextStyle(color: Colors.black)),
                        Text('ID: ${employee.id}',
                            style: TextStyle(color: Colors.black)),
                        Text('EmailId: ${employee.emailid}',
                            style: TextStyle(color: Colors.black)),
                        Text('PhoneNumber: ${employee.phonenumber}',
                            style: TextStyle(color: Colors.black)),
                        Text('BloodGroup: ${employee.bloodgroup}',
                            style: TextStyle(color: Colors.black)),
                        Text('DOB: ${employee.dob}',
                            style: TextStyle(color: Colors.black)),
                        Text('DOJ: ${employee.doj}',
                            style: TextStyle(color: Colors.black)),
                        SizedBox(height: 15),
                        Container(
                          height: 120,
                          width: 120,
                          child: imageCache[employee.documentId] != null
                              ? Image.network(
                            imageCache[employee.documentId]!,
                            fit: BoxFit.fill,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                Text('Error loading image: $error'),
                          )
                              : Center(
                            child: Text(
                              'No Image Available',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirm Delete"),
                                  content: Text(
                                      "Are you sure you want to delete this item?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('Employees')
                                            .doc(employee.documentId)
                                            .delete();
                                        Navigator.of(context).pop();
                                        Fluttertoast.showToast(
                                          msg: "Item Deleted Successfully",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.cyan,
                                          textColor: Colors.white,
                                        );
                                      },
                                      child: Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.teal),
                          onPressed: () async {
                            String? imageUrl = imageCache[employee.documentId];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAdminscreen(
                                  documentId: employee.documentId,
                                  imageurl: imageUrl ?? '', // Default empty string if imageUrl is null
                                ),
                              ),
                            ).then((_) {
                              // Refresh data after returning from edit screen
                              fetchImageUrls();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
