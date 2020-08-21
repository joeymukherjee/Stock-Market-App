import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/shared/colors.dart';
import 'package:sma/shared/styles.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/helpers/color/color_helper.dart';
import 'package:sma/widgets/portfolio/widgets/modify_portfolio_folder.dart';

class ChangeBox extends StatelessWidget {
  final String label;
  final FolderChange data;
  ChangeBox ({@required this.label, @required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Company Name
          Text (label,
            style: TextStyle (
              fontSize: 8,
            ),
          ),

          // Change Amount
          data.change != null ? Text(determineTextBasedOnChange(data.change), style: determineTextStyleBasedOnChange(data.change)) : Text (''),
          // Change percentage.
          SizedBox(height: 5),
          data.changePercentage != null ? Text(determineTextPercentageBasedOnChange(data.changePercentage), style: determineTextStyleBasedOnChange(data.changePercentage)) : Text (''),
        ],
      );
  }
}

class PortfolioFolderCard extends StatelessWidget {

  final PortfolioFolderModel data;

  PortfolioFolderCard({
    @required this.data
  });

  static const _kFolderNameStyle = const TextStyle(
    color: Color(0XFFc2c2c2),
    fontSize: 12,
    height: 1
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioFoldersBloc, PortfolioFoldersState> (
      builder: (BuildContext context, PortfolioFoldersState state) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: MaterialButton(
            color: kTileColor,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(flex: 8, child: _buildFolderData()),
                ],
              ),
            ),

            shape: RoundedRectangleBorder(borderRadius: kStandatBorder),
            onPressed: () {

              // Trigger fetch event.
              if (state is PortfolioFoldersLoadedEditingState) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ModifyPortfolioFolderSection ('Edit', PortfolioFolderModel(key: data.key, order: data.order, exclude: data.exclude, name: data.name))));
              } else {
                BlocProvider
                  .of<PortfolioFoldersBloc>(context)
                  .add(FetchPortfolioFoldersData());
              }

              // Go to portfolio folder contents.
              //Navigator.push(context, MaterialPageRoute(builder: (_) => PortfolioFolder(name: data.name)));
            },
          ),
        );
      }
    );
  }

  Widget _buildFolderData() {
    return BlocBuilder<PortfolioFoldersBloc, PortfolioFoldersState> (
      builder: (BuildContext context, PortfolioFoldersState state) {
        if (state is PortfolioFoldersLoadedEditingState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.highlight_off, color: Colors.red),
                onTap: () {
                  Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Delete Portfolio",
                    desc: "Are you sure you wish to delete the portfolio " + data.name + "?",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          BlocProvider.of<PortfolioFoldersBloc>(context).add(DeleteFolder(name: data.name));
                          Navigator.pop(context);
                        },
                        color: Colors.red,
                      ),
                      DialogButton(
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.green
                      ),
                    ],
                  ).show();
                },
              ),
              Text(data.name, style: _kFolderNameStyle),
              Icon(Icons.menu) // TODO - figure out how to move rows in a list
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(width: 100.0, child: Text(data.name, style: _kFolderNameStyle)),
              ChangeBox (label: 'Daily', data: data.daily),
              ChangeBox (label: 'Overall', data: data.overall)
            ],
          );
        }
      }
    );
  }
}
