--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-08 15:01:44
-- @description    : 
		-- VIP-每日礼包
---------------------------------
DailyGiftPanel = class("DailyGiftPanel", function()
    return ccui.Widget:create()
end)

local _controller = VipController:getInstance()
local _model = _controller:getModel()

function DailyGiftPanel:ctor()
	self.gift_charge_id = 0  
    self:config()
    self:layoutUI()
    self:registerEvents()
    self:setData()
end

function DailyGiftPanel:registerEvents(  )
	if self.update_daily_gift == nil then
		self.update_daily_gift = GlobalEvent:getInstance():Bind(VipEvent.DAILY_GIFT_INFO,function ( )
			self:setData()
		end)
	end

	-- 每日礼领取状态更新
	if self.update_daily_award == nil then
		self.update_daily_award = GlobalEvent:getInstance():Bind(WelfareEvent.Update_Daily_Awawd_Data,function ( )
			self:updateDailyAwardRed()
		end)
	end

	if not self.role_vo then
		self.role_vo = RoleController:getInstance():getRoleVo()
		if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "lev" or key == "vip_lev" then
                    self:setData()
                end
            end)
        end
	end

	registerButtonEventListener(self.daily_btn, function (  )
		WelfareController:getInstance():sender21009()
	end, true)

	if self.daygift_charge_data == nil then
        self.daygift_charge_data = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function (data)
            if data and data.status and data.charge_id then
            	local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                if charge_config and data.status == 1 and data.charge_id == self.gift_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name, charge_config.name)
                end
            end
        end)
    end
end

