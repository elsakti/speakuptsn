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
        leading: TextButton(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color.fromRGBO(134, 0, 146, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              alignment: Alignment.center,
            ),
            onPressed: () {
              // Simpan data laporan
              Navigator.pop(context);
            },
            child: const Text(
              'Kirim',
              style: TextStyle(
                color: Color.fromRGBO(134, 0, 146, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
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
                      hintText: "What's happening?",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Upload File'),
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
