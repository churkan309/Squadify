import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';

// โพสต์หนึ่งกระทู้ในกระดานสนทนา เก็บใน Firestore collection `posts`
class DiscussionPost {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final int commentCount;
  final DateTime? createdAt;

  DiscussionPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.commentCount,
    this.createdAt,
  });

  factory DiscussionPost.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return DiscussionPost(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        'commentCount': commentCount,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// คอมเมนต์หนึ่งอัน เก็บใน subcollection posts/{id}/comments
class PostComment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime? createdAt;

  PostComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.createdAt,
  });

  factory PostComment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return PostComment(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

// คุย Firestore collection `posts` + subcollection `posts/{id}/comments`
// ใช้ FirestoreService (shared_preferences) แค่ cache offline กับ draft
class CommunityProvider {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirestoreService _cache;

  CommunityProvider({FirebaseFirestore? firestore, FirebaseAuth? auth, FirestoreService? cache})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _cache = cache ?? FirestoreService();

  CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<DiscussionPost>> get allPosts {
    return _posts.orderBy('createdAt', descending: true).snapshots().map((snap) {
      final posts = snap.docs.map((d) => DiscussionPost.fromFirestore(d)).toList();
      // เก็บ cache ไว้เผื่อเปิดแอพตอนไม่มีเน็ต (ดู readCachedPosts)
      _cache.cachePosts(snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
      return posts;
    });
  }

  Future<List<Map<String, dynamic>>> readCachedPosts() => _cache.readCachedPosts();

  Stream<List<PostComment>> commentsOf(String postId) {
    return _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => PostComment.fromFirestore(d)).toList());
  }

  Future<void> addPost(String content, String authorName) async {
    final uid = _uid;
    if (uid == null || content.trim().isEmpty) return;
    await _posts.add(DiscussionPost(
      id: '',
      authorId: uid,
      authorName: authorName,
      content: content.trim(),
      commentCount: 0,
    ).toMap());
    await _cache.clearDraft();
  }

  // อัปเดต commentCount ด้วยทรานแซกชัน กันแข่งกันเขียนพร้อมกันแล้วนับเพี้ยน
  Future<void> addComment(String postId, String content, String authorName) async {
    final uid = _uid;
    if (uid == null || content.trim().isEmpty) return;
    final postRef = _posts.doc(postId);
    final commentRef = postRef.collection('comments').doc();
    await _firestore.runTransaction((tx) async {
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) return;
      tx.set(commentRef, {
        'authorId': uid,
        'authorName': authorName,
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      final current = (postSnap.data()?['commentCount'] as int?) ?? 0;
      tx.update(postRef, {'commentCount': current + 1});
    });
  }

  Future<void> saveDraft(String text) => _cache.saveDraft(text);
  Future<String> readDraft() => _cache.readDraft();
}
