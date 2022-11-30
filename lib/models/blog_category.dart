import 'dart:convert';

BlogCategory blogCategoryFromMap(String str) =>
    BlogCategory.fromMap(json.decode(str));

String blogCategoryToMap(BlogCategory data) => json.encode(data.toMap());

class BlogCategory {
  BlogCategory({
    this.status,
    this.message,
    this.data,
  });

  bool? status;
  String? message;
  late List<Datum>? data;

  factory BlogCategory.fromMap(Map<String, dynamic> json) => BlogCategory(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class BlogSubCategory {
  BlogSubCategory({
    this.id,
    this.categoryId,
    this.blogId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.category,
  });

  int? id, blogId, categoryId;
  dynamic createdAt, updatedAt, deletedAt;
  bool? status;
  String? message;
  late Category? category;

  factory BlogSubCategory.fromMap(Map<String, dynamic> json) => BlogSubCategory(
        id: json["id"],
        categoryId: json["category_id"] ?? 0,
        blogId: json["blog_id"] ?? 0,
        deletedAt: json["deleted_at"] ?? '',
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
        category: Category.fromMap(json["category"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "category_id": categoryId,
        "blog_id": blogId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt.toIso8601String(),
      };
}

class Category {
  Category(
      {this.id,
      this.name,
      this.image,
      this.index,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.isFeatured,
      this.slug,
      this.status,
      this.color,
      this.order});

  int? id;
  String? name, slug, color;
  int? status, isFeatured, order;
  dynamic image;
  int? index;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  // List<Blog>? blog;

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        slug: json["slug"],
        image: json["image"],
        index: json["index"],
        order: json["order"],
        color: json["color"],
        createdAt: json["created_at"],
        isFeatured: json["is_featured"] ?? 0,
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "status": status,
        "image": image,
        "color": color,
        "slug": slug,
        "order": order,
        "is_featured": isFeatured,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        // 'isMyFeed': this.isMyFeed,
        // // "blog": List<dynamic>.from(blog!.map((x) => x.toMap())),
        // 'blog' : this.blog!.toJson()
      };
}

class Datum {
  Datum({
    this.id,
    this.name,
    this.status,
    this.image,
    this.index,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.blog,
    this.isMyFeed,
  });

  int? id;
  String? name;
  int? status;
  dynamic image;
  int? index;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  // List<Blog>? blog;
  Blog? blog;
  dynamic isMyFeed;

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        image: json["image"],
        index: json["index"],
        createdAt: json["created_at"],
        //createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        isMyFeed: json['isMyFeed'] ?? false,
        // blog: List<Blog>.from(json["blog"].map((x) => Blog.fromMap(x))),
        blog: json['blog'] != null ? Blog.fromJson(json['blog']) : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "status": status,
        "image": image,
        "index": index,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        'isMyFeed': isMyFeed,
        // "blog": List<dynamic>.from(blog!.map((x) => x.toMap())),
        'blog': blog!.toJson()
      };
}

class Blog {
  int? currentPage;
  List<DataModel>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  Blog(
      {this.currentPage,
      this.data,
      this.firstPageUrl,
      this.from,
      this.lastPage,
      this.lastPageUrl,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});

  Blog.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(DataModel.fromMap(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toMap()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class DataModel {
  DataModel({
    this.id,
    this.title,
    this.shortDescription,
    this.description,
    this.trimedDescription,
    this.thumbImage,
    this.bannerImage,
    this.authorImage,
    this.isFeatured,
    this.isVote,
    this.isBookmarked,
    this.isVotingEnabled,
    this.yesPercent,
    this.noPercent,
    this.viewCount,
    this.url,
    this.status,
    this.blogAccentCode,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.authorName,
    this.time,
    this.categoryName,
    this.categoryColor,
    this.type,
    this.createDate,
    this.contentType,
    this.videoUrl,
    this.slug,
    this.voice,
    this.categoryId,
    this.authorId,
    this.postId,
    this.tags,
    this.audioFile,
    this.scialMediaImage,
    this.isVotingEnable,
    this.votingQuestion,
    this.optiontype,
    this.tweetPublished,
    this.seoTitle,
    this.seoKeyword,
    this.seoTag,
    this.seoDescription,
    this.isSlider,
    this.isEditorPicks,
    this.isWeeklyTopPicks,
    this.createdBy,
    this.scheduleDate,
    this.order,
    this.languageCode,
    this.isBookmark,
    this.image,
    this.color,
    this.frequency,
    this.startDate,
    this.endDate,
    this.view,
    this.click,
    this.blogCategory,
    this.clickCount,
    this.section,
  });

  int? id;
  String? videoUrl;
  List<BlogSubCategory>? blogCategory;
  String? contentType;
  String? title;
  String? shortDescription;
  String? description;
  String? trimedDescription;
  dynamic thumbImage;
  dynamic bannerImage;
  String? blogAccentCode;
  //Map<String, dynamic> bannerImage;
  //List<String> bannerImage;
  dynamic authorImage;
  int? isFeatured;
  int? isVote;
  int? isBookmarked;
  int? isVotingEnabled;
  dynamic yesPercent;
  dynamic noPercent;
  int? viewCount;
  String? url;
  int? status;
  DateTime? createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  String? authorName;
  String? time;
  String? categoryName;
  String? categoryColor;
  String? type;
  dynamic createDate;
  String? slug;
  String? voice;
  int? categoryId;
  int? authorId;
  int? postId;
  String? tags;
  dynamic audioFile;
  String? scialMediaImage;
  int? isVotingEnable;
  String? votingQuestion;
  int? optiontype;
  int? tweetPublished;
  String? seoTitle;
  String? seoKeyword;
  String? seoTag;
  String? seoDescription;
  int? isSlider;
  int? isEditorPicks;
  int? isWeeklyTopPicks;
  int? createdBy;
  String? scheduleDate;
  dynamic order;
  String? languageCode;
  int? isBookmark;
  String? image;
  String? color;
  int? frequency;
  String? startDate;
  String? endDate;
  int? view;
  int? click;
  int? clickCount;
  List<Section>? section;

  factory DataModel.fromMap(Map<String, dynamic> json) => DataModel(
        id: json["id"],
        title: json["title"],
        shortDescription: json["short_description"],
        description: json["description"],
        trimedDescription: json["trimed_description"],
        thumbImage: json["thumb_image"],
        bannerImage: json["banner_image"],
        authorImage: json["image"],
        isFeatured: json["is_featured"],
        isVote: json["is_vote"],
        isBookmarked: json["is_bookmark"],
        isVotingEnabled: json["is_voting_enable"],
        yesPercent: json["yes_percent"],
        noPercent: json["no_percent"],
        viewCount: json["view_count"],
        url: json["url"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        authorName: json["author_name"],
        time: json["time"],
        categoryName: json["category_name"],
        categoryColor: json["color"],
        createDate: json["create_date"],
        videoUrl: json['video_url'],
        contentType: json['content_type'],
        blogAccentCode: json['blog_accent_code'],
        type: json['type'],
        slug: json['slug'],
        voice: json['voice'],
        categoryId: json['category_id'],
        authorId: json['author_id'],
        postId: json['post_id'],
        tags: json['tags'],
        audioFile: json['audio_file'],
        scialMediaImage: json['scial_media_image'],
        isVotingEnable: json['is_voting_enable'],
        votingQuestion: json['VotingQuestion'],
        optiontype: json['optiontype'],
        tweetPublished: json['tweet_published'],
        seoTitle: json['seo_title'],
        seoKeyword: json['seo_keyword'],
        seoTag: json['seo_tag'],
        seoDescription: json['seo_description'],
        isSlider: json['is_slider'],
        isEditorPicks: json['is_editor_picks'],
        isWeeklyTopPicks: json['is_weekly_top_picks'],
        createdBy: json['created_by'],
        scheduleDate: json['schedule_date'],
        order: json['order'],
        languageCode: json['language_code'],
        isBookmark: json['is_bookmark'],
        image: json['image'],
        color: json['color'],
        frequency: json['frequency'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        view: json['view'],
        click: json['click'],
        clickCount: json['click_count'],
        blogCategory: json["blog_category"] != null
            ? List<BlogSubCategory>.from(
                json["blog_category"].map((x) => BlogSubCategory.fromMap(x)))
            : null,
        section: json["section"] != null
            ? List<Section>.from(
                json["section"].map((x) => Section.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "short_description": shortDescription,
        "description": description,
        "trimed_description": trimedDescription,
        "thumb_image": thumbImage,
        "banner_image": bannerImage,
        //List<dynamic>.from(bannerImage.map((x) => x)),
        "image": authorImage,
        "is_featured": isFeatured,
        "is_vote": isVote,
        "is_bookmark": isBookmarked,
        "is_voting_enable": isVotingEnabled,
        "yes_percent": yesPercent,
        "no_percent": noPercent,
        "view_count": viewCount,
        "url": url,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "author_name": authorName,
        "time": time,
        "category_name": categoryName,
        "color": categoryColor,
        "create_date": createDate,
        "blog_accent_code": blogAccentCode,
        "type": type,
        'slug': slug,
        'voice': voice,
        'category_id': categoryId,
        'author_id': authorId,
        'post_id': postId,
        'tags': tags,
        'audio_file': audioFile,
        'scial_media_image': scialMediaImage,
        'is_voting_enable': isVotingEnable,
        'VotingQuestion': votingQuestion,
        'optiontype': optiontype,
        'tweet_published': tweetPublished,
        'seo_title': seoTitle,
        'seo_keyword': seoKeyword,
        'seo_tag': seoTag,
        'seo_description': seoDescription,
        'is_slider': isSlider,
        'is_editor_picks': isEditorPicks,
        'is_weekly_top_picks': isWeeklyTopPicks,
        'created_by': createdBy,
        'schedule_date': scheduleDate,
        'order': order,
        'language_code': languageCode,
        'is_bookmark': isBookmark,
        'image': image,
        'color': color,
        'frequency': frequency,
        'start_date': startDate,
        'end_date': endDate,
        'view': view,
        'click': click,
        'click_count': clickCount,
        "section": List<dynamic>.from(section!.map((x) => x.toJson())),
      };
}

class Section {
  int? id;
  int? adID;
  int? imgOrder;
  String? originalName;
  String? storedName;
  String? location;
  String? extension;
  String? size;
  String? redirectUrl;
  String? createdAt;
  String? updatedAt;
  String? status;

  Section(
      {this.id,
      this.adID,
      this.imgOrder,
      this.originalName,
      this.storedName,
      this.location,
      this.extension,
      this.size,
      this.redirectUrl,
      this.createdAt,
      this.updatedAt,
      this.status});

  Section.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adID = json['adID'];
    imgOrder = json['img_order'];
    originalName = json['original_name'];
    storedName = json['stored_name'];
    location = json['location'];
    extension = json['extension'];
    size = json['size'];
    redirectUrl = json['redirectUrl'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['adID'] = adID;
    data['img_order'] = imgOrder;
    data['original_name'] = originalName;
    data['stored_name'] = storedName;
    data['location'] = location;
    data['extension'] = extension;
    data['size'] = size;
    data['redirectUrl'] = redirectUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['status'] = status;
    return data;
  }
}
