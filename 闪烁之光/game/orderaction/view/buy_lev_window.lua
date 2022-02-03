--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 购买等级
-- @DateTime:    2019-04-19 17:22:09
-- *******************************
BuyLevWindow = BuyLevWindow or BaseClass(BaseView)

local table_insert = table.insert
local table_sort = table.sort
local controller = OrderActionController:getInstance()
local lev_reward_list = Config.HolidayWarOrderData.data_lev_reward_list
function BuyLevWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "orderaction/buy_lev_window"
    self.cur_buy_lev = 1
    self.touch_max_btn = nil
    self.totle_reward_list = {}
end

function BuyLevWindow:open_callback()
	local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2)
    main_container:getChildByName("title_con"):getChildByName("title_label"):setString(TI18N("购买等级"))
    
    self.btn_buy = main_container:getChildByName("btn_buy")
    self.btn_buy:getChildByName("Text_1"):setString(TI18N("购   买"))
    local info_con = main_container:getChildByName("info_con")
	self.slider = info_con:getChildByName("slider")-- 滑块
    self.plus_btn = info_con:getChildByName("plus_btn")
    self.min_btn = info_con:getChildByName("min_btn")
    self.max_btn = info_con:getChildByName("max_btn")
    self.buy_price = info_con:getChildByName("buy_price")
    self.buy_price:setString("")

    --获取当前的信息
    self.cur_period = controller:getModel():getCurPeriod()
    self.cur_lev = controller:getModel():getCurLev()

    self.cur_max_lev = 0
    if lev_reward_list[self.cur_period] then
        self.cur_max_lev = #lev_reward_list[self.cur_period]
    end

    --购买等级
    self.buy_editbox = createEditBox(main_container, PathTool.getResFrame("common", "common_1021"), cc.size(200, 50), cc.c4b(0x95,0x95,0x95,0xff), 26, cc.c4b(0x95,0x95,0x95,0xff), 26, "1", nil, 6, LOADTEXT_TYPE_PLIST)
    self.buy_editbox:setPosition(269,200)
    self.buy_editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

    local function onEditInviteCodeEvent(event)
        if event.name == "began" then
            self.buy_editbox:setPlaceHolder("")
            self.buy_editbox:setText("")
        elseif event.name == "ended" or event.name == "return" then
            local lev = self.buy_editbox:getText()
            if lev ~= "" then
                local input = tonumber(lev)
                if input then
                    if input <= 0 then
                        input = 1
                    end
                    if input >= (self.cur_max_lev-self.cur_lev) then
                        input = self.cur_max_lev-self.cur_lev
                    end
                    self.buy_editbox:setText(input)

                    self.cur_buy_lev = input + self.cur_lev
                    if self.cur_buy_lev >= self.cur_max_lev then
                        self.cur_buy_lev = self.cur_max_lev
                    end
                    if self.cur_buy_lev <= self.cur_lev then
                        self.cur_buy_lev = self.cur_lev+1
                    end
                    self:buyDescript(self.cur_buy_lev)
                end
            end
        end
    end
    self.buy_editbox:onEditHandler(onEditInviteCodeEvent)

    self.reward_hight_desc = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5), cc.p(340,472), nil, nil, 400)
    main_container:addChild(self.reward_hight_desc)
    self.reward_common_desc = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5), cc.p(340,657), nil, nil, 400)
    main_container:addChild(self.reward_common_desc)

    self.lev_desc = createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5), cc.p(109,258), nil, nil, 400)
    main_container:addChild(self.lev_desc)

    --高级奖励
    local hight_goods = main_container:getChildByName("hight_goods")
    local scroll_view_size = hight_goods:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 32,
        space_x = 20,
        start_y = 0,
        space_y = 0,
        item_width = BackPackItem.Width,
        item_height = BackPackItem.Height,
        row = 1,
        col = 4,
    }
    self.item_hight_scrollview = CommonScrollViewLayout.new(hight_goods, cc.p(0,0),ScrollViewDir.horizontal,ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_hight_scrollview:setSwallowTouches(false)
    
    --普通奖励
    local common_goods = main_container:getChildByName("common_goods")
    local scroll_view_size = common_goods:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 32,
        space_x = 20,
        start_y = 0,
        space_y = 0,
        item_width = BackPackItem.Width,
        item_height = BackPackItem.Height,
        row = 1,
        col = 4,
    }
    self.item_common_scrollview = CommonScrollViewLayout.new(common_goods, cc.p(0,0),ScrollViewDir.horizontal,ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_common_scrollview:setSwallowTouches(false)
    
    self.cur_buy_lev = self.cur_lev + 1
    self:setEditBoxText(self.cur_buy_lev)
    self:buyDescript(self.cur_buy_lev)
    self:ticketInitShow(self.cur_buy_lev)
    self.btn_close = main_container:getChildByName("btn_close")
end
function BuyLevWindow:register_event()
	registerButtonEventListener(self.btn_close, function()
        controller:openBuyLevView(false)
    end,true, 2)

    registerButtonEventListener(self.plus_btn, function()
        self:addBuy()
    end,true, 1)
    registerButtonEventListener(self.min_btn, function()
        self:minusBuy()
    end,true, 1)
    registerButtonEventListener(self.max_btn, function()
        self:maxBuy()
    end,true, 1)

    registerButtonEventListener(self.btn_buy, function()
        local buy_lev = self.cur_buy_lev - self.cur_lev
        controller:send25307(buy_lev)
    end,true, 1)
end

function BuyLevWindow:setEditBoxText(num)
    if self.buy_editbox then
        num = num - self.cur_lev
        self.buy_editbox:setText(num)
    end
end

function BuyLevWindow:addBuy()
    self.cur_buy_lev = self.cur_buy_lev + 1
    if lev_reward_list[self.cur_period] then
        self.touch_max_btn = nil
        if self.cur_buy_lev > self.cur_max_lev then
            self.cur_buy_lev = self.cur_max_lev
            message(TI18N("已经到达最大等级了~~~"))
            return
        end
    end
    self:setEditBoxText(self.cur_buy_lev)
    self:buyDescript(self.cur_buy_lev)    
end
function BuyLevWindow:minusBuy()
    self.cur_buy_lev = self.cur_buy_lev - 1
    self:setEditBoxText(self.cur_buy_lev)
    self.touch_max_btn = nil
    if self.cur_buy_lev <= self.cur_lev then
        self.cur_buy_lev = self.cur_lev
        message(TI18N("已经是购买最小等级了~~~"))
        self:setEditBoxText(self.cur_buy_lev+1)
        return
    end
    if self.cur_buy_lev <= 0 then
        self.cur_buy_lev = 0
    end
    self:buyDescript(self.cur_buy_lev)    
end
function BuyLevWindow:maxBuy()
    if self.touch_max_btn then return end
    if not lev_reward_list[self.cur_period] then return end
    self.cur_buy_lev = self.cur_max_lev
    self:setEditBoxText(self.cur_buy_lev)
    self.touch_max_btn = true
    self:buyDescript(self.cur_max_lev)    
end

function BuyLevWindow:buyDescript(lev)
    local temp_lev = lev
    if not lev_reward_list[self.cur_period] then return end
    self:clearTicket()
    if self.buy_lev_ticket == nil then
        self.buy_lev_ticket = GlobalTimeTicket:getInstance():add(function()
            self:ticketInitShow(temp_lev)
        end,0.3)
    end

    lev = lev - self.cur_lev
    local str = string.format(TI18N("购买 <div fontcolor=#249003>%d</div> 级，升至 <div fontcolor=#249003>%d</div> 级"),lev,self.cur_buy_lev)
    self.lev_desc:setString(str)
    local totle_price = 1000 * lev
    self.buy_price:setString(totle_price*0.6)
end

function BuyLevWindow:ticketInitShow(lev)
    if not lev then return end
    local hight_list, hight_num, common_list, common_num = self:addTicket(lev)
    local hight_str = string.format(TI18N("激活进阶卡，更可解锁 <div fontcolor=#249003>%d</div> 件高级奖励"),lev,hight_num)
    if self.reward_hight_desc then
        self.reward_hight_desc:setString(hight_str)
    end
    local common_str = string.format(TI18N("升至 <div fontcolor=#249003>%d</div> 级，可立即解锁 <div fontcolor=#249003>%d</div> 件普通奖励"),lev,common_num)
    if self.reward_common_desc then
        self.reward_common_desc:setString(common_str)
    end
    if self.item_hight_scrollview then
        self.item_hight_scrollview:setData(hight_list)
        self.item_hight_scrollview:addEndCallBack(function()
            local item_list = self.item_hight_scrollview:getItemList()
            for k,v in pairs(item_list) do
                v:setDefaultTip()
            end
        end)
    end
    if self.item_common_scrollview then
        self.item_common_scrollview:setData(common_list)
        self.item_common_scrollview:addEndCallBack(function()
            local item_list = self.item_common_scrollview:getItemList()
            for k,v in pairs(item_list) do
                v:setDefaultTip()
            end
        end)
    end
end

function BuyLevWindow:clearTicket()
    if self.buy_lev_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_lev_ticket)
        self.buy_lev_ticket = nil
    end
