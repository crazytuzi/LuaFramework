local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local MAX_ZORDER = 11113
local RequestInfo = require("network.RequestInfo")

local DuobaoResult = class("DuobaoResult", function(data)
	return require("utility.ShadeLayer").new()
end)

function DuobaoResult:initWinDebris(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("duobao/duobao_win_debris.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = self._debrisName,
	size = 30,
	color = ResMgr.getItemNameColor(self._getItemId),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	
	ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, "debrisNameLbl", 0, 0)
	nameLbl:align(display.LEFT_CENTER)
	
	local effWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli",
	isRetain = true
	})
	effWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effWin)
	local effTextWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli_zi",
	isRetain = true
	})
	effTextWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effTextWin)
	self._rootnode.replayBtn:setEnabled(false)
	self._rootnode.confirmBtn:setEnabled(false)
	alignNodesOneByOne(self._rootnode.SilverCoin, self._rootnode.yinbiLbl)
	alignNodesOneByOne(self._rootnode.EXP, self._rootnode.expLbl)
	alignNodesOneByOne(self._rootnode.Niko, self._rootnode.nailiLbl)
	alignNodesOneByOne(self._rootnode.mtitle, self._rootnode.debrisNameLbl)
	self:createTreasure(false, data)
end

function DuobaoResult:setBtnEnabled(b, isSnatchAgain)
	if isSnatchAgain == false and self._rootnode.snatchBtn ~= nil then
		self._rootnode.snatchBtn:setEnabled(b)
	end
	if self._rootnode.replayBtn then
		self._rootnode.replayBtn:setEnabled(b)
	end
	if self._rootnode.confirmBtn then
		self._rootnode.confirmBtn:setEnabled(b)
	end
end

function DuobaoResult:setBtnDisabled(isSnatchAgain)
	self:setBtnEnabled(false, isSnatchAgain)
	self:performWithDelay(function()
		self:setBtnEnabled(true, isSnatchAgain)
	end,
	2)
end

