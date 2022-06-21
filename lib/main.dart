import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iQuote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 29, 3, 34),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          color: Colors.transparent,
          elevation: 2,
        ),
      ),
      home: const Qoutes(),
    );
  }
}

class Qoutes extends StatefulWidget {
  const Qoutes({Key? key}) : super(key: key);

  @override
  State<Qoutes> createState() => _QoutesState();
}

class _QoutesState extends State<Qoutes> {
  String from = '';
  String by = '';
  String quote = '';
  createQoute() {
    DocumentReference docref =
        FirebaseFirestore.instance.collection('qoutes').doc(by);

    Map<String, dynamic> qoute = {'fromQ': from, 'byQ': by, 'quoteQ': quote};
    docref.set(qoute);
  }

  deleteQoute(item) {
    DocumentReference docref =
        FirebaseFirestore.instance.collection('qoutes').doc(item);

    docref.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'iQoute',
          style: GoogleFonts.mcLaren(
            color: const Color.fromARGB(255, 158, 142, 142),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return showMyDialog(context);
              });
        },
        icon: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 142, 147, 158),
          size: 28,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('qoutes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
              'Something went wrong try again',
              style: GoogleFonts.mcLaren(
                color: const Color.fromARGB(255, 158, 142, 142),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (BuildContext context, int index) {
                QueryDocumentSnapshot<Object?>? docsnap =
                    snapshot.data?.docs[index];
                return Dismissible(
                  key: Key(index.toString()),
                  child: Card(
                    elevation: 6,
                    child: ListTile(
                      title: Text(
                        (docsnap != null) ? (docsnap['byQ']) : '',
                        style: GoogleFonts.mcLaren(
                          fontSize: 8,
                          color: Colors.white10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        (docsnap != null) ? (docsnap['qouteQ']) : '',
                        style: GoogleFonts.mcLaren(
                          fontSize: 14,
                          color: Colors.white10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (docsnap != null) ? (docsnap['fromQ']) : '',
                            style: GoogleFonts.mcLaren(
                              fontSize: 8,
                              color: Colors.white10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit),
                              ),
                              const SizedBox(width: 15),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    deleteQoute((docsnap != null)
                                        ? (docsnap['qouteQ'])
                                        : '');
                                  });
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          )
                        ],
                      ),
                      tileColor: const Color.fromARGB(255, 101, 26, 51),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: Text(
              'iQoute is empty click plus to add quote',
              style: GoogleFonts.mcLaren(
                color: const Color.fromARGB(255, 158, 142, 142),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget showMyDialog(BuildContext context, {bool isEditing = false}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: !isEditing ? const Text('Add Quote') : const Text('Edit Quote'),
      content: SizedBox(
        width: 400,
        height: 700,
        child: Column(
          children: [
            TextField(
              onChanged: (String value) {
                from = value;
              },
              decoration: const InputDecoration(
                label: Text('Qoute from:'),
              ),
            ),
            TextField(
              onChanged: (String value) {
                by = value;
              },
              decoration: const InputDecoration(
                label: Text('Qouted by:'),
              ),
            ),
            TextField(
              onChanged: (String value) {
                quote = value;
              },
              decoration: const InputDecoration(
                label: Text('Qoute:'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        !isEditing
            ? TextButton(
                onPressed: () {
                  setState(() {
                    createQoute();
                  });

                  Navigator.of(context).pop();
                },
                child: const Text('Add'))
            : TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: const Text('Edit')),
      ],
    );
  }
}

Widget qouteCard(Function()? onTab, QueryDocumentSnapshot? docsnap) {
  return InkWell(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 106, 13, 44),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            (docsnap != null) ? (docsnap['byQ']) : '',
            style: GoogleFonts.mcLaren(
              fontSize: 8,
              color: Colors.white10,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            (docsnap != null) ? (docsnap['fromQ']) : '',
            style: GoogleFonts.mcLaren(
              fontSize: 14,
              color: Colors.white10,
            ),
          ),
        ],
      ),
    ),
  );
}