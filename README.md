
# Facial Recognition

2D Facial Recognition System



## Features

- Attendance management system 
    - (i.e. store the whereabouts of indiviual movement)
- Boasts "check-in" methods using
    - QR Codes
    - Facial Recognition 
    - Human Input (i.e. Manual) 
- Cross platform
- Messaging between administrator and user


## Environment

Flutter 3.27

Python 3.9

Raspberry Pi (for facial recognition script)

## Platform Support

| Platform  | Compatibility |
| ------------- | ------------- |
| Android  | ✅  |
| iOS  | ✅  |

## Run Locally

Clone the project

```bash
  git clone https://link-to-project
```

Install dependencies for Facial Recognition Utility

```pip install -r requirements.txt```

Install dependencies for both client and administrator app
(Client and Admin folder)

```flutter pub get```

### Init Firebase

Create new firebase project

Enable firebase authentication

Create new user (this will be our administrator) - note: you can add "client users" from the admin application
![](https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/Instructions/New%20User.png)

Copy the User ID
![](https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/Instructions/UID.png)

Enable firestore (database)

Create a document following the schema below filling 'Full Name' and 'Your Email' with your details respectively
![](https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/Instructions/Firestore.png)

Enable firebase cloud storage

Enable firebase cloud functions

[Install the Trigger Email extension for firebase](https://firebase.google.com/docs/extensions/official/firestore-send-email)

### Firebase flutter (Apps)

[Install the Firebase CLI](https://firebaseopensource.com/projects/firebase/firebase-tools/)

[Connect both flutter apps in the Client and Admin folder to Firebase](https://firebase.google.com/docs/flutter/setup?platform=ios)

Get the API key for firebase cloud messaging
![](https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/Instructions/FCM%20key.png)

In ```messages.dart``` of the client app, replace ```'Authorization': 'key= Firebase Cloud Messaging API KEY GOES HERE'``` with the key above.

In ```chat.dart``` of the admin app, replace ```'Authorization': 'key= Firebase Cloud Messaging API KEY GOES HERE'``` with the key above.

### Firebase Admin SDK (Facial Recognition Utility)

Download the service account JSON from firebase

![](https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/Instructions/Service%20Account.png)

Place it in the same directory as the Facial Recognition Utility folder

Update the variable ```cred``` in ```main.py``` to the path of the service account JSON

### Cloud Functions

This project also relies on the use of cloud functions for the Admin app.

Open to the Cloud Function folder

```cd Cloud Function```

Deploy cloud function using CLI

```firebase deploy --only functions```

### Running the code
 
In order for the facial recognition aspect of the check-in system to be fully functional, the utility must be running.

To start the utility

```python3 main.py```

To start either app, select a device, then type

```flutter run```

## Screenshots

### FaceAdmin

#### **Dashboard**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/Dashboard.png" alt="Dashboard" height="400">

#### **Check-in History**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/Check-in%20History.png" alt="Check-in History" height="400">

#### **List of Users**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/Users.png" alt="List of Users" height="400">

##### **User Info**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/User%20Info.png" alt="User Info" height="400">

##### **Edit User**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/User%20Update.png" alt="Edit User" height="400">

#### **QR Code Check-in Page**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/QR.png" alt="QR Code Check-in Page" height="400">

#### **Manual Check-in**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/Manual%20Check-in.png" alt="Manual Check-in" height="400">

#### **Messaging Functionality**  
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceAdmin/Chat.png" alt="Messaging Functionality" height="400">

### FaceClient

#### **Login**
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceClient/Login.png" height="400">

#### **Dashboard**
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceClient/Dashboard.png" height="400">

#### **Chat**
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceClient/Chat.png" height="400">

#### **QR Code Scanner**
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceClient/QR%20Code%20Scanner.png" height="400">

#### **Edit User**
<img src="https://github.com/vas-byte/FacialRecognition/blob/main/Screenshots/FaceClient/User%20Edit.png" height="400">

