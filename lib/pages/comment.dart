import 'package:flutter/material.dart';
import '../models/report.dart';

class CommentPage extends StatelessWidget {
  final Report report;

  const CommentPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komentar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _MainPost(report: report),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, index) => const _CommentItem(),
            ),
          ),
          const Divider(height: 0),
          const _CommentInputField(),
        ],
      ),
    );
  }
}

class _MainPost extends StatelessWidget {
  final Report report;

  const _MainPost({required this.report});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: const CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(
        'Anonymous Student',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(report.title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Text(report.description),
          const SizedBox(height: 8),
          if (report.photoPath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                report.photoPath,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            report.getTimeAgo(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: const Text(
        'Siswa Lain',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Setuju! Semoga ditindak lanjuti 🙏'),
      trailing: const Icon(Icons.favorite_border, size: 18),
    );
  }
}

class _CommentInputField extends StatelessWidget {
  const _CommentInputField();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Balas komentar...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () {
              // Tambahkan aksi kirim komentar
            },
          ),
        ],
      ),
    );
  }
}
