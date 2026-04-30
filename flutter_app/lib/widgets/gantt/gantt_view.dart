import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/project.dart';
import 'gantt_painter.dart';
import 'gantt_sidebar.dart';

class GanttView extends StatefulWidget {
  final List<Task> tasks;
  final Project project;

  const GanttView({super.key, required this.tasks, required this.project});

  @override
  State<GanttView> createState() => _GanttViewState();
}

class _GanttViewState extends State<GanttView> {
  late final ScrollController _sidebarCtrl;
  late final ScrollController _chartVertCtrl;
  late final ScrollController _chartHorizCtrl;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _sidebarCtrl = ScrollController();
    _chartVertCtrl = ScrollController();
    _chartHorizCtrl = ScrollController();

    _chartVertCtrl.addListener(() {
      if (_syncing) return;
      _syncing = true;
      if (_sidebarCtrl.hasClients) {
        _sidebarCtrl.jumpTo(_chartVertCtrl.offset);
      }
      _syncing = false;
    });

    _sidebarCtrl.addListener(() {
      if (_syncing) return;
      _syncing = true;
      if (_chartVertCtrl.hasClients) {
        _chartVertCtrl.jumpTo(_sidebarCtrl.offset);
      }
      _syncing = false;
    });
  }

  @override
  void dispose() {
    _sidebarCtrl.dispose();
    _chartVertCtrl.dispose();
    _chartHorizCtrl.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _computeRange() {
    final dates = <DateTime>[];
    if (widget.project.startDate != null) dates.add(widget.project.startDate!);
    if (widget.project.endDate != null) dates.add(widget.project.endDate!);
    for (final t in widget.tasks) {
      if (t.startDate != null) dates.add(t.startDate!);
      if (t.dueDate != null) {
        dates.add(DateTime(
            t.dueDate!.year, t.dueDate!.month, t.dueDate!.day));
      }
    }
    final today = DateTime.now();
    if (dates.isEmpty) {
      return (
        today.subtract(const Duration(days: 7)),
        today.add(const Duration(days: 21)),
      );
    }
    final min = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final max = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    return (
      min.subtract(const Duration(days: 3)),
      max.add(const Duration(days: 7)),
    );
  }

  List<DateTime> _buildDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var d = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    while (!d.isAfter(e)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks to display in Gantt view',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      );
    }

    final (rangeStart, rangeEnd) = _computeRange();
    final days = _buildDays(rangeStart, rangeEnd);
    const dw = GanttPainter.dayWidth;
    const rh = GanttPainter.rowHeight;
    const hh = GanttPainter.headerHeight;
    final totalWidth = days.length * dw;
    final totalHeight = hh + widget.tasks.length * rh;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: GanttSidebar(
              tasks: widget.tasks, scrollController: _sidebarCtrl),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _chartHorizCtrl,
            child: SizedBox(
              width: totalWidth,
              child: SingleChildScrollView(
                controller: _chartVertCtrl,
                child: CustomPaint(
                  painter: GanttPainter(
                    days: days,
                    tasks: widget.tasks,
                    today: DateTime.now(),
                    isDark: isDark,
                  ),
                  size: Size(totalWidth, totalHeight),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
