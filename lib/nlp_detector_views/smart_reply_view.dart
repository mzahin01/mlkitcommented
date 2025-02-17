// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';

// Defining a StatefulWidget named SmartReplyView
class SmartReplyView extends StatefulWidget {
  @override
  State<SmartReplyView> createState() => _SmartReplyViewState();
}

// State class for SmartReplyView
class _SmartReplyViewState extends State<SmartReplyView> {
  // Controllers for text fields
  final _localUserController = TextEditingController();
  final _remoteUserController = TextEditingController();

  // Variable to hold smart reply suggestions
  SmartReplySuggestionResult? _suggestions;

  // Instance of SmartReply
  final SmartReply _smartReply = SmartReply();

  // Dispose method to clean up resources
  @override
  void dispose() {
    _smartReply.close(); // Close the SmartReply instance
    super.dispose();
  }

  // Build method to create the UI
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Reply'), // App bar title
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus(); // Unfocus text fields when tapping outside
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                SizedBox(height: 30), // Spacer
                Text('Local User:'), // Label for local user
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(
                      width: 2,
                    )),
                    child: TextField(
                      controller:
                          _localUserController, // Controller for local user text field
                      decoration: InputDecoration(border: InputBorder.none),
                      maxLines: null, // Allow multiple lines
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () => _addMessage(_localUserController,
                          true), // Add message for local user
                      child: Text('Add message to conversation')),
                ),
                SizedBox(height: 30), // Spacer
                Text('Remote User:'), // Label for remote user
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(
                      width: 2,
                    )),
                    child: TextField(
                      controller:
                          _remoteUserController, // Controller for remote user text field
                      decoration: InputDecoration(border: InputBorder.none),
                      maxLines: null, // Allow multiple lines
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () => _addMessage(_remoteUserController,
                          false), // Add message for remote user
                      child: Text('Add message to conversation')),
                ),
                SizedBox(height: 30), // Spacer
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_smartReply.conversation.isNotEmpty)
                        ElevatedButton(
                            onPressed: () {
                              _smartReply
                                  .clearConversation(); // Clear conversation
                              setState(() {
                                _suggestions = null; // Reset suggestions
                              });
                            },
                            child: Text('Clear conversation')),
                      ElevatedButton(
                          onPressed:
                              _suggestReplies, // Get smart reply suggestions
                          child: Text('Get Suggest Replies')),
                    ]),
                SizedBox(height: 30), // Spacer
                if (_suggestions != null)
                  Text(
                      'Status: ${_suggestions!.status.name}'), // Display suggestion status
                if (_suggestions != null &&
                    _suggestions!.suggestions.isNotEmpty)
                  for (final suggestion in _suggestions!.suggestions)
                    Text('\t $suggestion'), // Display each suggestion
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to add message to the conversation
  void _addMessage(TextEditingController controller, bool localUser) {
    FocusScope.of(context).unfocus(); // Unfocus text fields
    if (controller.text.isNotEmpty) {
      if (localUser) {
        _smartReply.addMessageToConversationFromLocalUser(controller.text,
            DateTime.now().millisecondsSinceEpoch); // Add local user message
      } else {
        _smartReply.addMessageToConversationFromRemoteUser(
            controller.text,
            DateTime.now().millisecondsSinceEpoch,
            'userZ'); // Add remote user message
      }
      controller.text = ''; // Clear text field
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Message added to the conversation'))); // Show confirmation
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message can\'t be empty'))); // Show error
    }
  }

  // Method to get smart reply suggestions
  Future<void> _suggestReplies() async {
    FocusScope.of(context).unfocus(); // Unfocus text fields
    final result = await _smartReply.suggestReplies(); // Get suggestions
    setState(() {
      _suggestions = result; // Update suggestions
    });
  }
}
