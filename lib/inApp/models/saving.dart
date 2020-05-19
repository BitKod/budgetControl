import 'package:budgetControl/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Saving extends BaseModel{
  final String id;
  final String bankName;
  final String savingType;
  final String savingAmount;
  final String savingCurrency;
  final String savingDate;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Saving({
    this.id,
    this.bankName,
    this.savingType,
    this.savingAmount,
    this.savingCurrency,
    this.savingDate,
    this.createdAt,
    this.updatedAt,
  });

  Saving.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        bankName = document['bankName'],
        savingType = document['savingType'],
        savingAmount = document['savingAmount'],
        savingCurrency = document['savingCurrency'],
        savingDate = document['savingDate'],
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
