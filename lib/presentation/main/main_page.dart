import 'package:flutter/material.dart';
import 'package:my_app/presentation/home/home_page.dart';
import 'package:my_app/presentation/resources/color_manager.dart';
import 'package:my_app/presentation/resources/styles_manager.dart';

import '../notebook/notebooks_page.dart';
import '../vocabulary/vocabularies_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  PageController _pageController = PageController(initialPage: 0);
  int _page = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null) {
      }
    });
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (int value) {},
          itemBuilder: (BuildContext context, int index) {
            if(index == 0) {
              return const HomePage();
            } else if(index == 1) {
              return const NotebooksPage();
            } else if(index == 2) {
              return const VocabulariesPage();
            }
            return Center(
              child: Text("Page $index"),
            );
          }),
      bottomNavigationBar: BottomNavigationBar(
        useLegacyColorScheme: false,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _page,
        onTap: (tab) {
          _pageController.jumpToPage(tab);
          setState(() {
            _page = tab;
          });
        },
        elevation: 0,
        iconSize: 22,
        selectedFontSize: 11,
        selectedItemColor: ColorManager.primary,
        unselectedItemColor: Colors.black26,
        items: [
          BottomNavigationBarItem(
            label: "",
            icon: Text(
              "Home",
              style: getSemiBoldStyle(
                color: _page == 0 ? ColorManager.primary : Colors.black26,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Text(
              "Notebooks",
              style: getSemiBoldStyle(
                color: _page == 1 ? ColorManager.primary : Colors.black26,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Text(
              "Vocabularies",
              style: getSemiBoldStyle(
                color: _page == 2 ? ColorManager.primary : Colors.black26,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Text(
              "Memo3",
              style: getSemiBoldStyle(
                color: _page == 3 ? ColorManager.primary : Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
