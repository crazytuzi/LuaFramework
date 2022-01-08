--[[--
	导演:

	--By: yun.bo
	--2013/7/8
]]
local TFFunction 			= TFFunction
local import 				= import

local TFBaseManager 		= require('TFFramework.client.manager.TFBaseManager')
local TFLogManager 			= require('TFFramework.client.manager.TFLogManager')
local TFEventManager 		= require('TFFramework.client.manager.TFEventManager')
local TFEnterFrameManager 	= require('TFFramework.client.manager.TFEnterFrameManager')
local TFTimerManager 		= require('TFFramework.client.manager.TFTimerManager')
local TFTweenManager 		= require('TFFramework.client.manager.TFTweenManager')
local TFSceneManager 		= require('TFFramework.client.manager.TFSceneManager')
local TFProtocolManager		= require('TFFramework.client.manager.TFProtocolManager')
local TFShaderManager       = require('TFFramework.client.manager.TFShaderManager')
local TFUILoadManager       = require('TFFramework.client.manager.TFUILoadManager')
local TFLuaOc               = nil 
local TFLuaJava   			= nil    

local moduleName 			= ...

TFDirector = class('TFDirector', TFBaseManager)
TFDirectorModel = {}

local TFDirector 			= TFDirector
local TFDirectorModel 		= TFDirectorModel

function TFDirector:description(...)
	TFDirectorModel.managerList 		= nil
	TFDirectorModel.bPause 				= nil
	TFDirectorModel.nEntryID 			= nil
	TFDirectorModel.nLastClock 			= nil
	TFDirectorModel.nNameCount 			= nil

	TFDirector.bUseNewNet    			= nil

	-- fundations
	TFDirector:init()
	TFDirector:ctor()
	TFDirector:reset()
	TFDirector:update()
	TFDirector:initPlugins()
	TFDirector:setFPS(nInterval)
	TFDirector:start()
	TFDirector:resume()
	TFDirector:pause()

	--
	
	TFDirector:getChildByName(objTarget, szChildName)
	TFDirector:getChildByPath(objTarget, szPath)
	TFDirector:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
	TFDirector:unRequire(...)
	TFDirector:currentScene()
	TFDirector:nameCount()
	TFDirector:addShaderWithFilename(szFFilename, szVFilename, szShaderName)
	TFDirector:addShaderWithShader(szFContent, szVContent, szShaderName)
	TFDirector:setScaleLayer(objScene, objControlLayer, objTouchLayer, smallest, bigest)
	TFDirector:clearScaleLayer()
	TFDirector:captureImage(objUI)
	TFDirector:updateNetFlow(...)
	TFDirector:createDebugerLayer(objScene)
	TFDirector:writeToDebugerLayer(...)

end


function TFDirector:init()
	TFDirectorModel.managerList = {TFTimerManager, TFEnterFrameManager}
	TFDirectorModel.bPause = true
	TFDirectorModel.nEntryID = nil
	TFDirectorModel.nNameCount = 0

	TFDirectorModel.nLastClock = TFTimeUtils:clock()
	TFShaderManager:init()

	import(".TFDirector_Adaptor", moduleName)
	import(".TFDirector_Event_Timer", moduleName)
	import(".TFDirector_Net", moduleName)
	import(".TFDirector_UIManager", moduleName)
	if DEBUG then
        import(".TFDirector_Debug", moduleName):initDebugEnv()
	end
end

function TFDirector:ctor()
	self:init()
end

function TFDirector:reset(szScenePath)
	TFFunction.call(TFLogManager 		.reset, TFLogManager 		)	
	TFFunction.call(TFEventManager 		.reset, TFEventManager 		)
	TFFunction.call(TFEnterFrameManager .reset, TFEnterFrameManager )	
	TFFunction.call(TFTimerManager 		.reset, TFTimerManager 		)
	TFFunction.call(TFTweenManager 		.reset, TFTweenManager 		)
	TFFunction.call(TFSceneManager 		.reset, TFSceneManager 		)
	TFFunction.call(TFProtocolManager	.reset, TFProtocolManager	)	

	TFDirectorModel.nNameCount = 0
	TFDirectorModel.nLastClock = TFTimeUtils:clock()

	TFDirector:start()

	if szScenePath then
		self:changeScene(szScenePath)
	end	
end

local nClock, nElapseEX, tTempMGR
function TFDirector.update(nElapse)
	-- 去掉了系统时间片, 采用游戏时间片控制更新逻辑
	-- 系统时间片会导致定时器并不会像想象中的运行
	-- 比如最小化游戏一段时间后再返回游戏  
	--
	-- nClock = TFTimeUtils:clock()
	-- nElapseEX = (nClock - TFDirectorModel.nLastClock) -- this real timeelapse used for Timer only
	-- TFDirectorModel.nLastClock = nClock
	for i = 1, #TFDirectorModel.managerList do
		tTempMGR = TFDirectorModel.managerList[i]
		tTempMGR:update(nElapse)
		--TFFunction.call(tTempMGR.update, tTempMGR, nElapse, nElapse)
	end
