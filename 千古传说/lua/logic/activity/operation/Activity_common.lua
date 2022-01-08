local Activity_common = class("Activity_common", BaseLayer)

function Activity_common:ctor(type)
    self.super.ctor(self)
    self.id     = type
    self.type   = type--EnumActivitiesType.TEAM_LEVEL_UP_REWARD

    self:init("lua.uiconfig_mango_new.operatingactivities.011")
end

function Activity_common:initUI(ui)
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

    local rewardList    = OperationActivitiesManager:getActivityRewardList(self.type)
    local desc1, desc2  = OperationActivitiesManager:getRewardItemDesc(self.type)

    --init reward information
    local rewardWidgetArray = TFArray:new()
    local rewardCount = rewardList:length()
    local position = ccp(20,self.img_award:getPosition().y-150)
    for i=1,rewardCount do
    	local rewardData = rewardList:objectAt(i)

    	local widget = require('lua.logic.activity.operation.RewardItemCommon'):new(self.type, rewardData.id, desc1, desc2, i)
    	widget:setPosition(ccp(position.x,position.y))
    	self.panel_content:addChild(widget)
        widget.index = i
        widget.rewardData_id = rewardData.id
        widget.status = OperationActivitiesManager:getActivityRewardStatus( self.type, rewardData.id )
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


    if EnumActivitiesType.ZHAOBUG == self.type or EnumActivitiesType.YAOHAOYOU == self.type or EnumActivitiesType.TEN_CARD == self.type or EnumActivitiesType.HAPPY_TOGETHER == self.type or EnumActivitiesType.PAY_FOR_REDBAG == self.type then
        self.img_reward:setVisible(false)
    end

    if EnumActivitiesType.V8_PRIZE == self.type then
        self.img_reward:setVisible(false)
    end

    if EnumActivitiesType.TEN_CARD == self.type then
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
    end
end

function Activity_common:isStatusComplete( status )
    if status == 4 or status == 5 then
        return true
    end

    return false
end

function Activity_common:resortReward()
    -- local rewardList =  OperationActivitiesManager:getActivityRewardList(11)
    local rewardCount = self.rewardList:length()

    print("rewardCount = ", rewardCount)
    
    for i=1,rewardCount do
        local widget = self.rewardWidgetArray:objectAt(i)
        print("i = ", i)
        widget.status =  OperationActivitiesManager:getActivityRewardStatus(self.type, widget.rewardData_id)
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
function Activity_common:removeUI()
    self.super.removeUI(self)
end

function Activity_common:onShow()
    self.super.onShow(self)
    local rewardCount = self.rewardWidgetArray:length()
	for i=1,rewardCount do
		local widget = self.rewardWidgetArray:objectAt(i)
		widget:onShow()
	end
    self:refreshUI()
end

function Activity_common:dispose()
    self.super.dispose(self)
end

function Activity_common:refreshUI()   
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


    local activity = OperationActivitiesManager:getActivityData(self.type)

    if not activity then
        self.txt_time:setText("")
        self.txt_content:setText("")

    else
        -- os.date("%x", os.time()) <== 返回自定义格式化时间字符串（完整的格式化参数），这里是"11/28/08"
        local startTime = ""
        local endTime   = ""

        if activity.startTime then
            startTime = self:getDateString(activity.startTime)
        end

        if activity.endTime then
            endTime   = self:getDateString(activity.endTime)
        end

        if activity.startTime and activity.endTime then
            self.txt_time:setText(startTime .. " - " .. endTime)
        elseif activity.startTime == nil and activity.endTime == nil then
            self.txt_time:setText("永久有效")
        else
            self.txt_time:setText(startTime .. " - " .. endTime)
        end

        self.txt_content:setText(activity.details)
    end

    local txt_cost = nil
    
    if EnumActivitiesType.LEIJICHONGZHI == self.type or self.type == EnumActivitiesType.DANGRICHONGZHI then
        self.img_yichongzhi:setVisible(true)
        txt_cost = TFDirector:getChildByPath(self.img_yichongzhi, 'txt_cost')

    elseif EnumActivitiesType.LEIJIXIAOFEI == self.type or self.type == EnumActivitiesType.DANGRIXIAOFEI then
        self.img_yixiaofei:setVisible(true)
        txt_cost = TFDirector:getChildByPath(self.img_yixiaofei, 'txt_cost')

    elseif EnumActivitiesType.LIANXUDENGLU == self.type then
        self.img_denglu:setVisible(true)
        txt_cost = TFDirector:getChildByPath(self.img_denglu, 'txt_cost')

    end


    if txt_cost then 
        txt_cost:setText(OperationActivitiesManager:getActivityVaule(self.type))
    end

end


function Activity_common:setLogic(logic)
    self.logic = logic
end

function Activity_common:registerEvents()
    print("Activity_common:registerEvents()------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        self:refreshUI()
    end;

    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD,self.updateRewardCallback)
    -- TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS,self.updateRewardCallback)
end

function Activity_common:removeEvents()
    print("Activity_common:removeEvents()------------------")
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
function Activity_common:getDateString(timestamp)

    if not timestamp then
        return
    end

    local date   = os.date("*t", timestamp)

    -- return date.year.."年"..date.month.."月"..date.day.."日"..date.hour.."时"

    return date.month.."月"..date.day.."日"..date.hour.."时"..date.min.."分"
end

return Activity_common