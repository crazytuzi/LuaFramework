require "scripts/cocos2d/Cocos2dConstants"
require "scripts/cocos2d/OpenglConstants"
require "scripts/cocos2d/GuiConstants"
--Enums will be deprecated,begin
_G.kCCTextAlignmentLeft              = cc.TEXT_ALIGNMENT_LEFT
_G.kCCTextAlignmentRight             = cc.TEXT_ALIGNMENT_RIGHT
_G.kCCTextAlignmentCenter            = cc.TEXT_ALIGNMENT_CENTER
_G.kCCVerticalTextAlignmentTop       = cc.VERTICAL_TEXT_ALIGNMENT_TOP
_G.kCCVerticalTextAlignmentCenter    = cc.VERTICAL_TEXT_ALIGNMENT_CENTER    
_G.kCCVerticalTextAlignmentBottom    = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM
_G.kCCDirectorProjection3D           = cc.DIRECTOR_PROJECTION3_D 
_G.kCCDirectorProjection2D           = cc.DIRECTOR_PROJECTION2_D
_G.kCCDirectorProjectionCustom       = cc.DIRECTOR_PROJECTION_CUSTOM
_G.kCCDirectorProjectionDefault      = cc.DIRECTOR_PROJECTION_DEFAULT
_G.kCCNodeTagInvalid                 = cc.NODE_TAG_INVALID
_G.kCCNodeOnEnter                    = cc.NODE_ON_ENTER
_G.kCCNodeOnExit                     = cc.NODE_ON_EXIT
_G.kCCTexture2DPixelFormat_RGBA8888  = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888
_G.kCCTexture2DPixelFormat_RGB888    = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888
_G.kCCTexture2DPixelFormat_RGB565    = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565
_G.kCCTexture2DPixelFormat_A8        = cc.TEXTURE2_D_PIXEL_FORMAT_A8
_G.kCCTexture2DPixelFormat_I8        = cc.TEXTURE2_D_PIXEL_FORMAT_I8 
_G.kCCTexture2DPixelFormat_AI88      = cc.TEXTURE2_D_PIXEL_FORMAT_A_I88
_G.kCCTexture2DPixelFormat_RGBA4444  = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444 
_G.kCCTexture2DPixelFormat_RGB5A1    = cc.TEXTURE2_D_PIXEL_FORMAT_RGB5_A1 
_G.kCCTexture2DPixelFormat_PVRTC4    = cc.TEXTURE2_D_PIXEL_FORMAT_PVRTC4
_G.kCCTexture2DPixelFormat_PVRTC2    = cc.TEXTURE2_D_PIXEL_FORMAT_PVRTC2
_G.kCCTexture2DPixelFormat_Default   = cc.TEXTURE2_D_PIXEL_FORMAT_DEFAULT
_G.kCCImageFormatPNG                 = cc.IMAGE_FORMAT_PNG 
_G.kCCImageFormatJPEG                = cc.IMAGE_FORMAT_JPEG
_G.kCCTouchesOneByOne                = cc.TOUCHES_ONE_BY_ONE
_G.kCCTouchesAllAtOnce               = cc.TOUCHES_ALL_AT_ONCE
_G.kCCTransitionOrientationLeftOver  = cc.TRANSITION_ORIENTATION_LEFT_OVER
_G.kCCTransitionOrientationRightOver = cc.TRANSITION_ORIENTATION_RIGHT_OVER
_G.kCCTransitionOrientationUpOver    = cc.TRANSITION_ORIENTATION_UP_OVER
_G.kCCTransitionOrientationDownOver  = cc.TRANSITION_ORIENTATION_DOWN_OVER
_G.kCCActionTagInvalid               = cc.ACTION_TAG_INVALID
_G.kCCLabelAutomaticWidth            = cc.LABEL_AUTOMATIC_WIDTH
_G.kCCMenuStateWaiting               = cc.MENU_STATE_WAITING 
_G.kCCMenuStateTrackingTouch         = cc.MENU_STATE_TRACKING_TOUCH
_G.kCCMenuHandlerPriority            = cc.MENU_HANDLER_PRIORITY
_G.kCCParticleDurationInfinity       = cc.PARTICLE_DURATION_INFINITY 
_G.kCCParticleStartSizeEqualToEndSize = cc.PARTICLE_START_SIZE_EQUAL_TO_END_SIZE 
_G.kCCParticleStartRadiusEqualToEndRadius = cc.PARTICLE_START_RADIUS_EQUAL_TO_END_RADIUS
_G.kCCParticleModeGravity            = cc.PARTICLE_MODE_GRAVITY
_G.kCCParticleModeRadius             = cc.PARTICLE_MODE_RADIUS
_G.kCCPositionTypeFree               = cc.POSITION_TYPE_FREE 
_G.kCCPositionTypeRelative           = cc.POSITION_TYPE_RELATIVE
_G.kCCPositionTypeGrouped            = cc.POSITION_TYPE_GROUPED
_G.kCCProgressTimerTypeRadial        = cc.PROGRESS_TIMER_TYPE_RADIAL 
_G.kCCProgressTimerTypeBar           = cc.PROGRESS_TIMER_TYPE_BAR
_G.kCCTMXTileHorizontalFlag          = cc.TMX_TILE_HORIZONTAL_FLAG
_G.kCCTMXTileVerticalFlag            = cc.TMX_TILE_VERTICAL_FLAG
_G.kCCTMXTileDiagonalFlag            = cc.TMX_TILE_DIAGONAL_FLAG
_G.kCCFlipedAll                      = cc.FLIPED_ALL
_G.kCCFlippedMask                    = cc.FLIPPED_MASK
_G.kCCControlStepperPartMinus        = cc.CONTROL_STEPPER_PART_MINUS
_G.kCCControlStepperPartPlus         = cc.CONTROL_STEPPER_PART_PLUS
_G.kCCControlStepperPartNone         = cc.CONTROL_STEPPER_PART_NONE

