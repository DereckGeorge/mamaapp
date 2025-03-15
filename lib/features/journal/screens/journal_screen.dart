import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../widgets/calendar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
  List<JournalEntry> _displayedEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      // Get entries for the month (for calendar display)
      final monthEntries =
          await _journalService.getEntriesForMonth(_userId, _selectedDate);
      // Get entries for the selected date
      final dateEntries =
          await _journalService.getEntriesForDate(_selectedDate);

      setState(() {
        // Keep all month entries for calendar display
        _entries = monthEntries;
        // Update displayed entries to show only selected date
        _displayedEntries = dateEntries;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading journals: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEntry(int journalId) async {
    try {
      await _journalService.deleteJournal(journalId.toString());
      _loadEntries(); // Reload the list after deletion
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting journal: $e')),
        );
      }
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
            try {
              await _journalService.addJournal(content);
              if (mounted) {
                Navigator.pop(context);
                _loadEntries(); // Reload the list after adding
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating journal: $e')),
                );
              }
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFFCB4172),
                  indicator: BoxDecoration(
                    color: const Color(0xFFCB4172),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(
                      height: 40,
                      text: 'Calendar',
                    ),
                    Tab(
                      height: 40,
                      text: 'Journal',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Calendar Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CalendarWidget(
                      selectedDate: _selectedDate,
                      onDateSelected: _onDateSelected,
                      datesWithEntries:
                          _entries.map((e) => e.createdAt).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_displayedEntries.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              'No entries for ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _displayedEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _displayedEntries[index];
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
                                        onPressed: () => _deleteEntry(entry.id),
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
                          child: const Text(
                            'Write on your journal today',
                            style: TextStyle(color: Colors.white),
                          ),
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
                                    onPressed: () => _deleteEntry(entry.id),
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
  bool _isSaving = false;

  Future<void> _saveEntry() async {
    if (_contentController.text.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSave(_contentController.text);
    } finally {
      setState(() => _isSaving = false);
    }
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
            onPressed: _isSaving ? null : _saveEntry,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFCB4172)),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFFCB4172),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
