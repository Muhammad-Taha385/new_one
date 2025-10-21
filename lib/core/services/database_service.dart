// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DatabaseService {
//   final _db = FirebaseFirestore.instance;

//   Future<void> saveUser(Map<String, dynamic> userData) async {
//     try {
//       final uid = userData["uid"];
//       await _db.collection("users").doc(uid).set(userData);
//       print("Saved user with UID: $uid");
//     } catch (e) {
//       print("Error saving user: $e");
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>?> loadUser(String uid) async {
//     try {
//       final res = await _db.collection("users").doc(uid).get();

//       if (res.data() != null) {
//         return res.data();
//       }
//     } catch (e) {
//       rethrow;
//     }
//     return null;
//   }

//   Future<List<Map<String, dynamic>?>> fetchUser(String currentUserId) async {
//     try {
//       final res = await _db
//           .collection("users")
//           .where("uid", isNotEqualTo: currentUserId)
//           .get();

//       //  if(res.data() != null){
//       //   return res.data();
//       //  }
//       return res.docs.map((e) => e.data()).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

// 2nd Model

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:real_time_chat_application/core/models/usermodel.dart';

// class DatabaseService {
//   final _db = FirebaseFirestore.instance;

//   /// Save or update user
//   Future<void> saveUser(Map<String, dynamic> userData) async {
//     try {
//       final uid = userData["uid"];
//       await _db.collection("users").doc(uid).set(userData);
//       print("Saved user with UID: $uid");
//     } catch (e) {
//       print("Error saving user: $e");
//       rethrow;
//     }
//   }

//   /// Load a single user by uid
//   Future<Map<String, dynamic>?> loadUser(String uid) async {
//     try {
//       final res = await _db.collection("users").doc(uid).get();
//       return res.data();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Fetch all users except current
//   Future<List<Map<String, dynamic>?>> fetchUser(String currentUserId) async {
//     try {
//       final res = await _db
//           .collection("users")
//           .where("uid", isNotEqualTo: currentUserId)
//           .get();

//       return res.docs.map((e) => e.data()).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // ------------------- CONTACTS LOGIC -------------------

//   /// Send contact request
//   Future<void> sendContactRequest(String currentUid, String targetUid) async {
//     try {
//       // Add "pending" entry in sender's contacts
//       await _db
//           .collection("users")
//           .doc(currentUid)
//           .collection("contacts")
//           .doc(targetUid)
//           .set({
//         "status": "pending",
//         "createdAt": FieldValue.serverTimestamp(),
//       });

//       // Add "requested" entry in receiver's contacts
//       await _db
//           .collection("users")
//           .doc(targetUid)
//           .collection("contacts")
//           .doc(currentUid)
//           .set({
//         "status": "requested",
//         "createdAt": FieldValue.serverTimestamp(),
//       });

//       print("Request sent from $currentUid to $targetUid");
//     } catch (e) {
//       print("Error sending request: $e");
//       rethrow;
//     }
//   }

//   /// Accept contact request
//   Future<void> acceptContactRequest(String currentUid, String targetUid) async {
//     try {
//       // Update both sides to "accepted"
//       await _db
//           .collection("users")
//           .doc(currentUid)
//           .collection("contacts")
//           .doc(targetUid)
//           .update({"status": "accepted"});

//       await _db
//           .collection("users")
//           .doc(targetUid)
//           .collection("contacts")
//           .doc(currentUid)
//           .update({"status": "accepted"});

//       print("Contact request accepted between $currentUid and $targetUid");
//     } catch (e) {
//       print("Error accepting request: $e");
//       rethrow;
//     }
//   }

//   /// Reject / Remove contact
//   Future<void> removeContact(String currentUid, String targetUid) async {
//     try {
//       // await _db
//       //     .collection("users")
//       //     .doc(currentUid)
//       //     // .collection("contacts")
//       //     // .doc(targetUid)
//       //     .delete();

//       await _db
//           .collection("users")
//           .doc(targetUid)
//           // .collection("contacts")
//           // .doc(currentUid)
//           .delete();

//       // print("Contact removed between $currentUid and $targetUid");
//     } catch (e) {
//       print("Error removing contact: $e");
//       rethrow;
//     }
//   }

//   /// Fetch only accepted contacts
//   Future<List<Map<String, dynamic>>> fetchContacts(String uid) async {
//     try {
//       final res = await _db
//           .collection("users")
//           .doc(uid)
//           .collection("contacts")
//           .where("status", isEqualTo: "accepted")
//           .get();

//       List<String> contactIds = res.docs.map((doc) => doc.id).toList();
//       if (contactIds.isEmpty) return [];

//       final usersRes = await _db
//           .collection("users")
//           .where("uid", whereIn: contactIds)
//           .get();

//       return usersRes.docs.map((e) => e.data()).toList();
//     } catch (e) {
//       print("Error fetching contacts: $e");
//       rethrow;
//     }
//   }

//   /// Fetch pending requests (incoming)
//   Future<List<Map<String, dynamic>>> fetchRequests(String uid) async {
//     try {
//       final res = await _db
//           .collection("users")
//           .doc(uid)
//           .collection("contacts")
//           .where("status", isEqualTo: "requested")
//           .get();

//       List<String> requestIds = res.docs.map((doc) => doc.id).toList();
//       if (requestIds.isEmpty) return [];

//       final usersRes = await _db
//           .collection("users")
//           .where("uid", whereIn: requestIds)
//           .get();

//       return usersRes.docs.map((e) => e.data()).toList();
//     } catch (e) {
//       print("Error fetching requests: $e");
//       rethrow;
//     }
//   }

//   Future<Usermodel?> getUserByUid(String uid) async {
//   try {
//     final doc = await _db.collection("users").doc(uid).get();
//     if (doc.exists && doc.data() != null) {
//       return Usermodel.fromMap(doc.data()!);
//     }
//     return null;
//   } catch (e) {
//     print("Error fetching user by uid: $e");
//     return null;
//   }
// }
// }

// New model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_time_chat_application/core/models/usermodel.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ------------------- USERS -------------------

  /// Save or update user
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final uid = userData["uid"];
      await _db
          .collection("users")
          .doc(uid)
          .set(userData, SetOptions(merge: true));
      // print("Saved user with UID: $uid");
    } catch (e) {
      // print("Error saving user: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUser(String uid) async {
    try {
      final res = await _db.collection("users").doc(uid).get();
      return res.data();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>?>> fetchUser(String currentUserId) async {
    try {
      final res = await _db
          .collection("users")
          .where("uid", isNotEqualTo: currentUserId)
          .get();

      return res.docs.map((e) => e.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ------------------- CONTACTS -------------------

  /// Send friend/contact request
  Future<void> sendContactRequest(String currentUid, String targetUid) async {
    try {
      // Sender side
      await _db
          .collection("users")
          .doc(currentUid)
          .collection("contacts")
          .doc(targetUid)
          .set({
        "status": "pending", // sent
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Receiver side
      await _db
          .collection("users")
          .doc(targetUid)
          .collection("contacts")
          .doc(currentUid)
          .set({
        "status": "requested", // incoming
        "createdAt": FieldValue.serverTimestamp(),
      });

      // print("Request sent from $currentUid → $targetUid");
    } catch (e) {
      // print("Error sending request: $e");
      rethrow;
    }
  }

  /// Accept friend request
//   Future<void> acceptContactRequest(String currentUid, String targetUid) async {
//   try {
//     // 1️⃣ Find the request doc where targetUid sent request to currentUid
//     final requestQuery = await _db
//         .collection("requests")
//         .where("fromUid", isEqualTo: targetUid)
//         .where("toUid", isEqualTo: currentUid)
//         .where("status", isEqualTo: "pending")
//         .get();

//     if (requestQuery.docs.isEmpty) {
//       throw Exception("No pending request found");
//     }

//     final requestDoc = requestQuery.docs.first;

//     // 2️⃣ Update request status
//     await requestDoc.reference.update({"status": "accepted"});

//     // 3️⃣ (Optional) Add to each other's contact list
//     await _db
//         .collection("users")
//         .doc(currentUid)
//         .collection("contacts")
//         .doc(targetUid)
//         .set({"status": "accepted"});

//     await _db
//         .collection("users")
//         .doc(targetUid)
//         .collection("contacts")
//         .doc(currentUid)
//         .set({"status": "accepted"});

//     print("✅ Contact request accepted between $currentUid ↔ $targetUid");
//   } catch (e) {
//     print("❌ Error accepting request: $e");
//     rethrow;
//   }
// }

  /// Reject or remove contact (removes both sides)
  Future<void> removeContact(String currentUid, String targetUid) async {
    try {
      await _db
          .collection("users")
          .doc(currentUid)
          .collection("contacts")
          .doc(targetUid)
          .delete();

      await _db
          .collection("users")
          .doc(targetUid)
          .collection("contacts")
          .doc(currentUid)
          .delete();

      // print("🗑️ Contact removed between $currentUid and $targetUid");
    } catch (e) {
      // print("Error removing contact: $e");
      rethrow;
    }
  }

  Future<void> acceptContactRequest(String currentUid, String targetUid) async {
    try {
      // 🔎 Find the request where targetUid invited currentUid
      final requestQuery = await _db
          .collection("requests")
          .where("fromUid", isEqualTo: targetUid)
          .where("toUid", isEqualTo: currentUid)
          .where("status", isEqualTo: "pending")
          .get();

      if (requestQuery.docs.isEmpty) {
        throw Exception("No pending request found");
      }

      final requestDoc = requestQuery.docs.first;

      //  Update the request status to accepted
      await requestDoc.reference.update({"status": "accepted"});

      // print("Request from $targetUid to $currentUid has been accepted");
    } catch (e) {
      // print("Error accepting request: $e");
      rethrow;
    }
  }

  Future<List<Usermodel>> fetchfriendsContacts(String currentUid) async {
    try {
      // 1️⃣ Get all requests where currentUid is either sender or receiver
      final snapshot = await _db
          .collection("requests")
          .where("status", isEqualTo: "accepted")
          .where(Filter.or(
            Filter("fromUid", isEqualTo: currentUid),
            Filter("toUid", isEqualTo: currentUid),
          ))
          .get();
      if (snapshot.docs.isEmpty) return [];
      // 2️⃣ Collect the other userIds
      final contactUids = snapshot.docs.map((doc) {
        final data = doc.data();
        return data["fromUid"] == currentUid ? data["toUid"] : data["fromUid"];
      }).toList();
      if (contactUids.isEmpty) return [];
      // 3️⃣ Fetch user profiles for those UIDs
      final usersSnapshot = await _db
          .collection("users")
          .where("uid", whereIn: contactUids)
          .get();
      return usersSnapshot.docs
          .map((doc) => Usermodel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      // print("Error fetching contacts: $e");
      rethrow;
    }
  }
// Stream<List<Usermodel>> streamFriendsContacts(String currentUid) {
//   return _db
//       .collection("requests")
//       .where("status", isEqualTo: "accepted")
//       .where(Filter.or(
//         Filter("fromUid", isEqualTo: currentUid),
//         Filter("toUid", isEqualTo: currentUid),
//       ))
//       .snapshots()
//       .asyncMap((snapshot) async {
//         if (snapshot.docs.isEmpty) return [];

//         final contactUids = snapshot.docs.map((doc) {
//           final data = doc.data();
//           return data["fromUid"] == currentUid
//               ? data["toUid"]
//               : data["fromUid"];
//         }).toList();

//         if (contactUids.isEmpty) return [];

//         final usersSnapshot = await _db
//             .collection("users")
//             .where("uid", whereIn: contactUids)
//             .get();

//         return usersSnapshot.docs
//             .map((doc) => Usermodel.fromMap(doc.data()))
//             .toList();
//       });
// }
// Future<List<Usermodel>> streamFriendsContacts(String currentUid)
// async {
//   try {
//     _db
//         .collection("requests")
//         .where("status", isEqualTo: "accepted")
//         .where(Filter.or(
//           Filter("fromUid", isEqualTo: currentUid),
//           Filter("toUid", isEqualTo: currentUid),
//         ))
//         .snapshots()
//         .asyncMap((snapshot) async {
//           if (snapshot.docs.isEmpty) return [];

//           // collect the other user ids
//           final contactUids = snapshot.docs.map((doc) {
//             final data = doc.data();
//             return data["fromUid"] == currentUid
//                 ? data["toUid"]
//                 : data["fromUid"];
//           }).toList();

//           if (contactUids.isEmpty) return [];

//           // fetch user profiles
//           final usersSnapshot = await _db
//               .collection("users")
//               .where("uid", whereIn: contactUids)
//               .get();

//           return usersSnapshot.docs
//               .map((doc) => Usermodel.fromMap(doc.data()))
//               .toList();
//         });
//   } catch (e) {
//     print("❌ Error streaming contacts: $e");
//     rethrow;
//   }
// }

  /// Fetch incoming requests
  Future<List<Usermodel>> fetchIncomingRequests(String currentUserId) async {
    try {
      // 1️⃣ Get all requests sent TO the current user
      final requestsSnapshot = await _db
          .collection("requests")
          .where("toUid", isEqualTo: currentUserId)
          .where("status", isEqualTo: "pending")
          .get();

      if (requestsSnapshot.docs.isEmpty) return [];

      // 2️⃣ Map each request -> load sender's user profile
      List<Usermodel> incomingUsers = [];
      for (var doc in requestsSnapshot.docs) {
        final fromUid = doc["fromUid"];

        final userDoc = await _db.collection("users").doc(fromUid).get();
        if (userDoc.exists) {
          incomingUsers.add(Usermodel.fromMap(userDoc.data()!));
        }
      }

      return incomingUsers;
    } catch (e) {
      // print("Error fetching incoming requests: $e");
      rethrow;
    }
  }
//   Stream<List<Usermodel>> streamfetchIncomingRequests(String currentUid) {
//   return _db
//       .collection("requests")
//       .where("toUid", isEqualTo: currentUid)
//       .where("status", isEqualTo: "pending")
//       .snapshots()
//       .asyncMap((snapshot) async {
//         if (snapshot.docs.isEmpty) return [];

//         final fromUids = snapshot.docs.map((d) => d["fromUid"]).toList();

//         final usersSnapshot = await _db
//             .collection("users")
//             .where("uid", whereIn: fromUids)
//             .get();

//         return usersSnapshot.docs
//             .map((doc) => Usermodel.fromMap(doc.data()))
//             .toList();
//       });
// }

  /// Fetch accepted contacts
  Future<List<Usermodel>> fetchContacts(String uid) async {
    try {
      // final res = await _db
      //     .collection("users")
      //     .doc(uid)
      //     .collection("contacts")
      //     .where("status", isEqualTo: "accepted")
      //     .get();
      final res =
          await _db.collection("users").where("uid", isNotEqualTo: uid).get();

      final ids = res.docs.map((doc) => doc.id).toList();
      if (ids.isEmpty) return [];

      final usersRes =
          await _db.collection("users").where("uid", whereIn: ids).get();
      return usersRes.docs.map((e) => Usermodel.fromMap(e.data())).toList();
    } catch (e) {
      // print("Error fetching contacts: $e");
      rethrow;
    }
  }

  /// Fetch incoming requests

  /// Fetch outgoing requests (the ones current user sent)
  Future<List<Usermodel>> fetchOutgoingRequests(String uid) async {
    try {
      final res = await _db
          .collection("users")
          .doc(uid)
          .collection("contacts")
          .where("status", isEqualTo: "pending")
          .get();

      final ids = res.docs.map((doc) => doc.id).toList();
      if (ids.isEmpty) return [];

      final usersRes =
          await _db.collection("users").where("uid", whereIn: ids).get();
      return usersRes.docs.map((e) => Usermodel.fromMap(e.data())).toList();
    } catch (e) {
      // print("❌ Error fetching outgoing requests: $e");
      rethrow;
    }
  }

  Future<void> sendFriendRequest(String fromUid, String toUid) async {
    final requestRef = _db.collection("requests").doc();

    await requestRef.set({
      "fromUid": fromUid,
      "toUid": toUid,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

// Future<List<Usermodel>> loadContactsWithStatus(String currentUserId) async {

//   final usersSnapshot = await _db.collection("users").where("uid", isNotEqualTo: currentUserId).get();

//   final requestsSnapshot = await _db
//       .collection("requests")
//       .where("fromUid", isEqualTo: currentUserId)
//       .get();

//   final requests = requestsSnapshot.docs.map((doc) => doc.data()).toList();

//   return usersSnapshot.docs.map((doc) {
//     final data = doc.data();
//     final user = Usermodel.fromMap(data);

//     // final hasPending = requests.any((r) =>
//     //     r["toUid"] == user.uid &&
//     //     r["status"] == "pending");

//       final hasPending = requests.any((r) =>
//         (r["fromUid"] == currentUserId && r["toUid"] == user.uid ||
//          r["toUid"] == currentUserId && r["fromUid"] == user.uid) &&
//         r["status"] == "pending");
//     return user.copyWith(isPending: hasPending);
//   }).toList();

// }
  Future<List<Usermodel>> loadContactsWithStatus(String currentUserId) async {
    // 1. Get all users except current
    final usersSnapshot = await _db
        .collection("users")
        .where("uid", isNotEqualTo: currentUserId)
        .get();

    // 2. Get all requests (where currentUser is sender or receiver)
    final outgoingRequestsSnapshot = await _db
        .collection("requests")
        .where("fromUid", isEqualTo: currentUserId)
        .get();

    final incomingRequestsSnapshot = await _db
        .collection("requests")
        .where("toUid", isEqualTo: currentUserId)
        .get();

    final allRequests = [
      ...outgoingRequestsSnapshot.docs.map((d) => d.data()),
      ...incomingRequestsSnapshot.docs.map((d) => d.data()),
    ];

    // 3. Map users with status
    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      final user = Usermodel.fromMap(data);

      final relatedRequest = allRequests.firstWhere(
        (r) =>
            (r["fromUid"] == currentUserId && r["toUid"] == user.uid) ||
            (r["toUid"] == currentUserId && r["fromUid"] == user.uid),
        orElse: () => {},
      );

      String status = "none";
      if (relatedRequest.isNotEmpty) {
        status = relatedRequest["status"] ?? "none"; // pending | accepted
      }

      return user.copyWith(requestStatus: status);
    }).toList();
  }
}
