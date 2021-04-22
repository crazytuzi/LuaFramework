-- @Author: xurui
-- @Date:   2016-11-12 11:41:29
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-11-25 16:15:02
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUnionSacrificeViewCell = class("QUIWidgetUnionSacrificeViewCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIWidgetUnionSacrificeViewCell.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetUnionSacrificeViewCell:ctor(options)
	local ccbFile = "ccb/Widget_society_union_jisixinxi.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetUnionSacrificeViewCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetUnionSacrificeViewCell:onEnter()
end

function QUIWidgetUnionSacrificeViewCell:onExit()
end

function QUIWidgetUnionSacrificeViewCell:setInfo(param)
	self._info = param.info

	self._ccbOwner.tf_level:setString("LV."..(self._info.level or ""))
	self._ccbOwner.tf_name:setString(self._info.name or "")
	self._ccbOwner.bf_vip:setString("VIP"..(self._info.vip or 0))

	local num, word = q.convertLargerNumber(self._info.force)
	self._ccbOwner.tf_battle_force:setString(num..(word or ""))

	self._ccbOwner.tf_sacrifice_type:setVisible(true)
	self._ccbOwner.tf_no_sacrifice:setVisible(false)
	if self._info.dailySacrificeType > 0 then 
		local data = QStaticDatabase:sharedDatabase():getSocietyFete(self._info.dailySacrificeType)
		local sacrificeType = data.fete_name ~= nil and data.fete_name or "未建设"
		local color = BREAKTHROUGH_COLOR_LIGHT[EQUIPMENT_QUALITY[data.tape_colour]]

		self._ccbOwner.tf_sacrifice_type:setString(sacrificeType)
		self._ccbOwner.tf_sacrifice_type:setColor(color)
		self._ccbOwner.tf_sacrifice_type = setShadowByFontColor(self._ccbOwner.tf_sacrifice_type, color)
	else
		self._ccbOwner.tf_sacrifice_type:setVisible(false)
		self._ccbOwner.tf_no_sacrifice:setVisible(true)
	end

	local state = "在线"
	self._ccbOwner.tf_state:setColor(UNITY_COLOR.green)
	if self._info.lastLeaveTime ~= nil and self._info.lastLeaveTime > 0 then
		local lastLeaveTime = self._info.lastLeaveTime/1000
		self._ccbOwner.tf_state:setColor(UNITY_COLOR.dark)
		if lastLeaveTime > HOUR then
			local hour = math.floor(lastLeaveTime/HOUR)
			if hour < 24 then
				state = string.format("离线%s小时", hour)
			else
				if math.floor(hour/24) > 7 then
					state = string.format("离线>7天")
				else
					state = string.format("离线%s天", math.floor(hour/24))
				end
			end
		else
			state = string.format("离线%s分", math.floor(lastLeaveTime/MIN))
		end
	end
	self._ccbOwner.tf_state:setString(state or "")

	if self._avatar == nil then
		self._avatar = QUIWidgetAvatar.new()
		self._ccbOwner.node_icon:addChild(self._avatar)
	end
	self._avatar:setInfo(self._info.avatar)
	self._avatar:setSilvesArenaPeak(self._info.championCount)
end

function QUIWidgetUnionSacrificeViewCell:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetUnionSacrificeViewCell.EVENT_CLICK, info = self._info})
end

function QUIWidgetUnionSacrificeViewCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end


return QUIWidgetUnionSacrificeViewCell