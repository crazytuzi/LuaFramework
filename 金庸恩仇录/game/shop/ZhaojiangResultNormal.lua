local ZhaojiangResultNormal = class("ZhaojiangResultNormal", function()
	return require("utility.ShadeLayer").new()
end)

function ZhaojiangResultNormal:createStar()
	display.addSpriteFramesWithFile("ui/ui_zhaojiangResult.plist", "ui/ui_zhaojiangResult.png")
	for i = 1, 5 do
		if self._star == i then
			self._rootnode["star_" .. i]:setVisible(true)
		else
			self._rootnode["star_" .. i]:setVisible(false)
		end
	end
	local key = "star_" .. self._star .. "_"
	for i = 1, self._star do
		local star = self._rootnode[key .. i]
		star:setScale(3.5)
		star:setDisplayFrame(display.newSprite("#star.png"):getDisplayFrame())
		star:setVisible(false)
	end
	for i = 1, self._star do
		local star = self._rootnode[key .. i]
		star:runAction(transition.sequence({
		CCDelayTime:create((i - 1) * 0.2),
		CCCallFuncN:create(function(node)
			node:setVisible(true)
		end),
		CCScaleTo:create(0.2, 1.3)
		}))
	end
end

function ZhaojiangResultNormal:luckInfo()
end

function ZhaojiangResultNormal:heroAppear(heroID)
	local icon = self._rootnode.icon_tag
	icon:setScale(0.5)
	local frame = ResMgr.getLargeFrame(ResMgr.HERO, heroID)
	icon:setDisplayFrame(frame)
	icon:runAction(transition.sequence({
	CCScaleTo:create(0.2, 1)
	}))
	local bgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "xiakejinjie_xunhuan",
	isRetain = true
	})
	local effectNode = self._rootnode.effect_tag
	local cntSize = effectNode:getContentSize()
	bgEffect:setPosition(cntSize.width / 2, cntSize.height / 2)
	effectNode:addChild(bgEffect)
	self:createStar()
	if self.heroIno.displaySound then
		GameAudio.palyHeroDub("sound/" .. ResMgr.PERSION_SFX .. "/" .. self.heroIno.displaySound)
	end
end

function ZhaojiangResultNormal:onExit()
	ResMgr.ReleaseUIArmature("xiakejinjie_xunhuan")
	ResMgr.ReleaseUIArmature("xiakejinjie_qishou")
	TutoMgr.removeBtn("zhaojiang_result_exit")
	if self.removeListener ~= nil then
		self.removeListener()
	end
end

