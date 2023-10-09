import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:daily_notes/model/note.dart';
import 'package:daily_notes/helper/note_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Atributes
  String _alertTitle = '';
  String _buttonTitle = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final NoteHelper _db = NoteHelper();
  List<Note> _notes = [];

  // Methods
  _showRegisterScreen({Note? note}) {
    if(note == null) {
      _titleController.text = '';
      _descriptionController.text = '';
      setState(() {
        _alertTitle = 'Adicionar Anotação';
        _buttonTitle = 'Salvar';
      });
    } else {
      _titleController.text = note.title!;
      _descriptionController.text = note.description!;
      setState(() {
        _alertTitle = 'Atualizar Anotação';
        _buttonTitle = 'Atualizar';
      });
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(_alertTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.text,
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o Título'
                )
              ),
              TextField(
                  keyboardType: TextInputType.text,
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Digite a Descrição'
                  )
              )
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.green)
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white
                ),
              )
            ),
            FilledButton(
                onPressed: () {
                  _saveUpdateNote(selectedNote: note);
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.green)
                ),
                child: Text(
                  _buttonTitle,
                  style: const TextStyle(
                      color: Colors.white
                  ),
                )
            )
          ],
        );
      }
    );
  }

  _retrieveNotes() async {
    List retrievedNotes = await _db.retrieveNotes();
    List<Note>? temporaryList = [];
    for( Map<String, dynamic> item in retrievedNotes) {
      Note note = Note.fromMap(item);
      temporaryList.add(note);
    }
    setState(() {
      _notes = temporaryList!;
    });
    temporaryList = null;
  }

  _saveUpdateNote({Note? selectedNote}) async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String date = DateTime.now().toString();
    if(selectedNote == null) {
      Note note = Note(title, description, date);
      await _db.saveNote(note);
    } else {
      selectedNote.title = title;
      selectedNote.description = description;
      selectedNote.date = date;
      await _db.updateNote(selectedNote);
    }

    _titleController.clear();
    _descriptionController.clear();
    _retrieveNotes();
  }

  String _dateFormat(String date) {
    initializeDateFormatting('pt_BR');
    DateFormat formater = DateFormat.yMd('pt_BR');
    DateTime convertedDate = DateTime.parse(date);
    String formatedDate = formater.format(convertedDate);
    return formatedDate;
  }

  _removeNote(int id) async {
    await _db.removeNote(id);
    _retrieveNotes();
  }

  @override
  void initState() {
    super.initState();
    _retrieveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações'),
        backgroundColor: Colors.green
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final Note note = _notes[index];
                return Card(
                  child: ListTile(
                    title: Text(note.title!),
                    subtitle: Text('${_dateFormat(note.date!)} - ${note.description!}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showRegisterScreen(note: note);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _removeNote(note.id!);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            )
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          _showRegisterScreen();
        },
      ),
    );
  }
}
