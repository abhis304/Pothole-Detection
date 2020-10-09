import 'package:bloc/bloc.dart';
import 'package:pothole/screen/HomeScreen.dart';
import 'package:pothole/screen/account_page.dart';
import 'package:pothole/screen/order_page.dart';

enum NavigationEvents {
  HomePageClickEvent,
  MyAccountPageClickEvent,
  MyOrdersPageClickEvent,
}

abstract class NavigationState {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationState> {
  NavigationBloc(NavigationState initialState) : super(initialState);

  @override
  NavigationState get initialState => HomeScreen();

  @override
  Stream<NavigationState> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.HomePageClickEvent:
        yield HomeScreen();
        break;
      case NavigationEvents.MyAccountPageClickEvent:
        yield AccountPage();
        break;
      case NavigationEvents.MyOrdersPageClickEvent:
        yield OrderPage();
        break;
    }
  }
}
