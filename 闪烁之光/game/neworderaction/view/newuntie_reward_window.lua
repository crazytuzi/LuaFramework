--******** 文件说明 ********
-- @Author:      yuanqi@shiyue.com 
-- @description: 奖励总览
-- @DateTime:    2020-02-20
-- *******************************
NewUntieRewardWindow = NewUntieRewardWindow or BaseClass(BaseView)

local controller = OrderActionController:getInstance()
local lev_reward_list = Config.HolidayNewWarOrderData.data_lev_reward_list
local table_insert = table.insert
local table_sort = table.sort
function NewUntieRewardWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "orderaction/untie_reward_window"
end

function NewUntieRewardWindow:open_callback()
	local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.main_container:getChildByName("title_con"):getChildByName("title_label"):setString(TI18N("奖励总览"))
    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy:getChildByName("Text_1"):setString(TI18N("解锁领取"))
    if controller:getModel():getGiftStatus() == 1 then
        self.btn_buy:getChildByName("Text_1"):setString(TI18N("查看进阶卡"))
    end
    self:commonShowReward()
    self.btn_close = self.main_container:getChildByName("btn_close")
end

function NewUntieRewardWindow:commonShowReward()
    local goods_1 = self.main_container:getChildByName("goods_1")
    local scroll_view_size = goods_1:getContentSize()
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
    self.item_good_1 = CommonScrollViewLayout.new(goods_1, cc.p(0,0),ScrollViewDir.vertical,ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_good_1:setSwallowTouches(false)

    local period = controller:getModel():getCurPeriod()
    if lev_reward_list[period] then
        local count = #lev_reward_list[period]
        local list = {}
        local dic_items = {}
        for i=1, count do
            if lev_reward_list[period][i] then
                if lev_reward_list[period][i].reward then
                    for j,v in ipairs(lev_reward_list[period][i].reward) do
                        if dic_items[v[1]] then
                            dic_items[v[1]] = dic_items[v[1]] + v[2]
                        else
                            dic_items[v[1]] = v[2]
                        end    
                    end
                    for j,v in ipairs(lev_reward_list[period][i].rmb_reward) do
                        if dic_items[v[1]] then
                            dic_items[v[1]] = dic_items[v[1]] + v[2]
                        else
                            dic_items[v[1]] = v[2]
                        end   
                    end
                end
            end
        end
        local price_list = Config.HolidayNewWarOrderData.data_price_list
        for id,count in pairs(dic_items) do
            local sort = 0
            if price_list[id] then
                sort = price_list[id].sort or 0
            end
            table_insert(list, {bid = id, quantity = count, sort = sort})
        end
        table_sort(list,function(a,b) return a.sort < b.sort end)
        self.item_good_1:setData(list)
        self.item_good_1:addEndCallBack(function()
            local item_list = self.item_good_1:getItemList()
            for k,v in pairs(item_list) do
                v:setDefaultTip()
            end
        end)
    end
end

function NewUntieRewardWindow:register_event()
	registerButtonEventListener(self.btn_close, function()
        controller:openUntieRewardView(false)
    end,true, 2)

    registerButtonEventListener(self.btn_buy, function()
        local period = controller:getModel():getCurPeriod()
        if period == 1 or period == 2 then
            local root = controller:getOrderActionMainRoot()
            if root then
                controller:openUntieRewardView(false)
                root:tabChargeView(3,period)
            end
        else
            controller:openBuyCardView(true)
        end
    end,true, 1)
end
function NewUntieRewardWindow:openRootWnd()
    
end
function NewUntieRewardWindow:close_callback()
    if self.item_good_1 then
        self.item_good_1:DeleteMe()
        self.item_good_1 = nil
    end
	controller:openUntieRewardView(false)
end