-- HeroSoulDecomposeLayer 分解将灵面板
-- This layer shows some options to decide
-- whether to decompose a hero-soul and how many to decompose.
local HeroSoulDecomposeLayer = class("HeroSoulDecomposeLayer", UFCCSModelLayer)

require("app.cfg.ksoul_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function HeroSoulDecomposeLayer.show(soulId)
	local layer = HeroSoulDecomposeLayer.new("ui_layout/herosoul_DecomposeLayer.json", Colors.modelColor, soulId)
	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function HeroSoulDecomposeLayer:ctor(jsonFile, color, soulId)
	self._soulId 	= soulId
	self._soulInfo 	= ksoul_info.get(soulId)
	self._ownNum 	= G_Me.heroSoulData:getSoulNum(self._soulId) -- 拥有的数量
	self._curNum 	= 1 -- 当前分解的数量，默认1

	self.super.ctor(self, jsonFile, color)
end

function HeroSoulDecomposeLayer:onLayerLoad()
	-- initialize soul info
	self:_initSoulInfo()

	-- label stroke
	self:enableLabelStroke("Label_SoulName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CurNum", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Add", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_AddTen", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Sub", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SubTen", Colors.strokeBrown, 1)

	-- register button click events
	self:registerBtnClickEvent("Button_AddOne", handler(self, self._onClickAddOne))
	self:registerBtnClickEvent("Button_AddTen", handler(self, self._onClickAddTen))
	self:registerBtnClickEvent("Button_SubOne", handler(self, self._onClickSubOne))
	self:registerBtnClickEvent("Button_SubTen", handler(self, self._onClickSubTen))
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
end

function HeroSoulDecomposeLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- bounce in the layer
	EffectSingleMoving.run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	-- update soul point number to get
	self:_updateSoulPoint(0)
end

function HeroSoulDecomposeLayer:_initSoulInfo()
	-- head icon
	local iconPath = G_Path.getKnightIcon(self._soulInfo.res_id)
	self:getImageViewByName("Image_Head"):loadTexture(iconPath)

	-- quality bg and quality frame
	local bgPath = G_Path.getEquipIconBack(self._soulInfo.quality)
	self:getImageViewByName("Image_QualityBg"):loadTexture(bgPath, UI_TEX_TYPE_PLIST)

	local framePath = G_Path.getEquipColorImage(self._soulInfo.quality, G_Goods.TYPE_HERO_SOUL)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(framePath)

	-- name
	local nameLabel = self:getLabelByName("Label_SoulName")
	nameLabel:setText(self._soulInfo.name)
	nameLabel:setColor(Colors.qualityColors[self._soulInfo.quality])

	-- own num
	local strNum = G_lang:get("LANG_GOODS_NUM", {num = self._ownNum})
	self:showTextWithLabel("Label_OwnNum", strNum)
end

-- 刷新分解获得的灵玉数量
function HeroSoulDecomposeLayer:_updateSoulPoint(delta)
	self._curNum = self._curNum + delta
	self._curNum = math.max(self._curNum, 1)
	self._curNum = math.min(self._curNum, self._ownNum)
	self:showTextWithLabel("Label_CurNum", tostring(self._curNum))

	local unitNum = self._soulInfo.ksoul_point
	local soulPoint = unitNum * self._curNum
	self:showTextWithLabel("Label_GetNum", tostring(soulPoint))
end

function HeroSoulDecomposeLayer:_onClickAddOne()
	self:_updateSoulPoint(1)
end

function HeroSoulDecomposeLayer:_onClickAddTen()
	self:_updateSoulPoint(10)
end

function HeroSoulDecomposeLayer:_onClickSubOne()
	self:_updateSoulPoint(-1)
end

function HeroSoulDecomposeLayer:_onClickSubTen()
	self:_updateSoulPoint(-10)
end

function HeroSoulDecomposeLayer:_onClickConfirm()
	local soulList = { {id = self._soulId, num = self._curNum} }
	G_HandlersManager.heroSoulHandler:sendDecomposeSoul(soulList)
	self:animationToClose()
end

function HeroSoulDecomposeLayer:_onClickClose()
	self:animationToClose()
end

return HeroSoulDecomposeLayer