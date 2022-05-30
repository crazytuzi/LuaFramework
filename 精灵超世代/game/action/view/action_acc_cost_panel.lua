-- --------------------------------------------------------------------
--      累计消费
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ActionAccCostPanel = class("ActionAccCostPanel",function ( ... )
    return ccui.Widget:create()
end)

function ActionAccCostPanel:ctor(bid, type)
    self.holiday_bid = bid
    self.action_type = type
    self.ctrl = ActionController:getInstance()
    self.item_list = {}
    self:configUI()
    self:register_event()
end

function ActionAccCostPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_cost_panel"))
    self.root_wnd:setPosition(-40, -120)
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_con = self.main_container:getChildByName("title_con")
    self.time_val = self.title_con:getChildByName("time_val")
    self.time_title = self.title_con:getChildByName("time_title")
    self.charge_con = self.main_container:getChildByName("charge_con")
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)
    self.title_img = self.title_con:getChildByName("title_img")
    if self.holiday_bid ~= nil or self.holiday_bid ~= 0 and self.action_type ~= nil or self.action_type ~= 0 then
        local tab_vo = self.ctrl:getActionSubTabVo(self.holiday_bid)
        if tab_vo then
            if tab_vo.aim_title == "" then
                tab_vo.aim_title = "txt_cn_action_acc_cost_title"
            end
            local res = PathTool.getTargetRes("bigbg/action",tab_vo.aim_title,false,false)
            if not self.item_load1 then
                self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
            end
        end
    end


    self.charge_btn = self.main_container:getChildByName("charge_btn")
    self.charge_btn:setTitleText(TI18N("立即充值"))
    self.charge_btn.label = self.charge_btn:getTitleRenderer()
    if self.charge_btn.label ~= nil then
        self.charge_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end
    local scroll_view_size = self.charge_con:getContentSize()
    local setting = {
        item_class = ActionAccCostItem,      -- 单元类
        start_x = 13,                  -- 第一个单元的X起点
        space_x = 2,                    -- x方向的间隔
        start_y = 2,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = ActionAccCostItem.Width,               -- 单元的尺寸width
        item_height = ActionAccCostItem.Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.charge_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

end

function ActionAccCostPanel:createList(data)
    if not data then return end
    local item_list = {}
    for i,v in ipairs(data.aim_list) do
        v.sort_index = 1
        if v.status == 1 then
            v.sort_index = 0
        elseif v.status == 2 then
            v.sort_index = 2
        end
        table.insert(item_list,v)
    end
    local sort_func = SortTools.tableLowerSorter({"sort_index","aim"})
    table.sort(item_list,sort_func)
    self.item_scrollview:setData(item_list,nil,nil,data)
    self.item_scrollview:addEndCallBack(
        function()
            local list = self.item_scrollview:getItemList()
            for k, v in pairs(list) do
                v:setHolidayBid(self.holiday_bid)
            end
        end
    )
    self:setLessTime(data.remain_sec)
end

--设置倒计时
function ActionAccCostPanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    self.time_val:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(
                        function()
                            less_time = less_time - 1
                            if less_time < 0 then
                                self.time_val:stopAllActions()
                            else
                                self:setTimeFormatString(less_time)
                            end
                        end
                    )
                )
            )
        )
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionAccCostPanel:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString("")
    end
end


function ActionAccCostPanel:register_event()
    if not self.update_action_even_event  then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if data.bid == self.holiday_bid then
   
                self:createList(data)
            end
        end)
    end
end

function ActionAccCostPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
        ActionController:getInstance():cs16603(self.holiday_bid)
    end
end

function ActionAccCostPanel:DeleteMe()
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:DeleteMe()
        end
    end
    if self.item_load1 then
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end
    self.item_list = nil
    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
end

ActionAccCostItem = class("ActionAccCostItem",function()
    return ccui.Widget:create()
end)

ActionAccCostItem.Width = 679
ActionAccCostItem.Height = 164

function ActionAccCostItem:ctor()
    self.ctrl = ActionController:getInstance()
    self:configUI()
    self:register_event()
end

function ActionAccCostItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_cost_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)
    self:setContentSize(cc.size(ActionAccCostItem.Width,ActionAccCostItem.Height))

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_label = self.main_container:getChildByName("title_label")
    self.coin = self.main_container:getChildByName("coin")
    self.exp = self.main_container:getChildByName("exp")
    self.exp:setString("")
    self.get = self.main_container:getChildByName("get")
    self.get:setVisible(false)
    self.btn = self.main_container:getChildByName("btn")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.btn = self.main_container:getChildByName("btn")
    self.btn:setTitleText(TI18N("领取"))
    self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[277], 2)
    end

    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 11,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.7
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ActionAccCostItem:setExtendData(data)
    self.extend_data = data
end

function ActionAccCostItem:setData(data)
    self.data = data
    local item_list = data.item_list
    local list = {}
    for k, v in pairs(item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        vo.quantity = v.num
        table.insert(list, vo)
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function (  )
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            local data1 = v:getData()
            if data1 and data1.id then
                local bid = data1.id
                local quality = data1.quality
                for a,j in pairs(self.extend_data.item_effect_list) do
                    if bid then
                        if bid == j.bid then
                            if quality >= 4 then
                                v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
                            else
                                v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
                            end
                        end
                    end
                end
            end
        end
    end)
    self.title_label:setString(data.aim_str)
    self.exp:setString(self:getValByKey(data.aim_args,5).."/"..self:getValByKey(data.aim_args,4))

    self:changeChargeBtn(data.status)
end

function ActionAccCostItem:getValByKey(aim_args,key)
    if not aim_args then return end
    for i,v in ipairs(aim_args) do
        if v.aim_args_key == key then
            return v.aim_args_val
        elseif v.aim_args_key == key then
            return v.aim_args_val
        end
    end
end


function ActionAccCostItem:register_event()
    self.btn:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()

                if self.data then
                    local status = self.data.status
                    if status == 1 then
                        self.ctrl:cs16604(self.holiday_bid, self.data.aim, 0)
                    elseif status == 0 then
                        message(TI18N("未达到条件"))
                    elseif status == 2 then
                        message(TI18N("已经领取过了"))
                    end
                end
            end
        end
    )
end

function ActionAccCostItem:setHolidayBid(bid)
    self.holiday_bid = bid
end

function ActionAccCostItem:changeChargeBtn(status)
    if status == 0 then
        self.btn:setTitleText(TI18N("领取"))
        setChildUnEnabled(true, self.btn)
        self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
    elseif status == 1 then --可领
        self.btn:setTitleText(TI18N("领取"))
        setChildUnEnabled(false, self.btn)
        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    elseif status == 2 then
        self.btn:setTitleText(TI18N("已领取"))
        setChildUnEnabled(true, self.btn)
        self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
    end
end

function ActionAccCostItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    
    self:removeAllChildren()
    self:removeFromParent()
end