_G.kLanguageEnglish  = cc.LANGUAGE_ENGLISH 
_G.kLanguageChinese  = cc.LANGUAGE_CHINESE 
_G.kLanguageFrench   = cc.LANGUAGE_FRENCH 
_G.kLanguageItalian  = cc.LANGUAGE_ITALIAN
_G.kLanguageGerman   = cc.LANGUAGE_GERMAN
_G.kLanguageSpanish  = cc.LANGUAGE_SPANISH
_G.kLanguageRussian  = cc.LANGUAGE_RUSSIAN
_G.kLanguageKorean   = cc.LANGUAGE_KOREAN
_G.kLanguageJapanese = cc.LANGUAGE_JAPANESE
_G.kLanguageHungarian = cc.LANGUAGE_HUNGARIAN
_G.kLanguagePortuguese = cc.LANGUAGE_PORTUGUESE
_G.kLanguageArabic     = cc.LANGUAGE_ARABIC
_G.kTargetWindows      = cc.PLATFORM_OS_WINDOWS
_G.kTargetLinux        = cc.PLATFORM_OS_LINUX 
_G.kTargetMacOS        = cc.PLATFORM_OS_MAC
_G.kTargetAndroid      = cc.PLATFORM_OS_ANDROID
_G.kTargetIphone       = cc.PLATFORM_OS_IPHONE
_G.kTargetIpad         = cc.PLATFORM_OS_IPAD 
_G.kTargetBlackBerry   = cc.PLATFORM_OS_BLACKBERRY

