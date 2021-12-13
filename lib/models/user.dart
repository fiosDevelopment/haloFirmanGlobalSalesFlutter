import 'package:cloud_firestore/cloud_firestore.dart';

class UserList {
  String uID;
  String firstName;
  String lastName;
  String email;
  String imageUrl;
  String phoneCode;
  String phone;
  String status;
  String accountType;
  String aboutMe;

  UserList(
      {this.uID,
      this.firstName,
      this.lastName,
      this.email,
      this.imageUrl,
      this.phoneCode,
      this.phone,
      this.status,
      this.accountType,
      this.aboutMe});

  UserList.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {
    uID = documentSnapshot["uID"];
    firstName = documentSnapshot["firstName"];
    lastName = documentSnapshot["lastName"];
    email = documentSnapshot["email"];
    imageUrl = documentSnapshot["imageUrl"];
    phoneCode = documentSnapshot["phoneCode"];
    phone = documentSnapshot["phone"];
    status = documentSnapshot["status"];
    accountType = documentSnapshot["accountType"];
    aboutMe = documentSnapshot["aboutMe"];
  }
}
