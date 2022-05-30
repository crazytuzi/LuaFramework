local fightRes = {
normal = "#arena_exchange_btn.png",
pressed = "#arena_exchange_btn_gray.png",
disabled = "#arena_exchange_btn_gray.png"
}

local BiwuDuihuanItem = class("BiwuDuihuanItem", function()
	return CCTableViewCell:new()
end)

function BiwuDuihuanItem:create(param)
	self:setUpView(param)
	return self
end

function BiwuDuihuanItem:refresh(param)
	self._data = param.cellData
	self:removeAllChildren()
	local padding = {
	left = 20,
	right = 20,
	top = 20,
	down = 20
	}
	local viewSize = param.viewSize
	local listener = param.listener
	local index = param.index
	self:setContentSize(param.viewSize)
	local bng = display.newScale9Sprite("#arena_itemBg_4.png", 0, 0, cc.size(viewSize.width, viewSize.height))
	bng:setAnchorPoint(cc.p(0, 0))
	self:addChild(bng)
	self:setContentSize(param.viewSize)
	local contentBng = display.newScale9Sprite("#arena_item_inner_bg.png", 0, 0, cc.size(viewSize.width * 0.7, viewSize.height * 0.65))
	contentBng:setAnchorPoint(cc.p(0, 1))
	contentBng:setPosition(cc.p(viewSize.width * 0.02, viewSize.height * 0.92))
	bng:addChild(contentBng)
	local starIcon = display.newSprite("#rongyu_icon.png")
	starIcon:setPosition(cc.p(bng:getContentSize().width * 0.05, bng:getContentSize().height * 0.14))
	bng:addChild(starIcon)
	local nameDis = ui.newTTFLabel({
	text = common:getLanguageString("@Honor"),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(110, 0, 0)
	})
	nameDis:setAnchorPoint(cc.p(0, 0.5))
	nameDis:setPosition(bng:getContentSize().width * 0.09, bng:getContentSize().height * 0.14)
	bng:addChild(nameDis)
	local nameDis = ui.newTTFLabel({
	text = self._data.price,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(216, 30, 0)
	})
	nameDis:setAnchorPoint(cc.p(0, 0.5))
	nameDis:setPosition(bng:getContentSize().width * 0.22, bng:getContentSize().height * 0.14)
	bng:addChild(nameDis)
	local levelDisIcon = ui.newTTFLabel({
	text = common:getLanguageString("@NeedCharacterLevel") .. self._data.level,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(99, 47, 8)
	})
	levelDisIcon:setAnchorPoint(cc.p(0, 0.5))
	levelDisIcon:setPosition(bng:getContentSize().width * 0.5, bng:getContentSize().height * 0.14)
	bng:addChild(levelDisIcon)
	local levelDis = ui.newTTFLabel({
	text = self._data.level,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(216, 30, 0)
	})
	levelDis:setAnchorPoint(cc.p(0, 0.5))
	levelDis:setPosition(bng:getContentSize().width * 0.68, bng:getContentSize().height * 0.14)
	bng:addChild(levelDis)
	if game.player:getLevel() >= self._data.level then
		levelDisIcon:setVisible(false)
		levelDis:setVisible(false)
	end
	levelDis:setVisible(false)
	local icon = ResMgr.refreshIcon({
	id = self._data.item,
	resType = self._data.iconType,
	iconNum = self._data.num,
	isShowIconNum = false,
	numLblSize = 22,
	numLblColor = cc.c3b(0, 255, 0),
	numLblOutColor = cc.c3b(0, 0, 0),
	itemType = self._data.type
	})
	icon:setPosition(contentBng:getContentSize().width * 0.02, contentBng:getContentSize().height * 0.92)
	icon:setAnchorPoint(cc.p(0, 1))
	contentBng:addChild(icon)
	local nameColor = ResMgr.getItemNameColorByType(self._data.item, self._data.iconType)
	local contentTitleDis = ui.newTTFLabel({
	text = self._data.name,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = nameColor
	})
	contentTitleDis:setAnchorPoint(cc.p(0, 0.5))
	contentTitleDis:setPosition(contentBng:getContentSize().width * 0.25, contentBng:getContentSize().height * 0.9)
	contentBng:addChild(contentTitleDis)
	local tips = {
	common:getLanguageString("@Total"),
	common:getLanguageString("@Week"),
	common:getLanguageString("@ToDay")
	}
	local timeLiftDis = ui.newTTFLabel({
	text = common:getLanguageString("@CanExchange", tips[self._data.type1], self._data.num1),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 18,
	color = cc.c3b(6, 129, 18)
	})
	timeLiftDis:setPosition(contentBng:getContentSize().width * 0.25, contentBng:getContentSize().height * 0.75)
	timeLiftDis:setAnchorPoint(cc.p(0, 0.5))
	contentBng:addChild(timeLiftDis)
	local diviver = display.newScale9Sprite("#fenge.png", 0, 0, cc.size(contentBng:getContentSize().width * 0.5, contentBng:getContentSize().height * 0.03))
	diviver:setPosition(cc.p(contentBng:getContentSize().width * 0.25, contentBng:getContentSize().height * 0.65))
	diviver:setAnchorPoint(cc.p(0, 0))
	contentBng:addChild(diviver)
	local text = self._data.dis
	local contentDis = CCLabelTTF:create(text, FONTS_NAME.font_fzcy, 20, cc.size(contentBng:getContentSize().width * 0.7, contentBng:getContentSize().height * 0.65), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	contentDis:setColor(cc.c3b(99, 47, 8))
	contentDis:setPosition(contentBng:getContentSize().width * 0.25, contentBng:getContentSize().height * 0.33)
	contentDis:setAnchorPoint(cc.p(0, 0.5))
	contentBng:addChild(contentDis)
	local titleBng = display.newScale9Sprite("#arena_name_bg_4.png", 0, 0, cc.size(viewSize.width - padding.left - padding.right, viewSize.height * 0.18))
	titleBng:setAnchorPoint(cc.p(0, 0))
	titleBng:setPosition(cc.p(viewSize.width * 0.02, viewSize.height * 0.7))
	bng:addChild(titleBng)
	titleBng:setVisible(false)
	local nameDis = ui.newTTFLabel({
	text = self._data.name,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(0, 219, 52)
	})
	nameDis:setAnchorPoint(cc.p(0, 0.5))
	nameDis:setPosition(titleBng:getContentSize().width * 0.4, titleBng:getContentSize().height * 0.5)
	titleBng:addChild(nameDis)
	local fightDis = ui.newTTFLabel({
	text = string.format("（" .. tips[self._data.type1] .. "可兑换%d次" .. "）", self._data.num1),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(0, 219, 52)
	})
	fightDis:setAnchorPoint(cc.p(0, 0.5))
	fightDis:setPosition(titleBng:getContentSize().width * 0.95, titleBng:getContentSize().height * 0.5)
	titleBng:addChild(fightDis)
	local arrowBng = display.newSprite("#arena_lv_bg_4.png")
	arrowBng:setAnchorPoint(cc.p(0, 0))
	titleBng:addChild(arrowBng)
	local levelDis = ui.newTTFLabel({
	text = "LV:" .. self._data.level,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(0, 219, 52)
	})
	levelDis:setAnchorPoint(cc.p(0, 0.5))
	levelDis:setPosition(arrowBng:getContentSize().width * 0.2, arrowBng:getContentSize().height * 0.5)
	arrowBng:addChild(levelDis)
	local heroBng = display.newScale9Sprite("#arena_itemInner_bg_1.png", 0, 0, cc.size(viewSize.width * 0.7, viewSize.height * 0.65))
	heroBng:setVisible(false)
	heroBng:setAnchorPoint(cc.p(0, 0))
	heroBng:setPosition(cc.p(viewSize.width * 0.01, viewSize.height * 0.05))
	bng:addChild(heroBng)
	
	
	local btn = require("utility.MyLayer").new({
	size = icon:getContentSize(),
	swallow = true,
	parent = icon,
	touchHandler = function (event)
		if event.name == EventType.ended then
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = self._data.item,
			type = self._data.type,
			name = self._data.name,
			describe = self._data.dis
			})
			CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
		end
	end
	})
	
	local jiangliBnt = ResMgr.newNormalButton(	{
	scaleBegan = 0.9,
	sprite = fightRes.normal,
	handle = function()
		if game.player:getLevel() < self._data.level then
			show_tip_label(common:getLanguageString("@ExchangeCondition") .. tostring(self._data.level) .. common:getLanguageString("@ExchangeConditionLevel"))
		elseif listener then
			listener(index)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end
	})
	jiangliBnt:align(display.CENTER, viewSize.width * 0.85, viewSize.height * 0.5)
	bng:addChild(jiangliBnt)
	if self._data.num1 == 0 then
		jiangliBnt:replaceNormalButton(fightRes.disabled)
		jiangliBnt:setTouchEnabled(false)
	end
end

function BiwuDuihuanItem:setUpView(param)
	self:refresh(param)
end

function BiwuDuihuanItem:createHeroView(index, node)
	local i = index
	local marginTop = 10
	local marginLeft = 10
	local offset = 100
	local icon = ResMgr.refreshIcon({
	id = 1,
	resType = 3,
	iconNum = 11,
	isShowIconNum = true,
	numLblSize = 22,
	numLblColor = cc.c3b(0, 255, 0),
	numLblOutColor = cc.c3b(0, 0, 0)
	})
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setPosition(node:getContentSize().width / 5 * i, node:getContentSize().height / 2)
	icon:setAnchorPoint(cc.p(0.5, 0.5))
	node:addChild(icon)
	return icon
end

function BiwuDuihuanItem:refreshHeroIcons()
end

return BiwuDuihuanItem