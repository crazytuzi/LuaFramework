--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-24 15:18:54
-- @description    : 
		-- 宅室商店 item
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

HomeworldShopItem = class("HomeworldShopItem", function()
    return ccui.Widget:create()
end)

function HomeworldShopItem:ctor()
	self:configUI()
	self:registerEvent()

	self.is_can_buy = true
end

function HomeworldShopItem:configUI(  )
	self.size = cc.size(194, 274)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("homeworld/homeworld_shop_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.container:setSwallowTouches(false)

    self.name_txt = self.container:getChildByName("name_txt")

    self.limit_image = self.container:getChildByName("limit_image")
    self.limit_image:setLocalZOrder(4)
    self.limit_tips = self.limit_image:getChildByName("limit_tips")
    self.limit_num = self.limit_image:getChildByName("limit_num")

    self.sell_out_panel = self.container:getChildByName("sell_out_panel")
    self.sell_out_panel:setOpacity(150)
    self.sell_out_panel:setLocalZOrder(4)
    local sell_out_sp = self.sell_out_panel:getChildByName("sell_out_sp")
    sell_out_sp:setOpacity(255)

    self.lock_panel = self.container:getChildByName("lock_panel")
    self.lock_panel:setOpacity(150)
    self.lock_panel:setLocalZOrder(4)
    self.lock_label = self.lock_panel:getChildByName("lock_label")
    self.lock_label:setOpacity(255)

    self.num_txt = self.container:getChildByName("num_txt")

	self.btn_buy = self.container:getChildByName("btn_buy")
end

function HomeworldShopItem:registerEvent(  )
	registerButtonEventListener(self.btn_buy, function (  )
		if self.data and self.is_can_buy then
			_controller:openHomeworldBuyWindow(true, self.data, self.shop_type)
		end
	end, true, nil, nil, nil, nil, true)

	-- 随机商店物品购买成功
	if not self.buy_success_random then
		self.buy_success_random = GlobalEvent:getInstance():Bind(MallEvent.Buy_One_Success,function ( data )
			if not data or not self.data then return end
			if self.data["order"] and data.order == self.data.order then
				if not self.data.has_buy then
					self.data.has_buy = data.num or 1
				else
					self.data.has_buy = self.data.has_buy + (data.num or 1)
				end
				self:updateSellStatus()
			end
		end)
	end

	-- 家具、出行商店购买成功
	if not self.buy_success_item then
		self.buy_success_item = GlobalEvent:getInstance():Bind(MallEvent.Buy_Success_Event,function ( data )
			if not data or not self.data then return end
			if self.data.id and data.eid == self.data.id and next(data.ext or {}) ~= nil then
				local has_buy = data.ext[1].val
				if not self.data.has_buy then
					self.data.has_buy = has_buy or 1
				else
					self.data.has_buy = self.data.has_buy + (has_buy or 1)
				end
				self:updateSellStatus()
			end
		end)
	end

    --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if not self.item_config then return end
            if not self.data then return end
            for i,item in pairs(temp_add) do
                if item.base_id == self.item_config.id then
                    self:updateHaveNum()
                end
            end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if not self.item_config then return end
            if not self.data then return end
            for i,item in pairs(temp_del) do
                if item.base_id == self.item_config.id then
                    self:updateHaveNum()
                end
            end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if not self.item_config then return end
            if not self.data then return end
            for i,item in pairs(temp_list) do
                if item.base_id == self.item_config.id then
                    self:updateHaveNum()
                end
            end
        end)
    end

end

-- shop_type:1家具商城 2:出行商城 3:随机商城
function HomeworldShopItem:setData( data, shop_type )
	if not data or not shop_type then return end

	self.data = data
	self.shop_type = shop_type -- 商店类型
	self.shop_item_type = 1 -- 商品类型（1：家具类 2：宠物类）
	self.is_can_buy = true
	if data.type == 42 then
		self.shop_item_type = 2
	end

	local item_bid = data.item_bid or data.item_id
	self.item_config = Config.ItemData.data_get_data(item_bid)
	if not self.item_config then return end

	-- 引导需要
	self.container:setName("guide_shop_item_" .. item_bid)

	-- 名称
	self.name_txt:setString(self.item_config.name)
	--self.name_txt:setTextColor(BackPackConst.getBlackQualityColorC4B(self.item_config.quality))
	self.name_txt:enableOutline(BackPackConst.getBlackQualityColorC4B(self.item_config.quality), 2)

	-- 舒适度或者描述
	if not self.desc_txt then
		self.desc_txt = createRichLabel(20, Config.ColorData.data_new_color4[10], cc.p(0.5, 0.5), cc.p(self.size.width*0.5, 180))
		self.container:addChild(self.desc_txt)
	end
	self.desc_txt:setString(data.item_desc)

	-- 图标
	local item_res
	local unit_cfg = Config.HomeData.data_home_unit(item_bid)
	if unit_cfg then
		item_res = PathTool.getFurnitureNormalRes(unit_cfg.icon)
	else
		item_res = PathTool.getItemRes(self.item_config.icon)
	end
	if not self.item_icon then
		self.item_icon = createSprite(item_res, self.size.width*0.5, 125, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
        self.item_icon:setScale(0.6)
	else
		loadSpriteTexture(self.item_icon, item_res, LOADTEXT_TYPE)
	end

	-- 价格
	if not self.price_txt then
		self.price_txt = createRichLabel(20, cc.c4b(255,246,228,255), cc.p(0.5, 0.5), cc.p(75, 27))
		self.btn_buy:addChild(self.price_txt)
	end
	if type(data.pay_type) == 'number' then
        pay_config = Config.ItemData.data_get_data(data.pay_type)
    else
        pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[data.pay_type])
    end
    if pay_config then
    	local pay_item_res = PathTool.getItemRes(pay_config.icon)
    	local price_str = _string_format(TI18N("<img src='%s' scale=0.35 />  <div fontcolor=#b57311>%d</div>"), pay_item_res, data.price)
    	self.price_txt:setString(price_str)
    end

    -- 舒适度解锁
    local my_soft = _model:getMaxComfortValue()
    if self.data.limit_soft and my_soft < self.data.limit_soft then
    	self.lock_label:setString(_string_format(TI18N("舒适度%d解锁"), self.data.limit_soft))
    	self.lock_panel:setVisible(true)
    	self.is_can_buy = false
    else
    	self.lock_panel:setVisible(false)
    end

    self:updateSellStatus()
    self:updateHaveNum()
