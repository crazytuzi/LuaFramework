-- --------------------------------------------------------------------
-- @description:
--      每日抢购
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ActionLimitBuyPanel =class("ActionLimitBuyPanel",function(...)
    return ccui.Widget:create()
end)

function ActionLimitBuyPanel:ctor(bid, type)
    self.holiday_bid = bid
    self.type = type
    self.action_type = type
    self.ctrl = ActionController:getInstance()
    self:configUI()
    self:register_event()
end

function ActionLimitBuyPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_buy_panel"))
    self.root_wnd:setPosition(-40, -145)
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
                tab_vo.aim_title = "txt_cn_action_limit_title"
            end
            local res = PathTool.getPlistImgForDownLoad("bigbg/action",tab_vo.aim_title)
            if not self.item_load1 then
                self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
            end
        end
    end

    local scroll_view_size = self.charge_con:getContentSize()
    local setting = {
        item_class = ActionLimitBuyItem, -- 单元类
        start_x = 10, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = ActionLimitBuyItem.Width, -- 单元的尺寸width
        item_height = ActionLimitBuyItem.Height, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1 -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.charge_con,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ActionLimitBuyPanel:createList(data)
    if not data then
        return
    end
    
    local item_list = {}
    self.everyday_data = nil
    for i, v in ipairs(data.aim_list) do
        --99是和后端 运营协议好的数字  99 为每日礼的
        if v.aim == 99 then 
            self.everyday_data = v
        else
            v.sort_index = 1
            if v.status == 1 then
                v.sort_index = 0
            elseif v.status == 2 then
                v.sort_index = 2
            end
            table.insert(item_list,v)    
        end
    end
    local sort_func = SortTools.tableLowerSorter({"sort_index", "aim"})
    table.sort(item_list, sort_func)
    self.item_scrollview:setData(item_list)
    self:setLessTime(data.remain_sec)

    --每日礼的红点
    if self.everyday_data and self.everyday_data.status ~= 2 then
        addRedPointToNodeByStatus(self.everyday_btn, true)
    else
        addRedPointToNodeByStatus(self.everyday_btn, false)
    end
end

--设置倒计时
function ActionLimitBuyPanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    self.time_val:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.time_val:stopAllActions()
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionLimitBuyPanel:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString("00:00:00")
    end
end

function ActionLimitBuyPanel:register_event()
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if data.bid == self.holiday_bid then
                self:createList(data)
            end
        end)
    end
end

function ActionLimitBuyPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
        ActionController:getInstance():cs16603(self.holiday_bid)
    end
end

function ActionLimitBuyPanel:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil

    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
    if self.item_load1 then
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end
end

ActionLimitBuyItem = class("ActionLimitBuyItem",function()
    return ccui.Widget:create()
end)

ActionLimitBuyItem.Width = 679
ActionLimitBuyItem.Height = 164

function ActionLimitBuyItem:ctor()
    self.ctrl = ActionController:getInstance()
    self.touch_limit_buy = true
    self:configUI()
    self:register_event()
end

function ActionLimitBuyItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_buy_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)
    self:setContentSize(cc.size(ActionLimitBuyItem.Width, ActionLimitBuyItem.Height))

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_label = self.main_container:getChildByName("title_label")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.has_bg = self.main_container:getChildByName("has_bg")
    self.has_bg:setVisible(false)

    self.btn = createButton(self.main_container, TI18N('购买'), 590, 67, cc.size(129, 62), PathTool.getResFrame('common', 'common_1018'), 24)
    self.btn:setRichText("<div fontColor=#ffffff fontsize=28 outline=2,#2b610d>￥ 0</div>")
    self.btn:setPositionY(self.btn:getPositionY()-15)

    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 3, -- 第一个单元的X起点
        space_x = 15, -- x方向的间隔
        start_y = 11, -- 第一个单元的Y起点
        space_y = 4, -- y方向的间隔
        item_width = BackPackItem.Width * 0.7, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.7, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.7
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con,cc.p(0, 0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
    self.limit_label = createRichLabel(24, 175, cc.p(1,0.5), cc.p(665,139), nil, nil, nil)
    self.main_container:addChild(self.limit_label)

    self.old_price = createRichLabel(20, 175, cc.p(0.5,0.5), cc.p(585,104), nil, nil, nil)
    self.main_container:addChild(self.old_price)

    self.price_line = createScale9Sprite(PathTool.getResFrame("welfare", "welfare_40"), 50, 10, LOADTEXT_TYPE_PLIST, self.old_price)
    self.price_line:setAnchorPoint(cc.p(0.5, 0.5))
    -- self.price_line:setContentSize(cc.size(150, 2))
end

function ActionLimitBuyItem:setData(data)
    self.data = data
    local item_list = {}

    local list = {}
    for k, v in ipairs(data.item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        if vo then
            vo.quantity = v.num
            table.insert(list, vo)
        end
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k, v in pairs(list) do
            v:setDefaultTip()
        end
    end)

    local discount_list = keyfind('aim_args_key', 26, data.aim_args) or nil
    local new_price_list = keyfind('aim_args_key', 27, data.aim_args) or nil

    local current_price = 0 
    if discount_list and new_price_list then
        local str = string.format(TI18N("原价:￥ %d"), discount_list.aim_args_val or 0)
        self.old_price:setString(str)
        local price_str = string.format("<div fontColor=#ffffff fontsize=24 outline=2,#2b610d>￥ %d</div>", new_price_list.aim_args_val or 0)
        self.btn:setRichText(price_str)
        current_price = new_price_list.aim_args_val
    end

    self.title_label:setString(data.aim_str)

    local _type = self:getValByKey(data.aim_args,7) or 0
    local max_num = self:getValByKey(data.aim_args,2) or 0
    local cur_num = self:getValByKey(data.aim_args,6) or 0
    local str = ""
    if _type == 1 then --日限购
        if max_num and max_num ~= 0 and cur_num  then 
            str = string.format(TI18N("<div>每周限购%s个:  (</div><div fontcolor=#249003>%s<div>/%s)"),max_num,cur_num,max_num)
        end
    elseif _type == 2 then --累计限购
        if max_num and max_num ~= 0 and cur_num  then 
            str = string.format(TI18N("<div>总限购%s个:  (</div><div fontcolor=#249003>%s<div>/%s)"), max_num,cur_num,max_num)
        end
    end
    self.limit_label:setString(str)

    if data.sort_index == 2 then
        self.btn:setGrayAndUnClick(true, false)
        local price_str = string.format("<div fontColor=#ffffff fontsize=24>￥ %d</div>", current_price)
        self.btn:setRichText(price_str)
    else
        self.btn:setGrayAndUnClick(false, true)
        local price_str = string.format("<div fontColor=#ffffff fontsize=24 outline=2,#2b610d>￥ %d</div>", current_price)
        self.btn:setRichText(price_str)
    end
end

function ActionLimitBuyItem:getValByKey(aim_args, key)
    if not aim_args then
        return 0
    end
    local val = 0
    for i, v in ipairs(aim_args) do
        if v.aim_args_key == key then
            val = v.aim_args_val
        end
    end
    return val
end

function ActionLimitBuyItem:register_event()
    self.btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.data then
                if self.data.status == 0 and self.touch_limit_buy == true then
                    self.touch_limit_buy = nil
                    local new_price = keyfind('aim_args_key', 27, self.data.aim_args) or {}
                    sdkOnPay(new_price.aim_args_val, 1, self.data.aim, self.data.aim_str)
                    if self.send_limit_buy_ticket == nil then
                        self.send_limit_buy_ticket = GlobalTimeTicket:getInstance():add(function()
                            self.touch_limit_buy = true
                            if self.send_limit_buy_ticket ~= nil then
                                GlobalTimeTicket:getInstance():remove(self.send_limit_buy_ticket)
                                self.send_limit_buy_ticket = nil
                            end
                        end,2)
                    end
                elseif self.data.status == 2 then
                    message(TI18N("已经购买完了"))
                end
            end
        end
    end)
end

function ActionLimitBuyItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.send_limit_buy_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.send_limit_buy_ticket)
        self.send_limit_buy_ticket = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
