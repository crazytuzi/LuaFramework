--
-- Author: Kumo.Wang
-- 宗門活躍排行榜
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionActivityRank = class("QUIWidgetSocietyUnionActivityRank", QUIWidget)
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSocietyUnionInfoSheet = import(".QUIWidgetSocietyUnionInfoSheet")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIWidgetSocietyUnionActivityRank:ctor(options)
	local ccbFile = "Widget_society_union_activity.ccbi"
	local callBacks = {}
	QUIWidgetSocietyUnionActivityRank.super.ctor(self,ccbFile,callBacks,options)

	self._memberList = {}
	self._moveIndex = 0
end

function QUIWidgetSocietyUnionActivityRank:onEnter()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED_OTHER, self._kickedUnionMember, self)

	if (remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "") then
		return
	end
	
	self:updateData()
	self:setInfo()
end

function QUIWidgetSocietyUnionActivityRank:onExit()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED_OTHER, self._kickedUnionMember, self)
end

function QUIWidgetSocietyUnionActivityRank:_kickedUnionMember(event)
	if self._ccbView then
		self._moveIndex = event.index or 0
		self:updateData()
	end
end

function QUIWidgetSocietyUnionActivityRank:updateData(  )
	 remote.union:consortiaGetMemberActiveListRequest(function (data)
	 	if self._ccbView then
	        self._memberList =  data.consortiaFighters
	        table.sort(self._memberList, function(a, b)
	        		if a.weekActiveDegree ~= b.weekActiveDegree then
	        			return a.weekActiveDegree > b.weekActiveDegree
	        		elseif a.totalActiveDegree ~= b.totalActiveDegree then
	        			return a.totalActiveDegree > b.totalActiveDegree
	        		elseif a.todayActiveDegree ~= b.todayActiveDegree then
	        			return a.todayActiveDegree > b.todayActiveDegree
	        		elseif a.force ~= b.force then
	        			return a.force > b.force
	        		else
	        			return a.lastLeaveTime > b.lastLeaveTime
	        		end
	        	end)
	        QPrintTable(self._memberList)
	        self:setInfo()
	    end
    end) 
end

function QUIWidgetSocietyUnionActivityRank:setInfo()
	self._moveIndex = self._moveIndex > #self._memberList and #self._memberList or self._moveIndex

	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._memberList[index]
	            if not item then
	                item = QUIWidgetSocietyUnionInfoSheet.new()
	                isCacheNode = false
	            end
	            item:setInfo(data, index, remote.union.ACTIVITY_MODULE_TYPE)
	            info.item = item
	            info.size = item:getContentSize()
	         
	            -- list:registerClickHandler(index, "self", function() return true end, nil, "_onTriggerLook")
	            list:registerBtnHandler(index, "btn_activity_info", "_onTriggerActivityInfo", nil, true)
	            list:registerBtnHandler(index, "btn_click", "_onTriggerLook")
	         

	            return isCacheNode
	        end,
	        spaceY = 5,
	        spaceY = 0,
	   		enableShadow = true,
	        curOffset = 5, 
	        curOriginOffset = -4,
	        totalNumber = #self._memberList,
	        contentOffsetX = -1,
    	} 
    	self._listView = QListView.new(self._ccbOwner.listView, cfg)
    else
    	self._listView:reload({totalNumber = #self._memberList, isCleanUp = true}) 
    	if self._moveIndex > 3 then
    		self._listView:startScrollToIndex(self._moveIndex, true, 500)
    	end
	end
end

return QUIWidgetSocietyUnionActivityRank
