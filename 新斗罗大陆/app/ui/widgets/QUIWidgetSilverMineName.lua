--
-- Author: Kumo
-- Date: 2014-11-24 16:39:45
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineName = class("QUIWidgetSilverMineName", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")

function QUIWidgetSilverMineName:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_name.ccbi"
	local callBacks = {}
	QUIWidgetSilverMineName.super.ctor(self, ccbFile, callBacks, options)

    self._nameAni = "normal"
    self._ccbam = nil
    self._ccbOwner.tf_mine_name_short:setString("")
    self._ccbOwner.tf_mine_name_long:setString("")

    self:_init()
end

function QUIWidgetSilverMineName:onEnter()
end

function QUIWidgetSilverMineName:onExit()   
end

function QUIWidgetSilverMineName:_init()
    self._ccbam = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    self._ccbam:runAnimationsForSequenceNamed(self._nameAni)
    self._ccbam:connectScriptHandler(function(str)
            if str == "show" then
                self._nameAni = "normal"
                self._ccbam:runAnimationsForSequenceNamed(self._nameAni)
            end
        end)
end

function QUIWidgetSilverMineName:setName( name, isLong )
    self._name = name
    if isLong then
        self._ccbOwner.tf_mine_name_short:setString("")
        self._ccbOwner.tf_mine_name_long:setString(name)
    else
        self._ccbOwner.tf_mine_name_short:setString(name)
        self._ccbOwner.tf_mine_name_long:setString("")
    end
end

function QUIWidgetSilverMineName:getName()
    return self._name
end

function QUIWidgetSilverMineName:stop()
    self._nameAni = "normal"
    self._ccbam:runAnimationsForSequenceNamed(self._nameAni)
end

function QUIWidgetSilverMineName:show()
    self._nameAni = "show"
    self._ccbam:runAnimationsForSequenceNamed(self._nameAni)
end

return QUIWidgetSilverMineName