end

--[[--
	设置游戏的FPS
	@param nInterval:帧数
	@return nil
]]
function TFDirector:setFPS(nInterval)
	me.Director:setAnimationInterval(1.0 / nInterval)
end

--[[--
	获取游戏的FPS
	@return FPS in Integer
]]
function TFDirector:getFPS()
	return 1.0 / me.Director:getAnimationInterval()
end

--[[--
	初始化插件
]]
function TFDirector:initPlugins()
	if not PLUGINS then return end
	for k, v in pairs(PLUGINS) do
		v:init()
	end
end

--[[--
	游戏开始
]]
function TFDirector:start()
	TFDirector:resume()
	if DEBUG == 1 then 
		TFDirector:createDebugerLayer()
	end
end

--[[--
	继续
]]
function TFDirector:resume()
	if TFDirectorModel.bPause then
		me.Director:resume()
		TFDirectorModel.bPause = false
		TFDirectorModel.nEntryID = me.Scheduler:scheduleScriptFunc(TFDirector.update, 0, false)
	end
end

--[[--
	暂停
]]
function TFDirector:pause()
	if not TFDirectorModel.bPause and TFDirectorModel.nEntryID then
		me.Director:pause()
		TFDirectorModel.bPause = true
		me.Director:getScheduler():unscheduleScriptEntry(TFDirectorModel.nEntryID)
		TFDirectorModel.nEntryID = nil
	end
end

--[[--
	Create
]]
function TFDirector:createAction(tween)
 	return TFTweenManager:createAction(tween)
end

--[[--
	To
]]
function TFDirector:toTween(tTween)
	return TFTweenManager:to(tTween)
end

--[[--
	From
]]
function TFDirector:fromTween(tTween)
	return TFTweenManager:from(tTween)
end

--[[--
	 删除指定的缓动
]]
function TFDirector:killTween(tTween)
	TFTweenManager:kill(tTween)
end

--[[--
	删除指定对象的所有缓动效果, 如果未指定对象, 则删除所有缓动
	@param objTarget: 对象
]]
function TFDirector:killAllTween(objTarget)
	TFTweenManager:killAll(objTarget)
end

--[[--
	清除指定对象的所有缓动效果, 如果未指定对象, 则清除所有缓动
	@param objTarget: 对象
]]
function TFDirector:clearAllTween(objTarget)
	TFTweenManager:clearAll(objTarget)
end

--[[--
	根据子对象名称获取对象的指定子对象
	@param objTarget: 对象
	@param szChildName: 子对象名称
]]
function TFDirector:getChildByName(objTarget, szChildName)
	if objTarget and objTarget.getChildren then
		local objArr = objTarget:getChildren()
		if objArr then
			local nLen = objArr:count()
			local obj, szName
			for i = 1, nLen do
				obj = objArr:objectAtIndex(i - 1)
				if obj.getName then
					szName = obj:getName()
					if szName == szChildName then
						return obj
					end
				end
				obj = TFDirector:getChildByName(obj, szChildName)
				if obj then return obj end
			end
		end
	end
	return nil
end

--[[
	通过路径获取孩子节点
--]]
function TFDirector:getChildByPath(objTarget, szPath)
	local tPath = string.split(szPath, '.')
	local objUI = objTarget
	local j = 1
	for i = j, #tPath do
		if not objUI then break end
		objUI = objUI:getChildByName(tPath[i])
	end
	return objUI
end

--[[
	移除指定的require缓存
--]]
function TFDirector:unRequire(...)
	local tb = {...}
	for i = 1, #tb do
		if type(tb[i]) == 'string' then
			package.loaded[tb[i]] = nil
		end
	end
end

function TFDirector:nameCount()
	TFDirectorModel.nNameCount = TFDirectorModel.nNameCount + 1
	return TFDirectorModel.nNameCount
end


--------------------------------------------TFShaderManager began-------------------------------

function TFDirector:addShaderWithFilename(szFFilename, szVFilename, szShaderName)
	return TFShaderManager:addShaderWithFilename(szFFilename, szVFilename, szShaderName)
end

function TFDirector:addShaderWithShader(szFContent, szVContent, szShaderName)
	return TFShaderManager:addShaderWithShader(szFContent, szVContent, szShaderName)
end

--------------------------------------------TFShaderManager ended-------------------------------


--------------------------------------------TFUILoadManager began-------------------------------
function TFDirector:loadUI(szConfigPath, szPrePath, bIsNotLoadLogicFile)
	return TFUILoadManager:load(szConfigPath, szPrePath, bIsNotLoadLogicFile)
end

function TFDirector:unLoadUI(szConfigPath)
	return TFUILoadManager:unLoad(szConfigPath)
end

function TFDirector:loadUIModule(szUIPath, szLogicPath, name, x, y)
	return TFUILoadManager:loadModule(szUIPath, szLogicPath, name, x, y)
