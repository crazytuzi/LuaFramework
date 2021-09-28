-- 这个类用于在CrossPVPScene加载之前拉取必需的数据，
-- 以让CrossPVPScene在加载时便知道需要跳转到哪个子界面
local CrossPVP = class("CrossPVP")

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPTimer = require("app.scenes.crosspvp.CrossPVPTimer")

-- a unique instance of CrossPVP, simulating singleton
local _crossPVPInstance = nil

-- a function to return the unique instance
local getInstance = function()
	if not _crossPVPInstance then
		_crossPVPInstance = require("app.scenes.crosspvp.CrossPVP").new()
	end

	return _crossPVPInstance
end

-- ready to load the CrossPVPScene
function CrossPVP.launch(scenePack)
	-- 如果没有网络，就弹出断线重联界面, 然后直接return
	if not G_NetworkManager:isConnected() then
		G_NetworkManager:checkConnection()
	    return
	end

	local instance = getInstance()
	instance:_reset()
	instance._ref = instance._ref + 1
	instance._withoutScene = false
	instance._scenePack = scenePack
	instance:_getDataFromServer()
end

-- launch without entering scene directly
-- it's called when entering the "ZhengZhanLayer" or "MainButtonLayer", only to check the conditions of showing shortcut buttons
function CrossPVP.launchWithoutScene(outerLayer)
	local instance = getInstance()
	instance:_reset()
	instance._ref = instance._ref + 1
	instance._withoutScene = true	-- <--important
	instance._outerLayer = outerLayer
	instance:_getDataFromServer()
end

-- exit
function CrossPVP.exit()
	if _crossPVPInstance then
		_crossPVPInstance._ref = _crossPVPInstance._ref - 1

		if _crossPVPInstance._ref == 0 then
			if _crossPVPInstance._timer then
				_crossPVPInstance._timer:closeTimer()
			end
			_crossPVPInstance:_reset()
			_crossPVPInstance = nil
		end
	end
end

function CrossPVP:matchNotOpen()
	if _crossPVPInstance then
		-- 如果是要尝试进入场景，就显示一个未开的窗口，并关闭自己
		if not _crossPVPInstance._withoutScene then
			local layer = require("app.scenes.crosspvp.CrossPVPIntroLayer").create()
			uf_sceneManager:getCurScene():addChild(layer)

			CrossPVP.exit()
		end
	end
end

-- 是否需要在状态切换时发事件(在征战界面中不需要)
function CrossPVP.needDispatchEvent()
	if _crossPVPInstance then
		return not _crossPVPInstance._withoutScene
	end
	return false
end

-- 告诉征战界面开启报名倒计时
function CrossPVP.showApplyTime()
	if _crossPVPInstance and _crossPVPInstance._outerLayer and _crossPVPInstance._outerLayer.createCrossPVPApplyTimer then
		_crossPVPInstance._outerLayer:createCrossPVPApplyTimer()
	end
end

-- 告诉征战界面刷新一下快捷入口按钮
function CrossPVP.updateCrossPVPTips()
	if _crossPVPInstance and _crossPVPInstance._outerLayer and _crossPVPInstance._outerLayer.updateCrossPVPTips then
		_crossPVPInstance._outerLayer:updateCrossPVPTips()
	end
end

function CrossPVP:ctor()
	self._ref = 0
	self._timer = nil
	self:_reset()
end

function CrossPVP:_reset()
	self._withoutScene 	= false -- 模块启动计时逻辑后，是否直接进入界面
	self._preGameScene 	= nil 	-- 当从服务器拉数据时，当前的游戏内场景
	self._scenePack	   	= nil 	-- 返回时要回到的场景
	self._outerLayer	= nil 	-- 外部调用界面的指针
end

