---
--- 周活动兑换界面
---
local table_sort = table.sort
local string_format = string.format

WeeklyExchangePanel =class("WeeklyExchangePanel",function(...)
    return ccui.Widget:create()
end)

function WeeklyExchangePanel:ctor(bid)
    self.ctrl = WeeklyActivitiesController:getInstance()
    self.model = self.ctrl:getModel()
    local cfg = Config.WeekActData.data_info[bid]
    self.activity_id = cfg.action_type
    cfg = Config.WeekActData.data_reward_info[self.activity_id]
    self.expend_item = cfg[1][1].item_id
    self.cur_index = 1
    self.active_layer = 1
    self:loadResources()
end

function WeeklyExchangePanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("weeklyactivity/weeklyexchange", "weekly_exchange_bg_"..self.activity_id), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("weeklyactivity/weeklyexchange", "weeklyexchange"), type = ResourcesType.plist}
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
            self:loadResListCompleted()
        end
    end)
end

function WeeklyExchangePanel:loadResListCompleted()
    self:configUI()
    self:register_event()
    --以下避免初始化资源未完成导致数据未能及时刷新
    self:updateItemInfo()
    self:sendForData()
end

function WeeklyExchangePanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/weekly_exchange_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.bg = self.main_container:getChildByName("bg")
    self.btn_rule = self.main_container:getChildByName("btn_rule")
    local buy_panel = self.main_container:getChildByName("buy_panel")
    self.coin_img = buy_panel:getChildByName("icon")
    self.coin_num = buy_panel:getChildByName("label")
    self.coin_add = buy_panel:getChildByName("add_btn")
    self.time_val = self.main_container:getChildByName("time_val")
    self.time_title = self.main_container:getChildByName("time_title")
    self.title_img = self.main_container:getChildByName("title_img")

    --根据不同活动ID获取不同的资源
    --背景
    local res = PathTool.checkRes(string_format("resource/weeklyactivity/weeklyexchange/%s.png", "weekly_exchange_bg_"..self.activity_id))
    if not self.bg_load1 then
        self.bg_load1 = loadSpriteTextureFromCDN(self.bg, res, ResourcesType.single, self.bg_load1)
    end
    --标题
    res = PathTool.checkRes(string_format("resource/weeklyactivity/weeklyexchange/txt_weeklyexchange/%s.png", "txt_weeklyexchange_"..self.activity_id))
    if not self.item_load1 then
        self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
    end

    self.nav_container = self.main_container:getChildByName("nav_container")
    self.good_cons = self.main_container:getChildByName("good_cons")
    local scroll_view_size = self.good_cons:getContentSize()
    local setting = {
        item_class = WeeklyExchangeItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 184,               -- 单元的尺寸width
        item_height = 248,              -- 单元的尺寸height
        row = 2,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        once_num = 4,
        --need_dynamic = true
    }
    self.common_scrollview = CommonScrollViewLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

    self:createTab()
    self:setIsBlockTabView()
    self:setSelectedTab(self.cur_index)
end

function WeeklyExchangePanel:createTab()
    if self.tab_list == nil then self.tab_list = {} end
    if self.line_list == nil then self.line_list = {} end
    for i = 1, 5 do
        --导航按钮
        local tab = {}
        tab.btn = self.tab_list[i] or WeeklyExchangeTab.new(self.activity_id)
        tab.btn:setData(i)
        tab.container = self.nav_container:getChildByName("tab_panel_" .. i)
        if tab.container then
            tab.container:addChild(tab.btn)
            self.tab_list[i] = tab
        end
        --按钮之间的连线
        if i == 1 then
            self.line_list[i] = nil
        else
            self.line_list[i] = self.nav_container:getChildByName("line_" .. (i-1))
        end
    end
end

--判断开启状态
function WeeklyExchangePanel:setIsBlockTabView()
    for i,v in pairs(self.tab_list) do
        if v and v.container and v.btn then
            local is_open = self:checkTabEnable(v.btn.index)
            if is_open == true then
                setChildUnEnabled(false, v.container)
                if i ~= 1 then
                    loadSpriteTexture(self.line_list[i], PathTool.getResFrame("weeklyexchange", "weeklyexchange_6"), LOADTEXT_TYPE_PLIST)
                end
            else
                setChildUnEnabled(true, v.container)
                --v.btn.text:enableOutline(cc.c4b(0x00,0x00,0x00,0xff),2)
                if i ~= 1 then
                    loadSpriteTexture(self.line_list[i], PathTool.getResFrame("weeklyexchange", "weeklyexchange_5"), LOADTEXT_TYPE_PLIST)
                end
            end
        end
    end
