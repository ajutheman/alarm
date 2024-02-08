import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class WeatherContainer extends StatefulWidget {
  final String apiKey;

  WeatherContainer({required this.apiKey});

  @override
  _WeatherContainerState createState() => _WeatherContainerState();
}

class _WeatherContainerState extends State<WeatherContainer> {
  late WeatherFactory ws;
  List<Weather> _data = [];
  AppState _state = AppState.NOT_DOWNLOADED;
  double? lat, lon;

  @override
  void initState() {
    super.initState();
    ws = WeatherFactory(widget.apiKey);
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        lat = position.latitude;
        lon = position.longitude;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void queryForecast() async {
    if (lat == null || lon == null) {
      print('Latitude or longitude is null');
      return;
    }

    setState(() {
      _state = AppState.DOWNLOADING;
    });

    List<Weather> forecasts = await ws.fiveDayForecastByLocation(lat!, lon!);
    setState(() {
      _data = forecasts;
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  void queryWeather() async {
    if (lat == null || lon == null) {
      print('Latitude or longitude is null');
      return;
    }

    setState(() {
      _state = AppState.DOWNLOADING;
    });

    Weather weather = await ws.currentWeatherByLocation(lat!, lon!);
    setState(() {
      _data = [weather];
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  Widget contentFinishedDownload() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _data.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_data[index].toString()),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  Widget contentDownloading() {
    return Container(
      margin: EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Fetching Weather...',
            style: TextStyle(fontSize: 10),
          ),
          SizedBox(height: 5),
          CircularProgressIndicator(strokeWidth: 4),
        ],
      ),
    );
  }

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            ' download the Weather forecast',
          ),
        ],
      ),
    );
  }

  Widget _resultView() {
    switch (_state) {
      case AppState.FINISHED_DOWNLOADING:
        return contentFinishedDownload();
      case AppState.DOWNLOADING:
        return contentDownloading();
      default:
        return contentNotDownloaded();
    }
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 29,
          margin: EdgeInsets.all(5),
          child: TextButton(
            child: Text(
              'Fetch weather',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: lat != null && lon != null ? queryWeather : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
          ),
        ),
        Container(
          height: 29,
          margin: EdgeInsets.all(5),
          child: TextButton(
            child: Text(
              'Fetch forecast',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: lat != null && lon != null ? queryForecast : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buttons(),
        SizedBox(height: 1),
        Text(
          'Output:',
          style: TextStyle(fontSize: 5),
        ),
        Divider(
          height: 5.0,
          thickness: 2.0,
        ),
        Expanded(child: _resultView()),
      ],
    );
  }
}

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }
