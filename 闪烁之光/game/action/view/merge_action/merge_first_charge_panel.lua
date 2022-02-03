--******** 文件说明 ********
-- @Author:      lc 
-- @description: 合服首充
-- @DateTime:    2019-10-14
-- *******************************
MergeFirstChargePanel = class("MergeFirstChargePanel", function()
    return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
function MergeFirstChargePanel:ctor(bid)
	self.holiday_bid = bid
	self.touch_buy_skin = true
	self.attr_list = {}
	self:configUI()
	self:register_event()
	self.charge_status = 0 
end

function MergeFirstChargePanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/merge_first_charge_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.holiday_bg = self.main_container:getChildByName("bg")
    self:setHolidayBG()
    
    self.time_text_0 = self.main_container:getChildByName("time_text_0")
    self.time_text_0:setString(TI18N("剩余时间："))


    self.text_attr = self.main_container:getChildByName("Text_32")
    self.text_attr:setVisible(false)

    local Text_2 = self.main_container:getChildByName("Text_2")
    Text_2:setVisible(false)
    self.text_price = self.main_container:getChildByName("text_price")
    self.text_price:setVisible(false)
    self.text_price:setString("")

    self.has_get = self.main_container:getChildByName("has_get")
    self.has_get:setVisible(false)

    self.btn_goto = self.main_container:getChildByName("btn_goto")
    self.btn_goto_text = self.btn_goto:getChildByName("Text_7_0")
    self.btn_goto_text:setString(TI18N("前往"))
    self.btn_goto:setVisible(false)

    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy_text = self.btn_buy:getChildByName("Text_4")
    self.btn_buy_text:setString(TI18N("领取"))
    self.btn_buy:setVisible(false)
    

    
    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString("")
    
	local goods = self.main_container:getChildByName("goods")
	local scroll_view_size = goods:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 75,
        space_x = 15,
        start_y = 15,
        space_y = 15,
        item_width = BackPackItem.Width * 0.9,
        item_height = BackPackItem.Height * 0.9,
        row = 0,
        col = 4,
        scale = 0.9
    }
    self.item_scrollview = CommonScrollViewLayout.new(goods,cc.p(0,0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
    
end

function MergeFirstChargePanel:setHolidayBG()
	local str_bg = "action_merge_first_charge"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.aim_title ~= "" and tab_vo.aim_title then
        str_bg = tab_vo.aim_title
    end
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str_bg)
    if not self.bg_load then
        self.bg_load = loadSpriteTextureFromCDN(self.holiday_bg, res, ResourcesType.single, self.bg_load)
    end
end

function MergeFirstChargePanel:register_event()
	if not self.merge_first_charge_event then
        self.merge_first_charge_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if not data then return end
            if data.bid == self.holiday_bid then
            	self.data = data
            	commonCountDownTime(self.time_text, data.remain_sec)
                self:setData(data)
            end
        end)
    end    

	registerButtonEventListener(self.btn_buy, function()
		ActionController:getInstance():cs16604(self.holiday_bid, self.data.aim_list[1].aim)
	end, true)

    registerButtonEventListener(self.btn_goto, function()
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
    end, true)
end

--首充奖励
function MergeFirstChargePanel:setData(data)
	local item_data = data.aim_list[1].item_list or nil
	if item_data then
		self.charge_status = data.aim_list[1].status
		if self.charge_status == 0 then
            self.has_get:setVisible(false)
            self.btn_buy:setVisible(false)
            self.btn_goto:setVisible(true)
	    elseif self.charge_status == 1 then
            self.has_get:setVisible(false)
            self.btn_buy:setVisible(true)
            self.btn_goto:setVisible(false)
	    else
            self.has_get:setVisible(true)
            self.btn_buy:setVisible(false)
            self.btn_goto:setVisible(false)
	    end
		self.charge_label = createRichLabel(26, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0,0.5), cc.p(25,620), nil, nil, 450)  -- 未完成
    	self.main_container:addChild(self.charge_label)
		self.charge_label:setString(data.aim_list[1].aim_str)
		local list = {}
	    for k, v in pairs(item_data) do
	        local vo = {}
            vo.bid = v.bid
            vo.quantity = v.num
            table.insert(list, vo)
	    end
	    if #list > 8 then
	   		self.item_scrollview:setClickEnabled(true)
		else
	   		self.item_scrollview:setClickEnabled(false)
	    end
	    
	    self.item_scrollview:setData(list)
	    self.item_scrollview:addEndCallBack(function()
	        local list = self.item_scrollview:getItemList()
	        for k,v in pairs(list) do
	            v:setDefaultTip()
	        end
	    end)
	    

	end
end



function MergeFirstChargePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
		ActionController:getInstance():cs16603(self.holiday_bid)
    end
end

function MergeFirstChargePanel:DeleteMe()
	-- if self.buy_skin_ticket ~= nil then
 --        GlobalTimeTicket:getInstance():remove(self.buy_skin_ticket)
 --        self.buy_skin_ticket = nil
 --    end
	doStopAllActions(self.time_text)
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end
	-- if self.item_scrollview then
 --        self.item_scrollview:DeleteMe()
 --        self.item_scrollview = nil
 --    end
    if self.merge_first_charge_event then
        GlobalEvent:getInstance():UnBind(self.merge_first_charge_event)
        self.merge_first_charge_event = nil
    end
end