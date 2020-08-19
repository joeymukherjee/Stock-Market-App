import 'package:flutter/material.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/shared/colors.dart';
import 'package:sma/shared/styles.dart';
import 'package:sma/bloc/portfolio/folder_bloc.dart';
import 'package:sma/helpers/text/text_helper.dart';
import 'package:sma/helpers/color/color_helper.dart';

class PortfolioFolderCard extends StatelessWidget {

  final PortfolioFolderModel data;

  PortfolioFolderCard({
    @required this.data
  });

  static const _kFolderNameStyle = const TextStyle(
    color: Color(0XFFc2c2c2),
    fontSize: 18,
    height: 1
  );

  @override
  Widget build(BuildContext context) {
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
          BlocProvider
            .of<PortfolioFolderBloc>(context)
            .add(FetchPortfolioFolderData());

          // Go to portfolio folder contents.
          //Navigator.push(context, MaterialPageRoute(builder: (_) => PortfolioFolder(name: data.name)));
        },
      ),
    );
  }

  Widget _buildFolderData() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: 100.0, child: Text(data.name, style: _kFolderNameStyle)),
        data.change != null ? Text(determineTextBasedOnChange(data.change), style: determineTextStyleBasedOnChange(data.change)) : Text (''),
        data.changePercentage != null ? Text(determineTextPercentageBasedOnChange(data.changePercentage), style: determineTextStyleBasedOnChange(data.changePercentage)) : Text ('')
      ], 
    );
  }
}
