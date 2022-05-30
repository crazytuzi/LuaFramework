OnlineGiftWindow = OnlineGiftWindow or BaseClass(BaseView)

local controller = OnlineGiftController:getInstance()
local get_time_items = Config.MiscData.data_get_time_items
local length = Config.MiscData.data_get_time_items_length
function OnlineGiftWindow:__init()
    self.is_full_screen = false
    self.layout_name = "onlinegift/onlinegift_windows"
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        --{path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_online_gift"), type = ResourcesType.single},
    }
    self.item_list = {}
end

function OnlineGiftWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local bg = self.root_wnd:getChildByName("bg")

    --local res = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_online_gift")
    --if not self.item_load then
    --    self.item_load = createResourcesLoad(res, ResourcesType.single, function()
    --        if not tolua.isnull(bg) then
    --            loadSpriteTexture(bg,res,LOADTEXT_TYPE)
    --        end
    --    end,self.item_load)
    --end
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openOnlineGiftView(false)
        end
    end)
    self:playEnterAnimatianByObj(bg , 2)
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.textTime = self.main_container:getChildByName("textTime")
    self.main_container:getChildByName("Text_1"):setString(TI18N("下档奖励: "))

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.goods_con:setScrollBarEnabled(false)
    
    self:getOnlineItems()
end

function OnlineGiftWindow:getOnlineItems()
    self.goods_con:setInnerContainerSize(cc.size(511,0.9*119*(math.floor(length/4)) + 30))
    local pos_y = self.goods_con:getInnerContainerSize().height - 60
    for i=1, length do
        if not self.item_list[i] then
            self.item_list[i] = BackPackItem.new(true,true,nil,0.9)
            self.item_list[i]:setAnchorPoint(0, 0.5)
            self.goods_con:addChild(self.item_list[i])
        end
        if self.item_list[i] and get_time_items[i] then
            local tvl = (i-1)%4
            local width = BackPackItem.Width * tvl
            local height = BackPackItem.Height * math.floor((i-1)/4)
            self.item_list[i]:setPosition(cc.p(19+width+tvl*15,pos_y - height))
            self.item_list[i]:setBaseData(get_time_items[i].items[1][1], get_time_items[i].items[1][2])
            self.item_list[i]:addCallBack(function ()
                controller:sender10927(get_time_items[i].index)
            end)
        end
    end
end

--设置倒计时
function OnlineGiftWindow:setLessTime(less_time)
    if tolua.isnull(self.textTime) then return end
    self.textTime:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.textTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.textTime:stopAllActions()
                self.textTime:setString("00:00:00")
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function OnlineGiftWindow:setTimeFormatString(time)
    if time > 0 then
        self.textTime:setString(TimeTool.GetTimeFormat(time))
    else
        self.textTime:setString("00:00:00")
    end
end

function OnlineGiftWindow:register_event()
    self:addGlobalEvent(OnlineGiftEvent.Get_Data, function(data)
        self:updataGetItem(data)
    end)

    self:addGlobalEvent(OnlineGiftEvent.Updata_Data, function(data)
        local num = 1
        for i, v in pairs(get_time_items) do
            if v.time == data then
                num = i
            end
        end
        self.item_list[num]:showExtendTag(true, TI18N("已领取"))
        setChildUnEnabled(true, self.item_list[num])
        self.item_list[num]:showItemEffect(false, 263, PlayerAction.action_1, true, 1.1)
        self.item_list[num]:setDefaultTip(false)
        self.item_list[num]:showStrTips(false)
    end)

    registerButtonEventListener(self.background, function()
        controller:openOnlineGiftView(false)
    end,false, 2)


    registerButtonEventListener(self.main_container, function()
        controller:openOnlineGiftView(false)
    end,false, 2)
end
function OnlineGiftWindow:updataGetItem(data)
    self.data = data
    self.dic_time = {}
    for i,v in ipairs(data.list) do
        self.dic_time[v.time] = true
    end

    local is_show = false --是否显示可领取
    local num = 0
    for i,v in ipairs(get_time_items) do
        if data.time >= v.time then
            num = i
        end
        if self.item_list[i] then
            if self.dic_time[v.time] then
                self.item_list[i]:showExtendTag(true, TI18N("已领取"), true)
                setChildUnEnabled(true, self.item_list[i])
                self.item_list[i]:setDefaultTip(false)
            else
                if i <= num then 
                    --可领取
                    self.item_list[i]:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
                    if not is_show then
                        is_show = true
                        self.item_list[i]:showStrTips(true, TI18N("可领取"))
                    end
                    self.item_list[i]:setDefaultTip(false)
                else
                    --不可领取
                    self.item_list[i]:setDefaultTip(true)
                end
            end
        end
    end

    if data.time >= get_time_items[length].time then
        self:setLessTime(0)
    else
        local time = get_time_items[num+1].time - data.time
        self:setLessTime(time)
    end
end

function OnlineGiftWindow:openRootWnd()
    controller:sender10926()
end

function OnlineGiftWindow:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    doStopAllActions(self.textTime)
    controller:openOnlineGiftView(false)
end