_G.GL_ZERO                           = gl.ZERO
_G.GL_ONE                            = gl.ONE
_G.GL_SRC_COLOR                      = gl.SRC_COLOR
_G.GL_ONE_MINUS_SRC_COLOR            = gl.ONE_MINUS_SRC_COLOR 
_G.GL_SRC_ALPHA                      = gl.SRC_ALPHA 
_G.GL_ONE_MINUS_SRC_ALPHA            = gl.ONE_MINUS_SRC_ALPHA
_G.GL_DST_ALPHA                      = gl.DST_ALPHA
_G.GL_ONE_MINUS_DST_ALPHA            = gl.ONE_MINUS_DST_ALPHA 
_G.GL_DST_COLOR                      = gl.DST_COLOR
_G.GL_ONE_MINUS_DST_COLOR            = gl.ONE_MINUS_DST_COLOR
_G.GL_RENDERBUFFER_INTERNAL_FORMAT = gl.RENDERBUFFER_INTERNAL_FORMAT
_G.GL_LINE_WIDTH = gl.LINE_WIDTH
_G.GL_CONSTANT_ALPHA = gl.CONSTANT_ALPHA
_G.GL_BLEND_SRC_ALPHA = gl.BLEND_SRC_ALPHA
_G.GL_GREEN_BITS = gl.GREEN_BITS
_G.GL_STENCIL_REF = gl.STENCIL_REF
_G.GL_ONE_MINUS_SRC_ALPHA = gl.ONE_MINUS_SRC_ALPHA
_G.GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = gl.FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE
_G.GL_CCW = gl.CCW
_G.GL_MAX_TEXTURE_IMAGE_UNITS = gl.MAX_TEXTURE_IMAGE_UNITS
_G.GL_BACK = gl.BACK
_G.GL_ACTIVE_ATTRIBUTES = gl.ACTIVE_ATTRIBUTES
_G.GL_TEXTURE_CUBE_MAP_POSITIVE_X = gl.TEXTURE_CUBE_MAP_POSITIVE_X
_G.GL_STENCIL_BACK_VALUE_MASK = gl.STENCIL_BACK_VALUE_MASK
_G.GL_TEXTURE_CUBE_MAP_POSITIVE_Z = gl.TEXTURE_CUBE_MAP_POSITIVE_Z
_G.GL_ONE = gl.ONE
_G.GL_TRUE = gl.TRUE
_G.GL_TEXTURE12 = gl.TEXTURE12
_G.GL_LINK_STATUS = gl.LINK_STATUS
_G.GL_BLEND = gl.BLEND
_G.GL_LESS = gl.LESS
_G.GL_TEXTURE16 = gl.TEXTURE16
_G.GL_BOOL_VEC2 = gl.BOOL_VEC2
_G.GL_KEEP = gl.KEEP
_G.GL_DST_COLOR = gl.DST_COLOR
_G.GL_VERTEX_ATTRIB_ARRAY_ENABLED = gl.VERTEX_ATTRIB_ARRAY_ENABLED
_G.GL_EXTENSIONS = gl.EXTENSIONS
_G.GL_FRONT = gl.FRONT
_G.GL_DST_ALPHA = gl.DST_ALPHA
_G.GL_ATTACHED_SHADERS = gl.ATTACHED_SHADERS
_G.GL_STENCIL_BACK_FUNC = gl.STENCIL_BACK_FUNC
_G.GL_ONE_MINUS_DST_COLOR = gl.ONE_MINUS_DST_COLOR
_G.GL_BLEND_EQUATION = gl.BLEND_EQUATION
_G.GL_RENDERBUFFER_DEPTH_SIZE = gl.RENDERBUFFER_DEPTH_SIZE
_G.GL_PACK_ALIGNMENT = gl.PACK_ALIGNMENT
_G.GL_VENDOR = gl.VENDOR
_G.GL_NEAREST_MIPMAP_LINEAR = gl.NEAREST_MIPMAP_LINEAR
_G.GL_TEXTURE_CUBE_MAP_POSITIVE_Y = gl.TEXTURE_CUBE_MAP_POSITIVE_Y
_G.GL_NEAREST = gl.NEAREST
_G.GL_RENDERBUFFER_WIDTH = gl.RENDERBUFFER_WIDTH
_G.GL_ARRAY_BUFFER_BINDING = gl.ARRAY_BUFFER_BINDING
_G.GL_ARRAY_BUFFER = gl.ARRAY_BUFFER
_G.GL_LEQUAL = gl.LEQUAL
_G.GL_VERSION = gl.VERSION
_G.GL_COLOR_CLEAR_VALUE = gl.COLOR_CLEAR_VALUE
_G.GL_RENDERER = gl.RENDERER
_G.GL_STENCIL_BACK_PASS_DEPTH_PASS = gl.STENCIL_BACK_PASS_DEPTH_PASS
_G.GL_STENCIL_BACK_PASS_DEPTH_FAIL = gl.STENCIL_BACK_PASS_DEPTH_FAIL
_G.GL_STENCIL_BACK_WRITEMASK = gl.STENCIL_BACK_WRITEMASK
_G.GL_BOOL = gl.BOOL
_G.GL_VIEWPORT = gl.VIEWPORT
_G.GL_FRAGMENT_SHADER = gl.FRAGMENT_SHADER
_G.GL_LUMINANCE = gl.LUMINANCE
_G.GL_DECR_WRAP = gl.DECR_WRAP
_G.GL_FUNC_ADD = gl.FUNC_ADD
_G.GL_ONE_MINUS_DST_ALPHA = gl.ONE_MINUS_DST_ALPHA
_G.GL_OUT_OF_MEMORY = gl.OUT_OF_MEMORY
_G.GL_BOOL_VEC4 = gl.BOOL_VEC4
_G.GL_POLYGON_OFFSET_FACTOR = gl.POLYGON_OFFSET_FACTOR
_G.GL_STATIC_DRAW = gl.STATIC_DRAW
_G.GL_DITHER = gl.DITHER
_G.GL_TEXTURE31 = gl.TEXTURE31
_G.GL_TEXTURE30 = gl.TEXTURE30
_G.GL_UNSIGNED_BYTE = gl.UNSIGNED_BYTE
_G.GL_DEPTH_COMPONENT16 = gl.DEPTH_COMPONENT16
_G.GL_TEXTURE23 = gl.TEXTURE23
_G.GL_DEPTH_TEST = gl.DEPTH_TEST
_G.GL_STENCIL_PASS_DEPTH_FAIL = gl.STENCIL_PASS_DEPTH_FAIL
_G.GL_BOOL_VEC3 = gl.BOOL_VEC3
_G.GL_POLYGON_OFFSET_UNITS = gl.POLYGON_OFFSET_UNITS
_G.GL_TEXTURE_BINDING_2D = gl.TEXTURE_BINDING_2D
_G.GL_TEXTURE21 = gl.TEXTURE21
_G.GL_UNPACK_ALIGNMENT = gl.UNPACK_ALIGNMENT
_G.GL_DONT_CARE = gl.DONT_CARE
_G.GL_BUFFER_SIZE = gl.BUFFER_SIZE
_G.GL_FLOAT_MAT3 = gl.FLOAT_MAT3
_G.GL_UNSIGNED_SHORT_5_6_5 = gl.UNSIGNED_SHORT_5_6_5
_G.GL_INT_VEC2 = gl.INT_VEC2
_G.GL_UNSIGNED_SHORT_4_4_4_4 = gl.UNSIGNED_SHORT_4_4_4_4
_G.GL_NONE = gl.NONE
_G.GL_BLEND_DST_ALPHA = gl.BLEND_DST_ALPHA
_G.GL_VERTEX_ATTRIB_ARRAY_SIZE = gl.VERTEX_ATTRIB_ARRAY_SIZE
_G.GL_SRC_COLOR = gl.SRC_COLOR
_G.GL_COMPRESSED_TEXTURE_FORMATS = gl.COMPRESSED_TEXTURE_FORMATS
_G.GL_STENCIL_ATTACHMENT = gl.STENCIL_ATTACHMENT
_G.GL_MAX_VERTEX_ATTRIBS = gl.MAX_VERTEX_ATTRIBS
_G.GL_NUM_COMPRESSED_TEXTURE_FORMATS = gl.NUM_COMPRESSED_TEXTURE_FORMATS
_G.GL_BLEND_EQUATION_RGB = gl.BLEND_EQUATION_RGB
_G.GL_TEXTURE = gl.TEXTURE
_G.GL_LINEAR_MIPMAP_LINEAR = gl.LINEAR_MIPMAP_LINEAR
_G.GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = gl.VERTEX_ATTRIB_ARRAY_BUFFER_BINDING
_G.GL_CURRENT_PROGRAM = gl.CURRENT_PROGRAM
_G.GL_COLOR_BUFFER_BIT = gl.COLOR_BUFFER_BIT
_G.GL_TEXTURE20 = gl.TEXTURE20
_G.GL_ACTIVE_ATTRIBUTE_MAX_LENGTH = gl.ACTIVE_ATTRIBUTE_MAX_LENGTH
_G.GL_TEXTURE28 = gl.TEXTURE28
_G.GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = gl.FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE
_G.GL_TEXTURE22 = gl.TEXTURE22
_G.GL_ELEMENT_ARRAY_BUFFER_BINDING = gl.ELEMENT_ARRAY_BUFFER_BINDING
_G.GL_STREAM_DRAW = gl.STREAM_DRAW
_G.GL_SCISSOR_BOX = gl.SCISSOR_BOX
_G.GL_TEXTURE26 = gl.TEXTURE26
_G.GL_TEXTURE27 = gl.TEXTURE27
_G.GL_TEXTURE24 = gl.TEXTURE24
_G.GL_TEXTURE25 = gl.TEXTURE25
_G.GL_NO_ERROR = gl.NO_ERROR
_G.GL_TEXTURE29 = gl.TEXTURE29
_G.GL_FLOAT_MAT4 = gl.FLOAT_MAT4
_G.GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = gl.VERTEX_ATTRIB_ARRAY_NORMALIZED
_G.GL_SAMPLE_COVERAGE_INVERT = gl.SAMPLE_COVERAGE_INVERT
_G.GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = gl.FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL
_G.GL_FLOAT_VEC3 = gl.FLOAT_VEC3
_G.GL_STENCIL_CLEAR_VALUE = gl.STENCIL_CLEAR_VALUE
_G.GL_UNSIGNED_SHORT_5_5_5_1 = gl.UNSIGNED_SHORT_5_5_5_1
_G.GL_ACTIVE_UNIFORMS = gl.ACTIVE_UNIFORMS
_G.GL_INVALID_OPERATION = gl.INVALID_OPERATION
_G.GL_DEPTH_ATTACHMENT = gl.DEPTH_ATTACHMENT
_G.GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = gl.MAX_COMBINED_TEXTURE_IMAGE_UNITS
_G.GL_FRAMEBUFFER_COMPLETE = gl.FRAMEBUFFER_COMPLETE
_G.GL_ONE_MINUS_CONSTANT_COLOR = gl.ONE_MINUS_CONSTANT_COLOR
_G.GL_TEXTURE2 = gl.TEXTURE2
_G.GL_TEXTURE1 = gl.TEXTURE1
_G.GL_GEQUAL = gl.GEQUAL
_G.GL_TEXTURE7 = gl.TEXTURE7
_G.GL_TEXTURE6 = gl.TEXTURE6
_G.GL_TEXTURE5 = gl.TEXTURE5
_G.GL_TEXTURE4 = gl.TEXTURE4
_G.GL_GENERATE_MIPMAP_HINT = gl.GENERATE_MIPMAP_HINT
_G.GL_ONE_MINUS_SRC_COLOR = gl.ONE_MINUS_SRC_COLOR
_G.GL_TEXTURE9 = gl.TEXTURE9
_G.GL_STENCIL_TEST = gl.STENCIL_TEST
_G.GL_COLOR_WRITEMASK = gl.COLOR_WRITEMASK
_G.GL_DEPTH_COMPONENT = gl.DEPTH_COMPONENT
_G.GL_STENCIL_INDEX8 = gl.STENCIL_INDEX8
_G.GL_VERTEX_ATTRIB_ARRAY_TYPE = gl.VERTEX_ATTRIB_ARRAY_TYPE
_G.GL_FLOAT_VEC2 = gl.FLOAT_VEC2
_G.GL_BLUE_BITS = gl.BLUE_BITS
_G.GL_VERTEX_SHADER = gl.VERTEX_SHADER
_G.GL_SUBPIXEL_BITS = gl.SUBPIXEL_BITS
_G.GL_STENCIL_WRITEMASK = gl.STENCIL_WRITEMASK
_G.GL_FLOAT_VEC4 = gl.FLOAT_VEC4
_G.GL_TEXTURE17 = gl.TEXTURE17
_G.GL_ONE_MINUS_CONSTANT_ALPHA = gl.ONE_MINUS_CONSTANT_ALPHA
_G.GL_TEXTURE15 = gl.TEXTURE15
_G.GL_TEXTURE14 = gl.TEXTURE14
_G.GL_TEXTURE13 = gl.TEXTURE13
_G.GL_SAMPLES = gl.SAMPLES
_G.GL_TEXTURE11 = gl.TEXTURE11
_G.GL_TEXTURE10 = gl.TEXTURE10
_G.GL_FUNC_SUBTRACT = gl.FUNC_SUBTRACT
_G.GL_STENCIL_BUFFER_BIT = gl.STENCIL_BUFFER_BIT
_G.GL_TEXTURE19 = gl.TEXTURE19
_G.GL_TEXTURE18 = gl.TEXTURE18
_G.GL_NEAREST_MIPMAP_NEAREST = gl.NEAREST_MIPMAP_NEAREST
_G.GL_SHORT = gl.SHORT
_G.GL_RENDERBUFFER_BINDING = gl.RENDERBUFFER_BINDING
_G.GL_REPEAT = gl.REPEAT
_G.GL_TEXTURE_MIN_FILTER = gl.TEXTURE_MIN_FILTER
_G.GL_RED_BITS = gl.RED_BITS
_G.GL_FRONT_FACE = gl.FRONT_FACE
_G.GL_BLEND_COLOR = gl.BLEND_COLOR
_G.GL_MIRRORED_REPEAT = gl.MIRRORED_REPEAT
_G.GL_INT_VEC4 = gl.INT_VEC4
_G.GL_MAX_CUBE_MAP_TEXTURE_SIZE = gl.MAX_CUBE_MAP_TEXTURE_SIZE
_G.GL_RENDERBUFFER_BLUE_SIZE = gl.RENDERBUFFER_BLUE_SIZE
_G.GL_SAMPLE_COVERAGE = gl.SAMPLE_COVERAGE
_G.GL_SRC_ALPHA = gl.SRC_ALPHA
_G.GL_FUNC_REVERSE_SUBTRACT = gl.FUNC_REVERSE_SUBTRACT
_G.GL_DEPTH_WRITEMASK = gl.DEPTH_WRITEMASK
_G.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT = gl.FRAMEBUFFER_INCOMPLETE_ATTACHMENT
_G.GL_POLYGON_OFFSET_FILL = gl.POLYGON_OFFSET_FILL
_G.GL_STENCIL_FUNC = gl.STENCIL_FUNC
_G.GL_REPLACE = gl.REPLACE
_G.GL_LUMINANCE_ALPHA = gl.LUMINANCE_ALPHA
_G.GL_DEPTH_RANGE = gl.DEPTH_RANGE
_G.GL_FASTEST = gl.FASTEST
_G.GL_STENCIL_FAIL = gl.STENCIL_FAIL
_G.GL_UNSIGNED_SHORT = gl.UNSIGNED_SHORT
_G.GL_RENDERBUFFER_HEIGHT = gl.RENDERBUFFER_HEIGHT
_G.GL_STENCIL_BACK_FAIL = gl.STENCIL_BACK_FAIL
_G.GL_BLEND_SRC_RGB = gl.BLEND_SRC_RGB
_G.GL_TEXTURE3 = gl.TEXTURE3
_G.GL_RENDERBUFFER = gl.RENDERBUFFER
_G.GL_RGB5_A1 = gl.RGB5_A1
_G.GL_RENDERBUFFER_ALPHA_SIZE = gl.RENDERBUFFER_ALPHA_SIZE
_G.GL_RENDERBUFFER_STENCIL_SIZE = gl.RENDERBUFFER_STENCIL_SIZE
_G.GL_NOTEQUAL = gl.NOTEQUAL
_G.GL_BLEND_DST_RGB = gl.BLEND_DST_RGB
_G.GL_FRONT_AND_BACK = gl.FRONT_AND_BACK
_G.GL_TEXTURE_BINDING_CUBE_MAP = gl.TEXTURE_BINDING_CUBE_MAP
_G.GL_MAX_RENDERBUFFER_SIZE = gl.MAX_RENDERBUFFER_SIZE
_G.GL_ZERO = gl.ZERO
_G.GL_TEXTURE0 = gl.TEXTURE0
_G.GL_SAMPLE_ALPHA_TO_COVERAGE = gl.SAMPLE_ALPHA_TO_COVERAGE
_G.GL_BUFFER_USAGE = gl.BUFFER_USAGE
_G.GL_ACTIVE_TEXTURE = gl.ACTIVE_TEXTURE
_G.GL_BYTE = gl.BYTE
_G.GL_CW = gl.CW
_G.GL_DYNAMIC_DRAW = gl.DYNAMIC_DRAW
_G.GL_RENDERBUFFER_RED_SIZE = gl.RENDERBUFFER_RED_SIZE
_G.GL_FALSE = gl.FALSE
_G.GL_GREATER = gl.GREATER
_G.GL_RGBA4 = gl.RGBA4
_G.GL_VALIDATE_STATUS = gl.VALIDATE_STATUS
_G.GL_STENCIL_BITS = gl.STENCIL_BITS
_G.GL_RGB = gl.RGB
_G.GL_INT = gl.INT
_G.GL_DEPTH_FUNC = gl.DEPTH_FUNC
_G.GL_SAMPLER_2D = gl.SAMPLER_2D
_G.GL_NICEST = gl.NICEST
_G.GL_MAX_VIEWPORT_DIMS = gl.MAX_VIEWPORT_DIMS
_G.GL_CULL_FACE = gl.CULL_FACE
_G.GL_INT_VEC3 = gl.INT_VEC3
_G.GL_ALIASED_POINT_SIZE_RANGE = gl.ALIASED_POINT_SIZE_RANGE
_G.GL_INVALID_ENUM = gl.INVALID_ENUM
_G.GL_INVERT = gl.INVERT
_G.GL_CULL_FACE_MODE = gl.CULL_FACE_MODE
_G.GL_TEXTURE8 = gl.TEXTURE8
_G.GL_VERTEX_ATTRIB_ARRAY_POINTER = gl.VERTEX_ATTRIB_ARRAY_POINTER
_G.GL_TEXTURE_WRAP_S = gl.TEXTURE_WRAP_S
_G.GL_VERTEX_ATTRIB_ARRAY_STRIDE = gl.VERTEX_ATTRIB_ARRAY_STRIDE
_G.GL_LINES = gl.LINES
_G.GL_EQUAL = gl.EQUAL
_G.GL_LINE_LOOP = gl.LINE_LOOP
_G.GL_TEXTURE_WRAP_T = gl.TEXTURE_WRAP_T
_G.GL_DEPTH_BUFFER_BIT = gl.DEPTH_BUFFER_BIT
_G.GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS = gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS
_G.GL_SHADER_TYPE = gl.SHADER_TYPE
_G.GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = gl.FRAMEBUFFER_ATTACHMENT_OBJECT_NAME
_G.GL_TEXTURE_CUBE_MAP_NEGATIVE_X = gl.TEXTURE_CUBE_MAP_NEGATIVE_X
_G.GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y
_G.GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
_G.GL_DECR = gl.DECR
_G.GL_DELETE_STATUS = gl.DELETE_STATUS
_G.GL_DEPTH_BITS = gl.DEPTH_BITS
_G.GL_INCR = gl.INCR
_G.GL_SAMPLE_COVERAGE_VALUE = gl.SAMPLE_COVERAGE_VALUE
_G.GL_ALPHA_BITS = gl.ALPHA_BITS
_G.GL_FLOAT_MAT2 = gl.FLOAT_MAT2
_G.GL_LINE_STRIP = gl.LINE_STRIP
_G.GL_SHADER_SOURCE_LENGTH = gl.SHADER_SOURCE_LENGTH
_G.GL_INVALID_VALUE = gl.INVALID_VALUE
_G.GL_NEVER = gl.NEVER
_G.GL_INCR_WRAP = gl.INCR_WRAP
_G.GL_BLEND_EQUATION_ALPHA = gl.BLEND_EQUATION_ALPHA
_G.GL_TEXTURE_MAG_FILTER = gl.TEXTURE_MAG_FILTER
_G.GL_POINTS = gl.POINTS
_G.GL_COLOR_ATTACHMENT0 = gl.COLOR_ATTACHMENT0
_G.GL_RGBA = gl.RGBA
_G.GL_SRC_ALPHA_SATURATE = gl.SRC_ALPHA_SATURATE
_G.GL_SAMPLER_CUBE = gl.SAMPLER_CUBE
_G.GL_FRAMEBUFFER = gl.FRAMEBUFFER
_G.GL_TEXTURE_CUBE_MAP = gl.TEXTURE_CUBE_MAP
_G.GL_SAMPLE_BUFFERS = gl.SAMPLE_BUFFERS
_G.GL_LINEAR = gl.LINEAR
_G.GL_LINEAR_MIPMAP_NEAREST = gl.LINEAR_MIPMAP_NEAREST
_G.GL_ACTIVE_UNIFORM_MAX_LENGTH = gl.ACTIVE_UNIFORM_MAX_LENGTH
_G.GL_STENCIL_BACK_REF = gl.STENCIL_BACK_REF
_G.GL_ELEMENT_ARRAY_BUFFER = gl.ELEMENT_ARRAY_BUFFER
_G.GL_CLAMP_TO_EDGE = gl.CLAMP_TO_EDGE
_G.GL_TRIANGLE_STRIP = gl.TRIANGLE_STRIP
_G.GL_CONSTANT_COLOR = gl.CONSTANT_COLOR
_G.GL_COMPILE_STATUS = gl.COMPILE_STATUS
_G.GL_RENDERBUFFER_GREEN_SIZE = gl.RENDERBUFFER_GREEN_SIZE
_G.GL_UNSIGNED_INT = gl.UNSIGNED_INT
_G.GL_DEPTH_CLEAR_VALUE = gl.DEPTH_CLEAR_VALUE
_G.GL_ALIASED_LINE_WIDTH_RANGE = gl.ALIASED_LINE_WIDTH_RANGE
_G.GL_SHADING_LANGUAGE_VERSION = gl.SHADING_LANGUAGE_VERSION
_G.GL_FRAMEBUFFER_UNSUPPORTED = gl.FRAMEBUFFER_UNSUPPORTED
_G.GL_INFO_LOG_LENGTH = gl.INFO_LOG_LENGTH
_G.GL_STENCIL_PASS_DEPTH_PASS = gl.STENCIL_PASS_DEPTH_PASS
_G.GL_STENCIL_VALUE_MASK = gl.STENCIL_VALUE_MASK
_G.GL_ALWAYS = gl.ALWAYS
_G.GL_MAX_TEXTURE_SIZE = gl.MAX_TEXTURE_SIZE
_G.GL_FLOAT = gl.FLOAT
_G.GL_FRAMEBUFFER_BINDING = gl.FRAMEBUFFER_BINDING
_G.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = gl.FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
_G.GL_TRIANGLE_FAN = gl.TRIANGLE_FAN
_G.GL_INVALID_FRAMEBUFFER_OPERATION = gl.INVALID_FRAMEBUFFER_OPERATION
_G.GL_TEXTURE_2D = gl.TEXTURE_2D
_G.GL_ALPHA = gl.ALPHA
_G.GL_CURRENT_VERTEX_ATTRIB = gl.CURRENT_VERTEX_ATTRIB
_G.GL_SCISSOR_TEST = gl.SCISSOR_TEST
_G.GL_TRIANGLES = gl.TRIANGLES

