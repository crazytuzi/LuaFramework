--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-22 09:48:33
-- @description    : 
		-- 杂货店
---------------------------------
VarietyStoreWindows = VarietyStoreWindows or BaseClass(BaseView)

local _controller = MallController:getInstance()
local _model = _controller:getModel()

function VarietyStoreWindows:__init()
	self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "mall/varietystore_window"   

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("varietystore", "varietystore"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_72", true), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_73"), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_74"), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_75"), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_76"), type = ResourcesType.single },
	}
end

function VarietyStoreWindows:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
    	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_72",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 1) 

    -- self.refresh_label = main_container:getChildByName("refresh_label")
    -- self.time_label = main_container:getChildByName("time_label")
    -- self.time_label:setString(TI18N("倒计时：00:00:00"))

    self.refresh_label = createRichLabel(22, Config.ColorData.data_color3[179], cc.p(0, 0), cc.p(18, 240))
    self:addChild(self.refresh_label)
    self.time_label = createRichLabel(22, Config.ColorData.data_color3[179], cc.p(0, 0), cc.p(270, 240))
    self:addChild(self.time_label)

    self.refresh_btn = main_container:getChildByName("refresh_btn")
    local refresh_btn_size = self.refresh_btn:getContentSize()
    self.refresh_btn_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(refresh_btn_size.width/2, refresh_btn_size.height/2))
    self.refresh_btn:addChild(self.refresh_btn_label)
    self.close_btn = main_container:getChildByName("close_btn")

    local item_list = main_container:getChildByName("item_list")
    local bg_size = item_list:getContentSize()
	local scroll_view_size = cc.size(bg_size.width, bg_size.height+50)
    local setting = {
        item_class = VarietyStoreItem,      -- 单元类
        start_x = 10,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 50,                    -- 第一个单元的Y起点
        space_y = 20,                   -- y方向的间隔
        item_width = 188,               -- 单元的尺寸width
        item_height = 230,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 3,                         -- 列数，作用于垂直滚动类型
    }

    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0,-40) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
	self.item_scrollview:setBounceEnabled(false)
	
	self:adaptationScreen()
end

--设置适配屏幕
function VarietyStoreWindows:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local bottom_y = display.getBottom(self.main_container)

    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(close_btn_y+bottom_y)
    
end

function VarietyStoreWindows:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.refresh_btn, handler(self, self._onClickRefreshBtn), true, 2)

	-- 商店数据
	self:addGlobalEvent(MallEvent.Get_Buy_list, function ( data )
		if data.type == MallConst.MallType.VarietyShop and data then
			self:setData(data)
		end
	end)
	-- 刷新数据
	self:addGlobalEvent(MallEvent.Free_Refresh_Data, function ( data )
		if data.type == MallConst.MallType.VarietyShop and data and self.data then
			for key,val in pairs(data) do
				self.data[key] = val
			end
			self:updateRefreshInfo()
		end
	end)
end

function VarietyStoreWindows:setData( data )
	self.data = data or {}

	self:updateRefreshInfo()

	-- 添加位置标识，引导需要
	for i,v in ipairs(data.item_list or {}) do
		v.index = i
	end
	self.item_scrollview:setData(data.item_list or {})
end

function VarietyStoreWindows:updateRefreshInfo(  )
	if self.data then
		-- 总刷新次数
		local max_num_cfg = Config.ExchangeData.data_shop_exchage_cost["maximum_number"]
		self.refresh_label:setString(string.format(TI18N("刷新次数：<div fontcolor=%s>%d/%d</div>"), Config.ColorData.data_new_color_str[12], self.data.count, max_num_cfg.val))
		
		-- 按钮上刷新文字
		local btn_str = ""
		if self.data.free_count > 0 then
			local free_num_cfg = Config.ExchangeData.data_shop_exchage_cost["max_free_times"]
			btn_str = string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>刷新(%d/%d)</div>"), Config.ColorData.data_new_color_str[3], self.data.free_count, free_num_cfg.val)
			if self.data.free_count == free_num_cfg.val then
				addRedPointToNodeByStatus(self.refresh_btn, true, 5, 5)
			else
				addRedPointToNodeByStatus(self.refresh_btn, false, 5, 5)
			end
		else
			addRedPointToNodeByStatus(self.refresh_btn, false)
			local refresh_cost_cfg = Config.ExchangeData.data_shop_list[MallConst.MallType.VarietyShop]
			if refresh_cost_cfg and refresh_cost_cfg.cost_list then
				local bid = refresh_cost_cfg.cost_list[1][1]
				local num = refresh_cost_cfg.cost_list[1][2]
				local item_config = Config.ItemData.data_get_data(bid)
                if item_config then 
                    local res = PathTool.getItemRes(item_config.icon)
                    btn_str = string.format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#ffffff shadow=0,-2,2,%s>%d 刷新</div>"),res,Config.ColorData.data_new_color_str[3],num)
                end
			end
		end
		self.refresh_btn_label:setString(btn_str)

		if self.data.refresh_time > 0 then
			local left_time = self.data.refresh_time - GameNet:getInstance():getTime()
			if left_time < 0 then
				left_time = 0
				self:openRefreshTimer(false)
			else
				self:openRefreshTimer(true)
			end
			-- self.time_label:setString(TI18N("倒计时："..TimeTool.GetTimeFormat(left_time)))
			self.time_label:setString(string.format(TI18N("倒计时：<div fontcolor=%s>%s</div>"), Config.ColorData.data_new_color_str[12], TimeTool.GetTimeFormat(left_time)))
		else
			self:openRefreshTimer(false)
			self.time_label:setString(string.format(TI18N("倒计时：<div fontcolor=%s>00:00:00</div>"), Config.ColorData.data_new_color_str[12]))
		end
	end
