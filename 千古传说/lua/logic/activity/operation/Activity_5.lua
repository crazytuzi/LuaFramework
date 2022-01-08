local Activity_5 = class("Activity_5", BaseLayer)

function Activity_5:ctor(data)
    self.super.ctor(self)
    self.type = EnumActivitiesType.ONLINE_REWARD
    self:init("lua.uiconfig_mango_new.operatingactivities.005")
end

function Activity_5:initUI(ui)
    self.super.initUI(self,ui)
    self.img_award 				= TFDirector:getChildByPath(ui, 'img_award')

    self.scroll_view 			= TFDirector:getChildByPath(ui, 'scroll_view')
    self.panel_content 			= TFDirector:getChildByPath(ui, 'panel_content')

    --init reward information
    local rewardWidgetArray = TFArray:new()
    local rewardCount = OnlineReward:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
    --local width = 434
    --local height = 0
    --local bottomY = 0
    --local parent = self.img_award:getParent()
    for i=1,rewardCount do
    	local rewardData = OnlineReward:objectAt(i)
    	local minutes = rewardData.delay / 60
        minutes = string.format("%.0f",minutes)
    	local widget = require('lua.logic.activity.operation.RewardItem'):new(self.type,rewardData.id,minutes)
    	widget:setPosition(ccp(position.x,position.y))
    	self.panel_content:addChild(widget)
        widget.index = i
        widget.rewardData_id = rewardData.id
        widget.minutes = minutes
        widget.status = OperationActivitiesManager:calculateRewardState(self.type,rewardData.id)
    	position.y = position.y - 136
    	rewardWidgetArray:push(widget)
    end

    self.rewardWidgetArray = rewardWidgetArray
    self:refreshUI()

    -- print("self.OnlineRewardTimes = ", self.OnlineRewardTimes)

    self.txt_time       = TFDirector:getChildByPath(ui, 'txt_time')
    local ActivityStatus = OperationActivitiesManager:getActivityStatus(EnumActivitiesType.ONLINE_REWARD)
    print("ActivityStatus = ", ActivityStatus)
    local startTime = OperationActivitiesManager:parseTime(ActivityStatus.startTime)
    local endTime   = OperationActivitiesManager:parseTime(ActivityStatus.endTime)

    self.txt_time:setText(startTime.."—"..endTime)

end

function Activity_5:isStatusComplete( index )
    if index <= self.OnlineRewardTimes then
        return true
    end
    return false
end

function Activity_5:resortReward()
    self.OnlineRewardTimes = OperationActivitiesManager.rewardRecord.onlineRewardCount
    local rewardCount = LogonReward:length()
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        widget.status = OperationActivitiesManager:calculateRewardState(self.type,widget.rewardData_id)
    end
    local function cmpFun(widget1, widget2)
        if self:isStatusComplete(widget1.index) and self:isStatusComplete(widget2.index) == false then
            return false;
        elseif self:isStatusComplete(widget1.index) ==false and self:isStatusComplete(widget2.index) == true then
            return true;
        else
            if widget1.index < widget2.index then
                return true;
            else
                return false;
            end
        end
    end

    self.rewardWidgetArray:sort(cmpFun)
end
function Activity_5:removeUI()
    self.super.removeUI(self)
end

function Activity_5:onShow()
    -- print("Activity_5:onShow")
    self.super.onShow(self)
 --    local rewardCount = self.rewardWidgetArray:length()
	-- for i=1,rewardCount do
	-- 	local widget = self.rewardWidgetArray:objectAt(i)
	-- 	widget:onShow()
	-- end
    self:refreshUI()
end

function Activity_5:dispose()
    self.super.dispose(self)
end

function Activity_5:refreshUI()
    self:resortReward()
    local rewardCount = self.rewardWidgetArray:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        widget:setPosition(ccp(position.x,position.y))
        position.y = position.y - 136
    end
    self:drawOnlineReward()
end

function Activity_5:setLogic(logic)
    self.logic = logic
end

function Activity_5:registerEvents()
        print(" Activity_5:registerEvents----------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        print(" Activity_5:registerEvents")
        self:refreshUI()
    end;

    TFDirector:addMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,       self.updateRewardCallback)
    TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,  self.updateRewardCallback)
    -- GET_ACITIVTY_REWARD_SUCCESS
end

function Activity_5:removeEvents()
        print(" Activity_5:removeEvents----------------------")
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,  self.updateRewardCallback)

    OperationActivitiesManager:stopOnlineRewardTimer(1002)
end

function Activity_5:drawOnlineReward()
    
    self.OnlineRewardTimes = OperationActivitiesManager.rewardRecord.onlineRewardCount

    print("OnlineRewardTimes = ", self.OnlineRewardTimes)

    local rewardCount = self.rewardWidgetArray:length()
    for i=1,rewardCount do
        local rewardData = OnlineReward:objectAt(i)

        local widget = self.rewardWidgetArray:objectAt(i)
        -- 已经领取过了在线奖励
        if widget.index <= self.OnlineRewardTimes  then
            widget:refreshUI()
            
            widget.txt_title:setText("00:00:00")
            -- widget.btn_get:setGrayEnabled(true)
            -- widget.btn_get:setTouchEnabled(false)
            
            --self:drawItemBtn(widget, 2)
        else
            if widget.index == (self.OnlineRewardTimes + 1) then
                -- print("开启在线奖励定时器")
                OperationActivitiesManager:setOnlineRewardTimer(widget, 1002, Activity_5.onlineRewardUpdate)
                widget.btn_get.bOpen = true

                --self:drawItemBtn(widget, 1)
                widget:refreshUI()
            else
                widget.btn_get.bOpen = false

                --self:drawItemBtn(widget, 0)
                widget:refreshUI()
            end
            widget.btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onclikReward),1)
            
            local txt = OperationActivitiesManager:TimeConvertString(rewardData.delay)
            widget.txt_title:setText(txt)
        end
    end
end

function Activity_5.onlineRewardUpdate(sender)
    local widget = sender.logic

    widget:refreshUI()
    widget.txt_title:setText(sender.desc)
end

function Activity_5.onclikReward(sender)
    if sender.bOpen == false then
        toastMessage("亲，要先领过前面的在线奖励")
        return
    end

    OperationActivitiesManager:getOnlineReward()
end


-- status = 0 未开启  status == 1 ing status == 2 已领
function Activity_5:drawItemBtn(widget, status)
    if not widget then
        return
    end

    if status == 0 then
        widget.btn_get:setGrayEnabled(true)
        widget.btn_get:setTouchEnabled(false)

        widget.img_ylq:setVisible(false)

    elseif status == 1 then
        widget.btn_get:setGrayEnabled(false)
        widget.btn_get:setTouchEnabled(true)

        widget.img_ylq:setVisible(false)   
    elseif status == 2 then
        widget.btn_get:setVisible(false)

        widget.img_ylq:setVisible(true)  
    end
end


return Activity_5