_G.CCControlEventTouchDown = cc.CONTROL_EVENTTYPE_TOUCH_DOWN
_G.CCControlEventTouchDragInside = cc.CONTROL_EVENTTYPE_DRAG_INSIDE 
_G.CCControlEventTouchDragOutside = cc.CONTROL_EVENTTYPE_DRAG_OUTSIDE
_G.CCControlEventTouchDragEnter = cc.CONTROL_EVENTTYPE_DRAG_ENTER
_G.CCControlEventTouchDragExit  = cc.CONTROL_EVENTTYPE_DRAG_EXIT
_G.CCControlEventTouchUpInside  = cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE
_G.CCControlEventTouchUpOutside = cc.CONTROL_EVENTTYPE_TOUCH_UP_OUTSIDE
_G.CCControlEventTouchCancel    = cc.CONTROL_EVENTTYPE_TOUCH_CANCEL
_G.CCControlEventValueChanged   = cc.CONTROL_EVENTTYPE_VALUE_CHANGED 
_G.CCControlStateNormal         = cc.CONTROL_STATE_NORMAL
_G.CCControlStateHighlighted    = cc.CONTROL_STATE_HIGH_LIGHTED
_G.CCControlStateDisabled       = cc.CONTROL_STATE_DISABLED
_G.CCControlStateSelected       = cc.CONTROL_STATE_SELECTED

