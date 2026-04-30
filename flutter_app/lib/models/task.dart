enum TaskStatus {
  todo,
  inProgress,
  done;

  String toJson() => switch (this) {
        TaskStatus.todo => 'todo',
        TaskStatus.inProgress => 'in_progress',
        TaskStatus.done => 'done',
      };

  static TaskStatus fromJson(String value) => switch (value) {
        'in_progress' => TaskStatus.inProgress,
        'done' => TaskStatus.done,
        _ => TaskStatus.todo,
      };

  String get label => switch (this) {
        TaskStatus.todo => 'To Do',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.done => 'Done',
      };
}

enum TaskPriority {
  low,
  medium,
  high;

  String toJson() => name;

  static TaskPriority fromJson(String value) => switch (value) {
        'medium' => TaskPriority.medium,
        'high' => TaskPriority.high,
        _ => TaskPriority.low,
      };

  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };
}

class Task {
  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int progress;
  final int projectId;
  final int? assigneeId;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.startDate,
    this.dueDate,
    required this.progress,
    required this.projectId,
    this.assigneeId,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: TaskStatus.fromJson(json['status'] as String? ?? 'todo'),
        priority: TaskPriority.fromJson(json['priority'] as String? ?? 'medium'),
        startDate: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'] as String)
            : null,
        dueDate: json['due_date'] != null
            ? DateTime.tryParse(json['due_date'] as String)
            : null,
        progress: json['progress'] as int? ?? 0,
        projectId: json['project_id'] as int,
        assigneeId: json['assignee_id'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
