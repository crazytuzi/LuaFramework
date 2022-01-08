
local Activity_4 = class("Activity_4", BaseLayer)

function Activity_4:ctor(data)
    self.super.ctor(self)
    self.type = EnumActivitiesType.LOGON_REWARD
    self:init("lua.uiconfig_mango_new.operatingactivities.004")
end

function Activity_4:initUI(ui)
    self.super.initUI(self,ui)
    self.img_award 				= TFDirector:getChildByPath(ui, 'img_award')

    self.scroll_view 			= TFDirector:getChildByPath(ui, 'scroll_view')
    self.panel_content 			= TFDirector:getChildByPath(ui, 'panel_content')

    --init reward information
    local rewardWidgetArray = TFArray:new()
    local rewardCount = LogonReward:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
    for i=1,rewardCount do
    	local rewardData = LogonReward:objectAt(i)
    	local widget = require('lua.logic.activity.operation.RewardItem'):new(self.type,rewardData.id,i)
    	widget:setPosition(ccp(position.x,position.y))
    	self.panel_content:addChild(widget)
        widget.index = i
        widget.rewardData_id = rewardData.id
        widget.status = OperationActivitiesManager:calculateRewardState(self.type,rewardData.id)
    	position.y = position.y - 136
    	rewardWidgetArray:push(widget)
    end

    self.rewardWidgetArray = rewardWidgetArray
    self:refreshUI()

    self.txt_time       = TFDirector:getChildByPath(ui, 'txt_time')

    local ActivityStatus = OperationActivitiesManager:getActivityStatus(EnumActivitiesType.LOGON_REWARD)
    print("ActivityStatus = ", ActivityStatus)
    local startTime = OperationActivitiesManager:parseTime(ActivityStatus.startTime)
    local endTime   = OperationActivitiesManager:parseTime(ActivityStatus.endTime)

    self.txt_time:setText(startTime.."—"..endTime)
end

function Activity_4:isStatusComplete( status )
    if status == 4 or status == 5 then
        return true
    end
    return false
end

function Activity_4:resortReward()
    local rewardCount = LogonReward:length()
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        widget.status = OperationActivitiesManager:calculateRewardState(self.type,widget.rewardData_id)
    end
    local function cmpFun(widget1, widget2)
        if self:isStatusComplete(widget1.status) and self:isStatusComplete(widget2.status) == false then
            return false;
        elseif self:isStatusComplete(widget1.status) ==false and self:isStatusComplete(widget2.status) == true then
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

function Activity_4:removeUI()
    self.super.removeUI(self)
end

function Activity_4:onShow()
    print("Activity_4:onShow() -------------")
    self.super.onShow(self)
    local rewardCount = self.rewardWidgetArray:length()
	for i=1,rewardCount do
		local widget = self.rewardWidgetArray:objectAt(i)
		widget:onShow()
	end
    self:refreshUI()
end

function Activity_4:dispose()
    self.super.dispose(self)
end

function Activity_4:refreshUI()
    self:resortReward()
	local rewardCount = self.rewardWidgetArray:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
	for i=1,rewardCount do
		local widget = self.rewardWidgetArray:objectAt(i)
		widget:refreshUI()
        widget:setPosition(ccp(position.x,position.y))
        position.y = position.y - 136
	end
end

function Activity_4:setLogic(logic)
    self.logic = logic
end

function Activity_4:registerEvents()
    print("Activity_4:registerEvents()------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        
        self:refreshUI()
    end;

    TFDirector:addMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
end

function Activity_4:removeEvents()
    print("Activity_4:removeEvents()------------------")
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
end

return Activity_4