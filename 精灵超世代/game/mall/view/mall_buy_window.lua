-- --------------------------------------------------------------------
-- 竖版商城批量购买
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MallBuyWindow = MallBuyWindow or BaseClass(BaseView)

local model = MallController:getInstance():getModel()

function MallBuyWindow:__init()
	self.ctrl = MallController:getInstance()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini    
    self.layout_name = "mall/mall_buy_panel"       	
    self.res_list = {
        
	}
	self.is_can_buy_max = false
end

function MallBuyWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setPosition(360, 640)
    self.background:setAnchorPoint(cc.p(0.5, 0.5))
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

	self.title_con = self.main_container:getChildByName("title_con")
	self.title_label = self.title_con:getChildByName("title_label")
	self.title_label:setString(TI18N("购买"))

	self.ok_btn = self.main_container:getChildByName("ok_btn")
	local ok_btn_size = self.ok_btn:getContentSize()
	self.ok_btn_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(ok_btn_size.width/2, ok_btn_size.height/2))
	self.ok_btn_label:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>购买</div>"), Config.ColorData.data_new_color_str[3]))
	self.ok_btn:addChild(self.ok_btn_label)
	-- self.ok_btn:setTitleText(TI18N("购买"))
	-- self.ok_btn.label = self.ok_btn:getTitleRenderer()
 --    if self.ok_btn.label ~= nil then
 --    	self.ok_btn.label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
 --    end
	self.cancel_btn = self.main_container:getChildByName("cancel_btn")
	local cancel_btn_size = self.cancel_btn:getContentSize()
	self.cancel_btn_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(cancel_btn_size.width/2, cancel_btn_size.height/2))
	self.cancel_btn_label:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>取消</div>"), Config.ColorData.data_new_color_str[2]))
	self.cancel_btn:addChild(self.cancel_btn_label)
	-- self.cancel_btn:setTitleText(TI18N("取消"))
	-- self.cancel_btn.label = self.cancel_btn:getTitleRenderer()
 --    if self.cancel_btn.label ~= nil then
 --    	self.cancel_btn.label:enableOutline(cc.c4b(0x29,0x4a,0x15,0xff), 2)
 --    end
	self.close_btn = self.main_container:getChildByName("close_btn")

	self.item_con = self.main_container:getChildByName("item_con")
	self.name = self.item_con:getChildByName("name")
	self.coin = self.item_con:getChildByName("coin")
	self.price = self.item_con:getChildByName("price")
	self.limit = self.item_con:getChildByName("limit")

	self.icon_bg_image = self.item_con:getChildByName("Image_1")

	self.goods_item = BackPackItem.new()
	--self.goods_item:setData(Config.ItemData.data_get_data(1))
	self.goods_item:setScale(0.8)
	self.goods_item:setPosition(110,self.item_con:getContentSize().height/2-2)
	self.item_con:addChild(self.goods_item)

	self.info_con = self.main_container:getChildByName("info_con")
	self.slider = self.info_con:getChildByName("slider")-- 滑块
    self.slider:setBarPercent(10, 89)
	self.buy_count_title = self.info_con:getChildByName("buy_count_title")
	self.buy_count_title:setString(TI18N("购买数量："))
	self.plus_btn = self.info_con:getChildByName("plus_btn")
	self.buy_count = self.info_con:getChildByName("buy_count")
	self.num = 1
	self.buy_count:setString(self.num)
	self.min_btn = self.info_con:getChildByName("min_btn")
	self.max_btn = self.info_con:getChildByName("max_btn")
	self.total_price_title = self.info_con:getChildByName("total_price_title")
	self.total_price_title:setString(TI18N("总价："))
	self.total_price = self.info_con:getChildByName("total_price")
	self.buy_desc = self.main_container:getChildByName("buy_desc")
	self.buy_desc:setString("")
	self.tips_label = createLabel(22, 15, nil, 385, 277, TI18N('只能买这么多了'), self.main_container, nil, cc.p(0.5, 0.5))
	self.tips_label:setVisible(false)
end

function MallBuyWindow:openRootWnd()

