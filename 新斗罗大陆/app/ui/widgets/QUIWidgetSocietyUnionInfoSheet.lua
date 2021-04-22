--[[	
	文件名称：QUIWidgetSocietyUnionInfoSheet.lua
	创建时间：2016-03-23 18:15:12
	作者：nieming
	描述：QUIWidgetSocietyUnionInfoSheet
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionInfoSheet = class("QUIWidgetSocietyUnionInfoSheet", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("..QUIViewController")

--初始化
function QUIWidgetSocietyUnionInfoSheet:ctor(options)
	local ccbFile = "Widget_society_union_info_sheet.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLook", callback = handler(self, QUIWidgetSocietyUnionInfoSheet._onTriggerLook)},
		{ccbCallbackName = "onTriggerActivityInfo", callback = handler(self, QUIWidgetSocietyUnionInfoSheet._onTriggerActivityInfo)},
	}
	QUIWidgetSocietyUnionInfoSheet.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSocietyUnionInfoSheet:_onTriggerLook()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionHeadpromptNew", 
        options = {info = self._info, index = self._index}}, {isPopCurrentDialog = false})
end

function QUIWidgetSocietyUnionInfoSheet:_onTriggerActivityInfo()
    app.sound:playSound("common_small")
    remote.union:consortiaGetTargetUserActiveInfoRequest(self._info.userId, function(data)
    		if self._ccbView then
    			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionActivityInfo", 
			        options = {data = data.consortiaGetTargetUserActiveInfoResponse.detail, userName = self._info.name}}, {isPopCurrentDialog = false})
    		end
		end)
end

function QUIWidgetSocietyUnionInfoSheet:setInfo(info, index, moduleType)
	self._info = info
	self._index = index
	if not self._avatar then
		self._avatar = QUIWidgetAvatar.new(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	    self._ccbOwner.nodeIcon:addChild(self._avatar)
	else
		self._avatar:setInfo(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	end
	self._ccbOwner.memberLevel:setString("LV."..(info.level or 1))
	self._ccbOwner.memberName:setString(info.name or "")
	self._ccbOwner.vipNum:setString("VIP"..(info.vip or ""))

	if info.lastLeaveTime ~= nil and info.lastLeaveTime > 0 then
		local lastLeaveTime = info.lastLeaveTime/1000
		self._ccbOwner.memberState:setColor(UNITY_COLOR.dark)
		if lastLeaveTime > HOUR then
			local hour = math.floor(lastLeaveTime/HOUR)
			if hour < 24 then
				self._ccbOwner.memberState:setString(string.format("离线%s小时", hour))
			else
				local day = math.floor(hour/24)
				self._ccbOwner.memberState:setString(string.format("离线%s天", day))
				if day > 7 then
					self._ccbOwner.memberState:setString(string.format("离线>7天", day))
				end
			end
		else
			self._ccbOwner.memberState:setString(string.format("离线%s分", math.floor(lastLeaveTime/MIN)))
		end
	else
		self._ccbOwner.memberState:setColor(UNITY_COLOR.green)
		self._ccbOwner.memberState:setString("在线")	
	end

	if info.force then
		if info.force > 1000000 then
			self._ccbOwner.fightNum:setString(math.floor(info.force/10000).."万")
		else
			self._ccbOwner.fightNum:setString(info.force)
		end
	end

	if info.rank then
		if info.rank == SOCIETY_OFFICIAL_POSITION.BOSS then
			self._ccbOwner.memberJob:setString("宗主")
		elseif info.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
			self._ccbOwner.memberJob:setString("副宗主")
		elseif info.rank == SOCIETY_OFFICIAL_POSITION.ELITE then
			self._ccbOwner.memberJob:setString("精英")
		else
			self._ccbOwner.memberJob:setString("成员")
		end
	end
	if not moduleType or moduleType ~= remote.union.ACTIVITY_MODULE_TYPE then
		self._ccbOwner.tf_daily_activity:setString(info.todayActiveDegree or 0)
		self._ccbOwner.tf_daily_activity:setVisible(true)
		self._ccbOwner.tf_total_activity:setVisible(false)
		self._ccbOwner.tf_weekly_activity:setVisible(false)
		self._ccbOwner.btn_activity_info:setVisible(false)
		self._ccbOwner.node_job:setVisible(true)
		self._ccbOwner.memberState:setVisible(true)
		local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(info.soulTrial)
		if frame then
			self._ccbOwner.sp_soulTrial:setDisplayFrame(frame)
			self._ccbOwner.sp_soulTrial:setVisible(true)
		else
			self._ccbOwner.sp_soulTrial:setVisible(false)
		end
		self:_autoLayout()
	elseif moduleType == remote.union.ACTIVITY_MODULE_TYPE then
		self._ccbOwner.tf_total_activity:setString(info.totalActiveDegree or 0)
		self._ccbOwner.tf_weekly_activity:setString(info.weekActiveDegree or 0)
		self._ccbOwner.tf_daily_activity:setVisible(false)
		self._ccbOwner.tf_total_activity:setVisible(true)
		self._ccbOwner.tf_weekly_activity:setVisible(true)
		self._ccbOwner.btn_activity_info:setVisible(true)
		self._ccbOwner.node_job:setVisible(false)
		self._ccbOwner.memberState:setVisible(false)
		self._ccbOwner.sp_soulTrial:setVisible(false)
		self._ccbOwner.memberLevel:setPositionX(105)
		self._ccbOwner.memberName:setPositionX(270)
		self._ccbOwner.memberName:setAnchorPoint(ccp(0.5, 0.5))
		self._ccbOwner.vipNum:setPositionX(370)
	end
end

function QUIWidgetSocietyUnionInfoSheet:_autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.memberLevel)
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.memberName)
	table.insert(nodes, self._ccbOwner.vipNum)
	q.autoLayerNode(nodes, "x", 5)
end

--describe：getContentSize 
function QUIWidgetSocietyUnionInfoSheet:getContentSize()
	--代码
	return self._ccbOwner.btnLook:getContentSize()
end

return QUIWidgetSocietyUnionInfoSheet
