import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryHomePage extends StatefulWidget {
  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory Management')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return ListTile(
                title: Text(document['name']),
                subtitle: Text('Quantity: ${document['quantity']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit Button
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditItemDialog(context, document),
                    ),
                    // Delete Button
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteItem(document.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  // Show Dialog to Add a New Item
  void _showAddItemDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Inventory Item'),
        content: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name')),
            TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('items').add({
                'name': nameController.text,
                'quantity': int.parse(quantityController.text),
                'timestamp': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // Show Dialog to Edit an Existing Item
  void _showEditItemDialog(BuildContext context, DocumentSnapshot document) {
    TextEditingController nameController =
        TextEditingController(text: document['name']);
    TextEditingController quantityController =
        TextEditingController(text: document['quantity'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Inventory Item'),
        content: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name')),
            TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateItem(document.id, nameController.text,
                  int.parse(quantityController.text));
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