end

function VarietyStoreWindows:openRefreshTimer( status )
	if status == true then
		if self.refresh_timer == nil then
			self.refresh_timer = GlobalTimeTicket:getInstance():add(function (  )
				if self.data and self.data.refresh_time > 0 then
					local left_time = self.data.refresh_time - GameNet:getInstance():getTime()
					if left_time < 0 then
						GlobalTimeTicket:getInstance():remove(self.refresh_timer)
	            		self.refresh_timer = nil
					end
					-- self.time_label:setString(TI18N("倒计时："..TimeTool.GetTimeFormat(left_time)))
					self.time_label:setString(string.format(TI18N("倒计时：<div fontcolor=%s>%s</div>"), Config.ColorData.data_new_color_str[12], TimeTool.GetTimeFormat(left_time)))
				else
					self.time_label:setString(string.format(TI18N("倒计时：<div fontcolor=%s>00:00:00</div>"), Config.ColorData.data_new_color_str[12]))
					GlobalTimeTicket:getInstance():remove(self.refresh_timer)
            		self.refresh_timer = nil
				end
			end, 1)
		end
	else
		if self.refresh_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.refresh_timer)
            self.refresh_timer = nil
        end
	end
end

function VarietyStoreWindows:_onClickCloseBtn(  )
	_controller:openVarietyStoreWindows(false)
end

function VarietyStoreWindows:_onClickRefreshBtn(  )
	if self.data then
		_controller:sender13405(MallConst.MallType.VarietyShop)
	end
end

function VarietyStoreWindows:openRootWnd(  )
	_controller:sender13403(MallConst.MallType.VarietyShop)
end

function VarietyStoreWindows:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	self:openRefreshTimer(false)
	_controller:openVarietyStoreWindows(false)
end


-----------------------------@ 杂货店商品 item
VarietyStoreItem = class("VarietyStoreItem", function()
    return ccui.Widget:create()
end)

function VarietyStoreItem:ctor()
	self:configUI()
	self:register_event()
end

function VarietyStoreItem:configUI(  )
	self.size = cc.size(158, 214)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("mall/varietystore_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    local btn_buy = container:getChildByName("btn_buy")
    btn_buy:setTouchEnabled(false)

    self.pos_node = container:getChildByName("pos_node")
    self.image_zhe = container:getChildByName("image_zhe")
    self.image_zhe:setVisible(false)
    -- self.zhe_label = self.image_zhe:getChildByName("zhe_label")
    self.image_buy = container:getChildByName("image_buy")
    self.image_buy:setVisible(false)
end

function VarietyStoreItem:register_event(  )
	registerButtonEventListener(self.container, handler(self, self._onClickItem), true)

	if not self.buy_success_event then
		self.buy_success_event = GlobalEvent:getInstance():Bind(MallEvent.Buy_One_Success,function ( data )
			if self.data and self.data.order and data.order == self.data.order then
				self.data.has_buy = self.data.has_buy + 1
				if self.data.limit_count and self.data.has_buy >= self.data.limit_count then
					self:showSellOutStatus(true)
				end
			end
		end)
	end
end

function VarietyStoreItem:_onClickItem(  )
	if self.data and self.data.order then
		-- 引导中则直接购买，无需弹出确认窗口
		if GuideController:getInstance():isInGuide() then
			_controller:sender13407(self.data.order, MallConst.MallType.VarietyShop, 1)
		else
	        self:showAlert(self.data)
		end
	end
end

function VarietyStoreItem:showAlert(data)
	if not data then return end
	--购买实际价格
	local cost = data.price
	if data.discount ~= 0 then
		cost = data.discount
	end
	local role_vo = RoleController:getInstance():getRoleVo()
	if not role_vo then return end
	local cur_num = BackpackController:getInstance():getModel():getItemNumByBid(data.pay_type)
	if cur_num >= cost then
		local item_cfg = Config.ItemData.data_get_data(data.item_id)
		local bag_type = BackPackConst.Bag_Code.BACKPACK
		if item_cfg.sub_type == 1 then --背包中装备类型
			bag_type = BackPackConst.Bag_Code.EQUIPS
		end
		local num = BackpackController:getInstance():getModel():getItemNumByBid(data.item_id, bag_type)
		local tips_str = string.format(TI18N("是否购买<div fontColor=#289b14 fontsize= 26>%s</div>(拥有:<div fontColor=#289b14 fontsize= 26>%d</div>)？"), item_cfg.name, num)
        CommonAlert.show(tips_str, TI18N("确定"), function()
            _controller:sender13407(data.order, MallConst.MallType.VarietyShop, 1)
        end, TI18N("取消"), nil, CommonAlert.type.rich)
	else
		local pay_config = nil
        if type(data.pay_type) == 'number' then
            pay_config = Config.ItemData.data_get_data(data.pay_type)
        else
            pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[data.pay_type])
        end
        if pay_config then
			if pay_config.id == Config.ItemData.data_assets_label2id.gold then
	            if FILTER_CHARGE then
	                message(TI18N("钻石不足"))
	            else
	                local function fun()
						VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
						--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
	                end
	                local str = string.format(TI18N('%s不足，是否前往充值？'), pay_config.name)
	                CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
	            end
	        else
	        	BackpackController:getInstance():openTipsSource(true, pay_config)
	        end
	    end
	end
