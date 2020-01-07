import 'dart:convert';

import 'package:epub/epub.dart' as epub;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
class BookEncoder{
  static BookEncoder _bookEncoder;

  BookEncoder._instance();

  factory BookEncoder(){
    if(_bookEncoder == null){
      _bookEncoder = BookEncoder._instance();
    }
    return _bookEncoder;
  }

  Future<Map<String, dynamic>> decodeEpub(epub.EpubBook epubBook) async {
    try {
      print('decode epub...');
      String content = '';
      List<Map> chapters = <Map>[];
//    content = epubBook.Content.toString();
      epubBook.Chapters?.forEach((epub.EpubChapter chapter) {
        if (null != chapter) {
          dom.Document doc = parse(chapter.HtmlContent);
          String text = doc.body.text;
          chapters.add({
            'title': chapter.Title,
            'offset': content?.length,
            'length': text?.length
          });
          content += text;
        }
      });
      return {'content': content, 'chapters': jsonEncode(chapters).toString()};
    } catch (e) {
      print('decode epub failed, e: $e');
      throw e;
    }
  }
}