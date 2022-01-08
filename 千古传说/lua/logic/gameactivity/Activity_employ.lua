local Activity_employ = class("Activity_employ", BaseLayer)

function Activity_employ:ctor(type)
    self.super.ctor(self)
    self.id     = type
    local activityInfo = OperationActivitiesManager:getActivityInfo(self.id)
    if activityInfo ~= nil then
        self.type   = activityInfo.type
    end
    
    self:init("lua.uiconfig_mango_new.operatingactivities.011")
end

function Activity_employ:initUI(ui)
    self.super.initUI(self,ui)
    self.img_award 				= TFDirector:getChildByPath(ui, 'img_award')

    self.scroll_view 			= TFDirector:getChildByPath(ui, 'scroll_view')
    self.panel_content 			= TFDirector:getChildByPath(ui, 'panel_content')
    self.txt_time               = TFDirector:getChildByPath(ui, 'txt_time')
    self.txt_content            = TFDirector:getChildByPath(ui, 'txt_content')
    self.img_yichongzhi         = TFDirector:getChildByPath(ui, 'img_yichongzhi')
    self.img_yixiaofei          = TFDirector:getChildByPath(ui, 'img_yixiaofei')
    self.img_denglu             = TFDirector:getChildByPath(ui, 'img_denglu')

    self.img_reward             = TFDirector:getChildByPath(ui, 'img_reward')



    -- 酒馆招募活动，每个条目分为三个类型 (1普通 2高级 3十连抽)
    local pos = self.img_reward:getPosition()
    -- local employLabel = TFLabel:create()
    -- employLabel:setAnchorPoint(ccp(0, 0.5))
    -- employLabel:setPosition(ccp(pos.x+60, pos.y))
    -- employLabel:setFontSize(26)
    -- employLabel:setColor(ccc3(0, 0, 0))
    -- employLabel:setText("123123")

    -- self.panel_content:addChild(employLabel)
    -- self.employLabel = employLabel

    
    local rewardItemImage = TFImage:create("ui_new/operatingactivities/new/img_yzmcs.png")
    rewardItemImage:setPosition(pos)
    rewardItemImage:setPositionY(pos.y + 10)
    self.panel_content:addChild(rewardItemImage)

    -- pos = rewardItemImage:getPosition()
    local employLabel = TFLabel:create()
    employLabel:setAnchorPoint(ccp(0, 0.5))
    employLabel:setPosition(ccp(pos.x+60+10, pos.y+10))
    employLabel:setFontSize(26)
    employLabel:setColor(ccc3(0, 0, 0))
    employLabel:setText("123123")

    self.panel_content:addChild(employLabel)
    self.employLabel = employLabel


    pos = self.img_reward:getPosition()
    self.img_reward:setPositionY(pos.y-20)

    local height = 0

    local activity      = OperationActivitiesManager:getActivityInfo(self.id)
    local desc1, desc2  = OperationActivitiesManager:getRewardItemDesc(self.type)
    local rewardList    = activity.activityReward

    --init reward information
    local rewardWidgetArray = TFArray:new()
    local rewardCount = rewardList:length()
    local position = ccp(20, rewardItemImage:getPosition().y-20)
    for i=1,rewardCount do
    	local rewardData = rewardList:objectAt(i)

    	local widget = require('lua.logic.gameactivity.RewardItemEmploy'):new(self.id, self.type, rewardData.id, desc1, desc2, i)
    	widget:setPosition(ccp(position.x,position.y))
    	self.panel_content:addChild(widget)
        widget.index = i
        widget.rewardData_id = rewardData.id
        widget.status = OperationActivitiesManager:getActivityRewardStatus(self.id, rewardData.id )
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


    -- 
    self.img_yichongzhi:setVisible(false)
    self.img_yixiaofei:setVisible(false)
    self.img_denglu:setVisible(false)

    print("activity.reward = ", activity.reward)
    if activity and activity.reward and activity.reward ~= "" then
        self.img_reward:setVisible(true)
    else
        self.img_reward:setVisible(false)
    end

end

function Activity_employ:isStatusComplete( status )
    if status == 4 or status == 5 then
        return true
    end

    return false
end

function Activity_employ:resortReward()
    -- local rewardList =  OperationActivitiesManager:getActivityRewardList(11)
    local rewardCount = self.rewardList:length()

    print("rewardCount = ", rewardCount)
    
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        print("i = ", i)
        widget.status =  OperationActivitiesManager:getActivityRewardStatus(self.id, widget.rewardData_id)
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
function Activity_employ:removeUI()
    self.super.removeUI(self)
end

function Activity_employ:onShow()
    self.super.onShow(self)
    local rewardCount = self.rewardWidgetArray:length()
	for i=1,rewardCount do
		local widget = self.rewardWidgetArray:objectAt(i)
		widget:onShow()
	end
    self:refreshUI()
end

function Activity_employ:dispose()
    self.super.dispose(self)
end

function Activity_employ:refreshUI()   
    print("当前活动类型 = ", self.type)

    self:resortReward();
	local rewardCount = self.rewardWidgetArray:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
	for i=1,rewardCount do
		local widget = self.rewardWidgetArray:objectAt(i)
		widget:refreshUI()
        widget:setPosition(ccp(position.x,position.y))
        position.y = position.y - 136
	end


    local activity = OperationActivitiesManager:getActivityInfo(self.id)

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

    --local desc = {"普通招募", "高级招募", "十连抽"}
    local desc = localizable.activity_recruit_type
    local employDesc = ""
    if self.employLabel then
        for i=1,3 do
            local count = activity.employStatus[i] or 0
            --employDesc = string.format("%s%s%d次  ", employDesc, desc[i], count)
	    employDesc = stringUtils.format(localizable.activity_employDesc, employDesc, desc[i], count)
        end

        self.employLabel:setText(employDesc)
    end

end


function Activity_employ:setLogic(logic)
    self.logic = logic
end

function Activity_employ:registerEvents()
    print("Activity_employ:registerEvents()------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        self:refreshUI()
    end;

    TFDirector:addMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_GET_REWARD,self.updateRewardCallback)
    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)


    TFDirector:addMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_PROGRESS_UPDATE,self.updateRewardCallback)
end

function Activity_employ:removeEvents()
    print("Activity_employ:removeEvents()------------------")
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_GET_REWARD,self.updateRewardCallback)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_PROGRESS_UPDATE,self.updateRewardCallback)
    
    self.updateRewardCallback = nil
    -- TFDirector:removeMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
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
function Activity_employ:getDateString(timestamp)

    if not timestamp then
        return
    end

    local date   = os.date("*t", timestamp)

    -- return date.year.."年"..date.month.."月"..date.day.."日"..date.hour.."时"

    --return date.month.."月"..date.day.."日"..date.hour.."时"..date.min.."分"
    return stringUtils.format(localizable.common_time_4, date.month, date.day, date.hour, date.min)
end

return Activity_employ