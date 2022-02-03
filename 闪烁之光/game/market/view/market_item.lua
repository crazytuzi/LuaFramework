-- --------------------------------------------------------------------
-- 竖版市场item
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MarketItem = class("MarketItem", function()
	return ccui.Widget:create()
end)

local controller = MarketController:getInstance()

function MarketItem:ctor()
	self.ctrl = MarketController:getInstance()
	self:configUI()
	self:registerEvent()
end

function MarketItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("market/market_item"))
	
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

	self.sold_icon = self.main_container:getChildByName("sold_icon")
	self.sold_icon:setLocalZOrder(20)
	self.sold_icon:setVisible(false)
	self.timeout_icon = self.main_container:getChildByName("timeout_icon")
	self.timeout_icon:setLocalZOrder(20)
	self.timeout_icon:setVisible(false)

	self.need_icon = self.main_container:getChildByName("need_icon")
	self.need_label = self.main_container:getChildByName("need_label")
	self.need_icon:setVisible(false)
	self.need_label:setVisible(false)
end

function MarketItem:setData( data )
	self.data = data
	if self.goods_item == nil then
		self.goods_item = BackPackItem.new(true,true)
		self.goods_item:setPosition(75,self.main_container:getContentSize().height/2)
		self.main_container:addChild(self.goods_item)
	end
	self.price:setString(data.price)
	local config = deepCopy(Config.ItemData.data_get_data(data.item_base_id or data.base_id))
	config.quantity = data.num
	self.goods_item:setData(config)
	self.goods_item:setDefaultTip()
	self.name:setString(config.name)
	self:changeIcon(data.status)

	if data.item_base_id then --银币市场
		loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(2).icon), LOADTEXT_TYPE)
	else --金币出售
		loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(1).icon), LOADTEXT_TYPE)
	end
	-- 检查需求
	self:checkNeedStatus()
end

function MarketItem:checkNeedStatus(bid)
	if self.data == nil then return end
	if controller:checkIsNeedItem(self.data.item_base_id) then
		self.need_icon:setVisible(true)
		self.need_label:setVisible(true)
	else
		self.need_icon:setVisible(false)
		self.need_label:setVisible(false)
	end
end

function MarketItem:addCallBack( value )
	self.callback =  value
end

function MarketItem:getData(  )
	return self.data
end

--银币市场 下架售罄等状态改变
function MarketItem:changeIcon( status )
	if status == 3 then --下架
		self.timeout_icon:setVisible(true)
		self.sold_icon:setVisible(false)
		self:setTouchEnabled(true)
	elseif status == 2 then --被买了
		self.sold_icon:setVisible(true)
		self.timeout_icon:setVisible(false)
		self:setTouchEnabled(false)
	elseif self.data.num == 0 then
		self.sold_icon:setVisible(true)
		self.timeout_icon:setVisible(false)
		self:setTouchEnabled(false)
	else
		self.timeout_icon:setVisible(false)
		self.sold_icon:setVisible(false)
		self:setTouchEnabled(true)
	end
end

function MarketItem:registerEvent(  )
	self.main_container:addTouchEventListener(function(sender, event_type) 
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
			sender:setScale(1)
		elseif event_type == ccui.TouchEventType.moved then
		elseif event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
			sender:setScale(0.95)
		elseif event_type == ccui.TouchEventType.canceled then
			sender:setScale(1)
		end
	end)

	--银币市场购买返回
	-- if self.sliver_buy_event == nil then
	-- 	self.sliver_buy_event = GlobalEvent:getInstance():Bind(MarketEvent.Sliver_Market_Buy_Success,function ( data )
	-- 		if data.id == self.data.id and data.type == self.data.type then
	-- 			self.data.num = data.num 
	-- 			self.data.status = data.status
	-- 			self.goods_item:setNum(self.data.num)
	-- 			self:checkNeedStatus()
	-- 			self:changeIcon(data.status)
	-- 		end
	-- 	end)
	-- end
end

function MarketItem:updateSelfInfo(num, status)
	if self.data == nil then return end
	self.data.num = num 
	self.data.status = status

	self.goods_item:setNum(num)
	self:checkNeedStatus()
	self:changeIcon(status)
end

function MarketItem:DeleteMe()
    if self.goods_item then 
		self.goods_item:DeleteMe()
	end

	self:removeAllChildren()
	self:removeFromParent()
end