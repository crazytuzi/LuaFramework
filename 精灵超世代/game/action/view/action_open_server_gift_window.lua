-----------------------------------------------
-- @author: zj@qqg.com
-- @date:   2019-04-19 14:11:23
-- @description:   开服超值礼包
-----------------------------------------------
ActionOpenServerGiftWindow = ActionOpenServerGiftWindow or BaseClass(BaseView)

local string_format = string.format
local item_size = cc.size(642, 284)

function ActionOpenServerGiftWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "action/action_open_server_gift_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("aciontopenserver", "aciontopenserver"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/action", "txt_cn_action_open_server_gift"), type = ResourcesType.single},
	}
	self.controller = ActionController:getInstance() 
 	self.model = ActionController:getInstance():getModel()

 	self.open_server_charge_id = 0 --当前充值ID
end

function ActionOpenServerGiftWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setAnchorPoint(cc.p(0.5, 0.5))
	self.background:setPosition(360,640)
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.container, 1)
	self.time_text = self.main_container:getChildByName("label_time")	--活动倒计时
	self.time_text:setString("")
	self.btn_close = self.main_container:getChildByName("btn_close")

	local panel_item = self.main_container:getChildByName("panel_item")
	local scroll_view_size = panel_item:getContentSize()
    local setting = {
        item_class = ActionOpenServerGiftItem, -- 单元类
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 2, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = item_size.width, -- 单元的尺寸width
        item_height = item_size.height, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
        scale = 1
    }
    self.item_scrollview = CommonScrollViewLayout.new(panel_item,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview:setClickEnabled(false)
end

function ActionOpenServerGiftWindow:openRootWnd(bid)
	if bid then
		self.holiday_bid = bid
		self.controller:cs16603(self.holiday_bid)
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.open_server_recharge, false)
	end
end

function ActionOpenServerGiftWindow:register_event()
	registerButtonEventListener(self.background, function()
		self.controller:openActionOpenServerGiftWindow(false)
	end, false, 2)
	registerButtonEventListener(self.btn_close, function()
        self.controller:openActionOpenServerGiftWindow(false)
    end, false, 2)

    if not self.update_action_open_server_event then
		self.update_action_open_server_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
			if data.bid == self.holiday_bid then
				self:setData(data)
			end
		end)
	end

	if not self.open_server_charge_data then
        self.open_server_charge_data = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function(data)
            if data and data.status and data.charge_id then
                local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                if charge_config and data.status == 1 and data.charge_id == self.open_server_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name, charge_config.name)
                end
            end
        end)
    end
end

function ActionOpenServerGiftWindow:setData(data)
	local time = data.remain_sec or 0
	self.model:setCountDownTime(self.time_text, time)

	-- status 0为可购买，2为买完（放后面）
    local function sortFunc( objA, objB )
        if objA.status == objB.status then
            local price_a = 0 -- 价格
            local price_b = 0
            for k,v in pairs(objA.aim_args) do
                if v.aim_args_key == 27 then
                    price_a = v.aim_args_val
                end
            end
            for k,v in pairs(objB.aim_args) do
                if v.aim_args_key == 27 then
                    price_b = v.aim_args_val
                end
            end
            return price_a < price_b
        else
            return objA.status < objB.status
        end
    end
    table.sort(data.aim_list, sortFunc)
    if #data.aim_list > 3 then
    	self.item_scrollview:setClickEnabled(true)
    end
    self.item_scrollview:setData(data.aim_list,function(data)
        if data and data.charge_id and data.left_time > 0 then
            self.open_server_charge_id = data.charge_id
            ActionController:getInstance():sender21016(data.charge_id)
        end
    end)
end

function ActionOpenServerGiftWindow:close_callback()
	doStopAllActions(self.time_text)
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
	end
	if self.update_action_open_server_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_action_open_server_event)
        self.update_action_open_server_event = nil
    end
    if self.open_server_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.open_server_charge_data)
        self.open_server_charge_data = nil
    end
end

-----------------------------------------------
ActionOpenServerGiftItem = class("ActionOpenServerGiftItem", function()
	return ccui.Layout:create()
end) 

function ActionOpenServerGiftItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_open_server_gift_item"))
	self:addChild(self.root_wnd)
    self:setAnchorPoint(cc.p(0, 0))
    self:setContentSize(item_size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.label_title = self.main_container:getChildByName("label_title")	--标题
    self.label_title:setString("")
    self.label_item_desc = self.main_container:getChildByName("label_item_desc") --描述
    self.label_item_desc:setString("")
    self.label_cost = self.main_container:getChildByName("label_cost") 		--折扣前金额
	self.label_cost:setString("")
    self.label_limit = self.main_container:getChildByName("label_limit")	--限购
    self.label_limit:setString("")
	self.img_line = self.main_container:getChildByName("img_line") 			--红线

    self.img_has_get = self.main_container:getChildByName("img_has_get")	--已领取
    self.img_has_get:setVisible(false)
    self.btn_get = self.main_container:getChildByName("btn_get")			--购买
 	self.btn_get:setTitleText("")
	local title = self.btn_get:getTitleRenderer()
	title:enableOutline(Config.ColorData.data_color4[278],2)

    self.good_cons = self.main_container:getChildByName("goods_con")
	local scroll_view_size = self.good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 5, -- 第一个单元的X起点
        space_x = 15, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = BackPackItem.Width * 0.8, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.8, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.8
    }

    self.cell_item_scrollview = CommonScrollViewLayout.new(self.good_cons,cc.p(0, 0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size,setting)
    self.cell_item_scrollview:setSwallowTouches(false)
    self.cell_item_scrollview:setClickEnabled(false)

    self.touch_get_btn = true
    self:registerEvent()
end

function ActionOpenServerGiftItem:registerEvent()
    self.btn_get:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.touch_get_btn then return end
            if self.get_item_ticket == nil then
                self.get_item_ticket = GlobalTimeTicket:getInstance():add(function()
                    self.touch_get_btn = true
                    if self.get_item_ticket ~= nil then
                        GlobalTimeTicket:getInstance():remove(self.get_item_ticket)
                        self.get_item_ticket = nil
                    end
                end,2)
            end
            self.touch_get_btn = nil
            if self.call_back and self.data then
                self.call_back(self.data)
            end
        end
    end)
end

function ActionOpenServerGiftItem:addCallBack(callback)
    self.call_back = callback
end

function ActionOpenServerGiftItem:getData()
    return self.data
end

function ActionOpenServerGiftItem:setData(data)
    self.data = data
    --标题
    self.label_title:setString(data.aim_str)

    --描述
    local desc_list = keyfind('aim_args_key', ActionExtType.ItemDesc, data.aim_args)
    self.label_item_desc:setString(desc_list.aim_args_str or "")

    --当前已购买次数/总次数
    local totle_count,current_count
    local current_list = keyfind('aim_args_key', ActionExtType.RechageCurCount, data.aim_args)
    local totle_list = keyfind('aim_args_key', ActionExtType.RechageTotalCount, data.aim_args)
    current_count = current_list.aim_args_val or 0
    totle_count = totle_list.aim_args_val or 0
    self.label_limit:setString(TI18N(string_format("限购：%d/%d",current_count,totle_count)))

    --剩余购买次数
    self.data.left_time = totle_count - current_count

    --折扣前价格、折扣后价格
    local price,discount_price
    local price_list = keyfind('aim_args_key', ActionExtType.ActivityOldPrice, data.aim_args)
    local dis_price_list = keyfind('aim_args_key', ActionExtType.ActivityCurrentPrice, data.aim_args)
    price = price_list.aim_args_val or 0
    discount_price = dis_price_list.aim_args_val or 0
    self.label_cost:setString(TI18N(string_format("%d元", price)))
    self.btn_get:setTitleText(TI18N(string_format("%d元领取", discount_price)))

    local charge_list = keyfind('aim_args_key', ActionExtType.ItemRechargeId, data.aim_args)
    --支付物品ID
    self.data.charge_id = charge_list.aim_args_val or 0

    --加载礼包物品列表
    self:loadRewardList(data.item_list)

	self.btn_get:setVisible(self.data.left_time > 0)
    self.img_has_get:setVisible(self.data.left_time <= 0)
end

function ActionOpenServerGiftItem:loadRewardList(item_list)
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
	    if item_count > 4 then
	   		self.cell_item_scrollview:setClickEnabled(true)
	   	else
            local posX = (4 - item_count) * 65 - (3 - item_count) * 10
	   		self.cell_item_scrollview:setPositionX(posX)
	   	end
	    self.cell_item_scrollview:setData(list)
	    self.cell_item_scrollview:addEndCallBack(function()
	        local list = self.cell_item_scrollview:getItemList()
	        for k,v in pairs(list) do
	            v:setDefaultTip()
	            v:setSwallowTouches(false)
	        end
	    end)
	end
end

function ActionOpenServerGiftItem:DeleteMe()
    if self.cell_item_scrollview then
        self.cell_item_scrollview:DeleteMe()
        self.cell_item_scrollview = nil
    end
    if self.get_item_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.get_item_ticket)
        self.get_item_ticket = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end