-- 从服务器拉取基本信息
function CrossPVP:_getDataFromServer()
	-- 计时器都已经启动了，说明之前拉取过数据了
	if self._timer then
		if not self._withoutScene then
			self:_enterScene()
		end
		return
	end

	-- 记录下当时的游戏内场景
	self._preGameScene = G_SceneObserver:getSceneName()

	-- 注册协议事件
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_SCHEDULE, self._onRcvSchedule, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BASE_INFO, self._onRcvBaseInfo, self)

	-- 请求比赛时间
	if not G_Me.crossPVPData:hasRcvTime() then
		G_HandlersManager.crossPVPHandler:sendGetSchedule()
	else
		G_HandlersManager.crossPVPHandler:sendGetBaseInfo()
	end
end

-- 获取时间表之后的处理
function CrossPVP:_onRcvSchedule()
	G_HandlersManager.crossPVPHandler:sendGetBaseInfo()
end

-- 获取基础数据之后的处理
function CrossPVP:_onRcvBaseInfo()
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_BASE_INFO)

	-- 首先，如果此时外部的场景已经切换(比如可能从征战退回了主场景)，那么不再做任何处理
	if self._preGameScene ~= "" and self._preGameScene ~= G_SceneObserver:getSceneName() then
		return
	end

	-- 获取当前比赛赛程
	local curCourse = G_Me.crossPVPData:getCourse()
	local curStage  = G_Me.crossPVPData:getStage()
	if curCourse == CrossPVPConst.COURSE_NONE or 
	   curCourse == CrossPVPConst.COURSE_EXTRA and curStage ~= CrossPVPConst.STAGE_REVIEW then
	   	if G_Me.crossPVPData:isBeforeApply() then
	   		CrossPVP.showApplyTime()
	   	end
		CrossPVP.matchNotOpen()
	else
		-- 如果可以拉取上轮比赛的回顾信息，就拉取
		if G_Me.crossPVPData:canRequestReviewInfo() then
			uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_REVIEW_INFO, self._onRcvReviewInfo, self)
			G_HandlersManager.crossPVPHandler:sendGetReviewInfo()
		-- 如果可以拉取房间号，就拉取
		elseif G_Me.crossPVPData:needRequestRoomID() then
			uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_ROLE_SUCC, self._onRcvRoomInfo, self)
			G_HandlersManager.crossPVPHandler:sendGetCrossPvpRole()
		-- 否则就直接进界面
		else
			self:_enterScene()

			-- 顺便添加本地通知
			self:_addNotification()
		end
	end
end

-- 获取回顾数据之后的处理
function CrossPVP:_onRcvReviewInfo()
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_REVIEW_INFO)

	-- 首先，如果此时外部的场景已经切换(比如可能从征战退回了主场景)，那么不再做任何处理
	if self._preGameScene ~= "" and self._preGameScene ~= G_SceneObserver:getSceneName() then
		return
	end

	-- 进界面
	self:_enterScene()
end

-- 获取房间号之后的处理
function CrossPVP:_onRcvRoomInfo()
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_ROLE_SUCC)

	-- 首先，如果此时外部的场景已经切换(比如可能从征战退回了主场景)，那么不再做任何处理
	if self._preGameScene ~= "" and self._preGameScene ~= G_SceneObserver:getSceneName() then
		return
	end

	-- 进界面
	self:_enterScene()
end

-- 拉取基本信息完成，进入界面
function CrossPVP:_enterScene()
	-- 启动CrossPVP的计时器
	if not self._timer then
		self._timer = CrossPVPTimer.new()
		self._timer:startTimer()
	end

	-- 如果只是进入了征战界面，那么只刷新快捷入口
	-- 如果是要进入模块，则加载CrossPVPScene
	if self._withoutScene then
		CrossPVP.updateCrossPVPTips()
	else
		G_Loading:showLoading(function() 
			uf_sceneManager:replaceScene(require("app.scenes.crosspvp.CrossPVPScene").new(self._scenePack))
		end)
	end
	self._preGameScene = nil
end

-- 添加本地通知
function CrossPVP:_addNotification()
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) and
	   not G_Me.crossPVPData:hasAddNotify() then

		G_NotifycationManager:registerCrossPVPNotification()
		G_Me.crossPVPData:setHasAddNotify(true)
	end
end

return CrossPVP