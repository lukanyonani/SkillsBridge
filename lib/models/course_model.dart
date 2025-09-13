class CourseModel {
  final String image;
  final String title;
  final String instructors;
  final String courseDescription;
  final String category;
  final List<Lecture> lectures;

  CourseModel({
    required this.image,
    required this.title,
    required this.instructors,
    required this.courseDescription,
    required this.category,
    required this.lectures,
  });

  // Factory constructor for creating from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      instructors: json['instructors'] ?? '',
      courseDescription: json['courseDescription'] ?? '',
      category: json['category'] ?? '',
      lectures:
          (json['lectures'] as List<dynamic>?)
              ?.map((lectureJson) => Lecture.fromJson(lectureJson))
              .toList() ??
          [],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'instructors': instructors,
      'courseDescription': courseDescription,
      'category': category,
      'lectures': lectures.map((lecture) => lecture.toJson()).toList(),
    };
  }

  // CopyWith method for immutable updates
  CourseModel copyWith({
    String? image,
    String? title,
    String? instructors,
    String? courseDescription,
    String? category,
    List<Lecture>? lectures,
  }) {
    return CourseModel(
      image: image ?? this.image,
      title: title ?? this.title,
      instructors: instructors ?? this.instructors,
      courseDescription: courseDescription ?? this.courseDescription,
      category: category ?? this.category,
      lectures: lectures ?? this.lectures,
    );
  }

  @override
  String toString() {
    return 'CourseModel(image: $image, title: $title, instructors: $instructors, courseDescription: $courseDescription, category: $category, lectures: $lectures)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseModel &&
        other.image == image &&
        other.title == title &&
        other.instructors == instructors &&
        other.courseDescription == courseDescription &&
        other.category == category &&
        other.lectures == lectures;
  }

  @override
  int get hashCode {
    return image.hashCode ^
        title.hashCode ^
        instructors.hashCode ^
        courseDescription.hashCode ^
        category.hashCode ^
        lectures.hashCode;
  }
}

class Lecture {
  final String name;
  final String url;

  Lecture({required this.name, required this.url});

  // Factory constructor for creating from JSON
  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(name: json['name'] ?? '', url: json['url'] ?? '');
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }

  // CopyWith method
  Lecture copyWith({String? name, String? url}) {
    return Lecture(name: name ?? this.name, url: url ?? this.url);
  }

  @override
  String toString() {
    return 'Lecture(name: $name, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lecture && other.name == name && other.url == url;
  }

  @override
  int get hashCode => name.hashCode ^ url.hashCode;
}