end

function WeeklyExchangePanel:setSelectedTab(tab_index)
    local is_open = self:checkTabEnable(tab_index)
    --if is_open == false then
    --    message(TI18N("积分未达到要求"))
    --    return
    --end
    --if self.cur_index == tab_index then return end

    if self.cur_tab ~= nil then
        self.cur_tab:setSelected(false)
    end
    self.cur_index = tab_index
    self.cur_tab = self.tab_list[tab_index].btn
    if self.cur_tab ~= nil then
        self.cur_tab:setSelected(true)
    end
    --显示对应列表的兑换道具
    local data = self:getCurData(self.cur_index)
    self.common_scrollview:setData(data)
end

function WeeklyExchangePanel:getCurData(tab_index)
    local data = {}
    if self.exchange_data_list and next(self.exchange_data_list) ~= nil then
        local min = (tab_index - 1) * 4 + 1
        local max = tab_index * 4
        for i,v in ipairs(self.exchange_data_list) do
            if i >= min and i <= max then
                table.insert(data, v)
            end
        end
    end
    return data
end

--开启判断
function WeeklyExchangePanel:checkTabEnable(tab_index)
    return tab_index <= self.active_layer
end

function WeeklyExchangePanel:updateData(data)
    --dump(data, "handle_29205")
    if not data then return end
    if data.active_layer then
        self.active_layer = data.active_layer
        self:setIsBlockTabView()
    end

    if data.cost_num then
        self.cost_num = data.cost_num
    end

    if data.has_time then
        self:setLessTime(data.has_time)
    end

    --兑换配置
    self.exchange_cfg = self:getExchangeConfig(data.activity_id)
    --dump(self.exchange_cfg, "兑换配置")
    ---兑换数据
    self.exchange_data_list = {}
    if data.info_list and next(data.info_list) ~= nil then
        table_sort( data.info_list , function(a,b) return a.id < b.id end )
        ----local sort_func = SortTools.tableCommonSorter({{"sort_lock", false}, {"aim", false}})
        ----table_sort(data.info_list , sort_func )
        --dump(data.info_list)
        for i,v in ipairs(data.info_list) do
            if v.id and v.num then
                self.exchange_data_list[i] = {}
                self.exchange_data_list[i].activity_id = data.activity_id
                self.exchange_data_list[i].id = v.id
                self.exchange_data_list[i].buy_count = v.num
                self.exchange_data_list[i].limit_buy = self.exchange_cfg[i].limit_num
                self.exchange_data_list[i].expend_num = self.exchange_cfg[i].consume_num
                self.exchange_data_list[i].expend_id = self.exchange_cfg[i].item_id
                self.exchange_data_list[i].item_list = {}
                self.exchange_data_list[i].item_list[1] = {}
                self.exchange_data_list[i].item_list[1].bid = self.exchange_cfg[i].reward[1][1]
                self.exchange_data_list[i].item_list[1].num = self.exchange_cfg[i].reward[1][2]
                self.exchange_data_list[i].active = (i/4) <= data.active_layer
            end
        end
        self:setSelectedTab(self.cur_index)
        --dump(self.exchange_data_list, "兑换数据")
    end

    --解锁提示
    if not self.expend_label then
        self.expend_label = createRichLabel(18, Config.ColorData.data_new_color4[1], cc.p(1, 0.5), cc.p(680, 0), nil, nil, 500)
        self.main_container:addChild(self.expend_label)
    end
    local item_config = Config.ItemData.data_get_data(self.expend_item)
    local res = PathTool.getItemRes(item_config.icon)
    --解锁需要消耗的配置
    local cfg_num = self:getCostConfig()
    if cfg_num > 0 then
    self.expend_label:setString(string_format(TI18N("解锁第<div fontcolor=#0cff01>%s</div>星云兑换需要消耗: <img src='%s' scale=0.3 /> %d/%d"), data.active_layer+1, res, self.cost_num or 0, cfg_num))
    else
        self.expend_label:setString("")
    end
    if not self.item_load2 then
        self.item_load2 = loadSpriteTextureFromCDN(self.coin_img, res, ResourcesType.single, self.item_load2)
    end
end

function WeeklyExchangePanel:getCostConfig()
    local cost = 0
    local cfg = Config.WeekActData.data_lock_info
    if cfg and cfg[self.activity_id] and cfg[self.activity_id][self.active_layer + 1] then
        cost = cfg[self.activity_id][self.active_layer + 1].unlock_num
    end
    return cost
