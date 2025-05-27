import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../app/app.dart';

class SmoothBarVisualizer extends StatefulWidget {
  const SmoothBarVisualizer({
    Key? key,
    required this.amplitude,
    required this.startedAudio,
    this.barCount = 12,
    this.height = 100,
    this.width = 300,
    this.color,
  }) : super(key: key);

  final double? amplitude;
  final bool startedAudio;
  final int barCount;
  final double height;
  final double width;
  final Color? color;

  @override
  State<SmoothBarVisualizer> createState() => _SmoothBarVisualizerState();
}

class _SmoothBarVisualizerState extends State<SmoothBarVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;
  late List<double> _targetHeights;
  late List<double> _currentHeights;
  double _normalizedAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller for smooth transitions
    _animationController = AnimationController(
      duration: Duration(milliseconds: Constants.amplitudeCaptureRateInMilliSeconds),
      vsync: this,
    );

    // Initialize bar controllers and animations
    _barControllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 150 + (index * 20)), // Staggered timing
        vsync: this,
      ),
    );

    _targetHeights = List.filled(widget.barCount, 0.1);
    _currentHeights = List.filled(widget.barCount, 0.1);

    // Create smooth animations for each bar
    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(begin: 0.1, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic, // Smooth easing curve
        ),
      );
    }).toList();

    // Add listeners to update current heights
    for (int i = 0; i < _barAnimations.length; i++) {
      _barAnimations[i].addListener(() {
        if (mounted) {
          setState(() {
            _currentHeights[i] = _barAnimations[i].value;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SmoothBarVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amplitude != oldWidget.amplitude || 
        widget.startedAudio != oldWidget.startedAudio) {
      _updateAmplitude();
    }
  }

  void _updateAmplitude() {
    double db = widget.amplitude ?? Constants.decibleLimit;
    if (db == double.infinity || db < Constants.decibleLimit) {
      db = Constants.decibleLimit;
    }
    if (db > 0) {
      db = 0;
    }

    if (widget.startedAudio) {
      _normalizedAmplitude = 1 - (db * (1 / Constants.decibleLimit));
    } else {
      _normalizedAmplitude = 0.0;
    }

    _updateBarHeights();
  }

  void _updateBarHeights() {
    final random = math.Random();
    
    for (int i = 0; i < widget.barCount; i++) {
      // Create frequency-based distribution for more realistic effect
      double frequency = (i + 1) / widget.barCount;
      
      // Lower frequencies (bass) get more amplitude, higher frequencies get less
      double frequencyMultiplier = 1.0 - (frequency * 0.6);
      
      // Add some controlled randomness for natural variation
      double variation = (random.nextDouble() - 0.5) * 0.3;
      
      // Calculate target height with smooth falloff
      double baseHeight = _normalizedAmplitude * frequencyMultiplier;
      double targetHeight = (baseHeight + variation).clamp(0.05, 1.0);
      
      // Smooth interpolation to target height
      _targetHeights[i] = targetHeight;
      
      // Update animation target
      _barAnimations[i] = Tween<double>(
        begin: _currentHeights[i],
        end: _targetHeights[i],
      ).animate(
        CurvedAnimation(
          parent: _barControllers[i],
          curve: Curves.easeOutCubic,
        ),
      );
      
      // Start animation with slight delay for wave effect
      Future.delayed(Duration(milliseconds: i * 15), () {
        if (mounted) {
          _barControllers[i].forward(from: 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = widget.color ?? colorScheme.primary;

    return Container(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return _buildSmoothBar(index, primaryColor, colorScheme);
        }),
      ),
    );
  }

  Widget _buildSmoothBar(int index, Color primaryColor, ColorScheme colorScheme) {
    final barWidth = (widget.width / widget.barCount) * 0.6;
    final height = _currentHeights[index] * widget.height;
    
    // Create gradient colors using theme colors
    final gradientColors = [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.4),
    ];

    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      width: barWidth,
      height: height < 8 ? 8 : height, // Minimum height for visibility
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(barWidth / 2),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: gradientColors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(barWidth / 2),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              colorScheme.onPrimary.withOpacity(0.1),
              Colors.transparent,
              colorScheme.onPrimary.withOpacity(0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}