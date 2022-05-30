--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-06 15:27:32
-- @description    : 
		-- 购买家具
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

HomeworldBuyUnitWindow = HomeworldBuyUnitWindow or BaseClass(BaseView)

function HomeworldBuyUnitWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_buy_unit_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
	}
	
	self.buy_num = 1  -- 购买数量
end

function HomeworldBuyUnitWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 2) 

	main_container:getChildByName("win_title"):setString(TI18N("购买提示"))
	main_container:getChildByName("num_title"):setString(TI18N("购买数量:"))
	main_container:getChildByName("price_title"):setString(TI18N("总        价:"))

	self.sp_icon = main_container:getChildByName("sp_icon")

	self.res_bg_1 = main_container:getChildByName("res_bg_1")
	self.res_sp_1 = self.res_bg_1:getChildByName("sp_res")
	self.res_label_1 = self.res_bg_1:getChildByName("label")

	self.res_bg_2 = main_container:getChildByName("res_bg_2")
	self.res_sp_2 = self.res_bg_2:getChildByName("sp_res")
	self.res_label_2 = self.res_bg_2:getChildByName("label")

	self.price_bg = main_container:getChildByName("price_bg")
	self.price_sp = self.price_bg:getChildByName("sp_res")
	self.price_sp:setScale(0.35)
	self.price_label = self.price_bg:getChildByName("label")

	self.set_right = main_container:getChildByName("set_right")
	self.set_left = main_container:getChildByName("set_left")
	self.set_max = main_container:getChildByName("set_max")
	self.slider = main_container:getChildByName("slider")
	self.slider:setBarPercent(0, 100)

	self.close_btn = main_container:getChildByName("close_btn")
	self.check_btn = main_container:getChildByName("check_btn")
	self.check_btn:setVisible(false)
	self.buy_btn = main_container:getChildByName("buy_btn")
	self.buy_btn_label = self.buy_btn:getChildByName("label"):setString(TI18N("确认购买"))

	-- 引导需要
	self.buy_btn:setName("guide_buy_btn")

	self.num_txt = main_container:getChildByName("num_txt")
end

function HomeworldBuyUnitWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openHomeworldBuyWindow(false)
	end, true, 2)

	registerButtonEventListener(self.check_btn, function (  )
		self:_onClickCheckBtn()
	end, true, 1)

	registerButtonEventListener(self.buy_btn, function (  )
		self:_onClickBuyBtn()
	end, true, 1)

	self.set_left:addTouchEventListener(function(sender, event_type) --减少
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data then
                local target_value = self.buy_num - 1
                if target_value < 1 then
                    target_value = 1
                end
                self:updateBuyNumAndPrice(target_value)
                self:setSliderPercent()
            end
        end
    end)
    self.set_right:addTouchEventListener(function(sender, event_type) --增加
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data then
                local target_value = self.buy_num + 1
                if target_value > self.max_num then
                    target_value = self.max_num
                end
                self:updateBuyNumAndPrice(target_value)
                self:setSliderPercent()
            end
        end
    end)
    self.set_max:addTouchEventListener(function(sender, event_type) --最大
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data then
                self:updateBuyNumAndPrice(self.max_num)
                self:setSliderPercent()
            end
        end
    end)
    if self.slider ~= nil then
        self.slider:addEventListener(function ( sender,event_type )
            if event_type == ccui.SliderEventType.percentChanged then
            	local percent = self.slider:getPercent()
                self:setCurBuyNumByPercent()
            end
        end)
    end
end

function HomeworldBuyUnitWindow:setSliderPercent(  )
	if self.buy_num then
        local percent = (self.buy_num/self.max_num)*100
        self.slider:setPercent(percent)
    end
end

function HomeworldBuyUnitWindow:setCurBuyNumByPercent(  )
	if not self.slider then return end
    local percent = self.slider:getPercent()
    local cur_val = math.floor(self.max_num*percent/100)
    if cur_val < 1 then
    	self:setSliderPercent()
    	self:updateBuyNumAndPrice(1)
    else
    	self:updateBuyNumAndPrice(cur_val)
    end
end

-- open_type:1家具商城 2:出行商城 3:随机商城
function HomeworldBuyUnitWindow:openRootWnd( data, open_type )
	self.data = data
	self.open_type = open_type or 1
	self.price = data.price or 0 -- 单价
	self.max_num = MallController:getInstance():getModel():checkMoenyByType(self.data.pay_type, data.price) -- 最大购买数量
	if self.max_num < 1 then
		self.max_num = 1
	elseif self.max_num > 10 then
		self.max_num = 10
	end
    --限购...只能有一种
    self:setLimitCount(self.data.limit_count)
    self:setLimitCount(self.data.limit_day)
    self:setLimitCount(self.data.limit_week)
    self:setLimitCount(self.data.limit_month)
	self:setData()
