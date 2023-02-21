import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import "dart:math";
import 'package:path/path.dart' as path;

void main() async {
  final List<String> subredditNames = const [
    '2meirl4meirl',
    'WeWantPlates',
    'antiMLM',
    'NatureIsFuckingLit',
    'funny',
    'nevertellmetheodds',
    'iamverysmart',
    'insanepeoplefacebook',
    'oldpeoplefacebook',
    'LateStageCapitalism',
    'dataisbeautiful',
    'redditgetsdrawn',
    'aww',
    'GetMotivated',
    'wtfstockphotos',
    'food',
    'ukraine',
    'Austria',
    'wien',
    'Poetry',
    'Showerthoughts',
    'sad',
  ];

  final subreddit = subredditNames[Random().nextInt(subredditNames.length)];
  final url = 'https://www.reddit.com/r/$subreddit.json';
  print(subreddit);
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      final posts = data['data']['children'];

      final futures = <Future>[];
      for (var post in posts) {
        final url = post['data']['url'];
        if (url.endsWith('.jpg') ||
            url.endsWith('.png') ||
            url.endsWith('.gif')) {
          futures.add(downloadImage(url));
        }
      }

      await Future.wait(futures);
    } else {
      throw Exception(
          'HTTP request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

Future<void> downloadImage(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final fileName = path.basename(url);

      final directory = Directory('images');
      if (!await directory.exists()) {
        await directory.create();
      }
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      print('Downloaded $fileName.');
    } else {
      throw Exception(
          'HTTP request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('Failed to download $url: $e');
  }
}
