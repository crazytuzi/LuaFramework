--------------------------------------------
-- @Author  : lc
-- @Editor  : lc
-- @Date    : 2019-10-12
-- @description    : 
		-- 合服钜惠商城
---------------------------------
local controller = ActionController:getInstance()
MergeTimeShopPanel = class("MergeTimeShopPanel", function()
    return ccui.Widget:create()
end)

function MergeTimeShopPanel:ctor(bid)
	self.holiday_bid = bid
	self:configUI()
	self:register_event()
end

function MergeTimeShopPanel:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/week_month_panel"))
    self:addChild(self.root_wnd)
    self:setPosition(-40, -64)
    self:setAnchorPoint(0, 0)
    
    local main_container = self.root_wnd:getChildByName("main_container")
    local title_con = main_container:getChildByName("title_con")
    local btn_rule = title_con:getChildByName("btn_rule")
    btn_rule:setVisible(false)
    local sprite_title = title_con:getChildByName("sprite_title")

    local str_banner = "txt_cn_welfare_banner76"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str_banner = tab_vo.reward_title
    end
    local res = PathTool.getWelfareBannerRes(str_banner)
    if not self.banner_load then
        self.banner_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(sprite_title) then
                loadSpriteTexture(sprite_title, res, LOADTEXT_TYPE)
            end
        end,self.banner_load)
    end

    local time_panel = title_con:getChildByName("time_panel")
    time_panel:getChildByName("Text_1"):setString(TI18N("剩余时间: "))
    self.remain_time = time_panel:getChildByName("remain_time")
    self.remain_time:setString("")
    self.remain_time:setPositionX(117)
    time_panel:setPositionX(0)

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = MergeTimeShopItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 2,                    -- 第一个单元的Y起点
        space_y = 2,                   -- y方向的间隔
        item_width = 688,               -- 单元的尺寸width
        item_height = 136,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }
    self.child_scrollview = CommonScrollViewLayout.new(good_cons,cc.p(0,0),ScrollViewDir.vertical,ScrollViewStartPos.top, scroll_view_size, setting)
    self.child_scrollview:setSwallowTouches(false)
    controller:cs16603(self.holiday_bid)
end

function MergeTimeShopPanel:register_event(  )
	if not self.time_shop_event  then
		self.time_shop_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
			if data.bid == self.holiday_bid then
                controller:getModel():setCountDownTime(self.remain_time,data.remain_sec)
				self:setLimitShopData(data)
			end
		end)
	end
end

function MergeTimeShopPanel:setLimitShopData( data )
    local shop_data = {}
    for i,v in pairs(data.aim_list) do
        local sort_data = keyfind('aim_args_key', 39, v.aim_args) or nil
        if sort_data then
            local sort_id = sort_data.aim_args_val
            if v.status == 2 then
                sort_id = 5
            end
            v.sort_id = sort_id
            table.insert(shop_data,v)
        end
    end
    if next(shop_data) == nil then
        -- status 0为可购买，2为买完（放后面）
        local function sortFunc( objA, objB )
            if objA.status == objB.status then
                local price_a = 0 -- 价格
                local price_b = 0
                local price_a_data = keyfind('aim_args_key', 27, objA.aim_args) or nil
                if price_a_data then
                    price_a = price_a_data.aim_args_val
                end
                local price_b_data = keyfind('aim_args_key', 27, objB.aim_args) or nil
                if price_b_data then
                    price_b = price_b_data.aim_args_val
                end
                -- 贵的放后面
                return price_a < price_b
            else
                return objA.status < objB.status
            end
        end
        table.sort(data.aim_list, sortFunc)
        self.child_scrollview:setData(data.aim_list)
    else
        table.sort(shop_data, function(a,b) return a.sort_id < b.sort_id end)
        self.child_scrollview:setData(shop_data)
    end
end

function MergeTimeShopPanel:setVisibleStatus(bool)
	bool = bool or false
    self:setVisible(bool) 
end

function MergeTimeShopPanel:DeleteMe()
	doStopAllActions(self.remain_time)
	if self.banner_load then
		self.banner_load:DeleteMe()
		self.banner_load = nil
	end
	if self.child_scrollview then
		self.child_scrollview:DeleteMe()
		self.child_scrollview = nil
	end
	if self.time_shop_event then
        GlobalEvent:getInstance():UnBind(self.time_shop_event)
        self.time_shop_event = nil
    end
end

---------------------------@ 子项
MergeTimeShopItem = class("MergeTimeShopItem", function()
    return ccui.Widget:create()
end)

function MergeTimeShopItem:ctor()
    self.touch_buy_limit_shop = true
	self:configUI()
	self:register_event()
end

function MergeTimeShopItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/week_month_panel_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(688,136))
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.has_get = main_container:getChildByName("has_get")
    self.btn_charge = main_container:getChildByName("btn_charge")
    self.charge_price = self.btn_charge:getChildByName("Text_4_0")
    self.text_remian = main_container:getChildByName("Text_4")   

    local item_goods = main_container:getChildByName("good_cons")
    local scroll_view_size = item_goods:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 12,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.80
    }
    self.good_scrollview = CommonScrollViewLayout.new(item_goods, cc.p(0,0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)
end

function MergeTimeShopItem:register_event()
	registerButtonEventListener(self.btn_charge, function()
        if not self.touch_buy_limit_shop then return end
        if self.buy_limit_shop_ticket == nil then
            self.buy_limit_shop_ticket = GlobalTimeTicket:getInstance():add(function()
                self.touch_buy_limit_shop = true
                if self.buy_limit_shop_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.buy_limit_shop_ticket)
                    self.buy_limit_shop_ticket = nil
                end
            end,2)
        end
        self.touch_buy_limit_shop = nil

		if self.data and self.data.aim then
			local charge_config = Config.ChargeData.data_charge_data[self.data.aim]
	        if charge_config then
	            sdkOnPay(charge_config.val, nil, charge_config.id, charge_config.name, charge_config.name)
	        end
		end
	end, true)
end

function MergeTimeShopItem:setData( data )
	if not data then return end

	self.data = data
	-- 物品列表
    local list = {}
    for k, v in pairs(data.item_list or {}) do
        local vo = {}
        vo.bid = v.bid
        vo.quantity = v.num
        table.insert(list, vo)
    end
    self.good_scrollview:setData(list)
    self.good_scrollview:addEndCallBack(function()
        local item_list = self.good_scrollview:getItemList()
        for k,v in pairs(item_list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)

    if data.status == 2 then -- 卖完
        self.btn_charge:setVisible(false)
        self.text_remian:setVisible(false)
    	self.has_get:setVisible(true)
    else
    	self.has_get:setVisible(false)
        self.btn_charge:setVisible(true)
        self.text_remian:setVisible(true)

    	-- 剩余数量
    	local max_num = 0
    	local buy_num = 0
        local price = 0 -- 价格
    	for k,v in pairs(data.aim_args) do
    		if v.aim_args_key == 2 then
    			max_num = v.aim_args_val
    		elseif v.aim_args_key == 6 then
    			buy_num = v.aim_args_val
            elseif v.aim_args_key == 27 then
                price = v.aim_args_val
    		end
    	end
    	self.text_remian:setString(string.format(TI18N("剩余:%d"), (max_num-buy_num)))
        -- 价格
        self.charge_price:setString(price .. TI18N("元"))
    end
end

function MergeTimeShopItem:DeleteMe()
    if self.buy_limit_shop_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_limit_shop_ticket)
        self.buy_limit_shop_ticket = nil
    end
	if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end