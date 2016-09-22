require 'fiddle/import'

class GL
  module Lib
    extend Fiddle::Importer
    dlload '/System/Library/Frameworks/OpenGL.framework/OpenGL'

    typealias('GLenum', 'unsigned int')
    typealias('GLint', 'int')
    typealias('GLuint', 'unsigned int')
    typealias('GLbitfield', 'unsigned int')
    typealias('GLdouble', 'double')
    typealias('GLfloat', 'float')
    typealias('GLclampf', 'float')
    typealias('GLclampd', 'double')

    extern 'void glBegin(GLenum mode)'
    extern 'void glClear(GLbitfield mask)'
    extern 'void glClearAccum(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)'
    extern 'void glClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)'
    extern 'void glClearDepth(GLclampd depth)'
    extern 'void glClearIndex(GLfloat c)'
    extern 'void glClearStencil(GLint s)'
    extern 'void glColor3d(GLdouble red, GLdouble green, GLdouble blue)'
    extern 'void glColor3dv(const GLdouble *v)'
    extern 'void glEnd(void)'
    extern 'void glEndList(void)'
    extern 'void glFlush(void)'
    extern 'void glLoadIdentity(void)'
    extern 'void glOrtho(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)'
    extern 'void glPopMatrix(void)'
    extern 'void glPushMatrix(void)'
    extern 'void glScalef(GLfloat x, GLfloat y, GLfloat z)'
    extern 'void glTranslatef(GLfloat x, GLfloat y, GLfloat z)'
    extern 'void glVertex2i(GLint x, GLint y)'
    extern 'void glVertex2iv(const GLint *v)'
    extern 'void glViewport(GLint x, GLint y, GLint width, GLint height)'
    extern 'void glBeginQuery(GLenum target, GLuint id)'
    extern 'void glEndQuery(GLenum target)'
  end

  POINTS              = 0x0000
  LINES               = 0x0001
  LINE_LOOP           = 0x0002
  LINE_STRIP          = 0x0003
  TRIANGLES           = 0x0004
  TRIANGLE_STRIP      = 0x0005
  TRIANGLE_FAN        = 0x0006
  QUADS               = 0x0007
  QUAD_STRIP          = 0x0008
  POLYGON             = 0x0009

  CURRENT_BIT         = 0x00000001
  POINT_BIT           = 0x00000002
  LINE_BIT            = 0x00000004
  POLYGON_BIT         = 0x00000008
  POLYGON_STIPPLE_BIT = 0x00000010
  PIXEL_MODE_BIT      = 0x00000020
  LIGHTING_BIT        = 0x00000040
  FOG_BIT             = 0x00000080
  DEPTH_BUFFER_BIT    = 0x00000100
  ACCUM_BUFFER_BIT    = 0x00000200
  STENCIL_BUFFER_BIT  = 0x00000400
  VIEWPORT_BIT        = 0x00000800
  TRANSFORM_BIT       = 0x00001000
  ENABLE_BIT          = 0x00002000
  COLOR_BUFFER_BIT    = 0x00004000
  HINT_BIT            = 0x00008000
  EVAL_BIT            = 0x00010000
  LIST_BIT            = 0x00020000
  TEXTURE_BIT         = 0x00040000
  SCISSOR_BIT         = 0x00080000
  ALL_ATTRIB_BITS     = 0x000fffff

  class << self
    def primitive(mode)
      Lib.glBegin(mode)
      yield
      Lib.glEnd
    end

    def clear(mask)
      Lib.glClear(mask)
    end

    def clear_color(red, green, blue, alpha)
      Lib.glClearColor(red, green, blue, alpha)
    end

    def color3d(red, green, blue)
      Lib.glColor3d(red, green, blue)
    end

    def color3dv(rgb)
      Lib.glColor3dv(rgb.pack('d*'))
    end

    def flush
      Lib.glFlush
    end

    def load_identity
      Lib.glLoadIdentity
    end

    def ortho(left, right, bottom, top, z_near, z_far)
      Lib.glOrtho(left, right, bottom, top, z_near, z_far)
    end

    def pop_matrix
      Lib.glPopMatrix
    end

    def push_matrix
      Lib.glPushMatrix
    end

    def scalef(x, y, z)
      Lib.glScalef(x, y, z)
    end

    def translatef(x, y, z)
      Lib.glTranslatef(x, y, z)
    end

    def vertex2i(x, y)
      Lib.glVertex2i(x, y)
    end

    def viewport(x, y, width, height)
      Lib.glViewport(x, y, width, height)
    end
  end
end
