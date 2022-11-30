import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class CardItem extends StatefulWidget {
  final int index;
  final DataModel item;
  final Blog blogs;
  const CardItem(this.item, this.index, this.blogs);

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 10.0),
      child: SizedBox(
        height: 0.4 * MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.65,
        // decoration: BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       blurRadius: 7.0,
        //       color: Colors.black38.withOpacity(0.1),
        //       spreadRadius: 5.0,
        //       offset: Offset(0.0, 10.0),
        //     ),
        //   ],
        // ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: buildStack(context),
        ),
      ),
    );
  }

  buildStack(BuildContext context) {
    //_viewPost();
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: widget.item.bannerImage != null
              ? CachedNetworkImage(
                  imageUrl: widget.item.bannerImage[0],
                  fit: BoxFit.cover,
                  cacheKey: widget.item.bannerImage[0],
                )
              : Image.asset(
                  'assets/img/home1.jpg',
                  fit: BoxFit.cover,
                ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ),
        _buildTextAndUser(context),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                blogListHolder.clearList();
                blogListHolder.setList(widget.blogs);
                blogListHolder.setIndex(widget.index);
                print(
                    'title is ${blogListHolder.getList().data![widget.index].title}');
                print('item blog is ${widget.item.title}');

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SwipeablePage(widget.index, isFromFeatured: true),
                ));
                //  Navigator.pushNamed(context, '/ReadBlog', arguments: item);
              },
            ),
          ),
        ),
      ],
    );
  }

  _buildTextAndUser(context) {
    print(widget.item.viewCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.only(
        //     right: 13.0,
        //     top: 5.0,
        //   ),
        //   child: Container(
        //     alignment: Alignment.topRight,
        //     child: Opacity(
        //       opacity: 0.6,
        //       child: ButtonTheme(
        //         minWidth: 0.07 * MediaQuery.of(context).size.width,
        //         height: 0.04 * MediaQuery.of(context).size.height,
        //         child: RaisedButton(
        //           padding: EdgeInsets.only(
        //             right: 8,
        //             left: 8,
        //           ),
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(10.0)),
        //           onPressed: () {
        //             Navigator.of(context).pushReplacementNamed('/HomeClonePage',
        //                 arguments: false);
        //           },
        //           color: Colors.black,
        //           child: Wrap(
        //             children: [
        //               Icon(
        //                 Mdi.eye,
        //                 color: Colors.white,
        //                 size: 18.0,
        //               ),
        //               Padding(
        //                 padding: const EdgeInsets.only(top: 0.0),
        //                 child: Text(
        //                   " " + widget.item.viewCount.toString(),
        //                   style: Theme.of(context).textTheme.bodyText1?.merge(
        //                         TextStyle(
        //                             color: Colors.white,
        //                             fontFamily: 'Montserrat',
        //                             fontSize: 16.0,
        //                             fontWeight: FontWeight.normal),
        //                       ),
        //                   //style: TextStyle(fontSize: 16.0, color: Colors.white),
        //                 ),
        //               ),
        //             ],
        //             // child: Text(
        //             //   "SKIP",
        //             //   style: TextStyle(fontSize: 20.0, color: Colors.white),
        //           ),
        //         ),
        //       ),
        //     ),
        //     // Wrap(
        //     //   children: [
        //     //     Padding(
        //     //       padding: const EdgeInsets.only(top: 2.0),
        //     //       child: Icon(
        //     //         Mdi.eye,
        //     //         color: Colors.white,
        //     //         size: 16.0,
        //     //       ),
        //     //     ),
        //     //     Padding(
        //     //       padding: const EdgeInsets.only(top: 0),
        //     //       child: Text(
        //     //         " " + item.viewCount.toString(),
        //     //         style: Theme.of(context).textTheme.bodyText1.merge(
        //     //               TextStyle(
        //     //                   color: Colors.white,
        //     //                   fontFamily: 'Montserrat',
        //     //                   fontSize: 16.0,
        //     //                   fontWeight: FontWeight.bold),
        //     //             ),
        //     //         //style: Theme.of(context).textTheme.headline3,
        //     //       ),
        //     //     ),
        //     //   ],
        //     // ),
        //   ),
        // ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 1.5),
          child: Text(
            widget.item.title.toString(),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText1?.merge(
                  const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
            //style: Theme.of(context).textTheme.headline3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 20.0, bottom: 20.0),
          child: widget.item.blogCategory != null
              ? Row(
                  children: <Widget>[
                    Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                          color: HexColor(
                              widget.item.blogCategory![0].category!.color ??
                                  '#fffff'),
                          //color: Colors.orange,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.white30,
                                spreadRadius: 1,
                                blurRadius: 4)
                          ]),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(5.0),
                    //   child: CircleAvatar(
                    //       radius: 10,
                    //       backgroundImage: NetworkImage(item.authorImage)),
                    // ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.item.blogCategory![0].category!.name.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 13.0,
                                fontWeight: FontWeight.normal),
                          ),
                      //style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: HexColor(widget.item.categoryColor ?? '#00000'),
                        //color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(5.0),
                    //   child: CircleAvatar(
                    //       radius: 10,
                    //       backgroundImage: NetworkImage(item.authorImage)),
                    // ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.item.categoryName.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 13.0,
                                fontWeight: FontWeight.normal),
                          ),
                      //style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
