--修改完成
require("data.data_error_error")
local data_ui_ui = require("data.data_ui_ui")
local data_boss_qinglong_boss_qinglong = require("data.data_boss_qinglong_boss_qinglong")
local MAX_ZORDER = 110

local GuildQinglongLayer = class("GuildQinglongLayer", function()
	return require("utility.ShadeLayer").new()
end)

local format_time = function(time)
	local hour = math.floor(time / 60)
	if hour < 10 then
		hour = "0" .. hour or hour
	end
	local min = time % 60
	if min < 10 then
		min = "0" .. min or min
	end
	local str = hour .. ":" .. min
	return str
end

function GuildQinglongLayer:reqLevelup(msgBox)
	levelupBtn = self._rootnode.levelup_btn
	RequestHelper.Guild.unionLevelUp({
	unionid = game.player:getGuildMgr():getGuildInfo().m_id,
	buildtype = self._buildType,
	errback = function(data)
		levelupBtn:setEnabled(true)
		msgBox:setBtnEnabled(true)
	end,
	callback = function(data)
		dump(data, "建筑升级", 8)
		ResMgr.showErr(2900083)
		msgBox:removeFromParentAndCleanup(true)
		self:updateLevel(data.buildLevel, data.currentUnionMoney)
		self:checkBtnState(self._level, self._curState)
		game.player:getGuildInfo():updateData({
		qinglongLevel = data.buildLevel,
		currentUnionMoney = data.currentUnionMoney
		})
		PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
		PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL)
		levelupBtn:setEnabled(true)
	end
	})
end

function GuildQinglongLayer:reqOpen()
	local openBtn = self._rootnode.open_btn
	RequestHelper.Guild.bossCreate({
	unionId = game.player:getGuildMgr():getGuildInfo().m_id,
	errback = function(data)
		openBtn:setEnabled(true)
	end,
	callback = function(data)
		dump(data, "开启", 8)
		if data.err ~= "" then
			dump(data.err)
			openBtn:setEnabled(true)
		else
			local rtnObj = data.rtnObj
			self:updateLevel(self._level, rtnObj.curUnionMoney)
			game.player:getGuildInfo():updateData({
			currentUnionMoney = rtnObj.curUnionMoney
			})
			PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
			if rtnObj.result == 1 or rtnObj.result == 2 then
				GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, true)
			else
				openBtn:setEnabled(true)
				show_tip_label(common:getLanguageString("@ServerSendResultError") .. rtnObj.result)
			end
		end
	end
	})
end

