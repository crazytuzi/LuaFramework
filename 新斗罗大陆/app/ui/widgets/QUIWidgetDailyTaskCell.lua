--
-- Author: Your Name
-- Date: 2014-11-15 12:19:29
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetDailyTaskCell = class("QUIWidgetDailyTaskCell", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")

QUIWidgetDailyTaskCell.EVENT_QUICK_LINK = "EVENT_QUICK_LINK"
QUIWidgetDailyTaskCell.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetDailyTaskCell:ctor(options)
	local ccbFile = "ccb/Widget_DailyMission_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetDailyTaskCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self._defaultText = self._ccbOwner.tf_time:getString()
	self._oldPositionX = self._ccbOwner.sp_icon1:getPositionX()
end

function QUIWidgetDailyTaskCell:setInfo(info)
	if not info then
		return
	end
	
	self._taskInfo = info
	self:resetAll()
	
	if self._taskInfo.state == remote.task.TASK_DONE then
		self._ccbOwner.btn_done:setVisible(true)
		self._ccbOwner.normal_banner:setVisible(false)
		self._ccbOwner.done_banner:setVisible(true)
	else
		self._ccbOwner.normal_banner:setVisible(true)
		self._ccbOwner.done_banner:setVisible(false)
	end
	self._ccbOwner.tf_name:setString(self._taskInfo.config.name)
	self._ccbOwner.tf_desc:setString(self._taskInfo.config.desc)
	self._ccbOwner.tf_name:setVisible(true)
	self._ccbOwner.tf_desc:setVisible(true)

	self._positionX = self._oldPositionX
	self._gap = 20
	local awards = {}
	if self._taskInfo.config.task_level_drop ~= nil then
		awards = QStaticDatabase.sharedDatabase():getLevelDropById(self._taskInfo.config.task_level_drop, remote.user.level)
	else
		if (self._taskInfo.config.levellimit_1 or 0) <= remote.user.level then 
			if self._taskInfo.config.id_1 ~= nil or self._taskInfo.config.type_1 ~= nil then
				table.insert(awards, {id = self._taskInfo.config.id_1, typeName = self._taskInfo.config.type_1, count = self._taskInfo.config.num_1})
			end
		end
		if (self._taskInfo.config.levellimit_2 or 0) <= remote.user.level then
			if self._taskInfo.config.id_2 ~= nil or self._taskInfo.config.type_2 ~= nil  then
				table.insert(awards, {id = self._taskInfo.config.id_2, typeName = self._taskInfo.config.type_2, count = self._taskInfo.config.num_2})
			end
		end
	end
	if (self._taskInfo.config.meiri_points or 0) > 0 then
		local  typeName = ITEM_TYPE.TASK_POINT
		if self._taskInfo.config.module == "每周任务" then
			 typeName = ITEM_TYPE.TASKWK_POINT
		end
		table.insert(awards, {id = nil, typeName = typeName, count = self._taskInfo.config.meiri_points})
	end
	for index,value in ipairs(awards) do
		self:setIconInfo(value.typeName, value.count, value.id, index)
	end

	self:showTaskInfo()
	if self._taskInfo.config.icon ~= nil then
		self._ccbOwner.box_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(self._taskInfo.config.icon))
		self._ccbOwner.box_icon:setVisible(true)
	end
end

function QUIWidgetDailyTaskCell:setIconInfo(itemType, value, id, index)
	if self._ccbOwner["sp_icon"..index] == nil then return end
	local respath = nil
	if itemType ~= nil and value ~= nil then
		if itemType == ITEM_TYPE.ITEM then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(id)
			respath = itemInfo.icon
		else
			respath = remote.items:getURLForItem(itemType, "alphaIcon")
		end
	end
	if respath ~= nil then
		-- local icon = nil
		-- if itemType == ITEM_TYPE.ITEM then
			local icon = QUIWidgetItemsBox.new()
			-- icon:removeFromParent()
			icon:setGoodsInfo(id, itemType, 0)
		-- else
		-- 	icon = CCSprite:create()
		-- 	icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		-- end
		local sp_icon_index = self._ccbOwner["sp_icon"..index]
		sp_icon_index:setVisible(true)
		sp_icon_index:removeAllChildren()
		sp_icon_index:addChild(icon)

		self._positionX = self._positionX + sp_icon_index:getScaleX() * icon:getContentSize().width/2 
		sp_icon_index:setPositionX(self._positionX)
		self._positionX = self._positionX + sp_icon_index:getScaleX() * icon:getContentSize().width/2 + self._gap/2
	end

	if value ~= nil then
		local tf_value_index = self._ccbOwner["tf_value"..index]
		tf_value_index:setString("x "..value)
		tf_value_index:setVisible(true)
		tf_value_index:setPositionX(self._positionX)
		self._positionX = self._positionX + tf_value_index:getContentSize().width + self._gap
	end
end

