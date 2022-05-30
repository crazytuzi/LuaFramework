local data_boss_boss = require("data.data_boss_boss")
require("utility.richtext.richText")
local MAX_ZORDER = 1100
local MOVE_TIME = 0.7
local MOVE_DISY = 10
local DELAY_TIME = 0.2

local BaseScene = require("game.BaseScene")
local WorldBossNormalScene = class("WorldBossNormalScene", BaseScene)
--[[
local WorldBossNormalScene = class("WorldBossNormalScene", function()
	return require("game.BaseScene").new({
	contentFile = "huodong/worldBoss_normal_layer.ccbi",
	bgImage = "bg/weijiao_yishou_bg.jpg",
	isHideBottom = true
	})
end)
]]


function WorldBossNormalScene:getHistoryData(bIsCheck)
	RequestHelper.worldBoss.history({
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			CCMessageBox(data["0"], "Error")
		else
			self:initData(data, bIsCheck)
		end
	end
	})
end

function WorldBossNormalScene:initData(data, bIsCheck)
	local waitSecs = data["1"]
	local hisBattle = data["2"]
	if hisBattle ~= nil and not bIsCheck then
		self._rootnode.level_lbl:setString("LV." .. tostring(hisBattle.level))
		self._rootnode.name_1:setString(tostring(hisBattle.name))
		self._rootnode.name_2:setString(tostring(hisBattle.name))
		local width = self._rootnode.hang_1:getContentSize().width
		local contentLabel = getRichText(common:getLanguageString("@BattleRewards", hisBattle.name), width - 10, hrefHandler, 10)
		contentLabel:setPosition((width - contentLabel:getContentSize().width) / 2, contentLabel:getContentSize().height - contentLabel.offset)
		self._rootnode.hang_1:removeAllChildren()
		self._rootnode.hang_1:addChild(contentLabel)
		local contentLabel2 = getRichText(common:getLanguageString("@BattleRewards2", hisBattle.name), width - 10, hrefHandler, 10)
		contentLabel2:setPosition((width - contentLabel2:getContentSize().width) / 2, contentLabel2:getContentSize().height - contentLabel2.offset)
		self._rootnode.hang_2:removeAllChildren()
		self._rootnode.hang_2:addChild(contentLabel2)
		local top3Name = ""
		for i = 1, 3 do
			if hisBattle.top3Name ~= nil and hisBattle.top3Name[i] ~= nil then
				top3Name = top3Name .. hisBattle.top3Name[i]
			else
				top3Name = top3Name .. common:getLanguageString("@NotHave")
			end
			if i < 3 then
				top3Name = top3Name .. "、"
			end
		end
		self._rootnode.weijiao_lbl:setString(common:getLanguageString("@shangciwjqsm") .. top3Name)
		local killName = hisBattle.killName
		if killName == nil or killName == "" then
			killName = common:getLanguageString("@NotHave")
		end
		self._rootnode.jisha_lbl:setString(common:getLanguageString("@shangcijsz") .. killName)
	end
	self:checkTime(waitSecs)
end

function WorldBossNormalScene:checkTime(waitSecs)
	self._time = waitSecs
	self._rootnode.time_lbl:setString(tostring(format_time(self._time)))
	if self._time > 0 then
		self._rootnode.time_node:setVisible(true)
		self._rootnode.battleBtn:setVisible(false)
	else
		self._rootnode.time_node:setVisible(false)
		self._rootnode.battleBtn:setVisible(true)
	end
end

function WorldBossNormalScene:ctor(data)
	WorldBossNormalScene.super.ctor(self, {
	contentFile = "huodong/worldBoss_normal_layer.ccbi",
	bgImage = "bg/weijiao_yishou_bg.jpg",
	isHideBottom = true
	})
	
	ResMgr.removeBefLayer()
	
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.shuchuBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:addChild(require("game.Worldboss.WorldBossRankLayer").new(), MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.extraRewardBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:addChild(require("game.Worldboss.WorldBossExtraRewardLayer").new({
		rewardListData = data_boss_boss,
		level = game.player:getLevel(),
		isGuildBoss = false
		}), MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.battleBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.battleBtn:setVisible(false)
	self._bossSprite = display.newSprite()
	self._bossSprite:setDisplayFrame(ResMgr.getHeroFrame(4901, 0))
	self._bossSprite:setScale(1.3)
	local bossIconNode = self._rootnode.boss_icon_node
	self._bossSprite:setPosition(bossIconNode:getContentSize().width / 2, self._bossSprite:getContentSize().height / 2)
	bossIconNode:addChild(self._bossSprite)
	self._bossSprite:runAction(CCRepeatForever:create(transition.sequence({
	CCMoveBy:create(MOVE_TIME, cc.p(0, MOVE_DISY)),
	CCDelayTime:create(DELAY_TIME),
	CCMoveBy:create(MOVE_TIME, cc.p(0, -MOVE_DISY)),
	CCDelayTime:create(DELAY_TIME)
	})))
	self._time = -1
	self:initData(data, false)
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		self._rootnode.kaiqi_time:setString("11:00")
	else
		self._rootnode.kaiqi_time:setString("21:00")
	end
	alignNodesOneByAllCenterX(self._rootnode.hang_5, {
	self._rootnode.kaiqi_msg_0,
	self._rootnode.kaiqi_time,
	self._rootnode.kaiqi_msg
	}, 5)
end

function WorldBossNormalScene:onEnter()
	WorldBossNormalScene.super.onEnter(self)
	GameAudio.playMainmenuMusic(true)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	local function updateTime()
		if self._time > 0 then
			self._time = self._time - 1
			self._rootnode.time_lbl:setString(tostring(format_time(self._time)))
			if self._time <= 0 then
				self:getHistoryData(true)
			end
		end
	end
	self.scheduler = require("framework.scheduler")
	self._schedule = self.scheduler.scheduleGlobal(updateTime, 1, false)
end

function WorldBossNormalScene:onExit()
	WorldBossNormalScene.super.onExit(self)
	if self._schedule ~= nil then
		self.scheduler.unscheduleGlobal(self._schedule)
	end
end

return WorldBossNormalScene