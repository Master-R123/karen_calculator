import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const KarenCalculatorApp());
}

class KarenCalculatorApp extends StatelessWidget {
  const KarenCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K.A.R.E.N. Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF06090E),
        primaryColor: const Color(0xFF00F0FF),
      ),
      home: const TacticalCalculatorScreen(),
    );
  }
}

class TacticalCalculatorScreen extends StatefulWidget {
  const TacticalCalculatorScreen({super.key});

  @override
  State<TacticalCalculatorScreen> createState() => _TacticalCalculatorScreenState();
}

class _TacticalCalculatorScreenState extends State<TacticalCalculatorScreen> {
  String _expression = '';
  String _result = '0';
  bool _isScientificOpen = false;
  bool _isRad = true;
  final List<String> _history = [];

  void _onButtonPressed(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _evaluateExpression();
        }
      } else if (value == '=') {
        if (_expression.isNotEmpty && _result != 'Error') {
          _history.insert(0, '$_expression = $_result');
          _expression = _result;
        }
      } else if (value == 'RAD/DEG') {
        _isRad = !_isRad;
        _evaluateExpression();
      } else {
        _expression += value;
        _evaluateExpression();
      }
    });
  }

  void _evaluateExpression() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }
    try {
      String parsedExp = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '${math.pi}')
          .replaceAll('e', '${math.e}');

      double eval = _parseAndEval(parsedExp);
      if (eval.isNaN || eval.isInfinite) {
        _result = 'Error';
      } else {
        _result = eval % 1 == 0 ? eval.toInt().toString() : eval.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      // Keep working as user types
    }
  }

  double _parseAndEval(String exp) {
    // Basic fallback evaluator for tactical grid
    exp = exp.replaceAll(' ', '');
    if (exp.contains('+')) {
      var parts = exp.split('+');
      return parts.map(_parseAndEval).reduce((a, b) => a + b);
    }
    if (exp.contains('-') && !exp.startsWith('-')) {
      var parts = exp.split('-');
      double res = _parseAndEval(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        res -= _parseAndEval(parts[i]);
      }
      return res;
    }
    if (exp.contains('*')) {
      var parts = exp.split('*');
      return parts.map(_parseAndEval).reduce((a, b) => a * b);
    }
    if (exp.contains('/')) {
      var parts = exp.split('/');
      double res = _parseAndEval(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        res /= _parseAndEval(parts[i]);
      }
      return res;
    }
    return double.tryParse(exp) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06090E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Control Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.history, color: Color(0xFF00F0FF)),
                    onPressed: _showHistorySheet,
                  ),
                  const Text(
                    'K.A.R.E.N. TACTICAL',
                    style: TextStyle(
                      color: Color(0xFF00F0FF),
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isScientificOpen = !_isScientificOpen),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00F0FF),
                      backgroundColor: const Color(0xFF0D1520),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF00F0FF), width: 0.5),
                      ),
                    ),
                    child: Text(_isScientificOpen ? 'BASIC' : 'SCI MODE'),
                  ),
                ],
              ),
            ),

            // Display Screen
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1520),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 28,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          color: Color(0xFF00F0FF),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scientific Expandable Grid
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isScientificOpen ? 180 : 0,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildButton('sin', color: const Color(0xFF142232)),
                          _buildButton('cos', color: const Color(0xFF142232)),
                          _buildButton('tan', color: const Color(0xFF142232)),
                          _buildButton('RAD/DEG', color: const Color(0xFF142232), textColor: const Color(0xFF00F0FF)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton('ln', color: const Color(0xFF142232)),
                          _buildButton('log', color: const Color(0xFF142232)),
                          _buildButton('π', color: const Color(0xFF142232)),
                          _buildButton('e', color: const Color(0xFF142232)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton('√', color: const Color(0xFF142232)),
                          _buildButton('^', color: const Color(0xFF142232)),
                          _buildButton('(', color: const Color(0xFF142232)),
                          _buildButton(')', color: const Color(0xFF142232)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Standard Numpad Grid
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('AC', textColor: Colors.redAccent),
                      _buildButton('⌫', textColor: const Color(0xFF00F0FF)),
                      _buildButton('%', textColor: const Color(0xFF00F0FF)),
                      _buildButton('÷', textColor: const Color(0xFF00F0FF)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('×', textColor: const Color(0xFF00F0FF)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('-', textColor: const Color(0xFF00F0FF)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('+', textColor: const Color(0xFF00F0FF)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('00'),
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildButton('=', color: const Color(0xFF00F0FF), textColor: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF0D1520),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: (textColor ?? Colors.white).withOpacity(0.15),
                width: 0.5,
              ),
            ),
          ),
          onPressed: () => _onButtonPressed(label),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              const Text(
                'TACTICAL LOGS',
                style: TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: _history.isEmpty
                    ? const Center(child: Text('No calculations recorded.', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_history[index], style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
                            trailing: const Icon(Icons.copy, color: Color(0xFF00F0FF), size: 18),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: _history[index].split('=').last.trim()));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Result copied to clipboard!')),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
