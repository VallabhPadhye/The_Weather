String getIcon(String url){
  List<String> parts = url.split('/');
  String extractedText = 'lib/assets/icons/${parts[parts.length - 2]}/${parts[parts.length - 1]}';
  return extractedText;
}
