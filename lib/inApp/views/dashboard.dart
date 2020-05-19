import 'package:budgetControl/core/constants/app_image_constants.dart';
import 'package:budgetControl/core/init/locale_keys.g.dart';
import 'package:budgetControl/core/init/string_extensions.dart';
import 'package:budgetControl/core/view/base/base_state.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends BaseState<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentTheme.primaryColorLight,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: dynamicHeight(0.2),
            flexibleSpace: _getFlexSpace(),
          ),
          // If the main content is a list, use SliverList instead.
          SliverFillRemaining(
            hasScrollBody: false,
            child: _getBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 10,
        label: Text(LocaleKeys.appStrings_operations.locale),
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/operation');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _getFlexSpace() {
    return FlexibleSpaceBar(
      titlePadding: EdgeInsets.only(
        left: dynamicWidth(0.02),
        right: dynamicWidth(0.02),
        top: dynamicHeight(0.01),
        bottom: dynamicHeight(0.01),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/datainput');
            },
            child: Icon(
              Icons.dashboard,
              color: Colors.white,
              size: dynamicWidth(0.09),
            ),
          ),
          Text(
            LocaleKeys.appStrings_dashboard.locale,
            textAlign: TextAlign.center,
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Icon(
              Icons.supervised_user_circle,
              color: Colors.white,
              size: dynamicWidth(0.09),
            ),
          ),
        ],
      ),
      background: Image.network(
        ImagePath.instance.dashboardBackgroundNetwork,
        fit: BoxFit.fill,
      ),
    );
  }

  _getBody() {
    return Center(
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _getBodyInkwell(
              LocaleKeys.appStrings_dashboardItems_balance.locale, 'balance'),
          _getBodyInkwell(
              LocaleKeys.appStrings_dashboardItems_incomes.locale, 'incomes'),
          _getBodyInkwell(
              LocaleKeys.appStrings_dashboardItems_expenses.locale, 'expenses'),
          _getBodyInkwell(
              LocaleKeys.appStrings_dashboardItems_savings.locale, 'savings'),
          SizedBox(
            height: dynamicHeight(0.06),
          ),
        ],
      ),
    );
  }

  _getBodyInkwell(name, path) {
    return InkWell(
      autofocus: true,
      onTap: () {
        Navigator.pushNamed(context, '/$path');
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          dynamicWidth(0.02),
          dynamicWidth(0.03),
          dynamicWidth(0.02),
          dynamicWidth(0.03),
        ),
        height: dynamicHeight(0.15),
        width: double.maxFinite,
        child: Card(
          color: currentTheme.primaryColorDark,
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.all(dynamicWidth(0.03)),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                '$name'.toString().toUpperCase(),
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
