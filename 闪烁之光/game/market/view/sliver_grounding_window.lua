-- --------------------------------------------------------------------
-- 银币摆摊界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-07
-- --------------------------------------------------------------------
SliverGroundingWindow = SliverGroundingWindow or BaseClass(BaseView)

function SliverGroundingWindow:__init()
	self.ctrl = MarketController:getInstance()
	self.model = self.ctrl:getModel()
    self.is_full_screen = true
    self.win_type = WinType.Big     
    self.view_tag = ViewMgrTag.DIALOGUE_TAG           	
    self.layout_name = "market/sliver_grounding_window"  
    self.res_list = {
    }

    self.goods_list = {}
    self.select_item = nil
    self.precent = 1
    self.add_precent = 0.05
end

function SliverGroundingWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

	self.title_con = self.main_container:getChildByName("title_con")
	self.title_label = self.title_con:getChildByName("title_label")
	self.title_label:setString(TI18N("可摆摊物品"))

	self.empty_tips = self.main_container:getChildByName("empty_tips")
	local empty_label = self.empty_tips:getChildByName("empty_label")
	empty_label:setString(TI18N("请点击上方的物品\n\n选择多个物品可批量上架"))

	self.info_con = self.main_container:getChildByName("info_con")
	self.price_min_btn = self.info_con:getChildByName("price_min_btn")
	self.price_plus_btn = self.info_con:getChildByName("price_plus_btn")
	self.num_min_btn = self.info_con:getChildByName("num_min_btn")
	self.num_plus_btn = self.info_con:getChildByName("num_plus_btn")

	self.price_val = self.info_con:getChildByName("price_val")
	self.num_val = self.info_con:getChildByName("num_val")
	self.total_val = self.info_con:getChildByName("total_val")
	self.tips = self.info_con:getChildByName("tips")

	self.goods_item = BackPackItem.new(true,true)
	self.goods_item:setPosition(78,116)
	self.info_con:addChild(self.goods_item)

	self.info_con:setVisible(false)

	self.goods_con = self.main_container:getChildByName("goods_con")

	self.ok_btn = self.main_container:getChildByName("ok_btn")
	self.ok_btn:setTitleText(TI18N("确定上架"))
	self.ok_btn.label = self.ok_btn:getTitleRenderer()
    if self.ok_btn.label ~= nil then
        self.ok_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end

	self.one_up_btn = self.main_container:getChildByName("one_up_btn")
	self.one_up_btn:setTitleText(TI18N("一键上架"))
	self.one_up_btn.label = self.one_up_btn:getTitleRenderer()
    if self.one_up_btn.label ~= nil then
        self.one_up_btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
    end

	self.close_btn = self.main_container:getChildByName("close_btn")
end

function SliverGroundingWindow:openRootWnd(data,cell_id)
	--Debug.info(data)
	self.data = data
	self.cell_id = cell_id
	self:setData()
end

function SliverGroundingWindow:setData(  )
	local total_page = 3
	local per_page = 15 
	local len = #self.data

	total_page = math.max(math.ceil(len/15),3)
	print("====len===",len)
	if #self.data==0 then
		local list = {}
		for i=1,total_page*per_page do
			list[i] = {}
		end
		self.data = list
		--Debug.info(self.data)
	else
		if #self.data < total_page*per_page then
			for i=#self.data+1,total_page*per_page do
				table.insert(self.data,{})
			end
		end
	end

	self.page_view = CustomPageView.new(self.goods_con:getContentSize(), false, true, 10, 20,total_page)
	self.goods_con:addChild(self.page_view)
	self.page_view.per_page = per_page
	
	local function createPage(data_list, page, layout)
        local start_pos = self.page_view.per_page*(page-1)+1
        local length = self.page_view.per_page * page
        local count = 1
        local scale = 0.8
        for i=start_pos, length do                
            	local item = BackPackItem.new(true,true)
            	item.id = data_list[i].id or 0
				item.num = data_list[i].num or 0
            	local config = deepCopy(Config.ItemData.data_get_data(data_list[i].base_id))
            	if config then 
            		config.quantity = item.num
            	end
				item:setData(config or data_list[i])
				layout:addChild(item)
				item:setScale(scale)
				item:setPosition(63+(count-1)%5*(BackPackItem.Width*scale+13), 295-math.floor((count-1)/5)*(BackPackItem.Height*scale+10))

				self.goods_list[i] = item
				item:addCallBack(function ( cell )
					self:itemCallBack(cell)
				end)
                count = count + 1
        end
    end

	self.page_view:addCreatePageCallBack(createPage)
	self.page_view:setViewData(self.data)
	self.page_view:adjustLightPos(10,20,10)