end

function TFDirector:unLoadUIModule(szName)
	return TFUILoadManager:unLoadModule(szName)
end

function TFDirector:getLoadUI(szName)
	return TFUILoadManager:getUI(szName)
end

function TFDirector:getLoadLogic(szName)
	return TFUILoadManager:getLogic(szName)
end

function TFDirector:getDict()
	return TFUILoadManager:getDict()
end

function TFDirector:clearLoadedUI()
	return TFUILoadManager:clear()
end

--------------------------------------------TFUILoadManager ended-------------------------------

function TFDirector:setScaleLayer(objScene, objControlLayer, objTouchLayer, smallest, bigest)
	TFSceneManager:setScaleLayer(objScene, objControlLayer, objTouchLayer, smallest, bigest)
end

function TFDirector:clearScaleLayer()
	TFSceneManager:clearScaleLayer()
end

--[[
	场景切换
--]]
function TFDirector:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
	local objScene = TFSceneManager:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
	return objScene
end


--[[
	读取场景配置
--]]
function TFDirector:readGameConfig(szGameConfigPath)
	return TFSceneManager:readGameConfig(szGameConfigPath)
end

--[[
	场景创建
--]]
function TFDirector:createCustomScene(szSceneType, tData)
	return TFSceneManager:createCustomScene(szSceneType, tData)
end

function TFDirector:currentScene()
	return me.Director:getRunningScene()
	--return TFSceneManager:currentScene()
end

function TFDirector:currentSceneType()
	return TFSceneManager:currentSceneType()
end

local _captureImgBuffName = "TFDirector_CaptureImage"
function TFDirector:captureTexture(objUI)
	if not objUI then return nil end
	local size = objUI:getSize()
	local objRendTexture = CCRenderTexture:create(size.width, size.height, kCCTexture2DPixelFormat_RGBA8888)
	local oldPos = objUI:getPosition()
	oldPos = ccp(oldPos.x, oldPos.y)
	objUI:setPosition(ccp(0, 0))
    objRendTexture:begin()
    objUI:visit()
    objRendTexture:endToLua()
    objUI:setPosition(oldPos)

    me.TextureCache:removeTextureForKey(_captureImgBuffName)
    local objImage = objRendTexture:newCCImage()
    local objTex = me.TextureCache:addUIImage(objImage, _captureImgBuffName)
    objImage:release()
    objRendTexture:clear(0, 0, 0, 0)
    return objTex
end

function TFDirector:captureImage(objUI)
	local tex = self:captureTexture(objUI)
	if tex then
		local img = TFImage:create()
		img:setTexture(tex)
		local size = tex:getContentSize()
		img:setTextureRect(CCRectMake(0, 0, size.width, size.height))
		me.TextureCache:removeTextureForKey(_captureImgBuffName)
    	return img
	end
end

function TFDirector:makeLuaVMSnapshot()
	self.snapshots_ = self.snapshots_ or {}
    self.snapshots_[#self.snapshots_ + 1] = TFLuaStackSnapshot()
    while #self.snapshots_ > 2 do
        table.remove(self.snapshots_, 1)
    end
    return self
end

function TFDirector:checkLuaVMLeaks()
    assert(#self.snapshots_ >= 2, "TFDirector:checkLuaVMLeaks() - need least 2 snapshots")
    local s1 = self.snapshots_[1]
    local s2 = self.snapshots_[2]
    for k, v in pairs(s2) do
        if s1[k] == nil then
            print(k, v)
        end
    end
    return self
end

function TFDirector:printLuaVMLeaks()
	if self.snapshots_ and #self.snapshots_ > 0 then
		local s = self.snapshots_[#self.snapshots_]
		for k, v in pairs(s) do
	           CCLuaLog(tostring(k) .. '  '  .. tostring(v) )
	    end
	end
end

function TFDirector:LoadChunksFromZIP(szZIPFilePath)
	meLoadChunksFromZIP(szZIPFilePath)
end

function TFDirector:startRemoteDebug(host)
	-- implements in TFDirector_Debug
end

function TFDirector:purgeDebug()
	-- implements in TFDirector_Debug
end

function TFDirector:createDebugerLayer(objScene)

end

function TFDirector:setTouchBeganDefaultDelay(fDelay)
	CCNode:setTouchBeganDefaultDelay(fDelay)
end

function TFDirector:disableDiviceSleep(bNotSleep)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		TFLuaOc = TFLuaOc or require('TFFramework.TFLuaOc')
		TFLuaOc.callStaticMethod("AppController","disableDeviceSleep",{notSleep = bNotSleep})
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
	end
end

function TFDirector:setTouchSingled(bIsSingleTouch)
	me.Director:setTouchSingled(bIsSingleTouch)
end

function TFDirector:setTouchEnabled(bEnabled)
	me.Director:setTouchEnabled(bEnabled)
end

function TFDirector:getTouchEnabled()
	return me.Director:getTouchEnabled()
end

return TFDirector:new()
