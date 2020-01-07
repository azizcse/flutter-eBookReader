/*
import 'package:flutter/material.dart';
import 'pages/app.dart';
import 'utils/initial.dart';

void main() async {
  /// initialize the app
  await initial();

  /// run the app
  runApp(new App());
}

*/



import 'package:flutter/material.dart';
import 'package:flutter_ebup_test/book_reader.dart';
import 'package:http/http.dart' as http;
import 'package:epub/epub.dart' as epub;
import 'package:image/image.dart' as image;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

void main() => runApp(EpubWidget());

class EpubWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new EpubState();
  }
}

class EpubState extends State<EpubWidget> {
  Future<epub.EpubBookRef> book;

  final _urlController = TextEditingController();

  void fetchBookButton() {
    setState(() {
      book = fetchBook(_urlController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Fetch Epub Example",
        home: new Material(
            child: new Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.white,
                child: new Container(
                  child: new Center(
                      child: new ListView(children: [
                        new Padding(padding: EdgeInsets.only(top: 70.0)),
                        new Text(
                          'Epub Inspector',
                          style: new TextStyle(fontSize: 25.0),
                        ),
                        new Padding(padding: EdgeInsets.only(top: 50.0)),
                        new Text(
                          'Enter the Url of an Epub to view some of it\'s metadata.',
                          style: new TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Enter Url",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                          validator: (val) {
                            if (val.length == 0) {
                              return "Url cannot be empty";
                            } else {
                              return null;
                            }
                          },
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          style: new TextStyle(
                            fontFamily: "Poppins",
                          ),
                        ),
                        new Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),
                        new RaisedButton(
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.white,
                          color: Colors.blue,
                          onPressed: fetchBookButton,
                          child: new Text("Inspect Book"),
                        ),
                        new Padding(padding: EdgeInsets.only(top: 25.0)),
                        Center(
                          child: FutureBuilder<epub.EpubBookRef>(
                            future: book,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return new Material(
                                    color: Colors.white,
                                    child: buildEpubWidget(snapshot.data));
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              // By default, show a loading spinner
                              // return CircularProgressIndicator();

                              // By default, show just empty.
                              return Container();
                            },
                          ),
                        ),
                      ])),
                ))));
  }
}

Widget buildEpubWidget(epub.EpubBookRef book) {
  var chapters = book.getChapters();
  var cover = book.readCover();
  _sowText(book);
  return Container(
      child: new Column(
        children: <Widget>[
          Text(
            "Title",
            style: TextStyle(fontSize: 20.0),
          ),
          Text(
            book.Title,
            style: TextStyle(fontSize: 15.0),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
          Text(
            "Author",
            style: TextStyle(fontSize: 20.0),
          ),
          Text(
            book.Author,
            style: TextStyle(fontSize: 15.0),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
          FutureBuilder<List<epub.EpubChapterRef>>(
              future: chapters,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  for(int i = 0; i < snapshot.data.length; i++){
                    //print(snapshot.data[i].toString());
                  }

                  return Column(
                    children: <Widget>[
                      Text("Chapters", style: TextStyle(fontSize: 20.0)),
                      Text(
                        snapshot.data.toString(),
                        style: TextStyle(fontSize: 15.0),
                      ),
                      //Text(snapshot.data),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Container();
              }),
          new Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
          FutureBuilder<epub.Image>(
            future: cover,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Text("Cover", style: TextStyle(fontSize: 20.0)),
                    Image.memory(image.encodePng(snapshot.data)),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Container();
            },
          ),
        ],
      ));
}

void _sowText(epub.EpubBookRef book)async{
  var chapter = await book.getChapters();
  chapter.forEach((chap)async{
    var html = await chap.epubTextContentFileRef.toString();
    var content = await chap.readHtmlContent();
    dom.Document doc = parse(content);
    //print("Document body "+doc.body.text);
    //print("Chapter text ="+html);
    var para = await chap.epubTextContentFileRef.ReadContentAsync();
    //print("Document body "+para);
  });
  //print("Chapter text "+book.Content.);
}

void _printAllData(epub.EpubBook book) async{
  print("Ebook instance for loop");
  var content = await BookEncoder().decodeEpub(book);
  print("book content : \n ${content["content"]}");
  /*epub.EpubContent bookContent = book.Content;

  book.Chapters.forEach((chapter){
    String chapterTitle = chapter.Title;

    // HTML content of current chapter
    String chapterHtmlContent = chapter.HtmlContent;
    print(chapterTitle+"\n "+chapterHtmlContent);

  });*/
}

// Needs a url to a valid url to an epub such as
// https://www.gutenberg.org/ebooks/11.epub.images
// or
// https://www.gutenberg.org/ebooks/19002.epub.images
Future<epub.EpubBookRef> fetchBook(String url) async {
  // Hard coded to Alice Adventures In Wonderland in Project Gutenberb
  final response = await http.get('https://www.gutenberg.org/ebooks/19002.epub');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the EPUB

    var value = await epub.EpubReader.readBook(response.bodyBytes);

    print("Read boo value ="+value.Chapters.length.toString());
    _printAllData(value);
    return epub.EpubReader.openBook(response.bodyBytes);
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load epub');
  }

}

