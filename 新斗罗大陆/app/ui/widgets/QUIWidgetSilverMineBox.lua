--
-- Author: Kumo
-- Date: 2014-11-24 16:39:45
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineBox = class("QUIWidgetSilverMineBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")

function QUIWidgetSilverMineBox:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_Box.ccbi"
	local callBacks = {}
	QUIWidgetSilverMineBox.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetSilverMineBox:onEnter()
end

function QUIWidgetSilverMineBox:onExit()   
end

function QUIWidgetSilverMineBox:update( id, type, count, isGoldPickaxe )
    if type == ITEM_TYPE.GEMSTONE_PIECE then
        self._item = QUIWidgetGemStonePieceBox.new()
        if count == 0 then
            self._item:setGoodsInfo(id, type, count, false, false)
        else
            self._item:setGoodsInfo(id, type, count, true, false)
        end
    else
        self._item = QUIWidgetItemsBox.new()
        self._item:setGoodsInfo(id, type, count)
    end
    self._item:setPromptIsOpen(true)
    self._ccbOwner.node_box:removeAllChildren()
    self._ccbOwner.node_box:addChild(self._item)

    if isGoldPickaxe then
        self._ccbOwner.sp_goldPickaxe:setVisible(true)
    else
        self._ccbOwner.sp_goldPickaxe:setVisible(false)
    end
end

function QUIWidgetSilverMineBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilverMineBox:getItemBox()
    return self._item
end

function QUIWidgetSilverMineBox:getCurScale()

    return self._ccbOwner.node_scale:getScale() or 1
end

function QUIWidgetSilverMineBox:setCurScale(scale_)
    self._ccbOwner.node_scale:setScale(scale_)
end

return QUIWidgetSilverMineBox