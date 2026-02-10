class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String schedule; // e.g., "Lunes y Miércoles 18:00"
  final String location;
  final String imageUrl;
  final String contactWhatsApp; // WhatsApp number for inquiries
  final String price;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.schedule,
    required this.location,
    required this.imageUrl,
    required this.contactWhatsApp,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'schedule': schedule,
      'location': location,
      'imageUrl': imageUrl,
      'contactWhatsApp': contactWhatsApp,
      'price': price,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructor: map['instructor'] ?? '',
      schedule: map['schedule'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      contactWhatsApp: map['contactWhatsApp'] ?? '',
      price: (map['price'] ?? '').toString(),
    );
  }
}
