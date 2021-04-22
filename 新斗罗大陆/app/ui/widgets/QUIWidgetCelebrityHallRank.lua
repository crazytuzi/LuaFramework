local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCelebrityHallRank = class("QUIWidgetCelebrityHallRank", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActivityItem = import("..widgets.QUIWidgetActivityItem")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

function QUIWidgetCelebrityHallRank:ctor(options)
	local ccbFile = "ccb/Widget_CelebrityHallRank.ccbi"
  	local callBacks = {}
	QUIWidgetCelebrityHallRank.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetCelebrityHallRank:onEnter()
	QUIWidgetCelebrityHallRank.super.onEnter(self)
end

function QUIWidgetCelebrityHallRank:initListView()
    if type(self._targets) ~= "table" then
        self._targets = {}
    end

    local cfg = {
        renderItemCallBack = function( list, index, info )
            local isCacheNode = true
            local item = list:getItemFromCache()
            local data = self._targets[index]
            if not item then
                item = QUIWidgetActivityItem.new()
                isCacheNode = false
            end

            item:setInfo(data.activityId, data, self)
            info.item = item
            info.size = item:getContentSize()

            list:registerTouchHandler(index,"onTouchListView")

            return isCacheNode
        end,
        spaceY = 5,
        totalNumber = #self._targets,
    }  
    self._contentListView = QListView.new(self._ccbOwner.content_sheet_layout,cfg)
end

function QUIWidgetCelebrityHallRank:getContentListView(  )
    return self._contentListView
end

function QUIWidgetCelebrityHallRank:setInfo(info)
    --时间
    local startTimeTbl = q.date("*t", (info.start_at or 0)/1000)
    local endTimeTbl = q.date("*t", (info.end_at or 0)/1000)
    timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
        startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
        endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
    self._ccbOwner.tf_time:setString(timeStr)
    --描述
    self._ccbOwner.tf_desc:setString(info.description)
    --列表
	local targets = info.targets
	table.sort(targets, function (a,b)
		return a.index < b.index
	end)
    self._targets = targets
    if not self._contentListView then
        self:initListView()
    else
        self._contentListView:reload({totalNumber = #targets})
    end
end

return QUIWidgetCelebrityHallRank