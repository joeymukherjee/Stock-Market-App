import 'package:flutter/material.dart';
import 'package:sma/widgets/portfolio/widgets/save_portfolio_folder.dart';
import 'package:sma/models/storage/portfolio_folders_storage.dart';

class AddPortfolioHeadingSection extends StatelessWidget {

  final String name;
  final bool exclude;

  AddPortfolioHeadingSection(this.name, this.exclude);

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
            Text('Add Portfolio', 
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                )
              ),
            SavePortfolioWidget (
              name: name, exclude: exclude, 
              storageModel: PortfolioFoldersStorageModel (
                name: name, exclude: exclude
              )
            ),
          ],
        ),
    );
  }
}