local data_bossguwu_bossguwu = require("data.data_bossguwu_bossguwu")
local data_atk_number_time_time = require("data.data_atk_number_time_time")
require("data.data_error_error")
require("utility.richtext.richText")
local data_card_card = require("data.data_card_card")
local data_huodong_huodong = require("data.data_huodong_huodong")
local data_boss_boss = require("data.data_boss_boss")
local data_item_item = require("data.data_item_item")


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
local worldBossDoubleTimes = 30

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
local WorldBossScene = class("WorldBossScene", BaseScene)

--[[
local WorldBossScene = class("WorldBossScene", function()
	return require("game.BaseScene").new({
	contentFile = "huodong/worldBoss_layer.ccbi",
	bgImage = "bg/weijiao_yishou_bg.jpg",
	isHideBottom = true
	})
end)
]]

function WorldBossScene:payUse(payType)
	RequestHelper.worldBoss.pay({
	use = payType,
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			show_tip_label(data_error_error[data.errCode].prompt)
		else
			game.player:updateMainMenu({
			gold = data["3"],
			silver = data["4"]
			})
			PostNotice(NoticeKey.CommonUpdate_Label_Gold)
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			local isFinish = data["2"]
			self:setIsEnd(isFinish)
			if self._bEnd then
				self:getResultData()
			else
				local isSuccess = data["5"]
				if payType == PayType.relive_gold then
					if isSuccess == 1 then
						show_tip_label(data_error_error[1405].prompt)
					end
				elseif isSuccess == 1 then
					show_tip_label(data_error_error[1402].prompt)
				else
					show_tip_label(data_error_error[1401].prompt)
				end
				self:refreshSelfState(data["1"])
			end
		end
	end
	})
end

function WorldBossScene:getBossStateData()
	RequestHelper.worldBoss.state({
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			show_tip_label(data["0"])
		else
			self:initData(data)
			self._refreshTime = REFRESH_TIME
		end
	end
	})
end

function WorldBossScene:refreshBossStateData()
	GameRequest.worldBoss.state({
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
		else
			local stateObj = data["1"]
			if stateObj.endTime <= 0 then
				self:getResultData()
			else
				self:refreshBattleState(data)
				self._refreshTime = REFRESH_TIME
			end
		end
	end
	})
end

function WorldBossScene:getPlayerBattleData()
	RequestHelper.worldBoss.battle({
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			show_tip_label(data["0"])
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
						self:showAutoBattleInfo(data)
						self:refreshOtherPlayerState(0, {
						hurt = selfStat.curHurt or 0,
						name = game.player:getPlayerName()
						}, true)
					else
						self._bChallenge = true
						push_scene(require("game.Worldboss.WorldBossBattleScene").new({
						fubenType = WORLDBOSS_FUBEN,
						data = data,
						resultFunc = function()
							if data["8"] ~= nil then
								game.runningScene:addChild(require("game.Worldboss.WorldBossBattleResultLayer2").new({
								data = data,
								count = worldBossDoubleTimes - self.changeTimes - 1,
								confirmFunc = function()
									pop_scene()
								end
								}), MAX_ZORDER)
							else
								game.runningScene:addChild(require("game.Worldboss.WorldBossBattleResultLayer").new({
								data = data,
								confirmFunc = function()
									pop_scene()
								end
								}), MAX_ZORDER)
							end
						end
						}))
					end
				end
			end
		end
	end
	})
end

function WorldBossScene:showAutoBattleInfo(data)
	local itemInfo = ""
	for i, v in ipairs(data["3"]) do
		local item = data_item_item[v.id]
		if item then
			itemInfo = itemInfo .. item.name .. "*" .. v.n
			if i < #data["3"] then
				itemInfo = itemInfo .. ","
			end
		end
		if v.t == 7 and v.id == 2 then
			local money = game.player:getSilver() + v.n
			game.player:setSilver(money)
		end
	end
	if data["7"] ~= nil then
		game.player:setGold(data["7"])
	end
	PostNotice(NoticeKey.CommonUpdate_Label_Silver)
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	show_tip_label(common:getLanguageString("@zhulongjiangli", itemInfo))
end

function WorldBossScene:setIsEnd(isFinish)
	if isFinish == nil then
		CCMessageBox(common:getLanguageString("@fuwuqifgl"))
	end
	if isFinish == 1 then
		self._bEnd = false
	elseif isFinish == 2 then
		GameAudio.playMainmenuMusic(true)
		self._bEnd = true
		self._bossSprite:stopAllActions()
	else
		CCMessageBox(common:getLanguageString("@fuwuqifgl1") .. isFinish)
	end
end

function WorldBossScene:playBatMusic()
	local musiceName = data_huodong_huodong[5].bgm
	local bgmPath = "sound/" .. musiceName .. ".mp3"
	GameAudio.playMusic(bgmPath, true)
end

