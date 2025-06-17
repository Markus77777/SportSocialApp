class exceptions implements Exception {
  final String message;
  
  exceptions(this.message);
  
  @override
  String toString() => 'Error: $message';
}