_G.kWebSocketScriptHandlerOpen  = cc.WEBSOCKET_OPEN
_G.kWebSocketScriptHandlerMessage = cc.WEBSOCKET_MESSAGE
_G.kWebSocketScriptHandlerClose   = cc.WEBSOCKET_CLOSE
_G.kWebSocketScriptHandlerError   = cc.WEBSOCKET_ERROR

_G.kStateConnecting               = cc.WEBSOCKET_STATE_CONNECTING 
_G.kStateOpen                     = cc.WEBSOCKET_STATE_OPEN 
_G.kStateClosing                  = cc.WEBSOCKET_STATE_CLOSING
_G.kStateClosed                   = cc.WEBSOCKET_STATE_CLOSED

_G.LAYOUT_COLOR_NONE              = ccui.LayoutBackGroundColorType.none
_G.LAYOUT_COLOR_SOLID             = ccui.LayoutBackGroundColorType.solid
_G.LAYOUT_COLOR_GRADIENT          = ccui.LayoutBackGroundColorType.gradient

_G.LAYOUT_ABSOLUTE                = ccui.LayoutType.ABSOLUTE
_G.LAYOUT_LINEAR_VERTICAL         = ccui.LayoutType.VERTICAL
_G.LAYOUT_LINEAR_HORIZONTAL       = ccui.LayoutType.HORIZONTAL
_G.LAYOUT_RELATIVE                = ccui.LayoutType.RELATIVE

