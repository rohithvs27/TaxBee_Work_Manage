import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'updateclientdetails.dart';
import 'createnewclient.dart';
import 'widgets/customappbar.dart';

class ManageClients extends StatefulWidget {
  final String companyId;

  ManageClients(this.companyId);
  @override
  _ManageClientsState createState() => _ManageClientsState();
}

class _ManageClientsState extends State<ManageClients> {
  List userSnapShots = <Map>[];
  bool isReversed = false;

  bool sort = false;
  @override
  void initState() {
    print("init state called");
    super.initState();
    getClientsData();
  }

  getClientsData() {
    userSnapShots.clear();
    var collectionRef = FirebaseFirestore.instance
        .collection(widget.companyId)
        .doc("ClientsDocument")
        .collection("ClientsCollection");

    var inputDataSnapshot =
        collectionRef.orderBy("name", descending: false).get();

    inputDataSnapshot.then((snapshots) {
      for (int i = 0; i < snapshots.docs.length; i++) {
        var snap = snapshots.docs[i].data();
        userSnapShots.add({"docId": snapshots.docs[i].id, "data": snap});
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> color) {
      return Colors.blue[800];
    }

    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) =>
                        CreateNewClient(widget.companyId))).then((value) {
              print("State refreshed");
              getClientsData();
            });
          },
          tooltip: "Add Client",
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person_add_outlined,
            color: Colors.green,
          )),
      appBar: customAppBar(context, "Manage Clients"),
      body: SingleChildScrollView(
          child: userSnapShots.isNotEmpty
              ? Container(
                  width: double.maxFinite,
                  child: DataTable(
                      headingTextStyle: TextStyle(fontSize: 18),
                      dividerThickness: 1,
                      headingRowHeight: 50,
                      dataRowHeight: 55,
                      headingRowColor:
                          MaterialStateProperty.resolveWith(getColor),
                      sortAscending: sort,
                      sortColumnIndex: 0,
                      columns: [
                        DataColumn(
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortColumn(columnIndex, ascending);
                            },
                            label: Expanded(
                              child: Text(
                                "Name",
                              ),
                            )),
                        DataColumn(
                            label: Expanded(
                          child: Text(
                            "Manage",
                          ),
                        )),
                      ],
                      // rows: userList.map((user) => user).toList(),
                      rows: isReversed
                          ? userSnapShots
                              .map((snap) => DataRow(cells: [
                                    DataCell(Container(
                                      child: Text(snap['data']['name'],
                                          style: TextStyle(fontSize: 16)),
                                    )),
                                    DataCell(IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        UpdateClientDetails(
                                                            widget.companyId,
                                                            snap)))
                                            .then((value) => getClientsData());
                                      },
                                    ))
                                  ]))
                              .toList()
                          : userSnapShots.reversed
                              .map((snap) => DataRow(cells: [
                                    DataCell(Container(
                                      child: Text(snap['data']['name'],
                                          style: TextStyle(fontSize: 16)),
                                    )),
                                    DataCell(IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        UpdateClientDetails(
                                                            widget.companyId,
                                                            snap)))
                                            .then((value) => getClientsData());
                                      },
                                    ))
                                  ]))
                              .toList()),
                )
              : Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )),
    ));
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
