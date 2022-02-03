--******** 文件说明 ********
-- @Author:      zj
-- @description: 神秘杂货铺
-- @DateTime:    2019-04-25 10:51:42
-- *******************************

ActionMysteriousStorePanel = class("ActionMysteriousStorePanel", function()
	return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local model = ActionController:getInstance():getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local img_equal = {166, 243}
local get_cont = {220, 270}

function ActionMysteriousStorePanel:ctor(bid)
    self.holiday_bid = bid
    self.frist_come_in = false
    self.is_change_id = nil --兑换ID
    self.cell_data_list = {}
	self:configUI()
	self:register_event()
end

function ActionMysteriousStorePanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_hero_expedit_panel"))
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setPosition(-40, -66)
	self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_con = self.main_container:getChildByName("title_con")
    self.time_label = self.title_con:getChildByName("label_time_key")
    self.time_label:setString(TI18N("剩余时间："))
    self.time_text = self.title_con:getChildByName("label_time")
    self.time_text:setTextColor(cc.c4b(0x80,0xf7,0x31,0xff))
    self.time_text:setAnchorPoint(cc.p(0, 0.5))
    self.rank_btn = self.title_con:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("详细排行"))
    self.reward_btn = self.title_con:getChildByName("reward_btn")
    self.reward_btn:getChildByName("label"):setString(TI18N("奖励预览"))
    self.btn_rule = self.title_con:getChildByName("btn_rule") --规则说明按钮
    self.btn_rule:setPositionX(670)
    self:loadBannerImage()

    self.good_cons = self.main_container:getChildByName("charge_con")
    -- local scroll_view_size = child_goods:getContentSize()
    -- local setting = {
    --     item_class = ActionStoreItem,
    --     start_x = 0,
    --     space_x = 0,
    --     start_y = 0,
    --     space_y = 0,
    --     item_width = 688,
    --     item_height = 150,
    --     row = 0,
    --     col = 1,
    --     need_dynamic = true
    -- }
    -- self.child_scrollview = CommonScrollViewLayout.new(child_goods, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    -- self.child_scrollview:setSwallowTouches(false)
    self:updateScrollviewList()
    self:setPanelData()
    controller:sender16688()
    model:setGiftRedStatus({bid = ActionRankCommonType.mysterious_store, status = false})
end

function ActionMysteriousStorePanel:updateScrollviewList()
    if self.child_scrollview == nil then
        local scroll_view_size = self.good_cons:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 688,                -- 单元的尺寸width
            item_height = 150,               -- 单元的尺寸height
            row = 0,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.child_scrollview = CommonScrollViewSingleLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.child_scrollview:setSwallowTouches(false)
    self.child_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionMysteriousStorePanel:createNewCell(width, height)
    local cell = ActionStoreItem.new()
	return cell
end

--获取数据数量
function ActionMysteriousStorePanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionMysteriousStorePanel:updateCellByIndex(cell, index)
    if not self.cell_data_list then return end
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

--加载banner图片
function ActionMysteriousStorePanel:loadBannerImage()
    -- 横幅图片
    local title_img = self.title_con:getChildByName("title_img")
    local str_banner = ""
    if self.holiday_bid == ActionRankCommonType.mysterious_store then
        str_banner = "txt_cn_welfare_banner24"
        self.reward_btn:setVisible(false)
        self.rank_btn:setVisible(false)
    end

    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str_banner = tab_vo.reward_title
    end
    
    self:updataItem(nil, nil, true)

    local res = PathTool.getWelfareBannerRes(str_banner)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(title_img) then
                loadSpriteTexture(title_img, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
end

function ActionMysteriousStorePanel:setPanelData()
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    local time = tab_vo.remain_sec or 0
    model:setCountDownTime(self.time_text,time)
end

function ActionMysteriousStorePanel:setItemData()
    if self.child_scrollview then
        -- local list = self:setConfigData()
        -- self.child_scrollview:setData(list)
        self.cell_data_list = self:setConfigData()
        self.child_scrollview:reloadData()
    end
end

function ActionMysteriousStorePanel:setConfigData()
    local list = {}
    local config = Config.HolidayExchangeData.data_get_config_const

    for i,v in pairs(config) do
        local buy_data = model:getStoneShopData(v.id)
        if buy_data then
            local day_count = buy_data.day_num or 0      --个人天购买次数
            local totle_count = buy_data.all_num or 0    --个人总购买次数
            local remian_count = 0
            if v.sub_type == ActonExchangeType.Perday then     --每日限兑
                remian_count = v.r_limit_day - day_count
            elseif v.sub_type == ActonExchangeType.AllServer then --全服限兑
                --暂时不开放
            elseif v.sub_type == ActonExchangeType.Activity then --活动限兑
                remian_count = v.r_limit_all - totle_count
            end
            v.count = remian_count
            if v.count <= 0 then
                v.sort = 1000000
            else
                v.sort = remian_count
            end
            local name_str
            for k,v in ipairs(v.expend) do
                local bid = v[1]
                local item_cfg = Config.ItemData.data_get_data(bid)
                if item_cfg and k == 1 then
                    name_str = item_cfg.name
                else
                    name_str = name_str .. "、" .. item_cfg.name
                end
            end
            v.name_str = name_str
            table_insert(list,v)
        end
    end

    local sort_func = SortTools.tableCommonSorter({{"sort", false},{"id", false}})
    table_sort(list, sort_func)
    return list
end 

function ActionMysteriousStorePanel:register_event()
    if not self.update_store_data_event then
        self.update_store_data_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_STORE_DATA_EVENT,function()
            if self.setItemData and self.frist_come_in == false then
                self.frist_come_in = true
                self:setItemData()
            end
        end)
    end

    if not self.update_store_data_success_event then
        self.update_store_data_success_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_STORE_DATA_SUCCESS_EVENT,function(data)
            self:changeSuccessData(data.id)
        end)
    end

    registerButtonEventListener(self.rank_btn, function()
        self:jumpRankView()
    end ,true, 1)
    registerButtonEventListener(self.reward_btn, function()
        RankController:getInstance():openRankRewardPanel(true, self.holiday_bid)
    end ,true, 1)
    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.HolidayClientData.data_constant.expedit_rules
        if self.holiday_bid == ActionRankCommonType.mysterious_store then
            config = Config.HolidayClientData.data_constant.mysterious_store_rules
        end
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,true, 1)
    
    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event =
            GlobalEvent:getInstance():Bind(
            BackpackEvent.ADD_GOODS,
            function(bag_code, data_list)
                self:updataItem(bag_code, data_list)
            end
        )
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event =
            GlobalEvent:getInstance():Bind(
            BackpackEvent.DELETE_GOODS,
            function(bag_code, data_list)
                self:updataItem(bag_code, data_list)
            end
        )
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event =
            GlobalEvent:getInstance():Bind(
            BackpackEvent.MODIFY_GOODS_NUM,
            function(bag_code, data_list)
                self:updataItem(bag_code, data_list)
            end
        )
    end
