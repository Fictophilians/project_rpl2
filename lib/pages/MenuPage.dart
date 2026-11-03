import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_rpl2/pages/AddGamePage.dart';
import 'package:project_rpl2/pages/EditGamePage.dart';
import 'package:project_rpl2/service/api.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  int currentIndex = 0;
  Map<String, dynamic>? userProfile;
  bool isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final res = await Apiservice.get('/profile');
      if (res != null && res['data'] != null) {
        if (!mounted) return;
        setState(() {
          userProfile = Map<String, dynamic>.from(res['data']);
          isProfileLoading = false;
        });

        await Apiservice.saveUserInfo(
          userProfile?['role']?.toString() ?? 'user',
          userProfile?['username']?.toString() ?? 'User',
        );
      }
    } catch (_) {
      if (mounted) setState(() => isProfileLoading = false);
    }
  }

  bool get isAdmin => userProfile?['role'] == 'admin';

  @override
  Widget build(BuildContext context) {
    final pages = [
      GamesTab(userProfile: userProfile, isAdmin: isAdmin),
      UsersTab(isAdmin: isAdmin, currentUser: userProfile),
      ProfileTab(
        userProfile: userProfile,
        isLoading: isProfileLoading,
        onProfileUpdated: loadProfile,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: pages[currentIndex],
      ),
      floatingActionButton: (currentIndex == 0 && isAdmin)
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddGamePage()),
                );
                if (result == true) {
                  setState(() {});
                }
              },
              backgroundColor: const Color(0xFF6366F1),
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Tambah Game',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(
            top: BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SalomonBottomBar(
                margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                currentIndex: currentIndex,
                onTap: (index) => setState(() => currentIndex = index),
                items: [
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.sports_esports_outlined, size: 28),
                    activeIcon: const Icon(Icons.sports_esports_rounded, size: 28),
                    title: const Text('Games'),
                    selectedColor: const Color(0xFF6366F1),
                    unselectedColor: const Color(0xFF94A3B8),
                  ),
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.group_outlined, size: 28),
                    activeIcon: const Icon(Icons.group_rounded, size: 28),
                    title: const Text('Users'),
                    selectedColor: const Color(0xFF22D3EE),
                    unselectedColor: const Color(0xFF94A3B8),
                  ),
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.person_outline, size: 28),
                    activeIcon: const Icon(Icons.person_rounded, size: 28),
                    title: const Text('Profile'),
                    selectedColor: const Color(0xFF10B981),
                    unselectedColor: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GamesTab extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final bool isAdmin;

  const GamesTab({
    super.key,
    required this.userProfile,
    required this.isAdmin,
  });

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  List<dynamic> games = [];
  List<dynamic> filteredGames = [];
  bool isLoading = true;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getGames();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getGames() async {
    setState(() => isLoading = true);
    try {
      final res = await Apiservice.get('/games');
      if (res != null && res['data'] != null) {
        if (!mounted) return;
        setState(() {
          games = List.from(res['data']);
          _filterGames(searchController.text);
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat games: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterGames(String query) {
    if (query.isEmpty) {
      filteredGames = List.from(games);
    } else {
      filteredGames = games.where((game) {
        final title = game['title']?.toString().toLowerCase() ?? '';
        final dev = game['developer']?.toString().toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) || dev.contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> deleteGame(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Hapus Game', style: TextStyle(color: Colors.white)),
        content: Text(
          'Apakah kamu yakin ingin menghapus game "$title"?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await Apiservice.delete('/games/$id');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Game berhasil dihapus!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      getGames();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildGameCard(dynamic game) {
    final id = game['id'];
    final title = game['title']?.toString() ?? '-';
    final developer = game['developer']?.toString() ?? '-';
    final rating = game['rating']?.toString() ?? '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6366F1)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sports_esports_rounded,
                    color: Color(0xFF22D3EE),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.comicRelief(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      developer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFF334155)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 20),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                  ),
                  const Text(
                    ' / 10.0',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
              if (widget.isAdmin)
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditGamePage(game: game)),
                        );
                        if (result == true) {
                          getGames();
                        }
                      },
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => deleteGame(id, title),
                      icon: const Icon(Icons.delete_outline_rounded, size: 14),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.userProfile?['username'] ?? 'User';
    final role = widget.userProfile?['role'] ?? 'user';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;
        final contentWidth = constraints.maxWidth > 1000 ? 1000.0 : constraints.maxWidth;

        return RefreshIndicator(
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF1E293B),
          onRefresh: getGames,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.sports_esports_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'GameHaven',
                            style: GoogleFonts.comicRelief(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.isAdmin
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : const Color(0xFF22D3EE).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.isAdmin ? const Color(0xFF10B981) : const Color(0xFF22D3EE),
                          ),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.isAdmin ? const Color(0xFF10B981) : const Color(0xFF22D3EE),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Halo, $username!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jelajahi dan kelola katalog game pilihanmu.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) {
                              setState(() => _filterGames(val));
                            },
                            decoration: const InputDecoration(
                              hintText: 'Cari game atau developer...',
                              hintStyle: TextStyle(color: Color(0xFF64748B)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              searchController.clear();
                              setState(() => _filterGames(''));
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Game (${filteredGames.length})',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (!widget.isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Read Only',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                      ),
                    )
                  else if (filteredGames.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.sports_esports_outlined, size: 60, color: Color(0xFF64748B)),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada game ditemukan.',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  else if (isDesktop)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: filteredGames.map((game) {
                        final cardWidth = (contentWidth - 40 - 16) / 2;
                        return SizedBox(
                          width: cardWidth,
                          child: _buildGameCard(game),
                        );
                      }).toList(),
                    )
                  else
                    Column(
                      children: filteredGames
                          .map((game) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildGameCard(game),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class UsersTab extends StatefulWidget {
  final bool isAdmin;
  final Map<String, dynamic>? currentUser;

  const UsersTab({
    super.key,
    required this.isAdmin,
    required this.currentUser,
  });

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      getUsers();
    } else {
      isLoading = false;
    }
  }

  Future<void> getUsers() async {
    setState(() => isLoading = true);
    try {
      final res = await Apiservice.get('/users');
      if (res != null && res['data'] != null) {
        if (!mounted) return;
        setState(() {
          users = List.from(res['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(int id, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Yakin ingin menghapus user "$username"?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await Apiservice.delete('/users/$id');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'User berhasil dihapus!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      getUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildUserCard(dynamic user) {
    final id = user['id'];
    final username = user['username']?.toString() ?? '-';
    final email = user['email']?.toString() ?? '-';
    final role = user['role']?.toString() ?? 'user';
    final photo = user['profile_photo']?.toString();
    final isCurrent = widget.currentUser?['id'] == id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: role == 'admin' ? const Color(0xFF10B981) : const Color(0xFF22D3EE),
            backgroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
            child: (photo == null || photo.isEmpty)
                ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (isCurrent)
                      const Text(' (Kamu)', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                  ],
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'admin'
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : const Color(0xFF334155),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: role == 'admin' ? const Color(0xFF10B981) : Colors.white,
              ),
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
              onPressed: () => deleteUser(id, username),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAdmin) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings_outlined, size: 70, color: Color(0xFF6366F1)),
              const SizedBox(height: 16),
              Text(
                'Khusus Admin Bro!',
                style: GoogleFonts.comicRelief(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar user hanya dapat diakses oleh akun dengan role "admin".',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;
        final contentWidth = constraints.maxWidth > 1000 ? 1000.0 : constraints.maxWidth;

        return RefreshIndicator(
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF1E293B),
          onRefresh: getUsers,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Daftar Pengguna',
                    style: GoogleFonts.comicRelief(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kelola semua pengguna terdaftar di GameHaven.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                  else if (isDesktop)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: users.map((user) {
                        final cardWidth = (contentWidth - 40 - 12) / 2;
                        return SizedBox(
                          width: cardWidth,
                          child: _buildUserCard(user),
                        );
                      }).toList(),
                    )
                  else
                    Column(
                      children: users
                          .map((user) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildUserCard(user),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final bool isLoading;
  final VoidCallback onProfileUpdated;

  const ProfileTab({
    super.key,
    required this.userProfile,
    required this.isLoading,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool isUploading = false;

  Future<void> pickAndUploadPhoto() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      backgroundColor: const Color(0xFF1E293B),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ganti Foto Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF22D3EE)),
                title: const Text('Pilih dari Galeri', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF6366F1)),
                title: const Text('Ambil dari Kamera', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    setState(() => isUploading = true);

    try {
      final res = await Apiservice.uploadProfilePhoto(picked);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Foto profile berhasil diupload ke Cloudinary!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      widget.onProfileUpdated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Konfirmasi Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah kamu yakin ingin logout dari GameHaven?', style: TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Apiservice.logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
    }

    final username = widget.userProfile?['username'] ?? 'User';
    final email = widget.userProfile?['email'] ?? '-';
    final role = widget.userProfile?['role'] ?? 'user';
    final photo = widget.userProfile?['profile_photo']?.toString();
    final id = widget.userProfile?['id']?.toString() ?? '-';

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: const Color(0xFF6366F1), width: 3),
                    ),
                    child: ClipOval(
                      child: (photo != null && photo.isNotEmpty)
                          ? Image.network(
                              photo,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Center(
                                child: Text(
                                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: isUploading ? null : pickAndUploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                        child: isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                username,
                style: GoogleFonts.comicRelief(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: role == 'admin'
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFF22D3EE).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: role == 'admin' ? const Color(0xFF10B981) : const Color(0xFF22D3EE),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined, color: Color(0xFF94A3B8)),
                      title: const Text('User ID', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      subtitle: Text('#$id', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    ListTile(
                      leading: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                      title: const Text('Email', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      subtitle: Text(email, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF94A3B8)),
                      title: const Text('Role Akun', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      subtitle: Text(
                        role == 'admin' ? 'Administrator (Akses Penuh)' : 'User (Hanya Lihat)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: logout,
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  label: const Text(
                    'Keluar / Logout',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
