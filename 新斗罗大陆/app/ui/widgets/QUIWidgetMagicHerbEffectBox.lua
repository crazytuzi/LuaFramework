--
-- Author: Kumo.Wang
-- 仙品养成悬浮Box
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbEffectBox = class("QUIWidgetMagicHerbEffectBox", QUIWidget)

local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")

function QUIWidgetMagicHerbEffectBox:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_EffectBox.ccbi"
	local callBacks = {}
	QUIWidgetMagicHerbEffectBox.super.ctor(self, ccbFile, callBacks, options)

	self:_resetAll()
end

function QUIWidgetMagicHerbEffectBox:_resetAll()
	self:_hideAllColor()
end

function QUIWidgetMagicHerbEffectBox:setInfo(sid, isDonotShowColorBg)
	self._icon = QUIWidgetMagicHerbBox.new()
	self._ccbOwner.node_icon:removeAllChildren()
    self._ccbOwner.node_icon:addChild(self._icon)
    self._icon:setInfo(sid)

    if not isDonotShowColorBg then
	    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
	    local _colorIndex = 4
		_colorIndex = magicHerbItemInfo.colour
		self:_setColor(_colorIndex)
	end
end

function QUIWidgetMagicHerbEffectBox:getNodeIcon()
	return self._ccbOwner.node_icon
end

function QUIWidgetMagicHerbEffectBox:hideName()
	if self._icon then
    	self._icon:hideName()
    end
end

function QUIWidgetMagicHerbEffectBox:setStarNum( num )
	if self._icon then
    	self._icon:setStarNum(num)
    end
end

function QUIWidgetMagicHerbEffectBox:_setColor(index)
	if index ~= nil then
		self:_hideAllColor()
		self._ccbOwner["break"..index]:setVisible(true)
	end
end 

function QUIWidgetMagicHerbEffectBox:_hideAllColor()
	for i = 1, 7, 1 do
		self._ccbOwner["break"..i]:setVisible(false)
	end
end

return QUIWidgetMagicHerbEffectBox