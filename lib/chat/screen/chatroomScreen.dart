import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app1/chat/firestorechat.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUsername;
  final String otherProfile;

  const ChatRoomScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUsername,
    required this.otherProfile,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreChatService _chatService = FirestoreChatService();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (DateFormat('yyyy-MM-dd').format(now) ==
        DateFormat('yyyy-MM-dd').format(date)) {
      return '今天';
    } else if (DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1))) ==
        DateFormat('yyyy-MM-dd').format(date)) {
      return '昨天';
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  @override
  void initState() {
    super.initState();
    _chatService.markMessagesAsRead(
      fromUid: widget.currentUserId,
      toUid: widget.otherUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.otherProfile),
            ),
            const SizedBox(width: 10),
            Text(widget.otherUsername),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getChatMessages(
                widget.currentUserId,
                widget.otherUserId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                String? lastDate;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['from'] == widget.currentUserId;
                    final time = (msg['timestamp'] as Timestamp).toDate();
                    final formattedTime = DateFormat('HH:mm').format(time);
                    final read = msg['read'] == true;
                    final dateLabel = _formatDate(time);

                    Widget? dateHeader;
                    if (lastDate != dateLabel) {
                      lastDate = dateLabel;
                      dateHeader = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (dateHeader != null) dateHeader,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(widget.otherProfile),
                                  ),
                                ),
                              if (!isMe) const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.blue[100]
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        msg['text'] ?? '',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (isMe) const SizedBox(width: 6),
                                        if (isMe)
                                          Icon(
                                            read
                                                ? Icons.done_all
                                                : Icons.check,
                                            size: 16,
                                            color: read
                                                ? Colors.blueAccent
                                                : Colors.grey[600],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '輸入訊息...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _textController.text.trim();
                    if (text.isEmpty) return;
                    _textController.clear();
                    await _chatService.sendMessage(
                      toUid: widget.otherUserId,
                      text: text,
                    );
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent + 100,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}