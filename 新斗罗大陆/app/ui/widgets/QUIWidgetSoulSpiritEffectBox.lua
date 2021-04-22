--
-- Author: Kumo.Wang
-- 魂靈养成悬浮Box
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritEffectBox = class("QUIWidgetSoulSpiritEffectBox", QUIWidget)

local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetSoulSpiritEffectBox:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_EffectBox.ccbi"
	local callBacks = {}
	QUIWidgetSoulSpiritEffectBox.super.ctor(self, ccbFile, callBacks, options)

	self:_resetAll()
end

function QUIWidgetSoulSpiritEffectBox:_resetAll()
	self:_hideAllColor()
end

function QUIWidgetSoulSpiritEffectBox:setInfo(id, isDonotShowColorBg)
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)
	self._icon = QUIWidgetSoulSpiritHead.new()
	self._ccbOwner.node_icon:removeAllChildren()
    self._ccbOwner.node_icon:addChild(self._icon)
    self._icon:setInfo(soulSpiritInfo)

    if not isDonotShowColorBg then
    	local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(id)
	    local _colorIndex = 4
		_colorIndex = characterConfig.colour
		self:_setColor(_colorIndex)
	end
end

function QUIWidgetSoulSpiritEffectBox:setStarNum( num )
	if self._icon then
    	self._icon:setStar(num)
    end
end

function QUIWidgetSoulSpiritEffectBox:_setColor(index)
	if index ~= nil then
		self:_hideAllColor()
		self._ccbOwner["break"..index]:setVisible(true)
	end
end 

function QUIWidgetSoulSpiritEffectBox:_hideAllColor()
	for i = 1, 7, 1 do
		self._ccbOwner["break"..i]:setVisible(false)
	end
end

return QUIWidgetSoulSpiritEffectBox