import 'package:meta/meta.dart';

import 'framework/framework.dart';
import 'theme/theme.dart';

String _prompt(int x) => '';

class Progress extends Component<ProgressState> {
  Context _context;
  final Theme theme;
  final int length;
  final double size;
  final String Function(int) leftPrompt;
  final String Function(int) rightPrompt;

  Progress({
    @required this.length,
    this.size = 1.0,
    this.leftPrompt = _prompt,
    this.rightPrompt = _prompt,
  }) : theme = Theme.defaultTheme;

  Progress.withTheme({
    @required this.theme,
    @required this.length,
    this.size = 1.0,
    this.leftPrompt = _prompt,
    this.rightPrompt = _prompt,
  });

  @override
  _ProgressState createState() => _ProgressState();

  @override
  void disposeState(State state) {}

  @override
  State pipeState(State state) {
    if (_context != null) {
      state.setContext(_context);
    }

    return state;
  }

  void setContext(Context c) => _context = c;
}

class ProgressState {
  int current;
  void Function(int) increase;
  void Function() Function() done;

  ProgressState({
    @required this.current,
    @required this.increase,
    @required this.done,
  });
}

class _ProgressState extends State<Progress> {
  int current;
  bool done;

  @override
  void init() {
    super.init();
    current = 0;
    done = false;
    context.hideCursor();
  }

  @override
  void dispose() {
    context.wipe();
    context.showCursor();
    super.dispose();
  }

  @override
  void render() {
    final line = StringBuffer();
    final leftPrompt = component.leftPrompt(current);
    final rightPrompt = component.rightPrompt(current);
    final occupied = component.theme.progressPrefix.length +
        component.theme.progressSuffix.length +
        leftPrompt.length +
        rightPrompt.length;
    final available = (context.windowWidth * component.size).round() - occupied;

    line.write(leftPrompt);
    line.write(component.theme.progressPrefix);
    line.write(_progress(
      available,
      (available / component.length * current).round(),
      component.theme.emptyProgress,
      component.theme.filledProgress,
      component.theme.leadingProgress,
    ));
    line.write(component.theme.progressSuffix);
    line.write(rightPrompt);

    context.writeln(line.toString());
  }

  @override
  ProgressState interact() {
    final state = ProgressState(
      current: current,
      increase: (int n) {
        if (current < component.length) {
          setState(() {
            current += n;
          });
        }
      },
      done: () {
        setState(() {
          done = true;
        });

        if (component._context != null) {
          return dispose;
        } else {
          dispose();
          return () {};
        }
      },
    );

    return state;
  }

  String _progress(
    int length,
    int filled,
    String empty,
    String filler,
    String leader,
  ) {
    return ''
        .padRight(filled - 1, filler)
        .padRight(filled, filled == length ? filler : leader)
        .padRight(length, empty);
  }
}
