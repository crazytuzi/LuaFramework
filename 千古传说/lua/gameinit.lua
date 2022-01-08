-- CCLog_setDebugFileEnabled(1)
-- local __addMEListener = CCNode.addMEListener
-- local function addMEListener(sender, nType, handle, clickEffectType)
-- 	local self = sender
-- 	if nType == TFWIDGET_CLICK then 
-- 		local function tHandle(sender, ...)
-- 			sender:setTouchEnabled(false)
-- 			if sender.timeOut then
-- 				local nDT  = 0
-- 				sender:timeOut(function()
-- 					sender:setTouchEnabled(true)
-- 				end, nDT)
-- 			end
-- 			handle(sender, ...)
-- 		end
-- 		__addMEListener(self, nType, tHandle)
-- 	else 
-- 		__addMEListener(self, nType, handle)
-- 	end

-- 	clickEffectType = clickEffectType or 0; 
-- 	if tolua.type(sender) == 'TFButton' and clickEffectType == 1 then
-- 		sender:setClickScaleEnabled(true)
-- 		sender:setClickHighLightEnabled(false)
-- 	end
-- end
-- rawset(CCNode, "addMEListener", addMEListener)


c2s = require("lua.net.codes_c2s")
s2c = require("lua.net.codes_s2c")
tblS2CData = require("lua.net.protos_s2c")
tblC2SData = require("lua.net.protos_c2s")

BaseLayer = require('lua.logic.BaseLayer')
BaseScene = require('lua.logic.BaseScene')
SceneType = require('lua.logic.SceneType');
require('lua.table.MEMapArray')
AlertManager  = require('lua.public.AlertManager')
Public   = require("lua.public.Public")
LoadingLayer   = require("lua.logic.common.LoadingLayer")

require('lua.public.BaseFunction')
require('lua.public.TPageView')
require('lua.public.TFTimeLabel')

-- 增加多语言管理器
stringUtils = require("language.StringUtils_format")
TextManager = require("language.TextManager")

require('lua.gamedata.base.EnumGameObject')
require('lua.gamedata.base.functions')

AudioFun  = require("lua.logic.common.AudioFun")

Public   = require("lua.public.Public")
 
TFLanguageManager = require('lua.public.TFLanguageUtils')
ErrorCodeData = require("language.textIndex")
GameConfig = require('lua.logic.common.GameConfig');
TimeRecoverProperty = require('lua.public.TimeRecoverProperty');
GroupLayerManager  = require("lua.public.GroupLayerManager")
GroupButtonManager  = require("lua.public.GroupButtonManager")
ToastMessage  = require('lua.logic.common.ToastMessage')
TFScrollRichText  = require('lua.public.TFScrollRichText')

TFWebView = require('TFFramework.utils.TFWebView')

TFLuaTime:begin()
-- 适配 start
MEArray 	= TFArray
TFMapArray 	= MEMapArray
-- end
BaseDataManager = require('lua.table.BaseDataManager')
ModelManager = require('lua.gamedata.ModelManager')
TFLuaTime:endToLua("============================================BaseDataManager:")

TFLuaTime:begin()

DeviceAdpter = require("lua.public.DeviceAdpter")
MainPlayer   = require("lua.gamedata.MainPlayer")
TFLuaTime:endToLua("=================================================MainPlayer:")
