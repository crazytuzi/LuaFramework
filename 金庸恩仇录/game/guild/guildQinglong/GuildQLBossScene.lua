--ÐÞ¸ÄÍê³É
local data_bossguwu_bossguwu = require("data.data_bossguwu_bossguwu")
local data_atk_number_time_time = require("data.data_atk_number_time_time")
local data_card_card = require("data.data_card_card")
local data_huodong_huodong = require("data.data_huodong_huodong")
local data_boss_qinglong_boss_qinglong = require("data.data_boss_qinglong_boss_qinglong")
require("data.data_error_error")

local REFRESH_TIME = 5
local MAX_ZORDER = 1111
local MOVE_TIME = 0.7
local MOVE_DISY = 10
local DELAY_TIME = 0.2
local PayType = {
guwu_silver = 1,
guwu_gold = 2,
relive_gold = 3
}

local WorldBossHurtNode = class("WorldBossHurtNode", function(param)
	local data = param.data
	local isSelf = param.isSelf
	local rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/worldBoss_hurt_node.ccbi", proxy, rootnode)
	rootnode.name_lbl:setString(data.name)
	rootnode.hurt_lbl:setString("-" .. tostring(data.hurt))
	if isSelf then
		rootnode.name_lbl:setColor(cc.c3b(6, 129, 18))
	end
	return node
end)

local BaseScene = require("game.BaseScene")
local GuildQLBossScene = class("GuildQLBossScene", BaseScene)

function GuildQLBossScene:payUse(payType)
	RequestHelper.Guild.bossPay({
	unionId = game.player:getGuildInfo().m_id,
	use = payType,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		else
			local rtnObj = data.rtnObj
			game.player:updateMainMenu({
			gold = rtnObj.goldNum,
			silver = rtnObj.silverNum
			})
			PostNotice(NoticeKey.CommonUpdate_Label_Gold)
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			local isFinish = rtnObj.isFinish
			self:setIsEnd(isFinish)
			if self._bEnd then
				self:getResultData()
			else
				local isSuccess = rtnObj.isSuccess
				if payType == PayType.relive_gold then
					if isSuccess == 1 then
						show_tip_label(data_error_error[1405].prompt)
					end
				elseif isSuccess == 1 then
					show_tip_label(data_error_error[1402].prompt)
				else
					show_tip_label(data_error_error[1401].prompt)
				end
				self:refreshSelfState(rtnObj.selfStat)
			end
		end
	end
	})
end

function GuildQLBossScene:refreshBossStateData()
	GameRequest.Guild.bossState({
	unionId = game.player:getGuildInfo().m_id,
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		else
			local rtnObj = data.rtnObj
			local stateObj = rtnObj.stateObj
			if stateObj.endTime <= 0 then
				dump("=========refreshBossStateData===========")
				self:getResultData()
			else
				self:refreshBattleState(data)
				self._refreshTime = REFRESH_TIME
			end
		end
	end
	})
end

function GuildQLBossScene:getPlayerBattleData()
	RequestHelper.Guild.bossPve({
	unionId = game.player:getGuildInfo().m_id,
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			dump(data["0"])
		else
			local isFinish = data["6"]
			self:setIsEnd(isFinish)
			if self._bEnd then
				self:getResultData()
			else
				local attackWaitTime = data["5"]
				if attackWaitTime > 0 then
					self:updateAttackCDTime(attackWaitTime)
				else
					local selfStat = data["4"]
					self:refreshSelfState(selfStat)
					if self._isAutoBattle then
						self:refreshOtherPlayerState(0, {
						hurt = selfStat.curHurt or 0,
						name = game.player:getPlayerName()
						}, true)
					else
						self._bChallenge = true
						push_scene(require("game.Worldboss.WorldBossBattleScene").new({
						fubenType = GUILD_QLBOSS_FUBEN,
						data = data,
						resultFunc = function()
							game.runningScene:addChild(require("game.Worldboss.WorldBossBattleResultLayer").new({
							data = data,
							confirmFunc = function()
								pop_scene()
							end
							}), MAX_ZORDER)
						end
						}))
					end
				end
			end
		end
	end
	})
end

function GuildQLBossScene:setIsEnd(isFinish)
	if isFinish == nil then
		CCMessageBox(common:getLanguageString("@ServerSendValueConfirmIsNil"))
	end
	if isFinish == 1 then
		self._bEnd = false
	elseif isFinish == 2 then
		GameAudio.playMainmenuMusic(true)
		self._bEnd = true
		self._bossSprite:stopAllActions()
	else
		CCMessageBox(common:getLanguageString("@ServerSendValueConfirm") .. isFinish)
	end
end

