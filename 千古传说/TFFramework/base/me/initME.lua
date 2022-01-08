--
-- Author: MiYu
-- Date: 2014-01-22 15:50:07
--

me = me or {}

-----------------------------------------Instance----------------------------------------

me.Director 			= CCDirector:sharedDirector()
me.TextureCache 		= CCTextureCache:sharedTextureCache()
me.FileUtils 			= CCFileUtils:sharedFileUtils()
me.FrameCache 			= CCSpriteFrameCache:sharedSpriteFrameCache()
me.EGLView 				= CCEGLView:sharedOpenGLView()
me.Application 			= CCApplication:sharedApplication()
me.ShaderCache 			= CCShaderCache:sharedShaderCache()
me.ArmatureDataManager  = TFArmatureDataManager:getInstance()
me.Scheduler 			= CCDirector:sharedDirector():getScheduler()
me.MCManager			= TFMovieClipManager:getInstance()

-----------------------------------------properties--------------------------------------

me.winSize 					= me.Director:getWinSize()
me.frameSize 				= me.EGLView:getFrameSize()

me.width              = me.frameSize.width
me.height             = me.frameSize.height
-- me.widthInPixels      = me.frameSize.width
-- me.heightInPixels     = me.frameSize.height
me.cx                 = me.width / 2
me.cy                 = me.height / 2
me.left               = 0
me.right              = me.width
me.top                = me.height
me.bottom             = 0

me.DIRECTOR_PROJECTION_2D 	= 0
me.DIRECTOR_PROJECTION_3D 	= 1

me.frameworkDirectory = 'TFFramework.'
me.svnServerIP = '127.0.0.1'
me.svnServerPort = '8094'

------------------------------------------modules----------------------------------------

local moduleName = ...

import(".cocos.cocos2d", moduleName)
import(".cocos.enums", moduleName)

import(".mango.definitions", moduleName)
import(".mango.platform", moduleName)
import(".mango.classes", moduleName)
import(".mango.helpers", moduleName)
import(".mango.json", moduleName)
import(".mango.shortcut", moduleName)

import(".loader.initLoader", moduleName)
do return end
------------------------------------------remove unsupport-------------------------------------

CCDirector 				= nil
CCTextureCache 			= nil
CCFileUtils 			= nil
CCSpriteFrameCache 		= nil
CCEGLView 				= nil
CCApplication 			= nil
CCShaderCache 			= nil
TFArmatureDataManager 	= nil