end

function ActionMysteriousStorePanel:updataItem(bag_code, data_list, is_update)
    local item_id
    local config = Config.HolidayExchangeData.data_constant
    if config and config.consume_id and config.consume_id.val then
        item_id = config.consume_id.val
    else
        return
    end
    if data_list ~= nil then
        for i,v in pairs(data_list) do
            if v.base_id == item_id then
                is_update = true
            end
        end
    end
    if is_update then
        -- if self.count_bg == nil  then
        --     self.count_bg = createImage(self.title_con, PathTool.getResFrame("common", "common_1035"), 628, 33, cc.p(0.5,0.5), true, 1, true)
        --     self.count_bg:setContentSize(cc.size(137, 33))
        -- end
        if self.item_icon == nil  then
            self.item_icon = createSprite(nil, 580, 36, self.title_con, cc.p(0.5, 0.5), nil)
            self.item_icon:setScale(0.4)
        end
        if self.item_num == nil  then
            self.item_num = createLabel(24, cc.c4b(255,255,255,255), nil, 630, 36, nil, self.title_con, nil, cc.p(0.5,0.5))
        end
        local item_config = Config.ItemData.data_get_data(item_id)
        if item_config then
            local res = PathTool.getItemRes(item_config.icon)
            loadSpriteTexture(self.item_icon, res, LOADTEXT_TYPE)
        end
        local count = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
        self.item_num:setString(count)
    end
end

function ActionMysteriousStorePanel:changeSuccessData(change_id)
    local config = Config.HolidayExchangeData.data_get_config_const
    local buy_data = model:getStoneShopData(change_id)
    if buy_data and config and config[change_id] then
        local day_count = buy_data.day_num or 0      --个人天购买次数
        local totle_count = buy_data.all_num or 0    --个人总购买次数
        local remian_count = 0
        if config[change_id].sub_type == ActonExchangeType.Perday then     --每日限兑
            remian_count = config[change_id].r_limit_day - day_count
        elseif config[change_id].sub_type == ActonExchangeType.AllServer then --全服限兑
            --暂时不开放
        elseif config[change_id].sub_type == ActonExchangeType.Activity then --活动限兑
            remian_count = config[change_id].r_limit_all - totle_count
        end
        if self.child_scrollview then
            -- if remian_count <= 0 then
            --     local list = self:setConfigData()
            --     self.child_scrollview:setData(list)
            -- else
            --     local list = self:setConfigData()
            --     self.child_scrollview:resetAddPosition(list)
            -- end
            self.cell_data_list = self:setConfigData()
            if remian_count <= 0 then
                self.child_scrollview:reloadData()
            else
                self.child_scrollview:resetCurrentItems()
            end
        end
    end
