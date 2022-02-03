-- --------------------------------------------------------------------
-- 竖版银币摆摊item
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
SliverSellItem = class("SliverSellItem", function()
	return ccui.Widget:create()
end)

function SliverSellItem:ctor()
	self.ctrl = MarketController:getInstance()
	self:configUI()
	self:registerEvent()
end

function SliverSellItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("market/sliver_item"))
	
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(306,143))
	self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
	self.main_container:setTouchEnabled(true)
	self.main_container:setSwallowTouches(false)

	self.name = self.main_container:getChildByName("name")
	self.coin = self.main_container:getChildByName("coin")
	self.price = self.main_container:getChildByName("price")

	self.price_bg = self.main_container:getChildByName("price_bg")

	self.empty_item = self.main_container:getChildByName("empty_item")
	self.add_icon = self.empty_item:getChildByName("add_icon")
	self.lock_icon = self.empty_item:getChildByName("lock_icon")
	self.empty_item:setVisible(false)

	self.sold_icon = self.main_container:getChildByName("sold_icon")
	self.sold_icon:setLocalZOrder(20)
	self.sold_icon:setVisible(false)
	self.timeout_icon = self.main_container:getChildByName("timeout_icon")
	self.timeout_icon:setLocalZOrder(20)
	self.timeout_icon:setVisible(false)
	self.get_icon = self.main_container:getChildByName("get_icon")
	self.get_icon:setLocalZOrder(20)
	self.get_icon:setVisible(false)

	self.goods_item = BackPackItem.new(true,true)
	--self.goods_item:setScale(0.6)
	self.goods_item:setPosition(78,self.main_container:getContentSize().height/2)
	self.main_container:addChild(self.goods_item)
	self.goods_item:setVisible(false)
end


function SliverSellItem:setData( data )
	--Debug.info(data)
	self.data = data
	if data.is_free then
		if data.is_free == 0 then --空摊位
			self.goods_item:setVisible(false)
			self.empty_item:setVisible(true)
			self.add_icon:setVisible(true)
			self.lock_icon:setVisible(false)
			self.coin:setVisible(false)
			self.name:setString("")
			self.price:setString("")
			self.price_bg:setVisible(false)
			self.timeout_icon:setVisible(false)
			self.get_icon:setVisible(false)
			self.sold_icon:setVisible(false)
		elseif data.is_free == 1 then --有东西的摊位
			self.empty_item:setVisible(false)
			self.goods_item:setVisible(true)
			local config = deepCopy(Config.ItemData.data_get_data(data.item_base_id))
			config.quantity = data.num
			self.name:setString(config.name)
			self.goods_item:setData(config)
			self.goods_item:setDefaultTip()
			self.coin:setVisible(true)
			self.price:setString(data.price)
			self.price_bg:setVisible(true)
			if data.status==1 then --已出售
				self.get_icon:setVisible(false)
				self.timeout_icon:setVisible(false)
				self.sold_icon:setVisible(true)
			elseif data.status == 5 then --提现
				self.sold_icon:setVisible(false)
				self.get_icon:setVisible(true)
				self.timeout_icon:setVisible(false)
			elseif data.status == 6 then --超时
				self.timeout_icon:setVisible(true)
				self.get_icon:setVisible(false)
				self.sold_icon:setVisible(false)
			else
				self.timeout_icon:setVisible(false)
				self.get_icon:setVisible(false)
				self.sold_icon:setVisible(false)
			end
		end
		loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(2).icon), LOADTEXT_TYPE)
	end

	if data.is_lock then
		self.goods_item:setVisible(false)
		self.empty_item:setVisible(true)
		self.add_icon:setVisible(false)
		self.lock_icon:setVisible(true)
		self.coin:setVisible(true)
		--self.price:setString("")
		self.name:setString("")
		self.price:setString(Config.MarketSilverData.data_shop_open[data.cell_id].loss[1][2])
		self.price_bg:setVisible(true)
		local asset_id = Config.MarketSilverData.data_shop_open[data.cell_id].loss[1][1]
		loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(asset_id).icon), LOADTEXT_TYPE)
		self.timeout_icon:setVisible(false)
		self.get_icon:setVisible(false)
		self.sold_icon:setVisible(false)
	end
end

function SliverSellItem:addCallBack( value )
	self.callback =  value
end

function SliverSellItem:getData(  )
	return self.data
end

function SliverSellItem:registerEvent(  )
	self:addTouchEventListener(function(sender, event_type) 
		customClickAction(self, event_type)
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


end

function SliverSellItem:DeleteMe()
	if self.goods_item then 
		self.goods_item:DeleteMe()
	end

	self:removeAllChildren()
	self:removeFromParent()
end
