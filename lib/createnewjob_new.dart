import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_ca_management_app/widgets/customappbar.dart';
import 'package:provider/provider.dart';
import './services/dbcollection.dart';
import 'checkconnectivity.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
TextStyle snackBarTextStyle =
    TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold);

class CreateNewJob extends StatefulWidget {
  final String companyId;
  final String currentUser;

  CreateNewJob(this.companyId, this.currentUser);
  @override
  _CreateNewJobState createState() => _CreateNewJobState();
}

class _CreateNewJobState extends State<CreateNewJob> {
  bool resetValue = false;
  String _jobType;
  String _assignedTo_1;
  String _assignedTo_2;
  List employees = [];
  List assignedTo = [];

  @override
  void initState() {
    super.initState();
    addEmpListToArr();
  }

  addEmpListToArr() async {
    await FirebaseFirestore.instance
        .collection(widget.companyId)
        .doc("UserDocument")
        .collection("UserCollection")
        .get()
        .then((snapshots) => {
              for (var i = 0; i < snapshots.docs.length; i++)
                {employees.add(snapshots.docs[i].data()["name"])}
            });
    print("State" + employees.toString());
    if (employees.isNotEmpty) {
      setState(() {
        print("Set state called");
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static List<String> friendsList = [null];

  final TextEditingController _clientName = TextEditingController();
  final TextEditingController _jobSubType = TextEditingController();
  final TextEditingController _jobDescription = TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();

  DateTime _selectedDueDate;
  var _docCount = 0;
  double sizedBoxHeight = 10;
  int empToAddCount = 1;
  int teamLeadToAddCount = 1;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2050),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return null;
      }
      setState(() {
        _selectedDueDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInternetConnectivityProvider>(
        builder: (context, checkConnection, child) {
      return SafeArea(
        child: Scaffold(
          appBar: customAppBar(context, "Create Job"),
          body: ListView(
            physics: new BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            shrinkWrap: true,
            padding: EdgeInsets.all(5),
            children: [
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: sizedBoxHeight,
                    ),
                    TextFormField(
                      controller: _clientName,
                      decoration: InputDecoration(
                        labelText: 'Client Details',
                        prefixIcon: Icon(
                          Icons.business_center_outlined,
                          //color: Color(0xFF003580),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) return 'Please enter some text';
                        return null;
                      },
                    ),
                    SizedBox(
                      height: sizedBoxHeight,
                    ),
                    getDifferentJobsList("Select Job Type"),
                    TextFormField(
                      controller: _jobSubType,
                      decoration: InputDecoration(
                        labelText: 'Add Job Sub Type',
                        prefixIcon: Icon(
                          Icons.work_outline_outlined,
                          //color: Color(0xFF003580),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) return 'Please enter some text';
                        return null;
                      },
                    ),
                    SizedBox(
                      height: sizedBoxHeight,
                    ),
                    ..._getFriends(),
                    /*for (int i = 0; i < teamLeadToAddCount; i++)
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child:
                                  getEmpList("Team Lead", teamLeadToAddCount)),
                          Expanded(
                              child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        teamLeadToAddCount =
                                            teamLeadToAddCount + 1;
                                        setState(() {
                                          // print(teamLeadToAddCount.toString());
                                        });
                                      }),
                                ),
                                Expanded(
                                  child: IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: teamLeadToAddCount != 1
                                          ? () {
                                              teamLeadToAddCount =
                                                  teamLeadToAddCount - 1;
                                              setState(() {
                                                // print(teamLeadToAddCount.toString());
                                              });
                                            }
                                          : null),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),*/
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      height: 50,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                            child: Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextButton(
                              onPressed: () {
                                _presentDatePicker();
                              },
                              child: Text(
                                _selectedDueDate == null
                                    ? DateFormat.yMMMd().format(DateTime.now())
                                    : DateFormat.yMMMd()
                                        .format(_selectedDueDate),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: sizedBoxHeight,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _jobDescription,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Comments",
                      ),
                      maxLines: 5,
                      scrollPhysics: new BouncingScrollPhysics(),
                    ),
                    SizedBox(
                      height: sizedBoxHeight,
                    ),
                    MaterialButton(
                        child: Text(
                          "Create Job",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 19),
                        ),
                        height: 50,
                        minWidth: double.infinity,
                        color: Colors.amber[600],
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.amber,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(0.0)),
                        onPressed: () async {
                          if (checkConnection.isOnline != null) {
                            if (checkConnection.isOnline) {
                              var currentYear = DateTime.now().year.toString();

                              var jobMonth = DateTime.now().month.toInt() < 10
                                  ? "0" + DateTime.now().month.toString()
                                  : DateTime.now().month.toString();

                              var jobDate = DateTime.now().day.toInt() < 10
                                  ? "0" + DateTime.now().day.toString()
                                  : DateTime.now().day.toString();

                              getDocumentCount(currentYear + jobMonth + jobDate)
                                  .then((docCount) {
                                _docCount = docCount + 1;
                                var docCounter = _docCount < 10
                                    ? "00" + _docCount.toString()
                                    : docCount < 99
                                        ? "0" + _docCount.toString()
                                        : _docCount.toString();

                                var uniqueJobId = "SR" +
                                    currentYear +
                                    jobMonth +
                                    jobDate +
                                    docCounter;

                                if (_formKey.currentState.validate()) {
                                  DocumentReference documentReference =
                                      dbCollection
                                          .collection(widget.companyId)
                                          .doc("JobDocument")
                                          .collection("JobCollection")
                                          .doc(uniqueJobId);

                                  var data = {
                                    "employee": {
                                      "assignedTo": [
                                        "Test User",
                                        "Nithiya Gurusamy"
                                      ],
                                      "teamLead": ["Admin User"]
                                    },
                                    "createdDate":
                                        currentYear + jobMonth + jobDate,
                                    "companyId": widget.companyId,
                                    "clientName": _clientName.text.trim(),
                                    "jobType": _jobType,
                                    "jobSubType": _jobSubType.text.trim(),
                                    "currentStatus": "Created",
                                    "dueDate": _selectedDueDate == null
                                        ? DateTime.now()
                                        : _selectedDueDate,
                                  };

                                  var jobDescriptionNotEmpty = {
                                    "jobDescription": FieldValue.arrayUnion([
                                      "${widget.currentUser}: ${_jobDescription.text}"
                                    ])
                                  };

                                  _jobDescription.text.isNotEmpty
                                      ? documentReference
                                          .set(data)
                                          .then((value) {
                                          documentReference
                                              .update(jobDescriptionNotEmpty)
                                              .then((value) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    backgroundColor:
                                                        Colors.amber,
                                                    content: Text(
                                                      "New Job $uniqueJobId created successfully",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    )));
                                          });
                                        })
                                      : documentReference
                                          .set(data)
                                          .then((value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.amber,
                                                  content: Text(
                                                    "New Job $uniqueJobId created successfully",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )));
                                        });

                                  resetAllValues();
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        "No Internet Connection",
                                        style: TextStyle(color: Colors.black),
                                      )));
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void resetAllValues() {
    _formKey.currentState.reset();
    _clientName.clear();
    _jobDescription.clear();
    _jobSubType.clear();
    setState(() {
      _selectedDueDate = null;
      _assignedTo_1 = null;
      _jobType = null;
    });
  }

  Future<int> getDocumentCount(String currentDate) async {
    Query collectionReference = dbCollection
        .collection(widget.companyId)
        .doc("JobDocument")
        .collection("JobCollection")
        .where("createdDate", isEqualTo: currentDate);
    var count = await collectionReference.get().then((val) => val.size);
    return count;
  }

  getEmpList(String empType, int empToAddCount) {
    List<DropdownMenuItem> empList = [];
    if (employees.isEmpty) {
      print("Loading employee");
      Text("Loading");
    } else {
      print("Printing " + employees.toString());
      for (int i = 0; i < employees.length; i++) {
        empList.add(DropdownMenuItem(
          child: Text(employees[i]),
          value: employees[i],
        ));
      }
    }
    // write a custom widget with two dropdownbutton to reduce the number of calls
    return customDropDownButtonEmpField(empList, empType, empToAddCount);
  }

  /*StreamBuilder<QuerySnapshot> getEmpList() {
    return StreamBuilder(
        stream: dbCollection
            .collection(widget.companyId)
            .doc("UserDocument")
            .collection("UserCollection")
            .snapshots(),
        builder: (context, snapshot) {
          List<DropdownMenuItem> empList = [];
          if (!snapshot.hasData) {
            Text("Loading");
          } else {
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              empList.add(DropdownMenuItem(
                child: Text(snapshot.data.docs[i].data()["name"]),
                value: snapshot.data.docs[i].data()["name"],
              ));
            }
          }
          // write a custom widget with two dropdownbutton to reduce the number of calls
          return customDropDownButtonEmpField(empList);
        });
  }*/

  /*StreamBuilder<QuerySnapshot> getTeamLeadList() {
    return StreamBuilder(
        stream: dbCollection
            .collection(widget.companyId)
            .doc("UserDocument")
            .collection("UserCollection")
            .snapshots(),
        builder: (context, snapshot) {
          List<DropdownMenuItem> empList = [];
          if (!snapshot.hasData) {
            Text("Loading");
          } else {
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              empList.add(DropdownMenuItem(
                child: Text(snapshot.data.docs[i].data()["name"]),
                value: snapshot.data.docs[i].data()["name"],
              ));
            }
          }
          // write a custom widget with two dropdownbutton to reduce the number of calls
          return customDropDownButtonTeamLeadField(empList);
        });
  }*/

  StreamBuilder<QuerySnapshot> getDifferentJobsList(String jobType) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(widget.companyId)
            .doc("JobTypeDocument")
            .collection("JobTypeCollection")
            .snapshots(),
        builder: (context, snapshot) {
          List<DropdownMenuItem> jobTypeList = [];
          if (!snapshot.hasData) {
            Text("Loading");
          } else {
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              jobTypeList.add(DropdownMenuItem(
                child: Text(snapshot.data.docs[i].id),
                value: snapshot.data.docs[i].id,
              ));
            }
          }
          return DropdownButtonFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.work_outline_outlined,
                  // color: Color(0xFF003580),
                ),
              ),
              hint: Text("$jobType"),
              items: jobTypeList,
              onChanged: (jobType) {
                _jobType = jobType;
              },
              value: _jobType,
              validator: (var value) {
                if (value == null) return 'Please Select Job Type';
                return null;
              });
        });
  }

  Widget customDropDownButtonEmpField(
      List<DropdownMenuItem> empList, String empType, int empIndex) {
    print("List " + empList.toString());
    return Container(
      child: Column(
        children: [
          DropdownButtonFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.person_outline_outlined,
                  //color: Color(0xFF003580),
                ),
              ),
              hint: Text(empType),
              items: empList,
              onChanged: (empname) => _assignedToController.text = empname,
              value: _assignedTo_1,
              validator: (var value) {
                if (value == null) return 'Please select any Employee';

                return null;
              }),
          SizedBox(
            height: sizedBoxHeight,
          ),
        ],
      ),
    );
  }

  Widget customDropDownButtonTeamLeadField(List<DropdownMenuItem> empList) {
    return Container(
      child: DropdownButtonFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.person_outline_outlined,
              //color: Color(0xFF003580),
            ),
          ),
          hint: Text("Team Lead"),
          items: empList,
          onChanged: (empname) => _assignedTo_2 = empname,
          value: _assignedTo_2,
          validator: (var value) {
            if (value == null) return 'Please select any Employee';

            return null;
          }),
    );
  }

  List<Widget> _getFriends() {
    List<Widget> friendsTextFields = [];
    for (int i = 0; i < friendsList.length; i++) {
      friendsTextFields.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Expanded(child: FriendTextFields(i)),
            SizedBox(
              width: 16,
            ),
            // we need add button at last friends row
            _addRemoveButton(i == friendsList.length - 1, i),
          ],
        ),
      ));
    }
    return friendsTextFields;
  }

  /// add / remove button
  Widget _addRemoveButton(bool add, int index) {
    return InkWell(
      onTap: () {
        if (add) {
          // add new text-fields at the top of all friends textfields
          friendsList.insert(0, null);
        } else
          friendsList.removeAt(index);
        setState(() {});
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: (add) ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          (add) ? Icons.add : Icons.remove,
          color: Colors.white,
        ),
      ),
    );
  }
}

class FriendTextFields extends StatefulWidget {
  final int index;
  FriendTextFields(this.index);
  @override
  _FriendTextFieldsState createState() => _FriendTextFieldsState();
}

class _FriendTextFieldsState extends State<FriendTextFields> {
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nameController.text = _CreateNewJobState.friendsList[widget.index] ?? '';
    });

    return Container(
      child: Column(
        children: [
          DropdownButtonFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.person_outline_outlined,
                  //color: Color(0xFF003580),
                ),
              ),
              hint: Text("Assigned To"),
              items: _CreateNewJobState().employees,
              onChanged: (empname) => _nameController.text = empname,
              value: _nameController,
              validator: (var value) {
                if (value == null) return 'Please select any Employee';

                return null;
              }),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
