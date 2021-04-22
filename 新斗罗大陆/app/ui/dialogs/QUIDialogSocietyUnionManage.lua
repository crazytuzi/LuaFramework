--[[	
	文件名称：QUIDialogSocietyUnionManage.lua
	创建时间：2016-03-23 17:51:09
	作者：nieming
	描述：QUIDialogSocietyUnionManage 宗门管理
]]

local QUIDialogBaseUnion = import(".QUIDialogBaseUnion")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyUnionManage = class("QUIDialogSocietyUnionManage", QUIDialogBaseUnion)

local QUIWidgetSocietyUnionInfo = import("..widgets.QUIWidgetSocietyUnionInfo")
local QUIWidgetSocietyUnionExamine = import("..widgets.QUIWidgetSocietyUnionExamine")
local QUIWidgetSocietyUnionLog = import("..widgets.QUIWidgetSocietyUnionLog")
local QUIWidgetSocietyUnionLevelGuide = import("..widgets.QUIWidgetSocietyUnionLevelGuide")
local QUIWidgetSocietyUnionActivityRank = import("..widgets.QUIWidgetSocietyUnionActivityRank")

local QNotificationCenter = import("...controllers.QNotificationCenter")

--初始化
function QUIDialogSocietyUnionManage:ctor(options)
	local ccbFile = "Dialog_society_union_manage.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIDialogSocietyUnionManage._onTriggerInfo)},
		{ccbCallbackName = "onTriggerExamine", callback = handler(self, QUIDialogSocietyUnionManage._onTriggerExamine)},
		{ccbCallbackName = "onTriggerLog", callback = handler(self, QUIDialogSocietyUnionManage._onTriggerLog)},
		{ccbCallbackName = "onTriggerDragonLog", callback = handler(self, QUIDialogSocietyUnionManage._onTriggerDragonLog)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogSocietyUnionManage._onTriggerRank)},
		{ccbCallbackName = "onTriggerLevel", callback = handler(self, QUIDialogSocietyUnionManage._onTriggerLevel)},
		{ccbCallbackName = "onTriggerActivety", callback = handler(self, QUIDialogSocietyUnionManage._onTriggerActivety)},
	}
	QUIDialogSocietyUnionManage.super.ctor(self,ccbFile,callBacks,options)
	--代码

	self._ccbOwner.frame_tf_title:setString("宗门管理")
end

function QUIDialogSocietyUnionManage:_init(options)
	if not options then
		options = {}
	end
	self._curSelectBtn = options.curSelectBtn or "onTriggerInfo"
	
	
	self:render()

	self:refreshButtonPosition()
end


function QUIDialogSocietyUnionManage:showRedTips(  )
	if remote.user.userConsortia.rank and remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.MEMBER  and remote.union:checkUnionManageRedTips() then
	
		self._ccbOwner.applyRedTips:setVisible(true)
	else
	
		self._ccbOwner.applyRedTips:setVisible(false)
	end

end

function QUIDialogSocietyUnionManage:refreshButtonPosition()
	local positionY = 191
	local offsetY = 74

	self._ccbOwner.node_btn_union_info:setPositionY(positionY)
	positionY = positionY - offsetY

	self._ccbOwner.node_btn_activity:setPositionY(positionY)
	positionY = positionY - offsetY

	self._ccbOwner.node_union_log:setPositionY(positionY)
	positionY = positionY - offsetY

 	if app.unlock:checkLock("SOCIATY_DRAGON") then
		self._ccbOwner.node_btn_dragon_log:setVisible(true)
		self._ccbOwner.node_btn_dragon_log:setPositionY(positionY)
		positionY = positionY - offsetY
	else
		self._ccbOwner.node_btn_dragon_log:setVisible(false)
	end
	if ENABLE_UNIONLEVEL then
		self._ccbOwner.node_btn_level:setPositionY(positionY)
		positionY = positionY - offsetY
	else
		self._ccbOwner.node_btn_level:setVisible(false)
	end

	self._ccbOwner.node_btn_examine:setPositionY(positionY)
	positionY = positionY - offsetY

	self._ccbOwner.node_btn_rank:setVisible(false)
end


--describe：
function QUIDialogSocietyUnionManage:_onTriggerInfo()
    app.sound:playSound("common_switch")
	if self._curSelectBtn ~= "onTriggerInfo" then
		self._curSelectBtn = "onTriggerInfo"
		self:render()
	end
end

--describe：
function QUIDialogSocietyUnionManage:_onTriggerExamine()
    app.sound:playSound("common_switch")
	if self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.MEMBER then
		return
	end
	if self._curSelectBtn ~= "onTriggerExamine" then
		self._curSelectBtn = "onTriggerExamine"
		self:render()
	end
end

--describe：
function QUIDialogSocietyUnionManage:_onTriggerLog()
    app.sound:playSound("common_switch")
	if self._curSelectBtn ~= "onTriggerLog" then
		self._curSelectBtn = "onTriggerLog"
		self:render()
	end
end

--describe:
function QUIDialogSocietyUnionManage:_onTriggerDragonLog()
	app.sound:playSound("common_switch")
	if self._curSelectBtn ~= "onTriggerDragonLog" then
		self._curSelectBtn = "onTriggerDragonLog"
		self:render()
	end
end

--describe：
function QUIDialogSocietyUnionManage:_onTriggerRank()
	--代码

	-- if self._curSelectBtn ~= "onTriggerRank" then
	-- 	self._curSelectBtn = "onTriggerRank"
	-- 	self:render()
	-- end
