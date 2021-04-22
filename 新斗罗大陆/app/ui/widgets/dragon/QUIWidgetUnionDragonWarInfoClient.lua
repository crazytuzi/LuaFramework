local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarInfoClient = class("QUIWidgetUnionDragonWarInfoClient", QUIWidget)
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

function QUIWidgetUnionDragonWarInfoClient:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_info_sheet.ccbi"
	local callBack = {
	}
	QUIWidgetUnionDragonWarInfoClient.super.ctor(self, ccbFile, callBack, options)

end

function QUIWidgetUnionDragonWarInfoClient:getContentSize()
	return self._ccbOwner.btnLook:getContentSize()
end

function QUIWidgetUnionDragonWarInfoClient:setInfo(info, tab)
	self._ccbOwner.node_btn:setVisible(false)
	self._ccbOwner.node_done:setVisible(false)
	self._ccbOwner.tf_contribution:setVisible(false)
	self._ccbOwner.tf_member_buff:setVisible(false)
	
	local num,unit = q.convertLargerNumber(info.topnForce or "")
	self._ccbOwner.tf_force:setString(num..(unit or ""))
	self._ccbOwner.tf_level:setString("LV."..info.teamLevel or "")
	self._ccbOwner.tf_name:setString(info.memberName or "")
	self._ccbOwner.tf_vip:setString("VIP"..(info.vipLv or 0))
	self._ccbOwner.node_icon:removeAllChildren()
	if info.icon ~= nil then
		local avatar = QUIWidgetAvatar.new(info.icon)
		avatar:setSilvesArenaPeak(info.championCount)
		self._ccbOwner.node_icon:addChild(avatar)
	end
	if info.identityType == SOCIETY_OFFICIAL_POSITION.BOSS then
		self._ccbOwner.tf_role:setString("宗主")
	elseif info.identityType == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
		self._ccbOwner.tf_role:setString("副宗主")
	elseif info.identityType == SOCIETY_OFFICIAL_POSITION.ELITE then
		self._ccbOwner.tf_role:setString("精英")
	else
		self._ccbOwner.tf_role:setString("成员")
	end
	local num,unit = q.convertLargerNumber(info.todayHurt or 0)
	self._ccbOwner.tf_hurt1:setString(num..(unit or ""))
	if tab == "DAMAGE" then
		local num,unit = q.convertLargerNumber(info.weekHurt or 0)
		self._ccbOwner.tf_hurt2:setString(num..(unit or ""))
	elseif tab == "BUFF" then
		self._ccbOwner.tf_hurt2:setString("")
		if remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.BOSS and remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.ADJUTANT then
			self._ccbOwner.node_btn:setVisible(false)
			if info.isHolyedWeekly then
				self._ccbOwner.tf_member_buff:setVisible(true)
			end
		else
			self._ccbOwner.node_btn:setVisible(true)
			if info.isHolyedWeekly then
				self._ccbOwner.tf_wear:setString("已开启")
				makeNodeFromNormalToGray(self._ccbOwner.node_btn)
				self._ccbOwner.tf_wear:disableOutline()
			else
				makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
				self._ccbOwner.tf_wear:enableOutline()
			end
		end
	end

	local nodes = {}
	table.insert(nodes, self._ccbOwner.tf_level)
	table.insert(nodes, self._ccbOwner.tf_name)
	table.insert(nodes, self._ccbOwner.tf_vip)
	q.autoLayerNode(nodes, "x", 5)
end

return QUIWidgetUnionDragonWarInfoClient