_G.BRIGHT_NONE               = ccui.BrightStyle.none
_G.BRIGHT_NORMAL             = ccui.BrightStyle.normal
_G.BRIGHT_HIGHLIGHT          = ccui.BrightStyle.highlight

_G.UI_TEX_TYPE_LOCAL               = ccui.TextureResType.localType
_G.UI_TEX_TYPE_PLIST               = ccui.TextureResType.plistType

_G.TOUCH_EVENT_BEGAN                = ccui.TouchEventType.began
_G.TOUCH_EVENT_MOVED                = ccui.TouchEventType.moved
_G.TOUCH_EVENT_ENDED                = ccui.TouchEventType.ended
_G.TOUCH_EVENT_CANCELED             = ccui.TouchEventType.canceled
 
_G.SIZE_ABSOLUTE                = ccui.SizeType.absolute
_G.SIZE_PERCENT                 = ccui.SizeType.percent

_G.POSITION_ABSOLUTE                = ccui.PositionType.absolute
_G.POSITION_PERCENT                 = ccui.PositionType.percent

_G.CHECKBOX_STATE_EVENT_SELECTED     = ccui.CheckBoxEventType.selected
_G.CHECKBOX_STATE_EVENT_UNSELECTED   = ccui.CheckBoxEventType.unselected

