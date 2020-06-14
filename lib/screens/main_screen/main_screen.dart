import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ccrapp/models/directions_api.dart';

import 'package:ccrapp/models/place.dart';
import 'package:ccrapp/models/api.dart';

import 'package:ccrapp/components/loader.dart';
import 'package:url_launcher/url_launcher.dart';

TextStyle _lowOpacity =
    TextStyle(color: Colors.black.withAlpha(200), fontSize: 16.0);

Map<String, String> types = {
'accounting': 'contabilidade',
'airport': 'aeroporto',
'amusement park': 'Parque de diversões',
'aquarium': 'aquário',
'art_gallery': 'galeria de Arte',
'atm': 'atm',
'bakery': 'padaria',
'bank': 'banco',
'bar': 'Barra',
'beauty_salon': 'salão de beleza',
'bicycle_store': 'loja de bicicletas',
'book_store': 'livraria',
'bowling_alley': 'pista de boliche',
'bus_station': 'estação de onibus',
'cafe': 'cafeteria',
'campground': 'área de camping',
'car_dealer': 'vendedor de carros',
'car_rental': 'aluguel de carros',
'car_repair': 'reparo do carro',
'car_wash': 'lava-jato',
'casino': 'cassino',
'cemetery': 'cemitério',
'church': 'Igreja',
'city_hall': 'Câmara Municipal',
'clothing_store': 'loja de roupas',
'convenience_store': 'loja de conveniência',
'courthouse': 'tribunal',
'dentist': 'dentista',
'department_store': 'loja de departamento',
'doctor': 'médico',
'drugstore': 'Drogaria',
'electrician': 'eletricista',
'electronics store': 'loja de eletrônicos',
'embassy': 'embaixada',
'fire_station': 'Corpo de Bombeiros',
'florist': 'florista',
'funeral_home': 'casa funerária',
'furniture_store': 'loja de móveis',
'gas_station': 'posto de gasolina',
'gym': 'Academia',
'hair_care': 'cuidado capilar',
'hardware_store': 'loja de ferragens',
'hindu_temple': 'templo hindu',
'home_goods_store': 'loja de artigos para o lar',
'hospital': 'hospital',
'insurance_agency': 'agência de seguros',
'jewelry_store': 'joalheria',
'laundry': 'lavanderia',
'lawyer': 'advogado',
'library': 'biblioteca',
'light_rail_station': 'estação ferroviária',
'liquor_store': 'loja de bebidas',
'local_government_office': 'escritório do governo local',
'locksmith': 'chaveiro',
'lodging': 'alojamento',
'meal_delivery': 'entrega de refeições',
'meal_takeaway': 'comida para viagem',
'mosque': 'mesquita',
'movie_rental': 'aluguel de filmes',
'movie_theater': 'cinema',
'moving_company': 'empresa de mudanças',
'museum': 'museu',
'night_club': 'Boate',
'painter': 'pintor',
'park': 'parque',
'parking': 'estacionamento',
'pet_store': 'loja de animais',
'pharmacy': 'farmacia',
'physiotherapist': 'fisioterapeuta',
'plumber': 'encanador',
'police': 'polícia',
'post_office': 'agência dos Correios',
'primary_school': 'escola primaria',
'real_estate_agency': 'agência imobiliária',
'restaurant': 'restaurante',
'roofing_contractor': 'empreiteiro de coberturas',
'rv_park': 'rv park',
'school': 'escola',
'secondary_school': 'Ensino Médio',
'shoe_store': 'loja de sapatos',
'shopping_mall': 'Centro de compras',
'spa': 'spa',
'stadium': 'estádio',
'storage': 'armazenamento',
'store': 'loja',
'subway_station': 'estação de metrô',
'supermarket': 'supermercado',
'synagogue': 'sinagoga',
'taxi_stand': 'ponto de taxi',
'tourist_attraction': 'atração turística',
'train_station': 'estação de trem',
'transit_station': 'estação de trânsito',
'travel_agency': 'agência de viagens',
'university': 'universidade',
'veterinary_care': 'cuidados veterinários',
'zoo': 'jardim zoológico',
'administrative_area_level_1': 'Área administrativa',
'administrative_area_level_2': 'Área administrativa',
'administrative_area_level_3': 'Área administrativa',
'administrative_area_level_4': 'Área administrativa',
'administrative_area_level_5': 'Área administrativa',
'archipelago': 'arquipélago',
'colloquial_area': 'área coloquial',
'continent': 'continente',
'country': 'país',
'establishment': 'estabelecimento',
'finance': 'finança',
'floor': 'chão',
'food': 'Comida',
'general_contractor': 'empreiteiro geral',
'geocode': 'geocódigo',
'health': 'saúde',
'intersection': 'interseção',
'locality': 'localidade',
'natural_feature': 'característica natural',
'neighborhood': 'Vizinhança',
'place_of_worship': 'local de culto',
'plus_code': 'mais código',
'point_of_interest': 'ponto de interesse',
'political': 'político',
'post_box': 'caixa postal',
'postal_code': 'Código postal',
'postal_code_prefix': 'prefixo do código postal',
'postal_code_suffix': 'sufixo do código postal',
'postal_town': 'cidade postal',
'premise': 'premissa',
'room': 'sala',
'route': 'rota',
'street_address': 'Endereço',
'street_number': 'número da rua',
'sublocality': 'Sublocalidade',
'sublocality_level_1': 'Sublocalidade',
'sublocality_level_2': 'Sublocalidade',
'sublocality_level_3': 'Sublocalidade',
'sublocality_level_4': 'Sublocalidade',
'sublocality_level_5': 'Sublocalidade',
'subpremise': 'subpremise',
'town_square': 'Praça da cidade',
};

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng _defaultLatLng = LatLng(45.521563, -122.677433);
  LatLng _currentLocation;
  String _destination;

  GoogleMapController _mapController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLngBounds _bounds;
  Place _place;

  bool _loading = false;
  bool _showRatingMenu = false;

  List<Widget> windowStack = [];

  final _windowPadding = EdgeInsets.all(16.0);

  double _prevencaoSlider = 2.5;
  double _precoSlider = 2.5;
  double _servicoSlider = 2.5;
  double _esperaSlider = 2.5;
  double _segurancaSlider = 2.5;
  double _segurancaFemininaSlider = 2.5;

  @override
  void initState() {
    super.initState();

    _destination = 'Rio de Janeiro';

    getLocation();
  }

  _clearMarkers() {
    setState(() {
      _markers = {_markers.first};
    });
  }

  _clearPolylines() {
    setState(() {
      _polylines = {};
    });
  }

  _addInterestPoints() async {
    var places = await GoogleDirections().nearbyPlaces(
        '${_currentLocation.latitude},${_currentLocation.longitude}', '5000');

    Set<Marker> newMarkers = {};
    places.forEach((place) {
      newMarkers.add(Marker(
        markerId: MarkerId(place['place_id']),
        position: LatLng(place['geometry']['location']['lat'],
            place['geometry']['location']['lng']),
        onTap: () {
          _showPlaceInfo(place['place_id']);
        },
      ));
    });

    setState(() {
      _markers = {..._markers, ...newMarkers};
    });
  }

  _showPlaceInfo(placeId) async {
    setState(() {
      _loading = true;
    });

    var info = await GoogleDirections().placeInfo(placeId);

    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth-token');

    var ratingInfo = await Api().get(route: '/place/$placeId', headers: {
      'x-auth': token,
    });

    var ratings = {
      'prevencao': ratingInfo != null ? ratingInfo['body']['prevencao'] : null,
      'preco': ratingInfo != null ? ratingInfo['body']['preco'] : null,
      'servico': ratingInfo != null ? ratingInfo['body']['servico'] : null,
      'espera': ratingInfo != null ? ratingInfo['body']['espera'] : null,
      'seguranca': ratingInfo != null ? ratingInfo['body']['seguranca'] : null,
      'segurancaFeminina':
          ratingInfo != null ? ratingInfo['body']['segurancaFeminina'] : null
    };

    setState(() {
      _loading = false;
      _place = Place(
        id: placeId,
        name: info['name'],
        rating: info['rating'] != null ? info['rating'].toString() : null,
        formatted_phone_number: info['formatted_phone_number'],
        open_now: info['opening_hours'] != null
            ? info['opening_hours']['open_now']
            : null,
        types: info['types'],
        website: info['website'],
        prevencao: ratings['prevencao'].toString(),
        preco: ratings['preco'].toString(),
        servico: ratings['servico'].toString(),
        espera: ratings['espera'].toString(),
        seguranca: ratings['seguranca'].toString(),
        segurancaFeminina: ratings['segurancaFeminina'].toString(),
      );
    });
  }

  route() async {
    setState(() {
      _loading = true;
    });

    var current = '${_currentLocation.latitude},${_currentLocation.longitude}';
    var points = await GoogleDirections().route(current, _destination);

    var latLngPoints =
        points.map((e) => LatLng(e.latitude, e.longitude)).toList();

    _clearMarkers();
    _clearPolylines();
    setState(() {
      _bounds = boundsFromLatLngList(latLngPoints);
      _loading = false;

      _markers.add(
        Marker(
          markerId: MarkerId('1'),
          position: latLngPoints.last,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );

      _polylines.add(
        Polyline(
          polylineId: PolylineId('$current+$_destination'),
          points: latLngPoints,
          color: Colors.red,
          width: 7,
        ),
      );

      _addInterestPoints();
    });
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(_bounds, 30));
    await Future.delayed(Duration(seconds: 2));
    _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_polylines.first.points.first, 16.0));
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  getLocation() async {
    setState(() {
      _loading = true;
    });

    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print('service not enabled');
        setState(() {
          _loading = false;
          _currentLocation = _defaultLatLng;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('permission denied');
        setState(() {
          _currentLocation = _defaultLatLng;
          _loading = false;
        });
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      _loading = false;
      _currentLocation =
          LatLng(_locationData.latitude, _locationData.longitude);

      _markers.add(Marker(
        markerId: MarkerId('0'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ));
      return;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Widget _buildInfoWindow() {
    var open_now = null;
    if (_place.open_now != null) {
      if (_place.open_now)
        open_now = 'Aberto agora';
      else
        open_now = 'Fechado agora';
    }

    print('type');
    print(_place.types.first);
    return Container(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: _windowPadding,
          height: MediaQuery.of(context).size.height / 2.5,
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _place.name,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Color(0xFF323232)),
                        ),
                        if (open_now != null)
                          SizedBox(
                            height: 8.0,
                          ),
                        if (open_now != null)
                          Text(
                            open_now,
                            style: _lowOpacity,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.store,
                                size: 26.0,
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                types[_place.types.first],
                                style: _lowOpacity,
                              )
                            ],
                          ),
                        ),
                        if (_place.rating != null)
                          SizedBox(
                            width: 16.0,
                          ),
                        if (_place.rating != null)
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.star,
                                  color: Colors.green,
                                  size: 32.0,
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Text(
                                  _place.rating,
                                  style: _lowOpacity,
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  _buildRatingTile(
                      'Prevenção', Icons.local_hospital, _place.prevencao),
                  _buildRatingTile('Preço', Icons.attach_money, _place.preco),
                  _buildRatingTile(
                      'Serviço', Icons.room_service, _place.servico),
                  _buildRatingTile('Espera', Icons.access_time, _place.espera),
                  _buildRatingTile(
                      'Segurança', Icons.warning, _place.seguranca),
                  _buildRatingTile('Segurança Feminina', Icons.report_problem,
                      _place.segurancaFeminina),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (_place.formatted_phone_number != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Telefone'),
                        SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.phone),
                            Text(_place.formatted_phone_number),
                          ],
                        ),
                      ],
                    ),
                  if (_place.website != null)
                    Column(
                      children: <Widget>[
                        Text('Site'),
                        IconButton(
                          icon: Icon(Icons.language),
                          onPressed: () async {
                            final url = _place.website;
                            if (await canLaunch(url)) {
                              await launch(url);
                            }
                          },
                        ),
                      ],
                    )
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.yellow,
                    child: Text('Avaliar local'),
                    onPressed: () {
                      setState(() {
                        _showRatingMenu = true;
                      });
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingTile(title, icon, rating) {
    var iconColor;
    if (rating == null || rating == 'null') {
      iconColor = Colors.black.withAlpha(200);
      rating = '--';
    } else {
      rating = double.parse(double.parse(rating).toStringAsFixed(1));
      if (rating < 2.0)
        iconColor = Color.fromARGB(255, 250, 33, 33);
      else if (rating < 4.0)
        iconColor = Color.fromARGB(255, 253, 165, 18);
      else
        iconColor = Color.fromARGB(255, 34, 168, 36);
    }

    return Expanded(
      flex: 1,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(rating.toString(), style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  _sendRating(placeId) async {
    setState(() {
      _loading = true;
    });

    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth-token');

    var result = await Api().post(route: '/place/$placeId/rating', headers: {
      'x-auth': token
    }, body: {
      'prevencao': _prevencaoSlider.toString(),
      'preco': _precoSlider.toString(),
      'servico': _servicoSlider.toString(),
      'espera': _esperaSlider.toString(),
      'seguranca': _segurancaSlider.toString(),
      'segurancaFeminina': _segurancaFemininaSlider.toString(),
    });

    setState(() {
      _showRatingMenu = false;
      _loading = false;
    });

    var msg;
    if (result == null)
      msg = 'Falha ao registrar avaliação';
    else {
      msg = 'Avaliação registrada com sucesso!';
      setState(() {
        _showPlaceInfo(placeId);
      });
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(msg),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    if (_currentLocation != null) {
      var map = GoogleMap(
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 15.00,
        ),
        onMapCreated: onMapCreated,
        onTap: (latLng) {
          if (_place != null) {
            setState(() {
              _place = null;
            });
          }
        },
      );
      widgets.add(map);

      if (_place != null) {
        var infoWindow = _buildInfoWindow();

        widgets.add(infoWindow);
      }

      var searchBar = Container(
        padding: _windowPadding,
        child: Align(
          alignment: Alignment.topCenter,
          child: TextFormField(
            decoration: new InputDecoration(
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(10.0),
                ),
              ),
              filled: true,
              hintText: "Ex: Niterói, RJ",
              labelText: 'Aonde você quer ir?',
              fillColor: Colors.white70,
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  route();
                },
              ),
            ),
            onChanged: (v) {
              v = v.trim();
              setState(() {
                _destination = v;
              });
            },
          ),
        ),
      );
      widgets.add(searchBar);

      if (_showRatingMenu) {
        var ratingMenu = Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withAlpha(80),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0)),
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 1.5,
              child: ListView(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showRatingMenu = false;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Prevenção'),
                      Slider(
                        min: 0,
                        max: 5,
                        value: _prevencaoSlider,
                        label: '$_prevencaoSlider',
                        onChanged: (val) {
                          setState(() {
                            _prevencaoSlider = val;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Preço'),
                      Slider(
                        min: 0,
                        max: 5,
                        value: _precoSlider,
                        label: '$_precoSlider',
                        onChanged: (val) {
                          setState(() {
                            _precoSlider = val;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Serviço'),
                      Slider(
                        min: 0,
                        max: 5,
                        value: _servicoSlider,
                        label: '$_servicoSlider',
                        onChanged: (val) {
                          setState(() {
                            _servicoSlider = val;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Espera'),
                      Slider(
                        min: 0,
                        max: 5,
                        value: _esperaSlider,
                        label: '$_esperaSlider',
                        onChanged: (val) {
                          setState(() {
                            _esperaSlider = val;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Segurança'),
                      Slider(
                        min: 0,
                        max: 5,
                        value: _segurancaSlider,
                        label: '$_segurancaSlider',
                        onChanged: (val) {
                          setState(() {
                            _segurancaSlider = val;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(width: 100, child: Text('Segurança Feminina')),
                      Slider(
                        min: 0,
                        max: 5,
                        value: _segurancaFemininaSlider,
                        label: '$_segurancaFemininaSlider',
                        onChanged: (val) {
                          setState(() {
                            _segurancaFemininaSlider = val;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  RaisedButton(
                    color: Colors.yellow,
                    child: Text('Enviar'),
                    onPressed: () {
                      _sendRating(_place.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        widgets.add(ratingMenu);
      }
    }

    if (_loading)
      widgets.add(Loader(
        fullScreen: true,
      ));

    return Stack(
      children: widgets,
    );
  }
}
