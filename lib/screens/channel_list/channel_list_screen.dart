import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:sendbird_flutter/screens/channel_list/channel_list_view_model.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
// import 'package:universal_platform/universal_platform.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';
import '../channel/channel_screen.dart';
import 'components/channel_list_item.dart';

class ChannelListScreen extends StatefulWidget {
  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen>
    with ChannelEventHandler {
  ChannelListViewModel model = ChannelListViewModel();

  @override
  void initState() {
    super.initState();
    model.loadChannelList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: navigationBar(),
        body: p.ChangeNotifierProvider<ChannelListViewModel>(
          create: (context) => model,
          child: p.Consumer<ChannelListViewModel>(
            builder: (context, value, child) {
              return _buildList(value);
            },
          ),
        ),
      ),
      onWillPop: () async {
        print('disconnect');
        SendbirdSdk().disconnect();
        return true;
      },
    );
  }

  Widget navigationBar() {
    return AppBar(
      leading: BackButton(color: Theme.of(context).primaryColor),
      toolbarHeight: 65,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: Platform.isAndroid == true ? false : true,
      title: Text('Channels', style: TextStyles.sendbirdH2OnLight1),
      actions: [
        Container(
          width: 60,
          child: RawMaterialButton(
            padding: EdgeInsets.fromLTRB(0, 18, 0, 18),
            onPressed: () {
              Navigator.pushNamed(context, '/create_channel');
            },
            shape: CircleBorder(),
            child: Image.asset("assets/iconCreate@3x.png"),
          ),
        ),
      ],
      centerTitle: true,
    );
  }

  // build helpers

  Widget _buildList(ChannelListViewModel model) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await model.loadChannelList(reload: true);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: model.lstController,
        itemCount: model.itemCount,
        itemBuilder: (context, index) {
          if (index == model.groupChannels.length && model.hasNext) {
            return Container(
                color: Colors.white,
                child: Center(
                  child: Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                ));
          }

          final channel = model.groupChannels[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: InkWell(
              child: ChannelListItem(channel),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/channel',
                  arguments: channel,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
