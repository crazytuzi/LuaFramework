local ActivityOnline = class("ActivityOnline", BaseLayer)

function ActivityOnline:ctor(data)
    self.super.ctor(self)
    self.activityId = data
    self:init("lua.uiconfig_mango_new.operatingactivities.011")
end

function ActivityOnline:initUI(ui)
    self.super.initUI(self,ui)
    self.img_award 				= TFDirector:getChildByPath(ui, 'img_award')

    self.scroll_view 			= TFDirector:getChildByPath(ui, 'scroll_view')
    self.panel_content 			= TFDirector:getChildByPath(ui, 'panel_content')

    self.img_yichongzhi          = TFDirector:getChildByPath(ui, 'img_yichongzhi')
    self.img_yixiaofei          = TFDirector:getChildByPath(ui, 'img_yixiaofei')
    self.img_denglu             = TFDirector:getChildByPath(ui, 'img_denglu')

    self.txt_content            = TFDirector:getChildByPath(ui, 'txt_content')

    self.txt_time               = TFDirector:getChildByPath(ui, 'txt_time')

    self.img_yichongzhi:setVisible(false)
    self.img_yixiaofei:setVisible(false)
    self.img_denglu:setVisible(false)

    --init reward information
    local rewardWidgetArray = TFArray:new()
    local rewardList        = OperationActivitiesManager:getActivityRewardList(self.activityId)

    local rewardCount       = rewardList:length()

    local position = ccp(20,self.img_award:getPosition().y-150)

    local height = 0
    for i=1,rewardCount do
    	local rewardData = rewardList:objectAt(i)
    	local minutes = rewardData.id / 60
        minutes = string.format("%.0f",minutes)
        timeText = OperationActivitiesManager:TimeConvertString(rewardData.id)
    	local widget = require('lua.logic.gameactivity.RewardItemOnline'):new(self.activityId, rewardData.id, timeText, i)
    	widget:setPosition(ccp(position.x,position.y))
    	self.panel_content:addChild(widget)
        widget.index = i
        widget.rewardData_id = rewardData.id
        widget.minutes = minutes
        -- widget.status = OperationActivitiesManager:calculateRewardState(self.activityId,rewardData.id)
        widget.status = OperationActivitiesManager:getActivityRewardStatus( self.activityId, rewardData.id )

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
    self.scroll_view:setInnerContainerSize(CCSizeMake(size.width, height))
    size = self.scroll_view:getInnerContainerSize()

    -- 重设高度
    self.panel_content:setPosition(ccp(0, height))
    
    -- print("self.OnlineRewardTimes = ", self.OnlineRewardTimes)

    -- local ActivityStatus = OperationActivitiesManager:getActivityStatus(EnumActivitiesType.ONLINE_REWARD)
    -- print("ActivityStatus = ", ActivityStatus)
    -- local startTime = OperationActivitiesManager:parseTime(ActivityStatus.startTime)
    -- local endTime   = OperationActivitiesManager:parseTime(ActivityStatus.endTime)

    -- self.txt_time:setText(startTime.."—"..endTime)

end



function ActivityOnline:isStatusComplete( index )
    if index <= self.OnlineRewardTimes then
        return true
    end
    return false
end

function ActivityOnline:resortReward()

    -- print(".activityData = ", OperationActivitiesManager.activityData)

    self.OnlineRewardTimes = OperationActivitiesManager.OnlineRewardData.onlineRewardCount
    local rewardCount = self.rewardList:length()

    print("rewardCount =" , rewardCount)
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)

        local rewardData = self.rewardList:objectAt(i)
        -- widget.status = OperationActivitiesManager:calculateRewardState(self.activityId,widget.rewardData_id)
        print("rewardData.type = ", self.activityId )
        print("rewardData.id = ", rewardData.id )

        widget.status = OperationActivitiesManager:getActivityRewardStatus( self.activityId, rewardData.id )
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
function ActivityOnline:removeUI()
    self.super.removeUI(self)
end

function ActivityOnline:onShow()
    -- print("ActivityOnline:onShow")
    self.super.onShow(self)
 --    local rewardCount = self.rewardWidgetArray:length()
	-- for i=1,rewardCount do
	-- 	local widget = self.rewardWidgetArray:objectAt(i)
	-- 	widget:onShow()
	-- end

    self.rewardList       = OperationActivitiesManager:getActivityRewardList(self.activityId)

    self:refreshUI()
