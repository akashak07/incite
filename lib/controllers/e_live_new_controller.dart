import 'package:blog_app/models/e_news.dart';
import 'package:blog_app/models/live_news.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/e_live_news_repository.dart' as eLiveRepo;

class ELiveNewsController extends ControllerMVC {
  List<ENews>? eNews;
  List<LiveNewsModel>? liveNewsModel;

  getENews() async {
    eNews = await eLiveRepo.gewENews().catchError((e) {});
    print("eNews ${eNews?.length}");
    setState(() {});
  }

  getLiveNews() async {
    liveNewsModel = await eLiveRepo.getliveNews().catchError((e) {});
    print("liveNewsModel ${liveNewsModel?.length}");
    setState(() {});
  }
}
