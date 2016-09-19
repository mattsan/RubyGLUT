require 'fiddle/import'

module GLUT
  extend Fiddle::Importer
  dlload '/System/Library/Frameworks/GLUT.framework/GLUT'

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
