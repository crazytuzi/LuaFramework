-- CrossWarScene
-- the main scene of the cross-server war mode

local CrossWarScene = class("CrossWarScene", UFCCSBaseScene)

-- #以下三个参数都是从征战界面的快捷入口传进来的，根据不同状态传进true or false
-- #param autoToScoreMatch: 	是否一进来就切到积分赛界面
-- #param autoShowWinAward: 	是否一进来就切到积分赛界面，并弹出连胜奖励
-- #param autoToChampionship: 是否一进来就切到争霸赛界面
-- #param autoShowServerAward:	是否一进来就切到争霸赛界面，并弹出全服奖励
-- #param autoShowBetAward:		是否一进来就切到争霸赛界面，并弹出押注奖励
function CrossWarScene:ctor(autoToScoreMatch, autoShowWinAward, autoToChampionship, autoShowServerAward, autoShowBetAward, scenePack, ...)
	self._autoToScoreMatch		= autoToScoreMatch
	self._autoShowWinAward		= autoShowWinAward
	self._autoToChampionship	= autoToChampionship
	self._autoShowServerAward	= autoShowServerAward
	self._autoShowBetAward		= autoShowBetAward
	self._timer = nil
	self.super.ctor(self, ...)

	if scenePack then
		G_GlobalFunc.savePack(self, scenePack)
	end
end

function CrossWarScene:onSceneLoad(...)

end

function CrossWarScene:onSceneEnter(...)
	-- attach top bar and bottom bar
	if not self._topBar then
		self._topBar	= G_commonLayerModel:getStrengthenRoleInfoLayer()
		self:addUILayerComponent("TopBar", self._topBar, true)
	end

	if not self._bottomBar then
		self._bottomBar = G_commonLayerModel:getSpeedbarLayer()
		self:addUILayerComponent("BottomBar", self._bottomBar, true)
	end

	-- attach the entry layer
	-- 如果之前有别的scene刚pop出去，这里就不用回到入口了
	if not self._mainBody then
		-- 积分赛开始，且玩家已分组，直接跳到积分赛界面
		if self._autoToScoreMatch and G_Me.crossWarData:canChallenge() then
			local layer = require("app.scenes.crosswar.CrossWarScoreMatchLayer").create()
			self:replaceLayer(layer)
			self._autoToScoreMatch = false

		-- 玩家有连胜奖励可领，直奔积分赛界面并弹出奖励界面（and后面的条件用来防御比赛状态已变的情况）
		elseif self._autoShowWinAward and G_Me.crossWarData:canEnterScoreMatch() then
			local layer = require("app.scenes.crosswar.CrossWarScoreMatchLayer").create()
			self:replaceLayer(layer)
			layer:showWinAwardLayer()
			self._autoShowWinAward = false

		-- 争霸赛开始，玩家有参赛资格，且有挑战次数，跳到争霸赛界面
		elseif self._autoToChampionship and G_Me.crossWarData:isInChampionship() then
			local layer = require("app.scenes.crosswar.CrossWarChampionshipLayer").create()
			self:replaceLayer(layer)
			self._autoToChampionship = false

		-- 玩家有全服奖励可领，直奔争霸赛界面并弹出全服奖励
		elseif self._autoShowServerAward and G_Me.crossWarData:isChampionshipEnd() then
			local layer = require("app.scenes.crosswar.CrossWarChampionshipLayer").create()
			self:replaceLayer(layer)
			layer:showServerAward()
			self._autoShowServerAward = false

		-- 玩家有押注奖励可领，直奔争霸赛界面并弹出押注奖励
		elseif self._autoShowBetAward and G_Me.crossWarData:isChampionshipEnd() then
			local layer = require("app.scenes.crosswar.CrossWarChampionshipLayer").create()
			self:replaceLayer(layer)
			layer:prepareToShowBetAward()
			self._autoShowBetAward = false

		-- 正常情况。。。
		else
			self:goToEntry()
		end
	end

	-- register event listner
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO, self._onRcvBattleInfo, self)

	-- pull the times of different war stages, if not pulled yet, or pull current stage
	if not G_Me.crossWarData:isBattleTimePulled() then
		G_HandlersManager.crossWarHandler:sendGetBattleTime()
	else
		G_HandlersManager.crossWarHandler:sendGetBattleInfo()
	end
end

function CrossWarScene:onSceneExit(...)
	self:removeComponent(SCENE_COMPONENT_GUI, "TopBar")
	self:removeComponent(SCENE_COMPONENT_GUI, "BottomBar")
	self._topBar = nil
	self._bottomBar = nil

	-- remove event listner
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarScene:onSceneUnload(...)
	-- close the timer
	if self._timer then
		self._timer:closeTimer()
		self._timer = nil
	end
end

function CrossWarScene:_onRcvBattleInfo()
	-- 第一次进界面拉到比赛状态之后，才开启计时器
	if not self._timer then
		self._timer = require("app.scenes.crosswar.CrossWarTimer").new()
		self._timer:startTimer()
	end

	-- 只需要一次，之后可以取消事件监听
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarScene:replaceLayer(layer)
	-- remove current layer
	if self._mainBody then
		self._mainBody:unregisterKeypadEvent()
		self:removeComponent(SCENE_COMPONENT_GUI, "MainBody")
	end

	-- add new layer
	self._mainBody = layer
	self._mainBody:setZOrder(-1)
	self:addUILayerComponent("MainBody", self._mainBody, false)
	self:adapterLayerHeight(self._mainBody, self._topBar, self._bottomBar, -4, 0)
end

function CrossWarScene:goToEntry()
	-- remove current layer
	if self._mainBody then
		self._mainBody:unregisterKeypadEvent()
		self:removeComponent(SCENE_COMPONENT_GUI, "MainBody")
	end

	-- attach the entry layer
	self._mainBody = require("app.scenes.crosswar.CrossWarEntryLayer").create(GlobalFunc.getPack(self))
	self._mainBody:setZOrder(-1)
	self:addUILayerComponent("MainBody", self._mainBody, false)
	self:adapterLayerHeight(self._mainBody, self._topBar, self._bottomBar, -4, 0)
end

return CrossWarScene