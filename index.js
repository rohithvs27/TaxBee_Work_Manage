/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)});
const db = admin.firestore();

exports.SendNotificationsToDevice = functions.firestore
    .document("/{CompanyId}/JobDocument/JobCollection/{message}")
    .onWrite((change) => {
      const previousValue = change.before.data();
      const newValue = change.after.data();
      if (previousValue["employee"] == null) {
        const payLoad = {"notification": {"title": "New Job Alert", "body": `Job ${change.after.id} assigned to you`, "clickAction": "FLUTTER_NOTIFICATION_CLICK"}};
        db.collection(change.after.data()["companyId"]).doc("UserDocument").collection("UserCollection").where("name", "in", newValue["employee"]["assignedTo"]).get().then((snapShot)=>{
          snapShot.docs.map((snap) => {
            admin.messaging().sendToDevice(snap.data()["token"], payLoad ).then(() => {
              console.log("Notifications sent:"+ snap.data()["token"]);
            });
          });
        });
      } else {
        const payLoad = {"notification": {"title": "Job Update Alert", "body": `Job ${change.after.id} updated`, "clickAction": "FLUTTER_NOTIFICATION_CLICK"}};
        db.collection(change.after.data()["companyId"]).doc("UserDocument").collection("UserCollection").where("name", "in", newValue["employee"]["assignedTo"]).get().then((snapShot)=>{
          snapShot.docs.map((snap) => {
            admin.messaging().sendToDevice(snap.data()["token"], payLoad ).then(() => {
              console.log("Notifications sent:"+ snap.data()["token"]);
            });
          });
        });
      }
      return null;
    });

exports.RemoveUser = functions.firestore.document("/{CompanyId}/UserDocument/UserCollection/{uid}").onDelete((snapShot, context) =>{
  return admin.auth().deleteUser(context.params.uid);
});

exports.scheduledFunctionCheckSubscription = functions.pubsub.schedule("00 00 * * *")
    .timeZone("Asia/Kolkata") // Users can choose timezone - default is America/Los_Angeles
    .onRun(() => {
      db.listCollections().then( (collections) => {
        for (const collection of collections) {
          db.collection(collection.id).doc("Subscription").get().then((snap) => {
            let subscriptionExpiryIn;
            try {
              if (snap.exists) {
                subscriptionExpiryIn = snap.data()["subscriptionExpiryIn"];
                if (subscriptionExpiryIn != 0) {
                  db.collection(collection.id).doc("Subscription").update({"subscriptionExpiryIn": (subscriptionExpiryIn - 1)}, {merge: true});
                }
              }
            } catch (error) {
              console.log(error);
            }
          }
          );
        }
      });
      return null;
    });

exports.CreateNewEmp = functions.firestore
    .document("/{CompanyId}/addEmpDocument/addEmpCollection/{newemp}")
    .onCreate((change) => {
      console.log(change.data());
      admin.auth().createUser({
        email: change.data()["email"],
        password: "password",
        displayName: change.data()["name"],
      }).then(function(userRecord) {
        const companyId = change.data()["uniqueCompanyId"];
        db.collection(companyId).doc("UserDocument").collection("UserCollection").doc(userRecord.uid).set({
          "uniqueCompanyId": companyId,
          "email": userRecord.email,
          "name": userRecord.displayName,
          "isAdmin": change.data()["isAdmin"],
        }).then(() => {
          db.collection(companyId).doc("addEmpDocument").collection("addEmpCollection").doc("newusertemplocation").delete().then((value) => {
            console.log(value);
          });
        });
      });
      return null;
    }
    );
