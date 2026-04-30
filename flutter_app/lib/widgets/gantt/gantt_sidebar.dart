import 'package:flutter/material.dart';
import '../../models/task.dart';

class GanttSidebar extends StatelessWidget {
  final List<Task> tasks;
  final ScrollController scrollController;

  static const rowHeight = 40.0;
  static const headerHeight = 44.0;

  const GanttSidebar({
    super.key,
    required this.tasks,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        Theme.of(context).colorScheme.outline.withOpacity(0.15);
    return Column(
      children: [
        Container(
          height: headerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            'ACTIVITY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemExtent: rowHeight,
            itemBuilder: (context, i) {
              final task = tasks[i];
              return Container(
                height: rowHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: borderColor),
                    bottom: BorderSide(color: borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${task.progress}%',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.45),
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
