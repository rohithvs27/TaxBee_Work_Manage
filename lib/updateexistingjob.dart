import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_ca_management_app/widgets/customappbar.dart';
import './services/dbcollection.dart';

final firestore = FirebaseFirestore.instance;
TextStyle customLeftStyle = TextStyle(fontSize: 16);
TextStyle customRightStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

class UpdateExistingJob extends StatefulWidget {
  final jobId;
  final _jobDetails;
  final currentUser;
  final admin;

  UpdateExistingJob(this.admin, this.jobId, this._jobDetails, this.currentUser);
  @override
  _UpdateExistingJobState createState() => _UpdateExistingJobState();
}

class _UpdateExistingJobState extends State<UpdateExistingJob>
    with TickerProviderStateMixin {
  List<DropdownMenuItem> adminList = [
    DropdownMenuItem(
      child: Text("Created"),
      value: "Created",
    ),
    DropdownMenuItem(
      child: Text("InProgress"),
      value: "InProgress",
    ),
    DropdownMenuItem(
      child: Text("InReview"),
      value: "InReview",
    ),
    DropdownMenuItem(
      child: Text("Complete"),
      value: "Complete",
    ),
  ];

  List<DropdownMenuItem> nonAdminList = [
    DropdownMenuItem(
      child: Text("Created"),
      value: "Created",
    ),
    DropdownMenuItem(
      child: Text("InProgress"),
      value: "InProgress",
    ),
    DropdownMenuItem(
      child: Text("InReview"),
      value: "InReview",
    ),
  ];

  bool resetValue = false;
  var initDate;
  String _jobType;
  String _assignedTo;
  String _teamLead;
  String _jobStatus;
  List baseEmpList = [];
  List assignedToList = [];
  List teamLeadList = [];
  double sizedBoxHeight = 10;
  int empToAddCount;
  int teamLeadToAddCount;

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _clientName = TextEditingController();
  final TextEditingController _jobSubType = TextEditingController();
  final TextEditingController _jobDescription = TextEditingController();
  final TextEditingController _jobTypeNA = TextEditingController();
  final TextEditingController _assignedToNA = TextEditingController();
  final TextEditingController _teamLeadNA = TextEditingController();
  AnimationController animationController;

  bool updatingJob = false;

  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();

    empToAddCount = widget._jobDetails["employee"]['assignedTo'].length;
    teamLeadToAddCount = widget._jobDetails["employee"]['teamLead'].length;
    _jobType = widget._jobDetails['jobType'];
    _jobTypeNA..text = widget._jobDetails['jobType'];
    for (int i = 0;
        i < widget._jobDetails["employee"]['assignedTo'].length;
        i++) {
      assignedToList.add(widget._jobDetails["employee"]['assignedTo'][i]);
    }
    for (int j = 0;
        j < widget._jobDetails["employee"]['teamLead'].length;
        j++) {
      teamLeadList.add(widget._jobDetails["employee"]['teamLead'][j]);
    }

    _teamLead = widget._jobDetails['teamLead'];
    _assignedToNA..text = widget._jobDetails["employee"]['assignedTo'][0];
    _teamLeadNA..text = widget._jobDetails['teamLead'];
    _jobStatus = widget._jobDetails['currentStatus'];
    _clientName..text = widget._jobDetails['clientName'];
    _jobSubType..text = widget._jobDetails['jobSubType'];
    Timestamp timestamp = widget._jobDetails['dueDate'];
    initDate =
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
    addEmpListToArr();
  }

  addEmpListToArr() async {
    await FirebaseFirestore.instance
        .collection(widget._jobDetails['companyId'])
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

  DateTime _selectedDueDate;

  var docCount = 0;

  _presentDatePicker() {
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
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(context, widget.jobId),
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
                    readOnly: true,
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
                  widget.admin
                      ? getDifferentJobsList("Job Type")
                      : getJobTypeNonAdmin(),
                  TextFormField(
                    readOnly: widget.admin ? false : true,
                    controller: _jobSubType,
                    decoration: InputDecoration(
                      labelText: 'Job Sub Type',
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
                  widget.admin
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: empToAddCount,
                          itemBuilder: (context, index) {
                            return getEmpList("AssignedTo", index);
                          })
                      : getEmpListNonAdmin(width),
                  widget.admin
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: teamLeadToAddCount,
                          itemBuilder: (context, teamLeadIndex) {
                            return getTeamLeadList("TeamLead", teamLeadIndex);
                          })
                      : getTeamLeadListNonAdmin(width),
                  Container(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      //padding: EdgeInsets.only(top: 10),
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Center(
                            child: Column(
                          children: <Widget>[
                            DropdownButtonFormField(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                },
                                //controller: _directionFacingcontroller,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.star_border_outlined),
                                  labelText: 'Job Status',
                                ),
                                items: widget.admin ? adminList : nonAdminList,
                                onChanged: (jobStatus) {
                                  _jobStatus = jobStatus;
                                },
                                value: _jobStatus,
                                validator: (var value) {
                                  if (value == null)
                                    return 'Please Select Job Type';

                                  return null;
                                })
                          ],
                        ))
                      ],
                    ),
                  ),
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
                            onPressed: widget.admin
                                ? () {
                                    HapticFeedback.lightImpact();
                                    _presentDatePicker();
                                  }
                                : null,
                            child: Text(
                              _selectedDueDate == null
                                  ? DateFormat.yMMMd().format(initDate)
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
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    controller: _jobDescription,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Comments",
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
                  !updatingJob
                      ? MaterialButton(
                          child: Text(
                            "Update Job",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 20),
                          ),
                          height: 50,
                          minWidth: double.infinity,
                          color: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                updatingJob = true;
                              });
                              if ((_jobType != widget._jobDetails['jobType']) |
                                  (!ListEquality().equals(
                                      assignedToList,
                                      widget._jobDetails['employee']
                                              ["assignedTo"]
                                          .toList())) |
                                  (!ListEquality().equals(
                                      teamLeadList,
                                      widget._jobDetails['employee']["teamLead"]
                                          .toList())) |
                                  (_jobStatus !=
                                      widget._jobDetails['currentStatus']) |
                                  (_clientName.text !=
                                      widget._jobDetails['clientName']) |
                                  (_jobSubType.text !=
                                      widget._jobDetails['jobSubType']) |
                                  (_selectedDueDate != null) |
                                  (_jobDescription.text.isNotEmpty)) {
                                Future.delayed(Duration(seconds: 2))
                                    .then((value) {
                                  DocumentReference documentReference =
                                      dbCollection
                                          .collection(
                                              widget._jobDetails['companyId'])
                                          .doc("JobDocument")
                                          .collection("JobCollection")
                                          .doc(widget.jobId);

                                  var dataJobDescriptionNotEmpty = {
                                    "clientName": _clientName.text.trim(),
                                    "jobType": _jobType,
                                    "jobSubType": _jobSubType.text.trim(),
                                    "currentStatus": _jobStatus,
                                    "jobUpdatedBy": widget.currentUser,
                                    "dueDate": _selectedDueDate == null
                                        ? initDate
                                        : _selectedDueDate,
                                    "jobDescription": FieldValue.arrayUnion([
                                      "${widget.currentUser}: ${_jobDescription.text}"
                                    ]),
                                    "employee": {
                                      "assignedTo":
                                          FieldValue.arrayUnion(assignedToList),
                                      "teamLead":
                                          FieldValue.arrayUnion(teamLeadList)
                                    },
                                  };

                                  /*var dataJobDescriptionEmpty = {
                              "clientName": _clientName.text.trim(),
                              "jobType": _jobType,
                              "jobSubType": _jobSubType.text.trim(),
                              "currentStatus": _jobStatus,
                              "jobUpdatedBy": widget.currentUser,
                              "dueDate": _selectedDueDate == null
                                  ? initDate
                                  : _selectedDueDate,
                              "employee": {
                                "assignedTo":
                                    FieldValue.arrayUnion(assignedToList),
                                "teamLead": FieldValue.arrayUnion(teamLeadList)
                              },
                            };*/

                                  documentReference
                                      .update(dataJobDescriptionNotEmpty)
                                      .then((value) {
                                    setState(() {
                                      updatingJob = false;
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            backgroundColor: Colors.blue[800],
                                            content: Text(
                                              "Job ${widget.jobId} updated successfully",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )));
                                    resetAllValues();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  });
                                });
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        backgroundColor: Colors.blue[800],
                                        content: Text(
                                          "Please make changes to update",
                                          style: TextStyle(color: Colors.white),
                                        )));
                              }
                            }
                          })
                      : CircularProgressIndicator.adaptive(
                          valueColor: animationController.drive(ColorTween(
                              begin: Colors.blue[800],
                              end: Colors.green[300]))),
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
        .collection(widget._jobDetails['companyId'])
        .doc("JobDocument")
        .collection("JobCollection")
        .where("createdDate", isEqualTo: currentDate);
    var count = await collectionReference.get().then((val) => val.size);
    return count;
  }

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
              print(employees2);
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
    print("assinged to length:" + assignedToList.length.toString());
    print("Index length:" + index.toString());
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
                      if (assignedToList.length == index) {
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
                    value: assignedToList.length.toInt() > index.toInt()
                        ? assignedToList[index].toString()
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
                          onPressed:
                              assignedToList.length > index && empToAddCount < 5
                                  ? () {
                                      HapticFeedback.lightImpact();
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
                                      HapticFeedback.lightImpact();
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
              print(teamLead2);
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
      //print("Printing " + employees.toString());
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
                      if (teamLeadList.length == index) {
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
                        ? _teamLead
                        : teamLeadList.length > index
                            ? teamLeadList[index]
                            : _teamLead,
                    validator: (var value) {
                      // print("index:" + index.toString());
                      print("Team Lead List:" + teamLeadList.toString());
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
                              ? () {
                                  HapticFeedback.lightImpact();
                                  teamLeadToAddCount = teamLeadToAddCount + 1;
                                  setState(() {
                                    print(teamLeadList.length.toString() +
                                        "," +
                                        index.toString());
                                  });
                                }
                              : null),
                    ),
                    Expanded(
                      child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: teamLeadToAddCount != 1
                              ? teamLeadToAddCount == index + 1
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      teamLeadToAddCount =
                                          teamLeadToAddCount - 1;
                                      if (teamLeadList.length != index)
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
          SizedBox(
            height: sizedBoxHeight,
          ),
        ],
      ),
    );
  }

  getJobTypeNonAdmin() {
    return TextFormField(
      readOnly: true,
      controller: _jobTypeNA,
      decoration: InputDecoration(
        labelText: 'Job Type',
        prefixIcon: Icon(
          Icons.work_outline_outlined,
          //color: Color(0xFF003580),
        ),
      ),
      validator: (String value) {
        if (value.isEmpty) return 'Please enter some text';
        return null;
      },
    );
  }

  getEmpListNonAdmin(double width) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                "Assigned To",
                style: customLeftStyle,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 30,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount:
                        widget._jobDetails['employee']["assignedTo"].length,
                    itemBuilder: (context, assignedToEmpCount) {
                      print(
                          "assignedToEmpCount" + assignedToEmpCount.toString());
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          width: width / 4,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),

                          //color: Colors.green[200],
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                              child: Text(
                                widget._jobDetails['employee']["assignedTo"]
                                        [assignedToEmpCount]
                                    .toString(),
                                textAlign: TextAlign.start,
                                style: TextStyle(color: Colors.red),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  getTeamLeadListNonAdmin(double width) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                "Team Lead",
                style: customLeftStyle,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 30,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount:
                        widget._jobDetails['employee']["teamLead"].length,
                    itemBuilder: (context, teamLeadCount) {
                      print("assignedToEmpCount" + teamLeadCount.toString());
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          width: width / 4,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                              child: Text(
                                widget._jobDetails['employee']["teamLead"]
                                        [teamLeadCount]
                                    .toString(),
                                textAlign: TextAlign.start,
                                style: TextStyle(color: Colors.indigo),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot> getDifferentJobsList(String jobType) {
    return StreamBuilder(
        stream: firestore
            .collection(widget._jobDetails['companyId'])
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
                labelText: "Job Type",
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
}
