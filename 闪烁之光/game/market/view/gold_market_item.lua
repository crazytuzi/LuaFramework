-- --------------------------------------------------------------------
-- 竖版金币市场item
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
GoldMarketItem = class("GoldMarketItem", function()
	return ccui.Widget:create()
end)

function GoldMarketItem:ctor()
	self.ctrl = MarketController:getInstance()
	self:configUI()
	self:registerEvent()
end

function GoldMarketItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("market/gold_market_item"))
	
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(622,123))
	self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
	self.main_container:setTouchEnabled(true)
	self.main_container:setSwallowTouches(false)

	self.name = self.main_container:getChildByName("name")
	self.coin = self.main_container:getChildByName("coin")
	self.price = self.main_container:getChildByName("price")
	--self.limit_tips = self.main_container:getChildByName("limit_tips")
	
	self.limit_tips = createRichLabel(20, 175, cc.p(0,0.5), cc.p(310,40))
	self.main_container:addChild(self.limit_tips)
	self.limit_tips:setVisible(false)

	self.buy_btn = self.main_container:getChildByName("buy_btn")
	self.buy_btn.label = self.buy_btn:getTitleRenderer()
	if self.buy_btn.label ~= nil then
		self.buy_btn.label:enableOutline(Config.ColorData.data_color4[178], 2)
	end
	self.buy_btn:setTitleText(TI18N("购买"))

	self.limit_icon = self.main_container:getChildByName("limit_icon")
	self.limit_icon:setLocalZOrder(20)
	self.limit_icon:setVisible(false)

	self.increase = createRichLabel(22, 175, cc.p(0.5,0.5), cc.p(380,80), 0, 0, 150)
	self.main_container:addChild(self.increase)
	self.increase:setString(string.format("<div fontcolor=%s>%s <img src=%s visible=true />",tranformC3bTostr(178),123,PathTool.getResFrame("common","common_90020")))

	self.goods_item = BackPackItem.new(true,true)
	self.goods_item:setData(Config.ItemData.data_get_data(1))
	self.goods_item:setScale(0.8)
	self.goods_item:setPosition(5+self.goods_item:getContentSize().width/2,self:getContentSize().height/2)
	self.main_container:addChild(self.goods_item)

	self.need_icon = self.main_container:getChildByName("need_icon")
	self.need_label = self.main_container:getChildByName("need_label")
	self.need_icon:setVisible(false)
	self.need_label:setVisible(false)
end

function GoldMarketItem:setData( data )
	self.data = data
	if data == nil then return end
	local config = Config.ItemData.data_get_data(data.base_id)
	if config then
		-- 引导需要,
		self.buy_btn:setTag(data.base_id)
		
		self.goods_item:setData(config)
		self.goods_item:setDefaultTip()
		self.name:setString(config.name)
		self.price:setString(data.cur_price)

		local color = 182
		local str = "一 一"
		local img = ""
		local show_str = ""

		if data.margin == "" or data.margin == nil then
			data.margin = 1000
		end
		self.margin = string.format("%0.1f",(data.margin-1000)/10)
		if data.margin < 1000 then
			color = 183
			show_str = string.format("<div fontcolor=%s>%s<img src=%s visible=true />",tranformC3bTostr(color),self.margin.."%",PathTool.getResFrame("market","market_down"))
		elseif data.margin > 1000 then
			color = 178
			show_str = string.format("<div fontcolor=%s>%s<img src=%s visible=true />",tranformC3bTostr(color),self.margin.."%",PathTool.getResFrame("market","market_up"))
		else
			show_str = str
		end
		self.increase:setString(show_str)
		if data.limit_num and data.limit_num>0 then
			local str = ""
			if data.limit_type == 1 then
				str = TI18N("每日限购")
			elseif data.limit_type == 2 then
				str = TI18N("每周限购")
			end
			self.limit_tips:setString(string.format(TI18N("%s<div fontcolor=#249003>%s/%s</div>个"),str,data.has_buy,data.limit_num))
			self.limit_tips:setVisible(true)
			self.limit_icon:setVisible(true)
			self.increase:setPositionY(80)
		else
			self.limit_tips:setVisible(false)
			self.limit_icon:setVisible(false)
			self.increase:setPositionY(60)
		end
	end
	if self.ctrl:checkIsNeedItem(data.base_id) == true then
		self.need_icon:setVisible(true)
		self.need_label:setVisible(true)
	else
		self.need_icon:setVisible(false)
		self.need_label:setVisible(false)
	end
end

function GoldMarketItem:setSoldAll( status )
	
end

function GoldMarketItem:addCallBack( value )
	self.callback =  value
end

function GoldMarketItem:registerEvent(  )
	self:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click =
					math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
					math.abs(self.touch_end.y - self.touch_began.y) <= 20
			end
			if is_click == true then
				playButtonSound2()
				if self.callback then
					self:callback()
				end
			end
		elseif event_type == ccui.TouchEventType.moved then
		elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.canceled then
		end
	end)

	if self.buy_btn then
		self.buy_btn:addTouchEventListener(function ( sender,event_type )
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.data then
					if self.data.limit_num and self.data.limit_num>0 and self.data.has_buy == self.data.limit_num then
						message(TI18N("已经购买完啦"))
					else
						local price_val = self.data.cur_price or self.data.price or 1
						local coin = RoleController:getInstance():getRoleVo().coin
						local can_buy_num = math.floor(coin /price_val)
						if can_buy_num < 1 then
							local config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.coin)
							if config then
								BackpackController:getInstance():openTipsSource(true, config)
							end
						else
							-- 引导中不需要判断
							local is_in_guide = GuideController:getInstance():isInGuide()
							if tonumber(self.margin)>=10 and not is_in_guide then 
								local str = TI18N("目前该物品涨幅超过10%,继续购买将以130%的价格支付,是否继续？")
								CommonAlert.show(str, TI18N("确定"), function (  )
									self.ctrl:openBuyOrSellWindow(true,1,self.data)
								end, TI18N("取消"), nil, CommonAlert.type.rich)
							else
								self.ctrl:openBuyOrSellWindow(true,1,self.data)
							end
						end
					end
				end
			end
		end)
	end
end

function GoldMarketItem:DeleteMe()
	if self.goods_item then 
		self.goods_item:DeleteMe()
	end

	self:removeAllChildren()
	self:removeFromParent()
end
