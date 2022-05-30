require("game.GameConst")
local MAX_ZORDER = 11113

local ArenaResult = class("ArenaResult", function(data)
	return require("utility.ShadeLayer").new()
end)

function ArenaResult:createTreasure(lostDebris, data)
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
			for i, v in ipairs(rtnAry) do
				if i ~= index then
					openTreasure(i)
				end
			end
			if lostDebris then
				self._rootnode.snatchBtn:setEnabled(true)
				self._rootnode.zhenrongBtn:setEnabled(true)
			end
			self._rootnode.replayBtn:setEnabled(true)
			self._rootnode.confirmBtn:setEnabled(true)
		end
		local item = rtnAry[index]
		rtnAry[index] = rtnAry[1]
		rtnAry[1] = item
		for i, v in ipairs(rtnAry) do
			local id = v.id
			local rewardIcon = self._rootnode["icon_" .. i]
			local resType = ResMgr.getResType(v.t)
			ResMgr.refreshIcon({
			id = id,
			resType = resType,
			itemBg = rewardIcon,
			iconNum = v.n,
			isShowIconNum = false,
			numLblSize = 22,
			numLblColor = ccc3(0, 255, 0),
			numLblOutColor = ccc3(0, 0, 0),
			itemType = v.t
			})
			rewardIcon:setTag(i)
			rewardIcon:setVisible(false)
			self._rootnode["canhun_" .. i]:setVisible(false)
			self._rootnode["suipian_" .. i]:setVisible(false)
			local nameKey = "reward_name_" .. tostring(i)
			local nameColor = ResMgr.getItemNameColorByType(id, resType)
			local name = ResMgr.getItemNameByType(id, resType)
			local nameLbl = ui.newTTFLabelWithShadow({
			text = name,
			size = 20,
			color = nameColor,
			shadowColor = FONT_COLOR.BLACK,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_LEFT
			})
			nameLbl:setPosition(-nameLbl:getContentSize().width / 2, nameLbl:getContentSize().height / 2)
			self._rootnode[nameKey]:addChild(nameLbl)
			self._rootnode[nameKey]:setVisible(false)
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
	for i, v in ipairs(rtnAry) do
		do
			local baoxiang = self._rootnode["baoxiang_" .. i]
			baoxiang:runAction(transition.sequence({
			CCDelayTime:create((i - 1) * 0.3),
			CCCallFuncN:create(scaleFunc)
			}))
			baoxiang:setTouchEnabled(true)
			baoxiang:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
				if event.name == "began" then
					onClickCard(i)
					for j, vbao in ipairs(rtnAry) do
						self._rootnode["baoxiang_" .. j]:setTouchEnabled(false)
					end
					return true
				end
			end)
		end
	end
end

function ArenaResult:initWin(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("arena/arena_win.ccbi", proxy, self._rootnode)
	node:setPosition(display.width / 2, display.height / 2)
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
	self._rootnode.replayBtn:setEnabled(false)
	self._rootnode.confirmBtn:setEnabled(false)
	self:createTreasure(false, data)
end

function ArenaResult:initLost(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("arena/arena_lost.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local zhenrongBtn = self._rootnode.zhenrongBtn
	zhenrongBtn:setVisible(false)
	self._rootnode.wujiangBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhuangbeiBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.goZhenrongBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.heroRewardBtn:addHandleOfControlEvent(function(sender, eventName)
		GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhenqiBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
	end,
	CCControlEventTouchUpInside)
end

function ArenaResult:ctor(param)
	local data = param.data
	self._rootnode = {}
	local battleData = data["2"][1]
	local result = battleData.d["end"].win
	local coinAry = data["4"]
	local objData = data["5"]
	if result == 1 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
		self:initWin(data)
	elseif result == 2 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
		self:initLost(data)
	else
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
		self:initLost(data)
	end
	self._rootnode.battle_value_left:setString(tostring(objData.attack1))
	self._rootnode.battle_value_right:setString(tostring(objData.attack2))
	self._rootnode.nailiLbl:setString("-2")
	self._rootnode.player_name_left:setString(objData.name1)
	self._rootnode.player_name_right:setString(objData.name2)
	for _, v in ipairs(coinAry) do
		if v.id == 2 then
			self._rootnode.yinbiLbl:setString("+" .. tostring(v.n))
		elseif v.id == 5 then
			self._rootnode.shengwangLbl:setString("+" .. tostring(v.n))
		elseif v.id == 6 then
			self._rootnode.expLbl:setString("+" .. tostring(v.n))
		end
	end
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_ARENA)
	end,
	CCControlEventTouchUpInside)
	
	local replayBtn = self._rootnode.replayBtn
	replayBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		replayBtn:setEnabled(false)
		local function closeFunc(node)
			node:removeFromParentAndCleanup(true)
			replayBtn:setEnabled(true)
		end
		self:addChild(require("game.Duobao.DuobaoBattleReplayLayer").new(data, closeFunc), MAX_ZORDER)
	end,
	CCControlEventTouchUpInside)
	
end

function ArenaResult:onExit(...)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
end

return ArenaResult