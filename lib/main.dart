import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> todoList = [];
  List<bool> chkBoxValue = [];
  SharedPreferences? prefs;
  final TextEditingController taskModificationController =
      TextEditingController();

  bool toBoolean(String str) {
    return str != '0' && str != 'false' && str != '';
  }

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs!.containsKey("todo_List")) {
      setState(() {
        todoList = prefs!.getStringList("todo_List")!;
      });
    }
    if (prefs!.containsKey("chkBox_values")) {
      setState(() {
        chkBoxValue = prefs!
            .getStringList("chkBox_values")!
            .map((value) => toBoolean(value))
            .toList();
      });
    }
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('New Task'),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 10, bottom: 10, top: 15),
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.done,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(15),
                ),
                onSubmitted: (value) {
                  setState(() {
                    todoList.add(value);
                    prefs!.setStringList("todo_List", todoList);
                    chkBoxValue.add(false);
                    prefs!.setStringList("chkBox_values",
                        chkBoxValue.map((value) => value.toString()).toList());
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          ],
        ),
      );

  Future showModificationDialog(String taskTitle, String taskInfo, bool chkBoxVal, int index) =>
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(taskTitle,
              style: TextStyle(
                color:
                    chkBoxVal == false ? const Color(0xFFFE6C0E) : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
          content: TextFormField(
            autofocus: true,
            controller: taskModificationController..text = taskInfo,
            style: TextStyle(
              color: chkBoxVal == false
                  ? const Color(0xFFFE6C0E).withOpacity(0.75)
                  : Colors.lightGreen,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(15),
            ),
            maxLines: null,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                todoList[index] = taskModificationController.text;
                prefs!.setStringList("todo_List", todoList);
                chkBoxValue[index] = false;
                prefs!.setStringList("chkBox_values",
                    chkBoxValue.map((value) => value.toString()).toList());
                Navigator.of(ctx).pop();
              },
              child: const Text('Modify'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

  @override
  void initState() {
    getSharedPreferences();
    super.initState();
  }

  @override
  void dispose() {
    taskModificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF396D62),
        body: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset("assets/background.png", fit: BoxFit.contain),
            ),
            const Positioned(
                top: 40,
                left: 20,
                child: Text(
                  "Todos",
                  style: TextStyle(
                    fontSize: 40,
                    color: Color(0xFFEDFFFF),
                    fontWeight: FontWeight.bold,
                  ),
                )),
            DraggableScrollableSheet(
                maxChildSize: 0.85,
                initialChildSize: 0.30,
                minChildSize: 0.1,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40)),
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(15),
                            physics: const BouncingScrollPhysics(),
                            controller: scrollController,
                            itemCount: todoList.length,
                            itemBuilder: (context, int index) {
                              return ListTile(
                                title: Text(
                                  "Task No.$index  [${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}]",
                                  style: TextStyle(
                                    color: chkBoxValue[index] == false
                                        ? const Color(0xFFFE6C0E)
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Text(
                                  todoList[index],
                                  style: TextStyle(
                                    color: chkBoxValue[index] == false
                                        ? const Color(0xFFFE6C0E)
                                            .withOpacity(0.75)
                                        : Colors.lightGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: Checkbox(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7)),
                                  value: chkBoxValue[index],
                                  onChanged: (value) {
                                    setState(() {
                                      chkBoxValue[index] = value!;
                                      prefs!.setStringList(
                                          "chkBox_values",
                                          chkBoxValue
                                              .map((value) => value.toString())
                                              .toList());
                                    });
                                  },
                                  checkColor: Colors.white,
                                  activeColor: Colors.green,
                                  side: chkBoxValue[index] == true
                                      ? const BorderSide(color: Colors.white)
                                      : const BorderSide(
                                          color: Color(0xFFFE6C0E)),
                                ),
                                onTap: () {
                                  setState(() {
                                    showModificationDialog(
                                        "Task No.$index  [${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}]",
                                        todoList[index],
                                        chkBoxValue[index],
                                        index);
                                  });
                                },
                              );
                            }),
                      ),
                      Positioned(
                        top: -20,
                        right: 30,
                        child: FloatingActionButton(
                          backgroundColor: const Color(0xFFFE6C0E),
                          onPressed: () => openDialog(),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
