import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_ca_management_app/widgets/customappbar.dart';
import './services/dbcollection.dart';
import 'widgets/loadingscreen.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class CreateNewJob extends StatefulWidget {
  final String companyId;
  final String name;

  CreateNewJob(this.companyId, this.name);
  @override
  _CreateNewJobState createState() => _CreateNewJobState();
}

class _CreateNewJobState extends State<CreateNewJob> {
  bool creatingJob = false;

  bool resetValue = false;
  String _jobType;
  String _clientName;
  String _assignedTo;
  String _teamLead;
  List<String> assignedToList = [];
  List<String> teamLeadList = [];
  List baseEmpList = [];
  List employees = [];
  List employees1 = [];
  List employees2 = [];
  List employees3 = [];
  List employees4 = [];
  List employees5 = [];
  List teamLead = [];
  List teamLead1 = [];
  List teamLead2 = [];
  List teamLead3 = [];
  List teamLead4 = [];
  List teamLead5 = [];

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
                {baseEmpList.add(snapshots.docs[i].data()["name"])}
            });

    if (baseEmpList.isNotEmpty) {
      setState(() {
        //employees = List.from(baseEmpList);
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //final TextEditingController _clientName = TextEditingController();
  final TextEditingController _jobSubType = TextEditingController();
  final TextEditingController _jobDescription = TextEditingController();

  DateTime _selectedDueDate;
  var docCount = 0;
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

  bool highPriority = false;

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
                  /* TextFormField(
                    controller: _clientName,
                    decoration: InputDecoration(
                      labelText: 'Client Details',
                      prefixIcon: Icon(Icons.business_center_outlined
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
                  ),*/
                  getClientsList("Select Client"),
                  SizedBox(
                    height: sizedBoxHeight,
                  ),
                  getDifferentJobsList("Select Job Type"),
                  TextFormField(
                    controller: _jobSubType,
                    textCapitalization: TextCapitalization.words,
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
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: empToAddCount,
                      itemBuilder: (context, index) {
                        return getEmpList("AssignedTo", index);
                      }),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: teamLeadToAddCount,
                      itemBuilder: (context, teamLeadIndex) {
                        return getTeamLeadList("TeamLead", teamLeadIndex);
                      }),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                            child: Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
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
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                            child: Row(
                              children: [
                                highPriority
                                    ? Text(
                                        "High Priority",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.normal),
                                      )
                                    : Text(
                                        "No Priority",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                Switch(
                                  value: highPriority,
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey,
                                  activeColor: Colors.red[600],
                                  onChanged: (value) {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      highPriority = !highPriority;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
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
                    height: 20,
                  ),
                  MaterialButton(
                      color: Colors.blue[800],
                      child: Text(
                        "Create Job",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 20),
                      ),
                      height: 50,
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () async {
                        HapticFeedback.lightImpact();

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
                            loadingScreen(context);
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
                              "jobId": uniqueJobId,
                              "companyId": widget.companyId,
                              "priority": highPriority,
                              "createdDate": currentYear + jobMonth + jobDate,
                              "clientName": _clientName,
                              "jobType": _jobType,
                              "jobSubType": _jobSubType.text.trim(),
                              "currentStatus": "Created",
                              "dueDate": _selectedDueDate == null
                                  ? DateTime.now()
                                  : _selectedDueDate,
                              // "jobDescription": _jobDescription.text,
                            }).then((value) => documentReference.update({
                                  "jobDescription": FieldValue.arrayUnion([
                                    "${widget.name}: ${_jobDescription.text}"
                                  ]),
                                  "employee": {
                                    "assignedTo":
                                        FieldValue.arrayUnion(assignedToList),
                                    "teamLead":
                                        FieldValue.arrayUnion(teamLeadList)
                                  },
                                }).then((value) {
                                  Navigator.pop(context);
                                  resetAllValues();

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: Colors.blue[800],
                                          content: Text(
                                            "Job $uniqueJobId created successfully",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )));
                                }));
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
    setState(() {
      _formKey.currentState.reset();
      _clientName = null;
      _jobDescription.clear();
      _jobSubType.clear();
      assignedToList.clear();
      teamLeadList.clear();
      _selectedDueDate = null;
      _assignedTo = null;
      _teamLead = null;
      _jobType = null;
      highPriority = false;
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

  buildEmpList(int index) {
    switch (index) {
      case 0:
        employees1 = List.from(baseEmpList);

        return employees1;

      case 1:
        if (employees2.isEmpty) {
          employees1.forEach((element) {
            if (element != assignedToList[index - 1]) {
              employees2.add(element);
            }
          });
        }
        return employees2;
      case 2:
        if (employees3.isEmpty) {
          employees2.forEach((element) {
            if (element != assignedToList[index - 1]) employees3.add(element);
          });
        }
        return employees3;
      case 3:
        if (employees4.isEmpty) {
          employees3.forEach((element) {
            if (element != assignedToList[index - 1]) employees4.add(element);
          });
        }

        return employees4;
      case 4:
        if (employees5.isEmpty) {
          employees4.forEach((element) {
            if (element != assignedToList[index - 1]) employees5.add(element);
          });
        }

        return employees5;
    }
  }

  clearEmpLists(int index) {
    switch (index) {
      case 0:
        employees2.clear();
        return employees2;
      case 1:
        employees3.clear();
        return employees3;
      case 2:
        employees4.clear();
        return employees4;
      case 3:
        employees5.clear();
        return employees5;
    }
  }

  getEmpList(String empType, int index) {
    employees = buildEmpList(index);

    List<DropdownMenuItem> empList = [];
    if (employees.isEmpty) {
      Text("Loading");
    } else {
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
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Assigned To",
                      prefixIcon: Icon(
                        Icons.person_outline_outlined,
                        //color: Color(0xFF003580),
                      ),
                    ),
                    // hint: Text(empType),
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
                        clearEmpLists(index);
                        if (assignedToList.contains(empname)) {
                        } else
                          assignedToList.add(empname);
                      }
                      setState(() {
                        getEmpList(empType, index);
                      });
                    },
                    value: assignedToList.length == index
                        ? _assignedTo
                        : assignedToList.length > index
                            ? assignedToList[index]
                            : _assignedTo,
                    validator: (var value) {
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
                          onPressed:
                              assignedToList.length > index && empToAddCount < 5
                                  ? empToAddCount == index + 1
                                      ? () {
                                          HapticFeedback.selectionClick();
                                          HapticFeedback.lightImpact();
                                          empToAddCount = empToAddCount + 1;

                                          setState(() {});
                                        }
                                      : null
                                  : null),
                    ),
                    Expanded(
                      child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: empToAddCount != 1
                              ? empToAddCount == index + 1
                                  ? () {
                                      HapticFeedback.selectionClick();
                                      HapticFeedback.lightImpact();
                                      empToAddCount = empToAddCount - 1;

                                      if (assignedToList.length.toInt() > index)
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
        ],
      ),
    );
  }

  buildTeamLeadList(int teamLeadIndex) {
    switch (teamLeadIndex) {
      case 0:
        teamLead1 = List.from(baseEmpList);
        return teamLead1;

      case 1:
        if (teamLead2.isEmpty) {
          teamLead1.forEach((element) {
            if (element != teamLeadList[teamLeadIndex - 1]) {
              teamLead2.add(element);
            }
          });
        }
        return teamLead2;
      case 2:
        if (teamLead3.isEmpty) {
          teamLead2.forEach((element) {
            if (element != teamLeadList[teamLeadIndex - 1])
              teamLead3.add(element);
          });
        }
        return teamLead3;
      case 3:
        if (teamLead4.isEmpty) {
          teamLead3.forEach((element) {
            if (element != teamLeadList[teamLeadIndex - 1])
              teamLead4.add(element);
          });
        }

        return teamLead4;
      case 4:
        if (teamLead5.isEmpty) {
          teamLead4.forEach((element) {
            if (element != teamLeadList[teamLeadIndex - 1])
              teamLead5.add(element);
          });
        }

        return teamLead5;
    }
  }

  clearTeamLeadLists(int index) {
    switch (index) {
      case 0:
        teamLead2.clear();
        return teamLead2;
      case 1:
        teamLead3.clear();
        return teamLead3;
      case 2:
        teamLead4.clear();
        return teamLead4;
      case 3:
        teamLead5.clear();
        return teamLead5;
    }
  }

  getTeamLeadList(String empType, int teamLeadIndex) {
    teamLead = buildTeamLeadList(teamLeadIndex);

    List<DropdownMenuItem> teamLeadList = [];
    if (teamLead.isEmpty) {
      Text("Loading");
    } else {
      for (int i = 0; i < teamLead.length; i++) {
        teamLeadList.add(DropdownMenuItem(
          child: Text(teamLead[i]),
          value: teamLead[i],
        ));
      }
    }
    // write a custom widget with two dropdownbutton to reduce the number of calls
    return customDropDownButtonTeamLeadField(
        teamLeadList, empType, teamLeadIndex);
  }

  Widget customDropDownButtonTeamLeadField(
      List<DropdownMenuItem> empList, String empType, int index) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField(
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Team Lead",
                      prefixIcon: Icon(
                        Icons.person_outline_outlined,
                        //color: Color(0xFF003580),
                      ),
                    ),
                    // hint: Text(empType),
                    items: empList,
                    onChanged: (empname) {
                      if (teamLeadList.length == 0) {
                        teamLeadList.add(empname);
                      } else if (teamLeadList.length == index) {
                        if (teamLeadList.contains(empname)) {
                        } else
                          teamLeadList.add(empname);
                      } else {
                        teamLeadList.removeAt(index);
                        clearTeamLeadLists(index);
                        if (teamLeadList.contains(empname)) {
                        } else
                          teamLeadList.add(empname);
                      }
                      setState(() {
                        getTeamLeadList(empType, index);
                      });
                    },
                    value: teamLeadList.length == index
                        ? _assignedTo
                        : teamLeadList.length > index
                            ? teamLeadList[index]
                            : _assignedTo,
                    validator: (var value) {
                      if (value == null) return 'Please select any Employee';
                      if (index > index + 1) if (teamLeadList.contains(value))
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
                          onPressed: teamLeadList.length > index &&
                                  teamLeadToAddCount < 5
                              ? teamLeadToAddCount == index + 1
                                  ? () {
                                      HapticFeedback.selectionClick();
                                      HapticFeedback.lightImpact();
                                      teamLeadToAddCount =
                                          teamLeadToAddCount + 1;
                                      setState(() {});
                                    }
                                  : null
                              : null),
                    ),
                    Expanded(
                      child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: teamLeadToAddCount != 1
                              ? teamLeadToAddCount == index + 1
                                  ? () {
                                      HapticFeedback.selectionClick();
                                      HapticFeedback.lightImpact();
                                      teamLeadToAddCount =
                                          teamLeadToAddCount - 1;
                                      if (teamLeadList.length > index)
                                        teamLeadList.removeAt(index);
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
              onTap: () {
                HapticFeedback.lightImpact();
              },
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

  StreamBuilder<QuerySnapshot> getClientsList(String clientName) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(widget.companyId)
            .doc("ClientsDocument")
            .collection("ClientsCollection")
            .snapshots(),
        builder: (context, snapshot) {
          List<DropdownMenuItem> clientList = [];
          if (!snapshot.hasData) {
            Text("Loading");
          } else {
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              clientList.add(DropdownMenuItem(
                child: Text(snapshot.data.docs[i].data()["name"]),
                value: snapshot.data.docs[i].data()["name"],
              ));
            }
          }
          return DropdownButtonFormField(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.business_outlined,
                  // color: Color(0xFF003580),
                ),
              ),
              hint: Text("$clientName"),
              items: clientList,
              onChanged: (clientName) {
                _clientName = clientName;
              },
              value: _clientName,
              validator: (var value) {
                if (value == null) return 'Please Select Client Name';
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
              onTap: () {
                HapticFeedback.lightImpact();
              },
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
              onTap: () {
                HapticFeedback.lightImpact();
              },
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
