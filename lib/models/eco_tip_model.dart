class EcoTipModel {
  final int id;
  final String title;
  final String description;
  final String category;

  EcoTipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  factory EcoTipModel.fromJson(Map<String, dynamic> json) {
    return EcoTipModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
    };
  }
}