end

function QUIDialogSocietyUnionManage:_onTriggerLevel()
	app.sound:playSound("common_switch")
	if self._curSelectBtn ~= "onTriggerLevel" then
		self._curSelectBtn = "onTriggerLevel"
		self:render()
	end
end

function QUIDialogSocietyUnionManage:_onTriggerActivety()
	app.sound:playSound("common_switch")
	if self._curSelectBtn ~= "onTriggerActivety" then
		self._curSelectBtn = "onTriggerActivety"
		self:render()
	end
end


function QUIDialogSocietyUnionManage:render( )
	-- body
	self._myOfficialPosition = remote.user.userConsortia.rank or SOCIETY_OFFICIAL_POSITION.MEMBER
	
	
	if self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.MEMBER and self._curSelectBtn == "onTriggerExamine" then
		self._curSelectBtn = "onTriggerInfo"
	end
	self._ccbOwner.node_btn_examine:setVisible(self._myOfficialPosition ~= SOCIETY_OFFICIAL_POSITION.MEMBER)

	self._ccbOwner.btnInfo:setEnabled(true)
	self._ccbOwner.btnExamine:setEnabled(true)
	self._ccbOwner.btn_union_log:setEnabled(true)
	self._ccbOwner.btn_dragon_log:setEnabled(true)
	self._ccbOwner.btnRank:setEnabled(true)
	self._ccbOwner.btn_level:setEnabled(true)
	self._ccbOwner.btn_activity:setEnabled(true)

	self._ccbOwner.clientNode:removeAllChildren()
	if self._curSelectBtn == "onTriggerInfo" then
		self._ccbOwner.btnInfo:setEnabled(false)
		local widget = QUIWidgetSocietyUnionInfo.new()
		self._ccbOwner.clientNode:addChild(widget)
		self._curWidget = widget

	elseif self._curSelectBtn == "onTriggerExamine" then
		self._ccbOwner.btnExamine:setEnabled(false)
		local widget = QUIWidgetSocietyUnionExamine.new()
		self._ccbOwner.clientNode:addChild(widget)
		self._curWidget = widget

	elseif self._curSelectBtn == "onTriggerLog" then
		self._ccbOwner.btn_union_log:setEnabled(false)
		remote.union:unionLogRequest(function (data)
	        if data.consortiaLogResponse and data.consortiaLogResponse.consortiaLog then
				local widget = QUIWidgetSocietyUnionLog.new({data = data.consortiaLogResponse.consortiaLog})
				widget:setPosition(ccp(-28, 3))
				self._ccbOwner.clientNode:addChild(widget)
				self._curWidget = widget
	        end
	    end) 

	elseif self._curSelectBtn == "onTriggerDragonLog" then
		self._ccbOwner.btn_dragon_log:setEnabled(false)
	    remote.dragon:consortiaDragonLogrequest(function (data)
	        if data.consortiaGetDragonLogResponse and data.consortiaGetDragonLogResponse.consortiaDragonLog then
	        	local dragonLog = data.consortiaGetDragonLogResponse.consortiaDragonLog
				local widget = QUIWidgetSocietyUnionLog.new({data = dragonLog})
				widget:setPosition(ccp(-28, 3))
				self._ccbOwner.clientNode:addChild(widget)
				self._curWidget = widget
	        end
	    end) 
	elseif self._curSelectBtn == "onTriggerRank" then
		self._ccbOwner.btnRank:setEnabled(false)
	elseif self._curSelectBtn == "onTriggerLevel" then
		self._ccbOwner.btn_level:setEnabled(false)
		local widget = QUIWidgetSocietyUnionLevelGuide.new()
		self._ccbOwner.clientNode:addChild(widget)
		widget:setPosition(ccp(-38, 3))
		self._curWidget = widget
	elseif self._curSelectBtn == "onTriggerActivety" then
		self._ccbOwner.btn_activity:setEnabled(false)
		local widget = QUIWidgetSocietyUnionActivityRank.new()
		self._ccbOwner.clientNode:addChild(widget)
		self._curWidget = widget
	end

	self:showRedTips()
end

function QUIDialogSocietyUnionManage:handleJobChange(  )
	-- body
	self:render()
end

function QUIDialogSocietyUnionManage:handleUnionInfoUpdate(  )
	-- body
	self:render()
end

function QUIDialogSocietyUnionManage:handleRedTipsUpdate( )
	-- body
	if self._curSelectBtn == "onTriggerExamine" and remote.user.userConsortia.rank ~= SOCIETY_OFFICIAL_POSITION.MEMBER and self._curWidget then
		self._curWidget:updateData()
	end
	self:showRedTips()
end

--describe：viewDidAppear 
function QUIDialogSocietyUnionManage:viewDidAppear()
	--代码
	QUIDialogSocietyUnionManage.super.viewDidAppear(self)

   

end

-- describe：viewWillDisappear 
function QUIDialogSocietyUnionManage:viewWillDisappear()
	--代码
	QUIDialogSocietyUnionManage.super.viewWillDisappear(self)


end

--describe：viewAnimationInHandler 
--function QUIDialogSocietyUnionManage:viewAnimationInHandler()
	----代码
--end

--describe：_backClickHandler 
--function QUIDialogSocietyUnionManage:_backClickHandler()
	----代码
--end

return QUIDialogSocietyUnionManage
