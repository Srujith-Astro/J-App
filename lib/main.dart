import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class EntryPage extends StatefulWidget {
  const EntryPage({Key? key}) : super(key: key);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _gratitudeController = TextEditingController();
  final TextEditingController _dreamController = TextEditingController();

  late SharedPreferences _preferences;

  List<String> _recentEntries = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEntries();
  }

Future<void> _loadSavedEntries() async {
  _preferences = await SharedPreferences.getInstance();

  setState(() {
    _recentEntries = _preferences.getStringList('recentEntries') ?? [];
  });
}

Future<void> _saveEntry(String entry, DateTime date) async {
  final selectedDateFormatted = _getFormattedDate(date);

  final journalEntry = _journalController.text;
  final gratitudeEntry = _gratitudeController.text;
  final dreamEntry = _dreamController.text;

  final key = 'entry_$selectedDateFormatted';

  final savedEntries = _preferences.getStringList(key) ?? [];

  savedEntries.add('Journal: $journalEntry');
  savedEntries.add('Gratitude: $gratitudeEntry');
  savedEntries.add('Dream: $dreamEntry');

  await _preferences.setStringList(key, savedEntries);
}




  String _getFormattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _journalController.dispose();
    _gratitudeController.dispose();
    _dreamController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Journal'),
            TextField(
              controller: _journalController,
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            const Text('Gratitude'),
            TextField(
              controller: _gratitudeController,
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            const Text('Dream'),
            TextField(
              controller: _dreamController,
              maxLines: 5,
            ),
            
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final journalEntry = _journalController.text;
          final gratitudeEntry = _gratitudeController.text;
          final dreamEntry = _dreamController.text;

          final entry = 'Journal: $journalEntry\nGratitude: $gratitudeEntry\nDream: $dreamEntry';

          await _saveEntry(entry, DateTime.now());

          Navigator.pop(context, entry);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class EntryDetailsPage extends StatefulWidget {
  final String entry;

  const EntryDetailsPage({Key? key, required this.entry}) : super(key: key);

  @override
  _EntryDetailsPageState createState() => _EntryDetailsPageState();
}

class _EntryDetailsPageState extends State<EntryDetailsPage> {
  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _gratitudeController = TextEditingController();
  final TextEditingController _dreamController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final entryLines = widget.entry.split('\n');
    _journalController.text = entryLines[1].substring(9);
    _gratitudeController.text = entryLines[1].substring(12);
    _dreamController.text = entryLines[1].substring(8);
  }

  @override
  void dispose() {
    _journalController.dispose();
    _gratitudeController.dispose();
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final journalEntry = _journalController.text;
    final gratitudeEntry = _gratitudeController.text;
    final dreamEntry = _dreamController.text;

    final entry = '${widget.entry.split('\n')[0]}\nJournal: $journalEntry\nGratitude: $gratitudeEntry\nDream: $dreamEntry';

    // Save the updated entry to SharedPreferences or your desired storage mechanism
    // ...

    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Journal'),
            TextField(
              controller: _journalController,
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            const Text('Gratitude'),
            TextField(
              controller: _gratitudeController,
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            const Text('Dream'),
            TextField(
              controller: _dreamController,
              maxLines: 5,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChanges,
        child: const Icon(Icons.check),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
// ...

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();

  late SharedPreferences _preferences;
  List<String> _recentEntries = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEntries();
  }

  Future<void> _loadSavedEntries() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _recentEntries = _preferences.getStringList('recentEntries') ?? [];
    });
  }

  Future<void> _saveEntries() async {
    await _preferences.setStringList('recentEntries', _recentEntries);
  }

  String _getFormattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

void _deleteEntry(int index) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final entry = _recentEntries[index];
              setState(() {
                _recentEntries.removeAt(index);
              });
              _saveEntries();

              final entryLines = entry.split('\n');
              if (entryLines.length >= 4) {
                final date = entryLines[0];
                final journalKey = 'journal_$date';
                final gratitudeKey = 'gratitude_$date';
                final dreamKey = 'dream_$date';

                await _preferences.remove(journalKey);
                await _preferences.remove(gratitudeKey);
                await _preferences.remove(dreamKey);
              }

              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}


void _openEntryDetails(String entry) {
  final entryLines = entry.split('\n');
  if (entryLines.length >= 1) {
    final date = entryLines[0];
    final key = 'entry_$date';
    final savedEntries = _preferences.getStringList(key) ?? [];

    final combinedEntry = savedEntries.join('\n');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryDetailsPage(entry: combinedEntry)),
    ).then((value) {
      if (value != null) {
        final updatedEntry = value as String;
        final index = _recentEntries.indexOf(entry);
        setState(() {
          _recentEntries[index] = date;
        });
        _saveEntries();
      }
    });
  }
}



Widget _buildHomePage() {
  return ListView.builder(
    itemCount: _recentEntries.length,
    itemBuilder: (context, index) {
      final entry = _recentEntries[index];
      final entryLines = entry.split('\n');

      if (entryLines.length >= 1) {
        final date = entryLines[0];
        final key = 'entry_$date';
        final savedEntries = _preferences.getStringList(key) ?? [];

        return GestureDetector(
          onTap: () => _openEntryDetails(entry),
          onLongPress: () => _deleteEntry(index),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  color: Colors.lightGreen[100],
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                ...savedEntries.map((entry) => Text(entry)),
              ],
            ),
          ),
        );
      } else {
        // Handle the case where entry is empty or doesn't contain valid data
        return Container();
      }
    },
  );
}




  Widget _buildCalendarPage() {
    return TableCalendar(
      firstDay: DateTime(DateTime.now().year - 1),
      lastDay: DateTime(DateTime.now().year + 1),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      onDaySelected: (date, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });

        final currentDate = DateTime.now();
        final selectedDate = DateTime(date.year, date.month, date.day);

        if (selectedDate.isBefore(currentDate)) {
          _addEntryToPastDate(selectedDate);
        }
      },
    );
  }

void _showTextInputDialog(BuildContext context) {
  final currentDateFormatted = _getFormattedDate(DateTime.now());
  final todayEntryIndex = _recentEntries.indexWhere((entry) => entry.startsWith(currentDateFormatted));

  if (todayEntryIndex >= 0) {
    _openEntryDetails(_recentEntries[todayEntryIndex]);
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryPage()),
    ).then((value) {
      if (value != null) {
        final entry = value as String;
        setState(() {
          _recentEntries.insert(0, '$currentDateFormatted\n$entry');
        });
        _saveEntries();
      }
    });
  }
}


void _addEntryToPastDate(DateTime date) async {
  final currentDateFormatted = _getFormattedDate(date);
  final key = 'entry_$currentDateFormatted';

  final savedEntries = _preferences.getStringList(key) ?? [];

  if (savedEntries.isNotEmpty) {
    final entry = savedEntries.join('\n');
    _openEntryDetails(entry);
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryPage()),
    ).then((value) {
      if (value != null) {
        final entry = value as String;
        setState(() {
          _recentEntries.insert(0, currentDateFormatted);
        });
        _saveEntries();
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          _buildCalendarPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _showCalendar = index == 1;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !_showCalendar,
        child: FloatingActionButton(
          onPressed: () {
            _showTextInputDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