end

function WeeklyExchangePanel:getExchangeConfig(index)
    local cfg = Config.WeekActData.data_reward_info[index]
    local temp = {}
    for _, layer in ipairs(cfg) do
        for _, item in ipairs(layer) do
            table.insert(temp, item)
        end
    end
    return temp
end

--设置倒计时
function WeeklyExchangePanel:setLessTime(less_time)
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

function WeeklyExchangePanel:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString(TI18N("已结束"))
    end
end

function WeeklyExchangePanel:register_event()
    --导航按钮点击事件
    for i,v in pairs(self.tab_list) do
        registerButtonEventListener(v.container, function()
            playButtonSound2()
            self:setSelectedTab(v.btn.index)
        end,true)
    end
    --获取兑换活动数据
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.UPDATE_WEEK_EXCHANGE_DATA,function(data)
            --if data and data.activity_id and data.activity_id == self.activity_id then
                self:updateData(data)
            --end
        end)
    end
    --说明
    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.WeekActData.data_const
        local key = ""
        if self.activity_id == 1 then
            key = "bomb_bridge_shop_tips"
        elseif self.activity_id == 2 then
            key = "water_shop_tips"
        else
            key = "shop_tips"
        end
        if config[key] then
            TipsManager:getInstance():showCommonTips(config[key].desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end, true)
    --消耗道具添加点击
    registerButtonEventListener(self.coin_add, function()
        WeeklyActivitiesController:getInstance():openMainWindow(true, 1)
    end, true)
    --道具变化
    --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                self:updateItemInfo()
            end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                self:updateItemInfo()
            end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                self:updateItemInfo()
            end
        end)
    end
end

function WeeklyExchangePanel:updateItemInfo()
    if self.coin_num and self.expend_item then
        local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.expend_item)
        self.coin_num:setString(count)
    end
end

function WeeklyExchangePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
        ----请求数据
        self:sendForData()
        self:updateItemInfo()
    end
end

function WeeklyExchangePanel:sendForData()
    local bid = self.model:getWeeklyActivityId()
    if bid == self.activity_id then
        self.ctrl:send_29205(1)
    else
        self.ctrl:send_29205(2)
    end
end

function WeeklyExchangePanel:DeleteMe()
    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end
    if self.bg_load1 then
        self.bg_load1:DeleteMe()
        self.bg_load1 = nil
    end
    if self.item_load1 then
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end
    if self.item_load2 then
        self.item_load2:DeleteMe()
        self.item_load2 = nil
    end
    self.tab_list = nil
    self.line_list = nil
    self.exchange_data_list = nil
end

----------------------@ 子项
WeeklyExchangeTab =
class(
        "WeeklyExchangeTab",
        function()
            return ccui.Widget:create()
        end
)

function WeeklyExchangeTab:ctor(activity_id)
    self.activity_id = activity_id
    self:configUI()
    self:register_event()
end

function WeeklyExchangeTab:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/weekly_exchange_tab"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(128, 128))
    self:setAnchorPoint(0, 0)

    self.container = self.root_wnd:getChildByName("main_container")
    self.bg = self.container:getChildByName("bg")
    self.pic = self.container:getChildByName("pic")
    self.tab = self.container:getChildByName("tab")
    self.text = self.container:getChildByName("text")
end

function WeeklyExchangeTab:register_event()
    --self.container:addTouchEventListener(function(sender, event_type)
    --    if event_type == ccui.TouchEventType.ended then
    --        playButtonSound2()
    --        --if self.data and self.data.id and self.data.finish == 1 then
    --        --    controller:sender16654(self.data.id)
    --        --end
    --    end
    --end)
end

function WeeklyExchangeTab:setData(index)
    if not index then
        return
    end
    self.index = index
    --图片
    loadSpriteTexture(self.bg, PathTool.getResFrame("weeklyexchange", "weeklyexchange_1"), LOADTEXT_TYPE_PLIST)
    loadSpriteTexture(self.tab, PathTool.getResFrame("weeklyexchange", "weeklyexchange_3"), LOADTEXT_TYPE_PLIST)
    loadSpriteTexture(self.pic, PathTool.getResFrame("weeklyexchange", "weeklyexchange_"..self.activity_id.."00"..index), LOADTEXT_TYPE_PLIST)
    --文字
    self.text:setString(string_format(TI18N("第%s星云"), index))
    self.text:enableOutline(Config.ColorData.data_new_color4[6],2)
end

