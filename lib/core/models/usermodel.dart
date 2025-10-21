// ignore_for_file: public_member_api_docs, sort_constructors_first

// class Usermodel {
//   String uid;
//   String name;
//   String email;
//   String profileImageUrl;
//   bool isPending; // 👈 new field

//   Usermodel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     required this.profileImageUrl,
//     this.isPending = false, // 👈 default false
//   });

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'uid': uid,
//       'name': name,
//       'email': email,
//       'profileImageUrl': profileImageUrl,
//       'isPending': isPending, // 👈 include in map
//     };
//   }

//   factory Usermodel.fromMap(Map<String, dynamic> map) {
//     return Usermodel(
//       uid: map['uid'] as String,
//       name: map['name'] as String,
//       email: map['email'] as String,
//       profileImageUrl: map['profileImageUrl'] as String,
//       isPending: map['isPending'] != null ? map['isPending'] as bool : false, // 👈 safe fallback
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory Usermodel.fromJson(String source) =>
//       Usermodel.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   String toString() {
//     return 'Usermodel(uid: $uid, name: $name, email: $email, profileImageUrl: $profileImageUrl, isPending: $isPending)';
//   }

//   Usermodel copyWith({
//     String? uid,
//     String? name,
//     String? email,
//     String? profileImageUrl,
//     bool? isPending,
//   }) {
//     return Usermodel(
//       uid: uid ?? this.uid,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       profileImageUrl: profileImageUrl ?? this.profileImageUrl,
//       isPending: isPending ?? this.isPending,
//     );
//   }
// }
class Usermodel {
  final String uid;
  final String name;
  final String email;
  final String profileImageUrl;
  final String requestStatus; // 👈 none | pending | accepted

  Usermodel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    this.requestStatus = "none", // default
  });

  factory Usermodel.fromMap(Map<String, dynamic> data) {
    return Usermodel(
      uid: data["uid"] ?? "",
      name: data["name"] ?? "",
      email: data["email"] ?? "",
      profileImageUrl: data["image"] ?? "", // adjust if key differs
      requestStatus: data["requestStatus"] ?? "none",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "image": profileImageUrl,
      "requestStatus": requestStatus,
    };
  }

  Usermodel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? requestStatus,
  }) {
    return Usermodel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      requestStatus: requestStatus ?? this.requestStatus,
    );
  }
}
