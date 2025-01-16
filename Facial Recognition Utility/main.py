
import face_recognition
import cv2
import numpy as np
import firebase_admin
from firebase_admin import credentials, firestore, messaging
import requests
import os
import glob
import threading
import time
from datetime import datetime
from numpy import save
from numpy import load

callback_done = threading.Event()


UserEncodingIndex = {}
UsertoUid = {}
faces_encodings = []
faces_names = []

# If user photos are modified (or on launch)
def on_snapshot(doc_snapshot, changes, read_time):
    #for doc in doc_snapshot:
        for change in changes:

            # If photo is added (while running or on launch)
            if change.type.name == 'ADDED':
                 
                 ### PHOTO ADDED WHILE RUNNING ###
                 data = change.document.to_dict()
                 name = data['FullName']
                
                 photo = data['Photo']
                 uid = data["uid"]
                 UsertoUid[name] = uid
                 if data["storedEncodings"] == False:
                     img_data = requests.get(photo).content
                     with open(f'data/faces/{uid}.jpg', 'wb') as handler:
                         handler.write(img_data)
                     globals()['image_{}'.format(uid)] = face_recognition.load_image_file(f'data/faces/{uid}.jpg')
                     globals()['image_encoding_{}'.format(uid)] = face_recognition.face_encodings(globals()['image_{}'.format(uid)])[0]
                     faces_encodings.append(globals()['image_encoding_{}'.format(uid)])
                
                  
                     faces_names.append(f'/data/faces/{name}.jpg')
                

                     save(f'data/savedfaces/{uid}.npy',  globals()['image_encoding_{}'.format(uid)])
                     db.collection(u'Users').document(UsertoUid[name]).update({
                        "storedEncodings": True,
                     })
                     UserEncodingIndex[uid] = len(faces_encodings)

                 elif data["storedEncodings"] == True:
                     
                     ### PHOTO ADDED ON STARTUP ###
                     
                     # Load saved embeddings
                     faces_names.append(f'/data/faces/{name}.jpg')
                   
                     faces_encodings.append(load(f'data/savedfaces/{uid}.npy'))
                     UserEncodingIndex[uid] = len(faces_encodings)

            # If user photo modified
            elif change.type.name == 'MODIFIED':
                 data = change.document.to_dict()
                 name = data['FullName']
                 photo = data['Photo']
                 uid = data["uid"]
               
                 if data["storedEncodings"] == False:
                     
                     # Store the image as a picture
                     os.remove(f'data/savedfaces/{uid}.npy')
                     img_data = requests.get(photo).content
                     with open(f'data/faces/{uid}.jpg', 'wb') as handler:
                         handler.write(img_data)
                    
                     # Load picture and calculate embeddings
                     globals()['image_{}'.format(uid)] = face_recognition.load_image_file(f'data/faces/{uid}.jpg')
                     globals()['image_encoding_{}'.format(uid)] = face_recognition.face_encodings(globals()['image_{}'.format(uid)])[0]
                     faces_encodings[UserEncodingIndex[uid]] = globals()['image_encoding_{}'.format(uid)]
                    
                    # Save embeddings
                     save(f'data/savedfaces/{uid}.npy',  globals()['image_encoding_{}'.format(uid)])
                     db.collection(u'Users').document(UsertoUid[name]).update({
                        "storedEncodings": True,
                     })
                  

                    
            # If photo is removed
            elif change.type.name == 'REMOVED':
                 
                 # Remove user embedding 
                 data = change.document.to_dict()
                 name = data['FullName']
                 photo = data['Photo']
                 uid = data["uid"]
                 os.remove(f'data/savedfaces/{uid}.npy')
                 faces_encodings.pop(UserEncodingIndex[uid])
                 faces_names.pop(UserEncodingIndex[uid])
                 for key in UserEncodingIndex:
                     if UserEncodingIndex[key] >= UserEncodingIndex[uid]:
                         UserEncodingIndex[key] = UserEncodingIndex[key] - 1

                 UsertoUid.pop(name)
                 UserEncodingIndex.pop(uid)  
         
        print(faces_encodings)
        callback_done.set()