function ZhaojiangResultNormal:ctor(param)
	self:setTag(200)
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_zhaomu))
	self.removeListener = param.removeListener
	self:setNodeEventEnabled(true)
	local _type = param.type
	local _heroList = param.herolist
	local _leftTime = param.leftTime or 0
	local _zhaomulingNum = param.zhaomulingNum
	local _buyListener = param.buyListener
	local _point = param.point
	local _cost = param.cost or 280
	self.scoreTable = param.scoreTable
	local _heroInfo = ResMgr.getCardData(_heroList[1].id)
	self.heroIno = _heroInfo
	self._star = _heroInfo.star[1]
	local bg = display.newSprite("ui/jpg_bg/zhaojiang_bg.jpg")
	bg:setScaleX(display.width / bg:getContentSize().width)
	bg:setScaleY(display.height / bg:getContentSize().height)
	bg:setPosition(display.cx, display.cy)
	self:addChild(bg)
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("shop/zhaojiang_normal.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local goldLabel = self._rootnode.coinNumLbl01
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		self._rootnode.silver:setVisible(true)
		self._rootnode.gold:setVisible(false)
		goldLabel = self._rootnode.coinNumLbl02
	end
	self._rootnode.nameLbl:setString(_heroInfo.name)
	self._rootnode.nameLbl:setColor(NAME_COLOR[self._star])
	if self.scoreTable ~= nil then
		self._rootnode.limit_hero_node:setVisible(true)
		self:createLimitHeroDetail()
	else
		self._rootnode.limit_hero_node:setVisible(false)
	end
	if self._star < 4 then
		self._rootnode.shareBtn:setVisible(false)
		local exitBtn = self._rootnode.exitBtn
		exitBtn:setPosition(display.width / 2, exitBtn:getPositionY())
	end
	if _type == 4 then
		self._rootnode.zhaomuling_tag:setVisible(false)
		goldLabel:setString(_cost)
	elseif _type == 3 then
		self._rootnode.zhaomuling_tag:setVisible(false)
		goldLabel:setString("280")
	else
		if _type == 1 then
			self._rootnode.zhaomuling_tag:setVisible(true)
			self._rootnode.coin_tag:setVisible(false)
			self._rootnode.zhaomulingNumLabel:setString(_zhaomulingNum)
		else
			self._rootnode.coin_tag:setVisible(true)
			self._rootnode.zhaomuling_tag:setVisible(false)
			goldLabel:setString("80")
		end
		self._rootnode.leftTime_desc:setVisible(false)
	end
	--goldLabel:align(display.CENTER)
	
	if _leftTime == 0 then
		self._rootnode.RecruitGet:setString(common:getLanguageString("@zhaomubd"))
	else
		self._rootnode.RecruitGet:setString(common:getLanguageString("@RecruitGet", _leftTime))
	end
	
	--退出
	self._rootnode.exitBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeFromParentAndCleanup(true)
		PostNotice(NoticeKey.CommonUpdate_Label_Gold)
		PostNotice(NoticeKey.CommonUpdate_Label_Silver)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	end,
	CCControlEventTouchUpInside)
	TutoMgr.addBtn("zhaojiang_result_exit", self._rootnode.exitBtn)
	TutoMgr.active()
	
	--继续招募
	self._rootnode.zhaojiangBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local money, tips
		if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
			money = game.player:getSilver()
			tips = common:getLanguageString("@SilverCoinEnough")
		else
			money = game.player:getGold()
			tips = common:getLanguageString("@PriceEnough")
		end
		if _type == 1 and _zhaomulingNum <= 0 then
			show_tip_label(common:getLanguageString("@daojubz"))
		elseif _type == 2 and money < 80 then
			show_tip_label(tips)
		elseif _type == 3 and money < 280 then
			show_tip_label(tips)
		elseif _type == 4 and money < _cost then
			show_tip_label(tips)
		else
			_buyListener(_type, _, 1, self)
		end
	end,
	CCControlEventTouchUpInside)
	
	local bgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "xiakejinjie_qishou",
	frameFunc = c_func(handler(self, ZhaojiangResultNormal.heroAppear), _heroList[1].id),
	isRetain = false,
	finishFunc = function(...)
	end
	})
	local effectNode = self._rootnode.effect_tag
	local cntSize = effectNode:getContentSize()
	bgEffect:setPosition(cntSize.width / 2, cntSize.height / 2)
	effectNode:addChild(bgEffect)
	
	--查看卡牌
	ResMgr.setControlBtnEvent(self._rootnode.chakanBtn, function()
		local layer = require("game.Hero.HeroInfoLayer").new({
		info = {
		resId = _heroList[1].id,
		objId = _heroList[1].objId
		}
		}, 3)
		game.runningScene:addChild(layer, 100)
	end)
	alignNodesOneByOne(self._rootnode.Consume, self._rootnode.RecruitX1)
	if _point and _point > 0 then
		show_tip_label(common:getLanguageString("@LuckyPlus") .. tostring(_point))
	end
end

function ZhaojiangResultNormal:createLimitHeroDetail()
	local colorTable = {
	cc.c3b(255, 210, 0),
	cc.c3b(36, 255, 0),
	cc.c3b(255, 210, 0)
	}
	for i = 1, #self.scoreTable do
		local scoreTTF = ui.newTTFLabelWithShadow({
		text = self.scoreTable[i],
		size = 20,
		color = colorTable[i],
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		self:arrPos(scoreTTF, self._rootnode["score" .. i])
		self._rootnode.limit_hero_node:addChild(scoreTTF)
	end
end

function ZhaojiangResultNormal:arrPos(ttf, node)
	ttf:setPosition(node:getPositionX() + node:getContentSize().width / 2, node:getPositionY() - 3)
end

return ZhaojiangResultNormal