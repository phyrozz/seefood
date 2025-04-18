import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:seefood/models/food_item.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({super.key, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<FoodItem> foodItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _uploadImage();
  }

  @override
  void dispose() {
    foodItems.clear();
    isLoading = true;
    super.dispose();
  }

  Future<void> _uploadImage() async {
    final uri = Uri.parse('https://seefood-api.joshuamalabanan70.workers.dev/api/post');

    final mimeType = lookupMimeType(widget.imagePath) ?? 'application/octet-stream';
    final mimeTypeData = mimeType.split('/');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        widget.imagePath,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ),
    );

    try {
      setState(() {
        isLoading = true;
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> items = responseData['result']['body']['foodItems'];

        setState(() {
          foodItems = items.map((item) => FoodItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          foodItems = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        foodItems = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeeFood', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.fitHeight,
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Expanded(
              child: foodItems.isEmpty
                  ? const Center(child: Text('No food items found.'))
                  : ListView.builder(
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        final item = foodItems[index];
                        return AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOutCubic,
                          child: ExpansionTile(
                            title: Text(
                              item.food,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description),
                                if (item.otherPossibleMatches.isNotEmpty)
                                  const Text(
                                    'Tap to expand to see similar matches.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '${(item.confidence * 100).toStringAsFixed(1)}% confidence',
                            ),
                            children: item.otherPossibleMatches.map((match) {
                              return ListTile(
                                title: Text(match.food),
                                trailing: Text(
                                  '${(match.confidence * 100).toStringAsFixed(1)}% confidence',
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
