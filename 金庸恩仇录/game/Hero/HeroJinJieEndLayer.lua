local data_shentong_shentong = require("data.data_shentong_shentong")
local data_talent_talent = require("data.data_talent_talent")

local HeroJinJieEndLayer = class("HeroJinJieEndLayer", function()
	display.addSpriteFramesWithFile("ui/ui_herolist_v2.plist", "ui/ui_herolist_v2.png")
	display.addSpriteFramesWithFile("ui/ui_equipV2.plist", "ui/ui_equipV2.png")
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 200))
end)

function HeroJinJieEndLayer:onExit()
	TutoMgr.removeBtn("jinjie_end_layer_shentong_name")
end

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

function HeroJinJieEndLayer:ctor(param)
	self.data = param.data
	self.removeListener = param.removeListener
	self:setNodeEventEnabled(true)
	self:setContentSize(cc.size(display.width, display.height))
	local befData = self.data["2"]
	local nextData = self.data["3"]
	local stData = self.data["9"]
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
	self.cardNode:setPosition(display.width / 2, display.height * 0.8)
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
	self.heroImage:setDisplayFrame(ResMgr.getHeroFrame(ResID, Cls))
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
		bgEffect:setPosition(display.width / 2, display.height * 0.8)
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
	fontArma:setPosition(display.width / 2, display.height * 0.5)
	self.fontNode:addChild(fontArma)
	fontArma:setScale(2)
	fontArma:runAction(CCScaleTo:create(0.3, 1))
	local tal = ResMgr.getCardData(ResID).talent
	printf("======= %d", ResID)
	local tianFuPng = display.newSprite("#talent_unlock.png")
	tianFuPng:setPosition(display.width * 0.3 - 40, 0.43 * display.height)
	tianFuPng:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(tianFuPng)
	tianFuPng:setOpacity(0)
	local unlockSt = {}
	if stData ~= nil then
	for talIndex, v in ipairs(tal) do
		local st = data_shentong_shentong[v]
		for k, cls in ipairs(st.arr_cond) do
			printf("cls = %d, curCls = %d", cls, self.curCls)
			if cls == self.curCls then
				if stData[talIndex] then
					do
						local shentongData = data_shentong_shentong[data_talent_talent[stData[talIndex]].shentong]
						table.insert(unlockSt, {
						id = stData[talIndex],
						t = shentongData.type
						})
					end
					break
				end
				table.insert(unlockSt, {
				id = st.arr_talent[k],
				t = st.type
				})
				break
			end
		end
	end
	end
	if #unlockSt > 0 then
		tianFuPng:setOpacity(255)
		local image_bg_name = "image_name/talent_image/bg_atk.png"
		local tal_bg = display.newSprite(image_bg_name)
		tal_bg:setOpacity(0)
		tal_bg:setPosition(tianFuPng:getPositionX() + tianFuPng:getContentSize().width + tal_bg:getContentSize().width / 2.5, tianFuPng:getPositionY())
		self:addChild(tal_bg)
		local offsetX = 26
		for k, v in ipairs(unlockSt) do
			local label = ui.newTTFLabelWithShadow({
			text = data_talent_talent[v.id].name,
			font = FONTS_NAME.font_fzcy,
			size = 30,
			align = ui.TEXT_ALIGN_LEFT,
			color = ST_COLOR[v.t],
			shadowColor = display.COLOR_BLACK,
			})
			label:setPosition(offsetX, tal_bg:getContentSize().height / 2 - 5)
			label:align(display.LEFT_CENTER)
			tal_bg:addChild(label)
			offsetX = offsetX + label:getContentSize().width + 10
		end
		TutoMgr.addBtn("jinjie_end_layer_shentong_name", tal_bg)
	end
	
	local arr_point = ResMgr.getCardData(ResID).arr_point
	if arr_point ~= nil then
	local shentongLabel = ui.newTTFLabel({
	text = common:getLanguageString("@SuperSkillPointGet", ResMgr.getCardData(ResID).arr_point[self.curCls]),
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.ORANGE,
	size = 30
	})
	if tianFuPng:getOpacity() == 0 then
		shentongLabel:setPosition(tianFuPng:getContentSize().width - 18, -shentongLabel:getContentSize().height * 0.55 + 30)
	else
		shentongLabel:setPosition(tianFuPng:getContentSize().width - 18, -shentongLabel:getContentSize().height * 0.55)
	end
	tianFuPng:addChild(shentongLabel)
	end
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
			befNum = befData.base[i - 1]
			aftNum = nextData.base[i - 1]
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
	end,
	1)
	require("game.Bag.BagCtrl").setRequest(false)
end

return HeroJinJieEndLayer