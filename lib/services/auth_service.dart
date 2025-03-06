import 'dart:io';
import 'dart:typed_data'; // Web向け
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // 画像圧縮用

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1) 認証状態の監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 2) 匿名ログイン
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      throw Exception("Failed to sign in anonymously: $e");
    }
  }

  // 3) メールアドレスでログイン
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception("Failed to sign in with email: $e");
    }
  }

  // 4) メールアドレスで新規登録
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      return userCredential.user; 
      // userCredential.user は User? を返す
    } catch (e) {
      // 失敗時は例外を投げる
      throw Exception('登録エラー: $e');
    }
  }

  // 5) Google ログイン
  Future<void> signInWithGoogle() async {
    try {
      // Google でログイン画面を表示
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // ユーザーがログインをキャンセルした場合
        return;
      }

      // Google 認証情報を取得
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Firebase Auth 用の Credential に変換
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase にログイン
      await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception("Failed to sign in with Google: $e");
    }
  }

  // 6) ログアウト
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Failed to sign out: $e");
    }
  }

  // Firestore にユーザーネームを保存
  Future<void> saveUsername(String userId, String username) async {
    await _firestore.collection('users').doc(userId).set({
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Firestore からユーザーネームを取得
  Future<String?> getUsername(String userId) async {
  try {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.get('username') ?? "未設定";
    } else {
      return "未設定"; // デフォルト値を返す
    }
  } catch (e) {
    print("Firestore ユーザー名取得エラー: $e");
    return "エラー"; // エラー時もループしないように
  }
}
  
  // ユーザー名を更新
  Future<void> updateUsername(String userId, String newUsername) async {
    await _firestore.collection('users').doc(userId).update({
      'username': newUsername,
    });
  }

  // 投稿したトイレ一覧を取得
  Future<List<Map<String, dynamic>>> getUserToilets(String userId) async {
    try {
      print("📡 Firestore からユーザーの投稿を取得: userId = $userId");

      QuerySnapshot querySnapshot = await _firestore
          .collection('toilets')
          .where('registeredBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // 新しい順にソート
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ 投稿が見つかりませんでした");
        return [];
      }

      print("✅ Firestore から投稿を取得: ${querySnapshot.docs.length} 件");

      return querySnapshot.docs.map((doc) {
        print("📝 取得したデータ: ${doc.data()}");
        return {
          "name": doc["buildingName"] ?? "名称不明",
          "location": "${doc["location"].latitude}, ${doc["location"].longitude}",
          "rating": doc["rating"] ?? 0,
          "createdAt": doc["createdAt"]?.toDate().toString() ?? "不明",
        };
      }).toList();
    } catch (e) {
      print("🔥 投稿一覧取得エラー: $e");
      return [];
    }
  }

  // ユーザーのお気にいいりしたデータを取得
  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> favorites = [];

      for (var doc in querySnapshot.docs) {
        String toiletId = doc['toiletId'];

        // トイレの詳細を取得
        DocumentSnapshot toiletDoc = await FirebaseFirestore.instance
            .collection('toilets')
            .doc(toiletId)
            .get();

        if (toiletDoc.exists) {
          favorites.add({
            "name": toiletDoc["buildingName"] ?? "名称不明",
            "location": "${toiletDoc["location"].latitude}, ${toiletDoc["location"].longitude}",
            "rating": toiletDoc["rating"] ?? 0,
          });
        }
      }

      return favorites;
    } catch (e) {
      print("🔥 お気に入り取得エラー: $e");
      return [];
    }
  }

  // 画像を選択して Firebase Storage にアップロード
  Future<void> uploadProfileImage(void Function(String? newImageUrl) onComplete) async {
    print("🚀 uploadProfileImage: 開始");
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ ユーザーがログインしていません");
      onComplete(null);
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      print("⚠️ 画像が選択されませんでした");
      onComplete(null);
      return;
    }

    print("✅ 画像が選択されました: ${pickedImage.path}");

    try {
      Uint8List bytes = await pickedImage.readAsBytes();
      print("✅ readAsBytes OK. bytes.length = ${bytes.length}");

      // ===== ここで圧縮する =====
      bytes = await compressImage(bytes); 
      print("✅ 圧縮後 bytes.length = ${bytes.length}");

      String filePath = 'profile_images/${user.uid}.jpg';
      final ref = FirebaseStorage.instance.ref(filePath);

      print("🚀 putData開始");
      final uploadTask = ref.putData(bytes);

      // 進捗・成功・失敗をハンドリング
      uploadTask.snapshotEvents.listen((event) {
        print("📝 進捗: totalBytes=${event.totalBytes}, "
            "bytesTransferred=${event.bytesTransferred}, "
            "state=${event.state}");
      }, onError: (error) {
        print("🔥 スナップショットエラー: $error");
      });

      final snapshot = await uploadTask.whenComplete(() {
        print("✅ uploadTask.whenComplete が呼ばれました");
      });
      print("✅ putData成功");

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ ダウンロードURL取得: $downloadUrl");

      // Firestore に保存
      await FirebaseFirestore.instance.collection('users').doc(user.uid)
        .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));

      print("✅ FirestoreにprofileImageUrl保存完了");
      onComplete(downloadUrl);

    } catch (e) {
      print("🔥 画像アップロードエラー: $e");
      onComplete(null);
    }
  }
  // Firestore からプロフィール画像の URL を取得
  Future<String?> getProfileImageUrl(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc['profileImageUrl'];
  }

  // 画像の圧縮
  Future<Uint8List> compressImage(Uint8List originalBytes) async {
    img.Image? decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) return originalBytes;

    // 幅 500px に縮小 & 画質 70%
    img.Image resized = img.copyResize(decodedImage, width: 500);
    Uint8List compressed = Uint8List.fromList(img.encodeJpg(resized, quality: 70));
    return compressed;
  }
}