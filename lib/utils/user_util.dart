
class UserUtil{

  static String formatLanguagesList(List<String> langs){
      String formmated = "";
      if(langs.length > 0){
      for(String lang in langs){
        formmated += lang.trim() + ', ';
      }}
      return formmated;
  }


}