function WorldBossScene:getResultData()
	if self._bReqEndResult == false then
		self._bReqEndResult = true
		self._endTime = -1
		GameRequest.worldBoss.result({
		callback = function(data)
			dump(data)
			if data["0"] ~= "" then
				self._bReqEndResult = false
			else
				local rstObj = data["1"]
				self._endTime = rstObj.endTime or 0
				if self._endTime > 0 then
					self._rootnode.end_time_lbl:setString(tostring(format_time(self._endTime)))
				end
				self:setBoold(rstObj.bossLife, rstObj.lifeTotal)
				local finish = data["3"]
				self:setIsEnd(finish)
				if self._bEnd then
					self:addChild(require("game.Worldboss.WorldBossEndResultLayer").new({
					data = data,
					confirmFunc = function()
						GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
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

function WorldBossScene:ctor()
	WorldBossScene.super.ctor(self, {
	contentFile = "huodong/worldBoss_layer.ccbi",
	bgImage = "bg/weijiao_yishou_bg.jpg",
	isHideBottom = true
	})
	
	
	
	self:playBatMusic()
	ResMgr.removeBefLayer()
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
	self._bossSprite:setDisplayFrame(ResMgr.getHeroFrame(4901, 0))
	self._bossSprite:setScale(1.2)
	local bossIconNode = self._rootnode.boss_icon_node
	self._bossSprite:setPosition(bossIconNode:getContentSize().width / 2, self._bossSprite:getContentSize().height / 2)
	bossIconNode:addChild(self._bossSprite)
	self._bossSprite:runAction(CCRepeatForever:create(transition.sequence({
	CCMoveBy:create(MOVE_TIME, CCPoint(0, MOVE_DISY)),
	CCDelayTime:create(DELAY_TIME),
	CCMoveBy:create(MOVE_TIME, CCPoint(0, -MOVE_DISY)),
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
			text = common:getLanguageString("@tuichuqr"),
			color = cc.c3b(119, 62, 5),
			shadowColor = cc.c3b(0, 0, 0),
			size = 24
			})
			local rowOneTable = {lblTTF}
			local rowAll = {rowOneTable}
			local layer = require("utility.MsgBoxEx").new({
			resTable = rowAll,
			confirmFunc = function(node)
				GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
				node:removeSelf()
			end,
			closeFunc = function(node)
				node:removeSelf()
			end
			})
			self:addChild(layer, MAX_ZORDER)
		else
			GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
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
	
	local silverTime = self._rootnode.silver_time
	self._silverTimeLbl = ui.newTTFLabelWithOutline({
	text = tostring(format_time(0)),
	size = 25,
	color = cc.c3b(255, 255, 255),
	outlineColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	ResMgr.replaceKeyLableEx(self._silverTimeLbl, self._rootnode, "silver_time", 0, self._silverTimeLbl:getContentSize().height / 2)
	self._silverTimeLbl:align(display.CENTER)
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
	autoBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._isAutoBattle then
			self._isAutoBattle = false
			autoBtn:setTitleForState(common:getLanguageString("@zidonggj"), CCControlStateNormal)
		else
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.WorldBoss_AutoBattle, game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
			else
				self._isAutoBattle = true
				autoBtn:setTitleForState(common:getLanguageString("@quxiaozdgj"), CCControlStateNormal)
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
	
	self:getBossStateData()
	alignNodesOneByAllCenterX(self._rootnode.relive_gold:getParent(), {
	self._rootnode.relive_title,
	self._rootnode.relive_sign,
	self._rootnode.relive_gold
	}, 2)
end

function WorldBossScene:initData(data)
	local stateObj = data["1"]
	local selfStat = data["2"]
	local playerStat = data["3"]
	self._endTime = stateObj.endTime
	self._rootnode.end_time_lbl:setString(tostring(format_time(self._endTime)))
	self._rootnode.name_lbl:setString(tostring(stateObj.name))
	self._rootnode.level_lbl:setString("LV." .. tostring(stateObj.level))
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

function WorldBossScene:setBoold(curHp, totalHp)
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

function WorldBossScene:refreshBattleState(data)
	self:initData(data)
end

function WorldBossScene:refreshOtherPlayerState(index, data, isSelf)
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

function WorldBossScene:refreshSelfState(selfStat)
	self.changeTimes = selfStat.num
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
	alignNodesOneByAllCenterX(self._rootnode.msg_2:getParent(), {
	self._rootnode.msg_2,
	self._rootnode.hurtAdd_num,
	self._rootnode.msg_3,
	self._rootnode.rank_lbl
	}, 5)
end

function WorldBossScene:updateGuwuCDTime(silverWait)
	self._silverTime = silverWait
	if self._silverTime > 0 then
		self._silverTimeLbl:setString(tostring(format_time(self._silverTime)))
		self._silverTimeLbl:setVisible(true)
	else
		self._silverTimeLbl:setVisible(false)
	end
end

function WorldBossScene:updateAttackCDTime(battleWait)
	self._attackTime = battleWait
	local attackBtn = self._rootnode.attackBtn
	if self._attackTime > 0 then
		attackBtn:setTitleForState(tostring(format_time(self._attackTime)), CCControlStateNormal)
		self._rootnode.fuhuo_texiao:setVisible(true)
	else
		self._attackTime = -1
		attackBtn:setTitleForState(common:getLanguageString("@Attack2"), CCControlStateNormal)
		self._rootnode.fuhuo_texiao:setVisible(false)
		if self._isAutoBattle then
			self:getPlayerBattleData()
		end
	end
end

function WorldBossScene:onEnter()
	game.runningScene = self
	WorldBossScene.super.onEnter(self)
	--self:regNotice()
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	PostNotice(NoticeKey.CommonUpdate_Label_Silver)
	local function updateTime()
		if self._endTime > 0 then
			self._endTime = self._endTime - 1
			self._rootnode.end_time_lbl:setString(tostring(format_time(self._endTime)))
			if self._endTime <= 0 then
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

function WorldBossScene:onExit()
	--self:unregNotice()
	WorldBossScene.super.onExit(self)
	if not self._bChallenge and self._schedule ~= nil then
		self.scheduler.unscheduleGlobal(self._schedule)
	end
	display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return WorldBossScene