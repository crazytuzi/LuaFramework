--
-- Author: Qinyuanji
-- Date: 2015-1-20
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUnionBar = class("QUIWidgetUnionBar", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUnionAvatar = import("...utils.QUnionAvatar")

function QUIWidgetUnionBar:ctor(options)
	local ccbFile = "ccb/Widget_society_union_sheet.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerJoin", callback = handler(self, QUIWidgetUnionBar._onTriggerJoin)},
		{ccbCallbackName = "onTriggerCancelJoin", callback = handler(self, QUIWidgetUnionBar._onTriggerCancelJoin)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIWidgetUnionBar._onTriggerInfo)},
	}
	QUIWidgetUnionBar.super.ctor(self, ccbFile, callBacks, options)

	q.setButtonEnableShadow(self._ccbOwner.btn_join)
	self:setInfo(options)
end

function QUIWidgetUnionBar:setInfo(info)
	if info == nil then return end
	self._info = info
	self._ccbOwner.name:setString(info.name or "")
	-- self._ccbOwner.announcement:setString(info.notice or "")
	self._ccbOwner.minLevel:setString((info.applyTeamLevel or 23).."级")	

	local memberLimit = QStaticDatabase:sharedDatabase():getSocietyMemberLimitByLevel(info.level) or ""

	self._ccbOwner.capacity:setString((info.memberCount or 1).."/"..memberLimit)
	self._ccbOwner.unionLevel:setString("LV."..info.level or 1)

	if info.memberCount == memberLimit then
		self._ccbOwner.maxCount:setVisible(true)
		self._ccbOwner.node_btn_join:setVisible(false)
		self._ccbOwner.cancelJoinBtn:setVisible(false)
		self._ccbOwner.capacity:setColor(UNITY_COLOR.red)

	else
		self._ccbOwner.maxCount:setVisible(false)
		self._ccbOwner.capacity:setColor(UNITY_COLOR.green)
		if info.apply then
			self._ccbOwner.node_btn_join:setVisible(false)
			self._ccbOwner.cancelJoinBtn:setVisible(true)
		else
			self._ccbOwner.node_btn_join:setVisible(true)
			self._ccbOwner.cancelJoinBtn:setVisible(false)
		end
	end

	self._ccbOwner.sp_search:setVisible(info.isSearch or false)

	if info.authorize == 1 then
		self._ccbOwner.applyLimit:setString("需申请")
	elseif info.authorize == 2 then
		self._ccbOwner.applyLimit:setString("自由加入")
	else
		self._ccbOwner.applyLimit:setString("禁止加入")
		self._ccbOwner.node_btn_join:setVisible(false)
		self._ccbOwner.cancelJoinBtn:setVisible(false)
	end

	self._ccbOwner.first:setVisible(false)
	self._ccbOwner.second:setVisible(false)
	self._ccbOwner.third:setVisible(false)
	self._ccbOwner.other:setVisible(false)
	if info.rank == 0 then
		self._ccbOwner.first:setVisible(true)

	elseif info.rank == 1 then
		self._ccbOwner.second:setVisible(true)
	elseif info.rank == 2 then
		self._ccbOwner.third:setVisible(true)
	else
		self._ccbOwner.other:setVisible(true)
		self._ccbOwner.other:setString(info.rank + 1)
	end

	local unionAvatar = QUnionAvatar.new(info.icon)
    unionAvatar:setConsortiaWarFloor(info.consortiaWarFloor)
	self._ccbOwner.node_item:removeAllChildren()
	self._ccbOwner.node_item:addChild(unionAvatar)

	self._applyPowerLimit = info.applyPowerLimit or 0
	if self._applyPowerLimit > 0 then
		local num,unit = q.convertLargerNumber(info.applyPowerLimit)
		self._ccbOwner.forceLimit:setString(num..(unit or ""))
		self._ccbOwner.minLevel:setPositionY(36)
		self._ccbOwner.applyLimit:setPositionY(-15)
	else
		self._ccbOwner.forceLimit:setString("")
		self._ccbOwner.minLevel:setPositionY(20)
		self._ccbOwner.applyLimit:setPositionY(-5)		
	end
end



function QUIWidgetUnionBar:_onTriggerInfo(e)
	if e ~= nil then app.sound:playSound("common_common") end
	remote.union:unionGetRequest(self._info.sid, function(data)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionPrompt",
    		options = {info = data.consortia}}, {isPopCurrentDialog = false})
	end)
end

function QUIWidgetUnionBar:_onTriggerJoin(event)
	if event ~= nil then app.sound:playSound("common_common") end
	if self._info.applyTeamLevel > remote.user.level then
		app.tip:floatTip("您当前的等级不符合申请要求！")
        return
	end
	local topNForce = remote.herosUtil:getMostHeroBattleForce()
	if self._applyPowerLimit > topNForce then
		app.tip:floatTip("您当前的战力不符合申请要求！")
        return		
	end

	if not remote.user:checkJoinUnionCdAndTips() then return end

	-- local joinCD = QStaticDatabase.sharedDatabase():getConfigurationValue("ENTER_SOCIETY") * 60 
	-- local leave_at  = 0
	-- if remote.user.userConsortia.leave_at and remote.user.userConsortia.leave_at >0 then
	-- 	joinCD = remote.user.userConsortia.leave_at/1000 + joinCD - q.serverTime()	
	-- 	if joinCD > 0 then
	-- 		app.tip:floatTip(string.format("%d小时%d分钟内无法加入宗门", math.floor(joinCD/(60*60)), math.floor((joinCD/60)%60))) 
	-- 		return
	-- 	end
	-- end

	remote.union:unionApplyRequest(self._info.sid, function (data)
		if data.consortia.apply then
			self:setInfo(data.consortia)
		else
			remote.union:unionOpenRequest(function (data)
					if next(data.consortia) then
						app.tip:floatTip("恭喜您，加入宗门成功！") 
						remote.union:resetSocietyDungeonData()
						app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
					    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionMain", options = {info = data.consortia}})
					end
				end)
		end
	end)
end

function QUIWidgetUnionBar:_onTriggerCancelJoin(e)
	if e ~= nil then app.sound:playSound("common_common") end
	remote.union:unionApplyCancelRequest(self._info.sid, function (data)
		app.tip:floatTip("取消申请成功！")
		self:setInfo(data.consortia)
	end)
end

function QUIWidgetUnionBar:getContentSize()
	return self._ccbOwner.bg:getContentSize()
end

return QUIWidgetUnionBar