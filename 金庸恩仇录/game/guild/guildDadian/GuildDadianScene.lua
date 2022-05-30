require("data.data_error_error")
local data_union_juanxian_union_juanxian = require("data.data_union_juanxian_union_juanxian")
local MAX_ZORDER = 101
local NORMAL_SIZE = 20

local GuildBaseScene = require("game.guild.utility.GuildBaseScene")
local GuildDadianScene = class("GuildDadianScene", GuildBaseScene)

function GuildDadianScene:reqContribute(cell)
	RequestHelper.Guild.unionDonate({
	unionid = game.player:getGuildMgr():getGuildInfo().m_id,
	donatetype = cell:getId(),
	errback = function(data)
		cell:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
			cell:setBtnEnabled(true)
		else
			ResMgr.showErr(2900084)
			local addmoney = data_union_juanxian_union_juanxian[cell:getIdx() + 1].addmoney
			table.insert(self._dynamciList, 1, {
			roleName = game.player:getPlayerName(),
			conMoney = addmoney
			})
			self:reloadDynamicListView(self._dynamciList)
			self:updateContributeNum(self._curContributedNum + 1)
			self:updateLevel(self._level, self._currentUnionMoney + addmoney)
			game.player:updateMainMenu({
			silver = data.rtnObj.surplusSliver,
			gold = data.rtnObj.surplusGod
			})
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			PostNotice(NoticeKey.CommonUpdate_Label_Gold)
			self:setContributeState(true)
		end
	end
	})
end

function GuildDadianScene:reqLevelup(msgBox)
	levelupBtn = self._rootnode.levelup_btn
	RequestHelper.Guild.unionLevelUp({
	unionid = game.player:getGuildMgr():getGuildInfo().m_id,
	buildtype = self._buildType,
	errback = function(data)
		levelupBtn:setEnabled(true)
		msgBox:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data)
		ResMgr.showErr(2900083)
		msgBox:removeFromParentAndCleanup(true)
		self:updateLevel(data.buildLevel, data.currentUnionMoney)
		self:updateContributeNum(self._curContributedNum, data.roleMaxNum)
		levelupBtn:setEnabled(true)
	end
	})
end

function GuildDadianScene:ctor(data)
	game.runningScene = self
	local bottomFile = "guild/guild_bottom_frame_normal.ccbi"
	local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType
	if jopType ~= GUILD_JOB_TYPE.normal then
		bottomFile = "guild/guild_bottom_frame.ccbi"
	end
	GuildDadianScene.super.ctor(self, {
	topFile = "public/top_frame.ccbi",
	bottomFile = bottomFile,
	bgImage = "ui_common/common_bg.png",
	isOther = false
	})
	
	self._buildType = GUILD_BUILD_TYPE.dadian
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("guild/guild_dadian_layer.ccbi", proxy, self._rootnode)
	local centerH = self:getCenterHeight()
	local topH = self:getTopHeight()
	local bottomH = self:getBottomHeight()
	local bagH = self._rootnode.tag_bag:getContentSize().height
	local posY = (display.height - (topH - bottomH)) / 2
	node:setPosition(display.cx, posY)
	self:addChild(node)
	if centerH < bagH then
		self._rootnode.tag_bag:setScale(centerH / bagH)
	end
	self._rootnode.titleLabel:setString(common:getLanguageString("@GuildCenter"))
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
	end,
	CCControlEventTouchUpInside)
	
	local guildMgr = game.player:getGuildMgr()
	local guildInfo = guildMgr:getGuildInfo()
	local jopType = guildInfo.m_jopType
	local levelupBtn = self._rootnode.levelup_btn
	if jopType ~= GUILD_JOB_TYPE.leader and jopType ~= GUILD_JOB_TYPE.assistant then
		levelupBtn:setVisible(false)
	else
		levelupBtn:setVisible(true)
		levelupBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if guildMgr:checkIsReachMaxLevel(self._buildType, self._level) == true then
				show_tip_label(data_error_error[2900021].prompt)
			else
				levelupBtn:setEnabled(false)
				local msgBox = require("game.guild.GuildBuildLevelUpMsgBox").new({
				curLevel = self._level,
				toLevel = self._level + 1,
				needCoin = self._needCoin,
				curCoin = self._currentUnionMoney,
				buildType = self._buildType,
				cancelFunc = function()
					levelupBtn:setEnabled(true)
				end,
				confirmFunc = function(msgBox)
					self:reqLevelup(msgBox)
				end
				})
				game.runningScene:addChild(msgBox, MAX_ZORDER)
			end
		end,
		CCControlEventTouchUpInside)
		
	end
	local rtnObj = data.rtnObj
	game.player:setVip(rtnObj.viplevel)
	self:updateContributeNum(rtnObj.contributed, rtnObj.roleMaxNum)
	self._hasContribute = true
	if rtnObj.isCon == 0 then
		self._hasContribute = false
	end
	self:updateLevel(rtnObj.unionLevel, rtnObj.currentUnionMoney)
	self:createAllLbl()
	self:reloadCrontributeListView()
	self._dynamciList = {}
	for i, v in ipairs(rtnObj.dynamciList) do
		table.insert(self._dynamciList, {
		roleName = v[1],
		conMoney = v[4]
		})
	end
	self:reloadDynamicListView(self._dynamciList)
end