function GuildQLBossScene:playBatMusic()
	local musiceName = data_huodong_huodong[5].bgm
	local bgmPath = "sound/" .. musiceName .. ".mp3"
	GameAudio.playMusic(bgmPath, true)
end

function GuildQLBossScene:getResultData()
	if self._bReqEndResult == false then
		self._bReqEndResult = true
		self._endTime = -1
		GameRequest.Guild.bossResult({
		unionId = game.player:getGuildInfo().m_id,
		callback = function(data)
			dump(data)
			if data.err ~= "" then
				dump(data.err)
				self._bReqEndResult = false
			else
				local rtnObj = data.rtnObj
				self._endTime = rtnObj.res.endTime or 0
				if self._endTime > 0 then
					self._rootnode.end_time_lbl:setString(tostring(format_time(self._endTime)))
				end
				self:setBoold(rtnObj.res.bossLife, rtnObj.res.lifeTotal)
				local finish = rtnObj.isFinish
				self:setIsEnd(finish)
				if self._bEnd then
					self:addChild(require("game.guild.guildQinglong.GuildQLBossEndResultLayer").new({
					data = data,
					confirmFunc = function()
						GameStateManager:ChangeState(GAME_STATE.STATE_GUILD, GUILD_BUILD_TYPE.qinglong)
					end
					}), MAX_ZORDER)
				else
					self._bReqEndResult = false
				end
			end
		end
		})
	end
end

function GuildQLBossScene:exitScene()
	if self._isFromGuildMainScene == true then
		GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
	elseif self._isFromGuildMainScene == false then
		GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
	end
end