end

-- 刷新售罄
function HomeworldShopItem:updateSellStatus(  )
	if not self.data then return end
	-- 限购
    if self.data.limit_count and self.data.limit_count > 0 then  -- 总数限购
    	self.limit_image:setVisible(true)
    	local limit_count = self.data.limit_count
    	local has_buy = self.data.has_buy or 0
    	self.limit_tips:setString(TI18N("限购"))
    	self.limit_num:setString(has_buy .. "/" .. limit_count)
    	if has_buy < limit_count then
    		self.limit_num:setTextColor(cc.c4b(41,64,3,255))
    		self.sell_out_panel:setVisible(false)
    	else
    		self.limit_num:setTextColor(cc.c4b(217,80,20,255))
    		self.sell_out_panel:setVisible(true)
    		self.is_can_buy = false
    	end
    elseif self.data.limit_day and self.data.limit_day > 0 then  -- 每日限购
    	self.limit_image:setVisible(true)
    	local limit_day = self.data.limit_day
    	local has_buy = self.data.has_buy or 0
    	self.limit_tips:setString(TI18N("日限"))
    	self.limit_num:setString(has_buy .. "/" .. limit_day)
    	if has_buy < limit_day then
    		self.limit_num:setTextColor(cc.c4b(41,64,3,255))
    		self.sell_out_panel:setVisible(false)
    	else
    		self.limit_num:setTextColor(cc.c4b(217,80,20,255))
    		self.sell_out_panel:setVisible(true)
    		self.is_can_buy = false
    	end
    elseif self.data.limit_week and self.data.limit_week > 0 then  -- 每周限购
    	self.limit_image:setVisible(true)
    	local limit_week = self.data.limit_week
    	local has_buy = self.data.has_buy or 0
    	self.limit_tips:setString(TI18N("周限"))
    	self.limit_num:setString(has_buy .. "/" .. limit_week)
    	if has_buy < limit_week then
    		self.limit_num:setTextColor(cc.c4b(41,64,3,255))
    		self.sell_out_panel:setVisible(false)
    	else
    		self.limit_num:setTextColor(cc.c4b(217,80,20,255))
    		self.sell_out_panel:setVisible(true)
    		self.is_can_buy = false
    	end
    elseif self.data.limit_month and self.data.limit_month > 0 then  -- 每月限购
    	self.limit_image:setVisible(true)
    	local limit_month = self.data.limit_month
    	local has_buy = self.data.has_buy or 0
    	self.limit_tips:setString(TI18N("月限"))
    	self.limit_num:setString(has_buy .. "/" .. limit_month)
    	if has_buy < limit_month then
    		self.limit_num:setTextColor(cc.c4b(41,64,3,255))
    		self.sell_out_panel:setVisible(false)
    	else
    		self.limit_num:setTextColor(cc.c4b(217,80,20,255))
    		self.sell_out_panel:setVisible(true)
    		self.is_can_buy = false
    	end
    else
    	self.limit_image:setVisible(false)
    	self.sell_out_panel:setVisible(false)
    end
end

-- 刷新已拥有的数量
function HomeworldShopItem:updateHaveNum(  )
    if not self.item_config then return end
	if not self.num_txt then return end
	local have_num = 0
    local bag_code = BackPackConst.Gain_To_Bag_Code[self.item_config.gain_type]
    if bag_code then
        if bag_code == BackPackConst.Bag_Code.HOME then
            have_num = _model:getFurnitureAllNumByBid(self.item_config.id)
        else
            have_num = BackpackController:getInstance():getModel():getPackItemNumByBid(bag_code, self.item_config.id)
        end
    end
	self.num_txt:setString(_string_format(TI18N("已拥有:%d"), have_num))	
end

function HomeworldShopItem:DeleteMe(  )
	if self.buy_success_random then 
        GlobalEvent:getInstance():UnBind(self.buy_success_random)
        self.buy_success_random = nil
    end
    if self.buy_success_item then 
        GlobalEvent:getInstance():UnBind(self.buy_success_item)
        self.buy_success_item = nil
    end

    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end

	self:removeAllChildren()
	self:removeFromParent()
end