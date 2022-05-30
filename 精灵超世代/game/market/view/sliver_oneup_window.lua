-- --------------------------------------------------------------------
-- 银币摆摊一键上架界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-07
-- --------------------------------------------------------------------
SliverOneUpWindow = SliverOneUpWindow or BaseClass(BaseView)

function SliverOneUpWindow:__init()
	self.ctrl = MarketController:getInstance()
	self.model = self.ctrl:getModel()
    self.is_full_screen = true
    self.win_type = WinType.Big   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG             	
    self.layout_name = "market/sliver_oneup_window"  
    self.res_list = {
    }

    self.goods_list = {}
    self.precent = 1
    self.add_precent = 0.05
end

function SliverOneUpWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

	self.goods_con = self.main_container:getChildByName("goods_con")

	self.return_btn = self.main_container:getChildByName("return_btn")
	self.return_btn:setTitleText(TI18N("返回"))
	self.return_btn.label = self.return_btn:getTitleRenderer()
    if self.return_btn.label ~= nil then
        self.return_btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
    end


	self.one_up_btn = self.main_container:getChildByName("one_up_btn")
	self.one_up_btn:setTitleText(TI18N("一键出售"))
	self.one_up_btn.label = self.one_up_btn:getTitleRenderer()
    if self.one_up_btn.label ~= nil then
        self.one_up_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end


	self.price_min_btn = self.main_container:getChildByName("price_min_btn")
	self.price_plus_btn = self.main_container:getChildByName("price_plus_btn")

	self.price_val = self.main_container:getChildByName("price_val")
	self.price_val:setString("100%")

	self.title_con = self.main_container:getChildByName("title_con")
	self.title_label = self.title_con:getChildByName("title_label")
	self.title_label:setString(TI18N("可摆摊物品"))

	self.close_btn = self.main_container:getChildByName("close_btn")
end

function SliverOneUpWindow:openRootWnd(data)
	self.data = data
	self:setData()
end

function SliverOneUpWindow:setData(  )
	local total_page = 3
	local per_page = 20 
	local len = #self.data

	total_page = math.max(math.ceil(len/20),3)
	if #self.data==0 then
		local list = {}
		for i=1,total_page*per_page do
			list[i] = {}
		end
		self.data = list
	else
		if #self.data < total_page*per_page then
			for i=#self.data+1,total_page*per_page do
				table.insert(self.data,{})
			end
		end
	end

	--改一改 换成goodsvo
	self.list = {}
	for k,v in pairs(self.data) do
		if v.base_id then
			local temp = GoodsVo.New(v.base_id)
			temp:initAttrData(v)
			temp.quantity = v.num
			temp:setGoodsAttr("showSellStatus", {status = true, select = false})
			table.insert(self.list,temp)
		else
			table.insert(self.list,{})
		end
	end


	self.page_view = CustomPageView.new(self.goods_con:getContentSize(), false, true, 10, -15,total_page)
	self.goods_con:addChild(self.page_view)
	self.page_view.per_page = per_page
	
	local function createPage(data_list, page, layout)
        local start_pos = self.page_view.per_page*(page-1)+1
        local length = self.page_view.per_page * page
        local count = 1
        for i=start_pos, length do
            	local item = BackPackItem.new(true,true)
            	item:setExtendData({showCheckBox=true})
            	item:setScale(0.8)
				item:setData(data_list[i])
				layout:addChild(item)
				item:setPosition(65+(count-1)%5*(BackPackItem.Width*0.8+13), 365-math.floor((count-1)/5)*(BackPackItem.Height*0.8+6))
				self.goods_list[i] = item
				item.id = data_list[i].id or 0
				item.num = data_list[i].num or 0
                count = count + 1
        end
    end

	self.page_view:addCreatePageCallBack(createPage)
	self.page_view:setViewData(self.list) --(self.data)

end

function SliverOneUpWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openSliverOneUpWindow(false)
			end
		end)
	end

	if self.background then
		self.background:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openSliverOneUpWindow(false)
			end
		end)
	end

	self.price_plus_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local precent = 0.05+self.precent
			if precent<= Config.MarketSilverData.data_market_sliver_cost.silvermarket_salereduce.val/100 then
				self.precent = 0.05+self.precent
				self.price_val:setString((self.precent*100).."%")
			else
				message(TI18N("不能再贵了"))
			end
		end
	end)

	self.price_min_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local precent = self.precent-0.05
			if precent>= Config.MarketSilverData.data_market_sliver_cost.silvermarket_saleplus.val/100 then
				self.precent = self.precent-0.05
				self.price_val:setString((self.precent*100).."%")
			else
				message(TI18N("不能再便宜了"))
			end
		end
	end)

	self.one_up_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local item_list = {}
			for k,v in pairs(self.list) do
				if v.showSellStatus then
					if v.showSellStatus.select then
						table.insert(item_list,v)
					end
				end

			end
			table.sort(item_list, SortTools.KeyLowerSorter("base_id"))
			local free_list = self.model:getFreeList()
			local count = 1
			for k,v in pairs(item_list) do
				if v.num <= 5 then
					if free_list[count] then 
						self.ctrl:sender23504( 1,v.id,v.num,self.precent*100,free_list[count].cell_id )
					end
					count = count+1
				else
					local show_num = 5
					local num = math.ceil(v.num/5)
					for a=1,num do
						if a == (num -1) then
							if free_list[count] then 
								self.ctrl:sender23504( 1,v.id,v.num-(5*a),self.precent*100,free_list[count].cell_id )
							end
						else
							if free_list[count] then 
								self.ctrl:sender23504( 1,v.id,show_num,self.precent*100,free_list[count].cell_id )
							end
						end
						count = count+1
					end
				end
			end
			self.ctrl:openSliverOneUpWindow(false)
			self.ctrl:openSliverGroundingWindow(false)
		end
	end)

	self.return_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self.ctrl:openSliverOneUpWindow(false)
		end
	end)
end

function SliverOneUpWindow:close_callback()
	for k,v in pairs(self.goods_list) do
		v:DeleteMe()
	end
	self.goods_list = nil

	self.ctrl:openSliverOneUpWindow(false)
end