function GuildDadianScene:createAllLbl()
	local guildMgr = game.player:getGuildMgr()
	local yColor = cc.c3b(255, 222, 0)
	--升级消耗资金
	self:createTTF(common:getLanguageString("@GuildGoldForUpgrade"), yColor, self._rootnode, "cost_coin_msg_lbl")
	self._rootnode.cost_coin_lbl:setPositionX(self._rootnode.cost_coin_msg_lbl:getPositionX() + self:getShadowLblWidth(self._rootnode.cost_coin_msg_lbl))
	--帮派持有资金
	self:createTTF(common:getLanguageString("@GuildGold"), yColor, self._rootnode, "cur_coin_msg_lbl")
	self._rootnode.cur_coin_lbl:setPositionX(self._rootnode.cur_coin_msg_lbl:getPositionX() + self:getShadowLblWidth(self._rootnode.cur_coin_msg_lbl))
	--升级帮派大殿可以:
	self:createTTF(common:getLanguageString("@GuildCenterUpgrade"), cc.c3b(0, 219, 52), self._rootnode, "levelup_msg_lbl")
end

function GuildDadianScene:createTTF(text, color, nodes, name, size)
	local lbl = ui.newTTFLabelWithShadow({
	text = text,
	size = size or NORMAL_SIZE,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = color,
	shadowColor = FONT_COLOR.BLACK,
	})
	ResMgr.replaceKeyLableEx(lbl, nodes, name, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildDadianScene:getShadowLblWidth(node)
	--local child = node:getChildByTag(1)
	return node:getContentSize().width
end

function GuildDadianScene:updateContributeNum(curNum, totalNum)
	self._curContributedNum = curNum
	self._roleMaxNum = totalNum or self._roleMaxNum
	self._rootnode.contribute_num_lbl:setString(common:getLanguageString("@TodayTRTime") .. tostring(self._curContributedNum) .. "/" .. tostring(self._roleMaxNum))
end

function GuildDadianScene:updateLevel(level, currentUnionMoney)
	local guildMgr = game.player:getGuildMgr()
	self._level = level
	guildMgr:getGuildInfo().m_level = self._level
	self._currentUnionMoney = currentUnionMoney
	self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level)
	self:createTTF("LV." .. tostring(self._level), cc.c3b(255, 222, 0), self._rootnode, "cur_level_lbl")
	self:createTTF(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode, "cur_coin_lbl")
	self:updateNeedCoinLbl(self._needCoin)
end

function GuildDadianScene:updateNeedCoinLbl(needCoin)
	local str
	if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then
		str = common:getLanguageString("@GuildUpgradeMax")
	else
		str = tostring(needCoin)
	end
	self:createTTF(str, FONT_COLOR.WHITE, self._rootnode, "cost_coin_lbl")
end

function GuildDadianScene:setContributeState(bHasCont)
	self._hasContribute = bHasCont
	self:reloadCrontributeListView()
end

function GuildDadianScene:reloadCrontributeListView()
	if self._conListTable ~= nil then
		self._conListTable:removeSelf()
		self._conListTable = nil
	end
	local listViewSize = self._rootnode.contribute_listView:getContentSize()
	local function createFunc(index)
		local item = require("game.guild.guildDadian.GuildDadianContributeItem").new()
		return item:create({
		hasContribute = self._hasContribute,
		itemData = data_union_juanxian_union_juanxian[index + 1],
		viewSize = listViewSize,
		contributeFunc = function(cell)
			local bCan = true
			local contInfo = data_union_juanxian_union_juanxian[cell:getIdx() + 1]
			if game.player:getVip() < contInfo.nedvip then
				bCan = false
				show_tip_label(common:getLanguageString("@GuildVIPRequire") .. tostring(contInfo.nedvip) .. common:getLanguageString("@GuildVIPRequireLV"))
			elseif self._curContributedNum >= self._roleMaxNum then
				bCan = false
				show_tip_label(data_error_error[2900081].prompt)
			elseif contInfo.type == 1 and game.player:getSilver() < contInfo.number then
				bCan = false
				show_tip_label(data_error_error[2900022].prompt)
			elseif contInfo.type == 2 and game.player:getGold() < contInfo.number then
				bCan = false
				show_tip_label(data_error_error[2900023].prompt)
			end
			if bCan == true then
				cell:setBtnEnabled(false)
				self:reqContribute(cell)
			else
				cell:setBtnEnabled(true)
			end
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(data_union_juanxian_union_juanxian[index + 1])
	end
	local cellContentSize = require("game.guild.guildDadian.GuildDadianContributeItem").new():getContentSize()
	self._conListTable = require("utility.TableViewExt").new({
	size = listViewSize,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #data_union_juanxian_union_juanxian,
	cellSize = cellContentSize
	})
	self._rootnode.contribute_listView:addChild(self._conListTable)
end

function GuildDadianScene:reloadDynamicListView(listData)
	if self._dynamicListTable ~= nil then
		self._dynamicListTable:removeSelf()
		self._dynamicListTable = nil
	end
	local listViewSize = self._rootnode.dynamic_listView:getContentSize()
	local function createFunc(index)
		local item = require("game.guild.guildDadian.GuildDadianDynamicItem").new()
		return item:create({
		itemData = listData[index + 1],
		viewSize = listViewSize
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(listData[index + 1])
	end
	local cellContentSize = require("game.guild.guildDadian.GuildDadianDynamicItem").new():getContentSize()
	self._dynamicListTable = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #listData,
	cellSize = cellContentSize
	})
	self._rootnode.dynamic_listView:addChild(self._dynamicListTable)
end

function GuildDadianScene:onEnter()
	GuildDadianScene.super.onEnter(self)
	game.runningScene = self
end

function GuildDadianScene:onExit()
	GuildDadianScene.super.onExit(self)
end

return GuildDadianScene