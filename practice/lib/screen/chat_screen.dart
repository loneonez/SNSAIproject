import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<void> askGemini() async {
    const apikey = "AIzaSyAsXpi7IBGIJLZ63cltS1s3IiT6d0P226I";
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apikey);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                width: width * 0.8,
                height: height * 0.1,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
