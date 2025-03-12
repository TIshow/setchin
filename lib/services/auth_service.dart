import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
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

  // メールアドレスとパスワードを更新
  Future<String?> updateEmailAndPassword(String email, String password) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return 'ユーザーが見つかりません。ログインし直してください。';
      }

      // メールアドレスの更新
      await user.verifyBeforeUpdateEmail(email);
      await user.sendEmailVerification(); // 確認メールを送信

      // パスワードの更新
      await user.updatePassword(password);

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'セキュリティのため、もう一度ログインしてください。';
      } else if (e.code == 'email-already-in-use') {
        return 'このメールアドレスはすでに使用されています。';
      } else {
        return 'エラーが発生しました: ${e.message}';
      }
    }
  }
}

  // 投稿したトイレ一覧を取得
  Future<List<Map<String, dynamic>>> getUserToilets(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('toilets')
          .where('registeredBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // 新しい順にソート
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        return {
          "name": doc["buildingName"] ?? "名称不明",
          "location": "${doc["location"].latitude}, ${doc["location"].longitude}",
          "rating": doc["rating"] ?? 0,
          "createdAt": doc["createdAt"]?.toDate().toString() ?? "不明",
        };
      }).toList();
    } catch (e) {
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
    return [];
  }
}
}

