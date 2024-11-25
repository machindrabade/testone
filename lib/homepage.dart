import 'package:test_one/Userinfo.dart';
import 'package:test_one/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_one/sql_helper.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SQLHelper handler = new SQLHelper();
  int? position;
  String imgUrl = "";
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int count = 0;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    if (count == 0) {
      getData();
      count++;
    } else {}
    _refreshJournals();
  }

  // All journals
  List<Map<String, dynamic>> _journals = [];

  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      imgUrl = "";
      emailController.text = "";
      firstNameController.text = "";
      lastNameController.text = "";
      _journals = data;
      _isLoading = false;
    });
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted!'),
    ));
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, emailController.text,
        firstNameController.text, lastNameController.text, imgUrl);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully Updated!'),
    ));
    _refreshJournals();
  }

  Future<List<Data>> getData() async {
    List<Data> list = [];
    final res = await http.get(Uri.parse("https://reqres.in/api/users?page=1"));

    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var rest = data["data"] as List;
      list = rest.map<Data>((json) => Data.fromJson(json)).toList();
      print("List Size: ${list.length}");
      handler.queryAllRows();
      for (int count = 0; count < list.length; count++) {
        await SQLHelper.createItem(
            list[count].id!.toInt(),
            list[count].email.toString(),
            list[count].firstName.toString(),
            list[count].lastName.toString(),
            list[count].avatar.toString());
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data save to local DB Successfully!'),
      ));
      setState(() {
        print("data added to sqflite");
      });
      _isLoading = false;
    } else {
      print("error");
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_sharp),
          color: Colors.black,
          iconSize: 40,
          onPressed: () {
            // Navigator.push(context,
            // MaterialPageRoute(builder: (context) => AddDevice2()));
            // Get.to(const AddDevice2());
          },
        ),
        title: Text(
          "My Home",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : InkWell(
                    onTap: () {
                      setState(() {
                        _isLoading = true;
                        getData();
                        _isLoading = false;
                      });
                    },
                    child: Icon(
                      Icons.refresh,
                      color: Colors.black,
                    )),
          )
        ],
      ),
      // appBar: AppBar(
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Text("test"),
      //       _isLoading
      //           ? const Center(
      //         child: CircularProgressIndicator(),
      //       )
      //           :InkWell(onTap:(){
      //             setState(() {
      //               _isLoading=true;
      //               getData();
      //               _isLoading=false;
      //             });
      //       },child: Icon(Icons.refresh)),
      //
      //     ],
      //   ),
      // ),
      body: Column(
        children: [
          Container(
              height: 50,
              alignment: Alignment.center,
              child: FutureBuilder(
                future: handler.getEmpData(),
                builder: (context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    position = snapshot.data![index]['id'];
                                    imgUrl = snapshot.data![index]['avatar'];
                                    emailController.text =
                                        snapshot.data![index]['email'];
                                    firstNameController.text =
                                        snapshot.data![index]['first_name'];
                                    lastNameController.text =
                                        snapshot.data![index]['last_name'];
                                  });
                                },
                                child: Text(
                                  ' ${snapshot.data![index]['first_name']} ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF8BC34A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    )),
                              ),
                            ),
                          );
                        });
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.black,
                    ));
                  }
                },
              )),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: CircleAvatar(
                              child: Image.network(imgUrl != ""
                                  ? imgUrl
                                  : "https://www.hindupedia.com/images/3/31/Om-image.jpg")),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: Container(
                          // height: consraints.maxHeight*0.14,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.pinkAccent, width: 1.5)),

                          child: Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Center(
                              child: TextFormField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person_outline_outlined,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'First name',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Container(
                          // height: consraints.maxHeight*0.14,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.pinkAccent, width: 1.5)),

                          child: Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Center(
                              child: TextFormField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person_outline_outlined,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Last name',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Container(
                          // height: consraints.maxHeight*0.14,
                          decoration: BoxDecoration(
                              color: Color(0xffffffff).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Colors.pinkAccent, width: 1.5)),
                          child: Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Center(
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: InputBorder.none,
                                  hintText: 'test@gmail.com',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (position != null) {
                            _updateItem(position!);
                            print("Data updated");
                          } else {
                            print("Select item for update");
                          }
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8BC34A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (position != null) {
                            _deleteItem(position!);
                            print("Data Deleted");
                          } else {
                            print("Select item for delete");
                          }
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8BC34A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
