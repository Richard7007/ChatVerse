// import 'package:chat_app/screens/login_page.dart';
// import 'package:chat_app/widgets/build_text_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../widgets/chat_model.dart';
// import 'chat_detail.dart';
//
// class HomePage extends StatefulWidget {
//   final int? index;
//   final String? content;
//   final String? idTo;
//   final String? timestamp;
//   final int? type;
//   final bool? isMessageRead;
//   final String? lastMessage;
//   final String? email;
//   final String? name;
//
//   const HomePage({super.key,
//     this.index,
//     this.content,
//     this.idTo,
//     this.lastMessage,
//     this.timestamp,
//     this.type,
//     this.isMessageRead,
//     this.email,
//     this.name});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final TextEditingController _textEditingController = TextEditingController();
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   User? currentUser;
//   List<ChatMessages> chatUsers = [];
//   String formattedDate = DateFormat.yMMMEd().format(DateTime.now());
//
//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         toolbarHeight: 100,
//         backgroundColor: Colors.indigo.shade400,
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(
//                 left: MediaQuery
//                     .of(context)
//                     .size
//                     .width / 3.5,
//               ),
//               child: const BuildTextWidget(
//                 text: 'ChatApp',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontFamily: 'Pattaya',
//                   fontSize: 38,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             iconColor: Colors.white,
//             itemBuilder: (context) =>
//             [
//               PopupMenuItem(
//                 onTap: () async {
//                   await auth.signOut();
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const LoginPage()));
//                 },
//                 child: const Row(
//                   children: [
//                     Icon(
//                       Icons.logout,
//                       color: Colors.white,
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     BuildTextWidget(
//                       text: "Logout",
//                       style: TextStyle(
//                         color: Colors.white,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//             color: const Color.fromARGB(10, 300, 165, 245),
//             elevation: 1,
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: const DecorationImage(
//             image: AssetImage('assets/images/bg.jpg'),
//             fit: BoxFit.cover,
//             opacity: 0.5,
//           ),
//           color: Colors.indigo.shade900.withOpacity(0.1),
//         ),
//         child: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 700,
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance.collection('user')
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                       if (snapshot.hasError) {
//                         return Center(
//                           child: Text('Error: ${snapshot.error}'),
//                         );
//                       }
//                       final documents = snapshot.data!.docs;
//                       Set<String> uniqueEmails = Set<String>();
//                       documents.forEach((doc) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         uniqueEmails.add(data['email']);
//                       });
//                       List<String> chatList = uniqueEmails.toList();
//
//                       return ListView.builder(
//                         itemCount: chatList.length,
//                         shrinkWrap: true,
//                         padding: const EdgeInsets.only(top: 16),
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemBuilder: (context, index) {
//                           final data = documents[index].data() as Map<
//                               String,
//                               dynamic>;
//                           final timestamp = data['timestamp'];
//                           String formattedTime = '';
//                           if (timestamp != null && timestamp is Timestamp) {
//                             final dateTime = timestamp.toDate();
//                             formattedTime = DateFormat.jm().format(dateTime);
//                           }
//                           final recieverId = data['recieverId'];
//
//                           print(data['uid']);
//                           print(data['email']);
//                           return GestureDetector(
//                             onTap: () {
//                               print('recieverId from data: $recieverId');
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) {
//                                   return ChatDetailPage(
//                                     uid: data['uid'],
//                                     email: data['email'],
//                                     documentId: data['docId'],
//                                     name: data['name'],
//                                     photoURL: data['photoURL'],
//                                     recieverId: recieverId,
//                                   );
//                                 }),
//                               );
//                             },
//                             child: Container(
//                               child: Row(
//                                 children: <Widget>[
//                               Expanded(
//                               child: Row(
//                                 children: <Widget>[
//                                 Container(
//                                 width: 5,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadiusDirectional
//                                       .circular(2),
//                                   color: Colors.indigo.shade400,
//                                 ),
//                                 child: const Text(''),
//                               ),
//                               const SizedBox(
//                                 width: 5,
//                               ),
//                               CircleAvatar(
//                                 backgroundImage: NetworkImage(data['photoURL']),
//                                 maxRadius: 25,
//                               ),
//                               const SizedBox(
//                                 width: 16,
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   color: Colors.transparent,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment
//                                         .start,
//                                     children: <Widget>[
//                                   Row(
//                                   children: [
//                                   BuildTextWidget(
//                                   text: userList[index]["name"],
//
//                                     style: TextStyle(
//                                     fontSize: 22,
//                                     color: Colors.indigo.shade400,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 BuildTextWidget(
//                                   text: formattedTime,
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 6,
//                               ),
//                               Row(
//                                 children: [
//                                   BuildTextWidget(
//                                     text: data['uid'],
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   CircleAvatar(
//                                     backgroundColor: Colors.indigo.shade400,
//                                     minRadius: 8,
//                                     child: const BuildTextWidget(
//                                       text: '2',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     width: 5,
//                                   ),
//                                 ],
//                               ),
//                               ],
//                             ),
//                           ),
//                           ),
//                           ],
//                           ),
//                           ),
//                           Container(
//                           width: 5,
//                           height: 60,
//                           decoration: BoxDecoration(
//                           borderRadius: BorderRadiusDirectional.circular(2),
//                           color: Colors.indigo.shade400,
//                           ),
//                           child: const Text(''),
//                           ),
//                           ],
//                           ),
//                           ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }