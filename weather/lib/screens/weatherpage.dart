// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/main.dart';
import 'package:weather/processing/forecastIcons.dart';
import 'package:weather/processing/secrets.dart';
import 'package:weather/processing/weatherforecast.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController textEditingController = TextEditingController();
  late Future<Map<String, dynamic>> weather;
  late String location = 'Getting Location';
  late String completeLocation;
  final credit = 'https://www.google.com';
  late Color themecolor = Colors.black;
  late SharedPreferences pref;
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;
  late bool status = true;

  void checkConnectionContinuously(){
    const Duration checkInterval  = Duration(seconds:2);

    Timer.periodic(checkInterval, (Timer timer)async {
      bool isConnected = await InternetConnectionChecker().hasConnection;
      if(isConnected == true && status == false) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
                child: Text('Connection restored',
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        fetchLocationAndCallAPI();
        weather = getWeather(location);
        status = true;
      } else if(isConnected == false && status == true){
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Center(
                  child: Text(
                'No Connection',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              )),
              backgroundColor: Colors.red,
              duration: Duration(days: 1)),
        );
        const Center(child: CircularProgressIndicator.adaptive());
        status = false;
      }

    });
  }
  Future<void> loadThemeColor() async{
    pref = await SharedPreferences.getInstance();
    int? colorValue = pref.getInt('themecolor');
    setState(() {
      themecolor = Color(colorValue ?? Colors.black.value);
    });
  }

  Future<void> saveColor(Color color) async{
    setState(() {
      themecolor = color;
    });
    await pref.setInt('themecolor', color.value);
  }
  Future<bool> _handleLocationPermission() async {
    //LocationPermissionHandler
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<Position> _getPosition() async {
    //getting current position
    await _handleLocationPermission();
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> GetAddressFromLatLong(Position position) async {
    //getting address from latitude and longitude
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    completeLocation = '${place.locality}, '
        '${place.administrativeArea}, ${place.country}, ${place.postalCode}';
    location = '${place.locality}';
    return location;
  }

  //getWeather Function
  Future<Map<String, dynamic>> getWeather(String location) async {
    // ignore: prefer_typing_uninitialized_variables
    if (kDebugMode) {
      print("location: $location");
    }
    // ignore: prefer_typing_uninitialized_variables
    late final data;
    late final http.Response result;
    try {
      result = await http.get(
        Uri.parse(
            'http://api.weatherapi.com/v1/forecast.json?key=$apikey&q=$location&days=7&aqi=yes'), //API
      );
    } catch (e) {
      throw const SocketException("No internet Connection");
    }

    if (result.statusCode == 200) {
      data = jsonDecode(result.body);
      if (kDebugMode) {
        print(result.body);
      }
      if (data.containsKey('error') && data['error']['code'] == 1006) {
        throw Exception('City not found');
      }
      return data;
    } else {
      throw Exception('City not found');
    }
  }

  Future<Map<String, dynamic>> fetchLocationAndCallAPI() async {
    String locality;
    Position position = await _getPosition();
    locality = await GetAddressFromLatLong(position);
    if (kDebugMode) {
      print("Initial Location: $completeLocation");
    }
    setState(() {
      completeLocation = locality;
      weather = getWeather(locality);
    });
    return weather;
  }

  @override
  void initState() {
    super.initState();
    checkConnectionContinuously();
    weather = fetchLocationAndCallAPI();
    loadThemeColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          location,
          style: TextStyle(
              color: themecolor, fontFamily: 'Poppins', fontSize: 24),
        ),
        leading: IconButton(
          //ChangeLocationButton
          icon: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              //Input_Dialog_Box
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Center(child: Text('Change Location', style: TextStyle(fontFamily: 'Poppins'))),

                  elevation: 50,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 6.0, right:6.0, bottom:0),
                      child: TextField(
                        controller: textEditingController,
                        decoration: const InputDecoration(
                          labelText: "Location",
                          icon: Icon(Icons.location_on),
                          helperText:
                              "For accurate location, \nplease provide detailed address.",
                        ),
                        keyboardType: TextInputType.streetAddress,
                        maxLength: 50,
                        onChanged: (value) {
                          if (textEditingController.text.startsWith(' ')) {
                            textEditingController.clear();
                          }
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 150),
                          child: IconButton(
                              onPressed: () {
                                textEditingController.clear();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.close)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8.0, bottom: 8.0),
                          child: IconButton(
                            onPressed: () {
                              if (kDebugMode) {
                                print(textEditingController.text.length);
                              }
                              if (textEditingController.text.isEmpty) {
                                Navigator.of(context).pop();
                              }
                              completeLocation = textEditingController.text;
                              if (kDebugMode) {
                                print('testing check button: $location');
                              }
                              textEditingController.clear();
                              setState(() {
                                weather = getWeather(completeLocation);
                              });
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.check),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const WeatherPage(),
                ));
              },
              icon: const Icon(Icons.my_location)),
          //RefreshButton
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getWeather(completeLocation);
                });
              },
              icon: const Icon(Icons.refresh)),
          IconButton(     //thememode - light mode and dark mode
            onPressed: () {
              final newMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
                  ? AdaptiveThemeMode.dark
                  : AdaptiveThemeMode.light;
              AdaptiveTheme.of(context).toggleThemeMode(); // Use this to toggle the theme mode.
              saveThemeMode(newMode); // Save the new theme mode.
              setState(() {
                main();
                final themeMode = AdaptiveTheme.of(context).mode;
                if(themeMode == AdaptiveThemeMode.light) {
                  themecolor = Colors.black;
                  saveColor(themecolor);
                } else {
                  themecolor = Colors.white;
                  saveColor(themecolor);
                }
              });
            },
            icon: const Icon(Icons.light_mode),
          ),
        ],
      ),

      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator.adaptive(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Loading weather Info...",
                    style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                ),
              ],
            ));
          }
          if (snapshot.hasError) {
            return const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator.adaptive(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Unable to load data, retrying...",
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
          }
          final data = snapshot.data!;
          final currentSky = data['current']['condition']['text'];
          final skyicon = data['current']['condition']['icon'];
          final forecasticon = data['forecast']['forecastday'][0]['hour'];
          final tempf = data['current']['temp_c'];
          final humidity = data['current']['humidity'];
          final windspeed = data['current']['wind_kph'];
          final pressure = data['current']['pressure_mb'];
          final aqivalue = data['current']['air_quality']['us-epa-index'];
          final winddegree = data['current']['wind_degree'];
          final winddirection = data['current']['wind_dir'];
          final clouds = data['current']['cloud'];
          final sunrise =
              data['forecast']['forecastday'][0]['astro']['sunrise'];
          final sunset = data['forecast']['forecastday'][0]['astro']['sunset'];
          final rainchance =
              data['forecast']['forecastday'][0]['day']['daily_chance_of_rain'];
          final showchance =
              data['forecast']['forecastday'][0]['day']['daily_chance_of_snow'];
          final mintemp =
              data['forecast']['forecastday'][0]['day']['mintemp_c'];
          final maxtemp =
              data['forecast']['forecastday'][0]['day']['maxtemp_c'];
          List<dynamic> forecasthours =
              data['forecast']['forecastday'][0]['hour'];
          Map<dynamic, dynamic> aqiMapper = {
            1: 'Good',
            2: 'Moderate',
            3: 'Unhealthy for Sensitive Groups',
            4: 'Unhealthy',
            5: 'Very Unhealthy',
            6: 'Hazardous',
          };
          Map<dynamic, dynamic> compassDirections = {
            'N': 'North',
            'NNE': 'North-Northeast',
            'NE': 'Northeast',
            'ENE': 'East-Northeast',
            'E': 'East',
            'ESE': 'East-Southeast',
            'SE': 'Southeast',
            'SSE': 'South-Southeast',
            'S': 'South',
            'SSW': 'South-Southwest',
            'SW': 'Southwest',
            'WSW': 'West-Southwest',
            'W': 'West',
            'WNW': 'West-Northwest',
            'NW': 'Northwest',
            'NNW': 'North-Northwest',
          };

          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Main Card
                  SizedBox(
                    width: double.infinity,
                    height: 320,
                    child: Card(
                      //card
                      elevation: 5,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '$tempf°C',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2, left: 8.0, right: 8.0),
                            child: Image.asset(getIcon(skyicon.toString()),
                                height: 64, width: 64, color: themecolor),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: .8),
                            child: Text(
                              "$currentSky", //Current Sky
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Air Quality: ${aqiMapper[aqivalue]}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SunRiseSet(
                                moment: 'Sunrise',
                                icon: "lib/assets/icons/sunriseset/sunrise.png",
                                time: sunrise,
                                iconcolor: themecolor,
                              ),
                              SunRiseSet(
                                moment: 'Sunset',
                                icon: "lib/assets/icons/sunriseset/sunset.png",
                                time: sunset,
                                iconcolor: themecolor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  const Center(
                    child: Text(
                      "Weather Forecast", //Weather Forecast
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  //24 Hours Forecast
                  const Text(
                    "24 Hour Forecast",
                    style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 24,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return WeatherForecast(
                          time: DateFormat("hh:mm a").format(
                              DateFormat("yyyy-MM-dd HH:mm")
                                  .parse(forecasthours[index]['time'])),
                          icon: getIcon(getIcon(forecasticon[index]['condition']
                                  ['icon']
                              .toString())), //icon
                          temperature:
                              '${forecasthours[index]['temp_c'].toString()}°C',
                          iconcolor: themecolor,
                        );
                      },
                    ),
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  const Text(
                    '7 Days Forecast',
                    style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 3,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return WeatherForecast(
                          time: DateFormat("dd:MM ").format(
                              DateFormat("yyyy-MM-dd").parse(data['forecast']
                                  ['forecastday'][index]['date'])),
                          icon: getIcon(getIcon(data['forecast']['forecastday']
                                  [index]['day']['condition']['icon']
                              .toString())), //icon
                          temperature:
                              '${data['forecast']['forecastday'][index]['day']['avgtemp_c'].toString()}°C',
                          iconcolor: themecolor,
                        );
                      },
                    ),
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  //Additional Information
                  const Center(
                    child: Text(
                      'Additional Information',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  //Additional Info Cards
                  Row(
                    //row1
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AdditionalInformation(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '$humidity%',
                      ),
                      AdditionalInformation(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: '$windspeed kph'),
                      AdditionalInformation(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: '$pressure mb',
                      ),
                    ],
                  ),
                  //space in between
                  const SizedBox(height: 20),
                  //space in between
                  //Additional Info Cards
                  Row(
                    //row2
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AdditionalInformation(
                        icon: Icons.rotate_90_degrees_cw,
                        label: 'Wind Degree',
                        value: '$winddegree°',
                      ),
                      AdditionalInformation(
                          icon: Icons.compare_arrows_sharp,
                          label: 'Wind Direction',
                          value: compassDirections[winddirection]),
                      AdditionalInformation(
                        icon: Icons.cloud_done_sharp,
                        label: 'Clouds',
                        value: '$clouds%',
                      ),
                    ],
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  //Additional Info Cards
                  Row(
                    //row3
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AdditionalInformation(
                        icon: Icons.thermostat_auto,
                        label: 'Min Temp',
                        value: '$mintemp°C',
                      ),
                      AdditionalInformation(
                          icon: Icons.thermostat_rounded,
                          label: 'Max Temp',
                          value: '$maxtemp°C'),
                    ],
                  ),

                  //space in between
                  const SizedBox(height: 20),
                  //space in between

                  //Additional Info Cards
                  Row(
                    //row3
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AdditionalInformation(
                        icon: Icons.water_sharp,
                        label: 'Rain Chance',
                        value: '$rainchance %',
                      ),
                      AdditionalInformation(
                          icon: Icons.cloudy_snowing,
                          label: 'Snow Chance',
                          value: '$showchance %'),
                    ],
                  ),
                  //space in between
                  const SizedBox(height: 20),
                  //space in between
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        "Crafted with ❤ by Vallabh Padhye",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Data provided by ",
                          style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                        ),
                        Text(
                          "WeatherAPI.com",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}