end

function ActionMysteriousStorePanel:jumpRankView()
end

function ActionMysteriousStorePanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function ActionMysteriousStorePanel:DeleteMe()
	doStopAllActions(self.time_text)
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.child_scrollview then
        self.child_scrollview:DeleteMe()
    end
    self.child_scrollview = nil
    if self.update_holiday_common_event then
        GlobalEvent:getInstance():UnBind(self.update_holiday_common_event)
        self.update_holiday_common_event = nil
    end
    if self.update_store_data_success_event then
        GlobalEvent:getInstance():UnBind(self.update_store_data_success_event)
        self.update_store_data_success_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
end

------------------------------------------
-- 杂货铺子项
------------------------------------------
ActionStoreItem = class("ActionStoreItem", function()
    return ccui.Widget:create()
end)

function ActionStoreItem:ctor()
    self:configUI()
    self:register_event()
    self.cost_list_data = {}
    self.get_list_data = {}
end

function ActionStoreItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("action/action_mysterious_store_item"))
    self:setContentSize(cc.size(688,150))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.txt_title = main_container:getChildByName("txt_title")             --标题
    self.txt_title:setString("")
    self.txt_task = main_container:getChildByName("txt_task")               --剩余
    self.txt_task:setString("")
    self.btn_exchange = main_container:getChildByName("btn_exchange")       --兑换
    self.txt_exchange = self.btn_exchange:getChildByName("txt_exchange")
    self.txt_exchange:setString(TI18N("兑换"))
    self.img_has_get = main_container:getChildByName("img_has_get")
    self.img_has_get:setVisible(false)
    self.img_equal = main_container:getChildByName("img_equal")

    self.cost_good_cons = main_container:getChildByName("cost_good_cons")
    self.cost_good_cons:setContentSize(cc.size(200, 100))
    -- local scroll_view_size = self.cost_good_cons:getContentSize()
    -- local setting = {
    --     item_class = BackPackItem,
    --     start_x = 3,
    --     space_x = 5,
    --     start_y = 4,
    --     space_y = 4,
    --     item_width = BackPackItem.Width*0.80,
    --     item_height = BackPackItem.Height*0.80,
    --     row = 1,
    --     col = 0,
    --     scale = 0.80
    -- }
    -- self.cost_item_scrollview = CommonScrollViewLayout.new(self.cost_good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    -- self.cost_item_scrollview:setSwallowTouches(false)
    -- self.cost_item_scrollview:setClickEnabled(false)

    self.get_good_cons = main_container:getChildByName("get_good_cons")
    -- local scroll_view_size = self.get_good_cons:getContentSize()
    
    -- self.get_item_scrollview = CommonScrollViewLayout.new(self.get_good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    -- self.get_item_scrollview:setSwallowTouches(false)
    self:updateScrollviewList()
end

function ActionStoreItem:updateScrollviewList()
    local setting = {
        start_x = 3,                     -- 第一个单元的X起点
        space_x = 5,                     -- x方向的间隔
        start_y = 4,                     -- 第一个单元的Y起点
        space_y = 0,                     -- y方向的间隔
        item_width = BackPackItem.Width*0.80,                -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,               -- 单元的尺寸height
        row = 1,                         -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        delay = 4,                       -- 创建延迟时间
        once_num = 1,                    -- 每次创建的数量
    }
    if self.cost_item_scrollview == nil then
        local scroll_view_size = self.cost_good_cons:getContentSize()
        self.cost_item_scrollview = CommonScrollViewSingleLayout.new(self.cost_good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.cost_item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.cost_item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.cost_item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.cost_item_scrollview:setClickEnabled(false)
    self.cost_item_scrollview:setSwallowTouches(false)
    if self.get_item_scrollview == nil then
        local scroll_view_size = self.get_good_cons:getContentSize()
        self.get_item_scrollview = CommonScrollViewSingleLayout.new(self.get_good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.get_item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell1), ScrollViewFuncType.CreateNewCell) --创建cell
        self.get_item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells1), ScrollViewFuncType.NumberOfCells) --获取数量
        self.get_item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex1), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.get_item_scrollview:setSwallowTouches(false)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionStoreItem:createNewCell(width, height)
    local cell = BackPackItem.new()
    cell:setDefaultTip()
    cell:setSwallowTouches(false)
    cell:setScale(0.80)
	return cell
end

--获取数据数量
function ActionStoreItem:numberOfCells()
    if not self.cost_list_data then return 0 end
    return #self.cost_list_data
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionStoreItem:updateCellByIndex(cell, index)
    if not self.cost_list_data then return end
    cell.index = index
    local cell_data = self.cost_list_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionStoreItem:createNewCell1(width, height)
    local cell = BackPackItem.new()
    cell:setDefaultTip()
    cell:setSwallowTouches(false)
    cell:setScale(0.80)
	return cell
