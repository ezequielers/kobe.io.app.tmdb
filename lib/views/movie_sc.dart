import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kobe_tmdb/TmdbApiService.dart';
import 'package:kobe_tmdb/models/movie.dart';
import 'package:kobe_tmdb/models/genre.dart';
import 'package:kobe_tmdb/views/movie_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat("MMMM dd, yyyy");

class MovieScreen extends StatefulWidget{
  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  int _page;
  String _busca = "";
  List<Movie> _movies = [];
  List<Genre> _genres = [];
  API _api = new API();
  TextEditingController txtController = TextEditingController();

  bool isLoading = false;
  bool fimCarregamento = false;

  void buscaDados(var busca) async {
    setState((){
      _busca = busca;
      _movies = [];
      fimCarregamento = false;
    });

    if(busca.length > 0 ) {
      setState(() {
        _page = 0;
      });
      loadMore();
    }
  }

  void buscaLancamentos () async {
    setState((){
      _movies = [];
      fimCarregamento = false;
      _page = 0;
    });
    loadUpComing();
  }

  void loadUpComing () async {
    List<Movie> list = [];

    setState(() {
      isLoading = true;
      _page++;
    });

    list = await _api.upComming(_page);

    if (list.isEmpty)
      fimCarregamento = true;

    setState(() {
      isLoading = false;
      _movies.addAll(list);
    });
  }

  void loadMore() async {
    List<Movie> list = [];
    if(!isLoading && _busca.length > 0) {
      setState(() {
        isLoading = true;
        _page++;
      });

      list = await _api.get(_busca, _page);

       if (list.isEmpty)
         fimCarregamento = true;

       setState(() {
         isLoading = false;
         if(_busca.length >0)
           _movies.addAll(list);
       });
    }
  }

  void getGenres() async {
    List<Genre> list = await _api.getListGenre();
    setState(() {
      _genres = list;
    });
  }

  Widget buildProgressIndicator () {
    return Center(child:
      fimCarregamento ? Padding(padding: const EdgeInsets.all(10.0),)
      : Padding (
        padding: const EdgeInsets.all(10.0),
        child: new SizedBox(child: CircularProgressIndicator(strokeWidth: 2.0,), height: 15.0,width: 15.0,)
      )
    );
  }

  @override
  Widget build (BuildContext context) {
    var titleApp = AppBar( title: Text('Kobe.io - Search Movies App'));

    if (_genres.isEmpty) {
      getGenres();
    }

    var field =  TextField(
      controller: txtController,
      decoration: InputDecoration(
        hintText: 'Busque um filme',
        border: InputBorder.none
      ),
      onChanged: (valor){
        buscaDados(valor);
      },
    );

    var textField = new Container(
      padding: const EdgeInsets.only(left: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:  BorderRadius.circular(8.0)
      ),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child:field
          ),

          IconButton(icon: Icon(Icons.clear),
            onPressed: () {
              setState((){
                txtController.text = '';
                buscaDados('');
              });
            })
        ]
      )
    );

    if (txtController.text == '' && _movies.isEmpty) {
      buscaLancamentos();
    }

    return Scaffold (
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: titleApp,
      body: Column( children: [
        Container(padding: const EdgeInsets.all(10.0), child: textField),
        Flexible(child: buildResults(context))
      ])
    );
  }

  Widget buildResults (BuildContext context) {
    if(_movies.isEmpty && !isLoading) {
      return new Center(child: Icon(Icons.movie_creation,size: 200.0,color: Colors.grey[300]));
    } else {
      return ListView.builder(
        itemCount:  _movies.length+1,
        itemBuilder: (context, index) {
          if(index == _movies.length && !fimCarregamento ) {
//            if (txtController.text == '')
//              loadUpComing();
//            else
//              loadMore();
            loadMore();
          }
          if(index == _movies.length )
            return buildProgressIndicator();
          else
            return buildItem(_movies[index]);
        },
      );
    }
  }

  String getStringGenres (List<int> genres) {
    String newGenres = "";
    for(var i = 0; i < genres.length; i++) {
      var listContains = _genres.firstWhere((genre) => genre.id == genres[i], orElse: () => null);
      if (listContains != null) {
        if (newGenres != '')
          newGenres += ', ';
        newGenres += listContains.name;
      }
    }
    return newGenres;
  }

  String formatDate (release_date) {
    var dt = DateTime.tryParse(release_date);
    if (dt != null) {
      return formatter.format(dt);
    } else {
      return 'Not informed';
    }
  }

  Widget buildItem (Movie movie) {
    return new Column (
      children: <Widget>[
        ListTile(
          title:Text(movie.title, style: TextStyle(color: Theme.of(context).accentColor)),
          subtitle: Text("Release Date: ${formatDate(movie.release_date)}" + "\n${"Genre: " + getStringGenres(movie.genre_ids)}", style: TextStyle(color: Theme.of(context).accentColor)),
          // trailing: Text("Genre: " + movie.genre_ids, style: TextStyle(color: Theme.of(context).accentColor)),
          leading: CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w92${movie.poster_path}",
            width: 60.0,
            placeholder: (context, url) => Icon(Icons.movie_creation)
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context)=>MovieDetailScreen(movie) )
            );
          }
        ),
        Divider()
      ]
    );
  }
}
