local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityForce = class("QUIWidgetActivityForce", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIWidgetActivityForceItem = import("..widgets.QUIWidgetActivityForceItem")

local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QNotificationCenter = import("...controllers.QNotificationCenter")


function QUIWidgetActivityForce:ctor(options)
	local ccbFile = "ccb/Widget_Activity.ccbi"
  	local callBacks = {
         {ccbCallbackName = "onTriggerRank", callback = handler(self, QUIWidgetActivityForce._onTriggerRank)},
  	}
	QUIWidgetActivityForce.super.ctor(self,ccbFile,callBacks,options)
    
    self._isExit = true
    app:getClient():getBattleForceRank(function( data )
        -- body
        if self._isExit then
            if self._contentListView and type(self._targets) == "table" then
                for k, v in pairs(self._targets) do
                    v.myRank = data.forceRank
                end
                self._contentListView:refreshData()
            end
        end
    end)
end

function QUIWidgetActivityForce:onEnter()
	QUIWidgetActivityForce.super.onEnter(self)
end

function QUIWidgetActivityForce:initListView(  )
    -- body
    if type(self._targets) ~= "table" then
        self._targets = {}
    end

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
            item:setInfo(data, self._info.type)
            info.item = item
            info.size = item:getContentSize()
            item:registerItemBoxPrompt(index,list)
            return isCacheNode
        end,
        enableShadow = false,
        totalNumber = #self._targets,
    }  
    self._contentListView = QListView.new(self._ccbOwner.content_sheet_layout,cfg)

end

function QUIWidgetActivityForce:updateTime( ... )
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

function QUIWidgetActivityForce:onExit(  )
    -- body
    self._isExit = false
    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler) 
        self._scheduler = nil
    end
end

function QUIWidgetActivityForce:setInfo(info)
    self._info = info
    self._leftTime = info.end_at/1000 - q.serverTime()


    local starTime = q.timeToMonthDayHourMin((info.start_at or 0) / 1000)
    local endTime = q.timeToMonthDayHourMin((info.end_at or 0) / 1000)
    self._ccbOwner.tf_time:setString(starTime.."~"..endTime)
    -- if self._leftTime <= 0 then
    --     self._ccbOwner.tf_time:setString("")
    -- else
    --     self._ccbOwner.tf_time:setString(q.timeToHourMinuteSecond(self._leftTime))
    --     if not self._scheduler then
    --         self._scheduler = scheduler.scheduleGlobal(handler(self, self.updateTime), 1)
    --     end
    -- end
    -- self._ccbOwner.tf_time:setString(string.format("%s年%s月%s日%s时", date.year, date.month, date.day, 0))
	local activities = QStaticDatabase:sharedDatabase():getActivityForce()
	local targets = {}
	for _,activity in pairs(activities) do
		table.insert(targets, activity)
	end
	table.sort( targets, function (a,b)
		return a.ID < b.ID
	end )

    self._targets = targets
    self._ccbOwner.tf_desc:setString(info.description or "")
    if not self._contentListView then
        self:initListView()
    else
        self._contentListView:reload({totalNumber = #targets})
    end
end


function QUIWidgetActivityForce:_onTriggerRank(  )
    -- body
     app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
        options = {initRank = "battleForce"}}, 
        {isPopCurrentDialog = false})
end

return QUIWidgetActivityForce