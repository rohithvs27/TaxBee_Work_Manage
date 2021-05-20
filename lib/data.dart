import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_ca_management_app/widgets/customappbar.dart';
import './services/dbcollection.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class CreateNewJob extends StatefulWidget {
  final String companyId;
  final String name;

  CreateNewJob(this.companyId, this.name);
  @override
  _CreateNewJobState createState() => _CreateNewJobState();
}

class _CreateNewJobState extends State<CreateNewJob> {
  bool resetValue = false;
  String _jobType;
  String _assignedTo;
  String _teamLead;
  List<String> assignedToList = [];
  List employees = [];
  List dyEmp = [];

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
                {dyEmp.add(snapshots.docs[i].data()["name"])}
            });

    if (dyEmp.isNotEmpty) {
      setState(() {
        //employees = List.from(dyEmp);
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _clientName = TextEditingController();
  final TextEditingController _jobSubType = TextEditingController();
  final TextEditingController _jobDescription = TextEditingController();

  DateTime _selectedDueDate;
  var docCount = 0;
  double sizedBoxHeight = 10;
  int empToAddCount = 1;

  void _presentDatePicker() {
    print(DateFormat.yMMMd().format(DateTime.now()));
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
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: empToAddCount,
                      itemBuilder: (context, index) {
                        return getEmpList("AssignedTo", index);
                      }),
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
                                  : DateFormat.yMMMd().format(_selectedDueDate),
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
                      labelText: "Job Description",
                    ),
                    maxLines: 5,
                    scrollPhysics: new BouncingScrollPhysics(),
                    validator: (String value) {
                      if (value.isEmpty) return 'Please enter some text';
                      return null;
                    },
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
                        var currentYear = DateTime.now().year.toString();

                        var jobMonth = DateTime.now().month.toInt() < 10
                            ? "0" + DateTime.now().month.toString()
                            : DateTime.now().month.toString();

                        var jobDate = DateTime.now().day.toInt() < 10
                            ? "0" + DateTime.now().day.toString()
                            : DateTime.now().day.toString();

                        getDocumentCount(currentYear + jobMonth + jobDate)
                            .then((docCount) {
                          docCount = docCount + 1;
                          var docCounter = docCount < 10
                              ? "00" + docCount.toString()
                              : docCount < 99
                                  ? "0" + docCount.toString()
                                  : docCount.toString();

                          var uniqueJobId = "SR" +
                              currentYear +
                              jobMonth +
                              jobDate +
                              docCounter;

                          if (_formKey.currentState.validate()) {
                            if (_jobSubType.text.isNotEmpty &&
                                _jobType == null) {
                              DocumentReference jobTypeReference = dbCollection
                                  .collection("JobTypeCollection")
                                  .doc(_jobSubType.text);

                              jobTypeReference.get().then((docSnap) => {
                                    if (!docSnap.exists)
                                      {jobTypeReference.set({})}
                                  });
                            }

                            DocumentReference documentReference = dbCollection
                                .collection(widget.companyId)
                                .doc("JobDocument")
                                .collection("JobCollection")
                                .doc(uniqueJobId);

                            documentReference.set({
                              "companyId": widget.companyId,
                              "createdDate": currentYear + jobMonth + jobDate,
                              "clientName": _clientName.text.trim(),
                              "jobType": _jobType,
                              "jobSubType": _jobSubType.text.trim(),
                              "assignedTo": _assignedTo,
                              "teamLead": _teamLead,
                              "currentStatus": "Created",
                              "dueDate": _selectedDueDate == null
                                  ? DateTime.now()
                                  : _selectedDueDate,
                              // "jobDescription": _jobDescription.text,
                            });

                            documentReference.update({
                              "jobDescription": FieldValue.arrayUnion(
                                  ["${widget.name}: ${_jobDescription.text}"])
                            });

                            resetAllValues();

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.amber,
                                content: Text(
                                  "New Job $uniqueJobId created successfully",
                                  style: TextStyle(color: Colors.black),
                                )));
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void resetAllValues() {
    _formKey.currentState.reset();
    _clientName.clear();
    _jobDescription.clear();
    _jobSubType.clear();
    setState(() {
      _selectedDueDate = null;
      _assignedTo = null;
      _teamLead = null;
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

  /*StreamBuilder<QuerySnapshot> getEmpList(sizedBoxHeight) {
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
          return customDropDownButtonFormField(empList, sizedBoxHeight);
        });
  }*/

  getEmpList(String empType, int index) {
    employees = List.from(dyEmp);

    List<DropdownMenuItem> empList = [];
    if (employees.isEmpty) {
      print("Loading employee");
      Text("Loading");
    } else {
      //print("Printing " + employees.toString());
      for (int i = 0; i < employees.length; i++) {
        empList.add(DropdownMenuItem(
          child: Text(employees[i]),
          value: employees[i],
        ));
      }
    }
    // write a custom widget with two dropdownbutton to reduce the number of calls
    return customDropDownButtonEmpField(empList, empType, index);
  }

  Widget customDropDownButtonEmpField(
      List<DropdownMenuItem> empList, String empType, int index) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_outline_outlined,
                        //color: Color(0xFF003580),
                      ),
                    ),
                    hint: Text(empType),
                    items: empList,
                    onChanged: (empname) {
                      if (assignedToList.length == 0) {
                        assignedToList.add(empname);
                      } else if (assignedToList.length == index) {
                        if (assignedToList.contains(empname)) {
                        } else
                          assignedToList.add(empname);
                      } else {
                        assignedToList.removeAt(index);
                        if (assignedToList.contains(empname)) {
                        } else
                          assignedToList.add(empname);
                      }
                      setState(() {});
                    },
                    value: assignedToList.length == index
                        ? _assignedTo
                        : assignedToList.length > index
                            ? assignedToList[index]
                            : _assignedTo,
                    validator: (var value) {
                      // print("index:" + index.toString());
                      print("Assigned To List:" + assignedToList.toString());
                      if (value == null) return 'Please select any Employee';
                      if (index > index + 1) if (assignedToList.contains(value))
                        return 'Employee already selected';
                      return null;
                    }),
              ),
              Expanded(
                  child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: employees.length != empToAddCount &&
                                  assignedToList.length > index &&
                                  empToAddCount < 5
                              ? () {
                                  empToAddCount = empToAddCount + 1;
                                  setState(() {
                                    print(assignedToList.length.toString() +
                                        "," +
                                        index.toString());
                                  });
                                }
                              : null),
                    ),
                    Expanded(
                      child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: empToAddCount != 1
                              ? empToAddCount == index + 1
                                  ? () {
                                      empToAddCount = empToAddCount - 1;
                                      if (assignedToList.length != index)
                                        assignedToList.removeAt(index);
                                      setState(() {});
                                    }
                                  : null
                              : null),
                    ),
                  ],
                ),
              ))
            ],
          ),
          SizedBox(
            height: sizedBoxHeight,
          ),
        ],
      ),
    );
  }

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

  Widget customDropDownButtonFormField(
      List<DropdownMenuItem> empList, sizedBoxHeight) {
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
              items: empList,
              onChanged: (empname) => _assignedTo = empname,
              value: _assignedTo,
              validator: (var value) {
                if (value == null) return 'Please select any Employee';

                return null;
              }),
          SizedBox(
            height: sizedBoxHeight,
          ),
          DropdownButtonFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.person_outline_outlined,
                  //color: Color(0xFF003580),
                ),
              ),
              hint: Text("Team Lead"),
              items: empList,
              onChanged: (empname) => _teamLead = empname,
              value: _teamLead,
              validator: (var value) {
                if (value == null) return 'Please select any Employee';
                return null;
              }),
        ],
      ),
    );
  }
}
