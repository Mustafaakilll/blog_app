import 'dart:convert';

List<Blog> blogFromJson(String str) =>
    List<Blog>.from(json.decode(str).map((x) => Blog.fromJson(x)));

Map<String, dynamic> blogToJson(Blog blog) => blog.toJson();

class Blog {
  Blog({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
  });

  final String? id;
  final String title;
  final String content;
  final String category;
  final String author;

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
        id: json["_id"],
        title: json["title"],
        content: json["content"],
        category: json["category"],
        author: json["author"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
        "category": category,
        "author": author,
      };
}
