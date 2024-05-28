import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(FontAwesomeIcons.bars),
      onSelected: (String result) {
        switch (result) {
          case 'magazzino':
            // Handle 'magazzino' option
            break;
          case 'impostazioni':
            // Handle 'impostazioni' option
            break;
          case 'cazzi':
            // Handle 'cazzi' option
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'magazzino',
          child: Text('Magazzino'),
        ),
        const PopupMenuItem<String>(
          value: 'impostazioni',
          child: Text('Impostazioni'),
        ),
        const PopupMenuItem<String>(
          value: 'cazzi',
          child: Text('Cazzi'),
        ),
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Calendar Example'),
        actions: [
          MyWidget(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendarWidget(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.utc(2020, 1, 1),
            lastDate: DateTime.utc(2030, 12, 31),
          );

          if (selectedDate != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEventScreen(selectedDate: selectedDate)),
            );
          }
        },
        label: Text('Aggiungi evento'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.green,
        tooltip: 'Aggiungi un nuovo evento',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class TableCalendarWidget extends StatefulWidget {
  @override
  _TableCalendarWidgetState createState() => _TableCalendarWidgetState();
}

class _TableCalendarWidgetState extends State<TableCalendarWidget> with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late AnimationController _animationController;

  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.utc(2024, 5, 1): [
      {'name': 'Evento 1', 'time': '10:00', 'robot': 'Robot A', 'user': 'Utente 1'}
    ],
    DateTime.utc(2024, 5, 15): [
      {'name': 'Evento 2', 'time': '14:00', 'robot': 'Robot B', 'user': 'Utente 2'}
    ],
    DateTime.utc(2024, 5, 30): [
      {'name': 'Evento 3', 'time': '16:00', 'robot': 'Robot C', 'user': 'Utente 3'}
    ],
  };

  void _addEvent(DateTime date, Map<String, dynamic> event) {
    setState(() {
      if (_events[date] != null) {
        _events[date]!.add(event);
      } else {
        _events[date] = [event];
      }
    });
  }

  void _updateEvent(DateTime date, int index, Map<String, dynamic> updatedEvent) {
    setState(() {
      if (_events[date] != null) {
        _events[date]![index] = updatedEvent;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: (day) {
            return _events[day] ?? [];
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventsScreen(
                    selectedDate: selectedDay,
                    events: _events[selectedDay] ?? [],
                    onUpdateEvent: _updateEvent,
                  ),
                ),
              );
            });
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                _animationController.forward(from: 0.0);
                return Positioned(
                  bottom: 4,
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, dynamic>? event;
  final Function(DateTime, Map<String, dynamic>)? onSave;

  AddEventScreen({required this.selectedDate, this.event, this.onSave});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _eventName;
  late String _eventTime;
  late String _robotType;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _eventName = widget.event?['name'] ?? '';
    _eventTime = widget.event?['time'] ?? '';
    _robotType = widget.event?['robot'] ?? 'Robot A';
    _userName = widget.event?['user'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Aggiungi Evento' : 'Modifica Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data selezionata: ${widget.selectedDate.toLocal()}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _eventName,
                decoration: InputDecoration(
                  labelText: 'Nome dell\'evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un nome per l\'evento';
                  }
                  return null;
                },
                onSaved: (value) {
                  _eventName = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _eventTime,
                decoration: InputDecoration(
                  labelText: 'Orario dell\'evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un orario per l\'evento';
                  }
                  return null;
                },
                onSaved: (value) {
                  _eventTime = value!;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _robotType,
                decoration: InputDecoration(
                  labelText: 'Tipo di robot',
                  border: OutlineInputBorder(),
                ),
                items: ['Robot A', 'Robot B', 'Robot C']
                    .map((robot) => DropdownMenuItem(
                          child: Text(robot),
                          value: robot,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _robotType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleziona un tipo di robot';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _userName,
                decoration: InputDecoration(
                  labelText: 'Nome utente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un nome utente';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userName = value!;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final event = {
                        'name': _eventName,
                        'time': _eventTime,
                        'robot': _robotType,
                        'user': _userName,
                      };
                      if (widget.onSave != null) {
                        widget.onSave!(widget.selectedDate, event);
                      }
                      Navigator.pop(context, event);
                    }
                  },
                  child: Text('Salva evento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventsScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final Function(DateTime, int, Map<String, dynamic>) onUpdateEvent;

  EventsScreen({
    required this.selectedDate,
    required this.events,
    required this.onUpdateEvent,
  });

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _events = widget.events;
  }

  void _editEvent(int index, Map<String, dynamic> event) async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(
          selectedDate: widget.selectedDate,
          event: event,
          onSave: (date, newEvent) {
            widget.onUpdateEvent(date, index, newEvent);
          },
        ),
      ),
    );

    if (updatedEvent != null) {
      setState(() {
        _events[index] = updatedEvent;
      });
    }
  }

  void _deleteEvent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conferma'),
        content: Text('Sei sicuro di voler cancellare questo evento?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _events.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text('Conferma'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventi del giorno'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eventi del giorno ${widget.selectedDate.toLocal()}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                _events.isEmpty
                    ? Text('Nessun evento per questo giorno.')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            return Card(
                              child: ListTile(
                                title: Text(event['name'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Orario: ${event['time']}'),
                                    Text('Tipo di robot: ${event['robot']}'),
                                    Text('Nome utente: ${event['user']}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _editEvent(index, event);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteEvent(index);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          Positioned(
            bottom: 17.0, 
            right: MediaQuery.of(context).size.width / 2 - 180, 
            child: FloatingActionButton(
              onPressed: () async {
                final newEvent = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEventScreen(selectedDate: widget.selectedDate)),
                );

                if (newEvent != null) {
                  setState(() {
                    _events.add(newEvent);
                  });
                }
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

