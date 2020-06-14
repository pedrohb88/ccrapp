import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class GoogleDirections {

  String url = 'https://maps.googleapis.com/maps/api';
  String key = 'AIzaSyBkfHfpOchlos2McTUnflqNwOVCu37ITE4';

  Future<List<PointLatLng>> route(origin, destination) async {
    
    var query = Uri(queryParameters: {
      'key': key,
      'origin': origin,
      'destination': destination
    }).query;

    final result = await GoogleDirections().get(route: '/directions/json?$query');

    PolylinePoints polylinePoints = PolylinePoints();
    var encodedPoints = result['body']['routes'][0]['overview_polyline']['points'];
    
    return polylinePoints.decodePolyline(encodedPoints); 
  }

  Future<List<dynamic>> nearbyPlaces(location, radius) async{

     var query = Uri(queryParameters: {
      'key': key,
      'location': location,
      'radius': radius
    }).query;

    final result = await GoogleDirections().get(route: '/place/nearbysearch/json?$query');
    return result['body']['results'];
  }

  Future<Map<String, dynamic>> placeInfo(id) async {

    var query = Uri(queryParameters: {
        'key': key,
        'place_id': id,
        'fields': ['name', 'rating', 'formatted_phone_number', 'opening_hours', 'types', 'website'].join(','),
      }).query;

      print('id: $id');

      final result = await GoogleDirections().get(route: '/place/details/json?$query');
      print(result);
      return result['body']['result'];
  }

  Future<Map<String, dynamic>> get({route, headers}) async{

    var response = await http.get('$url$route', headers:headers);

    if(response.statusCode != 200) return null;

    return {
      "body": JsonDecoder().convert(response.body),
      "headers": response.headers
    };
  }
}