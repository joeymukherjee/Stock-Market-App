import 'package:flutter/material.dart';
import 'package:sma/widgets/portfolio/widgets/save_portfolio_folder.dart';

class ModifyPortfolioHeadingSection extends StatelessWidget {
  final String _prefix;
  ModifyPortfolioHeadingSection(this._prefix);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Icon(Icons.arrow_back_ios),
              onTap: () => Navigator.pop(context) 
            ),
            Text(_prefix + ' Portfolio', 
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                )
              ),
            SavePortfolioWidget ()
          ],
        ),
    );
  }
}