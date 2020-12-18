import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ucsi_mobile_web_attendance_system/screens/animation.dart';
import 'package:ucsi_mobile_web_attendance_system/screens/home_screen.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyStatefulWidget(),
    );
  }
}

const Duration _kExpand = Duration(milliseconds: 200);
enum AlignOpener { Left, Right }

class AdvancedExpansionTile extends StatefulWidget {
  const AdvancedExpansionTile({
    Key key,
    this.leading,
    this.trailing,
    @required this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.onTap,
    this.onLongPress,
    this.alignOpener,
    this.indentListTile,
    this.children = const <Widget>[],
    this.initiallyExpanded = false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color backgroundColor;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  /// A widget to display instead of a rotating arrow icon.
  final Widget trailing;

  /// A callback for onTap and onLongPress on the listTile
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  /// The side where the Open/Close-Icon/IconButton will be placed
  final AlignOpener alignOpener;

  /// indent of listTile (left)
  final indentListTile;

  @override
  _AdvancedExpansionTileState createState() => _AdvancedExpansionTileState();
}

class _AdvancedExpansionTileState extends State<AdvancedExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  AnimationController _controller;
  Animation<double> _iconTurns;
  Animation<double> _heightFactor;
  Animation<Color> _borderColor;
  Animation<Color> _headerColor;
  Animation<Color> _iconColor;
  Animation<Color> _backgroundColor;

  bool _isExpanded = false;

  /// If set to true an IconButton will be created. This button will open/close the children
  bool _isInAdvancedMode;
  AlignOpener _alignOpener;
  double _indentListTile;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _borderColor = _controller.drive(_borderColorTween.chain(_easeOutTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor =
        _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;

    /// OnTap or onLongPress are handled in the calling widget --> AdvancedExpansionTile is in Advanced Mode
    if (widget.onTap != null || widget.onLongPress != null) {
      _isInAdvancedMode = true;
    } else {
      _isInAdvancedMode = false;
    }

    /// fallback to standard behaviour if aligning isn't set
    _alignOpener = widget.alignOpener ?? AlignOpener.Right;

    /// if no indent is set the indent will be 0.0
    _indentListTile = widget.indentListTile ?? 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    final Color borderSideColor = _borderColor.value ?? Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor.value ?? Colors.transparent,
        border: Border(
          top: BorderSide(color: borderSideColor),
          bottom: BorderSide(color: borderSideColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value,
            textColor: _headerColor.value,
            child: ListTile(
              onTap: () {
                _isInAdvancedMode ? widget.onTap() : _handleTap();
              }, // in AdvancedMode a callback will handle the gesture inside the calling widget

              onLongPress: () {
                _isInAdvancedMode ? widget.onLongPress() : _handleTap();
              }, // in AdvancedMode a callback will handle the gesture inside the calling widget
              leading: getLeading(),
              title: widget.title,
              trailing: getTrailing(),
            ),
          ),
          ClipRect(
              child: Padding(
            padding: EdgeInsets.only(left: _indentListTile), // set the indent
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          )),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween..end = theme.dividerColor;
    _headerColorTween
      ..begin = theme.textTheme.subhead.color
      ..end = theme.accentColor;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    _backgroundColorTween..end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }

  /// A method to decide what will be shown in the leading part of the lisTile
  getLeading() {
    if (_alignOpener.toString() == AlignOpener.Left.toString() &&
        _isInAdvancedMode == true) {
      return buildIcon(); //IconButton will be created
    } else if (_alignOpener.toString() == AlignOpener.Left.toString() &&
        _isInAdvancedMode == false) {
      return widget.leading ??
          RotationTransition(
            turns: _iconTurns,
            child: const Icon(Icons.expand_more),
          );
    } else {
      return widget.leading;
    }
  }

  /// A method to decide what will be shown in the trailing part of the lisTile
  getTrailing() {
    if (_alignOpener.toString() == AlignOpener.Right.toString() &&
        _isInAdvancedMode == true) {
      return buildIcon(); //IconButton will be created
    } else if (_alignOpener.toString() == AlignOpener.Right.toString() &&
        _isInAdvancedMode == false) {
      return widget.trailing ??
          RotationTransition(
            turns: _iconTurns,
            child: const Icon(Icons.expand_more),
          );
    } else {
      return widget.leading;
    }
  }

  /// A widget to build the IconButton for the leading or trailing part of the listTile
  Widget buildIcon() {
    return Container(
        child: RotationTransition(
      turns: _iconTurns,
      child: IconButton(
        icon: Icon(Icons.expand_more),
        onPressed: () {
          _handleTap();
          //toDo: open/close is working but not the animation
        },
      ),
    ));
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _count = 0;
  var loadImg = new AssetImage(
      'images/spinner.gif');
  var profileImg = new NetworkImage(
  "https://www.phdmedia.com/singapore/wp-content/uploads/sites/24/2015/05/temp-people-profile.jpg");
  bool _checkLoaded = true;
  @override
  void initState() {
    profileImg.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((ImageInfo image, bool synchronousCall) {
      if (mounted) {
        setState(() {
          _checkLoaded = false;
        });
      }
    }));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Scaffold Example'),
        backgroundColor: Colors.pink[500],
      ),
      body: Center(
        child: Text('We have pressed the button $_count times.'),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _count++;
        }),
        tooltip: 'Increment Counter',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      drawer: Drawer(
        elevation: 50.0,
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink[400],
              ),
              accountName: Text("Cheah Wen"),
              accountEmail: Text("cheahwen@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _checkLoaded? profileImg:loadImg)),
            ListTile(
              title: new Text("Dashboard"),
              leading: new Icon(Icons.dashboard),
              onTap: () {
                print("Dashboard");
              },
            ),
            Divider(
              height: 0.1,
            ),
            AdvancedExpansionTile(
              title: new Text("Student"),
              indentListTile: 15.0,
              leading: new FaIcon(FontAwesomeIcons.users),
              children: [
                new ListTile(
                  title: new Text("List"),
                  onTap: () {
                    print("List");
                  },
                ),
                new ListTile(
                  title: new Text("Attendance"),
                  onTap: () {
                    print("Attendance");
                  },
                ),
              ],
            ),
            AdvancedExpansionTile(
              title: new Text("Lecturer"),
              indentListTile: 15.0,
              leading: new FaIcon(FontAwesomeIcons.userGraduate),
              children: [
                new ListTile(
                  title: new Text("List"),
                  onTap: () {
                    print("List");
                  },
                ),
                new ListTile(
                  title: new Text("Timetable Management"),
                  onTap: () {
                    print("Timetable Management");
                  },
                ),
              ],
            ),
            AdvancedExpansionTile(
              title: new Text("Course"),
              indentListTile: 15.0,
              leading: new Icon(FontAwesomeIcons.bookOpen),
              children: [
                new ListTile(
                  title: new Text("List"),
                  onTap: () {
                    print("List");
                  },
                ),
                new ListTile(
                  title: new Text("Enrolment"),
                  onTap: () {
                    print("Enrolment");
                  },
                ),
                new ListTile(
                  title: new Text("Timetable"),
                  onTap: () {
                    print("Timetable");
                  },
                ),
              ],
            ),
            ListTile(
              title: new Text("Camera"),
              leading: new FaIcon(FontAwesomeIcons.camera),
              onTap: () {
                print("Cam");
              },
            ),
            ListTile(
              title: new Text("Venues"),
              leading: new FaIcon(FontAwesomeIcons.building),
              onTap: () {
                print("Venues");
              },
            ),
            ListTile(
              title: new Text("Face Record"),
              leading: new FaIcon(FontAwesomeIcons.database),
              onTap: () {
                print("Record");
              },
            )
          ],
        ),
      ),
    );
  }
}