function DuobaoResult:initWin(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("duobao/duobao_win.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local effWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli",
	isRetain = true
	})
	effWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effWin)
	local effTextWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli_zi",
	isRetain = true
	})
	effTextWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effTextWin)
	local zhenrongBtn = self._rootnode.zhenrongBtn
	local zhanbaoBtn = self._rootnode.zhanbaoBtn
	if self._isNPC then
		zhenrongBtn:setVisible(false)
		zhanbaoBtn:setPosition(display.cx - zhenrongBtn:getContentSize().width / 2, zhanbaoBtn:getPositionY())
	end
	zhenrongBtn:setEnabled(false)
	zhanbaoBtn:setEnabled(false)
	self._rootnode.snatchBtn:setEnabled(false)
	self._rootnode.replayBtn:setEnabled(false)
	self._rootnode.confirmBtn:setEnabled(false)
	
	local snatchAgainBtn = self._rootnode.snatchBtn
	snatchAgainBtn:addHandleOfControlEvent(function()
		snatchAgainBtn:setEnabled(false)
		self:setBtnDisabled(true)
		if game.player.m_energy < 2 then
			local layer = require("game.Duobao.DuobaoBuyMsgBox").new({})
			game.runningScene:addChild(layer, self:getZOrder() + 1)
			snatchAgainBtn:setEnabled(true)
		else
			self._snatchAgain(self._snatchIndex)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self:createTreasure(true, data)
	alignNodesOneByOne(self._rootnode.SilverCoin, self._rootnode.yinbiLbl)
	alignNodesOneByOne(self._rootnode.EXP, self._rootnode.expLbl)
	alignNodesOneByOne(self._rootnode.Niko, self._rootnode.nailiLbl)
	alignNodesOneByOne(self._rootnode.mtitle, self._rootnode.snatchBtn)
end

function DuobaoResult:createTreasure(lostDebris, data)
	local rtnAry = data["3"]
	dump(rtnAry)
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	local createOpenEffect = function(baoxiang)
		local xunhuanEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "baoxiangdakaiguangxiao_xunhuan",
		isRetain = true
		})
		xunhuanEffect:setPosition(baoxiang:getContentSize().width / 2, baoxiang:getContentSize().height / 2)
		baoxiang:addChild(xunhuanEffect, -10)
	end
	local function onClickCard(index)
		local item = rtnAry[index]
		rtnAry[index] = rtnAry[1]
		rtnAry[1] = item
		local time = 0.2
		local function checkShuxingIcon(index)
			local tag = index
			local v = rtnAry[tag]
			local canhunIcon = self._rootnode["canhun_" .. tag]
			local suipianIcon = self._rootnode["suipian_" .. tag]
			if v.t == 3 then
				suipianIcon:setVisible(true)
			elseif v.t == 5 then
				canhunIcon:setVisible(true)
			end
			self._rootnode["icon_" .. tostring(tag)]:setVisible(true)
			self._rootnode["reward_name_" .. tostring(tag)]:setVisible(true)
		end
		local function openTreasure(index)
			local function resetFrame(node)
				node:setDisplayFrame(display.newSprite("#db_card_front_image.png"):getDisplayFrame())
				node:runAction(transition.sequence({
				CCScaleTo:create(time, 1, 1)
				}))
				checkShuxingIcon(index)
			end
			local baoxing = self._rootnode["baoxiang_" .. index]
			baoxing:stopAllActions()
			baoxing:runAction(transition.sequence({
			CCScaleTo:create(time, 0.01, 1),
			CCCallFuncN:create(resetFrame)
			}))
		end
		local function openAllBaoxiang()
			if self._isLevelup == true then
				self:confirmFunc()
			end
			for i, v in ipairs(rtnAry) do
				if i ~= index then
					openTreasure(i)
				end
			end
			if self._getDebris == false then
				self._rootnode.snatchBtn:setEnabled(true)
			end
			if lostDebris == true then
				self._rootnode.zhenrongBtn:setEnabled(true)
			end
			self._rootnode.replayBtn:setEnabled(true)
			self._rootnode.confirmBtn:setEnabled(true)
			for i, v in ipairs(rtnAry) do
				self._rootnode["icon_" .. i]:setTouchEnabled(true)
			end
		end
		for i, v in ipairs(rtnAry) do
			local id = v.id
			if i == index and id == self._debrisId then
				self._getDebris = true
			end
			local rewardIcon = self._rootnode["icon_" .. i]
			local resType = ResMgr.getResType(v.t)
			ResMgr.refreshIcon({
			id = id,
			resType = resType,
			itemBg = rewardIcon,
			iconNum = v.n,
			isShowIconNum = false,
			numLblSize = 22,
			numLblColor = cc.c3b(0, 255, 0),
			numLblOutColor = cc.c3b(0, 0, 0),
			itemType = v.t
			})
			rewardIcon:setTag(i)
			rewardIcon:setVisible(false)
			
			local touch = require("utility.MyLayer").new({
			size = rewardIcon:getContentSize(),
			swallow = true
			})
			touch:addTo(rewardIcon)
			touch:setTouchHandler(function(event)
				touch:setTouchEnabled(false)
				local itemInfo = require("game.Huodong.ItemInformation").new({
				id = id,
				type = v.t,
				endFunc = function()
					touch:setTouchEnabled(true)
				end
				})
				self:addChild(itemInfo, MAX_ZORDER)
				return true
			end)
			
			self._rootnode["canhun_" .. i]:setVisible(false)
			self._rootnode["suipian_" .. i]:setVisible(false)
			local nameKey = "reward_name_" .. tostring(i)
			local nameColor = ResMgr.getItemNameColorByType(id, resType)
			local name = ResMgr.getItemNameByType(id, resType)
			local nameLbl = ui.newTTFLabelWithShadow({
			text = name,
			size = 20,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_LEFT,
			color = nameColor,
			shadowColor = FONT_COLOR.BLACK
			})
			ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, nameLbl:getContentSize().height / 2)
			nameLbl:align(display.CENTER)
		end
		
		local baoxing = self._rootnode["baoxiang_" .. index]
		baoxing:stopAllActions()
		baoxing:runAction(transition.sequence({
		CCScaleTo:create(time, 0.01, 1),
		CCCallFuncN:create(function(node)
			node:setDisplayFrame(display.newSprite("#db_card_front_image.png"):getDisplayFrame())
			checkShuxingIcon(index)
			node:runAction(transition.sequence({
			CCScaleTo:create(time, 1, 1),
			CCCallFuncN:create(function(node)
				createOpenEffect(node)
			end),
			CCDelayTime:create(time),
			CCCallFunc:create(openAllBaoxiang)
			}))
		end)
		}))
	end
	local scaleFunc = function(node)
		node:runAction(CCRepeatForever:create(transition.sequence({
		CCScaleTo:create(0.15, 0.8),
		CCScaleTo:create(0.15, 1),
		CCDelayTime:create(0.5)
		})))
	end
	
	local baoxiangtouchs = {}
	for i, v in ipairs(rtnAry) do
		local baoxiang = self._rootnode["baoxiang_" .. i]
		baoxiang:runAction(transition.sequence({
		CCDelayTime:create((i - 1) * 0.3),
		CCCallFuncN:create(scaleFunc)
		}))
		local touch = require("utility.MyLayer").new({
		size = baoxiang:getContentSize(),
		swallow = true,
		touchHandler = function(event)
			if event.name == "began" then
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_fanpai))
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				onClickCard(i)
				for j, vt in ipairs(baoxiangtouchs) do
					vt:setTouchEnabled(false)
				end
				return true
			end
		end
		})
		touch:addTo(baoxiang)
		table.insert(baoxiangtouchs, touch)
	end
