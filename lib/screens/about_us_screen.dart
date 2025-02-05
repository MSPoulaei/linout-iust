import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  static const githubUrl = "https://github.com/MSPoulaei/linout-iust";
  static const telegramId = "sadegh369";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Color(0xff0e6a8c),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IUST WiFi Manager',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This app helps you manage your internet account at IUST (Iran University of Science and Technology). '
              'You can view your usage statistics, IP address, and connection duration. '
              'Additionally, you can securely connect or disconnect from the internet.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'All passwords are securely encrypted to protect your sensitive information.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            Text(
              'Developer:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Mohammad Sadegh Poulaei, ', // Name
                    style: TextStyle(fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        'Telegram ID: @$telegramId', // Replace with actual Telegram ID
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue, // Link color
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url =
                            'https://t.me/$telegramId'; // Replace with actual URL
                        await launchUrl(Uri.parse(url));
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "For more information, visit our GitHub repository or contact our support team.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            // const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                await launchUrl(Uri.parse(githubUrl));
              },
              child: Text(
                githubUrl,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
