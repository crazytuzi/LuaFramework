local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockInvite = class("QUIWidgetBlackRockInvite", QUIWidget)
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

function QUIWidgetBlackRockInvite:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_yaoqing.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
	}
	QUIWidgetBlackRockInvite.super.ctor(self, ccbFile, callBacks, options)
	self._timeCount = 60
end

function QUIWidgetBlackRockInvite:onExit()
	QUIWidgetBlackRockInvite.super.onExit(self)
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
end

function QUIWidgetBlackRockInvite:setInfo(info)
	self._info = info
	if self._info.selected == nil then
		self._info.selected = false
	end
	self._ccbOwner.tf_level:setString("LV."..self._info.level)
	self._ccbOwner.tf_name:setString(self._info.name or "")
	self._ccbOwner.tf_vip:setString("VIP "..self._info.vip)
	q.autoLayerNode({self._ccbOwner.tf_level, self._ccbOwner.tf_name}, "x")
	if self._avatar == nil then
    	self._avatar = QUIWidgetAvatar.new(self._info.avatar)
    	self._avatar:setSilvesArenaPeak(info.championCount)
    	self._ccbOwner.node_headPicture:addChild(self._avatar)
	else
		self._avatar:setInfo(self._info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	end
	self._ccbOwner.tf_vip:setString("VIP "..self._info.vip)
	local num,unit = q.convertLargerNumber(self._info.force)
	self._ccbOwner.tf_force:setString("战力："..num..(unit or ""))
	self:setSelect(self._info.selected == true)
	self._inviteTime = (self._info.blackRockLastInviteAt or 0)/1000
	
	if remote.user.userConsortia.consortiaId == self._info.consortiaId then 
		self._ccbOwner.node_union:setVisible(true)
	else
		self._ccbOwner.node_union:setVisible(false)
	end
	self:checkTime()	
end

function QUIWidgetBlackRockInvite:checkTime()
	local currTime = q.serverTime()
	local leftTime = self._timeCount - (currTime - self._inviteTime)
	if leftTime <= 0 then
		self._ccbOwner.node_select:setVisible(true)
		self._ccbOwner.tf_time:setString("")
	else
		self._ccbOwner.node_select:setVisible(false)
		self._ccbOwner.tf_time:setString(string.format("%.2d:%.2d", math.floor(leftTime/60), leftTime%60))
		if self._handler ~= nil then
			scheduler.unscheduleGlobal(self._handler)
			self._handler = nil
		end
		self._handler = scheduler.performWithDelayGlobal(function ()
			self._handler = nil
			self:checkTime()
		end, 1)
	end
end

function QUIWidgetBlackRockInvite:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetBlackRockInvite:setSelect(b)
	self._ccbOwner.btn_select:setHighlighted(b)
end

function QUIWidgetBlackRockInvite:_onTriggerSelect()
	self._info.selected = not self._info.selected
	self:setSelect(self._info.selected == true)
end

return QUIWidgetBlackRockInvite