function QUIWidgetDailyTaskCell:resetAll()
	-- self._ccbOwner.tf_name:setString("")
	-- self._ccbOwner.tf_desc:setString("")
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_desc:setVisible(false)
	self._ccbOwner.tf_time:setVisible(false)
	self._ccbOwner.btn_done:setVisible(false)
	-- self._ccbOwner.tf_value1:setString("")
	-- self._ccbOwner.tf_value2:setString("")
	self._ccbOwner.sp_icon1:setVisible(false)
	self._ccbOwner.sp_icon2:setVisible(false)
	self._ccbOwner.sp_icon3:setVisible(false)
	self._ccbOwner.tf_value1:setVisible(false)
	self._ccbOwner.tf_value2:setVisible(false)
	self._ccbOwner.tf_value3:setVisible(false)
	self._ccbOwner.box_icon:setVisible(false)
	self._ccbOwner.btn_go:setVisible(false)
	-- self._ccbOwner.tf_deal_num:setString("")
	self._ccbOwner.tf_deal_num:setVisible(false)
	self._ccbOwner.tokenDone:setVisible(false)
	self._ccbOwner.btnLabel:setString("前 往")
end

--[[
	根据不同的任务显示不同的东西
]]
function QUIWidgetDailyTaskCell:showTaskInfo()
	if self._taskInfo.state == remote.task.TASK_DONE then
		return 
	end

	if self._taskInfo.config.index == "100000" or self._taskInfo.config.index == "100001" or self._taskInfo.config.index == "100002" 
		or self._taskInfo.config.index == "100900" then
		if self._taskInfo.state == remote.task.TASK_DONE_TOKEN then
			self._ccbOwner.btn_go:setVisible(true)
			self._ccbOwner.btnLabel:setString("补 领")
			self._ccbOwner.tokenDone:setVisible(true)
			self._ccbOwner.tokenNum:setString(self._taskInfo.token or 20)
			self._ccbOwner.tf_deal_num:setVisible(false)

		elseif self._taskInfo.state == remote.task.TASK_NONE then
			self._ccbOwner.tf_time:setVisible(true)
			self._ccbOwner.tf_time:setString(self._defaultText)
		end

	elseif self._taskInfo.config.module == "月卡" then
		-- Monthly recharge daily task cell should be shown when completed @qinyuanji wow-10609
		local endTime = self._taskInfo.config.index == "200001" and remote.recharge.monthCard1EndTime or remote.recharge.monthCard2EndTime
		endTime = endTime or 0
		
		local remainingDays = (endTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
		print("remainingDays", remainingDays)

		if remainingDays > 0 then
			self._ccbOwner.tf_time:setVisible(true)
			self._ccbOwner.tf_time:setString(string.format("已领，剩余%d次", remainingDays - 1))
		else
			self._ccbOwner.tf_time:setVisible(false)
			self._ccbOwner.btn_go:setVisible(true)
		end
	else
		if self._taskInfo.state == remote.task.TASK_COMPLETE then return end
		self._ccbOwner.tf_deal_num:setString("进度："..(self._taskInfo.stepNum or 0).."/"..self._taskInfo.config.num)
		-- if (self._taskInfo.stepNum or 0) < self._taskInfo.config.num then
		-- 	 self._ccbOwner.tf_deal_num:setColor(UNITY_COLOR.red)
		-- end
		self._ccbOwner.tf_deal_num:setVisible(true)
		self._ccbOwner.btn_go:setVisible(true)
		if self._taskInfo.config.index == "110006" then
			self._ccbOwner.btn_go:setVisible(false)
		end
	end
end

function QUIWidgetDailyTaskCell:getContentSize( ... )
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetDailyTaskCell:_onTriggerGo(event)
	if self._taskInfo and self._taskInfo.state == remote.task.TASK_DONE_TOKEN then
		app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TO_CURRENT_PAGE)
		app:alert({content=string.format("是否花费%s钻石，补领%s任务？",self._taskInfo.token or 20, self._taskInfo.name), title="系统提示", 
                callback=function(state)
                	if self._isExit then
	                    if state == ALERT_TYPE.CONFIRM then
	                        self:dispatchEvent({name = QUIWidgetDailyTaskCell.EVENT_CLICK, index = self._taskInfo.config.index})
	                    end
                     end
                end}, false, true)
	else
		self:dispatchEvent({name = QUIWidgetDailyTaskCell.EVENT_QUICK_LINK, index = self._taskInfo.config.index})
	end
end

function QUIWidgetDailyTaskCell:_onTriggerClick(event)
	if self._taskInfo and self._taskInfo.state == remote.task.TASK_DONE then
		self:dispatchEvent({name = QUIWidgetDailyTaskCell.EVENT_CLICK, index = self._taskInfo.config.index})
	end
end

function QUIWidgetDailyTaskCell:onCleanup()
    -- self._iconQUIWidgetItemBox:release()
    -- self._iconQUIWidgetItemBox = nil
end


function QUIWidgetDailyTaskCell:onEnter()
	--代码
	self._isExit = true
end

--describe：onExit 
function QUIWidgetDailyTaskCell:onExit()
	--代码
	self._isExit = nil
end


return QUIWidgetDailyTaskCell