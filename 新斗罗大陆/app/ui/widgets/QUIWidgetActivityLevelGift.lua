
--zxs

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityLevelGift = class("QUIWidgetActivityLevelGift", QUIWidget)
local QUIWidgetActivityLevelGiftItem = import("..widgets.QUIWidgetActivityLevelGiftItem")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

function QUIWidgetActivityLevelGift:ctor(options)
	local ccbFile = "ccb/Widget_Activity.ccbi"
  	local callBacks = {
  	}
	QUIWidgetActivityLevelGift.super.ctor(self,ccbFile,callBacks,options)
    
    self._targets = {}
end

function QUIWidgetActivityLevelGift:onEnter()
    QUIWidgetActivityLevelGift.super.onEnter(self)
end

function QUIWidgetActivityLevelGift:onExit(  )
    QUIWidgetActivityLevelGift.super.onEnter(self)
    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler) 
        self._scheduler = nil
    end
end

function QUIWidgetActivityLevelGift:initListView(  )
    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local item = list:getItemFromCache()

            local data = self._targets[index]
            if not item then
                item = QUIWidgetActivityLevelGiftItem.new()
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

function QUIWidgetActivityLevelGift:updateTime( )
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

function QUIWidgetActivityLevelGift:setInfo(info)
    self._leftTime = info.end_at/1000 - q.serverTime()
    if self._leftTime <= 0 then
        self._ccbOwner.tf_time:setString("")
    else
        self._ccbOwner.tf_time:setString(q.timeToHourMinuteSecond(self._leftTime))
        if not self._scheduler then
            self._scheduler = scheduler.scheduleGlobal(handler(self, self.updateTime), 1)
        end
    end
    self._info = info
    self._targets = info.targets
    self._ccbOwner.tf_desc:setString(info.description or "")
    
    if info.banner and info.banner ~= "" then
        local namePath = "ui/Activity_game/"..info.banner
        QSetDisplayFrameByPath(self._ccbOwner.sp_banner, namePath)
        self._ccbOwner.sp_banner:setVisible(true)
    end 
    
    if not self._contentListView then
        self:initListView()
    else
        self._contentListView:refreshData()
    end
end


function QUIWidgetActivityLevelGift:onTriggerConfirm( x, y, touchNode, listView )
    app.sound:playSound("common_confirm")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    local target = item:getInfo()
    local awards = item:getAwards()
    local activityId = self._info.activityId
    local activityTargetId = target.activityTargetId
    if not target.isComplete and remote.user.level >= target.value then
        app:getClient():activityCompleteRequest(activityId, activityTargetId, nil, nil, function ()
            local dialog = app:alertAwards({awards = awards})
            dialog:setTitle("恭喜获得冲级礼包奖励")
            remote.activity:setCompleteDataById(activityId ,activityTargetId)
        end)
    else
        app.tip:floatTip("条件不足")
    end
end

return QUIWidgetActivityLevelGift