end

function SliverGroundingWindow:itemCallBack( cell )
	local data = cell:getData()
	if data and data.id ~= nil then
		if self.select_item ~= nil then
			self.select_item:setSelected(false)
		end
		self.select_item = cell
		cell:setSelected(true)

		self.empty_tips:setVisible(false)
		self.ctrl:sender23508(data.id)
		--self.info_con:setVisible(true)
	end

end

function SliverGroundingWindow:setInfoCon( data )
	if self.select_item == nil then return end
	local vo = self.select_item:getData()
	if data.item_base_id == vo.id then
		self.info_con:setVisible(true)
		self.price_val:setString(data.price)
		self.num = 1
		self.num_val:setString(self.num)
		self.price = data.price
		self.default_price = data.price
		self.total_val:setString(data.price*self.num)
		local config = Config.ItemData.data_get_data(data.item_base_id)
		self.goods_item:setData(config)
		self.goods_item:setDefaultTip()
	end
end

function SliverGroundingWindow:register_event()
	if self.sliver_price == nil then
		self.sliver_price = GlobalEvent:getInstance():Bind(MarketEvent.Sliver_Price,function ( data )
			self:setInfoCon(data)
		end)
	end


	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openSliverGroundingWindow(false)
			end
		end)
	end

	if self.background then
		self.background:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openSliverGroundingWindow(false)
			end
		end)
	end

	self.price_plus_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local max_price = Config.MarketSilverData.data_antique_list[self.select_item:getData().id].max_price
			
			local precent = self.add_precent+self.precent
			local price = self.default_price*precent
			--self.precent = 0.05+self.precent
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
			local min_price = Config.MarketSilverData.data_antique_list[self.select_item:getData().id].min_price
			--local price = self.default_price-self.default_price*self.add_precent --self.price-self.price*0.05
			local precent =  self.precent-self.add_precent
			local price = self.default_price*precent
			--self.precent = self.precent-0.05

			local color = 183
			local str = ""
			local config = Config.MarketSilverData.data_market_sliver_cost

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
			if num <= self.select_item.num then
				if num > 5 then 
					message(TI18N("同个摊位最多只能上架5个物品哟！"))
				else
					self.num = num
					self.num_val:setString(self.num)	
					self.total_val:setString(self.price*self.num)	
				end
			else
				message(TI18N("不能再多了"))
			end
		end
	end)

	self.ok_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.select_item ~=nil then
				local model = BackpackController:getInstance():getModel()
				local id = model:getBackPackItemIDByBid(self.select_item:getData().id)
				-- if self.precent == 0 then
				-- 	self.ctrl:sender23504(1,self.select_item.id,self.num,100,self.cell_id)
				-- else
					self.ctrl:sender23504(1,self.select_item.id,self.num,self.precent*100,self.cell_id)
					self.ctrl:openSliverGroundingWindow(false)
				--end
			end
		end
	end)

	self.one_up_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self.ctrl:openSliverOneUpWindow(true,self.data)
		end
	end)


end

function SliverGroundingWindow:close_callback()
	if self.sliver_price then 
        GlobalEvent:getInstance():UnBind(self.sliver_price)
        self.sliver_price = nil
    end

    if self.goods_item then 
		self.goods_item:DeleteMe()
	end

    for k,v in pairs(self.goods_list) do
		v:DeleteMe()
	end
	self.goods_list = nil

	self.ctrl:openSliverGroundingWindow(false)
end