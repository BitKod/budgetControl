import 'package:budgetControl/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FixedExpense extends BaseModel{
  final String id;
  final String expenseType;
  final String paymentInstrument;
  final String details;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  FixedExpense({
    this.id,
    this.expenseType,
    this.paymentInstrument,
    this.details,
    this.createdAt,
    this.updatedAt,
  });

  FixedExpense.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        expenseType = document['expenseType'],
        paymentInstrument = document['paymentInstrument'],
        details = document['details'],
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