function WeeklyExchangeTab:setSelected(bool)
    if bool then
        loadSpriteTexture(self.bg, PathTool.getResFrame("weeklyexchange", "weeklyexchange_2"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.tab, PathTool.getResFrame("weeklyexchange", "weeklyexchange_4"), LOADTEXT_TYPE_PLIST)
        self.text:enableOutline(Config.ColorData.data_new_color4[10],2)
    else
        loadSpriteTexture(self.bg, PathTool.getResFrame("weeklyexchange", "weeklyexchange_1"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.tab, PathTool.getResFrame("weeklyexchange", "weeklyexchange_3"), LOADTEXT_TYPE_PLIST)
        self.text:enableOutline(Config.ColorData.data_new_color4[6],2)
    end
end

function WeeklyExchangeTab:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end


----------------------@ 子项
WeeklyExchangeItem =
class(
        "WeeklyExchangeItem",
        function()
            return ccui.Widget:create()
        end
)

function WeeklyExchangeItem:ctor()
    self:configUI()
    self:register_event()
end

function WeeklyExchangeItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/weekly_exchange_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(184, 248))
    self:setAnchorPoint(0, 0)

    self.container = self.root_wnd:getChildByName("main_container")
    self.name = self.container:getChildByName("name")
    self.remain = self.container:getChildByName("remain")
    self.coin = self.container:getChildByName("coin")
    self.price = self.container:getChildByName("price")
    self.btn_buy = self.container:getChildByName("btn_buy")
    self.text = self.btn_buy:getChildByName("text")
    self.text:setString(TI18N("兑换"))

    --道具item
    self.goods_item = BackPackItem.new(true,true,nil,1,nil,true)
    self.goods_item:setPosition(self:getContentSize().width/2,135)
    self.goods_item:setScale(0.8)
    self.goods_item:setDefaultTip()
    self.container:addChild(self.goods_item)
end

function WeeklyExchangeItem:setData(data)
    if not data then
        return
    end
    self.data = data
    --dump(data, "exchange_item_data")
    --道具名字
    local cfg = Config.ItemData.data_get_data(data.item_list[1].bid)
    self.name:setString(cfg.name)
    --限购信息
    local buy_count = data.buy_count
    local limit_buy = data.limit_buy
    self.canBuy = data.buy_count < data.limit_buy
    if self.canBuy and data.active then
        --self.btn_buy:setVisible(true)
        setChildUnEnabled(false, self.btn_buy)
        self.btn_buy:setTouchEnabled(true)
        self.text:enableShadow(Config.ColorData.data_new_color4[4],cc.size(0, -2),2)
    else
        --self.btn_buy:setVisible(false)
        setChildUnEnabled(true, self.btn_buy)
        self.btn_buy:setTouchEnabled(false)
        self.text:enableShadow(Config.ColorData.data_new_color4[1],cc.size(0, 0),0)
    end
    self.remain:setString(string_format(TI18N("限购: %s/%s"), buy_count, limit_buy))
    --消耗配置
    local cost_config = Config.ItemData.data_get_data(data.expend_id)
    --消耗icon
    if cost_config then
        local res = PathTool.getItemRes(cost_config.icon, false)
        if self.record_cost_res == nil or self.record_cost_res ~= res then
            loadSpriteTexture(self.coin, res, LOADTEXT_TYPE)
        end
    end
    --出售价格
    self.price:setString(data.expend_num)
    --道具
    if data.item_list and #data.item_list > 0 then
        local bid = data.item_list[1].bid
        self.bid = bid
        local num = data.item_list[1].num
        self.goods_item:setBaseData(bid, num, true)
    end
end

function WeeklyExchangeItem:register_event()
    registerButtonEventListener(self.btn_buy, function()
        playButtonSound2()
        self:buy()
    end,true)

    --registerButtonEventListener(self.goods_item, function()
    --    self:setCellTouched()
    --end ,false, 0)
end

function WeeklyExchangeItem:buy()
    --if self.canBuy == false then
    --    message(TI18N("已兑换"))
    --    return
    --end
    if self.data and self.data.id then
        local type = 1
        local cur_type = WeeklyActivitiesController:getInstance():getModel():getWeeklyActivityId()
        if self.data.activity_id ~= cur_type then
            type = 2
        end
        WeeklyActivitiesController:getInstance():send_29206(type, self.data.id)
    end
end

--设置点击事件
--function WeeklyExchangeItem:setCellTouched()
--    print("Item_Clicked")
--end

function WeeklyExchangeItem:DeleteMe()
    if cell.goods_item ~= nil then
        cell.goods_item:DeleteMe()
        cell.goods_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end