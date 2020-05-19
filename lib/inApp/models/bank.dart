import 'package:budgetControl/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bank extends BaseModel{
  final String id;
  final String bankName;
  final String accountType;
  final String owner;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Bank({
    this.id,
    this.bankName,
    this.accountType,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  Bank.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        bankName = document['bankName'],
        accountType = document['accountType'],
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