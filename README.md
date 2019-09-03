# SmartTrainingLogiOS

# Note
This app was designed for the Georgia Tech Athletic Association and I have taken it for the purpose of the first programming assignment of Mobile Applications and Services. I have added all instructions and necessary dependencies in this README file, so please read carefully to run this application.

# Overview
	This mobile iOS application was designed for the Georgia Tech Athletic Association’s physical therapy department to help
	them streamline the process of creating treatments, checking into scheduled treatments and providing feedback on the
	treatments. As a response to the department’s current check-in system which consists of a single kiosk, our system
	addresses several of the existing issues we identified. First of all, upgrading to our application will allow the
	department to avoid a bottleneck at check-in during times of high traffic. Since all athletes will be able to access and
	check-in to their scheduled training on their own mobile devices, no one will need to wait in line for their turn at the 
	kiosk. In addition, trainers are immediately notified on their own device after the student athlete has checked in on their 
	app. Once the session begins, the trainer will be able to list the details of the training on the application and when the
	session is over, the athlete will be able to see that training on their own app. Afterwards, athletes and trainers are also 
	able to add comments to that training. For example, if a trainer recommended a certain exercise for the athlete to do at 
	home, and that exercise causes pain to the athlete, then they can go onto the app and add a comment to the training to tell 
	the trainer what happened. This system of commenting back and forth provides a channel of constant communication between 
	the student athlete and the trainer. Thus, students do not need to wait until their next visit to the Athletic Association
	to let their trainer know about any issues that they came across and vice versa. 
	Our application was created using XCode and the native development language, Swift. In addition, our team is utilizing 
	Firebase database to enable data storage and retrieval. Through this relatively simple technology stack, we were able to
	create an application that addresses the initial issues we identified with the physical therapy department’s current 
	system. 
	

# Release Notes

Version 0.1

New Software Features:
- Users are able to register themselves to the application as students.
- Users are able to log-in to the application using their username and password information. 
- Profile page with information such as name and sports team is provided for each registered user.

Bug Fixes:
- None since this is the first release

Defects/Bugs:
-  Currently no way to register as a trainer. 


Version 0.2

New Software Features:
- Treatments page is now implemented and shows a user's upcoming treatments.
- Users are now able to add a treatment to the treatments page using the Add Treatment Form. 

Bug Fixes: 
- Added a toggle on the registration page so now users can register as either a student or a trainer.
- Improved Register Page UI to make it less confusing. 

Defects/Bugs: 
- Both students and trainers can add treatments but we only want trainers to be able to do so. 
- We want trainers to be able to select treatments from a drop down list but that does not exist yet.


Version 0.3

New Software Featuers: 
- History page is added where users can view their past treatments.
- Users are now able to add comments to a past treatment as a way of communication between trainer and athlete. 

Bug Fixes: 
- Only trainers can add treatments now. 

Defects/Bugs:
- Currently no UI to show comments which have been added to past trainings. 


Version 0.4

New Software Features: 
-  None since this is the release after a debug sprint. 

Bug Fixes: 
- Changed data base structure into something more comprehensive for our team. 
- Cleaned and organized Firebase API code into it's own folder. 
- Made some slight improvements to the UI in the Add Treatments Form and the Treatments and History pages. 

Defects/Bugs: 
- Users have no way to add a profile picture to their profile.

Version 1.0

New Software Features:
- Push notification is sent to trainer when a student checks into their scheduled training to let the trainer know the student is here. 
- Push notification is sent to student whent trainer creates a new treatment for them. This will give the student information on the training, such as when it is.

Bug Fixes: 
- Users can now add their profile pictures. 

Defects/Bugs: 
- No way to schedule training between trainer and student on the app. Scheduling must be done externally and then the trainer can create the upcoming treatment for the student. 

# Installation Guide

# Pre-Requisites
# Preparing Hardware
In order to be able to successfully run the application on a computer, you must have access to a macOS system 

# Preparing Software
Please install XCode from this link: https://developer.apple.com/download/. 
CocoaPods will also be necessary. Please install by following the directions at this link: https://guides.cocoapods.org/using/getting-started.html

# Dependencies
All of the dependencies required will be listed in the a file called the ‘Podfile.’ These are necessary third-party softwares needed to run our application. Instructions to install these dependencies will be listed in steps 2 and 3 of the ‘Download Instructions’ section below. 

# Here is a list of the dependencies included in the Podfile: 
Firebase
Firebase Core
Firebase Auth
Firebase Storage
Firebase Database
Firebase Firestore
Firebase Messaging
Observable
Keychain
Codable Firebase Interaction

# Download Instructions
Since the application is still in beta testing, we have not yet released the application to be in the Apple App Store. In order to download the raw source code for our application to your own machine, please follow the instructions below: 
Please download the Smart Training Log source code from github here: https://github.com/JDBoizPlusAlice/SmartTrainingLogiOS Select clone or download, then download zip. Unzip the file when it is downloaded. 
Please navigate to the /SmartTrainingLogiOS/SmartTrainingLog directory where the Podfile resides.
Open terminal by going to Applications/Utilities/Terminal
Type ‘cd’ into the terminal followed by a space, then drag the SmartTrainingLog file to the terminal and press enter. This will navigate you to the project in Terminal.
Once you are inside the SmartTrainingLog directory, please run ‘pod install’ on the command line to install dependencies.

# Build Instructions
Once you have followed the ‘Download Instructions’ above, you are ready to spin up the application on your local machine. 

All you need to do to run the application is click on the play button in the top left corner of your XCode screen. This button should kick off a build! After the application successfully builds, an iPhone screen will appear and you can click through the application there. 

# Use Instructions 
Once the application is built and running on your machine, there are few simple steps you must follow to start your experience: 
Register yourself as a user. 
Once you have completed the above, please log into the application.
You will be brought to your profile page. Please click the ‘Edit’ button in the top right hand corner and set the sport team with which you are associated. 

# Run Instructions
If you are running from raw source code, please follow the Download Instructions. Once you have accomplished that, click the play button in the top left of the XCode screen. This will spin up the application! 

# Troubleshooting
The most likely issue that will appear is if you don’t install the dependencies in your Podfile before trying to spin up the application. If this happens, then your build will fail with an error that states: “unable to open file.” 

If this happens, then please go to your Terminal, navigate to the directory which contains the Podfile (/SmartTrainingLogiOS/SmartTrainingLog) using the ‘cd’ command and then run ‘pod install’ once you are there. Run the application again and the build should succeed! 
