const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();



exports.deleteUser = functions.https.onCall(async (req, res) => {
    var db = admin.firestore();
    var user = await db.collection("Users").where("uid", '==', req.uid).get()
    var isAdmin = user.docs[0].data()
    
    if(isAdmin["isAdmin"]){
       
        admin.auth()
        .deleteUser(req.text)
        .then(() => {
            return "deleted"
        })
        .catch((error) => {
          return String(error)
        });
    }
});

//called when new user is signed-up by admin
exports.addUser = functions.https.onCall(async (req, res) => {
    
    var db = admin.firestore();
    var user = await db.collection("Users").where("uid", "==", req.uid).get() 
    var isAdmin = user.docs[0].data()

    if(isAdmin["isAdmin"]){ //checks if user is administrator
       admin.auth()
        .createUser({ //creates user with firebase authentication (so user can log in)
            email: req.Useremail,
            password: req.Userpassword,
        }) 
        .then(function(userRecord) {
            
    //Create a document in Firestore with user info 
     db.collection("Users").doc(userRecord.uid).set({
        "FullName": req.fN, 
        "Photo": req.picURL, 
        "Email": req.Useremail, 
        "isAdmin": false, 
        "uid":  userRecord.uid.toString(),
        "imageUploaded": true,
        "storedEncodings": false,

   
  })
            return "success" //tell admin app user successfully created
        })
        .catch((error) => {
          return String(error) //shows error message to admin app
        });
    }
});

exports.addUserFromSignUp = functions.https.onCall(async (req, res) => { //avoid using .then and catch use tru catch instead
    var db = admin.firestore();
    var user = await db.collection("Tokens").where("id", "==", req.token).get()
    if(!user.empty){
       
        var DBToken = user.docs[0].data()
        if(DBToken["id"] == req.token && DBToken["devid"] == req.devid){
           
            var uid = ""
            try {
               await admin.auth()
                .createUser({
                    email: req.Useremail,
                    password: req.Userpassword,
                }).then(userRecord => {
                    uid = userRecord.uid.toString()
                })
               
           
                    
            // See the UserRecord reference doc for the contents of userRecord.
           await db.collection("Users").doc(uid).set({
                "FullName": req.fN,  "Email": req.Useremail, "isAdmin": false, "uid": uid   , "imageUploaded": false,
                "storedEncodings": false,
             })
    
           
    
           await db.collection("Tokens").doc(user.docs[0].id).delete()
    
          
    
           return "User Created"
           
            } catch(e){
                return e.toString()
            }
        
    
    } else {
         return  "Device Does Not Match Sign-Up Token"
        }
    } else {
        return "Invalid Token"
    }
})


exports.validateToken = functions.https.onCall(async (req, res) => {
    var db = admin.firestore();
    var user = await db.collection("Tokens").where("id", "==", req.token).get()
    var docos = user.empty
    var uattempt = await db.collection("TokenAttempts").doc(req.devid).get()

    if(!docos){
        
        if(uattempt.exists){
           
            var attemptdata = uattempt.data()
            var attemptno = attemptdata["attempts"]
            if(attemptno >= 3){
           
            return "Too Many Attempts Try Again in 24 Hours"
            } else {

                var DBToken = user.docs[0].data()
                var DocName = user.docs[0].id
               
                if(DBToken["id"] == req.token){
                    db.collection("Tokens").doc(DocName).update({
                        'devid': req.devid
                    })
                    return "Valid Token"
                } else {
        return "Invalid Token"
                }
            }
        } else {
           
            var DBToken = user.docs[0].data()
            var DocName = user.docs[0].id
            
            if(DBToken["id"] == req.token){
                db.collection("Tokens").doc(DocName).update({
                    'devid': req.devid
                })
                return "Valid Token"
            } else {
    return "Invalid Token"
            }
        }
     
    } else {
       
        if(uattempt.exists){
           
            var attemptdata = uattempt.data()
            var uattemptno = attemptdata["attempts"]
            db.collection("TokenAttempts").doc(req.devid).update({
                "devid": req.devid,
                "attempts": uattemptno + 1,
            })
        } else {
            
            db.collection("TokenAttempts").doc(req.devid).set({
                "devid": req.devid,
                "attempts": 1,
            })
        }
       
        return "Invalid Token"
    }
})


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
