/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)});
const db = admin.firestore();

exports.SendNotificationsToDevice = functions.firestore
    .document("/{CompanyId}/JobDocument/JobCollection/{message}")
    .onWrite((change, context) => {
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
        const payLoad = {"notification": {"title": "New Job Alert", "body": `Job ${change.after.id} updated`, "clickAction": "FLUTTER_NOTIFICATION_CLICK"}};
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

exports.scheduledFunctionCrontab = functions.pubsub.schedule("00 00 * * *")
    .timeZone("Asia/Kolkata") // Users can choose timezone - default is America/Los_Angeles
    .onRun((context) => {
      db.collection("nithiyasg").doc("Subscription").get().then((snap) => {
        let subscriptionExpiryIn;
        if (!snap.exists) {
          console.log("No Data Found");
        } else {
          subscriptionExpiryIn = snap.data()["subscriptionExpiryIn"];
          if (subscriptionExpiryIn != 0) {
            db.collection("nithiyasg").doc("Subscription").update({"subscriptionExpiryIn": (subscriptionExpiryIn - 1)}, {merge: true});
          }
        }
      });
      return null;
    });

exports.scheduledFunctionAllCollection = functions.pubsub.schedule("38 23 * * *")
    .timeZone("Asia/Kolkata") // Users can choose timezone - default is America/Los_Angeles
    .onRun((context) => {
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
