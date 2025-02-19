import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetch users from Supabase
  Future<void> _fetchUsers() async {
    final response = await supabase.from('users').select();
    if (response== null) {
      setState(() {
        users = List<Map<String, dynamic>>.from(response);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching users: ${response}')));
    }
  }

  // Create a user
  Future<void> _createUser() async {
    final response = await supabase.from('users').insert([
      {'name': nameController.text, 'email': emailController.text}
    ]);
    if (response.error == null) {
      setState(() {
        users.add(response.data[0]);
      });
      nameController.clear();
      emailController.clear();
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating user: ${response.error?.message}')));
    }
  }

  // Update a user
  Future<void> _updateUser(int userId) async {
    final response = await supabase.from('users').update({
      'name': nameController.text,
      'email': emailController.text,
    }).eq('id', userId);
    if (response.error == null) {
      setState(() {
        final index = users.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          users[index]['name'] = nameController.text;
          users[index]['email'] = emailController.text;
        }
      });
      nameController.clear();
      emailController.clear();
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating user: ${response.error?.message}')));
    }
  }

  // Delete a user
  Future<void> _deleteUser(int userId) async {
    final response = await supabase.from('users').delete().eq('id', userId);
    if (response.error == null) {
      setState(() {
        users.removeWhere((user) => user['id'] == userId);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting user: ${response.error?.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createUser,
              child: const Text('Create User'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Text(user['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            nameController.text = user['name'];
                            emailController.text = user['email'];
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Update User'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(labelText: 'Name'),
                                    ),
                                    TextField(
                                      controller: emailController,
                                      decoration: const InputDecoration(labelText: 'Email'),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _updateUser(user['id']);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Update'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteUser(user['id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