end

function HomeworldBuyUnitWindow:setLimitCount(limit_count)
    if not self.data then return end
    if limit_count and limit_count > 0 then
        local can_buy_num = limit_count - self.data.has_buy
        if self.max_num > can_buy_num then
            self.max_num = can_buy_num
        end
    end
end

function HomeworldBuyUnitWindow:setData(  )
	if not self.data then return end

	self.shop_item_type = 1 -- 商品类型（1：家具类 2：宠物类）
	if self.data.type == 42 or self.data.type == 3 then
		self.shop_item_type = 2
	end

	local item_bid = self.data.item_bid or self.data.item_id
	local item_config = Config.ItemData.data_get_data(item_bid)
	if not item_config then return end

	self.item_config = item_config

	local unit_cfg = Config.HomeData.data_home_unit(item_bid)
	
	if not self.name_label then
		self.name_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(207, 420), nil, nil, 450)
		self.main_container:addChild(self.name_label)
	end
	local name_str = _string_format("<div fontcolor=%s>%s</div>", BackPackConst.getWhiteQualityColorStr(item_config.quality), item_config.name)
	if unit_cfg then
		local suit_cfg = Config.HomeData.data_suit[unit_cfg.set_id]
		if suit_cfg then
			name_str = name_str .. _string_format(TI18N(" <div fontcolor=#3d5078>【所属主题:%s】</div>"), suit_cfg.name)
		end
	end
	self.name_label:setString(name_str)

	-- 图标
	local item_res
	if unit_cfg then
		item_res = PathTool.getFurnitureNormalRes(unit_cfg.icon)
	else
		item_res = PathTool.getItemRes(item_config.icon)
	end
	loadSpriteTexture(self.sp_icon, item_res, LOADTEXT_TYPE)

	-- 描述
	local desc_str = item_config.desc
	if unit_cfg then
		desc_str = unit_cfg.desc
	end
	if not self.desc_txt then
		self.desc_txt = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(207, 376), 5, nil, 380)
		self.main_container:addChild(self.desc_txt)
	end
	self.desc_txt:setString(desc_str)

	-- 消耗资源类型
	if type(self.data.pay_type) == 'number' then
        pay_config = Config.ItemData.data_get_data(self.data.pay_type)
    else
        pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[self.data.pay_type])
    end
    if pay_config then
    	local pay_item_res = PathTool.getItemRes(pay_config.icon)
    	loadSpriteTexture(self.price_sp, pay_item_res, LOADTEXT_TYPE)
    end

    if self.shop_item_type ~= 2 and unit_cfg then
    	self.res_label_1:setString(_string_format(TI18N("舒适度+%d"), unit_cfg.soft))
    	self.res_label_2:setString(_string_format(TI18N("占地:%s"), unit_cfg.grid_desc))
    end

    -- self.check_btn:setVisible(self.shop_item_type ~= 2)
    self.res_bg_1:setVisible(self.shop_item_type ~= 2)
    self.res_bg_2:setVisible(self.shop_item_type ~= 2)

	self:updateBuyNumAndPrice(1)
	self:setSliderPercent()
end

-- 更新购买数量和价格
function HomeworldBuyUnitWindow:updateBuyNumAndPrice( num )
	self.buy_num = num

	self.num_txt:setString(num)
	self.price_label:setString(MoneyTool.GetMoneyString(self.price * num))
end

function HomeworldBuyUnitWindow:_onClickCheckBtn(  )
	if self.item_config then
		_controller:openFurnitureInfoWindow(true, self.item_config.id)
	end
end

function HomeworldBuyUnitWindow:_onClickBuyBtn(  )
	if self.data then
		if self.open_type == 1 or self.open_type == 2 then
			MallController:getInstance():sender13402(self.data.id, self.buy_num)
		else -- 随机商城
			MallController:getInstance():sender13407(self.data.order, MallConst.MallType.HomeRandomShop, 1, self.buy_num)
		end
		_controller:openHomeworldBuyWindow(false)
	end
end

function HomeworldBuyUnitWindow:close_callback(  )
	_controller:openHomeworldBuyWindow(false)
end