
--zxs

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityLevelRace = class("QUIWidgetActivityLevelRace", QUIWidget)
local QUIWidgetActivityForceItem = import("..widgets.QUIWidgetActivityForceItem")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")


function QUIWidgetActivityLevelRace:ctor(options)
	local ccbFile = "ccb/Widget_Activity.ccbi"
  	local callBacks = {
  	}
	QUIWidgetActivityLevelRace.super.ctor(self,ccbFile,callBacks,options)
    
    self._targets = {}
    app:getClient():getUserLevelRank(function( data )
        if self:safeCheck() and data.userLevelInfo and self._contentListView then
            for k, v in pairs(self._targets) do
                v.myRank = data.userLevelInfo.selfRank
                v.level = data.userLevelInfo.level
                v.exp = data.userLevelInfo.exp
            end
            self._contentListView:refreshData()
        end
    end)

    self._ccbOwner.tf_desc:setString("又是一个牛逼的活动")
end

function QUIWidgetActivityLevelRace:onEnter()
	QUIWidgetActivityLevelRace.super.onEnter(self)
end

function QUIWidgetActivityLevelRace:onExit(  )
    QUIWidgetActivityLevelRace.super.onEnter(self)
    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler) 
        self._scheduler = nil
    end
end

function QUIWidgetActivityLevelRace:initListView(  )
    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local item = list:getItemFromCache()

            local data = self._targets[index]
            if not item then
                item = QUIWidgetActivityForceItem.new()
                isCacheNode = false
            end
            item:setInfo(data)
            info.item = item
            info.size = item:getContentSize()
            item:registerItemBoxPrompt(index,list)
            list:registerBtnHandler(index, "btn_ok", handler(self, self.onTriggerConfirm),nil,true)
            return isCacheNode
        end,
        spaceY = 5,
        totalNumber = #self._targets,
    }  
    self._contentListView = QListView.new(self._ccbOwner.content_sheet_layout,cfg)

end

function QUIWidgetActivityLevelRace:updateTime( )
    -- body
    self._leftTime = self._leftTime - 1
    if self._leftTime <= 0 then
        if self._scheduler then
            scheduler.unscheduleGlobal(self._scheduler) 
            self._scheduler = nil
        end
    else
        self._ccbOwner.tf_time:setString(q.timeToHourMinuteSecond(self._leftTime))
    end
end


function QUIWidgetActivityLevelRace:setInfo(info)
    self._leftTime = info.end_at/1000 - q.serverTime()
    if self._leftTime <= 0 then
        self._ccbOwner.tf_time:setString("")
    else
        self._ccbOwner.tf_time:setString(q.timeToHourMinuteSecond(self._leftTime))
        if not self._scheduler then
            self._scheduler = scheduler.scheduleGlobal(handler(self, self.updateTime), 1)
        end
    end
    self._ccbOwner.tf_desc:setString(info.description or "")
    if info.banner and info.banner ~= "" then
        local namePath = "ui/Activity_game/"..info.banner
        QSetDisplayFrameByPath(self._ccbOwner.sp_banner, namePath)
        self._ccbOwner.sp_banner:setVisible(true)
    end 

	local activities = db:getStaticByName("activity_warm_blood_level")
	local targets = {}
	for _,activity in pairs(activities) do
		table.insert(targets, activity)
	end
	table.sort( targets, function (a,b)
		return a.ID < b.ID
	end )
    self._targets = targets

    if not self._contentListView then
        self:initListView()
    else
        self._contentListView:reload({totalNumber = #targets})
    end
end

return QUIWidgetActivityLevelRace