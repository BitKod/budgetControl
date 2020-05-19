import 'package:budgetControl/inApp/models/invoice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseInvoiceService {
  final String uid;
  DatabaseInvoiceService({this.uid});

  final CollectionReference collection = Firestore.instance.collection('users');

  //Invoice list from snapshot

  List<Invoice> _invoiceListFromSnapshot(QuerySnapshot snapshot) {
    
    return snapshot.documents.map((doc) {
      return Invoice.fromFirestore(doc);
    }).toList();
  }

  // get banks
  Stream<List<Invoice>> get invoices {
    return collection
        .document(uid)
        .collection('invoices')
        .snapshots()
        .map(_invoiceListFromSnapshot);
  }

  Future createInvoice(
      String uid, String invoiceType, String paymentInstrument, String owner) async {
    try {
      await collection.document(uid).collection('invoices').document().setData({
        "invoiceType": invoiceType,
        "paymentInstrument": paymentInstrument,
        "owner": owner,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
      return uid;
    } catch (e) {
      print('Hata oluştu!! : $e');
    }
  }

  Future deleteInvoice(String id) async {
    try { 
      await collection
          .document(uid)
          .collection('invoices')
          .document(id)
          .delete();
    } catch (e) {
      print('Hata oluştu!! : $e');
      return null;
    }
  }

  Future editInvoice(
      String uid,String id, String invoiceType, String paymentInstrument, String owner) async {
    try {
      await collection.document(uid).collection('invoices').document(id).updateData({
        "invoiceType": invoiceType,
        "paymentInstrument": paymentInstrument,
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
