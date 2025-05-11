import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({super.key});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  List<Map<String, dynamic>> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.22,
      minChildSize: 0.17,
      maxChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Material(
              color: isDark ? theme.cardColor : Colors.grey[100],
              elevation: 2,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (text) {
                  if (text.isEmpty) {
                    setState(() => _suggestions.clear());
                  } else {
                    _getSuggestions(text);
                  }
                },
                onSubmitted: (text) {
                  if (_suggestions.isNotEmpty) {
                    final placeId = _suggestions.first['place_id'];
                    _getPlaceDetails(placeId).then((coords) {
                      if (!mounted) return;
                      Navigator.of(context).pushNamed('/overview', arguments: {
                        'address': _suggestions.first['address'],
                        'coordinates': coords,
                      });
                    });
                  }
                },
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Rechercher une destination...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(Icons.search, color: theme.hintColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: theme.hintColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _suggestions.clear());
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _suggestions.isEmpty
                  ? Center(
                child: Text(
                  'Saisir un lieu pour obtenir des suggestions',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: theme.hintColor),
                ),
              )
                  : ListView.separated(
                controller: scrollController,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  color: theme.dividerColor,
                  height: 1,
                ),
                itemBuilder: (_, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: Icon(Icons.location_on_outlined,
                        color: theme.iconTheme.color),
                    title: Text(suggestion['address'],
                        style: theme.textTheme.bodyLarge),
                    onTap: () async {
                      final coords =
                      await _getPlaceDetails(suggestion['place_id']);
                      if (!mounted) return;
                      Navigator.of(context).pushNamed(
                        '/overview',
                        arguments: {
                          'address': suggestion['address'],
                          'coordinates': coords,
                        },
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 2 || apiKey == null) return;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:FR&language=fr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final newSuggestions = (data['predictions'] as List)
              .map((p) => {
            'address': p['description'],
            'place_id': p['place_id'],
          })
              .toList();
          if (mounted) {
            setState(() => _suggestions = newSuggestions);
            if (newSuggestions.isNotEmpty && _draggableController.isAttached) {
              await _draggableController.animateTo(
                0.4,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }

        }
      }
    } catch (e) {
      debugPrint('Erreur suggestions: $e');
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        if (data['status'] == 'OK') {
          return {
            "lat": data['result']['geometry']['location']['lat'],
            "lon": data['result']['geometry']['location']['lng'],
          };
        }


      }
    } catch (e) {
      debugPrint('Erreur détails: $e');
    }
    return {};
  }
}