function GuildQinglongLayer:ctor(data)
	dump(data, "青龙", 6)
	local rtnObj = data.rtnObj
	self._curState = rtnObj.state
	self._openCostCoin = rtnObj.createBossCost
	self._bossLevel = rtnObj.dragonLevel
	self._buildType = GUILD_BUILD_TYPE.qinglong
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("guild/guild_qinglong_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@QingLongHall"))
	local scrollview = self._rootnode.scrollview
	local size = scrollview:getContentSize()
	local viewsize = scrollview:getViewSize()
	local des_label = ui.newTTFLabel({
	text = data_ui_ui[13].content,
	color = cc.c3b(153, 102, 51),
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	dimensions = cc.size(viewsize.width, 0)
	})
	local contentViewSize = des_label:getContentSize()
	des_label:align(display.LEFT_BOTTOM)
	scrollview:addChild(des_label)
	scrollview:setContentSize(contentViewSize)
	scrollview:updateInset()
	scrollview:setContentOffset(cc.p(0, -contentViewSize.height + viewsize.height - 10), false)
	scrollview:setDirection(kCCScrollViewDirectionVertical)
	if rtnObj.bossAutoTime == -1 then
		self._rootnode.autotimelabel:setString(common:getLanguageString("@contentcancelAuto"))
	else
		self._rootnode.autotimelabel:setString(format_time(rtnObj.bossAutoTime))
	end
	alignNodesOneByOne(self._rootnode.contentbbqtime, self._rootnode.autotimelabel, -25)
	self:createShadowLbl(tostring(self._bossLevel), cc.c3b(0, 219, 52), self._rootnode, "boss_level_lbl", 20)
	
	--关闭界面
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	local guildMgr = game.player:getGuildMgr()
	local guildInfo = guildMgr:getGuildInfo()
	self:updateLevel(rtnObj.templeLevel, rtnObj.curUnionMoney)
	self:createAllLbl()
	self:checkBtnState(self._level, self._curState)
	local jopType = guildInfo.m_jopType
	local levelupBtn = self._rootnode.levelup_btn
	local openBtn = self._rootnode.open_btn
	if jopType == GUILD_JOB_TYPE.leader or jopType == GUILD_JOB_TYPE.assistant then
		--升级
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
		
		--开启
		
		
		openBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if self._currentUnionMoney < self._openCostCoin then
				show_tip_label(data_error_error[2900035].prompt)
			else
				openBtn:setEnabled(false)
				self:reqOpen()
			end
		end,
		CCControlEventTouchUpInside)
	end
	
	--输出排行榜
	
	
	local shuchuBtn = self._rootnode.shuchuBtn
	shuchuBtn:addHandleOfControlEvent(function(sender, eventName)
		shuchuBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local function toLayer(data)
			local layer = require("game.guild.guildQinglong.GuildQLBossRankLayer").new({
			topPlayers = data.rtnObj.topPlayers,
			confirmFunc = function()
				shuchuBtn:setEnabled(true)
			end
			})
			game.runningScene:addChild(layer, MAX_ZORDER)
		end
		guildMgr:RequestBossRank(toLayer, function()
			shuchuBtn:setEnabled(true)
		end)
	end,
	CCControlEventTouchUpInside)
	
	--奖励
	local extraRewardBtn = self._rootnode.extraRewardBtn
	extraRewardBtn:addHandleOfControlEvent(function(sender, eventName)
		extraRewardBtn:setEnabled(false)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local function confirmFunc()
			extraRewardBtn:setEnabled(true)
		end
		self:addChild(require("game.Worldboss.WorldBossExtraRewardLayer").new({
		rewardListData = data_boss_qinglong_boss_qinglong,
		confirmFunc = confirmFunc,
		level = self._bossLevel,
		isGuildBoss = true
		}),
		MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
end

function GuildQinglongLayer:checkBtnState(level, state)
	local guildMgr = game.player:getGuildMgr()
	local guildInfo = guildMgr:getGuildInfo()
	local jopType = guildInfo.m_jopType
	local levelupBtn = self._rootnode.levelup_btn
	local openBtn = self._rootnode.open_btn
	local openNode = self._rootnode.open_node
	local notOpenNode = self._rootnode.open_need_node
	if jopType ~= GUILD_JOB_TYPE.leader and jopType ~= GUILD_JOB_TYPE.assistant then
		levelupBtn:setVisible(false)
		openBtn:setVisible(false)
		if level <= 0 then
			openNode:setVisible(false)
			notOpenNode:setVisible(true)
		else
			openNode:setVisible(true)
			notOpenNode:setVisible(false)
		end
	else
		levelupBtn:setVisible(true)
		openNode:setVisible(false)
		if level <= 0 then
			notOpenNode:setVisible(true)
			openBtn:setVisible(false)
		else
			notOpenNode:setVisible(false)
			openBtn:setVisible(true)
			if state == GUILD_QL_CHALLENGE_STATE.hasEnd then
				openBtn:setEnabled(false)
			elseif state == GUILD_QL_CHALLENGE_STATE.notOpen then
				openBtn:setEnabled(true)
			end
		end
	end
end
function GuildQinglongLayer:updateLevel(level, currentUnionMoney)
	local guildMgr = game.player:getGuildMgr()
	self._level = level
	guildMgr:getGuildInfo().m_greenDragonTempleLevel = self._level
	self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level)
	self._currentUnionMoney = currentUnionMoney
	self:createShadowLbl("LV." .. tostring(self._level), cc.c3b(255, 222, 0), self._rootnode, "cur_level_lbl")
	self:createShadowLbl(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode, "cur_coin_lbl")
	self:updateNeedCoinLbl(self._needCoin)
end

function GuildQinglongLayer:updateNeedCoinLbl(needCoin)
	local str
	if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then
		str = common:getLanguageString("@GuildUpgradeMax")
	else
		str = tostring(needCoin)
	end
	self:createShadowLbl(str, FONT_COLOR.WHITE, self._rootnode, "cost_coin_lbl")
end

function GuildQinglongLayer:createShadowLbl(text, color, nodes, name, size)
	local lbl = ui.newTTFLabelWithShadow({
	text = text,
	size = size or 20,
	color = color,
	shadowColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	})
	ResMgr.replaceKeyLableEx(lbl, nodes, name, 0, 0)
	lbl:align(display.LEFT_CENTER)
	return lbl
end

function GuildQinglongLayer:getShadowLblWidth(node)
	return node:getContentSize().width
end

function GuildQinglongLayer:createAllLbl()
	local guildMgr = game.player:getGuildMgr()
	local jopType = guildMgr:getGuildInfo().m_jopType
	local yColor = cc.c3b(255, 222, 0)
	
	self:createShadowLbl(common:getLanguageString("@GuildGoldForUpgrade"), yColor, self._rootnode, "cost_coin_msg_lbl")
	self._rootnode.cost_coin_lbl:setPositionX(self:getShadowLblWidth(self._rootnode.cost_coin_msg_lbl))
	
	self:createShadowLbl(common:getLanguageString("@GuildGold"), yColor, self._rootnode, "cur_coin_msg_lbl")
	self._rootnode.cur_coin_lbl:setPositionX(self:getShadowLblWidth(self._rootnode.cur_coin_msg_lbl))
	
	self:createShadowLbl(common:getLanguageString("@GuildTodayChaStatus"), FONT_COLOR.WHITE, self._rootnode, "state_msg_lbl")
	self._rootnode.state_msg_lbl:align(display.CENTER)
	local stateStr, stateColor
	if self._curState == GUILD_QL_CHALLENGE_STATE.notOpen then
		stateStr = common:getLanguageString("@ChaNotBegin")
		stateColor = cc.c3b(0, 219, 52)
	elseif self._curState == GUILD_QL_CHALLENGE_STATE.hasEnd then
		stateStr = common:getLanguageString("@ChaIsOver")
		stateColor = cc.c3b(240, 5, 5)
	end
	
	self:createShadowLbl(stateStr, stateColor, self._rootnode, "state_lbl")
	self._rootnode.state_lbl:align(display.CENTER)
	
	self:createShadowLbl(common:getLanguageString("@GuildLead"), yColor, self._rootnode, "leader_msg_lbl", 30)
	self:createShadowLbl(common:getLanguageString("@ChaToBeUnlock"), cc.c3b(22, 255, 255), self._rootnode, "open_msg_lbl", 24)
	local lbl = self:createShadowLbl(common:getLanguageString("@ConstructionUnlock"), cc.c3b(22, 255, 255), self._rootnode, "open_need_msg_lbl", 28)
	lbl:align(display.CENTER)
end

return GuildQinglongLayer