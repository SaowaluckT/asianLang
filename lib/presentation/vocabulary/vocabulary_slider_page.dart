import 'package:flutter/material.dart';
import 'package:my_app/presentation/vocabulary/vocabulary_edit_content_page.dart';
import '../../../models/keyword_model.dart';
import '../../../models/notebook_model.dart';
import '../widgets/vocabulary_frame_page.dart';

class VocabularySliderPage extends StatefulWidget {
  final List<NotebookModel> listNotebook;
  final NotebookModel vocabulary;

  const VocabularySliderPage({super.key,
    required this.listNotebook,
    required this.vocabulary});

  @override
  State<VocabularySliderPage> createState() => _VocabularySliderPageState();
}

class _VocabularySliderPageState extends State<VocabularySliderPage> with SingleTickerProviderStateMixin{
  PageController _controller = PageController(initialPage: 0);
  // List<NotebookModel> _listNotebook = [];
  late NotebookModel _vocabulary;
  int _currentIndex = 0;
  int _currentPage = 1;
  int? _nextPage;
  int? _previouePage;
  // WordHistoryModel


  @override
  void initState() {
    // _listNotebook = widget.listNotebook;
    _vocabulary = widget.vocabulary;
    _currentIndex = 0;
   if( _vocabulary.listWordTransalte?.isEmpty ?? true) {
     _currentPage = 0;
     _nextPage = null;
     _previouePage = null;
   } else {
     _currentPage = 1;
     _previouePage = null;
     _nextPage = 1;
   }
    // WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
    setState(() {

    });
    super.initState();
  }

  void _animateSlider() {
    _controller = PageController(initialPage: 0,);

    Future.delayed(const Duration(milliseconds: 1800)).then((_) {
      int nextPage = 0;
      if((_controller.page??0) > 0) {
        nextPage = _controller.page!.round() + 1;
        _nextPage = nextPage;
        _previouePage = (_controller.page!.round())-1;
      }
      if (nextPage == _vocabulary.listWordTransalte?.length) {
      // if (nextPage == _listNotebook.length) {
        nextPage = 0;
        _nextPage = null;
        _previouePage = (_controller.page!.round())-1;
      }

      _controller.animateToPage(nextPage, duration: const Duration(milliseconds: 800), curve: Curves.linear);
      // _controller.animateToPage(nextPage, duration: const Duration(milliseconds: 800), curve: Curves.linear)
      //     .then((_) => _animateSlider());
    });
  }

  void _animateSliderToPage(int page) {
    print("_animateSliderToPage >> page: $page");

    _controller.animateToPage(page, duration: const Duration(milliseconds: 600), curve: Curves.linear);

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text('$_currentPage/${_vocabulary.listWordTransalte?.length ?? 0}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VocabularyEditContentPage(
                    listNotebook: widget.listNotebook,
                    notebookVocabulary: _vocabulary ?? widget.vocabulary,
                    keywordContent: _vocabulary.listWordTransalte![_currentPage-1],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: (_vocabulary.listWordTransalte?.isEmpty ?? true) ? Container() : Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                _currentIndex = index;
                _currentPage = (index+1);

                _nextPage = _currentPage+1;
                _previouePage = (_currentPage-1) < 0 ? null : (_currentPage-1);

                if(_nextPage == ( _vocabulary.listWordTransalte?.length ?? 0)+1) {
                  _nextPage = null;
                }

                print(">> _currentPage: $_currentPage // _previouePage: $_previouePage // _nextPage: $_nextPage");

                setState(() {});

              },
              itemCount: _vocabulary.listWordTransalte?.length ?? 0,
              itemBuilder: (context, index) {
                KeywordModel vocabulary = _vocabulary.listWordTransalte![index]!;
                return VocabularyFramePage(vocabulary: vocabulary,);
              },
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              margin: EdgeInsets.fromLTRB(32, 24, 32, (MediaQuery.of(context).padding.bottom)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: (_previouePage == null || _currentIndex == 0)? null : () {
                      // print("back ${_controller.page} >> _currentPage: $_currentPage // _previouePage: $_previouePage");
                      _animateSliderToPage(_currentIndex-1);

                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _nextPage == null ? null : () {
                      // print("next ${_controller.page} >> _currentPage: $_currentPage // _nextPage: $_nextPage");
                      _animateSliderToPage(_currentIndex+1);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
