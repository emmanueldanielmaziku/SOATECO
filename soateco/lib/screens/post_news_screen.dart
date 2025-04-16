import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class PostNewsScreen extends StatefulWidget {
  const PostNewsScreen({Key? key}) : super(key: key);

  @override
  State<PostNewsScreen> createState() => _PostNewsScreenState();
}

class _PostNewsScreenState extends State<PostNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _postNews() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('news_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }
    


      // Save news to Firestore
      await FirebaseFirestore.instance.collection('news').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'imageUrl': imageUrl,
        'authorId': authService.user!.uid,
        'authorEmail': authService.user!.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('News posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting news: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post News'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create News Post',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share important information with the college community',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter news title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Content field
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Enter news content',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Image picker
                Text(
                  'Add Image (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add an image',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _postNews,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Post News'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
