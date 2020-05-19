import 'package:budgetControl/inApp/models/bank.dart';
import 'package:budgetControl/inApp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

   //Post list from snapshot

   List<Bank> _bankListFromSnapshot(QuerySnapshot snapshot) {
     return snapshot.documents.map((doc) {
       return Bank.fromFirestore(doc);
     }).toList();
   }

   // get individual user posts
   Stream<List<Bank>> get banks {
     return collection
         .document(uid)
         .collection('banks')
         .snapshots()
         .map(_bankListFromSnapshot);
   }

  Future registerUser(String uid, String name, String email) async {
    try {
      return await collection.document(uid).setData({
        "name": name,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future getProfile(String uid) async {
    try {
      DocumentSnapshot result =
          await Firestore.instance
          .collection('users')
          .document(uid)
          .get();

          if(result.exists) {
            return User.fromFirestore(result);
          }
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future editProfile(String uid, String name, String userImage) async {
    try {
      return await collection.document(uid).setData({
        "name": name,
        "userImage" : userImage,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future createBank(String uid, String bankName, String accountType, String owner) async {
    try {
      await collection.document(uid).collection('banks').document().setData({
        "bankName": bankName,
        "accountType, ": accountType, 
        "owner, ": owner,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future deleteBank(
    String id,
  ) async {
    try {
      return await collection
          .document(uid)
          .collection('banks')
          .document(id)
          .delete();
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editBank(String id, String bankName, String accountType, String owner) async {
    try {
      await collection.document(uid).collection('posts').document(id).updateData({
        "bankName": bankName,
        "accountType": accountType,
        "owner": owner,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }
}
