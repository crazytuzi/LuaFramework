local HeroSoulBatchDecompose = class("HeroSoulBatchDecompose", UFCCSModelLayer)

require("app.cfg.ksoul_info")
local BagConst = require("app.const.BagConst")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

-- 列表的一些宏
HeroSoulBatchDecompose.ITEM_ORIGIN_OFFSET= ccp(56, 60)
HeroSoulBatchDecompose.ITEM_GAP_HOR		= 118
HeroSoulBatchDecompose.ITEM_GAP_VER		= 140
HeroSoulBatchDecompose.ITEMS_PER_LINE	= 4

function HeroSoulBatchDecompose.show(needlessIds)
	local layer = HeroSoulBatchDecompose.new("ui_layout/herosoul_BatchDecompose.json", Colors.modelColor, needlessIds)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroSoulBatchDecompose:ctor(jsonFile, color, needlessIds)
	self._richText	= nil			-- 说明文字的rich text
	self._soulList	= needlessIds 	-- 将要分解的将灵列表
	self._soulNum 	= 0 			-- 总共要分解的将灵数量
	self._getPoint	= 0     		-- 分解能够得到的灵玉

	self:_calcSoulNumAndPoints()

	self.super.ctor(self, jsonFile, color)
end

function HeroSoulBatchDecompose:onLayerLoad()
	-- create the rich text for explanation text
	local parent 	= self:getWidgetByName("Image_Bg")
	local template	= self:getLabelByName("Label_Explain")
	local content	= G_lang:get("LANG_HERO_SOUL_DECOMPOSE_EXPLAIN")
	self._richText	= GlobalFunc.createRichTextFromTemplate(template, parent, content, Colors.strokeBrown)

	-- label stroke
	self:enableLabelStroke("Label_1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SoulNum", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_2", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SoulPoint", Colors.strokeBrown, 1)

	-- detail info
	self:showTextWithLabel("Label_SoulNum", tostring(self._soulNum))
	self:showTextWithLabel("Label_SoulPoint", tostring(self._getPoint))
	G_GlobalFunc.centerContent(self:getPanelByName("Panel_Detail"))

	-- init scroll list
	self:_initSoulList()

	-- register button click events
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
end

function HeroSoulBatchDecompose:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- bounce in the layer
	EffectSingleMoving.run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

-- calculate total soul points to get
function HeroSoulBatchDecompose:_calcSoulNumAndPoints()
	for i, v in ipairs(self._soulList) do
		local soulInfo = ksoul_info.get(v.id)
		self._soulNum  = self._soulNum + v.num
		self._getPoint = self._getPoint + soulInfo.ksoul_point * v.num
	end
end

-- initialize soul list
function HeroSoulBatchDecompose:_initSoulList()
	local scrollView = self:getScrollViewByName("ScrollView_Souls")

	-- create icons
	local itemArr = {}
	for i, v in ipairs(self._soulList) do
		local soulInfo = ksoul_info.get(v.id)

		-- icon background
		local bg = ImageView:create()
		bg:loadTexture("putong_bg.png", UI_TEX_TYPE_PLIST)
		itemArr[#itemArr + 1] = bg

		-- head
		local head = ImageView:create()
		local headIcon = G_Path.getKnightIcon(soulInfo.res_id)
		head:loadTexture(headIcon)
		bg:addChild(head)

		-- quality frame
		local qualityFrame = ImageView:create()
		local framePath = G_Path.getEquipColorImage(soulInfo.quality, G_Goods.TYPE_HERO_SOUL)
		qualityFrame:loadTexture(framePath)
		bg:addChild(qualityFrame)

		-- count
		local count = Label:create()
		count:setFontName(G_Path.getBattleLabelFont())
		count:setFontSize(20)
		count:setAnchorPoint(ccp(1, 0.5))
		count:setColor(Colors.lightColors.TITLE_02)
		count:setPositionXY(25, -65)
		count:setText(G_lang:get("LANG_BAG_ITEM_NUM"))
		bg:addChild(count)

		local num = Label:create()
		num:setFontName(G_Path.getBattleLabelFont())
		num:setFontSize(20)
		num:setAnchorPoint(ccp(0, 0.5))
		num:setColor(Colors.lightColors.DESCRIPTION)
		num:setPositionXY(15, -65)
		num:setText(tostring(v.num or 0))
		bg:addChild(num)
	end

	-- adjust the inner size of the scroll view and add labels
	local scrollSize = scrollView:getSize()
	local totalLine = math.ceil(#self._soulList / HeroSoulBatchDecompose.ITEMS_PER_LINE)
	local innerHeight = HeroSoulBatchDecompose.ITEM_GAP_VER * totalLine
	innerHeight = math.max(innerHeight, scrollSize.height)

	local oldPosY = scrollView:getPositionY()
	local oldHeight = scrollSize.height
	scrollView:setInnerContainerSize(CCSize(scrollSize.width, innerHeight))

	for i, v in ipairs(itemArr) do
		-- calculate position
		local line = math.ceil(i / HeroSoulBatchDecompose.ITEMS_PER_LINE)
		local col  = i % HeroSoulBatchDecompose.ITEMS_PER_LINE
		if col == 0 then col = HeroSoulBatchDecompose.ITEMS_PER_LINE end

		local x = HeroSoulBatchDecompose.ITEM_ORIGIN_OFFSET.x + HeroSoulBatchDecompose.ITEM_GAP_HOR * (col - 1)
		local y = innerHeight - HeroSoulBatchDecompose.ITEM_ORIGIN_OFFSET.y - HeroSoulBatchDecompose.ITEM_GAP_VER * (line - 1)
		v:setPositionXY(x, y)

		scrollView:addChild(v)
	end
end

function HeroSoulBatchDecompose:_onClickConfirm()
	G_HandlersManager.heroSoulHandler:sendDecomposeSoul(self._soulList)
	self:animationToClose()
end

function HeroSoulBatchDecompose:_onClickClose()
	self:animationToClose()
end

return HeroSoulBatchDecompose