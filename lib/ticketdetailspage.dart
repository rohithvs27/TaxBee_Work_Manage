import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_ca_management_app/updateexistingjob.dart';
import 'package:new_ca_management_app/widgets/customappbar.dart';
import 'package:new_ca_management_app/widgets/loadingscreen.dart';

FirebaseFirestore dbCollection = FirebaseFirestore.instance;
TextStyle customLeftStyle = TextStyle(
  fontSize: 16,
);
TextStyle customRightStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
double customContainerHeight = null;
bool jobDescempty = true;

class TicketDetailsPage extends StatefulWidget {
  final jobDetails;
  final jobId;
  final clientId;
  final bool admin;
  final empname;

  TicketDetailsPage(
      this.admin, this.clientId, this.jobId, this.jobDetails, this.empname);

  @override
  _TicketDetailsPageState createState() =>
      new _TicketDetailsPageState(jobId, jobDetails);
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  final jobId;
  final jobDetails;
  var currentStatus;
  var updatedStatus;
  bool deletingjob = false;
  _TicketDetailsPageState(this.jobId, this.jobDetails) {
    if (jobDetails.containsKey('jobDescription')) {
      jobDescempty = false;
    }
  }
  ScrollController _controller = new ScrollController();

  DateFormat dateFormat = DateFormat('dd-MMM-yy');

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          appBar: customAppBar(context, widget.jobId),
          body: Container(
            width: width,
            height: height,
            child: Hero(
              tag: widget.jobId,
              child: Card(
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10),
                    physics: new BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    children: <Widget>[
                      Card(
                        child: Container(
                          height: customContainerHeight,
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Text(
                                  "Client Name",
                                  style: customLeftStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  widget.jobDetails["clientName"].toString(),
                                  style: customRightStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Container(
                          height: customContainerHeight,
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Text(
                                  "Job Type",
                                  style: customLeftStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  widget.jobDetails["jobType"].toString(),
                                  style: customRightStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Container(
                          height: customContainerHeight,
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Text(
                                  "Job Sub Type",
                                  style: customLeftStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  widget.jobDetails["jobSubType"].toString(),
                                  style: customRightStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Container(
                          height: customContainerHeight,
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
                                      itemCount: widget
                                          .jobDetails['employee']["assignedTo"]
                                          .length,
                                      itemBuilder:
                                          (context, assignedToEmpCount) {
                                        print("assignedToEmpCount" +
                                            assignedToEmpCount.toString());
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: Container(
                                            width: width / 4,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),

                                            //color: Colors.green[200],
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 0, 10, 0),
                                                child: Text(
                                                  widget.jobDetails['employee']
                                                          ["assignedTo"]
                                                          [assignedToEmpCount]
                                                      .toString(),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                      ),
                      Card(
                        child: Container(
                          height: customContainerHeight,
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Text(
                                  "Lead",
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
                                      itemCount: widget
                                          .jobDetails['employee']["teamLead"]
                                          .length,
                                      itemBuilder: (context, teamLeadCount) {
                                        print("teamLeadCount" +
                                            teamLeadCount.toString());
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            width: width / 4,
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 0, 10, 0),
                                                child: Text(
                                                  widget.jobDetails['employee']
                                                          ["teamLead"]
                                                          [teamLeadCount]
                                                      .toString(),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.blue[800]),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Container(
                          height: customContainerHeight,
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Status",
                                  style: customLeftStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  widget.jobDetails["currentStatus"].toString(),
                                  style: customRightStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Container(
                          height: customContainerHeight,
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Text(
                                  "Due Date",
                                  style: customLeftStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dateFormat
                                      .format(
                                          widget.jobDetails["dueDate"].toDate())
                                      .toString(),
                                  style: customRightStyle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Container(
                          constraints: BoxConstraints(
                              minHeight: height / 6, maxHeight: height / 4),
                          // margin: EdgeInsets.all(10),
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          child: SingleChildScrollView(
                              child: jobDetails.containsKey('jobDescription')
                                  ? ListView.builder(
                                      controller: _controller,
                                      shrinkWrap: true,
                                      itemCount: widget
                                          .jobDetails['jobDescription'].length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                            title: Text(widget
                                                .jobDetails['jobDescription'][
                                                    widget
                                                            .jobDetails[
                                                                'jobDescription']
                                                            .length -
                                                        (index + 1)]
                                                .toString()));
                                      },
                                    )
                                  : Container(
                                      height: 0,
                                      width: 0,
                                    )),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 20, 10, 10),
                              alignment: Alignment.center,
                              child: widget.jobDetails["currentStatus"] !=
                                      "Complete"
                                  ? MaterialButton(
                                      color: Colors.blue[800],
                                      child: Text(
                                        "Update Job",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20),
                                      ),
                                      height: 50,
                                      minWidth: double.infinity,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateExistingJob(
                                                        widget.admin,
                                                        widget.jobId,
                                                        widget.jobDetails,
                                                        widget.empname)));
                                      },
                                    )
                                  : widget.admin
                                      ? MaterialButton(
                                          color: Colors.amber[600],
                                          child: Text(
                                            "Reopen Job",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20),
                                          ),
                                          height: 50,
                                          minWidth: double.infinity,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        UpdateExistingJob(
                                                            widget.admin,
                                                            widget.jobId,
                                                            widget.jobDetails,
                                                            widget
                                                                .empname))).then(
                                                (value) {
                                              setState(() {});
                                            });
                                          },
                                        )
                                      : MaterialButton(
                                          disabledColor: Colors.grey,
                                          child: Text(
                                            "Update Job",
                                            style: TextStyle(
                                                color: Colors.white30,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 19),
                                          ),
                                          height: 50,
                                          minWidth: double.infinity,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                                  BorderRadius.circular(0.0)),
                                          onPressed: null),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 20, 10, 10),
                              alignment: Alignment.center,
                              child: MaterialButton(
                                disabledColor: Colors.grey,
                                color: Colors.red,
                                child: Text(
                                  "Delete Job",
                                  style: TextStyle(
                                      color: widget.admin
                                          ? Colors.white
                                          : Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20),
                                ),
                                height: 50,
                                minWidth: double.infinity,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                onPressed: widget.admin &&
                                        widget.jobDetails["currentStatus"] !=
                                            "Complete"
                                    ? () {
                                        HapticFeedback.lightImpact();
                                        showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                    title: Text("Delete Job"),
                                                    titleTextStyle: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Text(
                                                          "Are you sure to delete this job?"),
                                                    ),
                                                    actions: <Widget>[
                                                      Container(),
                                                      MaterialButton(
                                                        elevation: 8,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        color: Colors.green,
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
                                                          Navigator.of(context)
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
                                                        color: Colors.red,
                                                        child: Text("Yes",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                        onPressed: () {
                                                          setState(() {
                                                            deletingjob = true;
                                                          });
                                                          HapticFeedback
                                                              .lightImpact();
                                                          loadingScreen(
                                                              context);

                                                          deleteJobDocument(
                                                                  jobId)
                                                              .then((success) {
                                                            setState(() {
                                                              if (success) {
                                                                deletingjob =
                                                                    false;
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            });
                                                          });
                                                        },
                                                      )
                                                    ]));
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
          )),
    );
  }

  Future<String> getCurrentJobStatus(String jobId) async {
    DocumentReference documentReference = dbCollection
        .collection(widget.clientId)
        .doc("JobDocument")
        .collection("JobCollection")
        .doc(jobId);

    DocumentSnapshot snapshot = await documentReference.get();

    return snapshot.data()["currentStatus"];
  }

  Stream<DocumentSnapshot> getCurrentJobStatusSnapshot(
      BuildContext context, String clientId) async* {
    yield* dbCollection
        .collection(clientId)
        .doc("JobDocument")
        .collection("JobCollection")
        .doc(jobId)
        .snapshots();
  }

  Future<bool> deleteJobDocument(String jobId) async {
    try {
      dbCollection
          .collection(widget.clientId)
          .doc("JobDocument")
          .collection("JobCollection")
          .doc(jobId)
          .delete();
    } catch (e) {
      return false;
    }
    await Future.delayed(Duration(seconds: 2));
    return true;
  }
}
