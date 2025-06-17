import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/Tasks/widget/task_widgets.dart';
import 'package:flutter_app1/Tasks/note_service.dart';

class StreamNote extends StatelessWidget {
  final bool done;
  const StreamNote(this.done, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: NoteService().streamNotes(done),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notesList = NoteService().getNotes(snapshot);

        return Column(
          children: notesList.map((note) {
            return Dismissible(
              key: UniqueKey(),
              onDismissed: (direction) {
                NoteService().deleteNote(note.id);
              },
              child: Task_Widget(note),
            );
          }).toList(),
        );
      },
    );
  }
}
