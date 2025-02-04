import 'package:flutter/material.dart';
import 'package:velock_app/main.dart';
import '../util/auth.dart';
import '../util/firebase_service.dart';
import 'home_page.dart';

class LockSetting extends StatefulWidget {
  const LockSetting({super.key});

  @override
  State<LockSetting> createState() => _LockSettingState();
}

class _LockSettingState extends State<LockSetting> {
  final TextEditingController _textController = TextEditingController();
  late String userUID;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    userUID = Auth().getUserUid() ?? "";
  }

  void _saveLock() async {
    if (_textController.text.isNotEmpty) {
      try {
        await _firebaseService.saveLock(userUID, _textController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lock added successfully!')),
        );
        setState(() {});
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "LockID does not exist in the database. Or is already inserted")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid lock ID!')),
      );
    }
  }

  Future<List<String>> loadUserLocks() async {
    return await _firebaseService.loadLock(userUID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Lock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: MyApp.accentColor),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const HomePage();
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
              ),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: true, // Ensure resizing when keyboard appears
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss keyboard when tapped outside
        },
        child: SingleChildScrollView(
          reverse: true, // Scroll from the bottom upwards
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<String>>(
                  future: loadUserLocks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Add your locks here"),
                      );
                    } else {
                      final lockIDs = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: lockIDs.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 5.0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              leading: const Icon(Icons.lock_outline),
                              title: Text(lockIDs[index],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: const Text('Unique Lock ID'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _firebaseService.deleteLock(
                                      userUID, lockIDs[index]);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: MyApp.accentColor),
                    hintText: 'Enter lock id',
                    hintStyle: const TextStyle(color: MyApp.accentColor),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: MyApp.accentColor,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: MyApp.accentColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: const TextStyle(color: MyApp.accentColor),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _saveLock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyApp.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Save Lock',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
