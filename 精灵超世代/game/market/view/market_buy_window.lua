-- --------------------------------------------------------------------
-- 竖版市场购买、出售界面
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MarketBuyWindow = MarketBuyWindow or BaseClass(BaseView)

function MarketBuyWindow:__init()
	self.ctrl = MarketController:getInstance()
	self.model = self.ctrl:getModel()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini    
    self.layout_name = "mall/mall_buy_panel"  
	self.role_vo = RoleController:getInstance():getRoleVo()
    self.limit_num = 20 
	self.has_buy = 0    	
	self.can_buy_num = 0
	self.is_can_buy_max = true
end

function MarketBuyWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

	self.title_con = self.main_container:getChildByName("title_con")
	self.title_label = self.title_con:getChildByName("title_label")
	
	self.ok_btn = self.main_container:getChildByName("ok_btn")
	
	self.cancel_btn = self.main_container:getChildByName("cancel_btn")
	self.cancel_btn:setTitleText(TI18N("取消"))
	self.cancel_btn.label = self.cancel_btn:getTitleRenderer()
    if self.cancel_btn.label ~= nil then
        self.cancel_btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
    end
	self.close_btn = self.main_container:getChildByName("close_btn")

	self.item_con = self.main_container:getChildByName("item_con")
	self.name = self.item_con:getChildByName("name")
	self.coin = self.item_con:getChildByName("coin")
	self.price = self.item_con:getChildByName("price")
	self.limit = self.item_con:getChildByName("limit")

	self.goods_item = BackPackItem.new(true,true)
	--self.goods_item:setData(Config.ItemData.data_get_data(1))
	--self.goods_item:setScale(0.8)
	self.goods_item:setPosition(110,self.item_con:getContentSize().height/2-2)
	self.item_con:addChild(self.goods_item)

	self.info_con = self.main_container:getChildByName("info_con")
	self.slider = self.info_con:getChildByName("slider")-- 滑块
    self.slider:setBarPercent(10, 89)
	self.buy_count_title = self.info_con:getChildByName("buy_count_title")
	
	self.plus_btn = self.info_con:getChildByName("plus_btn")
	self.buy_count = self.info_con:getChildByName("buy_count")
	self.num = 1
	self.price_val = 1
	self.buy_count:setString(self.num)
	self.min_btn = self.info_con:getChildByName("min_btn")
	self.max_btn = self.info_con:getChildByName("max_btn")
	local total_price_title = self.info_con:getChildByName("total_price_title")
	total_price_title:setString(TI18N("总价："))
	self.total_price = self.info_con:getChildByName("total_price")
	self.tips_label = createLabel(22,15,nil,385,277,TI18N("只能买这么多了"),self.main_container,nil,cc.p(0.5,0.5))
	self.tips_label:setVisible(false)
end

function MarketBuyWindow:openRootWnd(type,data)
	self.type = type
	self.data = data
	self.win = self.ctrl:getMarketMainWin()
	if self.win and self.win:getCurIndex()== MarketTabConst.gold_market then --金币市场查询下价格
		self.ctrl:sender23520()
		self.ctrl:sender23500(self.win:getCurSonIndex())
	elseif self.win and self.win:getCurIndex() == MarketTabConst.gold_sell then --金币出售也要查询下市价
		if Config.MarketGoldData.data_change_sell_list[data.base_id] then --转换商品
			local list = {}
			table.insert(list,{base_id=Config.MarketGoldData.data_change_sell_list[data.base_id].exchange_id})
			self.ctrl:sender23516(list)
		else
			local list = {}
			table.insert(list,{base_id=data.base_id})
			self.ctrl:sender23516(list)
		end
	else
		self:setData(data)
	end
	
	if self.type == 1 or self.type == 2 then --金币购买/银币购买
		self.title_label:setString(TI18N("购买"))
		self.ok_btn:setTitleText(TI18N("购买"))
		self.ok_btn.label = self.ok_btn:getTitleRenderer()
	    if self.ok_btn.label ~= nil then
	        self.ok_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
	    end
	    self.buy_count_title:setString(TI18N("购买数量："))
	elseif self.type == 3 then --金币出售
		self.title_label:setString(TI18N("出售"))
		self.ok_btn:setTitleText(TI18N("出售"))
		self.ok_btn.label = self.ok_btn:getTitleRenderer()
	    if self.ok_btn.label ~= nil then
	        self.ok_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
	    end
		self.buy_count_title:setString(TI18N("出售数量："))
	end
end

