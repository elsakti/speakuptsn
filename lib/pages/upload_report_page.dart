import 'package:flutter/material.dart';

class UploadReportPage extends StatefulWidget {
  const UploadReportPage({super.key});

  @override
  State<UploadReportPage> createState() => _UploadReportPageState();
}

class _UploadReportPageState extends State<UploadReportPage> {
  final TextEditingController _textController = TextEditingController();
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(Icons.close, color: Color.fromRGBO(134, 0, 146, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            icon: const Icon(Icons.send, color: Color.fromRGBO(134, 0, 146, 1)),
            onPressed: () {
              // Simpan data laporan
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "What's happening?\nเกิดอะไรขึ้น?",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(
                Icons.attach_file,
                color: Color.fromRGBO(134, 0, 146, 1),
              ),
              onPressed: () async {
                setState(() {
                  _fileName = 'contoh_file.pdf';
                });
                // Untuk upload file asli, gunakan package seperti file_picker
              },
            ),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('File: $_fileName'),
              ),
          ],
        ),
      ),
    );
  }
}
