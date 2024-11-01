import 'package:chat_app/screens/login_page.dart';
import 'package:chat_app/widgets/build_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_detail.dart';

class HomePage extends StatefulWidget {
  final int? index;
  final String? content;
  final String? idTo;
  final String? timestamp;
  final int? type;
  final bool? isMessageRead;
  final String? email;
  final String? name;
  final String? lastMessage;

  const HomePage(
      {super.key,
      this.index,
      this.content,
      this.idTo,
      this.lastMessage,
      this.timestamp,
      this.type,
      this.isMessageRead,
      this.email,
      this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String getConversationID(String sender, String peerID) {
    String id = sender.hashCode <= peerID.hashCode
        ? '${sender}_$peerID'
        : '${peerID}_$sender';
    print(id);
    return id;
  }


  @override
  Widget build(BuildContext context) {
    final CollectionReference userslistSnapShot =
        FirebaseFirestore.instance.collection('user');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.indigo.shade400,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 3.5),
              child: const BuildTextWidget(
                text: 'ChatApp',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Pattaya', fontSize: 38),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            iconColor: Colors.white,
            color: Colors.indigo.shade200,
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 10),
                    BuildTextWidget(
                      text: "Logout",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
          color: Colors.black,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 700,
                  child: StreamBuilder(
                      stream: userslistSnapShot.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator(
                              color: Colors.black);
                        } else {
                          var userList = snapshot.data!.docs;
                          userList.removeWhere((user) =>
                              user["uid"] ==
                              FirebaseAuth.instance.currentUser!.uid);
                          return ListView.builder(
                            itemCount: userList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        userList[index]["uid"],
                                        displayname: userList[index]["name"],
                                        photoURL: userList[index]['photoURL'],
                                        fcmToken: userList[index]['fcmToken'],
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: 5,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadiusDirectional
                                                            .circular(2),
                                                    color:
                                                        Colors.indigo.shade400),
                                                child: const Text(''),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    userList[index]
                                                        ["photoURL"]),
                                                maxRadius: 25,
                                              ),
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  color: Colors.transparent,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        children: [
                                                          BuildTextWidget(
                                                            text:
                                                                userList[index]
                                                                    ["name"],
                                                            style: TextStyle(
                                                                fontSize: 22,
                                                                color: Colors
                                                                    .indigo
                                                                    .shade400),
                                                          ),
                                                          const Spacer(),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 6,
                                                      ),
                                                      StreamBuilder(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'messages')
                                                            .doc(getConversationID(
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid,
                                                                userList[index]
                                                                    ["uid"]))
                                                            .collection('chat')
                                                            .orderBy(
                                                                'timestamp',
                                                                descending:
                                                                    true)
                                                            .limit(1)
                                                            .snapshots(),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    QuerySnapshot>
                                                                snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const SizedBox
                                                                .shrink();
                                                          }
                                                          if (snapshot
                                                              .hasError) {
                                                            return const Text(
                                                              'Something went wrong',
                                                            );
                                                          }
                                                          if (!snapshot
                                                                  .hasData ||
                                                              snapshot
                                                                  .data!
                                                                  .docs
                                                                  .isEmpty) {
                                                            return const Text(
                                                              '',
                                                            );
                                                          }
                                                          final lastMessage =
                                                              snapshot.data!
                                                                  .docs.first;
                                                          final timestamp = lastMessage[
                                                                      'timestamp']
                                                                  as Timestamp? ??
                                                              Timestamp.now();
                                                          final formattedTime =
                                                              DateFormat.jm()
                                                                  .format(timestamp
                                                                      .toDate());
                                                          final messageText =
                                                              lastMessage[
                                                                      'text'] ??
                                                                  '';

                                                          return Row(
                                                            children: [
                                                              BuildTextWidget(
                                                                text:
                                                                    messageText,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              BuildTextWidget(
                                                                text:
                                                                    formattedTime,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          width: 5,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadiusDirectional
                                                    .circular(2),
                                            color: Colors.indigo.shade400,
                                          ),
                                          child: const Text(''),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
