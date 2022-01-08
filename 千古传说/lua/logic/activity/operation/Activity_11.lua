local Activity_11 = class("Activity_11", BaseLayer)

function Activity_11:ctor(type)

    self.super.ctor(self)
    self.id     = type
    self.type   = type--EnumActivitiesType.TEAM_LEVEL_UP_REWARD
    
    self.desc1  = "累计充值"
    self.desc2  = "元宝"

    self:init("lua.uiconfig_mango_new.operatingactivities.011")
end

function Activity_11:initUI(ui)
    self.super.initUI(self,ui)
    self.img_award 				= TFDirector:getChildByPath(ui, 'img_award')

    self.scroll_view 			= TFDirector:getChildByPath(ui, 'scroll_view')
    self.panel_content 			= TFDirector:getChildByPath(ui, 'panel_content')
    self.txt_time               = TFDirector:getChildByPath(ui, 'txt_time')
    self.txt_content            = TFDirector:getChildByPath(ui, 'txt_content')

    local height = 0

    local rewardList = OperationActivitiesManager:getActivityRewardList(self.id, self.type)

    --init reward information
    local rewardWidgetArray = TFArray:new()
    local rewardCount = rewardList:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
    for i=1,rewardCount do
    	local rewardData = rewardList:objectAt(i)

    	local widget = require('lua.logic.activity.operation.RewardItemCommon'):new(self.id, self.type, rewardData.id, self.desc1, self.desc2)
    	widget:setPosition(ccp(position.x,position.y))
    	self.panel_content:addChild(widget)
        widget.index = i
        widget.rewardData_id = rewardData.id
        widget.status = OperationActivitiesManager:getActivityRewardStatus(self.id, self.type, rewardData.id )
    	position.y = position.y - 136
    	rewardWidgetArray:push(widget)


        height = position.y - 136
    end

    -- 动态调整高度
    height = 0 - height
    local scrollViewContentsize = self.scroll_view:getContentSize().height
    if height < scrollViewContentsize then
        height = scrollViewContentsize
    end

    self.rewardList = rewardList
    self.rewardWidgetArray = rewardWidgetArray
    self:refreshUI()

    local size = self.scroll_view:getInnerContainerSize()

    -- print("size1 = ", size)
    -- print("height = ", height)
    self.scroll_view:setInnerContainerSize(CCSizeMake(size.width, height))
    size = self.scroll_view:getInnerContainerSize()
    -- print("size2 = ", size)

    -- 重设高度
    self.panel_content:setPosition(ccp(0, height))
end


function Activity_11:isStatusComplete( status )
    if status == 4 or status == 5 then
        return true
    end
    return false
end

function Activity_11:resortReward()
    -- local rewardList =  OperationActivitiesManager:getActivityRewardList(11)
    local rewardCount = self.rewardList:length()
    
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        widget.status =  OperationActivitiesManager:getActivityRewardStatus(self.id, self.type, widget.rewardData_id)
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
function Activity_11:removeUI()
    self.super.removeUI(self)
end

function Activity_11:onShow()
    self.super.onShow(self)
    local rewardCount = self.rewardWidgetArray:length()
	for i=1,rewardCount do
		local widget = self.rewardWidgetArray:objectAt(i)
		widget:onShow()
	end
    self:refreshUI()
end

function Activity_11:dispose()
    self.super.dispose(self)
end

function Activity_11:refreshUI()    
    self:resortReward();
	local rewardCount = self.rewardWidgetArray:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
	for i=1,rewardCount do
		local widget = self.rewardWidgetArray:objectAt(i)
		widget:refreshUI()
        widget:setPosition(ccp(position.x,position.y))
        position.y = position.y - 136
	end


    local activity = OperationActivitiesManager:getActivityData(self.id, self.type)

    if not activity then
        self.txt_time:setText("")
        self.txt_content:setText("")

    else
        -- os.date("%x", os.time()) <== 返回自定义格式化时间字符串（完整的格式化参数），这里是"11/28/08"
        local startTime = self:getDateString(activity.startTime)
        local endTime   = self:getDateString(activity.endTime)

 
        self.txt_time:setText(startTime .. " / " .. endTime)
        self.txt_content:setText(activity.details)
    end
end

function Activity_11:setLogic(logic)
    self.logic = logic
end

function Activity_11:registerEvents()
    print("Activity_11:registerEvents()------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        self:refreshUI()
    end;

    TFDirector:addMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
end

function Activity_11:removeEvents()
    print("Activity_11:removeEvents()------------------")
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
end

-- ├┄┄sec=0,
-- ├┄┄min=0,
-- ├┄┄day=28,
-- ├┄┄isdst=false,
-- ├┄┄wday=3,
-- ├┄┄yday=209,
-- ├┄┄year=2015,
-- ├┄┄month=7,
-- ├┄┄hour=0
function Activity_11:getDateString(timestamp)

    if not timestamp then
        return
    end

    local date   = os.date("*t", timestamp)

    return date.year.."年"..date.month.."月"..date.day.."日"..date.hour.."时"
end

return Activity_11