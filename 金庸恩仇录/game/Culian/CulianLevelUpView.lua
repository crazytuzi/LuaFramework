local data_shentong_shentong = require("data.data_shentong_shentong")
local data_equipquench_equipquench = require("data.data_equipquench_equipquench")
local data_talent_talent = require("data.data_talent_talent")
local data_item_item = require("data.data_item_item")

local CulianLevelUpView = class("CulianLevelUpView", function()
	display.addSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
	display.addSpriteFramesWithFile("ui/ui_equipV2.plist", "ui/ui_equipV2.png")
	display.addSpriteFramesWithFile("ui/ui_item_board.plist", "ui/ui_item_board.png")
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 200))
end)

function CulianLevelUpView:onExit()
	TutoMgr.removeBtn("jinjie_end_layer_shentong_name")
end

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

function CulianLevelUpView:ctor(param)
	self:setNodeEventEnabled(true)
	self:setContentSize(cc.size(display.width, display.height))
	local data = param.data
	local Cls = data.cls
	self.curCls = Cls
	local starNum = self:getEquipByID(data.id).star
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
	--if starNum > 5 then
	--	starNum = 5
	--end
	ResMgr.refreshCardBg({
	sprite = self.cardBg,
	star = starNum,
	resType = ResMgr.ITEM_BG_UI --HERO_BG_UI
	})
	
	self.heroImage = display.newSprite()
	local cardWidth = self.cardBg:getContentSize().width
	local cardHeight = self.cardBg:getContentSize().height
	self.heroImage:setPosition(cardWidth / 2, cardHeight * 0.5)
	self.cardBg:addChild(self.heroImage)
	local resStr = data_item_item[data.resId].icon
	self.heroImage:setDisplayFrame(display.newSprite("equip/large/" .. resStr .. ".png"):getDisplayFrame())
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
	fontArma:setPosition(display.cx, display.cy)
	self.fontNode:addChild(fontArma)
	fontArma:setScale(2)
	fontArma:runAction(CCScaleTo:create(0.3, 1))
	local cardStateNames = {
	common:getLanguageString("@Order"),
	common:getLanguageString("@Life"),
	common:getLanguageString("@Attack"),
	common:getLanguageString("@ThingDefense"),
	common:getLanguageString("@LawDefense")
	}
	local keys = {
	"arr_hp",
	"arr_attack",
	"arr_defense",
	"arr_defenseM"
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
			befNum = self.curCls
			aftNum = self.curCls + 1
		else
			if self.curCls == 0 then
				befNum = self:getEquipByID(data.id).base[i - 1]
				aftNum = self:getEquipByID(data.id).base[i - 1] * (1 + data_equipquench_equipquench[data.pos][keys[i - 1]][self.curCls + 1] / 10000)
			else
				befNum = self:getEquipByID(data.id).base[i - 1] * (1 + data_equipquench_equipquench[data.pos][keys[i - 1]][self.curCls] / 10000)
				aftNum = self:getEquipByID(data.id).base[i - 1] * (1 + data_equipquench_equipquench[data.pos][keys[i - 1]][self.curCls + 1] / 10000)
			end
			befNum = math.ceil(befNum)
			aftNum = math.ceil(aftNum)
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
		size = 25,
		font = FONTS_NAME.font_fzcy,
		color = FONT_COLOR.GREEN_1,
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
	
	self:setTouchFunc(function(event)
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

function CulianLevelUpView:getEquipByID(id)
	for k, v in ipairs(game.player:getEquipments()) do
		if v._id == id then
			return v
		end
	end
	return nil
end

return CulianLevelUpView