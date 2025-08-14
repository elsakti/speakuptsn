import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import '../models/report.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';

class UploadReportBasic extends StatefulWidget {
  const UploadReportBasic({super.key});

  @override
  State<UploadReportBasic> createState() => _UploadReportBasicState();
}

class _UploadReportBasicState extends State<UploadReportBasic> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ReportService _reportService = ReportService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isSubmitting = false;
  XFile? _selectedImage;
  bool _isUploadingImage = false;
  bool _enableImages = true; // Set to false to disable images

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showMessage('Failed to pick image: $e', isError: true);
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showMessage('Failed to take photo: $e', isError: true);
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // Calculate compression quality to keep under 2MB
    int quality = 85;
    Uint8List compressedBytes;
    
    do {
      compressedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      if (compressedBytes.length <= 2 * 1024 * 1024) break; // 2MB limit
      quality -= 10;
    } while (quality > 10);

    return compressedBytes;
  }

  Future<String?> _uploadImage(XFile imageFile) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final bytes = await imageFile.readAsBytes();
      final compressedBytes = await _compressImage(bytes);
      
      // Create a unique filename with timestamp
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('report_images')
          .child(fileName);

      print('Uploading to path: report_images/$fileName');
      
      final uploadTask = storageRef.putData(compressedBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Upload error details: $e');
      _showMessage('Failed to upload image: $e', isError: true);
      return null;
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_titleController.text.trim().isEmpty || 
        _descriptionController.text.trim().isEmpty) {
      _showMessage('Please fill in all required fields', isError: true);
      return;
    }

    if (_userService.currentUser == null) {
      _showMessage('User not logged in', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload image if selected and images are enabled
      String photoPath = '';
      if (_enableImages && _selectedImage != null) {
        final uploadedImageUrl = await _uploadImage(_selectedImage!);
        if (uploadedImageUrl != null) {
          photoPath = uploadedImageUrl;
        }
      }

      // Create report
      final report = Report.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        reporterId: _userService.currentUser!.id,
        photoPath: photoPath,
      );

      await _reportService.createReport(report);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        _showSuccessDialog();
      }
    } catch (e) {
      _showMessage('Failed to submit report: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          title: const Text('Report Submitted'),
          content: const Text(
            'Your report has been submitted successfully and is now under review. You will be notified once it has been verified by a teacher.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

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
        title: const Text(
          'Create Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: (_isSubmitting || _isUploadingImage) ? null : _submitReport,
            child: (_isSubmitting || _isUploadingImage)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(
                      color: Color.fromRGBO(134, 0, 146, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                const Icon(Icons.account_circle, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userService.getDisplayName(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Student Report',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Title field
            const Text(
              'Report Title *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Give your report a clear title...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 1,
            ),
            
            const SizedBox(height: 20),
            
            // Description field
            const Text(
              'Description *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Describe what happened in detail...\nโปรดอธิบายรายละเอียดเหตุการณ์...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 6,
            ),

            const SizedBox(height: 20),

            // Image section - only show if images are enabled
            if (_enableImages) ...[
              const Text(
                'Add Photo (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            if (_enableImages && _selectedImage != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.file(
                        File(_selectedImage!.path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _removeImage,
                            iconSize: 20,
                          ),
                        ),
                      ),
                      if (_isUploadingImage)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ] else if (_enableImages) ...[
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add photo',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Guidelines
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Reporting Guidelines',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Be specific and factual in your description\n'
                    '• Include relevant details like time and location\n'
                    '• Your report will be reviewed by teachers\n'
                    '• False reports may result in consequences\n'
                    '• All reports are treated confidentially',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
