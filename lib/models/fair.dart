class Fair {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final String startDate;
  final String endDate;
  final String schedule;
  final String location;
  final String imageUrl;
  final String contactWhatsApp;
  final String entryFee;
  final bool isFinished;

  Fair({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    this.startDate = '',
    this.endDate = '',
    required this.schedule,
    required this.location,
    required this.imageUrl,
    required this.contactWhatsApp,
    required this.entryFee,
    this.isFinished = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer,
      'startDate': startDate,
      'endDate': endDate,
      'schedule': schedule,
      'location': location,
      'imageUrl': imageUrl,
      'contactWhatsApp': contactWhatsApp,
      'entryFee': entryFee,
      'isFinished': isFinished,
    };
  }

  factory Fair.fromMap(Map<String, dynamic> map) {
    return Fair(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      organizer: map['organizer'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      schedule: map['schedule'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      contactWhatsApp: map['contactWhatsApp'] ?? '',
      entryFee: (map['entryFee'] ?? '').toString(),
      isFinished: map['isFinished'] ?? false,
    );
  }
}
