// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:digilog_clock/rain_animation.dart';
import 'package:digilog_clock/snow-animation.dart';
import 'package:digilog_clock/tick_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

enum _Element {
  background,
  dashColor,
  shadow,
}

enum TickType { second, minute, hour }

final _lightTheme = {
  _Element.background: Colors.black12,
  _Element.dashColor: Colors.deepPurple,
};

final _darkTheme = {
  _Element.background: Colors.black54,
  _Element.dashColor: Colors.white,
};

class DigilogClock extends StatefulWidget {
  const DigilogClock(this.model);

  final ClockModel model;

  @override
  _DigilogClockState createState() => _DigilogClockState();
}

class _DigilogClockState extends State<DigilogClock>
    with SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  var _temperature = '';
  var _condition = '';
  var _location = '';
  bool _is24HourFormat;
  Timer _timer;

  String weatherConditionIcon = '';
  String clockBack = 'assets/leave.jpg';
  bool showSnowfall = false;
  bool showRain = false;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigilogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _condition = widget.model.weatherString;
      _location = widget.model.location;
      _is24HourFormat = widget.model.is24HourFormat;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    switch (_condition) {
      case 'sunny':
        weatherConditionIcon = 'assets/sun.png';
        clockBack = 'assets/leave.jpg';
        showSnowfall = false;
        showRain = false;
        break;
      case 'cloudy':
        weatherConditionIcon = 'assets/cloudIcon.png';
        clockBack = 'assets/cloudylight.jpg';
        showSnowfall = false;
        showRain = false;
        break;
      case 'foggy':
        weatherConditionIcon = 'assets/foggyIcon.png';
        clockBack = 'assets/foggyback.jpg';
        showSnowfall = false;
        showRain = false;
        break;
      case 'windy':
        weatherConditionIcon = 'assets/windyIcon.png';
        clockBack = 'assets/windy.jpg';
        showSnowfall = false;
        showRain = false;
        break;
      case 'thunderstorm':
        clockBack = 'assets/thunderstorm.jpg';
        weatherConditionIcon = 'assets/stormIcon.png';
        showSnowfall = false;
        showRain = false;
        break;
      case 'snowy':
        clockBack = 'assets/snowFall.jpg';
        weatherConditionIcon = 'assets/snowfallIcon.png';
        showSnowfall = true;
        showRain = false;
        break;
      case 'rainy':
        clockBack = 'assets/rainy.jpg';
        weatherConditionIcon = 'assets/rainyIcon.png';
        showSnowfall = false;
        showRain = true;
        break;
    }

    var orientation = MediaQuery.of(context).orientation;

    return Container(
      decoration: BoxDecoration(
          image:
              DecorationImage(image: AssetImage(clockBack), fit: BoxFit.cover)),
      child: Stack(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  weatherConditionIcon,
                  width: 100,
                  height: 100,
                ),
              ),
              Positioned.fill(child: Center(child: Text(_temperature))),
            ],
          ),
          Center(
            child: Stack(
              children: <Widget>[
                Container(
                  height: orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * (3 / 5)
                      : MediaQuery.of(context).size.height * (4 / 5),
                  width: orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * (3 / 5)
                      : MediaQuery.of(context).size.height * (4 / 5),
                  decoration: BoxDecoration(
                      color: colors[_Element.background],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26.withOpacity(0.04),
                            blurRadius: 10,
                            offset: Offset(-12, 0),
                            spreadRadius: 2),
                        BoxShadow(
                            color: Colors.black26.withOpacity(0.04),
                            blurRadius: 10,
                            offset: Offset(12, 0),
                            spreadRadius: 5),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CustomPaint(
                        painter: TickPainter(
                            maxLines: 60,
                            tick: _now.second / 60,
                            color: colors[_Element.dashColor],
                            tickType: TickType.second),
                        child: CustomPaint(
                          painter: TickPainter(
                              maxLines: 12,
                              tick: _now.minute / 60,
                              color: colors[_Element.dashColor],
                              tickType: TickType.minute),
                          child: CustomPaint(
                            painter: TickPainter(
                                maxLines: 12,
                                tick: (_now.hour % 12) / 12,
                                color: colors[_Element.dashColor],
                                tickType: TickType.hour),
                            child: Container(
                              margin: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(clockBack),
                                    fit: BoxFit.cover,
                                  ),
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26.withOpacity(0.03),
                                        blurRadius: 5,
                                        spreadRadius: 8),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: FittedBox(
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      final gradient = LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.green, Colors.brown]);
                                      return gradient.createShader(
                                          Offset.zero & bounds.size);
                                    },
                                    child: Text(getCurrentTime(),
                                        style: TextStyle(
                                            letterSpacing: 1.0,
                                            color: Colors.white,
                                            fontFamily: 'Environment')),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(child: Text(_location)),
                  ))),
          showSnowfall
              ? Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SnowWidget(
                      isRunning: showSnowfall,
                      totalSnow: 100,
                      speed: 1,
                    ),
                  ),
                )
              : SizedBox(),
          showRain
              ? Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RainWidget(
                      isRunning: showRain,
                      totalSnow: 200,
                      speed: 5,
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  String getCurrentTime() {
    if (_is24HourFormat) {
      return '${_now.hour}:${_now.minute.round()}';
    }
    return '${(_now.hour.round() % 12 == 0 ? 12 : _now.hour.round() % 12)}:${_now.minute.round()} ${TimeOfDay.fromDateTime(_now).period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}
