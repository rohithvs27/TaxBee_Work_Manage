import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_ca_management_app/checkconnectivity.dart';
import 'package:new_ca_management_app/createnewclient.dart';

import "./services/dbcollection.dart";
import 'package:new_ca_management_app/ticketdetailspage.dart';
import 'package:provider/provider.dart';
import 'widgets/customdrawer.dart';

String filterStatus;
String whereCondition;
String arrayFilter;
String filterCondition;
String sortType = "dueDate";
bool sortDescending = false;
bool sort = false;
bool upCominginThreeDays = false;

const TextStyle dropdownTextStyle = TextStyle(
  color: Colors.black,
  fontFamily: "GoogleFonts",
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

class TicketListPage extends StatefulWidget {
  final bool admin;
  final String uid;
  final String clientId;
  final String empname;
  final String email;

  TicketListPage(
    this.admin,
    this.uid,
    this.clientId,
    this.empname,
    this.email,
  );

  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage>
    with AutomaticKeepAliveClientMixin {
  List<String> userSnapShots = [];
  ScrollController _controller = new ScrollController();
  DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  @override
  void initState() {
    //fbm.subscribeToTopic("newJobCreated");
    super.initState();

    Provider.of<CheckInternetConnectivityProvider>(context, listen: false)
        .startMonitoring();
  }

  Future<List<String>> getEmpDetailsArr() async {
    userSnapShots.clear();
    await FirebaseFirestore.instance
        .collection(widget.clientId)
        .doc("UserDocument")
        .collection("UserCollection")
        .where("name", isNotEqualTo: "Admin User")
        .orderBy("name", descending: false)
        .get()
        .then((snapshots) {
      for (int i = 0; i < snapshots.docs.length; i++) {
        userSnapShots.add(snapshots.docs[i].data()["name"]);
      }
    });

    return userSnapShots;
  }

  var docCount = 0;

  bool viewLeadJob = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final Orientation orientation = MediaQuery.of(context).orientation;
    double aspectRatio = orientation == Orientation.portrait ? 1.2 : 1.5;
    int gridSize = orientation == Orientation.portrait ? 2 : 3;

    List popupitems = ["Job Status", "Employee", "Sort"];
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: <Widget>[
          Container(
            child: PopupMenuButton<String>(onSelected: (value) {
              if (value == "Job Status") {
                jobStatusBottomModalSheet(context);
              }
              if (value == "Employee") {
                employeeBottomModalSheet(context);
              }
              if (value == "Sort") {
                dueDateBottomModalSheet(context);
              }
            }, itemBuilder: (BuildContext context) {
              return popupitems.map((menuItems) {
                return PopupMenuItem<String>(
                  child: ListTile(
                    minLeadingWidth: 1,
                    leading: Icon(Icons.sort),
                    title: Text(menuItems),
                  ),
                  value: menuItems,
                );
              }).toList();
            }),
          )
        ],
      ),
      drawer: Drawer(
          elevation: 20,
          child: customDrawer(widget.admin, widget.clientId, context)),
      body: Container(
          // For Admin Users
          margin: EdgeInsets.all(2),
          child: (whereCondition == null && !sort)
              ? Container(
                  child: Center(
                    child: Text("Please select atleast one filter",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                )
              : StreamBuilder(
                  stream: !sort
                      ? getJobIdStreamSnapshotsFiltering(
                          context, widget.clientId)
                      : getJobIdStreamSnapshotsSorting(
                          context, widget.clientId),
                  builder: (context, snapshot) {
                    getDocumentCount(widget.clientId).then((val) {
                      docCount = val;
                    });
                    if (snapshot.data == null) {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()],
                      ));
                    }
                    if (snapshot.data.documents.length == 0) {
                      return Container(
                        child: Center(
                          child: docCount == 0
                              ? Text(
                                  "Please Create New Jobs",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : Text(
                                  "Please change filter type to view data",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      );
                    }

                    return GridView.builder(
                        padding: EdgeInsets.all(3),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: aspectRatio,
                            crossAxisCount: gridSize,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1),
                        physics: new BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        controller: _controller,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          Map emp =
                              snapshot.data.documents[index].data()['employee'];

                          List assignedTo = emp['assignedTo'];
                          List teamLead = emp['teamLead'];

                          var timestamp = snapshot.data.documents[index]
                              .data()['dueDate']
                              .toDate();

                          var todaydate = DateTime.now();
                          final diff = timestamp.difference(todaydate).inDays;

                          final formattedDate =
                              dateFormat.format(timestamp).toString();

                          return Hero(
                            tag: snapshot.data.documents[index].id.toString(),
                            child: Card(
                              borderOnForeground: false,
                              elevation: 5,
                              color: diff < 0 ? Colors.red[200] : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              TicketDetailsPage(
                                                  widget.admin,
                                                  widget.clientId,
                                                  snapshot
                                                      .data.documents[index].id,
                                                  snapshot.data.documents[index]
                                                      .data(),
                                                  widget.empname)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  snapshot.data.documents[index]
                                                          .data()['priority']
                                                      ? Expanded(
                                                          flex: 1,
                                                          child: Icon(
                                                            Icons
                                                                .priority_high_sharp,
                                                            size: 16,
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 0,
                                                          width: 0,
                                                        ),
                                                  Expanded(
                                                    flex: 8,
                                                    child: Text(
                                                      snapshot
                                                          .data.documents[index]
                                                          .data()['clientName'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            formattedDate,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                color: diff < 2
                                                    ? Colors.red
                                                    : diff < 4
                                                        ? Colors.amber
                                                        : Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Text(
                                              snapshot.data.documents[index]
                                                  .data()['currentStatus'],
                                              textAlign: TextAlign.end,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.amber[800],
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: assignedTo.length,
                                              itemBuilder: (context, count) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    width: width / 4,
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                2, 0, 2, 0),
                                                        child: Text(
                                                          assignedTo[count]
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black),
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: teamLead.length,
                                              itemBuilder: (context, count) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Container(
                                                    width: width / 4,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    //height: 10,
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                2, 0, 2, 0),
                                                        child: Text(
                                                          teamLead[count]
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black),
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                          );
                        });
                  })),
    );
  }

  @override
  bool get wantKeepAlive => true;

  jobStatusBottomModalSheet(context) {
    var customModalSheetFilterIcons = Icon(Icons.sort);

    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Container(
              margin: EdgeInsets.all(10),
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: customModalSheetFilterIcons,
                    title: Text("All"),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        filterStatus = null;
                        whereCondition = "currentStatus";
                        sort = false;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    leading: customModalSheetFilterIcons,
                    title: Text("High Priority"),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        whereCondition = "priority";
                        sort = false;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    leading: customModalSheetFilterIcons,
                    title: Text("Created"),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        filterStatus = "Created";
                        whereCondition = "currentStatus";
                        sort = false;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    leading: customModalSheetFilterIcons,
                    title: Text("In Progress"),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        filterStatus = "InProgress";
                        whereCondition = "currentStatus";
                        sort = false;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    leading: customModalSheetFilterIcons,
                    title: Text("In Review"),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        filterStatus = "InReview";
                        whereCondition = "currentStatus";
                        sort = false;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    leading: customModalSheetFilterIcons,
                    title: Text("Complete"),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        filterStatus = "Complete";
                        whereCondition = "currentStatus";
                        sort = false;
                        Navigator.pop(context);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  dueDateBottomModalSheet(context) {
    var customModalSheetSortIcons = Icon(Icons.arrow_circle_down_rounded);

    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: Container(
                  margin: EdgeInsets.all(10),
                  child: ListView(shrinkWrap: true, children: [
                    ListTile(
                      leading: customModalSheetSortIcons,
                      title: Text("Due Date"),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          sortType = 'dueDate';
                          sort = true;
                          upCominginThreeDays = false;
                          //Navigator.pop(context);
                        });
                      },
                    ),
                    ListTile(
                      leading: customModalSheetSortIcons,
                      title: Text("Due in next 3 days"),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          sortType = "dueDate";
                          sort = true;
                          upCominginThreeDays = true;
                          //Navigator.pop(context);
                        });
                      },
                    ),
                    ListTile(
                      leading: customModalSheetSortIcons,
                      title: Text("Client Name"),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          sortType = "clientName";
                          sort = true;
                          upCominginThreeDays = false;
                          //Navigator.pop(context);
                        });
                      },
                    ),
                  ])));
        });
  }

  employeeBottomModalSheet(context) {
    final double height = MediaQuery.of(context).size.height;
    var customModalSheetSortIcons = Icon(Icons.arrow_circle_down_rounded);
    //QuerySnapshot empSnap;

    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: height / 3,
            child: FutureBuilder(
                future: dbCollection
                    .collection(widget.clientId)
                    .doc("UserDocument")
                    .collection("UserCollection")
                    .where("name", isNotEqualTo: "Admin User")
                    .orderBy("name", descending: false)
                    .get()
                    .then((empSnap) => empSnap),
                builder: (context, AsyncSnapshot<QuerySnapshot> empSnap) {
                  if (empSnap.hasData) {
                    return ListView.builder(
                        itemCount: empSnap.data.docs.length,
                        itemBuilder: (context, index) {
                          final String empname =
                              empSnap.data.docs[index].data()["name"];
                          return Container(
                            child: ListTile(
                                leading: customModalSheetSortIcons,
                                title: Text(empname),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    whereCondition = "employee.assignedTo";
                                    arrayFilter = empname;
                                    sort = false;
                                    upCominginThreeDays = false;
                                    Navigator.pop(context);
                                  });
                                }),
                          );
                        });
                  } else {
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                }),
          );
        });
  }

  Stream<QuerySnapshot> getEmployeeDataStrem(
    BuildContext context,
  ) async* {
    yield* dbCollection
        .collection(clientId)
        .doc("UserDocument")
        .collection("UserCollection")
        .snapshots();
  }

  Stream<QuerySnapshot> getJobIdStreamSnapshotsFiltering(
      BuildContext context, String clientId) async* {
    if (whereCondition == "employee.assignedTo") {
      yield* dbCollection
          .collection(clientId)
          .doc("JobDocument")
          .collection("JobCollection")
          .where(whereCondition, arrayContains: arrayFilter)
          .limit(1000)
          .snapshots();
    } else {
      yield* dbCollection
          .collection(clientId)
          .doc("JobDocument")
          .collection("JobCollection")
          .where(whereCondition,
              isEqualTo: whereCondition == "priority" ? true : filterStatus)
          .where(whereCondition,
              isNotEqualTo: filterStatus == 'Complete' ? null : 'Complete')
          .limit(1000)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getJobIdStreamSnapshotsSorting(
      BuildContext context, String clientId) async* {
    if (!upCominginThreeDays) {
      yield* dbCollection
          .collection(clientId)
          .doc("JobDocument")
          .collection("JobCollection")
          .where("currentStatus",
              whereIn: ["Created", "InProgress", "InReview"])
          .orderBy(sortType, descending: sortDescending)
          .snapshots();
    } else {
      yield* dbCollection
          .collection(clientId)
          .doc("JobDocument")
          .collection("JobCollection")
          .where("currentStatus",
              whereIn: ["Created", "InProgress", "InReview"])
          .where(sortType, isLessThan: DateTime.now().add(Duration(days: 3)))
          .where(sortType, isGreaterThanOrEqualTo: DateTime.now())
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getJobIdStreamSnapshotsFilteringNonAdminTL(
      BuildContext context, String clientId, String empname) async* {
    yield* dbCollection
        .collection(clientId)
        .doc("JobDocument")
        .collection("JobCollection")
        .where("employee.teamLead", arrayContains: empname)
        .where(whereCondition,
            isEqualTo: whereCondition == "priority" ? true : filterStatus)
        .snapshots();
  }

  Stream<QuerySnapshot> getJobIdStreamSnapshotsFilteringNonAdmin(
      BuildContext context, String clientId, String empname) async* {
    yield* dbCollection
        .collection(clientId)
        .doc("JobDocument")
        .collection("JobCollection")
        .where("employee.assignedTo", arrayContains: empname)
        .where(whereCondition,
            isEqualTo: whereCondition == "priority" ? true : filterStatus)
        .snapshots();
  }

//To get the total number of Jobs from the Job Collection..
  Future<int> getDocumentCount(String clientId) async {
    CollectionReference collectionReference = dbCollection
        .collection(clientId)
        .doc("JobDocument")
        .collection("JobCollection");
    return await collectionReference.get().then((value) => value.size.toInt());
  }
}
