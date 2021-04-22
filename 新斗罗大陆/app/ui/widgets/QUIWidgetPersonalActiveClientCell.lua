-- @Author: xurui
-- @Date:   2016-11-09 09:59:55
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-11-15 11:30:26
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPersonalActiveClientCell = class("QUIWidgetPersonalActiveClientCell", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetPersonalActiveClientCell.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetPersonalActiveClientCell:ctor(options)
	local ccbFile = "ccb/Widget_society_gerenhuoyue_client.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
	}
	QUIWidgetPersonalActiveClientCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._awardsBox = {}
end

function QUIWidgetPersonalActiveClientCell:onEnter()
end

function QUIWidgetPersonalActiveClientCell:onExit()
end

function QUIWidgetPersonalActiveClientCell:setInfo(param)
	self._ccbOwner.tf_deal_num:setString("")

	self._taskInfo = param.task or {}

	self._ccbOwner.tf_name:setString(self._taskInfo.name or "")
	self._ccbOwner.tf_desc:setString(self._taskInfo.desc or "")

	self._ccbOwner.box_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(self._taskInfo.icon))
	self._ccbOwner.box_icon:setVisible(true)

	--set state
	self._isComplete = self._taskInfo.isComplete or false
	self._ccbOwner.done_banner:setVisible(self._isComplete)
	self._ccbOwner.sp_done:setVisible(self._isComplete)

	-- set link button
	self._ccbOwner.node_btn_go:setVisible(false)
	if self._taskInfo.link and self._isComplete == false then
		self._ccbOwner.node_btn_go:setVisible(true)
	end 

	--set awards 
	for i = 1, 3 do
		if i == 1 then
			local num = self._taskInfo.meiri_points or 0
			self._ccbOwner["tf_value"..i]:setString("X".. (self._taskInfo.meiri_points or 0))
			if self._awardsBox[i] == nil then
				self._awardsBox[i] = QUIWidgetItemsBox.new()
				self._ccbOwner["sp_icon"..i]:addChild(self._awardsBox[i])
			end
			self._awardsBox[i]:setGoodsInfo(nil, ITEM_TYPE.UNION_TASK_POINT)
		else
			self._ccbOwner["tf_value"..i]:setVisible(false)
			self._ccbOwner["sp_icon"..i]:setVisible(false)
		end
	end

	-- set progress
	local curNum = self._taskInfo.taskInfo.progress or 0
	local maxNum = self._taskInfo.num or 1
	if self._taskInfo.task_type == 20001 then
		curNum = QStaticDatabase:sharedDatabase():getSocietyFete((self._taskInfo.taskInfo.progress or 1)).contribution_gain or 0
		maxNum = QStaticDatabase:sharedDatabase():getSocietyFete((self._taskInfo.num or 1)).contribution_gain or 1
	end
	self._ccbOwner.tf_progress:setString(curNum .."/".. maxNum)
end

function QUIWidgetPersonalActiveClientCell:getContentSize()
	return self._ccbOwner.bg:getContentSize()
end

function QUIWidgetPersonalActiveClientCell:_onTriggerClick()
	if self._isComplete == false then return end

	self:dispatchEvent({name = QUIWidgetPersonalActiveClientCell.EVENT_CLICK, info = self._taskInfo})
end

function QUIWidgetPersonalActiveClientCell:_onTriggerGo()
	app.sound:playSound("common_small")
	if self._taskInfo.link then
		-- 检查shortcut表
		local shortcutInfo = QStaticDatabase.sharedDatabase():getShortcut()
		local quickInfo = {}
		for _, value in pairs(shortcutInfo) do
			if value.cname == self._taskInfo.link then
				quickInfo = value
				break
			end
		end
		-- 检查item_user_link表
		if next(quickInfo) == nil then
			local linkInfo = QStaticDatabase.sharedDatabase():getItemUseLink()
			for _, value in pairs(linkInfo) do
				if value.cname == self._taskInfo.link then
					quickInfo = value
					break
				end
			end
		end

		if next(quickInfo) then
			QQuickWay:clickGoto(quickInfo)
		end
	end
end

return QUIWidgetPersonalActiveClientCell