import 'package:flutter/material.dart';
import 'reactions_box_item.dart';
import 'reactions_position.dart';
import 'reaction.dart';
import 'utils.dart';

class ReactionsBox extends StatefulWidget {
  final Offset buttonOffset;

  final Size buttonSize;

  final List<Reaction> reactions;

  final position;

  final Color color;

  final double elevation;

  final double radius;

  final Duration duration;

  const ReactionsBox({
    @required this.buttonOffset,
    @required this.buttonSize,
    @required this.reactions,
    @required this.position,
    this.color = Colors.white,
    this.elevation = 5,
    this.radius = 50,
    this.duration = const Duration(milliseconds: 200),
  })  : assert(buttonOffset != null),
        assert(buttonSize != null),
        assert(reactions != null),
        assert(position != null);

  @override
  _ReactionsBoxState createState() => _ReactionsBoxState();
}

class _ReactionsBoxState extends State<ReactionsBox>
    with TickerProviderStateMixin {
  AnimationController _scaleController;

  Animation<double> _scaleAnimation;

  double _scale = 0;

  Reaction _selectedReaction;

  @override
  void initState() {
    super.initState();

    _scaleController =
        AnimationController(vsync: this, duration: widget.duration);

    final Tween<double> startTween = Tween(begin: 0, end: 1);
    _scaleAnimation = startTween.animate(_scaleController)
      ..addListener(() {
        setState(() {
          _scale = _scaleAnimation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.reverse)
          Navigator.of(context).pop(_selectedReaction);
      });

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Hide box when clicking out
      onTap: () => _scaleController.reverse(),
      child: Container(
        height: double.infinity,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: _getPosition(context),
              child: GestureDetector(
                child: Transform.scale(
                  scale: _scale,
                  child: Card(
                    color: widget.color,
                    elevation: widget.elevation,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(widget.radius)),
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: widget.reactions
                          .map((reaction) => ReactionsBoxItem(
                                onReactionClick: (reaction) {
                                  _selectedReaction = reaction;
                                  _scaleController.reverse();
                                },
                                reaction: reaction,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getPosition(BuildContext context) {
    if (_getTopPosition() - widget.buttonSize.height * 2 < 0)
      return _getBottomPosition();
    if (_getBottomPosition() + widget.buttonSize.height * 2 >
        getScreenSize(context).height) return _getTopPosition();
    return widget.position == Position.TOP
        ? _getTopPosition()
        : _getBottomPosition();
  }

  double _getTopPosition() =>
      widget.buttonOffset.dy - widget.buttonSize.height * 3.3;

  double _getBottomPosition() =>
      widget.buttonOffset.dy + widget.buttonSize.height;
}
