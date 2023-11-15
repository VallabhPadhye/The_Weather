import 'package:flutter/material.dart';

class WeatherForecast extends StatelessWidget {
  final String time;
  final String icon;
  final String temperature;
  final Color iconcolor;
  const WeatherForecast({
    super.key,
    required this.time,
    required this.icon,
    required this.temperature,
    required this.iconcolor,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 120,
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text(
                time,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, left: 8.0, bottom: 10.0, right: 8),
              child: Image.asset(icon, height: 32, width: 32, color: iconcolor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              child: Text(
                temperature,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SevenDaysForecast extends StatelessWidget {
  final String date;
  final String icon;
  final String temperature;
  final Color iconcolor;
  const SevenDaysForecast(
      {super.key,
      required this.date,
      required this.icon,
      required this.temperature,
      required this.iconcolor});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 120,
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text(
                date,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, left: 8.0, bottom: 10.0, right: 8),
              child: Image.asset(icon, height: 32, width: 32, color: iconcolor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              child: Text(
                temperature,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdditionalInformation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInformation(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        elevation: 0,
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Text(label,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SunRiseSet extends StatelessWidget {
  final String moment;
  final String icon;
  final String time;
  final Color iconcolor;

  const SunRiseSet({
    super.key,
    required this.moment,
    required this.icon,
    required this.time,
    required this.iconcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        child: Column(
          children: [
            Text(
              moment,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            Image.asset(
              icon,
              height: 64,
              width: 64,
              color: iconcolor,
            ),
            Text(time,
                style: const TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
