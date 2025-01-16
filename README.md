
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

![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)