function DailyGiftPanel:config(  )
    self.size = cc.size(668,644)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,0))

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/daily_gift_panel"))
	self.root_wnd:setPosition(-4, 0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
end

function DailyGiftPanel:layoutUI(  )
	self.main_container = self.root_wnd:getChildByName("main_container")

	self.daily_btn = self.main_container:getChildByName("daily_btn")
	self.daily_btn_tips = self.daily_btn:getChildByName("redpoint")

	self.sp_arrow = self.main_container:getChildByName("sp_arrow")
end

function DailyGiftPanel:createItemScrollview( item_count )
	if self.item_scrollview then return end

	local scrollCon = self.main_container:getChildByName("scrollCon")
	local con_size = scrollCon:getContentSize()
	local scroll_size = cc.size(con_size.width, con_size.height+20)
	local scroll_pos = cc.p(0,0)

	local setting = {
        item_class = DailyGiftItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 15,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 668,               -- 单元的尺寸width
        item_height = 213,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(scrollCon, scroll_pos, ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_size, setting)
end

function DailyGiftPanel:setData(  )
	local gift_data = {}
	if self.role_vo == nil then
		self.role_vo = RoleController:getInstance():getRoleVo()
	end
	for k,config in pairs(Config.ChargeData.data_daily_gift_data) do
		-- 判断是否达到显示要求
		if config.show_lv and config.show_lv <= self.role_vo.lev and config.show_vip_lv and config.show_vip_lv <= self.role_vo.vip_lev then
			table.insert(gift_data, deepCopy(config))
		end
	end
	local sort_func = SortTools.KeyLowerSorter("sort_id")
    table.sort(gift_data, sort_func)

    if not self.item_scrollview then
    	self:createItemScrollview(#gift_data)
    end
	self.item_scrollview:setData(gift_data,function(cell)
		self.gift_charge_id = cell:getData().charge_id
	end)

	if #gift_data > 3 then
		self.sp_arrow:setVisible(true)
		self.item_scrollview:setBounceEnabled(true)
		if not self._init_flag then
			self._init_flag = true
			local scroll_max_size = self.item_scrollview:getMaxSize()
			self.item_scrollview:scrollToPercentVertical(40/scroll_max_size.height*100, 0)
		end
	else
		self.sp_arrow:setVisible(false)
		self.item_scrollview:setBounceEnabled(false)
	end

	self:updateDailyAwardRed()
end

function DailyGiftPanel:setVisibleStatus( status )
	self:setVisible(status)
	WelfareController:getInstance():getModel():updateDailyGiftRedStatus(false)
end

-- 每日礼包按钮红点更新
function DailyGiftPanel:updateDailyAwardRed(  )
    local red_status = false
    -- 每日礼
    local award_status = WelfareController:getInstance():getModel():getDailyAwardStatus()
    if award_status == 0 then
        red_status = true
    end
    self.daily_btn_tips:setVisible(red_status)
end

function DailyGiftPanel:DeleteMe(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.update_daily_gift then
        GlobalEvent:getInstance():UnBind(self.update_daily_gift)
        self.update_daily_gift = nil
    end
    if self.update_daily_award then
    	GlobalEvent:getInstance():UnBind(self.update_daily_award)
    	self.update_daily_award = nil
    end
    if self.daygift_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.daygift_charge_data)
        self.daygift_charge_data = nil
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
	end
end

----------------------@ 每日礼包子项
DailyGiftItem = class("DailyGiftItem", function()
    return ccui.Widget:create()
end)

function DailyGiftItem:ctor()
	self.touch_buy_gift = true
	self:configUI()
	self:register_event()
end

function DailyGiftItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/daily_gift_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(668, 213))
    self:setAnchorPoint(0,0)

    self.container = self.root_wnd:getChildByName("container")
    self.image_bg = self.container:getChildByName("image_bg")
    self.title_txt = self.container:getChildByName("title_txt")
	self.buy_btn = self.container:getChildByName("buy_btn")
	self.buy_btn.label = self.buy_btn:getTitleRenderer()
    if self.buy_btn.label ~= nil then
    	self.buy_btn:setTitleColor(cc.c4b(0xff,0xff,0xff,0xff))
    	self.buy_btn.label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
    end 
    self.left_num = self.container:getChildByName("left_num")
    self.zhe_panel = self.container:getChildByName("zhe_panel")
    self.zhe_panel:setVisible(false)
    self.zhe_panel:getChildByName("price_title"):setString(TI18N("原价"))
    self.price_txt = self.zhe_panel:getChildByName("price_txt")

    local good_list = self.container:getChildByName("good_list")
    local scroll_size = good_list:getContentSize()
	local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = 0.7
    }
    self.good_scrollview = CommonScrollViewLayout.new(good_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_size, setting)
	self.good_scrollview:setSwallowTouches(fasle)
end

function DailyGiftItem:register_event(  )
	registerButtonEventListener(self.buy_btn, handler(self, self._onClickBuyBtn))
end

-- 点击购买
function DailyGiftItem:_onClickBuyBtn(  )
	if self.gift_config then
		local role_vo = RoleController:getInstance():getRoleVo()
		local limit_vip = self.gift_config.limit_vip
		if role_vo.vip_lev >= limit_vip then
			local charge_id = self.gift_config.charge_id
			local charge_config = Config.ChargeData.data_charge_data[charge_id or 0]
			if charge_config and self.touch_buy_gift == true then
				self.touch_buy_gift = nil
				if self.callback then
                    self:callback()
                end
	            ActionController:getInstance():sender21016(charge_config.id)
				if self.send_buy_gift_ticket == nil then
	                self.send_buy_gift_ticket = GlobalTimeTicket:getInstance():add(function()
	                    self.touch_buy_gift = true
	                    if self.send_buy_gift_ticket ~= nil then
	                        GlobalTimeTicket:getInstance():remove(self.send_buy_gift_ticket)
	                        self.send_buy_gift_ticket = nil
	                    end
	                end,2)
	            end

			end
		else
			message(string.format(TI18N("VIP%d可购买"), limit_vip))
		end
	end
end

function DailyGiftItem:getData()
    return self.gift_config
end
function DailyGiftItem:addCallBack(value)
    self.callback =  value
end

function DailyGiftItem:setData( data )
	if not data then return end
	self.gift_config = data

	local gift_bid = data.id -- 礼包id
	local buy_count = _model:getDailyGiftBuyCountById(gift_bid) -- 已购次数

	-- 背景
	local gift_res = PathTool.getPlistImgForDownLoad("bigbg", self.gift_config.bg_res)
	self.gift_bg_load = loadImageTextureFromCDN(self.image_bg, gift_res, ResourcesType.single, self.gift_bg_load)

	-- 名称
	self.title_txt:setString(self.gift_config.name)
	if self.gift_config.bg_res == "txt_cn_bigbg_25" then
		self.title_txt:enableOutline(cc.c3b(5,108,107), 2)
	elseif self.gift_config.bg_res == "txt_cn_bigbg_26" then
		self.title_txt:enableOutline(cc.c3b(109,5,148), 2)
	elseif self.gift_config.bg_res == "txt_cn_bigbg_27" then
		self.title_txt:enableOutline(cc.c3b(148,59,5), 2)
	end--

	-- 是否已经达到购买次数上限
	if self.gift_config.limit_count <= buy_count then
		setChildUnEnabled(true, self.buy_btn)
		self.buy_btn:setTouchEnabled(false)
		self.buy_btn:setTitleText(TI18N("今日已购"))
	else
		setChildUnEnabled(false, self.buy_btn)
		self.buy_btn:setTouchEnabled(true)
		self.buy_btn:setTitleText(string.format(TI18N("%d元"), self.gift_config.val or 0))
	end

	-- 剩余数量
	self.left_num:setString(string.format(TI18N("限购:%d次"), (self.gift_config.limit_count-buy_count)))

	-- 描述内容
	if not self.gift_desc_txt then
		self.gift_desc_txt = createRichLabel(24, 1, cc.p(0.5, 1), cc.p(314, 192), 10, nil, 280)
		self.container:addChild(self.gift_desc_txt)
	end
	local res_str = string.format("<img src='%s' scale=0.3 />", PathTool.getItemRes(3))
	self.gift_desc_txt:setString(string.format(self.gift_config.desc, res_str, res_str))

	-- 原价显示
	if self.gift_config.old_price and self.gift_config.old_price > 0 then
		self.zhe_panel:setVisible(true)
		self.price_txt:setString(self.gift_config.old_price .. TI18N("元"))
	else
		self.zhe_panel:setVisible(false)
	end

	-- 奖励物品
	local role_vo = RoleController:getInstance():getRoleVo()
	local gift_award_cfg = Config.ChargeData.data_daily_gift_award[gift_bid]
	if gift_award_cfg then
		local award_data = {}
		for k,v in pairs(gift_award_cfg) do
			if v.min <= role_vo.lev and v.max >= role_vo.lev then
				award_data = deepCopy(v.reward)
				break
			end
		end
		local item_list = {}
		for k,v in pairs(award_data) do
	        local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
	        if vo then
	        	vo.quantity = v[2]
	        	table.insert(item_list,vo)
	        end
	    end
		self.good_scrollview:setData(item_list)
		local is_show_double = false
		if self.gift_config and self.gift_config.is_double and self.gift_config.is_double == 1 then
			is_show_double = true
		end
		self.good_scrollview:addEndCallBack(function (  )
	        local list = self.good_scrollview:getItemList()
	        for k,v in pairs(list) do
	        	-- 判断是否显示双倍显示
	        	if is_show_double then
	        		local item_cfg = v:getData()
		        	if item_cfg and item_cfg.id == 3 then
		        		v:setDoubleIcon(true)
		        	else
		        		v:setDoubleIcon(false)
		        	end
	        	end
	            v:setDefaultTip()
	        end
	    end)
	end
end

function DailyGiftItem:DeleteMe(  )
	if self.gift_bg_load then
		self.gift_bg_load:DeleteMe()
		self.gift_bg_load = nil
	end

	if self.good_scrollview then
		self.good_scrollview:DeleteMe()
		self.good_scrollview = nil
	end
	self.touch_buy_gift = true
	if self.send_buy_gift_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.send_buy_gift_ticket)
        self.send_buy_gift_ticket = nil
    end
    
	self:removeAllChildren()
	self:removeFromParent()
end