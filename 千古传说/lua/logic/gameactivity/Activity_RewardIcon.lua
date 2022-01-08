local Activity_RewardIcon = class("Activity_RewardIcon", BaseLayer)


local RewardIconNum = 5
function Activity_RewardIcon:ctor(type)
    self.super.ctor(self)
    self.id     = type
    local activityInfo = OperationActivitiesManager:getActivityInfo(self.id)
    if activityInfo ~= nil then
        self.type   = activityInfo.type
    end
    

    self:init("lua.uiconfig_mango_new.operatingactivities.011")
end

function Activity_RewardIcon:initUI(ui)
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

    local height = 0

    local activity      = OperationActivitiesManager:getActivityInfo(self.id)
    local desc1, desc2  = OperationActivitiesManager:getRewardItemDesc(self.type)
    local rewardList    = activity.activityReward

    print("self.type = ", self.type)
    print("self.desc1 = ", desc1)
    print("self.desc2 = ", desc2)

    --init reward information
    local rewardWidgetArray = TFArray:new()
    local rewardCount = rewardList:length()
    local position = ccp(50,self.img_award:getPosition().y-50)
    for i=1,rewardCount do
        local rewardData = rewardList:objectAt(i)

        local widget = Public:createIconNumNode(rewardData);
        widget:setScale(0.6)
        widget:setPosition(ccp(position.x + (i-1)%RewardIconNum * 80 + 80,position.y - math.floor(i/RewardIconNum)*80))
        self.panel_content:addChild(widget)
        rewardWidgetArray:push(widget)

    end
    height = position.y - math.floor(rewardCount/RewardIconNum)*80

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

    -- if EnumActivitiesType.ZHAOBUG == self.type or EnumActivitiesType.YAOHAOYOU == self.type or EnumActivitiesType.TEN_CARD == self.type or EnumActivitiesType.HAPPY_TOGETHER == self.type or EnumActivitiesType.PAY_FOR_REDBAG == self.type then
    --     self.img_reward:setVisible(false)
    -- end

    -- if EnumActivitiesType.V8_PRIZE == self.type then
    --     self.img_reward:setVisible(false)
    -- end

    -- self.img_reward:setVisible(false)

    if OperationActivitiesManager.Type_Ten_Card == self.type then
        -- self.img_reward:setVisible(false)

        local size = self.panel_content:getSize()
        print("size.width = ", size.width)
        local button = TFButton:create()
        local pos = ccp(size.width/2, -480)
        self.panel_content:addChild(button)
        button:setTextureNormal("ui_new/operatingactivities/new/btn_quzhaomu.png")
        button:setAnchorPoint(ccp(0.5, 0.5))
        button:setPosition(pos)
        button:setZOrder(100)
        button:addMEListener(TFWIDGET_CLICK,
        function()
            MallManager:openRecruitLayer()
        end)
    
    elseif OperationActivitiesManager.Type_Hit_Egg == self.type then
        self.img_reward:setVisible(false)

        local size = self.panel_content:getSize()
        local button = TFButton:create()
        local pos = ccp(size.width/2, -480)
        self.panel_content:addChild(button)
        button:setTextureNormal("ui_new/zadan/btn_zadan.png")
        button:setAnchorPoint(ccp(0.5, 0.5))
        button:setPosition(pos)
        button:setZOrder(100)
        button:addMEListener(TFWIDGET_CLICK,
        function()
            GoldEggManager:openGoldEggMainLayer()
        end)
    elseif OperationActivitiesManager.Type_Active_XunBao == self.type then
        self.img_reward:setVisible(false)

        local size = self.panel_content:getSize()
        local button = TFButton:create()
        local pos = ccp(size.width/2, -480)
        self.panel_content:addChild(button)
        button:setTextureNormal("ui_new/treasure/btn_xunbao.png")
        button:setAnchorPoint(ccp(0.5, 0.5))
        button:setPosition(pos)
        button:setZOrder(100)
        button:addMEListener(TFWIDGET_CLICK,
        function()
            TreasureManager:requestConfigMessage()
        end)

    end
end

function Activity_RewardIcon:isStatusComplete( status )
    if status == 4 or status == 5 then
        return true
    end

    return false
end