end

function DuobaoResult:initLost(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("duobao/duobao_lost.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local zhenrongBtn = self._rootnode.zhenrongBtn
	if self._isNPC then
		zhenrongBtn:setVisible(false)
	end
	
	self._rootnode.wujiangBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhuangbeiBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.goZhenrongBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.heroRewardBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhenqiBtn:addHandleOfControlEvent(function(eventName, sender)
		GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	alignNodesOneByOne(self._rootnode.SilverCoin, self._rootnode.yinbiLbl)
	alignNodesOneByOne(self._rootnode.EXP, self._rootnode.expLbl)
	alignNodesOneByOne(self._rootnode.Niko, self._rootnode.nailiLbl)
end

function DuobaoResult:onEnter()
end

function DuobaoResult:onExit()
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	ResMgr.ReleaseUIArmature("zhandoushengli")
	ResMgr.ReleaseUIArmature("zhandoushengli_zi")
	ResMgr.ReleaseUIArmature("baoxiangdakaiguangxiao_xunhuan")
end

function DuobaoResult:confirmFunc()
	if self._getDebris == true then
		CCDirector:sharedDirector():popToRootScene()
	else
		pop_scene()
	end
end

function DuobaoResult:ctor(param)
	self._isLevelup = false
	self._rootnode = {}
	local data = param.data
	local name = param.name
	self._isNPC = param.isNPC
	self._enemyAcc = param.enemyAcc
	self._debrisName = param.title
	self._snatchIndex = param.snatchIndex
	self._snatchAgain = param.snatchAgain
	self._debrisId = param.debrisId
	dump(data)
	self:setNodeEventEnabled(true)
	local result = data["1"][1]
	self._getItemId = data["5"]
	local coinAry = data["4"]
	local resisVal = data["6"]
	local attack = data["7"]
	local beforeLevel = game.player.getLevel()
	local curlevel = data["9"] or beforeLevel
	local curExp = data["10"] or 0
	game.player:updateMainMenu({lv = curlevel, exp = curExp})
	self._getDebris = false
	if result == 2 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
		self:initLost(data)
	elseif result == 1 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
		if self._getItemId == 0 then
			self:initWin(data)
		else
			self._getDebris = true
			self:initWinDebris(data)
		end
	end
	local curLv = game.player:getLevel()
	if beforeLevel < curLv then
		self._isLevelup = true
		local curNail = game.player:getNaili()
		local levelUpLayer = UIManager:getLayer("game.LevelUp.LevelUpLayer", nil, {
		level = beforeLevel,
		uplevel = curLv,
		naili = curNail,
		curExp = curExp
		})
		self:addChild(levelUpLayer, MAX_ZORDER)
	end
	self._rootnode.battle_value_left:setString(tostring(game.player:getBattlePoint()))
	self._rootnode.battle_value_right:setString(tostring(attack))
	self._rootnode.nailiLbl:setString("-" .. resisVal)
	self._rootnode.player_name_left:setString(game.player.getPlayerName())
	self._rootnode.player_name_right:setString(name)
	for _, v in ipairs(coinAry) do
		if v.id == 2 then
			self._rootnode.yinbiLbl:setString("+" .. tostring(v.n))
		elseif v.id == 6 then
			self._rootnode.expLbl:setString("+" .. tostring(v.n))
		end
	end
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		self:setBtnDisabled(false)
		self:confirmFunc()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	end,
	CCControlEventTouchUpInside)
	
	local replayBtn = self._rootnode.replayBtn
	replayBtn:addHandleOfControlEvent(function(sender, eventName)
		self:setBtnDisabled(false)
		local function closeFunc(node)
			node:removeSelf()
			replayBtn:setEnabled(true)
		end
		self:addChild(require("game.Duobao.DuobaoBattleReplayLayer").new(data, closeFunc), MAX_ZORDER)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	if self._rootnode.zhenrongBtn ~= nil then
		self._rootnode.zhenrongBtn:setVisible(false)
	end
	if self._rootnode.zhanbaoBtn ~= nil then
		self._rootnode.zhanbaoBtn:setVisible(false)
	end
end

return DuobaoResult