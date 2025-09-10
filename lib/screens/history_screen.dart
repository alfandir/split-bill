import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List<FileObject> files = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response =
          await supabase.storage.from('splitbills').list(path: 'bills');
      setState(() {
        files = response;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error load history: $e");
      setState(() => loading = false);
    }
  }

  Future<String> _getPublicUrl(String path) async {
    return supabase.storage.from('splitbills').getPublicUrl(path);
  }

  Future<void> _openFile(String path) async {
    final url = await _getPublicUrl(path);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka link")),
      );
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      await supabase.storage.from('splitbills').remove([path]);
      setState(() {
        files.removeWhere((f) => f.name == path.split('/').last);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File berhasil dihapus")),
      );
    } catch (e) {
      debugPrint("Error delete: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghapus file")),
      );
    }
  }

  void _showFileActions(String filename) async {
    final path = "bills/$filename";
    final url = await _getPublicUrl(path);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 12,
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Colors.blue),
                title: const Text("Buka File"),
                onTap: () {
                  Navigator.pop(context);
                  _openFile(path);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.indigo),
                title: const Text("Copy Link"),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Link disalin ke clipboard")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text("Share ke WhatsApp"),
                onTap: () async {
                  final waUrl = Uri.parse(
                    "https://wa.me/?text=${Uri.encodeComponent(url)}",
                  );
                  Navigator.pop(context);
                  if (await canLaunchUrl(waUrl)) {
                    await launchUrl(waUrl,
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.send, color: Colors.blue),
                title: const Text("Share ke Telegram"),
                onTap: () async {
                  final tgUrl = Uri.parse(
                    "https://t.me/share/url?url=${Uri.encodeComponent(url)}",
                  );
                  Navigator.pop(context);
                  if (await canLaunchUrl(tgUrl)) {
                    await launchUrl(tgUrl,
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Hapus File"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFile(path);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Split Bill"),
        elevation: 2,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? const Center(child: Text("Belum ada riwayat PDF"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final filename = file.name;
                    final createdAt =
                        file.createdAt?.toString().split('.')[0] ?? "-";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading:
                            const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: Text(filename,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Upload: $createdAt"),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showFileActions(filename),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
