import 'dart:convert';

import 'package:clean_api/clean_api.dart';
import 'package:flutter/material.dart';
import 'package:handle_restapi_in_flutter/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = CleanApi.instance;
  bool loading = false;
  List<Note> notes = [];

  final noteTitleController = TextEditingController();
  final noteDescController = TextEditingController();

  int? updateId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handling Api smartly'),
      ),
      body: Column(
        children: [
          TextField(
            controller: noteTitleController,
            decoration: const InputDecoration(hintText: 'write title'),
          ),
          TextField(
            controller: noteDescController,
            decoration: const InputDecoration(hintText: 'write description'),
          ),
          if (updateId == null)
            ElevatedButton(
                onPressed: createNote, child: const Text('Create note'))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      final data = await api.put(
                          showLogs: true,
                          fromJson: (json) => json,
                          body: {
                            "id": updateId,
                            "title": noteTitleController.text,
                            "description": noteDescController.text
                          },
                          endPoint: 'updatenote');

                      data.fold((l) {
                        CleanFailureDialogue.show(context, failure: l);
                      }, (r) {
                        getNotes();
                      });
                    },
                    child: const Text('Update note')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        updateId = null;
                        noteTitleController.clear();
                        noteDescController.clear();
                      });
                    },
                    child: const Text('Cancel'))
              ],
            ),
          Expanded(
            child: Center(
              child: loading
                  ? const CircularProgressIndicator()
                  : notes.isEmpty
                      ? const Text('Sorry we do not have any data to present')
                      : ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return ListTile(
                              trailing: InkWell(
                                  onTap: () async {
                                    await api.delete(
                                        fromJson: (json) => json,
                                        showLogs: true,
                                        body: {"id": note.id},
                                        endPoint: 'deletenote');
                                    getNotes();
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                              leading: InkWell(
                                  onTap: () {
                                    setState(() {
                                      updateId = note.id;
                                      noteTitleController.text = note.title;
                                      noteDescController.text =
                                          note.description;
                                    });
                                  },
                                  child: const Icon(Icons.edit)),
                              title: Text('${note.id}. ${note.title}'),
                              subtitle: Text(note.description),
                            );
                          }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getNotes,
        child: const Icon(Icons.send_rounded),
      ),
    );
  }

  Future<void> getNotes() async {
    setState(() {
      loading = true;
    });
    final response = await api.get(
        endPoint: 'notes',
        fromJson: (json) {
          final list = json['note'] as List;

          return List<Note>.from(
              list.map((noteData) => Note.fromMap(noteData)));
        });
    setState(() {
      loading = false;
      response.fold((l) {
        CleanFailureDialogue.show(context, failure: l);
      }, (r) {
        notes = r;
      });
    });
  }

  Future<void> createNote() async {
    if (noteTitleController.text.isNotEmpty &&
        noteDescController.text.isNotEmpty) {
      setState(() {
        loading = true;
      });

      final response = await api.post(
          fromJson: (json) => json,
          showLogs: true,
          body: {
            "title": noteTitleController.text,
            "description": noteDescController.text
          },
          endPoint: 'newnote');

      // final response = await http.post(
      //     Uri.parse(
      //       '$baseUrl/newnote',
      //     ),
      //     body: {
      //       "title": noteTitleController.text,
      //       "description": noteDescController.text
      //     },
      //     headers: header);

      setState(() {
        loading = false;
        response.fold((l) {
          CleanFailureDialogue.show(context, failure: l);
        }, (r) {
          getNotes();
        });
      });
    }
  }
}
