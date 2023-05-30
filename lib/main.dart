import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("mybox");
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HiveDemo(),
  ));
}

class HiveDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HiveDemoState();
}

class HiveDemoState extends State {
  List<Map<String, dynamic>> items = [];

  final box = Hive.box('mybox');

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final item = box.keys.map((key) {
      final value = box.get(key);
      return {"key": key, "name": value["name"], "from": value['from'],"to": value["to"],"time":value["time"],"number":value["number"]};
    }).toList();
    setState(() {
      items = item.reversed.toList();
    });
  }

  // Create new item
  Future<void> additem(Map<String, dynamic> newItem) async {
    await box.add(newItem);
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enroute"),
        backgroundColor: Colors.blue,
      ),
      body: items.isEmpty
          ? const Center(
        child: CircularProgressIndicator(color: Colors.red,),
      )
          : ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) {
            final currentItem = items[index]; // fetching a single key - value pair from the list
            return Card(
              margin: EdgeInsets.all(10),
              //elevation: 3,
              child: ListTile(
                title: Row(
                  children: [
                    Text(currentItem['name']),
                    Text("/"),
                    Text(currentItem['number'].toString())
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(currentItem['from'].toString(),style: TextStyle(color: Colors.black),),
                    Text("-",style: TextStyle(color: Colors.black)),
                    Text(currentItem['to'].toString(),style: TextStyle(color: Colors.black))
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // if both main axis size and elevation is missing nothing will appear
                  // if main axis size is there then the list of card will appear
                  children: [
                    Text(currentItem["time"].toString(),style: TextStyle(fontSize: 15),),
                    IconButton(
                        onPressed: () {
                          _showForm(context, currentItem['key']);
                        },
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {

                          deleteitem(currentItem['key']);
                        },
                        icon: Icon(Icons.delete))
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
    );
  }

  final name_controller = TextEditingController();
  final from_controller = TextEditingController();
  final time_controller=TextEditingController();
  final to_controller =TextEditingController();
  final number_controller=TextEditingController();

  _showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingData =
      items.firstWhere((element) => element['key'] == itemKey);
      name_controller.text = existingData['name'];
      from_controller.text = existingData['from'];
      time_controller.text= existingData['time'];
      number_controller.text=existingData['number'];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        elevation: 3,
        context: context,
        builder: (context) {

          return Container(

            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 15,
              left: 15,
              right: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: name_controller,
                  decoration: InputDecoration(hintText: 'Bus Name'),
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: from_controller,
                        decoration: InputDecoration(hintText: 'from'),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: to_controller,
                        decoration: InputDecoration(hintText: 'to'),
                        keyboardType: TextInputType.text,
                      ),
                    ),

                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: time_controller,
                  decoration: InputDecoration(hintText: 'time   hh-mm-am/pm'),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: number_controller,
                  decoration: InputDecoration(hintText: 'Bus Number'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (itemKey == null||name_controller.text==null) {
                        additem({
                          'name': name_controller.text,
                          'from': from_controller.text,
                          'to':to_controller.text,
                          'time':time_controller.text,
                          "number":number_controller.text
                        });
                      }
                      if (itemKey != null) {
                        updateitem(itemKey, {
                          'name': name_controller.text.trim(),
                          'from': from_controller.text.trim(),
                          'to':to_controller.text.trim(),
                          'time':time_controller.text.trim(),
                          'number':number_controller.text.trim()
                        });
                      }
                      name_controller.text = '';
                      from_controller.text = '';
                      to_controller.text='';
                      time_controller.text='';
                      number_controller.text='';
                      Navigator.of(context).pop();
                    },
                    child: Text(itemKey == null ? "Create New" : "Update item"))
              ],
            ),
          );
        });
  }



  Future<void> updateitem(int itemkey, Map<String, dynamic> item) async{
    await box.put(itemkey,item);
    _refreshItems();
  }

  Future<void> deleteitem(itemkey) async{
    await box.delete(itemkey);
    _refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully deleted")));
  }


}