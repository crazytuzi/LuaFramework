--
-- Kumo.Wang
-- 资源夺宝选择主题Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTreasuresSelectThemeCell = class("QUIWidgetTreasuresSelectThemeCell", QUIWidget)
local QUIViewController = import("..QUIViewController")

local QUIWidgetTreasuresTheme = import(".QUIWidgetTreasuresTheme")

QUIWidgetTreasuresSelectThemeCell.SELECTED = "QUIWIDGETMONOPOLYSELECTCHEATCELL_SELECTED"

function QUIWidgetTreasuresSelectThemeCell:ctor(options)
	local ccbFile = "ccb/Widget_Treasures_Choose_Theme.ccbi"
	local callBacks = {}
	QUIWidgetTreasuresSelectThemeCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)
    
    self._ccbOwner.btn_detail:setVisible(false)
end

function QUIWidgetTreasuresSelectThemeCell:onEnter()
end

function QUIWidgetTreasuresSelectThemeCell:onExit()
end

function QUIWidgetTreasuresSelectThemeCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetTreasuresSelectThemeCell:setSelectState( isSelected )
	self._ccbOwner.sp_selected_on:setVisible(isSelected)
	self._ccbOwner.sp_selected_off:setVisible(not isSelected)
end

function QUIWidgetTreasuresSelectThemeCell:setInfo(info)
	self._id = info.id

	self._ccbOwner.node_item:removeAllChildren()
	local icon = QUIWidgetTreasuresTheme.new({themeType = info.type})
	icon:setItemIcon(info.icon)
	icon:setThemeName()
	icon:setHideTips()
	self._ccbOwner.node_item:addChild(icon)
	
	self._ccbOwner.tf_name:setString(info.name)
end

function QUIWidgetTreasuresSelectThemeCell:_onTriggerSelect()
	app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetTreasuresSelectThemeCell.SELECTED, id = self._id})
end

function QUIWidgetTreasuresSelectThemeCell:_onTriggerDetail()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasuresPreviewTheme", options = {id = self._id}})
end

return QUIWidgetTreasuresSelectThemeCell