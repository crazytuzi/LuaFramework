--
-- @Author: zj@qqg.com
-- @Date:   2019-04-24 15:26:48
-- @description:	超值礼包
--
ActionHighValueGiftPanel = class("ActionHighValueGiftPanel", function()
	return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local model = ActionController:getInstance():getModel()
local string_format = string.format

function ActionHighValueGiftPanel:ctor(bid)
	self.holiday_bid = bid
    self.touch_btn = true
	self:configUI()
	self:register_event()
end

function ActionHighValueGiftPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_high_value_gift_panel"))
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setAnchorPoint(0, 0)

	self.main_container = self.root_wnd:getChildByName("main_container")
    local jump_str = "txt_cn_action_jump"
    self.jump_btn = createImage(self.main_container, PathTool.getPlistImgForDownLoad("bigbg/action", jump_str), 600, 770, cc.p(0.5,0.5), false, 1, true)
    self.jump_btn:setTouchEnabled(true)
    self.jump_btn:setVisible(false)

	self.img_bg = self.main_container:getChildByName("img_bg")
    local str = "txt_cn_action_high_value_gift_panel"
    self.holiday_bid = self.holiday_bid or ActionRankCommonType.high_value_gift
    local config_data = Config.FunctionData.data_limit_little_recharge[self.holiday_bid]
    if not config_data then return end
    if config_data.bg_name and config_data.bg_name ~= "" then
        str = config_data.bg_name 
    end
    print("str:", str)
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.img_bg) then
                loadSpriteTexture(self.img_bg, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.txt_time_title = self.main_container:getChildByName("txt_time_title") 	--时间标题
    self.txt_time_title:setString(TI18N("剩余时间:"))
    --self.txt_time_title:setTextColor(color(config_data.time_title_color))       --设置字体颜色
    --self.txt_time_title:enableOutline(color(config_data.time_stroke_color),2)   --设置字体描边
    self.txt_time_val = self.main_container:getChildByName("txt_time_val") 		--剩余时间
    --self.txt_time_val:setTextColor(color(config_data.time_title_color))
    --self.txt_time_val:enableOutline(color(config_data.time_stroke_color),2)
    self.txt_price = self.main_container:getChildByName("txt_price") 				--礼包原价
    --self.txt_price:setTextColor(color(config_data.common_color))
    self.txt_discount_title = self.main_container:getChildByName("txt_discount_title")
    self.txt_discount_title:setString(TI18N("现价："))
    --self.txt_discount_title:setTextColor(color(config_data.common_color))
    self.txt_discount_price = self.main_container:getChildByName("txt_discount_price") --礼包折扣价
    --self.txt_discount_price:setTextColor(color(config_data.common_color))
    
    --礼包限购次数
    self.txt_limit_time = self.main_container:getChildByName("txt_limit_time")
    if config_data.limit_color then
        --self.txt_limit_time:setTextColor(color(config_data.limit_color))
    end

    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.txt_buy = self.btn_buy:getChildByName("txt_buy")
    self.txt_buy:setString(TI18N("立即抢购"))

    local send_data = config_data.send_data
    if send_data and next(send_data) ~= nil then
        local bid = send_data[1][1]
        local num = send_data[1][2]
        local send_img = createImage(self.main_container, PathTool.getItemRes(bid), 180, 470, cc.p(0,0.5), false, 1, false)
        send_img:setScale(0.4)
        self.send_num = CommonNum.new(23, self.main_container, num, 1, cc.p(0, 0))
        self.send_num:setPosition(cc.p(180 + send_img:getContentSize().width * 0.4, 470))
    end

    local goods_list = self.main_container:getChildByName("goods_list")
    local scroll_size = goods_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 10,                  -- 第一个单元的X起点
        space_x = 25,                    -- x方向的间隔
        start_y = 8,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width * 0.9,   -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.9, -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scroll_view = CommonScrollViewLayout:create(goods_list, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_size, setting)
    self.item_scroll_view:setSwallowTouches(false)
    self.item_scroll_view:setClickEnabled(false)

    if self.holiday_bid == ActionRankCommonType.week_gift then
        --self.txt_time_title:setPositionY(569)
        --self.txt_time_val:setPositionY(569)
    elseif self.holiday_bid == ActionRankCommonType.high_value_gift then
        self.txt_time_title:setPositionY(480)
        self.txt_time_val:setPositionY(480)
    elseif self.holiday_bid == ActionRankCommonType.over_value_gift_1 then
        --在 12月24日的版本更新 41要求隐藏..后面要求再开启
        self.jump_btn:setVisible(false)

        self.txt_time_title:setPositionY(440)
        self.txt_time_val:setPositionY(440)
    elseif self.holiday_bid == ActionRankCommonType.over_value_gift_2 then
        self.txt_time_title:setPositionY(440)
        self.txt_time_val:setPositionY(440)
    end

    controller:cs16603(self.holiday_bid)
    model:setGiftRedStatus({bid = ActionRankCommonType.high_value_gift, status = false})
end

function ActionHighValueGiftPanel:register_event()
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if not data then return end
            if data.bid == self.holiday_bid then
                self:setData(data)
            end
        end)
    end

    registerButtonEventListener(self.btn_buy, function()
        if not self.touch_btn then return end
        if self.get_item_ticket == nil then
            self.get_item_ticket = GlobalTimeTicket:getInstance():add(function()
                self.touch_btn = true
                if self.get_item_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.get_item_ticket)
                    self.get_item_ticket = nil
                end
            end, 2)
        end
        self.touch_btn = nil
        if self.data and self.data.charge_id and self.data.left_time > 0 then
            self.cur_charge_id = self.data.charge_id
            ActionController:getInstance():sender21016(self.data.charge_id)
        end
    end, true, 1)

    registerButtonEventListener(self.jump_btn, function()
        HeavenController:getInstance():openHeavenMainWindow(true,nil,HeavenConst.Tab_Index.DialRecord)
    end, true, 1)

    if not self.charge_data_event then
        self.charge_data_event = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function(data)
            if data and data.status and data.charge_id then
                local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                if charge_config and data.status == 1 and data.charge_id == self.cur_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name, charge_config.name)
                end
            end
        end)
    end
