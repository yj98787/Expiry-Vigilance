class UserModel{
  String? uid;
  String? fullName;
  String? email;

  UserModel({required this.email,required this.fullName,required this.uid});

  UserModel.fromMap(Map<String,dynamic>map){
    uid = map['uid'];
    fullName = map["fullName"];
    email = map['email'];
  }

  Map<String,dynamic> toMap(){
    return {
      "uid" : uid,
      "fullName":fullName,
      "email":email,
    };
}
}