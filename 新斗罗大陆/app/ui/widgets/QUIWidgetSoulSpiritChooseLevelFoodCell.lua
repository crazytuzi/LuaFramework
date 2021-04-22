--
-- Author: Kumo.Wang
-- 魂靈選擇升級食物Cell
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetSoulSpiritChooseLevelFoodCell = class("QUIWidgetSoulSpiritChooseLevelFoodCell", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QActorProp = import("...models.QActorProp")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetSoulSpiritChooseLevelFoodCell.ITEM_ADD = "QUIWIDGETSOULSPIRITCHOOSELEVELFOODCELL.ITEM_ADD"
QUIWidgetSoulSpiritChooseLevelFoodCell.ITEM_SUB = "QUIWIDGETSOULSPIRITCHOOSELEVELFOODCELL.ITEM_SUB"

function QUIWidgetSoulSpiritChooseLevelFoodCell:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_Choose_LevelFood_Cell.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerAdd", callback = handler(self, self._onTriggerAdd)},
		{ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},
	}
	QUIWidgetSoulSpiritChooseLevelFoodCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSoulSpiritChooseLevelFoodCell:onEnter()
end

function QUIWidgetSoulSpiritChooseLevelFoodCell:onExit()
end

function QUIWidgetSoulSpiritChooseLevelFoodCell:setInfo(param)
	self._itemId = param
	self._totalCount = remote.items:getItemsNumByID(self._itemId)
	self._selectedCount = remote.soulSpirit.selectedFoodDic[self._itemId] or 0

	self._box = QUIWidgetItemsBox.new()
	self._box:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, 0)
	self._ccbOwner.node_item:removeAllChildren()
	self._ccbOwner.node_item:addChild(self._box)

	local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(self._itemId)
	self._ccbOwner.tf_exp:setString(itemConfig.exp)
	self._ccbOwner.tf_double:setString(itemConfig.crit.."%")

	self:updateInfo()
end

function QUIWidgetSoulSpiritChooseLevelFoodCell:updateInfo()
	self._box:setItemCount(self._selectedCount.."/"..self._totalCount)
	self._ccbOwner.node_sub:setVisible(self._selectedCount > 0)
	self._ccbOwner.btn_add3:setVisible(self._selectedCount == 0)
	self._ccbOwner.ly_mask:setVisible(self._totalCount == 0)
end

function QUIWidgetSoulSpiritChooseLevelFoodCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSoulSpiritChooseLevelFoodCell:_onTriggerAdd()
	app.sound:playSound("common_small")
	if self._totalCount == 0 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
		return
	end
	local maxCount = math.min(self._totalCount, remote.soulSpirit:getNumForUnSelectedFood())
	print("+++ ", maxCount)
	if maxCount <= 0 then return end
	if (remote.soulSpirit.selectedFoodDic[self._itemId] or 0) >= self._totalCount then return end
	
	self._selectedCount = self._selectedCount + 1
	if self._selectedCount - (remote.soulSpirit.selectedFoodDic[self._itemId] or 0) > maxCount then
		self._selectedCount = maxCount
	end
	remote.soulSpirit.selectedFoodDic[self._itemId] = self._selectedCount
	self:updateInfo()
	self:dispatchEvent({name = QUIWidgetSoulSpiritChooseLevelFoodCell.ITEM_ADD})
end

function QUIWidgetSoulSpiritChooseLevelFoodCell:_onTriggerSub()
	app.sound:playSound("common_small")
	self._selectedCount = self._selectedCount - 1
	if self._selectedCount < 0 then
		self._selectedCount = 0
	end
	remote.soulSpirit.selectedFoodDic[self._itemId] = self._selectedCount > 0 and self._selectedCount or nil
	self:updateInfo()
	self:dispatchEvent({name = QUIWidgetSoulSpiritChooseLevelFoodCell.ITEM_ADD})
end

return QUIWidgetSoulSpiritChooseLevelFoodCell