end

function VarietyStoreItem:setData( data )
	if not data then return end
	self.data = data

	--引导需要
	if data.index then
		self.container:setName("buy_btn_" .. data.index)
	end

	-- 价格
	if not self.price_label then
		local btn_buy = self.container:getChildByName("btn_buy")
		local btn_buy_size = btn_buy:getContentSize()
		self.price_label = createRichLabel(22, Config.ColorData.data_new_color4[16], cc.p(0.5, 0.5), cc.p(btn_buy_size.width/2, btn_buy_size.height/2))
		btn_buy:addChild(self.price_label)
		-- self.container:addChild(self.price_label)
	end
	local res_bid = data.pay_type
	--[[if data.pay_type == 1 then --金币
		res_bid = Config.ItemData.data_assets_label2id.coin
	elseif data.pay_type == 2 then --钻石
		res_bid = Config.ItemData.data_assets_label2id.gold
	end--]]
	local item_config = Config.ItemData.data_get_data(res_bid)
    if item_config then 
        local res = PathTool.getItemRes(item_config.icon)
        local price = data.price
        if data.discount > 0 then -- 有折扣价格则读取折扣价格
        	price = data.discount
        end
        local price_str = string.format("<img src='%s' scale=0.3 /> %s", res, MoneyTool.GetMoneyString(price))
        self.price_label:setString(price_str)
    end

    -- 物品
    if not self.item_icon then
    	self.item_icon = BackPackItem.new(false, true, false, 1, nil, true)
        self.item_icon:setDefaultTip(true, false)
        self.item_icon:setAnchorPoint(cc.p(0.5, 0))
        --self.item_icon:setPosition(cc.p(0, 0))
        self.pos_node:addChild(self.item_icon)
    end
    self.item_icon:setBaseData(data.item_id, data.item_num)

    -- 折扣
    if data.discount > 0 and data.discount_type < 10 then
    	self.image_zhe:setVisible(true)
    	-- self.zhe_label:setString(string.format(TI18N("%d折"), data.discount_type))
		local zhe_res = PathTool.getResFrame("common", MallConst.Variety_Zhe_Res[data.discount_type])
		self.image_zhe:loadTexture(zhe_res, LOADTEXT_TYPE_PLIST)
		self.image_zhe:ignoreContentAdaptWithSize(true)
    else
    	self.image_zhe:setVisible(false)
    end

    data.limit_count = 1
    if data.has_buy and data.limit_count and data.has_buy >= data.limit_count then
    	self:showSellOutStatus(true)
    else
    	self:showSellOutStatus(false)
    end
end

function VarietyStoreItem:showSellOutStatus( status )
	if self.item_icon then
		self.item_icon:setItemIconUnEnabled(status)
	end
	if self.image_buy then
		self.image_buy:setVisible(status)
	end
	if self.container then
		self.container:setTouchEnabled(not status)
	end
end

function VarietyStoreItem:DeleteMe(  )
	if self.item_icon then
		self.item_icon:DeleteMe()
		self.item_icon = nil
	end
	if self.buy_success_event then
		GlobalEvent:getInstance():UnBind(self.buy_success_event)
        self.buy_success_event = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end