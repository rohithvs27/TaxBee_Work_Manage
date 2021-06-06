import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_ca_management_app/widgets/loadingscreen.dart';
import 'createnewemp.dart';
import 'services/deleteemp.dart';
import 'widgets/customappbar.dart';

class ManageUsers extends StatefulWidget {
  final String companyId;

  ManageUsers(this.companyId);
  @override
  _ManageUsersState createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List userSnapShots = [];
  bool isReversed = false;
  bool deletingUserInProgress = false;

  bool sort = false;
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
    getEmpDetails();
  }

  getEmpDetails() {
    userSnapShots.clear();
    var collectionRef = FirebaseFirestore.instance
        .collection(widget.companyId)
        .doc("UserDocument")
        .collection("UserCollection")
        .where("name", isNotEqualTo: "Admin User");

    var inputDataSnapshot =
        collectionRef.orderBy("name", descending: false).get();

    inputDataSnapshot.then((snapshots) {
      for (int i = 0; i < snapshots.docs.length; i++) {
        var snap = snapshots.docs[i].data();
        userSnapShots.add(snap);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> color) {
      return Colors.white;
    }

    const TextStyle tableHeaderStyle = TextStyle(
        fontSize: 17,
        fontFamily: "GoogleFonts",
        fontWeight: FontWeight.w500,
        color: Colors.black);

    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => CreateNewEmp(widget.companyId)))
                .then((value) => getEmpDetails());
          },
          tooltip: "Add Employee",
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[800],
          child: Icon(
            Icons.person_add_outlined,
            color: Colors.white,
          )),
      appBar: customAppBar(context, "Manage Users"),
      body: SingleChildScrollView(
          child: userSnapShots.isNotEmpty
              ? Container(
                  width: double.maxFinite,
                  child: DataTable(
                      columnSpacing: 80,
                      headingTextStyle: TextStyle(fontSize: 18),
                      dividerThickness: 1,
                      headingRowHeight: 55,
                      dataRowHeight: 55,
                      // headingRowColor:
                      //     MaterialStateProperty.resolveWith(getColor),
                      sortAscending: sort,
                      sortColumnIndex: 0,
                      columns: [
                        DataColumn(
                            numeric: false,
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortColumn(columnIndex, ascending);
                            },
                            label: Expanded(
                              child: Text(
                                "Name",
                                style: tableHeaderStyle,
                              ),
                            )),
                        DataColumn(
                            label: Expanded(
                          child: Text(
                            "Admin",
                            style: tableHeaderStyle,
                          ),
                        )),
                        DataColumn(
                            label: Expanded(
                          child: Text(
                            "Delete",
                            style: tableHeaderStyle,
                            //style: Theme.of(context).textTheme.headline6,
                          ),
                        ))
                      ],
                      // rows: userList.map((user) => user).toList(),
                      rows: isReversed
                          ? userSnapShots
                              .map((snap) => DataRow(cells: [
                                    DataCell(Container(
                                      child: Text(snap['name'],
                                          style: TextStyle(fontSize: 16)),
                                    )),
                                    DataCell(
                                      Switch(
                                        value: snap['isAdmin'],
                                        onChanged: (value) {
                                          setState(() {
                                            //snap['isAdmin'] = value;
                                          });
                                        },
                                        inactiveThumbColor: Colors.grey,
                                        activeColor: Colors.blue[800],
                                      ),
                                    ),
                                    snap['isAdmin']
                                        ? DataCell(IconButton(
                                            icon: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.grey,
                                              size: 30,
                                            ),
                                            onPressed: () {}))
                                        : DataCell(IconButton(
                                            icon: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.red,
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      deletingUserInProgress
                                                          ? AlertDialog(
                                                              content:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : AlertDialog(
                                                              title: Text(
                                                                  "Delete User"),
                                                              titleTextStyle: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: Text(
                                                                    "Are you sure to delete this user?"),
                                                              ),
                                                              actions: <Widget>[
                                                                  MaterialButton(
                                                                    elevation:
                                                                        8,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                    ),
                                                                    color: Colors
                                                                        .green,
                                                                    child: Text(
                                                                        "No",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.normal)),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                  MaterialButton(
                                                                      elevation:
                                                                          8,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      color: Colors
                                                                          .red,
                                                                      child: Text(
                                                                          "Yes",
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              fontWeight: FontWeight
                                                                                  .normal)),
                                                                      onPressed:
                                                                          () async {
                                                                        setState(
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          deletingUserInProgress =
                                                                              true;
                                                                        });
                                                                        await deleteUserFn(widget.companyId,
                                                                                snap['name'])
                                                                            .then((status) {
                                                                          print(
                                                                              status);
                                                                          if (status !=
                                                                              null) {
                                                                            if (status ==
                                                                                "true") {
                                                                              callSnackBar(context, "User Deleted Successfully");
                                                                              setState(() {
                                                                                deletingUserInProgress = false;
                                                                                int delIndexVal = userSnapShots.indexOf(snap);
                                                                                userSnapShots.removeAt(delIndexVal);
                                                                              });
                                                                            } else if (status ==
                                                                                "job_open") {
                                                                              callSnackBar(context, "Jobs assigned to user. Reassign and try again");
                                                                            } else {
                                                                              callSnackBar(context, status);
                                                                            }
                                                                            Navigator.of(context).pop();
                                                                          }
                                                                        });
                                                                      })
                                                                ]));
                                            },
                                          ))
                                  ]))
                              .toList()
                          : userSnapShots.reversed
                              .map((snap) => DataRow(cells: [
                                    DataCell(Container(
                                      child: Text(snap['name'],
                                          style: TextStyle(fontSize: 16)),
                                    )),
                                    DataCell(
                                      Switch(
                                        value: snap['isAdmin'],
                                        onChanged: (value) {
                                          setState(() {
                                            //snap['isAdmin'] = value;
                                          });
                                        },
                                        inactiveThumbColor: Colors.grey,
                                        activeColor: Colors.blue[800],
                                      ),
                                    ),
                                    snap['isAdmin']
                                        ? DataCell(IconButton(
                                            icon: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.grey,
                                              size: 30,
                                            ),
                                            onPressed: () {}))
                                        : DataCell(IconButton(
                                            icon: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.red,
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                          title: Text(
                                                              "Delete User"),
                                                          titleTextStyle:
                                                              TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                          content:
                                                              SingleChildScrollView(
                                                            child: Text(
                                                                "Are you sure to delete this User?"),
                                                          ),
                                                          actions: <Widget>[
                                                            MaterialButton(
                                                              elevation: 8,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              color:
                                                                  Colors.green,
                                                              child: Text("No",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal)),
                                                              onPressed: () {
                                                                HapticFeedback
                                                                    .lightImpact();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            MaterialButton(
                                                                elevation: 8,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                child: Text(
                                                                    "Yes",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.normal)),
                                                                onPressed: () {
                                                                  HapticFeedback
                                                                      .lightImpact();
                                                                  loadingScreen(
                                                                      context);
                                                                  Future.delayed(Duration(
                                                                          seconds:
                                                                              1))
                                                                      .then(
                                                                          (value) async {
                                                                    await deleteUserFn(
                                                                            widget
                                                                                .companyId,
                                                                            snap[
                                                                                'name'])
                                                                        .then(
                                                                            (status) {
                                                                      if (status !=
                                                                          null) {
                                                                        if (status ==
                                                                            "true") {
                                                                          callSnackBar(
                                                                              context,
                                                                              "User Deleted Successfully");
                                                                          setState(
                                                                              () {
                                                                            int delIndexVal =
                                                                                userSnapShots.indexOf(snap);
                                                                            userSnapShots.removeAt(delIndexVal);
                                                                          });
                                                                        } else if (status ==
                                                                            "job_open") {
                                                                          callSnackBar(
                                                                              context,
                                                                              "Jobs assigned to user. Reassign and try again");
                                                                        } else {
                                                                          callSnackBar(
                                                                              context,
                                                                              status);
                                                                        }
                                                                      }
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    });
                                                                  });
                                                                })
                                                          ]));
                                            },
                                          ))
                                  ]))
                              .toList()),
                )
              : Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                        valueColor: animationController.drive(ColorTween(
                            begin: Colors.blue[800], end: Colors.green[300]))),
                  ),
                )),
    ));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  onSortColumn(int columnIndex, bool ascending) {
    if (ascending) {
      setState(() {
        isReversed = true;
      });
    } else {
      setState(() {
        isReversed = false;
      });
    }
  }

  callSnackBar(context, content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue[800],
        content: Text(
          content.toString(),
          style: TextStyle(color: Colors.white),
        )));
  }
}
