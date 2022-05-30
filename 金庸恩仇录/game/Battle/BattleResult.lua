require("game.GameConst")

local BattleResult = class("BattleResult", function (data)
	return require("utility.ShadeLayer").new()
end)

function BattleResult:ctor(data)
	self:setNodeEventEnabled(true)
	self.jumpFunc = data.jumpFunc
	self.curLv = data.curLv
	self.befLv = data.befLv
	self._zhanli = data.zhanli or game.player.m_battlepoint
	self._npcLv = data.npcLv
	self._viewType = data.viewType or 0
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	local winType = data.win or 2
	if winType == 1 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
		self:initWin(data)
	else
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
		self:initLost(data)
	end
end

local fileMap = {}
fileMap[1] = "bw_easy.png"
fileMap[2] = "bw_normal.png"
fileMap[3] = "bw_hard.png"
fileMap[4] = "bw_emeng.png"
fileMap[5] = "bw_lianyu.png"
fileMap[6] = "bw_shishi.png"
fileMap[7] = "bw_chuanshuo.png"

function BattleResult:getIconName(id)
	return fileMap[id]
end

function BattleResult:initWin(rewards)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local nodeSz, boxSz
	
	if #rewards.rewardItem > 4 then
		nodeSz = cc.size(640, 960)
		boxSz = cc.size(450, 268)
	else
		nodeSz = cc.size(640, 850)
		boxSz = cc.size(450, 154)
	end
	
	local node = CCBuilderReaderLoad("ccbi/battle/battle_win.ccbi", proxy, rootnode, self, nodeSz)
	node:ignoreAnchorPointForPosition(false)
	node:setPosition(display.cx, display.height * 0.58)
	self:addChild(node)
	display.addSpriteFramesWithFile("ui/ui_battle_win.plist", "ui/ui_battle_win.png")
	local rewardNode = rootnode.reward_node
	local rewardBg = display.newScale9Sprite("#bw_bottom_bg.png", 0, 0, boxSz)
	rewardBg:setAnchorPoint(cc.p(0.5, 1))
	rewardBg:setPosition(rewardBg:getContentSize().width / 2, 0)
	rewardNode:addChild(rewardBg)
	if ResMgr.isHighEndDevice() == true then
		local effWin = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "zhandoushengli",
		isRetain = false
		})
		effWin:setPosition(rootnode.tag_title_anim:getContentSize().width / 2, rootnode.tag_title_anim:getContentSize().height)
		rootnode.tag_title_anim:addChild(effWin)
	end
	local effTextWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli_zi",
	isRetain = false
	})
	effTextWin:setPosition(rootnode.tag_title_anim:getContentSize().width / 2, rootnode.tag_title_anim:getContentSize().height)
	rootnode.tag_title_anim:addChild(effTextWin)
	rootnode.tag_lv:setString(game.player.m_level)
	rootnode.tag_zhanli:setString(self._zhanli)
	if rewards.levelName ~= nil then
		local titleLabel = ui.newTTFLabelWithOutline({
		text = rewards.levelName,
		font = FONTS_NAME.font_haibao,
		size = 28,
		color = FONT_COLOR.LEVEL_NAME,
		outlineColor = display.COLOR_BLACK,
		})
		ResMgr.replaceKeyLable(titleLabel, rootnode.tag_level_name, 0, 0)
		titleLabel:align(display.CENTER)
	end
	local rewardMoney = rootnode.tag_mid_bg
	local textTag = {
	"tag_silver",
	"tag_xiahun",
	"tag_exp"
	}
	self.coinTable = {}
	self.coinNum = {}
	ResMgr.setMetatableByKV(self.coinTable)
	ResMgr.setMetatableByKV(self.coinNum)
	for i, v in ipairs(rewards.rewardCoin) do
		local x = 0
		local y = 0
		local tag = ""
		if v.id == 2 then
			tag = "tag_silver"
		elseif v.id == 7 then
			tag = "tag_xiahun"
		elseif v.id == 6 then
			tag = "tag_exp"
		end
		_x = rootnode[tag]:getContentSize().width * 1.5
		_y = rootnode[tag]:getContentSize().height * 0.4
		local coinTextLabel = ui.newTTFLabel({
		text = v.n,
		x = rootnode[tag]:getContentSize().width / 2 + 30,
		y = _y,
		font = FONTS_NAME.font_fzcy,
		size = 20,
		color = cc.c3b(0, 0, 0),
		align = ui.TEXT_ALIGN_LEFT
		})
		coinTextLabel:align(display.LEFT_CENTER)
		self.coinTable[#self.coinTable + 1] = coinTextLabel
		self.coinNum[#self.coinNum + 1] = v.n
		if tag ~= "" then
			rootnode[tag]:addChild(coinTextLabel)
		else
			
		end
	end
	
	alignNodesOneByOne(rootnode.AcquireSilverCoin, rootnode.tag_silver)
	alignNodesOneByOne(rootnode.AcquireSoulMan, rootnode.tag_xiahun)
	alignNodesOneByOne(rootnode.AcquireExperience, rootnode.tag_exp)
	local TIME_TO = 0.1
	local repeatIndex = 30
	local interval = TIME_TO / repeatIndex
	local index = 0
	local function update(dt)
		index = index + 1
		for i = 1, #self.coinTable do
			self.coinTable[i]:setString(math.floor(self.coinNum[i] / repeatIndex) * index)
		end
		if index >= repeatIndex then
			self.scheduler.unscheduleGlobal(self.timeHandle)
			for i = 1, #self.coinTable do
				self.coinTable[i]:setString(self.coinNum[i])
			end
		end
	end
	
	self.scheduler = require("framework.scheduler")
	if self.timeHandle ~= nil then
		self.scheduler.unscheduleGlobal(self.timeHandle)
	end
	self.timeHandle = self.scheduler.scheduleGlobal(update, interval, false)
	local percent = game.player.m_exp / game.player.m_maxExp
	local befPercent = game.player.m_befExp / game.player.m_maxExp
	if percent > 1 then
		percent = 1
	end
	
	self.addBar = display.newProgressTimer("#bw_exp_green.png", display.PROGRESS_TIMER_BAR)
	self.addBar:setMidpoint(cc.p(0, 0.5))
	self.addBar:setBarChangeRate(cc.p(1, 0))
	self.addBar:setAnchorPoint(cc.p(0, 0.5))
	self.addBar:setPosition(0, rootnode.bw_exp_gray:getContentSize().height / 2)
	rootnode.bw_exp_gray:addChild(self.addBar)
	self.addBar:setPercentage(befPercent * 100)
	local riseAnim
	if self.curLv ~= self.befLv then
		riseAnim = transition.sequence({
		CCProgressTo:create(TIME_TO * (1 - befPercent) / (1 - befPercent + percent), 100),
		CCCallFunc:create(function ()
			self.addBar:setPercentage(0)
		end),
		CCProgressTo:create(TIME_TO * percent / (1 - befPercent + percent), percent * 100)
		})
	else
		riseAnim = CCProgressTo:create(TIME_TO, percent * 100)
	end
	
	self.addBar:runAction(riseAnim)
	if rewards.gradeID ~= nil then
		local iconName = self:getIconName(rewards.gradeID)
		if iconName ~= nil then
			rootnode.tag_star_title:setDisplayFrame(display.newSpriteFrame(iconName))
		end
		for i = 3, rewards.maxStar + 1, -1 do
			rootnode["gray_star_" .. i]:setVisible(false)
		end
		for i = 1, rewards.gradeID do
			rootnode["star_" .. i]:setVisible(true)
		end
	elseif self._npcLv ~= nil then
		local iconName = self:getIconName(self._npcLv)
		if iconName ~= nil then
			rootnode.tag_star_title:setDisplayFrame(display.newSpriteFrame(iconName))
		end
	end
	if self._viewType == CHALLENGE_TYPE.ZHENSHEN_VIEW then
		rootnode.tag_star_title:setVisible(false)
		for i = 1, 3 do
			rootnode["gray_star_" .. i]:setVisible(false)
			rootnode["star_" .. i]:setVisible(false)
		end
	end
	local _data
	local w = 95
	local h = 95
	local data_item_item = require("data.data_item_item")
	for k, v in pairs(rewards.rewardItem) do
		local x = w * 0.72 + math.floor((k - 1) % 4) * w * 1.1
		local y = rewardBg:getContentSize().height + h * 0.45 - h * 1.22 * (1 + math.floor((k - 1) / 4))
		local item = display.newSprite()
		ResMgr.refreshItemWithTagNumName({
		id = v.id,
		itemBg = item,
		isShowIconNum = 1 < v.n and 1 or 0,
		itemNum = v.n,
		itemType = v.t,
		resType = ResMgr.getResType(v.t),
		cls = 0
		})
		item:setPosition(x, y)
		rewardBg:addChild(item)
	end
	
	--È·ÈÏ°´Å¥
	rootnode.confirmBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self.jumpFunc ~= nil then
			self.jumpFunc()
		end
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	end,
	CCControlEventTouchUpInside)
	
	TutoMgr.addBtn("zhandoushengli1_btn_quedinganniu1", rootnode.confirmBtn)
	ResMgr.delayFunc(0.5, function ()
		TutoMgr.active()
	end)
end

function BattleResult:setJumpFunc(func)
	self.jumpFunc = func
end

function BattleResult:initLost(rewards)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/battle/lost.ccbi", proxy, rootnode)
	self:addChild(node)
	local bg = rootnode.tag_bg
	rootnode.tag_zhanli:setString(self._zhanli)
	dump(rootnode)
	if rewards.levelName ~= nil then
		local titleLabel = ui.newTTFLabelWithOutline({
		text = rewards.levelName,
		font = FONTS_NAME.font_haibao,
		size = 28,
		color = FONT_COLOR.LEVEL_NAME,
		outlineColor = display.COLOR_BLACK,
		align = ui.TEXT_ALIGN_CENTER,
		})
		ResMgr.replaceKeyLable(titleLabel, rootnode.tag_level_name, 0, 0)
		titleLabel:align(display.CENTER)
	end
	
	if rewards.gradeID ~= nil then
		local iconName = self:getIconName(rewards.gradeID)
		if iconName ~= nil then
			rootnode.tag_star_title:setDisplayFrame(display.newSpriteFrame(iconName))
		end
		for i = 3, rewards.maxStar + 1, -1 do
			rootnode["gray_star_" .. i]:setVisible(false)
		end
		if rewards.star > 0 then
			for i = 1, rewards.star do
				rootnode["star_" .. i]:setVisible(true)
			end
		end
	elseif self._npcLv ~= nil then
		local iconName = self:getIconName(self._npcLv)
		if iconName ~= nil then
			rootnode.tag_star_title:setDisplayFrame(display.newSpriteFrame(iconName))
		end
	end
	if self._viewType == CHALLENGE_TYPE.ZHENSHEN_VIEW then
		rootnode.tag_star_title:setVisible(false)
		for i = 1, 3 do
			rootnode["gray_star_" .. i]:setVisible(false)
			rootnode["star_" .. i]:setVisible(false)
		end
	end
	
	rootnode.wujiangBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
	end,
	CCControlEventTouchUpInside)
	
	rootnode.zhuangbeiBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
	end,
	CCControlEventTouchUpInside)
	
	rootnode.goZhenrongBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
	end,
	CCControlEventTouchUpInside)
	
	rootnode.heroRewardBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
	end,
	CCControlEventTouchUpInside)
	
	rootnode.zhenqiBtn:addHandleOfControlEvent(function (sender, eventName)
		GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self.jumpFunc ~= nil then
			self.jumpFunc()
		end
	end,
	CCControlEventTouchUpInside)
	
end

function BattleResult:onEnter()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

function BattleResult:onExit()
	if self.timeHandle ~= nil then
		self.scheduler.unscheduleGlobal(self.timeHandle)
	end
	TutoMgr.removeBtn("zhandoushengli1_btn_quedinganniu1")
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	ResMgr.ReleaseUIArmature("zhandoushengli")
	ResMgr.ReleaseUIArmature("zhandoushengli_zi")
	display.removeSpriteFrameByImageName("ccs/ui_effect/zhandoushengli/zhandoushengli.png")
	display.removeSpriteFrameByImageName("ccs/ui_effect/zhandoushengli_zi/zhandoushengli_zi.png")
	display.removeSpriteFrameByImageName("ccs/effect/nuqiji_zi/nuqiji_zi.png")
	display.removeSpriteFrameByImageName("ccs/effect/dazhaoshifang/dazhaoshifa_bao.png")
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.removeSpriteFrameByImageName("ui_weijiao_yishou.png")
	display.removeSpriteFramesWithFile("ui/ui_battle_win.plist", "ui/ui_battle_win.png")
	display.removeSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	collectgarbage("collect")
end

return BattleResult