-- --------------------------------------------------------------------
-- 银币摆摊更改出售信息界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-07
-- --------------------------------------------------------------------
SliverSellWindow = SliverSellWindow or BaseClass(BaseView)

function SliverSellWindow:__init()
	self.ctrl = MarketController:getInstance()
	self.model = self.ctrl:getModel()
    self.is_full_screen = true
    self.win_type = WinType.Big     
 	self.view_tag = ViewMgrTag.DIALOGUE_TAG           	
    self.layout_name = "market/sliver_sell_window"  
    self.res_list = {
    }

end

function SliverSellWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

	self.title_con = self.main_container:getChildByName("title_con")
	self.title_label = self.title_con:getChildByName("title_label")
	self.title_label:setString(TI18N("出售商品"))

	self.close_btn = self.main_container:getChildByName("close_btn")

	self.info_con = self.main_container:getChildByName("info_con")
	self.name = self.info_con:getChildByName("name")

	self.down_btn = self.info_con:getChildByName("down_btn")
	self.down_btn:setTitleText(TI18N("免费下架"))
	self.down_btn.label = self.down_btn:getTitleRenderer()
    if self.down_btn.label ~= nil then
        self.down_btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
    end

	self.up_btn = self.info_con:getChildByName("up_btn")
	self.up_btn:setTitleText(TI18N("重新上架"))
	self.up_btn.label = self.up_btn:getTitleRenderer()
    if self.up_btn.label ~= nil then
        self.up_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end

	self.price_min_btn = self.info_con:getChildByName("price_min_btn")
	self.price_plus_btn = self.info_con:getChildByName("price_plus_btn")
	self.num_min_btn = self.info_con:getChildByName("num_min_btn")
	self.num_plus_btn = self.info_con:getChildByName("num_plus_btn")

	self.price_val = self.info_con:getChildByName("price_val")
	self.num_val = self.info_con:getChildByName("num_val")
	self.total_val = self.info_con:getChildByName("total_val")

	self.tips = self.info_con:getChildByName("tips")

	self.goods_item = BackPackItem.new(true,true)
	--self.goods_item:setScale(0.6)
	self.goods_item:setPosition(150,470)
	self.main_container:addChild(self.goods_item)
end

function SliverSellWindow:openRootWnd(data)
	self.data = data
	-- Debug.info(data)
	self:setData()
end

function SliverSellWindow:setData(  )
	local config = Config.ItemData.data_get_data(self.data.item_base_id)
	self.goods_item:setData(config)
	self.name:setString(config.name)
	self.price = self.data.price
	self.precent = 1
	self.add_precent = 0.05
	self.num = self.data.num
	local model = BackpackController:getInstance():getModel()
	local num = model:getBackPackItemNumByBid(self.data.item_base_id)
	self.own_num = num
	self.price_val:setString(self.data.price)
	self.default_price = self.data.price
	self.num_val:setString(self.data.num)
	self.total_val:setString(self.data.price*self.data.num)
end

function SliverSellWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openSliveSellWindow(false)
			end
		end)
	end

	if self.background then
		self.background:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openSliveSellWindow(false)
			end
		end)
	end

	self.price_plus_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local max_price = Config.MarketSilverData.data_antique_list[self.data.item_base_id].max_price
			
			local precent = self.add_precent+self.precent
			local price = self.default_price*precent --self.price+self.price*0.05
			
			local color = 183
			local str = ""
			if price<= max_price and precent<= Config.MarketSilverData.data_market_sliver_cost.silvermarket_salereduce.val/100 then
				self.precent = self.add_precent+self.precent
				self.price = math.floor(price)
				self.price_val:setString(self.price)
				self.total_val:setString(self.price*self.num)
			else
				message(TI18N("不能再贵了"))
			end

			local show_precent = self.price/self.default_price*100 - 100
				if show_precent > 0 then
					color = 183 
					str = TI18N("推荐单价+"..show_precent.."%")
				elseif show_precent < 0 then
					color = 173
					str = TI18N("推荐单价"..show_precent.."%")
				else 
					str = ""
				end
			
			self.tips:setString(str)
			self.tips:setTextColor(Config.ColorData.data_color4[color])
		end
	end)

	self.price_min_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local min_price = Config.MarketSilverData.data_antique_list[self.data.item_base_id].min_price
			
			
			local color = 183
			local str = ""
			local config = Config.MarketSilverData.data_market_sliver_cost

			local precent = self.precent-self.add_precent
			local price = self.default_price*precent --self.price-self.price*0.05

			if price>= min_price and precent>= Config.MarketSilverData.data_market_sliver_cost.silvermarket_saleplus.val/100 then
				self.precent = self.precent-self.add_precent
				self.price = math.floor(price)
				self.price_val:setString(self.price)
				self.total_val:setString(self.price*self.num)
			else
				message(TI18N("不能再便宜了"))
			end

			local show_precent = self.price/self.default_price*100 - 100
			if show_precent > 0 then
					color = 183 
					str = TI18N("推荐单价+"..show_precent.."%")
			elseif show_precent < 0  then
					color = 173
					str = TI18N("推荐单价"..show_precent.."%")
			else 
					str = ""
			end

			self.tips:setString(str)
			self.tips:setTextColor(Config.ColorData.data_color4[color])
		end
	end)

	self.num_min_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local num = self.num-1
			if num >=1 then
				self.num = num
				self.num_val:setString(self.num)
				self.total_val:setString(self.price*self.num)		
			else
				message(TI18N("不能再少了"))
			end
		end
	end)

	self.num_plus_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local num = self.num+1
			if num <= self.own_num then
				self.num = num
				self.num_val:setString(self.num)	
				self.total_val:setString(self.price*self.num)	
			else
				message(TI18N("不能再多了"))
			end
		end
	end)

	self.down_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self.ctrl:sender23506(self.data.cell_id)
			self.ctrl:openSliveSellWindow(false)
		end
	end)

	self.up_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self.ctrl:sender23513(self.data.cell_id,self.precent*100,self.num)
			self.ctrl:openSliveSellWindow(false)
		end
	end)
end

function SliverSellWindow:close_callback()
	self.ctrl:openSliveSellWindow(false)
end