function GuildQLBossScene:ctor(param)
	GuildQLBossScene.super.ctor(self, {
	contentFile = "guild/guild_worldBoss_layer.ccbi",
	bgImage = "bg/weijiao_yishou_bg.jpg",
	isHideBottom = true
	})
	
	
	
	
	self:playBatMusic()
	ResMgr.removeBefLayer()
	local guildMgr = game.player:getGuildMgr()
	self._isFromGuildMainScene = param.isFromGuildMainScene
	local data = param.data
	self._bReqEndResult = false
	self._bEnd = false
	self._bChallenge = false
	self._endTime = -1
	self._attackTime = -1
	self._refreshTime = -1
	self._silverTime = -1
	self._totalHurtAdd = 0
	self._isAutoBattle = false
	self._bossLife = 10
	self._liveGoldNum = 10
	self._addHurt = data_bossguwu_bossguwu[1].add
	self._guwuLimit = data_bossguwu_bossguwu[1].limit
	self._bossSprite = display.newSprite()
	self._bossSprite:setDisplayFrame(ResMgr.getHeroFrame(4902, 0))
	local bossIconNode = self._rootnode.boss_icon_node
	self._bossSprite:setScale(0.9)
	self._bossSprite:setPosition(bossIconNode:getContentSize().width / 2, 0)
	bossIconNode:addChild(self._bossSprite)
	self._bossSprite:runAction(CCRepeatForever:create(transition.sequence({
	CCMoveBy:create(MOVE_TIME, cc.p(0, MOVE_DISY)),
	CCDelayTime:create(DELAY_TIME),
	CCMoveBy:create(MOVE_TIME, cc.p(0, -MOVE_DISY)),
	CCDelayTime:create(DELAY_TIME)
	})))
	self._guwuGoldNum = data_bossguwu_bossguwu[1].coin
	self._rootnode.guwu_gold_num:setString(tostring(self._guwuGoldNum))
	self._guwuSilverNum = data_bossguwu_bossguwu[1].silver
	self._rootnode.guwu_silver_num:setString(tostring(self._guwuSilverNum))
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self._isAutoBattle then
			local lblTTF = ResMgr.createShadowMsgTTF({
			text = common:getLanguageString("@QuitConfirm"),
			size = 24,
			dimensions = cc.size(400, 0),
			color = cc.c3b(119, 62, 5),
			shadowColor = FONT_COLOR.BLACK,
			})
			local rowOneTable = {lblTTF}
			local rowAll = {rowOneTable}
			local layer = require("utility.MsgBoxEx").new({
			resTable = rowAll,
			confirmFunc = function(node)
				node:removeSelf()
				self:exitScene()
			end,
			closeFunc = function(node)
				node:removeSelf()
			end
			})
			self:addChild(layer, MAX_ZORDER)
		else
			self:exitScene()
		end
	end,
	CCControlEventTouchUpInside)
	
	local buzhenBtn = self._rootnode.buzhenBtn
	buzhenBtn:addHandleOfControlEvent(function(sender, eventName)
		buzhenBtn:setEnabled(false)
		local formCtrl = require("game.form.FormCtrl")
		formCtrl.createFormSettingLayer({
		parentNode = game.runningScene,
		touchEnabled = true,
		closeListener = function()
			buzhenBtn:setEnabled(true)
		end
		})
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	local shuchuBtn = self._rootnode.shuchuBtn
	shuchuBtn:addHandleOfControlEvent(function(sender, eventName)
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
		}), MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
	self._silverTimeLbl = ui.newTTFLabelWithOutline({
	text = tostring(format_time(0)),
	size = 25,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = FONT_COLOR.WHITE,
	outlineColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLableEx(self._silverTimeLbl, self._rootnode, "silver_time", 0, 0)
	self._silverTimeLbl:align(display.CENTER_BOTTOM)
	silver_time = self._silverTimeLbl
	
	
	self._silverTimeLbl:setVisible(false)
	self._rootnode.attackBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._attackTime > 0 then
			show_tip_label(data_error_error[1400].prompt)
		elseif 0 < self._bossLife then
			self:getPlayerBattleData()
		end
	end,
	CCControlEventTouchUpInside)
	
	local autoBtn = self._rootnode.autoBtn
	autoBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._isAutoBattle then
			self._isAutoBattle = false
			autoBtn:setTitleForState(common:getLanguageString("@AutoAttack"), CCControlStateNormal)
		else
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.WorldBoss_AutoBattle, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self._isAutoBattle = true
				autoBtn:setTitleForState(common:getLanguageString("@AutoAttackCancel"), CCControlStateNormal)
				if self._attackTime <= 0 and 0 < self._bossLife then
					self:getPlayerBattleData()
				end
			end
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.fuhuoBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._attackTime <= 0 then
			show_tip_label(data_error_error[1405].prompt)
		elseif game.player:getGold() < self._liveGoldNum then
			show_tip_label(data_error_error[100004].prompt)
		else
			self:payUse(PayType.relive_gold)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.silverBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._silverTime > 0 then
			show_tip_label(data_error_error[1404].prompt)
		elseif self._totalHurtAdd >= self._guwuLimit then
			show_tip_label(data_error_error[1403].prompt)
		elseif game.player:getSilver() < self._guwuSilverNum then
			show_tip_label(data_error_error[1407].prompt)
		else
			self:payUse(PayType.guwu_silver)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.goldBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._totalHurtAdd >= self._guwuLimit then
			show_tip_label(data_error_error[1403].prompt)
		elseif game.player:getGold() < self._guwuGoldNum then
			show_tip_label(data_error_error[100004].prompt)
		else
			self:payUse(PayType.guwu_gold)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:initData(data)
	self._refreshTime = REFRESH_TIME
	alignNodesOneByAllCenterX(self._rootnode.relive_gold:getParent(), {
	self._rootnode.relive_title,
	self._rootnode.relive_sign,
	self._rootnode.relive_gold
	}, 2)
end

function GuildQLBossScene:initData(data)
	local rtnObj = data.rtnObj
	local stateObj = rtnObj.stateObj
	local selfStat = rtnObj.selfStat
	local playerStat = rtnObj.playerStat
	self._endTime = stateObj.endTime
	self._rootnode.end_time_lbl:setString(tostring(format_time(self._endTime)))
	self._rootnode.name_lbl:setString(tostring(stateObj.name))
	self._bossLevel = stateObj.level
	self._rootnode.level_lbl:setString("LV." .. tostring(self._bossLevel))
	alignNodesOneByOne(self._rootnode.name_lbl, self._rootnode.level_lbl, 3)
	self:setBoold(stateObj.life, stateObj.lifeTotal)
	self:refreshSelfState(selfStat)
	if not self._bChallenge then
		for i, v in ipairs(playerStat) do
			self:refreshOtherPlayerState(i, v, false)
		end
	end
	dump(self._bossLife)
	if self._bossLife <= 0 then
		self:getResultData()
	end
end
function GuildQLBossScene:setBoold(curHp, totalHp)
	self._bossLife = curHp
	self._rootnode.blood_lbl:setString(tostring(self._bossLife) .. "/" .. tostring(totalHp))
	local percent = self._bossLife / totalHp
	local normalBar = self._rootnode.normalBar
	local bar = self._rootnode.addBar
	local rotated = false
	if bar:isTextureRectRotated() == true then
		rotated = true
	end
	bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, normalBar:getContentSize().width * percent, bar:getTextureRect().height), rotated, cc.size(normalBar:getContentSize().width * percent, normalBar:getContentSize().height * percent))
end

function GuildQLBossScene:refreshBattleState(data)
	self:initData(data)
end

