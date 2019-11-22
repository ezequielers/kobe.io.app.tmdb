import 'package:kobe_tmdb/config.dart';
import 'dart:async';
import 'package:kobe_tmdb/models/movie.dart';
import 'package:kobe_tmdb/models/genre.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class API {

  var urlQuery = "https://api.themoviedb.org/3/search/movie?api_key=$API_KEY";
  var API_URL = "https://api.themoviedb.org/3/";


  final Dio dio = Dio();
  CancelToken cancelToken = CancelToken();


  void cancelar(){
    cancelToken.cancel("cancelled");
  }

  Future<List<Movie>> upComming(_page) async {
    List<Movie> list = [];

    await http.get("${API_URL}movie/upcoming?api_key=${API_KEY}&language=en-US&page=${_page}")
      .then( (res) {

        Map result = json.decode(res.body);

        if (result.containsKey('results') && result['results'].length > 0)
          (result['results']).forEach( (movie) => list.add(Movie.fromJSON(movie)) );
      }).catchError( (print));

    return list;
  }

  Future<List<Movie>> get(String query, int page) async {

    List<Movie> list = [];

    await http.get("$urlQuery&query=$query&page=$page")
        .then( (res) {

         Map result = json.decode(res.body);

         if(result.containsKey('results') && result['results'].length > 0)
         (result['results']).forEach( (movie) => list.add(Movie.fromJSON(movie)) );
      }).catchError( (print));

    return list;
  }

  Future<List<String>> listImages(int idMovie) async{

    var url = "${API_URL}movie/${idMovie}/images?api_key=$API_KEY";

    return await http.get(url).then( (res){
      Map map = json.decode(res.body);

      if(map.containsKey('backdrops')){
        return map['backdrops'].map( (entrada)=> entrada['file_path']).toList().cast<String>();
      }else{
        return [];
      }
    });

  }

  Future<List<Genre>> getListGenre() async {
    List<Genre> list = [];

    await http.get("${API_URL}genre/movie/list?api_key=$API_KEY&language=en-US")
        .then( (res) {

      Map result = json.decode(res.body);

      try {
        if (result.containsKey('genres') && result['genres'].length > 0)
          (result['genres']).forEach((genre) =>
              list.add(Genre.fromJSON(genre)));
      } catch (err) {
        print(err.toString());
      }
    }).catchError( (print));
    return list;
  }
}
