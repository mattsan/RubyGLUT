require 'fiddle/import'

class GLUT
  module Lib
    extend Fiddle::Importer
    dlload '/System/Library/Frameworks/GLUT.framework/GLUT'

    GLUT_STROKE_ROMAN = import_symbol 'glutStrokeRoman'
    GLUT_STROKE_MONO_ROMAN = import_symbol 'glutStrokeMonoRoman'

    extern 'void glutInit(int *argcp, char **argv)'
    extern 'void glutInitDisplayMode(unsigned int mode)'
    extern 'void glutInitDisplayString(const char *string)'
    extern 'void glutInitWindowPosition(int x, int y)'
    extern 'void glutInitWindowSize(int width, int height)'
    extern 'void glutMainLoop(void)'
    extern 'int glutCreateWindow(const char *title)'
    extern 'void glutSwapBuffers(void)'
    extern 'void glutDisplayFunc(void (*func)(void))'
    extern 'void glutReshapeFunc(void (*func)(int width, int height))'
    extern 'void glutKeyboardFunc(void (*func)(unsigned char key, int x, int y))'
    extern 'void glutTimerFunc(unsigned int millis, void (*func)(int value), int value)'
    extern 'void glutSpecialFunc(void (*func)(int key, int x, int y))'
    extern 'void glutStrokeCharacter(void *font, int character)'
  end

  GLUT_RGB          = 0
  RGBA              = GLUT_RGB
  DOUBLE            = 2
  KEY_LEFT          = 100
  KEY_UP            = 101
  KEY_RIGHT         = 102
  KEY_DOWN          = 103
  STROKE_ROMAN      = Lib::GLUT_STROKE_ROMAN
  STROKE_MONO_ROMAN = Lib::GLUT_STROKE_MONO_ROMAN

  class << self
    def create_window(title)
      Lib.glutCreateWindow(title)
    end

    def init(arg)
      Lib.glutInit([arg.size].pack('i*'), arg.pack('p*'))
    end

    def init_display_mode(mode)
      Lib.glutInitDisplayMode(mode)
    end

    def init_window_position(x, y)
      Lib.glutInitWindowPosition(x, y)
    end

    def init_window_size(width, height)
      Lib.glutInitWindowSize(width, height)
    end

    def stroke_character(font, character)
      Lib.glutStrokeCharacter(font, character.ord)
    end

    def swap_buffers
      Lib.glutSwapBuffers
    end

    def timer(callback, value)
      if callback.timer(value)
        Lib.glutTimerFunc(callback.interval, Lib.bind('void func(int value)') {|value| GLUT.timer(callback, value) }, 0)
      end
    end

    def main_loop(callback)
      display_handler = Lib.bind('void func(void)') { callback.display }
      keyboard_handler = Lib.bind('void func(unsigned char key, int x, int y)') {|key, x, y| callback.keyboard(key, x, y) }
      reshape_handler = Lib.bind('void func(int width, int height)') {|width, height| callback.reshape(width, height) }
      special_handler = Lib.bind('void func(int key, int x, int y)') {|key, x, y| callback.special(key, x, y) }
      timer_handler = Lib.bind('void func(int value)') {|value| GLUT.timer(callback, value) }

      Lib.glutDisplayFunc(display_handler)
      Lib.glutKeyboardFunc(keyboard_handler)
      Lib.glutReshapeFunc(reshape_handler)
      Lib.glutSpecialFunc(special_handler)
      Lib.glutTimerFunc(callback.interval, timer_handler, 0)

      Lib.glutMainLoop
    end
  end
end