function GuildQLBossScene:refreshOtherPlayerState(index, data, isSelf)
	local centerNode = self._rootnode.center_node
	local cntSize = centerNode:getContentSize()
	local posX = math.random(0, cntSize.width)
	local posY = math.random(0, cntSize.height)
	local NUM_SCALE = data_atk_number_time_time[1].num_scale / 10 or 1
	if 0 < data.hurt then
		local hurtNode = WorldBossHurtNode.new({data = data, isSelf = isSelf})
		hurtNode:setPosition(posX, posY)
		centerNode:addChild(hurtNode)
		hurtNode:setVisible(false)
		hurtNode:runAction(transition.sequence({
		CCDelayTime:create(index * 1),
		CCShow:create(),
		CCScaleTo:create(0.1, 1.2 * NUM_SCALE),
		CCScaleTo:create(0.1, NUM_SCALE),
		CCDelayTime:create(1),
		CCScaleTo:create(0.1, 0.8, 0.2),
		CCRemoveSelf:create(true)
		}))
	end
end
function GuildQLBossScene:refreshSelfState(selfStat)
	self._liveGoldNum = selfStat.nxtLiveGold
	self._totalHurtAdd = selfStat.hurtAdd
	local hang_1_Node = self._rootnode.hang_1
	hang_1_Node:removeAllChildren()
	local contentLabel = getRichText(common:getLanguageString("@WordBossHurt1", tostring(selfStat.num), tostring(selfStat.hurt), tostring(selfStat.hurtR)), hang_1_Node:getContentSize().width, nil, 0)
	local width = hang_1_Node:getContentSize().width
	local posX = width - contentLabel:getContentSize().width
	contentLabel:setPosition(posX / 2, contentLabel:getContentSize().height - contentLabel.offset)
	hang_1_Node:removeAllChildren()
	hang_1_Node:addChild(contentLabel)
	self._rootnode.hurtAdd_num:setString(tostring(self._totalHurtAdd) .. "%")
	local curRank
	if selfStat.rank == nil or 0 >= selfStat.rank then
		curRank = common:getLanguageString("@NotHave")
	else
		curRank = tostring(selfStat.rank)
	end
	self._rootnode.rank_lbl:setString(curRank)
	self._rootnode.relive_gold:setString(tostring(self._liveGoldNum))
	self:updateGuwuCDTime(selfStat.silverWait)
	self:updateAttackCDTime(selfStat.battleWait)
	alignNodesOneByAllCenterX(self._rootnode.hang_2, {
	self._rootnode.msg_2,
	self._rootnode.hurtAdd_num,
	self._rootnode.msg_3,
	self._rootnode.rank_lbl
	}, 5)
end

function GuildQLBossScene:updateGuwuCDTime(silverWait)
	self._silverTime = silverWait
	if self._silverTime > 0 then
		self._silverTimeLbl:setString(tostring(format_time(self._silverTime)))
		self._silverTimeLbl:setVisible(true)
	else
		self._silverTimeLbl:setVisible(false)
	end
end

function GuildQLBossScene:updateAttackCDTime(battleWait)
	self._attackTime = battleWait
	local attackBtn = self._rootnode.attackBtn
	if self._attackTime > 0 then
		attackBtn:setTitleForState(tostring(format_time(self._attackTime)), CCControlStateNormal)
		self._rootnode.fuhuo_texiao:setVisible(true)
	else
		self._attackTime = -1
		attackBtn:setTitleForState(common:getLanguageString("@Attack5"), CCControlStateNormal)
		self._rootnode.fuhuo_texiao:setVisible(false)
		if self._isAutoBattle then
			self:getPlayerBattleData()
		end
	end
end

function GuildQLBossScene:onEnter()
	game.runningScene = self
	--self:regNotice()
	GuildQLBossScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	local function updateTime()
		if self._endTime > 0 then
			self._endTime = self._endTime - 1
			self._rootnode.end_time_lbl:setString(tostring(format_time(self._endTime)))
			if self._endTime <= 0 then
				dump("======updateTime=======")
				self:getResultData()
			end
		end
		if 0 < self._refreshTime then
			self._refreshTime = self._refreshTime - 1
			if 0 >= self._refreshTime then
				self._refreshTime = -1
				if not self._bEnd then
					self:refreshBossStateData()
				end
			end
		end
		if 0 < self._silverTime then
			self._silverTime = self._silverTime - 1
			self:updateGuwuCDTime(self._silverTime)
		end
		if 0 < self._attackTime then
			self._attackTime = self._attackTime - 1
			self:updateAttackCDTime(self._attackTime)
		end
	end
	self.scheduler = require("framework.scheduler")
	if not self._bChallenge then
		self._schedule = self.scheduler.scheduleGlobal(updateTime, 1, false)
	end
	self._bChallenge = false
end

function GuildQLBossScene:onExit()
	--self:unregNotice()
	GuildQLBossScene.super.onExit(self)
	if not self._bChallenge and self._schedule ~= nil then
		self.scheduler.unscheduleGlobal(self._schedule)
	end
end

return GuildQLBossScene