end

function ActionHighValueGiftPanel:setData(data)
	if not data then return end
    --倒计时
    local time = data.remain_sec or 0
    model:setCountDownTime(self.txt_time_val, time)

    self.data = data.aim_list[1]

    --限购：已购次数/总次数
    local totle_count,current_count
    local current_list = keyfind('aim_args_key', ActionExtType.RechageCurCount, self.data.aim_args)
    local totle_list = keyfind('aim_args_key', ActionExtType.RechageTotalCount, self.data.aim_args)
    current_count = current_list.aim_args_val or 0
    totle_count = totle_list.aim_args_val or 0
    self.txt_limit_time:setString(string_format(TI18N("限购：%d/%d"),current_count,totle_count))
    --剩余购买次数
    self.data.left_time = totle_count - current_count

    --折扣前价格、折扣后价格
    local price,discount_price
    local price_list = keyfind('aim_args_key', ActionExtType.ActivityOldPrice, self.data.aim_args)
    local dis_price_list = keyfind('aim_args_key', ActionExtType.ActivityCurrentPrice, self.data.aim_args)
    price = price_list.aim_args_val or 0
    discount_price = dis_price_list.aim_args_val or 0
    --非中文版本特殊处理价格
    if not CHARGE_CONFIG_TYPE then
        price = price * 0.01
        discount_price = discount_price * 0.01
    end
	self.txt_price:setString(string_format(TI18N("原价:￥")..price))
	self.txt_discount_price:setString(GetSymbolByType()..discount_price)

    local charge_list = keyfind('aim_args_key', ActionExtType.ItemRechargeId, self.data.aim_args)
    --支付物品ID
    self.data.charge_id = charge_list.aim_args_val or 0
    
    --加载礼包物品列表
    self:loadRewardList(self.data.item_list)

    if self.data.left_time == 0 then
	    self.txt_buy:setString(TI18N("已领取"))
        --self.txt_buy:enableOutline(Config.ColorData.data_color4[84],2)
        setChildUnEnabled(true, self.btn_buy)
    else
        setChildUnEnabled(false, self.btn_buy)
    end
end

function ActionHighValueGiftPanel:loadRewardList(item_list)
    local list = {}
    if tableLen(item_list) > 0 then
        for k, v in pairs(item_list) do
            local vo = {}
            if vo then
                vo.bid = v.bid
                vo.quantity = v.num
                table.insert(list, vo)
            end
        end
        local item_count = #list
        if item_count > 5 then
            self.item_scroll_view:setClickEnabled(true)
            self.item_scroll_view:setPositionX(0)
        else
            self.item_scroll_view:setClickEnabled(false)
            self.item_scroll_view:setPositionX((5 - item_count) * 10 + (4 - item_count) * 55)
        end
        self.item_scroll_view:setData(list)
        self.item_scroll_view:addEndCallBack(function()
            local list = self.item_scroll_view:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
                v:setSwallowTouches(false)
            end
        end)
    end
end

function ActionHighValueGiftPanel:setVisibleStatus(bool)
	bool = bool or false
    self:setVisible(bool)
end

function ActionHighValueGiftPanel:DeleteMe()
    doStopAllActions(self.txt_time_val)
    if self.send_num then
        self.send_num:DeleteMe()
        self.send_num = nil
    end
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    -- if self.jump_load then 
    --     self.jump_load:DeleteMe()
    --     self.jump_load = nil
    -- end
	if self.item_scroll_view then
        self.item_scroll_view:DeleteMe()
        self.item_scroll_view = nil
    end
    if self.get_item_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.get_item_ticket)
        self.get_item_ticket = nil
    end
    if self.charge_data_event then
        GlobalEvent:getInstance():UnBind(self.charge_data_event)
        self.charge_data_event = nil
    end
    if self.update_action_even_event then
        GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
end