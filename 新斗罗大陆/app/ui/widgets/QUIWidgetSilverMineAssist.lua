local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineAssist = class("QUIWidgetSilverMineAssist", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetSilverMineAssist:ctor(options)
 	local ccbFile = "ccb/Widget_SilverMine_Yaoqing.ccbi"
	local callBacks = {
	    -- {ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIWidgetSilverMineAssist._onTriggerSelect)},
	    -- {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIWidgetSilverMineAssist._onTriggerConfirm)},
	}
	QUIWidgetSilverMineAssist.super.ctor(self, ccbFile, callBacks, options)
	self._ccbOwner.node_headPicture:setScale(0.8)
end

function QUIWidgetSilverMineAssist:setInfo(value)
	self._info = value
	self._ccbOwner.btn_select:setTouchEnabled(false)
	self._ccbOwner.tf_assist_count:setString("剩余协助次数："..(value.assistantCount or 0))
	self._ccbOwner.tf_level:setString(string.format("LV.%d %s", (value.level or 0), value.name))
	self._ccbOwner.tf_vip:setString(string.format("VIP %d", (value.vip or 0)))
	self._ccbOwner.tf_friend_count:setString(string.format("友情值：%d", (value.friendshipPoint or 0)))
	
	if value.lastLeaveTime ~= nil and value.lastLeaveTime > 0 then
		local lastLeaveTime = value.lastLeaveTime/1000
		self._ccbOwner.tf_deal_num:setColor(UNITY_COLOR.dark)
		if lastLeaveTime > HOUR then
			local hour = math.floor(lastLeaveTime/HOUR)
			if hour < 24 then
				self._ccbOwner.tf_deal_num:setString(string.format("离线%s小时", hour))
			else
				local day = math.floor(hour/24)
				self._ccbOwner.tf_deal_num:setString(string.format("离线%s天", day))
				if day > 7 then
					self._ccbOwner.tf_deal_num:setString(string.format("离线>7天", day))
				end
			end
		else
			self._ccbOwner.tf_deal_num:setString(string.format("离线%s分", math.floor(lastLeaveTime/MIN)))
		end
	else
		self._ccbOwner.tf_deal_num:setColor(UNITY_COLOR.green)
		self._ccbOwner.tf_deal_num:setString("在线")	
	end

	self._ccbOwner.node_headPicture:removeAllChildren()
	local avatar = QUIWidgetAvatar.new(value.avatar)
	avatar:setSilvesArenaPeak(value.championCount)
	self._ccbOwner.node_headPicture:addChild(avatar)
	self._ccbOwner.node_select:setVisible(value.assistStatus == 0)
	self._ccbOwner.sp_invite:setVisible(value.assistStatus == 1)
	self._ccbOwner.sp_assist:setVisible(value.assistStatus == 2)
	value._assistSelect = value._assistSelect or false
	if value.assistStatus == 0 then
		self._ccbOwner.btn_select:setHighlighted(value._assistSelect == true)
	end
end

function QUIWidgetSilverMineAssist:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

function QUIWidgetSilverMineAssist:onSelect()
	self._info._assistSelect = not self._info._assistSelect
	self._ccbOwner.btn_select:setHighlighted(self._info._assistSelect == true)
end

-- function QUIWidgetSilverMineAssist:_onTriggerSelect()
	
-- end

return QUIWidgetSilverMineAssist