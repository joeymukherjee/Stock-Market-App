
import 'package:flutter/material.dart';
import 'package:sma/widgets/widgets/base_list.dart';
import 'package:sma/models/storage/portfolio_folder_storage.dart';
import 'package:sma/widgets/portfolio/widgets/save_portfolio_folder.dart';
// import 'package:sma/widgets/portfolio/widgets/heading/add_portfolio.dart';

class AddPortfolioFolderSection extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AddPortfolioFolderSection> {
  String name = '';
  bool exclude = false;
  // String get getPortfolioName () { return name; }
  @override
  Widget build(BuildContext context) {
    return BaseList(
      children: [
        // AddPortfolioHeadingSection(name, exclude),
        Padding(
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
        ),
        Text("Name:"),
        TextField(
          decoration: InputDecoration (hintText: 'portfolio name'), 
          showCursor: true, 
          onSubmitted: (String value) async {
            setState(() {
              name = value;            
              print (name);  
            });
        }),
        Row(
          children: [
            Text("Exclude from Total:"),
            Switch(value: exclude, onChanged: (bool value) {
               setState (() {
                 exclude = value;
                });
            }),
          ],
        ),
      ]
    );
  }
}