math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()

__FRAMEWORK_VERSION__   	= require("TFFramework.TFVersion").__ENGINE_VERSION__
__FRAMEWORK_GLOBALS__     	= __FRAMEWORK_GLOBALS__ or {}
__FRAMEWORK_ENVIRONMENT__ 	= "WIN7"

--[[
	调试等级
	nil/0 	: 关闭所有调试信息
	1   	: 打开所有调试信息
]]
DEBUG 			  			= DEBUG or 0 
if DEBUG == 0 then DEBUG = nil end

--[[--
	To control wheather or not to send msg to svn http server
	0: off
	1: on
]]
ENABLE_DEBUG_HTTPMSG 		= ENABLE_DEBUG_HTTPMSG or 0
ENABLE_ADAPTOR				= ENABLE_ADAPTOR or false

ENABLE_LUA_DEBUG 			= ENABLE_LUA_DEBUG or "false"

PTM_RATIO 					= PTM_RATIO or 128

--[[--
	Load Base Tools
]]
require('TFFramework.base.macros')
require('TFFramework.base.class')
require('TFFramework.base.functions')
require('TFFramework.base.bit')
require('TFFramework.base.bit_64')

--[[--
	Load Utils
]]
require('TFFramework.utils.TFTableUtils')
require('TFFramework.utils.TFFunctionUtils')
require('TFFramework.utils.TFStringUtils')
require('TFFramework.utils.TFIOUtils')


--[[
	Load TF module
--]]
require('TFFramework.base.me.initME')

require('TFFramework.utils.TFVisibleUtils')
--require('TFFramework.utils.TFLanguageUtils')

--[[--
	Load Algorithm
]]
require('TFFramework.algorithm.TFArray')

--[[--
	Load Net
]]
require('TFFramework.net.TFClientNet')

--[[--
	Load Managers
]]
require('TFFramework.client.entity.TFEaseType')
require('TFFramework.client.manager.TFBaseManager')
require('TFFramework.client.manager.TFLogManager')
require('TFFramework.client.manager.TFEventManager')
require('TFFramework.client.manager.TFEnterFrameManager')
require('TFFramework.client.manager.TFTimerManager')
require('TFFramework.client.manager.TFTweenManager')
require('TFFramework.client.manager.TFSceneManager')
require('TFFramework.client.manager.TFProtocolManager')
require('TFFramework.client.manager.TFShaderManager')
require('TFFramework.client.director.TFDirector')

--[[--
	Load UI
]]
require('TFFramework.client.system.components.initComponents')
require('TFFramework.luacomponents.initLuaComponents')

require('TFFramework.base.me.TF_Adaptor')
--[[
	Load ClientUpdate
]]
-- require('TFFramework.net.TFClientUpdate')

-- require('TFFramework.SDK.TFSdk')
require("TFFramework.Plugins.anysdkConst")
require("TFFramework.Plugins.TFPlugins")
require("TFFramework.HeitaoSdk.HeitaoSdk")

--推送
require("TFFramework.push.TFPush")

-- avoid memory leak
collectgarbage("setpause", 130)
collectgarbage("setstepmul", 5000)

------------------------------------------------------info
print()
print('=======================TFFramework Infos===============')
print("MangoEngine Version: " .. __FRAMEWORK_VERSION__)
print("me.platform: " .. me.platform)
print(string.format("me.winSize: width(%d)  height(%d)", me.winSize.width, me.winSize.height))
print(string.format("me.frameSize: width(%d)  height(%d)", me.frameSize.width, me.frameSize.height))
print("DEBUG Level: " .. tostring(DEBUG))
print("Adaptor enabled: " .. tostring(ENABLE_ADAPTOR))
print("ENABLE_LUA_DEBUG: " .. ENABLE_LUA_DEBUG)
print("Lua collect pause: 100")
print("Lua collect stepmul: 5000")
print('=======================================================')
print()

---------------------------------------------------------------------------------------------

function meStartDebug(debugHost)
	if ENABLE_LUA_DEBUG == "true" or os.getenv('ENABLE_LUA_DEBUG') == "true"
		then
		debugHost = debugHost or '127.0.0.1'
		require('TFFramework.mobdebug').start('127.0.0.1')
	else
		print('Remote debug not enabled or not supported...')
	end
end
