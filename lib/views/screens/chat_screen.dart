import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/components/constants/colors.dart';

class ChatScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const ChatScreen(
      {super.key, required this.targetUserId, required this.targetUserName});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final userId = auth.currentUser?.uid;
      final message = _messageController.text.trim();

      final chatId = (userId.hashCode <= widget.targetUserId.hashCode)
          ? '$userId-${widget.targetUserId}'
          : '${widget.targetUserId}-$userId';

      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': message,
        'senderId': userId,
        'receiverId': widget.targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        centerTitle: true,
        backgroundColor: AppColors.blueColor,
        title: Text(
          widget.targetUserName,
          style: const TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(
                    (auth.currentUser?.uid.hashCode ?? 0) <=
                            (widget.targetUserId.hashCode)
                        ? '${auth.currentUser?.uid}-${widget.targetUserId}'
                        : '${widget.targetUserId}-${auth.currentUser?.uid}',
                  )
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return doc;
                }).toList();

                return ListView.builder(
                  reverse: true, // To show messages from bottom to top
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender =
                        message['senderId'] == auth.currentUser?.uid;
                    final messageText = message['text'];
                    final backgroundColor = isSender
                        ? AppColors.blueColor
                        : AppColors.recieverColor;
                    final alignment = isSender
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start;
                    final textColor =
                        isSender ? AppColors.whiteColor : AppColors.blackColor;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: alignment,
                        children: [
                          if (!isSender) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                messageText,
                                style:
                                    TextStyle(color: textColor, fontSize: 16.0),
                              ),
                            ),
                          ],
                          if (isSender) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                messageText,
                                style:
                                    TextStyle(color: textColor, fontSize: 16.0),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: AppColors.blueColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
