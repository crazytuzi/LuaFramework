-- 战斗底座解锁界面中的一项
local HeroSoulBattleBaseItem = class("HeroSoulBattleBaseItem", function()
	return CCSItemCellBase:create("ui_layout/herosoul_BattleBaseItem.json")
end)

require("app.cfg.ksoul_fight_base_info")

function HeroSoulBattleBaseItem:ctor()
	self._baseImg 	= self:getImageViewByName("Image_BattleBase")
	self._nameLabel = self:getLabelByName("Label_BattleBaseName")

	-- create stroke
	self:enableLabelStroke("Label_BattleBaseName", Colors.strokeBrown, 1)

	
	self:setTouchEnabled(true)
end

function HeroSoulBattleBaseItem:update(baseId, isUnlocked)
	local info = ksoul_fight_base_info.get(baseId)

	-- battle base image
	local imgPath = "battle/base/base_" .. info.own_image .. ".png"
	self._baseImg:loadTexture(imgPath)

	-- battle base name
	self._nameLabel:setText(info.name)
	self._nameLabel:setColor(Colors.qualityColors[info.quality])

	-- lock,todo
	self:showWidgetByName("Image_Lock", not isUnlocked)
end

function HeroSoulBattleBaseItem:onSelect()
	self:showWidgetByName("Image_Light", true)
end

function HeroSoulBattleBaseItem:Deselect()
	self:showWidgetByName("Image_Light", false)
end

return HeroSoulBattleBaseItem