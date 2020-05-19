import 'package:budgetControl/inApp/models/credit_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseCreditCardService {
  final String uid;
  DatabaseCreditCardService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //CreditCard list from snapshot

  List<CreditCard> _creditCardListFromSnapshot(QuerySnapshot snapshot) {
    
    return snapshot.documents.map((doc) {
      return CreditCard.fromFirestore(doc);
    }).toList();
  }

  // get banks
  Stream<List<CreditCard>> get creditCards {
    return collection
        .document(uid)
        .collection('creditCards')
        .snapshots()
        .map(_creditCardListFromSnapshot);
  }

  Future createCreditCard(
      String uid, String bankName, String cardType, String owner) async {
    try {
      await collection.document(uid).collection('creditCards').document().setData({
        "bankName": bankName,
        "cardType": cardType,
        "owner": owner,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future deleteCreditCard(String id) async {
    try { 
      await collection
          .document(uid)
          .collection('creditCards')
          .document(id)
          .delete();
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editCreditCard(
      String uid,String id, String bankName, String cardType, String owner) async {
    try {
      await collection.document(uid).collection('creditCards').document(id).updateData({
        "bankName": bankName,
        "cardType": cardType,
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
