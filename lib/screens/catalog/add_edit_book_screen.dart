import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';

/// Add-book mode when [book] is null, edit mode otherwise. Any signed-in
/// user can reach this screen — there is no separate admin role.
class AddEditBookScreen extends StatefulWidget {
  final Book? book;
  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookService = BookService();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _genreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _copiesController;

  bool _saving = false;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _isbnController = TextEditingController(text: b?.isbn ?? '');
    _genreController = TextEditingController(text: b?.genre ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _copiesController =
        TextEditingController(text: (b?.totalCopies ?? 1).toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final totalCopies = int.parse(_copiesController.text.trim());

      if (_isEditing) {
        final existing = widget.book!;
        // Keep availableCopies in step with any change to totalCopies,
        // without letting it exceed the new total or go negative.
        final delta = totalCopies - existing.totalCopies;
        final newAvailable =
            (existing.availableCopies + delta).clamp(0, totalCopies);

        final updated = Book(
          id: existing.id,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          isbn: _isbnController.text.trim(),
          genre: _genreController.text.trim(),
          description: _descriptionController.text.trim(),
          totalCopies: totalCopies,
          availableCopies: newAvailable,
          addedAt: existing.addedAt,
        );
        await _bookService.updateBook(updated);
      } else {
        final newBook = Book(
          id: '',
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          isbn: _isbnController.text.trim(),
          genre: _genreController.text.trim(),
          description: _descriptionController.text.trim(),
          totalCopies: totalCopies,
          availableCopies: totalCopies,
          addedAt: DateTime.now(),
        );
        await _bookService.addBook(newBook);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book saved successfully.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Book' : 'Add Book')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                      labelText: 'Author', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _isbnController,
                  decoration: const InputDecoration(
                      labelText: 'ISBN', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _genreController,
                  decoration: const InputDecoration(
                      labelText: 'Genre', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _copiesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Total copies', border: OutlineInputBorder()),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n < 1) return 'Enter a positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEditing ? 'Save Changes' : 'Add Book'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
