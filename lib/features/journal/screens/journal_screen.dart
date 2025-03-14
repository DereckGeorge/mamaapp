import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../widgets/calendar_widget.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  DateTime _selectedDate = DateTime.now();
  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  final String _userId = 'test_user'; // In real app, get from auth service

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _journalService.getEntriesForMonth(_userId, _selectedDate);
      setState(() => _entries = entries);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    _loadEntries();
  }

  void _addNewEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _JournalEntryScreen(
          date: _selectedDate,
          onSave: (content) async {
            await _journalService.addEntry(_userId, content, _selectedDate);
            if (mounted) {
              Navigator.pop(context);
              _loadEntries();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Personal Journal',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFCB4172),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFCB4172),
            tabs: [
              Tab(text: 'Calendar'),
              Tab(text: 'Journal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Calendar Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CalendarWidget(
                    selectedDate: _selectedDate,
                    onDateSelected: _onDateSelected,
                    datesWithEntries: _entries.map((e) => e.date).toList(),
                  ),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_entries.isEmpty)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Image(
                            image: AssetImage('assets/no_entries.png'),
                            width: 200,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Journal Records',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(entry.content),
                              subtitle: Text(entry.formattedDate),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _journalService.deleteEntry(_userId, entry.id);
                                  _loadEntries();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            // Journal Tab
            _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/no_entries.png',
                          width: 200,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Write on your journal today',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _addNewEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCB4172),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Write on your journal today'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.formattedDate,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(entry.content),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      await _journalService.deleteEntry(
                                        _userId,
                                        entry.id,
                                      );
                                      _loadEntries();
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewEntry,
          backgroundColor: const Color(0xFFCB4172),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _JournalEntryScreen extends StatefulWidget {
  final DateTime date;
  final Function(String) onSave;

  const _JournalEntryScreen({
    required this.date,
    required this.onSave,
  });

  @override
  State<_JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<_JournalEntryScreen> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'What is on your mind?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_contentController.text.isNotEmpty) {
                widget.onSave(_contentController.text);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFFCB4172),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 