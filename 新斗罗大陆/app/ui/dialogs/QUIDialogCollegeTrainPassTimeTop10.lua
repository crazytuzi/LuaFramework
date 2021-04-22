-- @Author: liaoxianbo
-- @Date:   2019-12-19 17:04:28
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-26 16:35:15
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainPassTimeTop10 = class("QUIDialogCollegeTrainPassTimeTop10", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetCollegeTrainPassTimeTop10 = import("..widgets.QUIWidgetCollegeTrainPassTimeTop10")
local QListView = import("...views.QListView")

function QUIDialogCollegeTrainPassTimeTop10:ctor(options)
	local ccbFile = "ccb/Dialog_CollegeTrain_PassTime_tips.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogCollegeTrainPassTimeTop10.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._rankData = {}
    -- for i=1,10 do
    -- 	table.insert(self._rankData,{rank= i,name = "豆超傻逼"..i.."号",passTime = 18258245})
    -- end

    remote.collegetrain:getCollegeTrainTop10(options.selectInfo.id,function(data)
    	if data.rankings then 
    		if data.rankings.top50 then
	    		for _,v in pairs(data.rankings.top50) do
	    			table.insert(self._rankData,{rank= v.rank,name = v.name,passTime = v.passTime})
	    		end
	    	end
	    	self:updateMyInfo(data.rankings.myself)
    	end
	    self:initListView()
    end)
    
end

function QUIDialogCollegeTrainPassTimeTop10:viewDidAppear()
	QUIDialogCollegeTrainPassTimeTop10.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogCollegeTrainPassTimeTop10:viewWillDisappear()
  	QUIDialogCollegeTrainPassTimeTop10.super.viewWillDisappear(self)

	self:removeBackEvent()
end
function QUIDialogCollegeTrainPassTimeTop10:updateMyInfo(myselfInfo )
	if myselfInfo then
		if myselfInfo.rank then
			self._ccbOwner.tf_myName:setString(myselfInfo.rank.." "..remote.user.nickname or "")
		else
			self._ccbOwner.tf_myName:setString("未上榜".." "..remote.user.nickname or "")
		end
		if myselfInfo.passTime then
			local myPassTime = string.format("%0.2f秒", tonumber(myselfInfo.passTime or 0) / 1000.0 )
			-- self._ccbOwner.tf_myPassTime:setString(q.timeToHourMinuteSecond(tonumber(myselfInfo.passTime),true))
			self._ccbOwner.tf_myPassTime:setString(myPassTime)
		else
			self._ccbOwner.tf_myPassTime:setString("未通关")
		end
	else
		self._ccbOwner.tf_myName:setString("未上榜".." "..remote.user.nickname or "")
		self._ccbOwner.tf_myPassTime:setString("未通关")
	end
end

function QUIDialogCollegeTrainPassTimeTop10:initListView()
    if not self._rankListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._rankData[index]
	            if not item then
	                item = QUIWidgetCollegeTrainPassTimeTop10.new()
	                isCacheNode = false
	            end
	            item:setRankInfo(data)
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        headIndex = self._curSelectBtnIndex,
	        enableShadow = false,
	        ignoreCanDrag = true,
	        totalNumber = #self._rankData,
	        spaceY = 6,

	    }  
	    self._rankListView = QListView.new(self._ccbOwner.sheet_layer,cfg)
	 else
	 	self._rankListView:reload({totalNumber = #self._rankData})
	 end
end
function QUIDialogCollegeTrainPassTimeTop10:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogCollegeTrainPassTimeTop10:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCollegeTrainPassTimeTop10:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainPassTimeTop10
