import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController(
    text: 'London',
  );
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Custom color palette
  final Color _primaryColor = Color(0xFF1A237E); // Deep indigo
  final Color _accentColor = Color(0xFF6200EE); // Vibrant purple
  final Color _backgroundColor = Color(0xFFF4F6FF); // Soft lavender background
  final Color _textColorPrimary = Color(0xFF120136); // Nearly black
  final Color _textColorSecondary = Color(0xFF4A4A4A); // Dark gray

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuart,
      ),
    );

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchWeather(_cityController.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Gradient background method
  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_backgroundColor, _backgroundColor.withOpacity(0.9)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Column(
            children: [
              
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Weather Insights",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, color: _primaryColor),
                      onPressed: () {
                        
                      },
                    ),
                  ],
                ),
              ),

              // City Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _cityController,
                    style: GoogleFonts.poppins(color: _textColorPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search for a city',
                      hintStyle: GoogleFonts.poppins(
                        color: _textColorSecondary.withOpacity(0.7),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: _accentColor),
                        onPressed: () {
                          _animationController.reset();
                          _animationController.forward();
                          Provider.of<WeatherProvider>(
                            context,
                            listen: false,
                          ).fetchWeather(_cityController.text);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              // Weather Content
              Expanded(
                child: Consumer<WeatherProvider>(
                  builder: (context, weatherProvider, child) {
                    // Loading State
                    if (weatherProvider.isLoading) {
                      return Center(
                        child: SpinKitFadingCircle(
                          color: _accentColor,
                          size: 70.0,
                        ),
                      );
                    }

                    // Error State
                    if (weatherProvider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off,
                              color: _primaryColor,
                              size: 100,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Oops! Weather Data Unavailable',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              weatherProvider.errorMessage!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: _textColorSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // No Data State
                    if (!weatherProvider.hasWeatherData) {
                      return Center(
                        child: Text(
                          'No weather information available',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: _textColorSecondary,
                          ),
                        ),
                      );
                    }

                    // Weather Data Display
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current Weather Card
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_primaryColor, _accentColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryColor.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          weatherProvider
                                              .currentWeather!
                                              .cityName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white70,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${weatherProvider.currentWeather!.temperature.toStringAsFixed(1)}°',
                                          style: GoogleFonts.poppins(
                                            fontSize: 64,
                                            fontWeight: FontWeight.w200,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              weatherProvider
                                                  .currentWeather!
                                                  .description,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Text(
                                              'Feels like ${weatherProvider.currentWeather!.feelsLike.toStringAsFixed(1)}°',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 25),

                              // Forecast Title
                              Text(
                                "5-Day Forecast",
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: _primaryColor,
                                ),
                              ),

                              SizedBox(height: 15),

                              // Forecast List
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: weatherProvider.forecastData!.length,
                                itemBuilder: (context, index) {
                                  final forecast =
                                      weatherProvider.forecastData![index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _primaryColor.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      title: Text(
                                        DateFormat(
                                          'EEE, MMM d',
                                        ).format(DateTime.parse(forecast.date)),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: _textColorPrimary,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${forecast.temperature.toStringAsFixed(1)}°',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _accentColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        forecast.description,
                                        style: GoogleFonts.poppins(
                                          color: _textColorSecondary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
