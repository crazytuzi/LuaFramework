local CrossPVPBetResult = class("CrossPVPBetResult", UFCCSNormalLayer)

require("app.cfg.item_info")
require("app.cfg.knight_info")
require("app.cfg.crosspvp_flower_award_info")
local CrossPVPConst = require("app.const.CrossPVPConst")
local Goods = require("app.setting.Goods")
local DropInfo = require("app.scenes.common.dropinfo.DropInfo")

local AWARD_ICON_INTERVAL = 5

function CrossPVPBetResult.create(betType)
	return CrossPVPBetResult.new("ui_layout/crosspvp_BetResult.json", nil, betType)
end

function CrossPVPBetResult:ctor(jsonFile, func, betType)
	self._betType = betType
	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPBetResult:onLayerLoad()
	self:enableLabelStroke("Label_AwardTitle", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Name", Colors.strokeBrown, 1)

	self:registerBtnClickEvent("Button_Get", handler(self, self._onClickGet))

	self:_initContent()
end

function CrossPVPBetResult:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_AWARD, self._onRcvBetAward, self)
end

-- initialize label contents
function CrossPVPBetResult:_initContent()
	local isFlowerAward = self._betType == CrossPVPConst.BET_FLOWER

	-- title
	local title = G_lang:get(isFlowerAward and "LANG_CROSS_PVP_FLOWER_AWARD" or "LANG_CROSS_PVP_EGG_AWARD")
	self:showTextWithLabel("Label_AwardTitle", title)

	-- get bet target
	local betTarget = nil
	if isFlowerAward then
		betTarget = G_Me.crossPVPData:getPrevFlowerTarget()
	else
		betTarget = G_Me.crossPVPData:getPrevEggTarget()
	end

	if betTarget then
		-- set name
		local knightInfo = knight_info.get(betTarget.main_role)
		local nameLabel = self:getLabelByName("Label_Name")
		nameLabel:setText(betTarget.name)
		nameLabel:setColor(Colors.qualityColors[knightInfo.quality])

		-- set rank
		local strRank = isFlowerAward and tostring(betTarget.lastRank) or G_lang:get("LANG_NOT_IN_RANKING_LIST")
		self:showTextWithLabel("Label_RankNum", strRank)

		-- what do you bet, flower or egg?
		local betThing = G_lang:get(isFlowerAward and "LANG_CROSS_PVP_BET_FLOWER" or "LANG_CROSS_PVP_BET_EGG")
		self:showTextWithLabel("Label_BetThing", betThing .. "：")
		self:showTextWithLabel("Label_BetNum", tostring(betTarget.betByMe))

		-- has award to get?
		local hasAward = false
		if isFlowerAward then
			hasAward = G_Me.crossPVPData:hasFlowerAward()
		else
			hasAward = G_Me.crossPVPData:hasEggAward()
		end

		self:showWidgetByName("Button_Get", hasAward)
		self:showWidgetByName("Image_GetTag", not hasAward)
	else
		self:showWidgetByName("Panel_Detail", false)
		self:showWidgetByName("Panel_Award", false)
		self:showWidgetByName("Button_Get", false)
		self:showWidgetByName("Image_GetTag", false)
		self:showWidgetByName("Label_NotBet", true)

		local notBetHint = G_lang:get(isFlowerAward and "LANG_CROSS_PVP_NOT_BET_FLOWER" or "LANG_CROSS_PVP_NOT_BET_EGG")
		self:showTextWithLabel("Label_NotBet", notBetHint)
	end

	-- initialize the scroll view of awards
	if betTarget then
		self:_initAwards(betTarget.betByMe)
	end
end

-- initialize scroll view of awards
function CrossPVPBetResult:_initAwards(betNum)
	self._scrollView = self:getScrollViewByName("ScrollView_Awards")

	-- find the matching award
	local len = crosspvp_flower_award_info.getLength()
	local awardInfo = nil
	for i = 1, len do
		local v = crosspvp_flower_award_info.indexOf(i)
		if v.type == self._betType and v.min_size <= betNum and v.max_size >= betNum then
			awardInfo = v
			break
		end
	end
	
	-- initialize award info icons
	if awardInfo then
		local prevIconX = 0
		local scale = 0.8
		local size = self._scrollView:getContentSize()
		local innerWidth = size.width
		for i = 1, 4 do
			local goodsInfo = Goods.convert(awardInfo["award_type_" .. i], awardInfo["award_value_" .. i])
			if i == 4 and goodsInfo then
				innerWidth = size.width + 20
			end
			if not goodsInfo then break end
			
			-- create icon back frame
			local iconBg = ImageView:create()
			iconBg:loadTexture("putong_bg.png", UI_TEX_TYPE_PLIST)
			iconBg:setScale(scale)
			self._scrollView:addChild(iconBg)

			local width = iconBg:getContentSize().width * scale
			local height = iconBg:getContentSize().height * scale
			iconBg:setPositionX(i == 1 and width / 2 or (prevIconX + width + AWARD_ICON_INTERVAL))
			iconBg:setPositionY(height / 2)
			prevIconX = iconBg:getPositionX()

			-- award icon
			local icon = ImageView:create()
			icon:loadTexture(goodsInfo.icon)
			iconBg:addChild(icon)

			-- quality frame
			local frame = Button:create()
			local qualityTex = G_Path.getEquipColorImage(goodsInfo.quality, goodsInfo.type)
			frame:loadTextureNormal(qualityTex, UI_TEX_TYPE_PLIST)
			frame:setTouchEnabled(true)
			frame:setName("Button_" .. self._betType .. "_" .. i)
			iconBg:addChild(frame)

			-- number
			local label = Label:create()
			label:setAnchorPoint(ccp(1, 0.5))
			label:setColor(Colors.darkColors.DESCRIPTION)
			label:setFontSize(20)
			label:createStroke(Colors.strokeBrown, 1)
			label:setText("x" .. awardInfo["award_size_" .. i])
			label:setPositionXY(44, -35)
			iconBg:addChild(label)

			-- register click event
			frame.itemType  = awardInfo["award_type_" .. i]
			frame.itemValue = awardInfo["award_value_" .. i]
			self:registerBtnClickEvent(frame:getName(), handler(self, self._onClickAward))
		end
		self._scrollView:setInnerContainerSize(CCSizeMake(innerWidth, size.height))
	end
end

function CrossPVPBetResult:_onClickGet()
	G_HandlersManager.crossPVPHandler:sendGetBetAward(self._betType)
end

function CrossPVPBetResult:_onClickAward(widget)
	DropInfo.show(widget.itemType, widget.itemValue)
end

function CrossPVPBetResult:_onRcvBetAward(data)
	if data.type == self._betType then
		-- show award info
		local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
		uf_notifyLayer:getModelNode():addChild(layer)

		-- hide the "get" button
		self:showWidgetByName("Button_Get", false)
		self:showWidgetByName("Image_GetTag", true)
	end
end

return CrossPVPBetResult