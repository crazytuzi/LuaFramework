--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 月、周福利
-- @DateTime:    2019-03-28 14:10:56
MonthWeekPanel = class("MonthWeekPanel", function()
	return ccui.Widget:create()
end)
local controller = WelfareController:getInstance()
local model = controller:getModel()
local table_sort = table.sort
local table_insert = table.insert
local gift_info = Config.MiscData.data_cycle_gift_info
local reward_list = Config.MiscData.data_cycle_gift_reward
function MonthWeekPanel:ctor(holiday_id)
	self.holiday_id = holiday_id
	self:configUI()
	self:register_event()
end

function MonthWeekPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/week_month_panel"))
	self:addChild(self.root_wnd)
	self:setAnchorPoint(0, 0)
	
    local main_container = self.root_wnd:getChildByName("main_container")
    local title_con = main_container:getChildByName("title_con")
    self.title_con = title_con
    self.btn_rule = title_con:getChildByName("btn_rule")
    self.btn_rule:setVisible(false)
    local sprite_title = title_con:getChildByName("sprite_title")
    
    self.shop_btn = title_con:getChildByName("btn_shop")
    self.shop_btn:setLocalZOrder(2)
    if self.holiday_id == WelfareIcon.week then -- 每周特惠
        local limit_cfg = Config.MiscData.data_const["hero_store_sign_time"] -- 注册时间限制
        local role_vo = RoleController:getInstance():getRoleVo()
        -- 要求注册时间小于配置的时间 或 注册时间大于等于配置时间且开服天数大于等于8天，才显示英魂商店
        if role_vo.reg_time < limit_cfg.val or role_vo.open_day >= 8 then 
            self.shop_btn:setVisible(true)
            self:handleShopffect(true)
        else
            self.shop_btn:setVisible(false)
        end
    else
        self.shop_btn:setVisible(false)
    end
	
	self.send_holiday_id = 1 --周循环
    local str = "txt_cn_welfare_banner6"
    if self.holiday_id == WelfareIcon.week and not self.shop_btn:isVisible() then
        str = "txt_cn_welfare_banner116"
	elseif self.holiday_id == WelfareIcon.month then
		str = "txt_cn_welfare_banner7"
		self.send_holiday_id = 2
	end
	local res = PathTool.getWelfareBannerRes(str)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(sprite_title) then
    			loadSpriteTexture(sprite_title, res, LOADTEXT_TYPE)
    		end
    	end,self.item_load)
    end

    local time_panel = title_con:getChildByName("time_panel")
    time_panel:getChildByName("Text_1"):setString(TI18N("剩余时间: "))
    self.remain_time = time_panel:getChildByName("remain_time")
    self.remain_time:setString("")

    self.good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = self.good_cons:getContentSize()
    local setting = {
        item_class = MonthWeekItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 688,               -- 单元的尺寸width
        item_height = 136,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end
function MonthWeekPanel:register_event()
	if self.update_month_week_data == nil then
        self.update_month_week_data = GlobalEvent:getInstance():Bind(WelfareEvent.Updata_Week_Month_Data,function(data)
            self:getMonthWeekItemInfo(data)
        end)
    end
    if self.update_month_charge_data == nil then
        self.update_month_charge_data = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function(data)
            if data and data.status and data.charge_id then
                local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                local cur_charge_id = model:getMonthWeekChargeID()
                if cur_charge_id and charge_config and data.status == 1 and data.charge_id == cur_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
                end
            end
        end)
    end

    registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true)
end

function MonthWeekPanel:onClickShopBtn(  )
    if self.holiday_id ~= WelfareIcon.week then return end
	local setting = {}
    setting.mall_type = MallConst.MallType.HeroSoulShop
    setting.item_id = 10005 -- 英魂之心
    setting.config = Config.ExchangeData.data_shop_exchage_herosoul
    setting.shop_name = TI18N("英魂商店")
    MallController:getInstance():openMallSingleShopPanel(true, setting)
end

