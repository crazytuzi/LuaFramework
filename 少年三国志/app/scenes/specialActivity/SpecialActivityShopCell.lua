local SpecialActivityShopCell = class("SpecialActivityShopCell",function()
	return CCSItemCellBase:create("ui_layout/specialActivity_ShopCell.json")
	end)

local ActivityDailyCellItem = require("app.scenes.activity.ActivityDailyCellItem")

function SpecialActivityShopCell:ctor(...)
	self._space = 10
	self._callback = nil

	self:registerBtnClickEvent("Button_duihuan",function (  )
		self:clickEvent()
	end)
	
	--消耗列表
	self._consumeList = {}

	self._scrollView = self:getScrollViewByName("ScrollView_duihuan")
	self._leftTimeTagLabel = self:getLabelByName("Label_leftTimeTag")
	self._leftTimeLabel = self:getLabelByName("Label_leftTime")
	--剩余次数
	self._leftTimeLabel:setText("")
	self:showWidgetByName("Panel_duihuancishu",true)

	--不用每次都创建
	if self.denghao == nil then
		self.denghao = ImageView:create()
		self.denghao:loadTexture("ui/activity/duihuan_denghao.png")
		self.denghao:setPositionY(self:_getScrollViewHeight()/2)
	end

	self:attachImageTextForBtn("Button_duihuan","Image_25")
end

function SpecialActivityShopCell:updateView(data)
	self._data = data
	self._info = G_Me.specialActivityData:getCurShop(data.id)
	
	local value02 = self._data.time_self or 0   --限制次数
	local value01 = self._info and self._info.count or 0   --当前进度
	local leftimes = value02 > value01 and (value02-value01) or 0
	local leftTime = string.format("%s/%s",leftimes,value02)
	self._leftTimeLabel:setText(leftTime)
	self:getButtonByName("Button_duihuan"):setTouchEnabled(value02 > value01 or self._data.time_self == 0)
	self:showWidgetByName("Panel_duihuancishu",self._data.time_self > 0)

	self:_initScrollView(data)
end

function SpecialActivityShopCell:_getScrollViewHeight()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().height
end

function SpecialActivityShopCell:_getScrollViewWidth()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().width
end

function SpecialActivityShopCell:_initScrollView(data)
	self.denghao:retain()
	self._scrollView:removeAllChildrenWithCleanup(true)
	self._consumeList = {}
	local awardList = {}
	local widgetWidth = 0
	local curWidth = 0
	local awardDataList = {{type=data.price_type,value=0,size=data.price},
				{type=data.extra_type,value=data.extra_value,size=data.extra_size},
				{type=data.extra_type2,value=data.extra_value2,size=data.extra_size2},}

	local function addItem( good,gray )
		local widget = ActivityDailyCellItem.new(good)
		if gray then
			widget:setGray()
		end
		widgetWidth = widget:getContentSize().width
		local height = widget:getContentSize().height
		widget:setPosition(ccp(self._space+curWidth,(self:_getScrollViewHeight()-height)/2))
		curWidth = curWidth + self._space+widgetWidth
		self._scrollView:addChild(widget,1)
	end

	for k, v in pairs(awardDataList) do
		if v.type > 0 then
			local good = G_Goods.convert(v.type,v.value,v.size)
			if good then
				table.insert(self._consumeList,good)
				addItem(good,true)
			end
		end
	end
	
	--添加一个等号
	--等号的x坐标
	self.denghao:setPositionX(curWidth+self._space/2)
	self._scrollView:addChild(self.denghao,10)
	self.denghao:release()
	local good = G_Goods.convert(data.type,data.value,data.size)
	if good then
		table.insert(awardList,good)
		addItem(good,false)
	end

	curWidth = curWidth + self._space
	
	--总长度
	local innerWidth = curWidth > self:_getScrollViewWidth() and curWidth or self:_getScrollViewWidth()
	self._scrollView:setInnerContainerSize(CCSizeMake(innerWidth,self:_getScrollViewHeight()))
end


function SpecialActivityShopCell:clickEvent()

	local count = -1
	for _,good in ipairs(self._consumeList) do
	    local check = G_Goods.checkGoodCount(good)
	    if check <= 0 then
    		G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_DUIHUAN_CONDITION_NOT_ENOUGH"))
    	    	return 
	    elseif count < 0 then
	    	count = check
	    elseif check < count then
	    	count = check
	    end
	end
	
	local value02 = self._data.time_self or 0   --限制次数
	local value01 = self._info and self._info.count or 0   --当前进度
	local leftimes = value02 > value01 and (value02-value01) or 0

	local buyCount = self._data.time_self > 0 and math.min(leftimes,count) or count

	local RichShopItemSellLayer = require "app.scenes.dafuweng.RichShopItemSellLayer"
	local layer = RichShopItemSellLayer.create(
	    self._data.type, 
	    self._data.value,
	    self._data.size,
	    0, 
	    0, 
	    buyCount, 
	    function(count, layer)
	        G_HandlersManager.specialActivityHandler:sendBuySpecialHolidaySale(self._data.id,count)
	        layer:animationToClose()                            
	    end)
	if self._data.time_self > 0 then 
		layer:showCount(leftimes)
	end
	uf_sceneManager:getCurScene():addChild(layer)
end


return SpecialActivityShopCell