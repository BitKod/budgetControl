import 'package:budgetControl/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice extends BaseModel{
  final String id;
  final String invoiceType;
  final String paymentInstrument;
  final String owner;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Invoice({
    this.id,
    this.invoiceType,
    this.paymentInstrument,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  Invoice.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        invoiceType = document['invoiceType'],
        paymentInstrument = document['paymentInstrument'],
        owner = document['owner'],
        createdAt = document['createdAt'],
        updatedAt = document['updatedAt'];

  @override
  fromJson(Map<String, Object> json) {
    throw UnimplementedError();
  }

  @override
  Map<String, Object> toJson() {
    throw UnimplementedError();
  }
}
