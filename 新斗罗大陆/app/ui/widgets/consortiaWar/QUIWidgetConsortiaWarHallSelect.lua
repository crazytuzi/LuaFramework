-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 10:47:22
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-05 12:06:50
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetConsortiaWarHallSelect = class("QUIWidgetConsortiaWarHallSelect", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

QUIWidgetConsortiaWarHallSelect.EVENT_CLICK_UP = "EVENT_CLICK_UP"

function QUIWidgetConsortiaWarHallSelect:ctor(options)
	local ccbFile = "ccb/Widget_Unionwar_setting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerUp", callback = handler(self, self._onTriggerUp)},
    }
    QUIWidgetConsortiaWarHallSelect.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetConsortiaWarHallSelect:onEnter()
end

function QUIWidgetConsortiaWarHallSelect:onExit()
end

function QUIWidgetConsortiaWarHallSelect:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.normal_banner, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_ok, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_btn, self._glLayerIndex)
	if self._head then
		self._glLayerIndex = self._head:initGLLayer()
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_score, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_vip, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_time, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetConsortiaWarHallSelect:setInfo(info)
	self._info = info
	self._userId = info.userId
	if not self._head then
		self._head = QUIWidgetAvatar.new()
		self._ccbOwner.node_head:addChild(self._head)
	end
	self._head:setInfo(info.avatar)
	self._head:setSilvesArenaPeak(info.championCount)

	local nameStr = string.format("LV.%d %s", (info.level or 1), (info.name or ""))
	self._ccbOwner.tf_name:setString(nameStr)

    local force = info.force or 0
    local num, uint = q.convertLargerNumber(force)
	self._ccbOwner.tf_force:setString("战力："..num..uint)
	self._ccbOwner.tf_vip:setString("VIP"..(info.vip or ""))

	if info.lastLeaveTime ~= nil and info.lastLeaveTime > 0 then
		local lastLeaveTime = info.lastLeaveTime/1000
		self._ccbOwner.tf_time:setColor(UNITY_COLOR.brown)
		if lastLeaveTime > HOUR then
			local hour = math.floor(lastLeaveTime/HOUR)
			if hour < 24 then
				self._ccbOwner.tf_time:setString(string.format("离线%s小时", hour))
			else
				local day = math.floor(hour/24)
				self._ccbOwner.tf_time:setString(string.format("离线%s天", day))
				if day > 7 then
					self._ccbOwner.tf_time:setString(string.format("离线>7天", day))
				end
			end
		else
			self._ccbOwner.tf_time:setString(string.format("离线%s分", math.floor(lastLeaveTime/MIN)))
		end
	else
		self._ccbOwner.tf_time:setColor(UNITY_COLOR.green)
		self._ccbOwner.tf_time:setString("在线")	
	end
end

function QUIWidgetConsortiaWarHallSelect:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetConsortiaWarHallSelect:_onTriggerUp(event, ss, ssa)
	app.sound:playSound("common_small")
    self:dispatchEvent({name = QUIWidgetConsortiaWarHallSelect.EVENT_CLICK_UP, info = self._info}) 
end

return QUIWidgetConsortiaWarHallSelect
