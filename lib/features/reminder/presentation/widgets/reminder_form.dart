import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/priority_constants.dart';
import '../../domain/entities/pre_reminder_offset.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/repeat_type.dart';

/// Form terpusat untuk Tambah & Edit reminder — dipakai oleh
/// AddReminderPage dan EditReminderPage supaya tidak ada duplikasi
/// validasi/UI input (DRY). Perbedaan Add vs Edit hanya pada data
/// awal ([initial]) dan aksi tombol simpan, yang di-handle oleh caller
/// lewat [onSubmit].
class ReminderForm extends StatefulWidget {
  const ReminderForm({
    super.key,
    this.initial,
    required this.onSubmit,
  });

  final Reminder? initial;
  final void Function(Reminder reminder) onSubmit;

  @override
  State<ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _categoryController;

  late ReminderPriority _priority;
  late int _colorValue;
  late DateTime _date;
  late TimeOfDay _time;
  late RepeatType _repeatType;
  late PreReminderOffset _preOffset;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _titleController = TextEditingController(text: r?.title ?? '');
    _noteController = TextEditingController(text: r?.note ?? '');
    _categoryController = TextEditingController(text: r?.category ?? '');
    _priority = r?.priority ?? ReminderPriority.medium;
    _colorValue = r?.colorValue ?? reminderColorPalette.first;
    final due = r?.dueDateTime ?? DateTime.now().add(const Duration(hours: 1));
    _date = DateTime(due.year, due.month, due.day);
    _time = TimeOfDay(hour: due.hour, minute: due.minute);
    _repeatType = r?.repeatType ?? RepeatType.none;
    _preOffset = r?.preReminderOffset ?? PreReminderOffset.onTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  DateTime get _combinedDueDateTime => DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final reminder = Reminder(
      id: widget.initial?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      category: _categoryController.text.trim(),
      colorValue: _colorValue,
      priority: _priority,
      dueDateTime: _combinedDueDateTime,
      repeatType: _repeatType,
      preReminderOffset: _preOffset,
      isCompleted: widget.initial?.isCompleted ?? false,
      createdAt: widget.initial?.createdAt ?? now,
    );
    widget.onSubmit(reminder);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul Reminder'),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Judul tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Kategori'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Catatan'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time_outlined),
                  label: Text(_time.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Prioritas', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<ReminderPriority>(
            segments: ReminderPriority.values
                .map((p) => ButtonSegment(value: p, label: Text(p.label)))
                .toList(),
            selected: {_priority},
            onSelectionChanged: (value) =>
                setState(() => _priority = value.first),
          ),
          const SizedBox(height: 20),
          Text('Warna', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: reminderColorPalette.map((colorInt) {
              final selected = colorInt == _colorValue;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = colorInt),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(colorInt),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Pengulangan', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<RepeatType>(
            value: _repeatType,
            items: RepeatType.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (value) =>
                setState(() => _repeatType = value ?? RepeatType.none),
          ),
          const SizedBox(height: 20),
          Text('Ingatkan', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<PreReminderOffset>(
            value: _preOffset,
            items: PreReminderOffset.values
                .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                .toList(),
            onChanged: (value) =>
                setState(() => _preOffset = value ?? PreReminderOffset.onTime),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _submit,
            child: Text(widget.initial == null ? 'Simpan Reminder' : 'Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