end

function ActivityOnline:dispose()
    self.super.dispose(self)
end

function ActivityOnline:refreshUI()
    self:resortReward()

    local rewardCount = self.rewardWidgetArray:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        widget:setPosition(ccp(position.x,position.y))
        position.y = position.y - 136
    end
    self:drawOnlineReward()


    local activity = OperationActivitiesManager:getActivityData(self.activityId)
    if not activity then
        self.txt_time:setText("")
        self.txt_content:setText("")

    else
        -- os.date("%x", os.time()) <== 返回自定义格式化时间字符串（完整的格式化参数），这里是"11/28/08"
        local startTime = ""
        local endTime   = ""

        -- 0、活动强制无效，不显示该活动；1、长期显示该活动 2、自动检测，过期则不显示',
        local status = activity.status or 1

        if status == 1 then
            --self.txt_time:setText("永久有效")
            self.txt_time:setText(localizable.common_time_longlong)

        else
            if activity.startTime then
                startTime = self:getDateString(activity.startTime)
            end
            if activity.endTime then
                endTime   = self:getDateString(activity.endTime)
            end

            self.txt_time:setText(startTime .. " - " .. endTime)
        end

        self.txt_content:setText(activity.details)
    end
end

function ActivityOnline:setLogic(logic)
    self.logic = logic
end

function ActivityOnline:registerEvents()
        print(" ActivityOnline:registerEvents----------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        print(" ActivityOnline:registerEvents")
        self:refreshUI()
    end;

    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,       self.updateRewardCallback)
    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,  self.updateRewardCallback)
    -- -- GET_ACITIVTY_REWARD_SUCCESS
end

function ActivityOnline:removeEvents()
        print(" ActivityOnline:removeEvents----------------------")
    self.super.removeEvents(self)

    -- TFDirector:removeMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    -- TFDirector:removeMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,  self.updateRewardCallback)

    OperationActivitiesManager:removeOnlineRewardTimer(1002)
end

function ActivityOnline:drawOnlineReward()
    
    self.OnlineRewardTimes = OperationActivitiesManager.OnlineRewardData.onlineRewardCount

    -- print("OnlineRewardTimes = ", self.OnlineRewardTimes)

    local rewardCount = self.rewardWidgetArray:length()
    for i=1,rewardCount do
        local rewardData = self.rewardList:objectAt(i)

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

                OperationActivitiesManager:addOnlineRewardListener(widget, 1002, ActivityOnline.onlineRewardUpdate)

                widget.btn_get.bOpen = true
                widget:refreshUI()
            else
                widget.btn_get.bOpen = false
                widget:refreshUI()
            end

            widget.btn_get.index = widget.index 
            widget.btn_get.logic = self
            widget.btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onclikReward),1)
            
            -- local txt = OperationActivitiesManager:TimeConvertString(rewardData.id)

            -- print("index = "..rewardData.id.."             text = ",txt)
            -- widget.txt_title:setText(txt)
        end
    end
end

function ActivityOnline.onlineRewardUpdate(sender)

    local widget = sender.logic

    local index = widget.index 

    -- print("sender.desc = ", sender.desc)

    widget:refreshUI()
    widget.txt_title:setText(sender.desc)
end

function ActivityOnline.onclikReward(sender)
    if sender.bOpen == false then
        --toastMessage("亲，要先领过前面的在线奖励")
        toastMessage(localizable.activity_online_award)
        return
    end

    local x     = sender.index
    local self  = sender.logic

    print("online self.activityId = ", self.activityId)
    -- print("x =", x)
    OperationActivitiesManager:sendMsgToGetActivityReward(self.activityId, sender.index)
end

-- status = 0 未开启  status == 1 ing status == 2 已领
function ActivityOnline:drawItemBtn(widget, status)
    if not widget then
        return
    end
    -- OperationActivitiesManager:getOnlineReward()



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


function ActivityOnline:getDateString(timestamp)

    if not timestamp then
        return
    end

    local date   = os.date("*t", timestamp)

    -- return date.year.."年"..date.month.."月"..date.day.."日"..date.hour.."时"
   --return date.month.."月"..date.day.."日"..date.hour.."时"..date.min.."分"
    return stringUtils.format(localizable.common_time_4, date.month,date.day,date.hour,date.min)
   
end


return ActivityOnline