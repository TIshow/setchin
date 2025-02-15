// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void addGoogleMapsScript(String apiKey) {
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap'
    ..type = 'text/javascript'
    ..async = true
    ..defer = true;
  html.document.body!.append(script);
}