--
-- Author: Kumo.Wang
-- 大富翁遥控骰子选择界面Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMonopolySelectCheatCell = class("QUIWidgetMonopolySelectCheatCell", QUIWidget)

QUIWidgetMonopolySelectCheatCell.Selected = "QUIWIDGETMONOPOLYSELECTCHEATCELL_SELECTED"

function QUIWidgetMonopolySelectCheatCell:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_cheat_select.ccbi"
	local callBacks = {}
	QUIWidgetMonopolySelectCheatCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMonopolySelectCheatCell:onEnter()
end

function QUIWidgetMonopolySelectCheatCell:onExit()
end

function QUIWidgetMonopolySelectCheatCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetMonopolySelectCheatCell:setSelectState( isSelected )
	self._ccbOwner.sp_selected_on:setVisible(isSelected)
	self._ccbOwner.sp_selected_off:setVisible(not isSelected)
end

function QUIWidgetMonopolySelectCheatCell:setInfo(info)
	self._itemId = info.itemId

	local config = info.config
	local tbl = string.split(config.target_number, ",")
	self._ccbOwner.tf_explain:setString("可骰到"..tbl[1].."到"..tbl[2].."点数")
	self._ccbOwner.tf_count:setString("x"..remote.items:getItemsNumByID(self._itemId))

	self._ccbOwner.node_dice:removeAllChildren()
	self._ccbOwner.node_dice:addChild(CCSprite:create(info.selectViewIcon))
	
	self._ccbOwner.tf_name:setString(info.config.name)
end

function QUIWidgetMonopolySelectCheatCell:_onTriggerSelect()
	app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetMonopolySelectCheatCell.Selected, itemId = self._itemId})
end


return QUIWidgetMonopolySelectCheatCell