--
-- Kumo.Wang
-- 宗门副本有效伤害排行榜cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyDungeonValidInfo = class("QUIWidgetSocietyDungeonValidInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIWidgetSocietyDungeonValidInfo.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetSocietyDungeonValidInfo:ctor(options)
	local ccbFile = "ccb/Widget_society_fuben_valid_info.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSocietyDungeonValidInfo.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSocietyDungeonValidInfo:onEnter()
end

function QUIWidgetSocietyDungeonValidInfo:onExit()
end

function QUIWidgetSocietyDungeonValidInfo:setInfo(param)
	self._info = param.info

	self._ccbOwner.tf_level:setString("LV."..(self._info.level or ""))
	self._ccbOwner.tf_name:setString(self._info.name or "")
	self._ccbOwner.bf_vip:setString("VIP"..(self._info.vip or 0))

	local num, word = q.convertLargerNumber(self._info.force)
	self._ccbOwner.tf_battle_force:setString(num..(word or ""))

	local num, word = q.convertLargerNumber(self._info.consortiaBossAllDamage or 0)
	self._ccbOwner.tf_damage:setString(num..(word or ""))
	
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

function QUIWidgetSocietyDungeonValidInfo:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetSocietyDungeonValidInfo.EVENT_CLICK, info = self._info})
end

function QUIWidgetSocietyDungeonValidInfo:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end


return QUIWidgetSocietyDungeonValidInfo