# Facial recognition function
def findFaces():

    # Temporary name blacklist
    TemporaryNamesList = []

    FrameNum = 0
   
    print("Thread2")


    face_locations = []
    face_encodings = []
    face_names = []
    process_this_frame = True

    video_capture = cv2.VideoCapture(0)
    #video_capture.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    #video_capture.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    #video_capture.set(cv2.CAP_PROP_FPS, 25)

    # Infinite Loop
    while True:
        
        FrameNum = FrameNum + 1
        ret, frame = video_capture.read()
        small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
        rgb_small_frame = small_frame[:, :, ::-1]

        # Process every second frame (improve performance) - facial recognition
        if process_this_frame:
            face_locations = face_recognition.face_locations( rgb_small_frame)
            face_encodings = face_recognition.face_encodings( rgb_small_frame, face_locations)
            face_names = []
            for face_encoding in face_encodings:
                matches = face_recognition.compare_faces (faces_encodings, face_encoding)
                name = "Unknown"
                face_distances = face_recognition.face_distance(faces_encodings, face_encoding)
                best_match_index = np.argmin(face_distances)
                if matches[best_match_index]:
                    name = faces_names[best_match_index]
                face_names.append(name)
        process_this_frame = not process_this_frame

        # Display the results
        for (top, right, bottom, left), name in zip(face_locations, face_names):
            top *= 4
            right *= 4
            bottom *= 4
            left *= 4

            # Draw a rectangle around the face
            cv2.rectangle(frame, (left, top), (right, bottom), (0, 0, 255), 2)

            # Input text label with a name below the face
            cv2.rectangle(frame, (left, bottom - 35), (right, bottom), (0, 0, 255), cv2.FILLED)
            font = cv2.FONT_HERSHEY_DUPLEX
            cv2.putText(frame, name, (left + 6, bottom - 6), font, 1.0, (255, 255, 255), 1)

            #firebase stuff goes here
            if len(face_names) != 0:
                colname = name.replace("/data/faces/", "")
                colname = colname.replace(".jpg", "")

                # Check if name is in temporary blacklist
                if colname not in TemporaryNamesList and colname != "Unknown":
                    
                     # Record date/time/location of detected user and send detection notification to Admin App (but not Client)
                     timeStamp = datetime.now()
                    
                     db.collection(u'Group').document(u'Members').collection(UsertoUid[colname]).document('Attendance').collection('Record').document().set({
                         "Time": datetime.now().strftime("%-I:%M %p"),
                         "Date": datetime.today().strftime('%Y-%m-%d'),
                         "Location": "Vas Rpi",
                         "DateTime": datetime.now().strftime("%d/%m/%Y %-I:%M:%S"),
                         "isFace": True,
                         "isManual": False,
                         "isQR": False,
                         "Timestamp": timeStamp
                     })
                     db.collection(u'Group').document(u'History').collection(u'Attendance').document().set({
                         "Time": datetime.now().strftime("%-I:%M %p"),
                         "Date": datetime.today().strftime('%Y-%m-%d'),
                         "Location": "Vas Rpi",
                         "DateTime": datetime.now().strftime("%d/%m/%Y %-I:%M:%S"),
                         "uid": UsertoUid[colname],
                         "isFace": True,
                         "isManual": False,
                         "isQR": False,
                         "Timestamp": timeStamp

                        })
                     message = messaging.Message(
                         notification=messaging.Notification(
                         title='User Detected', body=colname + ' was detected'),
                         topic = 'detect'
                     )
                     response = messaging.send(message)
                
                     TemporaryNamesList.append(colname)

        # Display the resulting image
        cv2.imshow('Video', frame)

        # Reset name blacklist after 100 frames
        if FrameNum == 100:
            TemporaryNamesList.clear()
            FrameNum = 0
    
        # Hit 'q' on the keyboard to quit!
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

def main():
     
    # Load all image files
    files = glob.glob('data/faces/*')

    for f in files:
        os.remove(f)

    # Load firebase Admin credentials
    cred = credentials.Certificate('NAME OF SERVICE ACCOUNT FILE.json')
    firebase_admin.initialize_app(cred)
    global db 
    db = firestore.client()  # this connects to our Firestore database
    
    # Listen for changes to users
    doc_ref = db.collection(u'Users').where(u"isAdmin", "==", False)
    doc_watch = doc_ref.on_snapshot(on_snapshot)

    print(faces_encodings)

    # Run facial recognition
    findFaces()

if __name__ == '__main__':
    main()


