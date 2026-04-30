class Project {
  final int id;
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        startDate: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.tryParse(json['end_date'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
