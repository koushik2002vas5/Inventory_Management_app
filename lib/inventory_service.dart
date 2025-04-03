import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addInventoryItem(String name, int quantity) {
  CollectionReference inventoryCollection =
      FirebaseFirestore.instance.collection('inventory');

  return inventoryCollection.add({
    'name': name,
    'quantity': quantity,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
