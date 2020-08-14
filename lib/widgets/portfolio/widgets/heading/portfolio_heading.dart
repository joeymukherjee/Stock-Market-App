
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:sma/widgets/widgets/standard/header.dart';

class PortfolioHeadingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: StandardHeader(
        title: 'Portfolios',
        subtitle: '',
        action: GestureDetector(
          child: Icon(FontAwesomeIcons.edit),
          onTap: () => Navigator.pushNamed(context, '/edit_portfolio_folder')
        ),
      ),
    );
  }
}