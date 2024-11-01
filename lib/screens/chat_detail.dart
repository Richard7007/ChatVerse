import 'dart:convert';
import 'package:chat_app/widgets/build_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class ChatScreen extends StatefulWidget {
  const ChatScreen(
    this.uid, {
    super.key,
    required this.displayname,
    required this.photoURL,
    required this.fcmToken,
  });

  final String uid;
  final String fcmToken;
  final String displayname;
  final String photoURL;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  String? fcmToken;
  final TextEditingController _channelController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  String getConversationID(String sender, String peerID) {
    String id = sender.hashCode <= peerID.hashCode
        ? '${sender}_$peerID'
        : '${peerID}_$sender';
    print(id);
    return id;
  }

  void _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      try {
        String currentSender = FirebaseAuth.instance.currentUser!.uid;
        String conversationId = getConversationID(currentSender, widget.uid);
        await FirebaseFirestore.instance
            .collection("messages")
            .doc(conversationId)
            .collection("chat")
            .add({
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'sender': currentSender,
          'receiver': widget.uid,
        });
        String? receiverFCMToken = await getReceiverFCMToken(widget.uid);

        await FirebaseFirestore.instance
            .collection("messages")
            .doc(conversationId)
            .set({
          'lastMessage': text,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'sender': currentSender,
          'receiver': widget.uid,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<String?> getReceiverFCMToken(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data()?['fcmToken'];
    }
    return null;
  }

  Future<void> sendNotification(String receiverToken, String message,
      {String? imageUrl}) async {
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/chatapp-7ceab/messages:send');
    final accessToken = await getAccessToken();
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) {
      print('No current user ID found.');
      return;
    }
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': {
            'token': receiverToken,
            'notification': {
              'title': widget.displayname,
              'body': '${widget.displayname} $message',
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'image_url': imageUrl ?? '',
              "type": "friend_request"
            },
          },
        },
      ),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Push notification sent successfully');
    } else {
      print('Failed to send push notification: ${response.statusCode}');
    }
  }

  Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "chatapp-7ceab",
      "private_key_id": "7d5178348bfdc9ec3dfcec49f0c6aef050812691",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCrd2dXBigBgrKC\n1mCitEenkCTglRKIzawUT8OpKGPudSPHvc0LmO9Jvaq9ETYXcDQ8Ic4j8dy5pnB5\nQOaXpFOJWf6Z8qewCGTg3uuUMPPKVXb7pD1mRQqryfL1skGZHvYBnFSYgR1FhlVS\njjdQzep/GFUJTCbUnvi005x2Zgd7GFc6X+kmfBcIysLaY5mI1cfYex+UqdZsPJwU\nc0z4wxQjdcK86W3AZm5own74QtSCSMASbRNAxsNtrWK+tvtoCLcfIb8pMh7ogIZ0\n2Qbkz0F7ltQRlbyDOjY7+2ljpa3LVFLhWxvMGRgYGvAdwY4L27ncwVLQatldkBfG\nyS1tEV+JAgMBAAECggEAC5zurCoyk3JH/Nc1fE+RetEnGOl/yTGE3MCk6SlfJfYG\nZ698hQiP9wKYNG3x/UG63Ue82m+1xK0ieP6Nn5T1mMaLmTRMvyi9DFiMxAtSDPt0\n2jOUJP+6v/Um4L/N9DzwlHNYwhYckWo5D8+qAhha2s4fFEjKvc52hxNonsGSSCKQ\nI5z9g9Y3zqkN7RZvwDUybmy3tEar43FzaETcvI6kFmySCJ3YG4pMc+4rdziamXn9\nK0K9J1FdaD+id7ZJVMYzi5WpG+NtWDvfB4SdygjEivNtWRwJNMhf22FQmoupqXYX\nM4JH2UFo90A20gYpZFW7XNxaPZK8mfjnoVD1jJ97wQKBgQDF/gfh01rWR0dBqAuN\nkHvrzdTiMGAkmiNkcZefXa46KAaSXZoVEfbI/Qi6XLLBSHpUGU9iO4QDk52ZKM/t\nDzO4/9CbOn79iLHD9iuDKNwPCOe5lNAsiie3MZ6aFrW7wVoXIvGM4FyqWGHSeHuq\n8sHeVGebD8ozyzIOjT5ggLVtlQKBgQDds9uxdOeFh92srObNOJWwdg0CWidjQsGx\nztRQjUZ93xjheztPhwBfUDKwiJCCJj1jv+hgO95Gt9ulevGvWlHvyvcM7UjcQr8J\nqZvAkB+S0eNNIi4+VbjyoqJAWf6ywyq4E2DUKFZoe0p9t+cuFdhHgSNmvhxA3mlT\nJr6enXolJQKBgDcqNGADV4fkjEIK5E0pOJ3W17295MvN9paB39ETdPvXMx2M3uWH\n/864Ubo7IcMgwpS0CJ5CHuIwOvT1nhla5vpgrGrTvZY+g+kpqa39sHKv9ICMqgP+\n6lnshVhBg5kwoj1YCx1JVghQX9EYqLxUrxeXRNa7a4dK0kOjrwGMWwCRAoGBAMju\niq2Ru4fNNL6cUe4rW5d71pyMIuiWh0BkqQ58jCfmfAFYE9AnFdJMuDRBAV/D0p3G\nP5CAkhrb5clb3RHFNT+0XyYrJH7kS4oxW0UyGjuR2IV+9hRu0tmtRoo2Rl2z/tKo\nVXjTOkUlgMTiWTbue3+K7g/fO3IbYbAIDHlrVlm1AoGBALpiqvvQDZ936x5bxNfA\nLAypjWQLLe9AeF7SgL7M5fj/4ghKejdN2X22XfNuFPPXl0I+mJ+QOXTfH1V+MEcx\n6RnCFaIVQRQxWAbbJAJz4kZY5p12Irapui/J9rjDgl77oehgYCCGeUMSqywNS2ly\ndVQ3vyp5J6s6UP/ySeaDeSYQ\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-bno50@chatapp-7ceab.iam.gserviceaccount.com",
      "client_id": "103172555950989900335",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-bno50%40chatapp-7ceab.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);

    return authClient.credentials.accessToken.data;
  }

  void _showBiggerImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.indigo.shade400,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.photoURL),
                  radius: 60,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  widget.displayname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo.shade400,
        toolbarHeight: 70,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(
              right: 16,
            ),
            child: Row(
              children: [
                BackButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                GestureDetector(
                  onTap: () {
                    _showBiggerImage();
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.photoURL),
                    radius: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BuildTextWidget(
                      text: widget.displayname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const BuildTextWidget(
                      text: 'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    FlutterPhoneDirectCaller.callNumber('6238883047');
                  },
                  icon: const Icon(
                    Icons.call,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {

                  },
                  icon: const Icon(
                    Icons.video_camera_back_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
          color: Colors.black,
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("messages")
                    .doc(getConversationID(
                        FirebaseAuth.instance.currentUser!.uid, widget.uid))
                    .collection("chat")
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      var timestamp =
                          message['timestamp'] as Timestamp? ?? Timestamp.now();
                      String formattedTime =
                          DateFormat.jm().format(timestamp.toDate());
                      return Align(
                        alignment: messages[index]["sender"] ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: messages[index]["sender"] ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? Colors.indigo.shade400
                                : Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              BuildTextWidget(
                                text: message['text'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1,
                                  letterSpacing: .8,
                                ),
                              ),
                              BuildTextWidget(
                                text: formattedTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.indigo.shade400,
              height: 60,
              child: Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _sendMessage();
                        sendNotification(
                            widget.fcmToken, messageController.text);
                        messageController.clear();
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ignore_for_file: avoid_print
