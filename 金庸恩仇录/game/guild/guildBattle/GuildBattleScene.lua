local MAX_ZORDER = 101
local NORMAL_SIZE = 20

local GuildBaseScene = require("game.guild.utility.GuildBaseScene")
local GuildBattleScene = class("GuildBattleScene", GuildBaseScene)

--[[
local GuildBattleScene = class("GuildBattleScene", function()
	local bottomFile = "guild/guild_battle_bottom.ccbi"
	return require("game.guild.utility.GuildBaseScene").new({
	topFile = "public/top_frame.ccbi",
	bottomFile = bottomFile,
	isOther = false
	})
end)
]]

local guildMsg = {
getMedalRank = function(param)
	local _callback = param.callback
	local msg = {m = "union", a = "medalRank"}
	RequestHelper.request(msg, _callback, param.errback)
end,

getDamageRank = function(param)
	local _callback = param.callback
	local msg = {m = "union", a = "damageRank"}
	RequestHelper.request(msg, _callback, param.errback)
end
}
function GuildBattleScene:ctor(data)
	GuildDynamicScene.super.ctor(self, {
	topFile = "public/top_frame.ccbi",
	bottomFile = "guild/guild_battle_bottom.ccbi",
	isOther = false
	})
	
	ResMgr.removeBefLayer()
	local centerH = self:getCenterHeight()
	self._top_height = self:getTopHeight()
	self._bottom_height = self:getBottomHeight()
	self._center_size = CCSizeMake(display.width, centerH)
	self.centerLayer = {}
	self:showCenterLayer(GuildBattleLayerType.MainLayer)
	self.timeNode = display.newNode()
	self:addChild(self.timeNode)
	self._rootnode.shuchuBtn:addHandleOfControlEvent(function(eventName, sender)
		local function toLayer(topPlayers)
			local layer = require("game.guild.guildQinglong.GuildQLBossRankLayer").new({
			topPlayers = topPlayers,
			showType = 2,
			confirmFunc = function()
				self._rootnode.shuchuBtn:setEnabled(true)
			end
			})
			game.runningScene:addChild(layer, 8751)
		end
		self._rootnode.shuchuBtn:setEnabled(false)
		guildMsg.getDamageRank({
		callback = function(data)
			toLayer(data.rtnObj)
		end,
		errback = function()
			self._rootnode.shuchuBtn:setEnabled(true)
		end
		})
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.rewardShowBtn:addHandleOfControlEvent(function(eventName, sender)
		local data = require("data.data_gvg_battlejiangli_gvg_battlejiangli")
		self:addChild(require("game.Worldboss.WorldBossExtraRewardLayer").new({rewardListData = data, normalReward = true}), 100)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.gongxunBtn:addHandleOfControlEvent(function(eventName, sender)
		local function toLayer(topList)
			local layer = require("game.guild.guildQinglong.GuildQLBossRankLayer").new({
			topPlayers = topList,
			showType = 3,
			titleLabel = common:getLanguageString("@GuildBattleExploitRank"),
			confirmFunc = function()
				self._rootnode.gongxunBtn:setEnabled(true)
			end
			})
			game.runningScene:addChild(layer, 8751)
		end
		self._rootnode.gongxunBtn:setEnabled(false)
		guildMsg.getMedalRank({
		callback = function(data)
			toLayer(data.rtnObj)
		end,
		errback = function()
			self._rootnode.gongxunBtn:setEnabled(true)
		end
		})
	end,
	CCControlEventTouchUpInside)
	addbackevent(self)
end

GuildBattleLayerType = {
MainLayer = 1,
CityLayer = 2,
WallList = 3,
SelectMember = 4,
BossInfo = 5
}
local center_layer_table = {
"game.guild.guildBattle.GuildBattleMainLayer",
"game.guild.guildBattle.GuildBattleCityLayer",
"game.guild.guildBattle.GuildBattleWallListLayer",
"game.guild.guildBattle.GuildBattleSelectMember",
"game.guild.guildBattle.GuildBattleBossInfoLayer"
}
function GuildBattleScene:showCenterLayer(layerType, paramData)
	if self.layerType == layerType then
		return
	end
	if self.centerLayer[self.layerType] then
		if paramData and paramData.remove then
			self.centerLayer[self.layerType]:removeFromParentAndCleanup(true)
			self.centerLayer[self.layerType] = nil
		else
			self.centerLayer[self.layerType]:setVisible(false)
		end
	end
	self.layerType = layerType
	if not self.centerLayer[layerType] then
		local layer = require(center_layer_table[layerType]).new({
		parent = self,
		size = self._center_size,
		data = paramData
		})
		self:addChild(layer)
		layer:setPositionY(self._bottom_height)
		self.centerLayer[layerType] = layer
	end
	self.centerLayer[layerType]:setVisible(true)
	self._bottomNode:setVisible(true)
	self.centerLayer[layerType]:initData(paramData)
end

function GuildBattleScene:refreshTopInfo()
end

function GuildBattleScene:refreshBottomInfo()
end

function GuildBattleScene:onEnter()
	game.runningScene = self
	GuildBattleScene.super.onEnter(self)
	local function stateChangeNotice()
		self.centerLayer[self.layerType]:initData()
	end
	GuildBattleModel.setStateChangeNotice(stateChangeNotice)
	local update = function(dt)
		GuildBattleModel.updateTime(dt)
	end
	self.timeNode:schedule(update, 1)
	self.centerLayer[self.layerType]:initData()
end

function GuildBattleScene:onExit()
	GuildBattleScene.super.onExit(self)
	self.timeNode:stopAllActions()
end

return GuildBattleScene