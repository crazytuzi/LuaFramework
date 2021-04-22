--
-- Author: Kumo
-- Date: 2015-04-25 11:34:22
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRobotTargetItem = class("QUIWidgetRobotTargetItem", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetRobotTargetItem:ctor(options)
	local ccbFile = "ccb/Widget_EliteBattleAgain_NoticeTips.ccbi"
	local callbacks = {}
	QUIWidgetRobotTargetItem.super.ctor(self, ccbFile, callbacks, options)

	self._ccbOwner.complete:setVisible(false)
	self._ccbOwner.incomplete:setVisible(false)
	self._ccbOwner.root:setVisible(false)

	self._inPackCount = options.inPackCount
end

function QUIWidgetRobotTargetItem:setInfo(id, packNum, targetNum)
	self._ccbOwner.root:setVisible(false)
	self._ccbOwner.complete:setVisible(false)
	self._ccbOwner.incomplete:setVisible(false)

	if not packNum or not targetNum then
		return 
	end

	if packNum ~= self._inPackCount then
		self:nodeEffect(self._ccbOwner.num1_incomplete1)
		self:nodeEffect(self._ccbOwner.num1_incomplete2)
		self._inPackCount = packNum
	end

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(id)
	self._ccbOwner.root:setVisible(true)
	local str = "目标道具："..itemConfig.name .. " "..tostring(packNum).."/"..tostring(targetNum)
	if packNum < targetNum then
		self._ccbOwner.incomplete:setVisible(true)
		self._ccbOwner.name_incomplete:setString(str)
	else
		self._ccbOwner.complete:setVisible(true)
		str = str.."（已集齐）"
		self._ccbOwner.name_complete:setString(str)
	end
end

function QUIWidgetRobotTargetItem:nodeEffect(node)
	if node ~= nil then
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.11, 3))
        actionArrayIn:addObject(CCScaleTo:create(0.11, 1))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

return QUIWidgetRobotTargetItem