function Activity_RewardIcon:resortReward()
    -- local rewardList =  OperationActivitiesManager:getActivityRewardList(11)
    -- local rewardCount = self.rewardList:length()

    -- print("rewardCount = ", rewardCount)
    
    -- for i=1,rewardCount do
    --     local widget = self.rewardWidgetArray:objectAt(i)
    --     print("i = ", i)
    --     widget.status =  OperationActivitiesManager:getActivityRewardStatus(self.id, widget.rewardData_id)
    -- end
end
function Activity_RewardIcon:removeUI()
    self.super.removeUI(self)
end

function Activity_RewardIcon:onShow()
    self.super.onShow(self)
 --    local rewardCount = self.rewardWidgetArray:length()
	-- for i=1,rewardCount do
	-- 	local widget = self.rewardWidgetArray:objectAt(i)
	-- 	widget:onShow()
	-- end
    self:refreshUI()
end

function Activity_RewardIcon:dispose()
    self.super.dispose(self)
end

function Activity_RewardIcon:refreshUI()   
    print("当前活动类型 = ", self.type)

    self:resortReward();



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

    self.txt_content:setTextAreaSize(CCSizeMake(430,0))
    local content_high = math.max(self.txt_content:getContentSize().height,100)
    self.img_reward:setPositionY(-205 - (content_high - 100))
    self.img_award:setPositionY(-218 - (content_high - 100))

    local rewardCount = self.rewardWidgetArray:length()
    local position = ccp(50,self.img_award:getPosition().y-50)
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        widget:setPosition(ccp(position.x +  (i-1)%RewardIconNum * 80 + 80,position.y - math.floor((i-1)/RewardIconNum)*80))
    end



    local txt_cost = nil
    

    if OperationActivitiesManager.Type_Total_Recharge == self.type or self.type == OperationActivitiesManager.Type_Total_Recharge or self.type == OperationActivitiesManager.Type_Continue_Recharge then
        self.img_yichongzhi:setVisible(true)
        txt_cost = TFDirector:getChildByPath(self.img_yichongzhi, 'txt_cost')

    elseif OperationActivitiesManager.Type_Total_Consume == self.type then
        self.img_yixiaofei:setVisible(true)
        txt_cost = TFDirector:getChildByPath(self.img_yixiaofei, 'txt_cost')

    elseif OperationActivitiesManager.Type_Continue_Login == self.type then
        self.img_denglu:setVisible(true)
        txt_cost = TFDirector:getChildByPath(self.img_denglu, 'txt_cost')

    end


    if txt_cost then 
        txt_cost:setText(OperationActivitiesManager:getActivityVaule(self.id))
    end


    if self.type == OperationActivitiesManager.Type_Continue_Recharge then
        if self.extendDesc == nil then
            local parent = self.img_reward:getParent()
            local pos    = self.img_reward:getPosition()

            local extendLabel = TFLabel:create()
            extendLabel:setAnchorPoint(ccp(0, 0.5))
            extendLabel:setPosition(pos)
            extendLabel:setPositionX(pos.x + 60)
            extendLabel:setFontSize(22)
            extendLabel:setColor(ccc3(0, 0, 0))
            parent:addChild(extendLabel)

            self.extendDesc = extendLabel
        end

        --self.extendDesc:setText("连续充值第"..activity.progress.."天")
        self.extendDesc:setText(stringUtils.format(localizable.activity_comm_pay,activity.progress))
    end

end


function Activity_RewardIcon:setLogic(logic)
    self.logic = logic
end

function Activity_RewardIcon:registerEvents()
    print("Activity_RewardIcon:registerEvents()------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        self:refreshUI()
    end;

    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
end

function Activity_RewardIcon:removeEvents()
    print("Activity_RewardIcon:removeEvents()------------------")
    self.super.removeEvents(self)
    -- TFDirector:removeMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
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
function Activity_RewardIcon:getDateString(timestamp)

    if not timestamp then
        return
    end

    local date   = os.date("*t", timestamp)

    -- return date.year.."年"..date.month.."月"..date.day.."日"..date.hour.."时"

    --return date.month.."月"..date.day.."日"..date.hour.."时"..date.min.."分"
    return stringUtils.format(localizable.common_time_4, date.month,date.day,date.hour,date.min)
end

return Activity_RewardIcon