end

function BuyLevWindow:addTicket(temp_lev)
    self:clearTicket()
    local hight_list = {}
    local hight_items = {}
    local totle_hight_num = 0

    local common_list = {}
    local common_items = {}
    local totle_common_num = 0
    for i=self.cur_lev+1, temp_lev do
        if lev_reward_list[self.cur_period][i] then
            --普通奖励
            if lev_reward_list[self.cur_period][i].reward then
                local common_num = 0
                if lev_reward_list[self.cur_period][i].common_num then
                    common_num = lev_reward_list[self.cur_period][i].common_num
                end
                totle_common_num = totle_common_num + common_num

                for j,v in ipairs(lev_reward_list[self.cur_period][i].reward) do
                    if common_items[v[1]] then
                        common_items[v[1]] = common_items[v[1]] + v[2]
                    else
                        common_items[v[1]] = v[2]
                    end   
                end
            end
        end
    end

    --高级奖励在没有激活进阶卡的时候需要从1级计算
    local rmb_status = controller:getModel():getRMBStatus()
    local rmb_lev = 1
    if rmb_status == 1 then
        rmb_lev = self.cur_lev+1
    end
    for i=rmb_lev, temp_lev do
        if lev_reward_list[self.cur_period][i] then
            --高级奖励
            if lev_reward_list[self.cur_period][i].rmb_reward then
                local hight_num = 0
                if lev_reward_list[self.cur_period][i].hight_num then
                    hight_num = lev_reward_list[self.cur_period][i].hight_num
                end
                totle_hight_num = totle_hight_num + hight_num

                for j,v in ipairs(lev_reward_list[self.cur_period][i].rmb_reward) do
                    if hight_items[v[1]] then
                        hight_items[v[1]] = hight_items[v[1]] + v[2]
                    else
                        hight_items[v[1]] = v[2]
                    end    
                end
            end
        end
    end

    local price_list = Config.HolidayWarOrderData.data_price_list
    --高级奖励
    for id,count in pairs(hight_items) do
        local sort = 0
        if price_list[id] then
            sort = price_list[id].sort or 0
        end
        table_insert(hight_list, {bid = id, quantity = count, sort = sort})
    end
    --普通奖励
    for id,count in pairs(common_items) do
        local sort = 0
        if price_list[id] then
            sort = price_list[id].sort or 0
        end
        table_insert(common_list, {bid = id, quantity = count, sort = sort})
    end

    table_sort(hight_list,function(a,b) return a.sort < b.sort end)
    table_sort(common_list,function(a,b) return a.sort < b.sort end)

    return hight_list, totle_hight_num, common_list, totle_common_num
end

function BuyLevWindow:openRootWnd()
end

function BuyLevWindow:close_callback()
    self:clearTicket()
    if self.item_hight_scrollview then
        self.item_hight_scrollview:DeleteMe()
        self.item_hight_scrollview = nil
    end
	controller:openBuyLevView(false)
end