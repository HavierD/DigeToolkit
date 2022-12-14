///this locker need 1 key to open, and 2 keys to close.
class DataGrabberLocker{
  bool _isOpening = false;
  bool _hasOneCloseKey = false;

  bool get isOpening{
    return _isOpening;
  }

  void _close(){
    _isOpening = false;
  }

  void open(){
    _isOpening = true;
  }

  void _clearCloseKey(){
    _hasOneCloseKey = false;
  }

  void findOneCloseKey(){
    if(_hasOneCloseKey){
      _close();
      _clearCloseKey();
      return;
    }
    _hasOneCloseKey = true;
  }

}