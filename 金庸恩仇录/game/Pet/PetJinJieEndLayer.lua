local data_shentong_shentong = require("data.data_shentong_shentong")
local data_talent_talent = require("data.data_talent_talent")

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

local PetJinJieEndLayer = class("PetJinJieEndLayer", function()
	display.addSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
	display.addSpriteFramesWithFile("ui/ui_equipV2.plist", "ui/ui_equipV2.png")
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 200))
end)

function PetJinJieEndLayer:onExit()
	TutoMgr.removeBtn("jinjie_end_layer_shentong_name")
end

function PetJinJieEndLayer:ctor(param)
	self.data = param.data
	self.removeListener = param.removeListener
	self:setNodeEventEnabled(true)
	self:setContentSize(cc.size(display.width, display.height))
	local befData = {
	lv = param.perData.level,
	base = param.perData.baseRate,
	baseAdd = param.perData.addBaseRate
	}
	local nextData = {
	resId = param.data.resId,
	cls = param.data.resId,
	star = param.data.star,
	lv = param.data.level,
	base = param.data.baseRate,
	baseAdd = param.data.addBaseRate
	}
	local ResID = nextData.resId
	local Cls = nextData.cls
	self.curCls = Cls
	local starNum = nextData.star
	self.effectNode = display.newNode()
	self:addChild(self.effectNode)
	self.baseNode = display.newNode()
	self:addChild(self.baseNode, 100)
	self.cardNode = display.newNode()
	self.baseNode:addChild(self.cardNode, 10)
	self.cardBg = display.newSprite()
	self.cardNode:addChild(self.cardBg)
	self.cardBg:setScale(0.6)
	self.cardNode:setPosition(display.cx, display.height * 0.8)
	ResMgr.refreshCardBg({
	sprite = self.cardBg,
	star = starNum,
	resType = ResMgr.HERO_BG_UI
	})
	self.heroImage = display.newSprite()
	local cardWidth = self.cardBg:getContentSize().width
	local cardHeight = self.cardBg:getContentSize().height
	self.heroImage:setPosition(cardWidth / 2, cardHeight * 0.7)
	self.cardBg:addChild(self.heroImage)
	self.heroImage:setDisplayFrame(ResMgr.getPetFrame(ResID, Cls))
	self.cardBg:setScale(1.9)
	self.cardBg:runAction(transition.sequence({
	CCScaleTo:create(0.3, 0.6),
	CCCallFunc:create(function()
		local bgEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "xiakejinjie_xunhuan",
		frameFunc = createEndLayer,
		isRetain = true
		})
		bgEffect:setPosition(display.cx, display.height * 0.8)
		self.effectNode:addChild(bgEffect)
	end)
	}))
	local starOrX = cardWidth * 0.11
	local starOrY = cardHeight * 0.08
	for i = 1, starNum do
		local star = display.newSprite("#item_board_star.png")
		star:setPosition(starOrX, starOrY)
		starOrX = starOrX + star:getContentSize().width
		star:setScale(0.9)
		self.cardBg:addChild(star)
	end
	self.fontNode = display.newNode()
	self.baseNode:addChild(self.fontNode)
	local fontArma = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "xiakejinjie_zitiliuguang",
	frameFunc = createEndLayer,
	isRetain = true
	})
	fontArma:setPosition(display.cx, display.height * 0.5)
	self.fontNode:addChild(fontArma)
	fontArma:setScale(2)
	fontArma:runAction(CCScaleTo:create(0.3, 1))
	local tal = ResMgr.getPetData(ResID).talent
	printf("======= %d", ResID)
	local tianFuPng = display.newSprite("#talent_unlock.png")
	tianFuPng:setPosition(display.width * 0.3 - 40, 0.43 * display.height)
	tianFuPng:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(tianFuPng)
	tianFuPng:setOpacity(0)
	TutoMgr.active()
	local cardStateNames = {
	common:getLanguageString("@LevelInfo"),
	common:getLanguageString("@Life"),
	common:getLanguageString("@Attack"),
	common:getLanguageString("@ThingDefense"),
	common:getLanguageString("@LawDefense")
	}
	local stateOrY = 0.35 * display.height
	local stateOffY = 0.05 * display.height
	for i = 1, #cardStateNames do
		
		local stateName = ui.newTTFLabel({
		text = cardStateNames[i],
		font = FONTS_NAME.font_haibao,
		color = FONT_COLOR.ORANGE
		})
		stateName:setPosition(display.width * 0.2, stateOrY)
		stateName:setScale(1.2)
		self:addChild(stateName)
		
		local befNum = 0
		local aftNum = 0
		if i == 1 then
			befNum = befData.lv
			aftNum = nextData.lv
		else
			befNum = math.ceil(befData.base[i - 1] + befData.baseAdd[i - 1])
			aftNum = math.ceil(nextData.base[i - 1] + nextData.baseAdd[i - 1])
		end
		local befNumLabel = ui.newTTFLabel({
		text = befNum,
		font = FONTS_NAME.font_fzcy,
		color = FONT_COLOR.ORANGE,
		size = 25
		})
		befNumLabel:setAnchorPoint(cc.p(0, 0.5))
		befNumLabel:setPosition(display.width * 0.3, stateOrY)
		self:addChild(befNumLabel)
		local fuhaoAr = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "xiakejinjie_fuhao",
		isRetain = true
		})
		fuhaoAr:setPosition(display.width * 0.5, stateOrY)
		self:addChild(fuhaoAr)
		local aftNumLabel = ui.newTTFLabel({
		text = aftNum,
		font = FONTS_NAME.font_fzcy,
		color = FONT_COLOR.GREEN_1,
		size = 25
		})
		aftNumLabel:setAnchorPoint(cc.p(0, 0.5))
		aftNumLabel:setPosition(display.width * 0.6, stateOrY)
		self:addChild(aftNumLabel)
		local upArrow = display.newSprite("#equip_up_arrow.png")
		upArrow:setPosition(display.width * 0.75, stateOrY)
		self:addChild(upArrow)
		stateOrY = stateOrY - stateOffY
	end
	
	self.isTouch = false
	ResMgr.delayFunc(0.5, function()
		self.isTouch = true
	end,
	self)
	
	self:setTouchHandler(function(event)
		if self.isTouch then
			if self.removeListener ~= nil then
				self.removeListener()
			end
			self:removeSelf()
		end
		if "began" == event.name then
			return true
		end
	end)
	require("game.Bag.BagCtrl").setRequest(false)
end

return PetJinJieEndLayer