_G.CHECKBOX_STATE_EVENT_SELECTED     = ccui.CheckBoxEventType.selected
_G.CHECKBOX_STATE_EVENT_UNSELECTED   = ccui.CheckBoxEventType.unselected

_G.LoadingBarTypeLeft     = ccui.LoadingBarDirection.LEFT
_G.LoadingBarTypeRight   = ccui.LoadingBarDirection.RIGHT

_G.LoadingBarTypeRight   = ccui.SliderEventType.percent_changed

_G.TEXTFIELD_EVENT_ATTACH_WITH_IME                = ccui.TextFiledEventType.attach_with_ime
_G.TEXTFIELD_EVENT_DETACH_WITH_IME                = ccui.TextFiledEventType.detach_with_ime
_G.TEXTFIELD_EVENT_INSERT_TEXT                 = ccui.TextFiledEventType.insert_text
_G.TEXTFIELD_EVENT_DELETE_BACKWARD             = ccui.TextFiledEventType.delete_backward

_G.SCROLLVIEW_EVENT_SCROLL_TO_TOP                = ccui.ScrollViewDir.none
_G.SCROLLVIEW_DIR_VERTICAL                = ccui.ScrollViewDir.vertical
_G.SCROLLVIEW_DIR_HORIZONTAL                 = ccui.ScrollViewDir.horizontal
_G.SCROLLVIEW_DIR_BOTH             = ccui.ScrollViewDir.both

