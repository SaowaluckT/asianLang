import 'dart:async';


abstract class BaseViewModel {
  void start(); // will be called while init. of view model
  void dispose(); // will be called when viewmodel dies.
}