function MonthWeekPanel:handleShopffect( status )
    if self.holiday_id ~= WelfareIcon.week then return end
    if status == false then
        if self.shop_effect_1 then
            self.shop_effect_1:clearTracks()
            self.shop_effect_1:removeFromParent()
            self.shop_effect_1 = nil
		end
		if self.shop_effect_2 then
            self.shop_effect_2:clearTracks()
            self.shop_effect_2:removeFromParent()
            self.shop_effect_2 = nil
        end
    else
		if not tolua.isnull(self.title_con) and self.shop_effect_1 == nil then
            self.shop_effect_1 = createEffectSpine("E20989", cc.p(85, 85), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self.title_con:addChild(self.shop_effect_1, 1)
		end
		if not tolua.isnull(self.shop_btn) and self.shop_effect_2 == nil then
            self.shop_effect_2 = createEffectSpine("E20989", cc.p(66, 75), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.shop_btn:addChild(self.shop_effect_2)
        end
    end
end

function MonthWeekPanel:getMonthWeekItemInfo(data)
	self:setLessTime(data.ref_time - GameNet:getInstance():getTime())
	if gift_info[data.type] then
		self:setBuyCount(data.first_gift)
        local list = {}
        local role_vo = RoleController:getInstance():getRoleVo()
		for i,v in pairs(gift_info[data.type]) do
            local is_open = false
            if reward_list[v.charge_id] then
                for _,n in ipairs(reward_list[v.charge_id]) do
                    if self.holiday_id == WelfareIcon.week then -- 每周特惠
                        if data.reg_day >= n.min and data.reg_day <= n.max and role_vo.reg_time >= n.reg_min and role_vo.reg_time <= n.reg_max then
                            is_open = true
                        end
                    else 
                        if data.reg_day >= n.min and data.reg_day <= n.max then
                            is_open = true
                        end
                    end
                    if is_open == true then 
                        break
                    end
                end
            end
            if is_open == true then
                v.count = v.limit_count - self:getBuyCount(v.charge_id)
                if v.count <= 0 then
                    v.count = 0
                end
                v.reward = self:getRegisteDayReward(v.charge_id, data.reg_day)
                table_insert(list,v)
            end
		end
		self:sortList(list)
		self.item_scrollview:setData(list)
	end
end
function MonthWeekPanel:getRegisteDayReward(id,day)
    local role_vo = RoleController:getInstance():getRoleVo()
	if reward_list[id] then
		local num = 1
		for i,v in pairs(reward_list[id]) do
			if day >= v.min and day <= v.max and role_vo.reg_time >= v.reg_min and role_vo.reg_time <= v.reg_max then
				num = v.sort_id
				break
			end
		end
		return reward_list[id][num].reward
	end
	return {}
end
--排序
function MonthWeekPanel:sortList(list)
	local function sort_func(obj_a,obj_b)
		if obj_a.count <= 0 and obj_b.count > 0 then
			return false
		elseif obj_a.count > 0 and obj_b.count <= 0 then
			return true
		else
			return obj_a.charge_id < obj_b.charge_id
		end
	end
	table_sort(list,sort_func)
end
--获取购买的数量
function MonthWeekPanel:setBuyCount(data)
	if not data or next(data) == nil then return end
	self.buyCountData = {}
	for i,v in pairs(data) do
		self.buyCountData[v.id] = v.count
	end
end
function MonthWeekPanel:getBuyCount(id)
	if self.buyCountData and self.buyCountData[id] then
		return self.buyCountData[id]
	end
	return 0
end

--设置倒计时
function MonthWeekPanel:setLessTime(less_time)
    if tolua.isnull(self.remain_time) then return end
    doStopAllActions(self.remain_time)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.remain_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(self.remain_time)
                self.remain_time:setString("00:00:00")
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function MonthWeekPanel:setTimeFormatString(time)
    if time > 0 then
        self.remain_time:setString(TimeTool.GetTimeForFunction(time))
    else
        doStopAllActions(self.remain_time)
        self.remain_time:setString("00:00:00")
    end
end

function MonthWeekPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
	if bool == true and self.send_holiday_id then
		controller:sender21007(self.send_holiday_id)
	end
end

function MonthWeekPanel:DeleteMe()
    doStopAllActions(self.remain_time)
    self:handleShopffect(fasle)
	if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_month_week_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_month_week_data)
        self.update_month_week_data = nil
    end
    if self.update_month_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_month_charge_data)
        self.update_month_charge_data = nil
    end
end

--子项
MonthWeekItem = class("MonthWeekItem", function()
    return ccui.Widget:create()
end)

function MonthWeekItem:ctor()
    self.touch_buy_month = true
	self:configUI()
	self:register_event()
end

function MonthWeekItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/week_month_panel_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(688,136))
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.has_get = main_container:getChildByName("has_get")
    self.has_get:setVisible(false)
    self.btn_charge = main_container:getChildByName("btn_charge")
    self.charge_price = self.btn_charge:getChildByName("Text_4_0")
    self.text_remian = main_container:getChildByName("Text_4")   

    self.good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = self.good_cons:getContentSize()
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
    self.good_scrollview = CommonScrollViewLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)
end
function MonthWeekItem:register_event()
	registerButtonEventListener(self.btn_charge, function()
		if not self.touch_buy_month then return end
        if self.buy_month_ticket == nil then
            self.buy_month_ticket = GlobalTimeTicket:getInstance():add(function()
                self.touch_buy_month = true
                if self.buy_month_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.buy_month_ticket)
                    self.buy_month_ticket = nil
                end
            end,2)
        end
        self.touch_buy_month = nil
        if self.data and self.data.charge_id and self.data.count > 0 then
            if self.callback then
                self:callback()
            end
            model:setMonthWeekChargeID(self.data.charge_id)
            ActionController:getInstance():sender21016(self.data.charge_id)
        else
            message(TI18N("该礼包已售罄"))
        end
	end, true, 1)
end
function MonthWeekItem:getData()
    return self.data
end
function MonthWeekItem:addCallBack(value)
    self.callback =  value
end

function MonthWeekItem:setData(data)
	self.data = data
    self.charge_price:setString(GetSymbolByType()..data.val)
    if data.count <= 0 then
        data.count = 0 
        setChildUnEnabled(true, self.btn_charge)
        --self.charge_price:disableEffect(cc.LabelEffect.OUTLINE)
        self.charge_price:disableEffect(cc.LabelEffect.SHADOW)
    else
        setChildUnEnabled(false, self.btn_charge)
        --self.charge_price:enableOutline(Config.ColorData.data_color4[277], 2)
        self.charge_price:enableShadow(Config.ColorData.data_new_color4[4],cc.size(0, -2),2)
    end
    self.text_remian:setString(TI18N("剩余: ")..data.count) 
    local list = {}
    for k, v in pairs(data.reward) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        table.insert(list, vo)
    end
    if #list > 4 then
        self.good_scrollview:setClickEnabled(true)
    else
        self.good_scrollview:setClickEnabled(false)
    end
    self.good_scrollview:setData(list)
 	self.good_scrollview:addEndCallBack(function()
        local list = self.good_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end
function MonthWeekItem:DeleteMe()
	if self.buy_month_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_month_ticket)
        self.buy_month_ticket = nil
    end
	if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end