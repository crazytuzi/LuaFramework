--
-- Author: Kumo
-- Date: 2014-11-24 16:39:45
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainBox = class("QUIWidgetUnionDragonTrainBox", QUIWidget)

local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")

QUIWidgetUnionDragonTrainBox.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetUnionDragonTrainBox:ctor(options)
	local ccbFile = "ccb/Widget_Society_Dragon_Task_Box.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClickAwards",  callback = handler(self, self._onTriggerClickAwards)},
	}
	QUIWidgetUnionDragonTrainBox.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.boxList = {}
end

function QUIWidgetUnionDragonTrainBox:onEnter()
	QUIWidgetUnionDragonTrainBox.super.onEnter(self)
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIWidgetUnionDragonTrainBox:onExit()   
	QUIWidgetUnionDragonTrainBox.super.onExit(self)
    if self.prompt ~= nil then
        self.prompt:removeItemEventListener()
    end
end

function QUIWidgetUnionDragonTrainBox:resetAll()
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_progress:setVisible(false)
	self._ccbOwner.tf_weiwancheng:setVisible(false)
	self._ccbOwner.sp_yilingqu:setVisible(false)
	self._ccbOwner.node_done:setVisible(false)
	local index = 1
	while true do
		local node = self._ccbOwner["item"..index]
		if node then
			node:removeAllChildren()
			node:setVisible(true)
			index = index + 1
		else
			break
		end
	end
end

function QUIWidgetUnionDragonTrainBox:setInfo(info, parent)
	self:resetAll()
	self._info = info
	self._parent = parent
	if not self._info then return end

	self._minProgressNumber = remote.dragon:getTaskMinProgress()
	self._myTaskInfo = remote.dragon:getMyTaskInfo()

	if self._info.box_name then
		self._ccbOwner.tf_name:setString(self._info.box_name)
		self._ccbOwner.tf_name:setVisible(true)
	end

	if self._info.box_target then
		self._ccbOwner.tf_progress:setString("进度 "..self._minProgressNumber.."/"..self._info.box_target)
		self._ccbOwner.tf_progress:setVisible(true)
	end

	local luckyDrawConfig = remote.dragon:getLuckyDrawById(self._info.box_lucky_draw)
	-- QPrintTable(luckyDrawConfig)
	local index = 1
	while true do
		if luckyDrawConfig[index] then
			local id = luckyDrawConfig[index].id
			local typeName = luckyDrawConfig[index].typeName
			local count = luckyDrawConfig[index].count
			local node = self._ccbOwner["item"..index]
			-- print(id, typeName, count, node)
			if node and typeName then
				local itemBox = QUIWidgetItemsBox.new()
				itemBox:setPromptIsOpen(true)
		    	itemBox:resetAll()
		    	itemBox:setGoodsInfo(id, typeName, count)
				node:addChild(itemBox)
				table.insert(self.boxList, itemBox)
				index = index + 1
			else
				break
			end
		else
			break
		end
	end
	if self._info.dragon_exp then
		local node = self._ccbOwner["item"..index]
		if node then
			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setPromptIsOpen(true)
	    	itemBox:resetAll()
	    	itemBox:setGoodsInfo(remote.dragon.EXP_RESOURCE_ID, remote.dragon.EXP_RESOURCE_TYPE, self._info.dragon_exp)
			node:addChild(itemBox)
			table.insert(self.boxList, itemBox)
			index = index + 1
		end
	end
	if not self._info.isOpenBox and self._info.dragon_exp and remote.union:isDragonTrainBuff() then
		local node = self._ccbOwner["item"..index]
		if node then
			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setPromptIsOpen(true)
	    	itemBox:resetAll()
	    	itemBox:setGoodsInfo(remote.dragon.EXP_RESOURCE_ID, remote.dragon.EXP_RESOURCE_TYPE, self._info.dragon_exp)
	    	itemBox:setAwardName("神赐加成")
			node:addChild(itemBox)
			table.insert(self.boxList, itemBox)
		end
	end
	self:_updateState()
end

function QUIWidgetUnionDragonTrainBox:_updateState()
	if self._minProgressNumber >= (self._info.box_target or 0) then
		if remote.dragon:isTaskBoxOpenedByBoxId(self._info.box_id) then
			self._ccbOwner.sp_yilingqu:setVisible(true)
		else
			self._ccbOwner.node_done:setVisible(true)
		end
	else
		self._ccbOwner.tf_weiwancheng:setVisible(true)
	end
end

function QUIWidgetUnionDragonTrainBox:_onTriggerClickAwards()
	if self._minProgressNumber >= (self._info.box_target or 0) then
		self:dispatchEvent({name = QUIWidgetUnionDragonTrainBox.EVENT_CLICK, boxId = self._info.box_id})
	else
		app.tip:floatTip("尚未完成")
	end
end

function QUIWidgetUnionDragonTrainBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetUnionDragonTrainBox