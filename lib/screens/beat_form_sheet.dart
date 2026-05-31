import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_event.dart';
import '../blocs/beat/beat_state.dart';
import '../models/beat.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

enum BeatFormMode { create, edit }

class BeatFormSheet extends StatefulWidget {
  const BeatFormSheet._({
    required this.mode,
    this.beat,
    required this.sortOrder,
  });

  final BeatFormMode mode;
  final Beat? beat;
  final int sortOrder;

  static void showCreate(
    BuildContext context, {
    required BeatBloc beatBloc,
    required int sortOrder,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: beatBloc,
        child: BeatFormSheet._(mode: BeatFormMode.create, sortOrder: sortOrder),
      ),
    );
  }

  static void showEdit(
    BuildContext context, {
    required BeatBloc beatBloc,
    required Beat beat,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: beatBloc,
        child: BeatFormSheet._(
          mode: BeatFormMode.edit,
          beat: beat,
          sortOrder: beat.sortOrder,
        ),
      ),
    );
  }

  @override
  State<BeatFormSheet> createState() => _BeatFormSheetState();
}

class _BeatFormSheetState extends State<BeatFormSheet> {
  late final TextEditingController _nameController;
  late int _colorIndex;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final b = widget.beat;
    _nameController = TextEditingController(text: b?.name ?? '');
    _colorIndex = _indexFromHex(b?.color);
    _startTime =
        _parseTime(b?.startTime) ?? const TimeOfDay(hour: 21, minute: 0);
    _endTime = _parseTime(b?.endTime) ?? const TimeOfDay(hour: 22, minute: 30);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _indexFromHex(String? hex) {
    if (hex == null) return 5;
    final normalized = hex.toLowerCase().replaceFirst('#', '');
    const hexValues = [
      'f5b67a',
      'a18bff',
      '7ad1f5',
      'f57aa3',
      '6ce4a3',
      'ffc857',
    ];
    final idx = hexValues.indexOf(normalized);
    return idx >= 0 ? idx : 5;
  }

  TimeOfDay? _parseTime(String? t) {
    if (t == null) return null;
    final parts = t.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) return TimeOfDay(hour: h, minute: m);
    }
    return null;
  }

  String _toApiTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _displayTime(TimeOfDay t) {
    final period = t.hour < 12 ? 'AM' : 'PM';
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    return '$h:${t.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.violet,
            surface: AppColors.surface,
            onSurface: AppColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final color = beatPaletteHex[_colorIndex];
    final startTime = _toApiTime(_startTime);
    final endTime = _toApiTime(_endTime);

    setState(() => _isSubmitting = true);

    if (widget.mode == BeatFormMode.create) {
      context.read<BeatBloc>().add(
        BeatAddRequested(
          name: name,
          color: color,
          startTime: startTime,
          endTime: endTime,
          sortOrder: widget.sortOrder,
        ),
      );
    } else {
      context.read<BeatBloc>().add(
        BeatUpdateRequested(
          id: widget.beat!.id,
          name: name,
          color: color,
          startTime: startTime,
          endTime: endTime,
          isActive: widget.beat!.isActive,
        ),
      );
    }
  }

  void _delete() {
    if (widget.beat == null) return;
    context.read<BeatBloc>().add(BeatDeleteRequested(widget.beat!.id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.mode == BeatFormMode.edit;

    return BlocListener<BeatBloc, BeatState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is BeatLoaded || state is BeatError) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 40,
              offset: Offset(0, -20),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(22, 12, 22, bottom + 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title + Custom badge
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  isEdit ? 'Edit beat' : 'New beat',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isEdit)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                      decoration: BoxDecoration(
                        color: AppColors.violetSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'CUSTOM',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: AppColors.violetBright,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Name field
            const InputLabel('Name'),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              decoration: const InputDecoration(hintText: 'e.g. Wind-down'),
              autofocus: !isEdit,
            ),
            const SizedBox(height: 14),

            // Color swatches
            const InputLabel('Color'),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
              child: Row(
                children: List.generate(beatPalette.length, (i) {
                  final selected = _colorIndex == i;
                  final c = beatPalette[i];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _colorIndex = i),
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i < beatPalette.length - 1 ? 10 : 0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: c.withValues(alpha: 0.33),
                                      blurRadius: 0,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Start / End time
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Starts',
                    value: _displayTime(_startTime),
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TimeField(
                    label: 'Ends',
                    value: _displayTime(_endTime),
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: isEdit ? 'Save changes' : 'Add beat',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),

            if (isEdit) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _delete,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      'Delete beat',
                      style: TextStyle(
                        color: AppColors.hot,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: AppColors.subtle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
