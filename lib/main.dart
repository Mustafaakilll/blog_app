import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'blog_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {},
      // '/detailBlog': (context) => BlogDetailPage(),
      routes: {
        '/': (context) => BlogHomePage(),
        '/addBlog': (context) => AddBlogPage(),
        '/detailBlog': (context) => BlogDetailPage(),
      },
      initialRoute: '/',
    );
  }
}

class BlogHomePage extends StatefulWidget {
  const BlogHomePage({Key? key}) : super(key: key);

  @override
  _BlogHomePageState createState() => _BlogHomePageState();
}

class _BlogHomePageState extends State<BlogHomePage> {
  late final List blogList;

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  Future<void> asyncInit() async {
    blogList = await getBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getBlogs(),
        builder: (_, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: blogList.length,
              itemBuilder: (_, int index) {
                final Blog blog = blogList[index];
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detailBlog',
                      arguments: blog,
                    ).then((_) => setState(() {
                          blogList.removeAt(index);
                        }));
                  },
                  title: Text(blog.title),
                  subtitle: Text(blog.content),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Icon(Icons.error_outline);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/addBlog').then((value) => setState(() {
                blogList.add(value);
              }));
        },
      ),
    );
  }

  Future<List<Blog>> getBlogs() async {
    final response = await http.get(Uri.parse('https://localhost:3000/blog'));
    final blogs = blogFromJson(response.body).toList();
    return blogs;
  }
}

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({Key? key}) : super(key: key);

  @override
  _AddBlogPageState createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _titleCTRL = TextEditingController();
  final _content = TextEditingController();
  final _author = TextEditingController();
  final _category = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCTRL,
              decoration: InputDecoration(
                hintText: 'Blog Basligi',
              ),
            ),
            TextField(
              controller: _author,
              decoration: InputDecoration(
                hintText: 'Blog Sahibi',
              ),
            ),
            TextField(
              controller: _category,
              decoration: InputDecoration(
                hintText: 'Blog Kategorisi',
              ),
            ),
            TextField(
              controller: _content,
              decoration: InputDecoration(
                hintText: 'Blog Icerigi',
              ),
              maxLines: null,
            ),
            ElevatedButton(
              onPressed: () async {
                final newBlog = Blog(
                    title: _titleCTRL.text,
                    content: _content.text,
                    category: _category.text,
                    author: _author.text);
                await http.post(
                  Uri.parse('https://localhost:3000/blog'),
                  body: blogToJson(newBlog),
                );
                Navigator.pop(context, newBlog);
              },
              child: Text('Ekle'),
            )
          ],
        ),
      ),
    );
  }
}

class BlogDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Blog blog = ModalRoute.of(context)!.settings.arguments as Blog;
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 'sil') {
                final response = await http.delete(
                    Uri.parse('https://localhost:3000/blog/${blog.id}'));
                if (response.statusCode == HttpStatus.ok) {
                  Navigator.pop(context, blog);
                }
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('sil'),
                  value: 'sil',
                )
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: Text(blog.category),
            trailing: Text(blog.author),
          ),
          Text(blog.id ?? 'BURASI BOS')
        ],
      ),
    );
  }
}