end
--data结构:
--data.item_bid data.item_id   道具id
--data.name = 道具名字  如果没有 用道具id原本名字
--data.limit_num  --购买上限
--data.discount or data.price --购买价格
--data.pay_type 支付类型 道具id
function MallBuyWindow:setData( data )
	-- Debug.info(data)
	self.data = data
	local config = Config.ItemData.data_get_data(data.item_bid or data.item_id)
    self.shop_type = data.shop_type
	if data.shop_type == MallConst.MallType.FestivalAction then
		self.goods_item:setBaseData(data.item_bid, data.quantity)
		self.num = data.limit_num - data.has_buy
		self.buy_desc:setString(TI18N("活跃值购买后仅增加该活动总活跃值"))
	elseif data.shop_type == MallConst.MallType.SuitShop then
		self.goods_item:setBaseData(data.item_bid)
		-- self.num = data.limit_num - data.has_buy
	elseif data.shop_type == MallConst.MallType.SteriousShop then
		self.goods_item:setBaseData(data.item_bid)
		self.total_price_title:setVisible(false)
		self.total_price:setVisible(false)
		-- self.ok_btn.label:setString(TI18N("兑换"))
		self.ok_btn_label:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>兑换</div>"), Config.ColorData.data_new_color_str[3]))
		self.title_label:setString(TI18N("兑换"))
		self.icon_bg_image:setVisible(false)
		self.price:setVisible(false)
		self.coin:setVisible(false)
		self.limit:setPositionX(211)
    elseif data.shop_type == MallConst.MallType.AdventureShotKillBuy then
        if self.goods_item.item_icon then
            local head_icon = PathTool.getResFrame("adventurewindow","adventurewindow_7")
            loadSpriteTexture(self.goods_item.item_icon, head_icon, LOADTEXT_TYPE_PLIST)
            self.goods_item.item_icon:setScale(1.2)
        end
		self.goods_item:setSelfBackground(3)
	elseif data.shop_type == MallConst.MallType.ActionYearMonsterExchange then
		self.goods_item:setBaseData(data.item_bid,data.quantity)
		self.total_price_title:setVisible(false)
		self.total_price:setVisible(false)
		self.ok_btn.label:setString(TI18N("兑换"))
		self.title_label:setString(TI18N("兑换"))
		self.icon_bg_image:setVisible(false)
		self.price:setVisible(false)
		self.coin:setVisible(false)
		self.limit:setPositionX(211)
	else
		self.goods_item:setData(config)
		if self.data and self.data.limit_num then
			self.goods_item:setSelfNum(self.data.item_num)
		end
	end

    if data.name then
       self.name:setString(data.name) 
    else
	   self.name:setString(config.name)
    end
	self.limit_num = self.data.limit_num
	if data["discount"] and data.discount>0 then
		self.price:setString(data.discount)
		self.price_val = data.discount
	else
		self.price:setString(data.price)
		self.price_val = data.price
	end
	if data.shop_type == MallConst.MallType.ActionShop then
		self.is_can_buy_num = self.ctrl:getModel():checkActionMoenyByType(data.pay_type, self.price_val)
    else
    	self.is_can_buy_num = self.ctrl:getModel():checkMoenyByType(data.pay_type, self.price_val)
    end
	local pay_config
	if type(data.pay_type) == "number" then
		pay_config = Config.ItemData.data_get_data(data.pay_type)
	else
		pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[data.pay_type])
	end
	self.coin:loadTexture(PathTool.getItemRes(pay_config.icon), LOADTEXT_TYPE)

	if self.limit_num >0 and data.is_show_limit_label and data.has_buy then
		-- self.limit:setString(TI18N("限购")..self.limit_num-data.has_buy..TI18N("个"))
		self.limit:setString(TI18N("限购").." "..self.limit_num-data.has_buy)
		self.is_can_buy_max = true
	else
		self.limit:setString("")
		if data.shop_type ~= MallConst.MallType.Recovery then
			if self.is_can_buy_num < self.limit_num then
				self.limit_num = self.is_can_buy_num
				self.tips_label:setVisible(false)
				self.is_can_buy_max = false
			end
		end
	end
	--显示限购或玩家可支付购买的个数最小值
	self.num = math.min(self.is_can_buy_num, self.num)
	self:setCurUseItemInfoByNum(self.num)
end

function MallBuyWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openMallBuyWindow(false)
			end
		end)
	end

	if self.background then
		self.background:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openMallBuyWindow(false)
			end
		end)
	end

	if self.slider ~= nil then
    	self.slider:addEventListener(function ( sender,event_type )
			if event_type == ccui.SliderEventType.percentChanged then
				if self.slider:getPercent() == 100 and self.is_can_buy_num >= self.limit_num and self.is_can_buy_max == false then
					self.tips_label:setVisible(true)
				else
					self.tips_label:setVisible(false)
				end
                self:setCurUseItemInfoByPercent(self.slider:getPercent())
    		end
    	end)
    end

    self.min_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
            local percent = self.slider:getPercent()
            if percent == 0 then return end --已经是最小的了
            if self.num == 0 then return end
            self.num = self.num - 1
            self:setCurUseItemInfoByNum(self.num)
        end
    end)
    self.plus_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
            local percent = self.slider:getPercent()
            if percent == 100 then return end --已经是最大的了
            local temp_num = math.min(self.is_can_buy_num, self.limit_num - self.data.has_buy)
            if self.num >= temp_num then return end
            self.num = self.num + 1
            self:setCurUseItemInfoByNum(self.num)
        end
    end)
    self.max_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
            local percent = self.slider:getPercent()
            if percent == 100 then return end --已经是最大的了
            local temp_num = self.limit_num - self.data.has_buy
            if self.num >= temp_num then return end
            self.num = math.min(self.is_can_buy_num, temp_num)
            self:setCurUseItemInfoByNum(self.num)
        end
    end)

	if self.ok_btn then
		self.ok_btn:addTouchEventListener(function ( sender,event_type )
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.data then
                    if self.data.shop_type == MallConst.MallType.Recovery then --神格特殊处理
                        -- 后端要求不必判断数量是否足够，直接发协议请求
                        self.ctrl:sender13407(self.data.order, self.data.shop_type, 1, 1)
					elseif self.data.shop_type == MallConst.MallType.ActionShop then --活动购买
						self.ctrl:send16661(self.data.bid, self.data.aim, self.num)
					elseif self.data.shop_type == MallConst.MallType.FestivalAction then --节日活动购买
						ActionController:getInstance():cs16604(self.data.bid, self.data.aim, self.num)
					elseif self.data.shop_type == MallConst.MallType.SuitShop then --神装商店购买
						MallController:getInstance():sender13402(self.data.id,self.num)
                    elseif self.data.shop_type == MallConst.MallType.GuessShop then --探宝
                        self.ctrl:sender13407(self.data.order, self.data.shop_type, 1, 1)
                    elseif self.data.shop_type == MallConst.MallType.SkillShop then --技能商店
                        self:showSkillAlert(self.data)
                    elseif self.data.shop_type == MallConst.MallType.CrossarenaShop then --跨服竞技场商城
                    	self.ctrl:sender13407(self.data.order, self.data.shop_type, 1, self.num)
                    elseif self.data.shop_type == MallConst.MallType.SteriousShop then --杂货铺
                        ActionController:getInstance():sender16689(self.data.aim,self.num)
                    elseif self.data.shop_type == MallConst.MallType.AdventureShotKillBuy then --神界冒险驱魂药剂购买
						AdventureController:getInstance():send20636(self.num)
					elseif self.data.shop_type == MallConst.MallType.ActionYearMonsterExchange then --年兽集字兑换
						ActionyearmonsterController:getInstance():sender28216(self.data.bid,self.num)
                    else
                        --通用商店 目前是道具商店 和 皮肤商店
                        self.ctrl:sender13402(self.data.id, self.num)
                    end
					self.ctrl:openMallBuyWindow(false)
				else
				end
			end
		end)
	end

	if self.cancel_btn then
		self.cancel_btn:addTouchEventListener(function ( sender,event_type )
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				self.ctrl:openMallBuyWindow(false)
			end
		end)
	end
end

--处理技能商城的购买
function MallBuyWindow:showSkillAlert(data)
	if not data then return end
	--非钻石购买
	if data.pay_type ~= 3 then
		self.ctrl:sender13407(data.order, data.shop_type, 1, 1)
	else
		local cost = data.price
		if data.discount ~= 0 then
			cost = data.discount
		end
		local role_vo = RoleController:getInstance():getRoleVo()
		if not role_vo then return end
		local cur_gold = role_vo.gold
		if cur_gold >= cost then
			local item_cfg = Config.ItemData.data_get_data(data.item_id)
			local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%d</div>购买<div fontColor=#289b14 fontsize= 26>%s</div>？"),PathTool.getItemRes(3), cost, item_cfg.name)
	        CommonAlert.show(tips_str, TI18N("确定"), function()
	            self.ctrl:sender13407(data.order, data.shop_type, 1, 1)
	        end, TI18N("取消"), nil, CommonAlert.type.rich)
		else
			--钻石不足
			local config = Config.ItemData.data_get_data(data.pay_type)
			if config then
				BackpackController:getInstance():openTipsSource(true, config)
			end
		end
	end
end

function MallBuyWindow:setCurUseItemInfoByPercent(percent)
	-- if self.item_vo == nil then return end
	local temp_num = math.min(self.is_can_buy_num, self.limit_num - self.data.has_buy)
    local num = math.floor( percent * temp_num * 0.01 + 0.5)
    self:setCurUseItemInfoByNum(num)
end

function MallBuyWindow:setCurUseItemInfoByNum(num)
    -- if self.item_vo == nil then return end
    self.num = num
    local temp_num = math.min(self.is_can_buy_num, self.limit_num - self.data.has_buy)
    
    if self.num < 1 then
        self.num = 1
    elseif self.num > temp_num then
        self.num = temp_num
    end

    local percent = self.num / temp_num * 100
    if percent < 1 then --进度条数值区间[1,100]
    	percent = math.ceil(percent)
    end
    self.slider:setPercent(percent)
    self.buy_count:setString(self.num)
    self.total_price:setString(self.num*self.price_val)
end

function MallBuyWindow:close_callback()
	-- if self.alert then
	-- 	self.alert:close()
	-- 	self.alert = nil
	-- end
	if self.goods_item then 
		self.goods_item:DeleteMe()
	end
	self.goods_item = nil
	self.ctrl:openMallBuyWindow(false)
end