local HeroSoulBagItem = class("HeroSoulBagItem", function()
	return CCSItemCellBase:create("ui_layout/herosoul_BagItem.json")
end)

require("app.cfg.ksoul_info")
require("app.cfg.ksoul_group_info")
local HeroSoulInfoLayer = require("app.scenes.herosoul.HeroSoulInfoLayer")
local HeroSoulDecomposeLayer = require("app.scenes.herosoul.HeroSoulDecomposeLayer")

function HeroSoulBagItem:ctor()
	self._soulId = 0

	self:enableLabelStroke("Label_SoulName", Colors.strokeBrown, 1)
	self:registerBtnClickEvent("Button_Decompose", handler(self, self._onClickDecompose))
	self:registerBtnClickEvent("Button_View", handler(self, self._onClickView))

	self:registerWidgetClickEvent("Image_QualityFrame", function()
	    require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_HERO_SOUL, self._soulId)
	end)
end

function HeroSoulBagItem:update(soulId, needless)
	self._soulId = soulId
	local soulInfo = ksoul_info.get(soulId)

	-- head icon
	local iconPath = G_Path.getKnightIcon(soulInfo.res_id)
	self:getImageViewByName("Image_Head"):loadTexture(iconPath)

	-- quality bg and quality frame
	local bgPath = G_Path.getEquipIconBack(soulInfo.quality)
	self:getImageViewByName("Image_QualityBg"):loadTexture(bgPath, UI_TEX_TYPE_PLIST)

	local framePath, texType = G_Path.getEquipColorImage(soulInfo.quality, G_Goods.TYPE_HERO_SOUL)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(framePath, texType)

	-- name
	local nameLabel = self:getLabelByName("Label_SoulName")
	nameLabel:setText(soulInfo.name)
	nameLabel:setColor(Colors.qualityColors[soulInfo.quality])

	-- count
	local count = G_Me.heroSoulData:getSoulNum(soulId)
	self:showTextWithLabel("Label_CurNum", tostring(count))

	-- activated chart ID
	local charts = G_Me.heroSoulData:getAllChartsBySoul(soulId)
	local activatedNum = 0
	for i, v in ipairs(charts) do
		if G_Me.heroSoulData:isChartActivated(v) then
			activatedNum = activatedNum + 1
		end
	end
	self:showTextWithLabel("Label_ActivatedNum", activatedNum .. "/" .. #charts)

	self:showWidgetByName("Label_Suggest", needless)
end

function HeroSoulBagItem:_onClickDecompose()
	HeroSoulDecomposeLayer.show(self._soulId)
end

function HeroSoulBagItem:_onClickView()
	HeroSoulInfoLayer.show(self._soulId)
end

return HeroSoulBagItem