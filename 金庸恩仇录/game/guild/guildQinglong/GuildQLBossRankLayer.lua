--ÐÞ¸ÄÍê³É
local data_ui_ui = require("data.data_ui_ui")
local enumShowType = {
qinglongType = 1,
guildDamageRank = 2,
guildGongxunRank = 3
}

local GuildQLBossRankLayer = class("GuildQLBossRankLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildQLBossRankLayer:initData(topPlayers)
	self._rankData = topPlayers
	if self._showType ~= enumShowType.guildGongxunRank then
		local hitData = self._rankData[1]
		if hitData.acc == "##" then
			hitData.isTrueData = false
			hitData.name = common:getLanguageString("@NotHave")
		end
		local curNum = #self._rankData
		if self._rankData ~= nil and curNum < 11 then
			for i = curNum + 1, 11 do
				table.insert(self._rankData, {
				isTrueData = false,
				rank = i - 1,
				acc = common:getLanguageString("@NotHave"),
				name = common:getLanguageString("@NotHave"),
				hurt = 0,
				lv = 0
				})
			end
		end
	end
	local viewSize = self._rootnode.listView:getContentSize()
	local function createFunc(index)
		local item = require(self._default_item).new()
		return item:create({
		viewSize = viewSize,
		itemData = self._rankData[index + 1],
		checkFunc = function(cell)
			local index = cell:getIdx() + 1
			self:checkZhenrong(index)
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(self._rankData[index + 1])
	end
	local cellContentSize = require(self._default_item).new():getContentSize()
	self._rootnode.listView:removeAllChildren()
	self._listTable = require("utility.TableViewExt").new({
	size = viewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._rankData,
	cellSize = cellContentSize
	})
	self._listTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self._listTable)
end

function GuildQLBossRankLayer:ctor(param)
	self:setNodeEventEnabled(true)
	local topPlayers = param.topPlayers
	local confirmFunc = param.confirmFunc
	self._showType = param.showType
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/worldBoss_rank_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	if param.titleLabel then
		self._rootnode.titleLabel:setString(param.titleLabel)
	end
	if param.showType == enumShowType.guildDamageRank then
		self._rootnode.top_msg_lbl:setString(data_ui_ui[23].content)
	elseif param.showType == enumShowType.guildGongxunRank then
		self._rootnode.top_msg_lbl:setString(data_ui_ui[24].content)
	else
		self._rootnode.top_msg_lbl:setString(data_ui_ui[8].content)
	end
	if param.showType == enumShowType.guildGongxunRank then
		self._default_item = "game.guild.guildBattle.GuildBattleGuildListItem"
	else
		self._default_item = "game.Worldboss.WorldBossRankItem"
	end
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if confirmFunc ~= nil then
			confirmFunc()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self:initData(topPlayers)
end

function GuildQLBossRankLayer:checkZhenrong(index)
	if ENABLE_ZHENRONG then
		local layer = require("game.form.EnemyFormLayer").new(1, self._rankData[index].acc)
		layer:setPosition(0, 0)
		self:addChild(layer, 10000)
	else
		show_tip_label(data_error_error[2800001].prompt)
	end
end

function GuildQLBossRankLayer:onExit()
	
end

return GuildQLBossRankLayer