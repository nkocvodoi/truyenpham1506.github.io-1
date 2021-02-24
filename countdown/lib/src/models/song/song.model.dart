/// FeedbackForm is a data class which stores data fields of Feedback.
class SongForm {
  String songName;
  String artist;
  String url;
  String lyric;

  SongForm(this.songName, this.artist, this.url, this.lyric);

  factory SongForm.fromJson(dynamic json) {
    return SongForm(
        "${json['songName']}",
        "${json['artist']}",
        "${json['url']}",
        "${json['lyric']}"
    );
  }

  // Method to make GET parameters.
  Map toJson() => {
    'songName': songName,
    'artist': artist,
    'url': url,
    'lyric': lyric
  };
}