end

--获取数据数量
function ActionStoreItem:numberOfCells1()
    if not self.get_list_data then return 0 end
    return #self.get_list_data
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionStoreItem:updateCellByIndex1(cell, index)
    if not self.get_list_data then return end
    cell.index = index
    local cell_data = self.get_list_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ActionStoreItem:register_event()
    registerButtonEventListener(self.btn_exchange, function()
        self:btnExchange()
    end ,true, 1)
end

function ActionStoreItem:btnExchange()
    if self.data and self.data.award and self.data.award[1] then
        local count = 0
        if self.data.sub_type == ActonExchangeType.Perday then     --每日限兑
            count = self.data.sort or 0
        elseif self.data.sub_type == ActonExchangeType.AllServer then --全服限兑
            --暂时不开放
        elseif self.data.sub_type == ActonExchangeType.Activity then --活动限兑
            count = self.data.sort or 0
        end
        if count <= 1 then
            local tips_str = string.format(TI18N("是否消耗<div fontColor=#289b14 fontsize= 26>%s</div>兑换物品？"), self.data.name_str)
            CommonAlert.show(tips_str, TI18N("确定"), function()
                if self.data and self.data.charge_id then
                    controller:sender16689(self.data.charge_id,1)
                end
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            local buy_data = {}
            buy_data.bid = self.data.award[1][1]
            buy_data.item_bid = self.data.award[1][1]
            buy_data.shop_type = MallConst.MallType.SteriousShop
            buy_data.limit_num = count -- 限购个数
            buy_data.has_buy = 0
            buy_data.is_show_limit_label = true
            local item_config = Config.ItemData.data_get_data(self.data.award[1][1])
            buy_data.name = item_config.name
            buy_data.aim = self.data.charge_id or 0


            buy_data.pay_type = 3
            buy_data.price = 1
            buy_data.quantity = 1

            MallController:getInstance():openMallBuyWindow(true,buy_data)
        end
    end
end

function ActionStoreItem:setData(data)
    if not data then return end
    self:setChangeData(data)
end

function ActionStoreItem:setChangeData(data)
    self.data = data
    self.data.charge_id = data.id
 
    self.txt_title:setString(data.title)
    self.txt_task:setString(TI18N(string_format("剩余:%d", data.count)))

    local show_type = 1 --展示格式 1：1=1+1+1   2：1+1=1+1+1
    local cost_size = cc.size(100, 100)
    local get_size = cc.size(270, 100)
    if #data.expend > 1 then --消耗物品列表
        show_type = 2
        cost_size = cc.size(200, 100)
        get_size = cc.size(220, 100)
    end
    self.cost_good_cons:setPositionX(15)
    self.img_equal:setPositionX(img_equal[show_type])
    self.get_good_cons:setPositionX(get_cont[show_type])
    -- self.get_good_cons:setContentSize(get_size)
    -- self.get_item_scrollview:setContentSize(get_size)
    -- self.get_item_scrollview.scroll_view:setContentSize(get_size)

    --加载礼包物品列表
    self:updateItemList(self.cost_item_scrollview, data.expend, 1)
    self:updateItemList(self.get_item_scrollview, data.award, 2) 

    self.btn_exchange:setTouchEnabled(data.count ~= 0)
    if data.count == 0 then
        self.txt_exchange:setString(TI18N("不可兑换"))
        setChildUnEnabled(true, self.btn_exchange)
        self.txt_exchange:disableEffect(cc.LabelEffect.OUTLINE)
    else
        self.txt_exchange:setString(TI18N("兑换"))
        setChildUnEnabled(false, self.btn_exchange)
        self.txt_exchange:enableOutline(Config.ColorData.data_color4[277], 2)
    end
end

function ActionStoreItem:updateItemList(parent, data_list, type)
    -- 物品列表
    local list = {}
    for k, v in pairs(data_list) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        table.insert(list, vo)
    end
    if type == 1 then
        self.cost_list_data = list
    elseif type == 2 then
        self.get_list_data = list
    end
    parent:reloadData()
    -- parent:setData(list)
    -- parent:addEndCallBack(function()
    --     local list = parent:getItemList()
    --     for k,v in pairs(list) do
    --         v:setDefaultTip(true, false)
    --         v:setSwallowTouches(false)
    --     end
    -- end)
    if #data_list <= 2 then
        parent:setTouchEnabled(false)
    end
end

function ActionStoreItem:DeleteMe()
    if self.cost_item_scrollview then
        self.cost_item_scrollview:DeleteMe()
        self.cost_item_scrollview = nil
    end
    if self.get_item_scrollview then
        self.get_item_scrollview:DeleteMe()
        self.get_item_scrollview = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end