class PlantModel {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PlantModel copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreatePlantModel {
  final String name;
  final String description;
  final int quantity;

  CreatePlantModel({
    required this.name,
    required this.description,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
    };
  }
}

class UpdatePlantModel {
  final String name;
  final String description;
  final int quantity;

  UpdatePlantModel({
    required this.name,
    required this.description,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
    };
  }
}