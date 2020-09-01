import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/widgets/about/attributions/attributions.dart';
import 'package:sma/bloc/settings/settings_bloc.dart';

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('About'),
          backgroundColor: Colors.indigo,
          bottom: TabBar(
            indicatorColor: Color(0X881f1f1f),
            indicatorPadding: EdgeInsets.symmetric(horizontal: 25),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Information',),
              Tab(text: 'Settings',),
            ],
          ),
        ),

        body: SafeArea(
          child: BlocBuilder <SettingsBloc, SettingsState> (
            builder: (context, state) {
              return TabBarView(
                children: <Widget>[
                  Attributions(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text ("Dark Mode Theme:", style: Theme.of(context).textTheme.caption),
                        Switch.adaptive(
                          value: state.isNight,
                          onChanged: (bool) => {
                            BlocProvider
                            .of<SettingsBloc>(context)
                            .add(ToggledThemeEvent())
                          }
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
          )
        )
      ),
    );
  }
}