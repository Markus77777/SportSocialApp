class Note {
  String id;
  String subtitle;
  String type; 
  DateTime? startTime;
  DateTime? endTime;
  int image;
  bool isDon;

  Note(
    this.id,
    this.subtitle,
    this.startTime,
    this.endTime,
    this.image,
    this.type,
    this.isDon,
  );
}