function MarketBuyWindow:setData( data )
	-- Debug.info(data)
	self.data = data
	local config = Config.ItemData.data_get_data(data.base_id or data.item_base_id)
	self.goods_item:setData(config)
	self.goods_item:setDefaultTip()
	self.name:setString(config.name)
	
	if (data.limit_num and data.limit_num>0) or data.num then
		self.limit_num = data.limit_num or data.num 
	else
		self.limit_num = 20
	end
	self.has_buy = data.has_buy or 0
	self.price_val = data.cur_price or data.price or 1
	self.price:setString(data.cur_price or data.price)

	if self.type==1 and (data.limit_num and data.limit_num>0) and data.limit_type then --金币市场
		self.limit:setString(TI18N("限购")..data.limit_num..TI18N("个"))
		self.is_can_buy_max = true --额外情况不显示
	elseif self.type ==2 and data.num and data.status then --银币市场
		self.limit:setString(TI18N("数量：")..data.num)
		self.is_can_buy_max = true --额外情况不显示
	elseif self.type==3 and data.num then --金币出售
		self.limit:setString(TI18N("拥有：")..data.num)
		self.price_val =  math.floor(self.model:getPrice(data.base_id)) or 1
		self.price:setString(self.price_val)
		self.limit_num = data.num
	end
	if self.type == 1 then
		self.can_buy_num = math.max(1,math.floor(self.role_vo.coin / self.price_val))
		if self.can_buy_num < self.limit_num then
			self.limit_num = self.can_buy_num
			self.tips_label:setVisible(false)
			self.is_can_buy_max = false
		end
	elseif self.type == 2 then
		self.can_buy_num = math.max(1, math.floor(self.role_vo.silver_coin / self.price_val))
		if self.can_buy_num < self.limit_num then
			self.limit_num = self.can_buy_num
			self.tips_label:setVisible(false)
			self.is_can_buy_max = false
		end
	end
	local pay_config
	if self.type == 2 then --银币
		pay_config = Config.ItemData.data_get_data(2)
	else
		pay_config = Config.ItemData.data_get_data(1)
	end
	self.coin:loadTexture(PathTool.getItemRes(pay_config.icon), LOADTEXT_TYPE)

	--print("=======limit_num==",self.limit_num,self.has_buy)
	self:setCurUseItemInfoByNum(self.num)
end

function MarketBuyWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openBuyOrSellWindow(false)
			end
		end)
	end

	if self.background then
		self.background:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openBuyOrSellWindow(false)
			end
		end)
	end

	if self.slider ~= nil then
    	self.slider:addEventListener(function ( sender,event_type )
			if event_type == ccui.SliderEventType.percentChanged then
				if self.type == 1 or self.type == 2 then
					if self.slider:getPercent() == 100 and self.can_buy_num >= self.limit_num and self.is_can_buy_max == false then
						self.tips_label:setVisible(true)
					else
						self.tips_label:setVisible(false)
					end
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
			if percent == 100 then 
				return 
			end --已经是最大的了
            if self.num >= (self.limit_num-self.has_buy) then return end
            self.num = self.num + 1
            self:setCurUseItemInfoByNum(self.num)
        end
    end)
    self.max_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
            local percent = self.slider:getPercent()
			if percent == 100 then 
				return 
			end --已经是最大的了
            if self.num >= (self.limit_num-self.has_buy) then return end
            self.num = (self.limit_num-self.has_buy)
            self:setCurUseItemInfoByNum(self.num)
        end
    end)

	if self.ok_btn then
		self.ok_btn:addTouchEventListener(function ( sender,event_type )
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.type == 1 then --金币市场购买
					self.ctrl:sender23501(self.data.base_id,self.num)
				elseif self.type == 2 then --银币市场购买
					self.ctrl:sender23505(self.data.type,self.data.id,self.num)
				elseif self.type == 3 then --金币出售
					self.ctrl:sender23502(self.data.id,self.num)
				end
				
				self.ctrl:openBuyOrSellWindow(false)
			end
		end)
	end

	if self.cancel_btn then
		self.cancel_btn:addTouchEventListener(function ( sender,event_type )
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				self.ctrl:openBuyOrSellWindow(false)
			end
		end)
	end


	--获取金币市场指定分类的数据
    if self.update_gold_market == nil then
        self.update_gold_market = GlobalEvent:getInstance():Bind(MarketEvent.Update_Gold_Category,function ( data )
        	if self.win and self.win:getCurIndex()== MarketTabConst.gold_market and self.win:getCurSonIndex()==data.catalg then
            --if self.cur_index == MarketTabConst.gold_market and self.cur_son_index == data.catalg then
                local list = self.model:getShowGoldShowList(data.catalg)
                --找出物品
                for k,v in pairs(list) do
                	if self.data.base_id == v.base_id then
                		self:setData(v)
                		return
                	end
                end
            end
        end)
    end

    --金币出售 获取物品市价
    if self.update_price == nil then
    	self.update_price = GlobalEvent:getInstance():Bind(MarketEvent.Gold_Sell_Price,function (  )
    		self:setData(self.data)
    	end)
    end
end

function MarketBuyWindow:setCurUseItemInfoByPercent(percent)
    self.num = math.floor( percent * (self.limit_num-self.has_buy) * 0.01 )
    self.buy_count:setString(self.num)
    self.total_price:setString(self.num*self.price_val)
end

function MarketBuyWindow:setCurUseItemInfoByNum(num)
    self.num = num
	local percent = self.num / (self.limit_num-self.has_buy) * 100
    self.slider:setPercent(percent)
    self.buy_count:setString(self.num)
	self.total_price:setString(self.num*self.price_val)
	if self.type == 1 or self.type == 2 then --金币情况下
		if percent == 100 and self.is_can_buy_max == false and self.can_buy_num >= self.limit_num  then
			self.tips_label:setVisible(true)
		else
			self.tips_label:setVisible(false)
		end
	end
end

function MarketBuyWindow:close_callback()
	if self.goods_item then 
		self.goods_item:DeleteMe()
	end

	if self.update_gold_market then 
        GlobalEvent:getInstance():UnBind(self.update_gold_market)
        self.update_gold_market = nil
    end

    if self.update_price then 
        GlobalEvent:getInstance():UnBind(self.update_price)
        self.update_price = nil
    end
	
	self.ctrl:openBuyOrSellWindow(false)
end