_G.SCROLLVIEW_EVENT_SCROLL_TO_TOP                = ccui.ScrollviewEventType.scrollToTop
_G.SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM             = ccui.ScrollviewEventType.scrollToBottom
_G.SCROLLVIEW_EVENT_SCROLL_TO_LEFT               = ccui.ScrollviewEventType.scrollToLeft
_G.SCROLLVIEW_EVENT_SCROLL_TO_RIGHT              = ccui.ScrollviewEventType.scrollToRight
_G.SCROLLVIEW_EVENT_SCROLLING                    = ccui.ScrollviewEventType.scrolling
_G.SCROLLVIEW_EVENT_BOUNCE_TOP                   = ccui.ScrollviewEventType.bounceTop
_G.SCROLLVIEW_EVENT_BOUNCE_BOTTOM                = ccui.ScrollviewEventType.bounceBottom
_G.SCROLLVIEW_EVENT_BOUNCE_LEFT                  = ccui.ScrollviewEventType.bounceLeft
_G.SCROLLVIEW_EVENT_BOUNCE_RIGHT                 = ccui.ScrollviewEventType.bounceRight

_G.PAGEVIEW_EVENT_TURNING                 = ccui.PageViewEventType.turning

_G.PAGEVIEW_TOUCHLEFT                  = ccui.PVTouchDir.touch_left
_G.PAGEVIEW_TOUCHRIGHT                 = ccui.PVTouchDir.touch_right

_G.LISTVIEW_DIR_NONE                      = ccui.ListViewDirection.none
_G.LISTVIEW_DIR_VERTICAL                  = ccui.ListViewDirection.vertical
_G.LISTVIEW_DIR_HORIZONTAL                = ccui.ListViewDirection.horizontal

_G.LISTVIEW_MOVE_DIR_NONE                = ccui.ListViewMoveDirection.none
_G.LISTVIEW_MOVE_DIR_UP                  = ccui.ListViewMoveDirection.up
_G.LISTVIEW_MOVE_DIR_DOWN                = ccui.ListViewMoveDirection.down
_G.LISTVIEW_MOVE_DIR_LEFT                = ccui.ListViewMoveDirection.left
_G.LISTVIEW_MOVE_DIR_RIGHT               = ccui.ListViewMoveDirection.right

_G.LISTVIEW_EVENT_INIT_CHILD                 = ccui.ListViewEventType.init_child
_G.LISTVIEW_EVENT_UPDATE_CHILD               = ccui.ListViewEventType.update_child

_G.LAYOUT_PARAMETER_NONE                   = ccui.LayoutParameterType.none
_G.LAYOUT_PARAMETER_LINEAR                 = ccui.LayoutParameterType.linear
_G.LAYOUT_PARAMETER_RELATIVE               = ccui.LayoutParameterType.relative

_G.kCCScrollViewDirectionHorizontal        = cc.SCROLLVIEW_DIRECTION_HORIZONTAL
_G.kCCScrollViewDirectionVertical          = cc.SCROLLVIEW_DIRECTION_VERTICAL
_G.kCCTableViewFillTopDown                 = cc.TABLEVIEW_FILL_TOPDOWN
_G.kCCTableViewFillBottomUp                = cc.TABLEVIEW_FILL_BOTTOMUP

ccui.LoadingBarType = ccui.LoadingBarDirection 
ccui.LoadingBarType.left = ccui.LoadingBarDirection.LEFT
ccui.LoadingBarType.right = ccui.LoadingBarDirection.RIGHT

ccui.LayoutType.absolute = ccui.LayoutType.ABSOLUTE
ccui.LayoutType.linearVertical = ccui.LayoutType.VERTICAL
ccui.LayoutType.linearHorizontal = ccui.LayoutType.HORIZONTAL
ccui.LayoutType.relative = ccui.LayoutType.RELATIVE

ccui.ListViewEventType.onsSelectedItem = ccui.ListViewEventType.ONSELECTEDITEM_START

