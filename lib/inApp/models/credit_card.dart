import 'package:budgetControl/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreditCard extends BaseModel{
  final String id;
  final String bankName;
  final String cardType;
  final String owner;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  CreditCard({
    this.id,
    this.bankName,
    this.cardType,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  CreditCard.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        bankName = document['bankName'],
        cardType = document['cardType'],
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
