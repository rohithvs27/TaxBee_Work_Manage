import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:new_ca_management_app/checkconnectivity.dart';
import 'package:new_ca_management_app/manageclients.dart';
import 'package:new_ca_management_app/manageusers.dart';
import 'package:new_ca_management_app/services/createnewjobtype.dart';

import 'package:new_ca_management_app/ticketdetailspage.dart';
import 'package:provider/provider.dart';
import 'signout.dart';

String filterStatus;
String whereCondition;
String sortType = "dueDate";
bool sortDescending = false;
bool sort = false;

FirebaseFirestore dbCollection = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class TicketListPage extends StatefulWidget {
  final bool admin;
  final String uid;
  final String clientId;
  final String empname;
  final String email;

  TicketListPage(this.admin, this.uid, this.clientId, this.empname, this.email);

  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller = new ScrollController();
  @override
  void initState() {
    final fbm = FirebaseMessaging();
    fbm.configure(onMessage: (msg) async {
      return;
    }, onLaunch: (msg) {
      return;
    }, onResume: (msg) {
      return;
    });
    //fbm.subscribeToTopic("newJobCreated");
    super.initState();

    Provider.of<CheckInternetConnectivityProvider>(context, listen: false)
        .startMonitoring();
  }

  var docCount = 0;
  DateFormat dateFormat = DateFormat('dd-MMM-yy');
  bool viewLeadJob = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: widget.admin ? null : 70,
        title: Text("Jobs"),
        centerTitle: true,
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(right: 1),
              child: !widget.admin
                  ? Container(
                      child: Column(
                        children: [
                          Switch(
                            value: viewLeadJob,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.redAccent[100],
                            activeColor: Colors.green,
                            onChanged: (value) {
                              print(viewLeadJob.toString());
                              viewLeadJob = !viewLeadJob;
                              setState(() {});
                            },
                          ),
                          viewLeadJob
                              ? Text(
                                  "Lead View",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  "Work View",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ],
                      ),
                    )
                  : Container(
                      child: Image.asset("assets/images/taxbee_logo.png",
                          width: 100,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.centerRight),
                    ),
            );
          })
        ],
      ),
      drawer: Drawer(
        elevation: 20,
        child: _customDrawer(widget.admin),
      ),
      //floatingActionButton: speedDialFloatingActionButton(context),
      floatingActionButton: FloatingActionButton(
        tooltip: "Filter",
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        focusColor: Colors.blue,
        child: Icon(Icons.sort),
        onPressed: () => filterBottomModalSheet(context),
      ),
      body: Container(
          // For Admin Users
          margin: EdgeInsets.all(10),
          child: whereCondition == null
              ? Container(
                  child: Center(
                    child: Text(
                      "Please select atleast one filter",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : widget.admin
                  ? StreamBuilder(
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "Please change filter type to view data",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }

                        return GridView.builder(
                            padding: EdgeInsets.all(3),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1,
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 3,
                                    crossAxisSpacing: 3),
                            physics: new BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            controller: _controller,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              Map emp = snapshot.data.documents[index]
                                  .data()['employee'];

                              List assignedTo = emp['assignedTo'];
                              List teamLead = emp['teamLead'];

                              var timestamp = snapshot.data.documents[index]
                                  .data()['dueDate']
                                  .toDate();
                              var todaydate = DateTime.now();

                              final diff =
                                  timestamp.difference(todaydate).inDays;

                              final formattedDate =
                                  dateFormat.format(timestamp).toString();

                              return Hero(
                                tag: snapshot.data.documents[index].id
                                    .toString(),
                                child: Card(
                                  elevation: 5,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  TicketDetailsPage(
                                                      widget.admin,
                                                      widget.clientId,
                                                      snapshot.data
                                                          .documents[index].id,
                                                      snapshot
                                                          .data.documents[index]
                                                          .data(),
                                                      widget.empname)));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(children: [
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  // height: 30,
                                                  child: Row(
                                                    children: [
                                                      snapshot.data
                                                              .documents[index]
                                                              .data()['priority']
                                                          ? Expanded(
                                                              flex: 1,
                                                              child: Icon(
                                                                Icons
                                                                    .priority_high_sharp,
                                                                size: 16,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 0,
                                                              width: 0,
                                                            ),
                                                      Expanded(
                                                        flex: 20,
                                                        child: Text(
                                                          snapshot.data
                                                                  .documents[index]
                                                                  .data()[
                                                              'clientName'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: diff < 2
                                                          ? Colors.red
                                                          : diff < 4
                                                              ? Colors.amber
                                                              : Colors.green,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(1),
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount: assignedTo.length,
                                                  itemBuilder:
                                                      (context, count) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 1.0),
                                                      child: Card(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0)),
                                                        child: Container(
                                                          width: width / 6,
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                            .grey[
                                                                        400],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0)),
                                                          child: Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      5,
                                                                      0,
                                                                      5,
                                                                      0),
                                                              child: Text(
                                                                assignedTo[
                                                                        count]
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .blue),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount: teamLead.length,
                                                  itemBuilder:
                                                      (context, count) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 1.0),
                                                      child: Card(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0)),
                                                        child: Container(
                                                          width: width / 6,
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                            .grey[
                                                                        400],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0)),
                                                          child: Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      5,
                                                                      0,
                                                                      5,
                                                                      0),
                                                              child: Text(
                                                                teamLead[count]
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              );
                            });
                      })

                  //For Non Admin Users
                  : StreamBuilder(
                      stream: !viewLeadJob
                          ? getJobIdStreamSnapshotsFilteringNonAdmin(
                              context, widget.clientId, widget.empname)
                          : getJobIdStreamSnapshotsFilteringNonAdminTL(
                              context, widget.clientId, widget.empname),
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "Please change filter type to view data",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }
                        return GridView.builder(
                            padding: EdgeInsets.all(3),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1,
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5),
                            physics: new BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            controller: _controller,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              Map emp = snapshot.data.documents[index]
                                  .data()['employee'];

                              List assignedTo = emp['assignedTo'];
                              List teamLead = emp['teamLead'];

                              var timestamp = snapshot.data.documents[index]
                                  .data()['dueDate']
                                  .toDate();
                              print("timestamp" + timestamp.toString());
                              // var todaydate = DateTime.now();
                              /* final diff =
                                  timestamp.difference(todaydate).inDays;*/

                              /*final formattedDate =
                                  dateFormat.format(timestamp).toString();*/

                              return Hero(
                                tag: snapshot.data.documents[index].id
                                    .toString(),
                                child: Card(
                                  elevation: 5,
                                  color: Colors.grey[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  TicketDetailsPage(
                                                      widget.admin,
                                                      widget.clientId,
                                                      snapshot.data
                                                          .documents[index].id,
                                                      snapshot
                                                          .data.documents[index]
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
                                                  // height: 30,
                                                  child: Row(
                                                    children: [
                                                      snapshot.data
                                                              .documents[index]
                                                              .data()['priority']
                                                          ? Expanded(
                                                              flex: 1,
                                                              child: Icon(
                                                                Icons
                                                                    .priority_high_sharp,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 0,
                                                              width: 0,
                                                            ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          snapshot.data
                                                                  .documents[index]
                                                                  .data()[
                                                              'clientName'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  // height: 30,
                                                  child: Text(
                                                    snapshot.data
                                                            .documents[index]
                                                            .data()[
                                                        'currentStatus'],
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              /*Text(
                                      formattedDate,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: diff < 24
                                              ? Colors.red
                                              : diff < 48
                                                  ? Colors.amber
                                                  : Colors.green),
                                    ),*/
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount: assignedTo.length,
                                                  itemBuilder:
                                                      (context, count) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        width: width / 4,
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    5, 0, 5, 0),
                                                            child: Text(
                                                              assignedTo[count]
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
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
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount: teamLead.length,
                                                  itemBuilder:
                                                      (context, count) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Container(
                                                        width: width / 4,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        //height: 10,
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    5, 0, 5, 0),
                                                            child: Text(
                                                              teamLead[count]
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .indigo),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
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

  Widget _customDrawer(bool admin) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 150,
          child: UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            accountName: Text(
              "${widget.clientId.toUpperCase()} - ${widget.empname}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              "${widget.email}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.business_center_outlined),
          title: Text("Create New Job Type",
              style: TextStyle(color: admin ? Colors.black : Colors.grey)),
          onTap: admin
              ? () {
                  HapticFeedback.lightImpact();
                  //Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            content: createNewJobTypeWidget(),
                            actions: [
                              MaterialButton(
                                color: Colors.amber[600],
                                child: Text(
                                  "Create New Job",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  createNewJobTypeFn(widget.clientId)
                                      .then((success) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            backgroundColor: Colors.amber,
                                            content: Text(
                                              "New Job Type created successfully",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )));
                                    Navigator.of(context).pop();
                                  });
                                },
                              )
                            ],
                          ));
                }
              : null,
        ),
        ListTile(
          leading: Icon(
            Icons.person_add,
          ),
          title: Text(
            "Manage Clients",
            style: TextStyle(color: admin ? Colors.black : Colors.grey),
          ),
          onTap: admin
              ? () {
                  HapticFeedback.lightImpact();
                  //Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) =>
                              ManageClients(widget.clientId)));
                }
              : null,
        ),
        ListTile(
          leading: Icon(Icons.edit_outlined),
          title: Text(
            "Manage Users",
            style: TextStyle(color: admin ? Colors.black : Colors.grey),
          ),
          onTap: admin
              ? () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => ManageUsers(widget.clientId)));
                }
              : null,
        ),
        ListTile(
          leading: Icon(Icons.power_settings_new, color: Colors.red),
          title: Text("Sign Out"),
          onTap: () {
            {
              final User user = _auth.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('No one has signed in.'),
                ));
                return;
              } else {
                signOut(context);
              }

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.amber,
                content: Text('Successfully signed out',
                    style: TextStyle(color: Colors.black)),
              ));
            }
          },
        ),
      ],
    );
  }

  Widget speedDialFloatingActionButton(context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Colors.white,
      foregroundColor: Colors.green,
      children: [
        SpeedDialChild(
            child: Icon(Icons.sort),
            label: "Filter",
            labelStyle: TextStyle(color: Colors.black),
            onTap: () => filterBottomModalSheet(context)),
        /*SpeedDialChild(
            child: Icon(Icons.arrow_downward),
            label: "Sort",
            labelStyle: TextStyle(color: Colors.black),
            onTap: () {}),
            */
      ],
    );
  }

  filterBottomModalSheet(context) {
    var customModalSheetFilterIcons = Icon(Icons.sort_outlined);
    return showModalBottomSheet(
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
}

Stream<QuerySnapshot> getJobIdStreamSnapshotsFiltering(
    BuildContext context, String clientId) async* {
  yield* dbCollection
      .collection(clientId)
      .doc("JobDocument")
      .collection("JobCollection")
      .where(whereCondition,
          isEqualTo: whereCondition == "priority" ? true : filterStatus)
      //.where("currentStatus", isEqualTo: filterStatus)
      .snapshots();
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

Stream<QuerySnapshot> getJobIdStreamSnapshotsSorting(
    BuildContext context, String clientId) async* {
  yield* dbCollection
      .collection(clientId)
      .doc("JobDocument")
      .collection("JobCollection")
      .orderBy(sortType, descending: sortDescending)
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

Widget teamLeadView(String herotag, String clientName, String currentStatus,
    double width, String formattedDate, String empName, var diff) {
  return Hero(
    tag: herotag,
    child: Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      borderOnForeground: true,
      elevation: 10,
      child: Container(
        height: 100,
        child: Center(
          child: ListTile(
            isThreeLine: true,
            //selected: index == _selectedIndex,
            title: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      clientName,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      currentStatus,
                      style: TextStyle(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),

            subtitle: Row(
              children: [
                Expanded(
                  child: Container(
                    width: width / 2.5,
                    height: 50,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      elevation: 5,
                      child: Center(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: diff < 24
                                  ? Colors.red
                                  : diff < 48
                                      ? Colors.amber
                                      : Colors.green),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    constraints: BoxConstraints(minWidth: width / 2.5),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      elevation: 5,
                      child: Row(
                        children: [
                          Expanded(child: Icon(Icons.person_outline_outlined)),
                          Expanded(
                            flex: 3,
                            child: Text(
                              empName,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {},
          ),
        ),
      ),
    ),
  );
}
