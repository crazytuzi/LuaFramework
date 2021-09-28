local ActivityHolidayCell = class("ActivityHolidayCell",function()
	return CCSItemCellBase:create("ui_layout/activity_ActivityHolidayCell.json")
	end)

local ActivityDailyCellItem = require("app.scenes.activity.ActivityDailyCellItem")
local EffectNode = require "app.common.effects.EffectNode"


function ActivityHolidayCell:ctor(holiday_id)
	self._holiday_id = holiday_id
	self._space = 10
	self._callback = nil
	self:_initEvent()
	
	self._scrollView = self:getScrollViewByName("ScrollView_duihuan")
	self._leftTimeLabel = self:getLabelByName("Label_lefttime")
	self._leftTimeLabel:setText("")

	self._levelLabel = self:getLabelByName("Label_level")
	self._levelLabel:setText("")
	self._levelLabel:createStroke(Colors.strokeBrown,1)

	--不用每次都创建
	if self.denghao == nil then
		self.denghao = ImageView:create()
		self.denghao:loadTexture("ui/activity/duihuan_denghao.png")
		self.denghao:setPositionY(self:_getScrollViewHeight()/2)
		self.denghao:retain()
	end

	self:attachImageTextForBtn("Button_duihuan","Image_25")
	if not self._effect then
		self._effect = EffectNode.new("effect_sd_lindang", function(event, frameIndex)
		            end)  
		local image = self:getImageViewByName("Image_level")
		if image then
			self._effect:setPosition(ccp(-image:getContentSize().width/2+ 21,-10))
			self:getImageViewByName("Image_level"):addNode(self._effect)
			-- self:showWidgetByName("Image_lingdang",false)
			self._effect:play()
		end
	end
end

function ActivityHolidayCell:updateItem(event)
	self._event = event
	if not self._event then
		self._leftTimeLabel:setText("")
		return
	end
	if event.level == 0 then
		self._levelLabel:setVisible(false)
		self:showWidgetByName("Image_level",false)
	else
		self._levelLabel:setVisible(true)
		self:showWidgetByName("Image_level",true)
		self._levelLabel:setText(G_lang:get("LANG_ACTIVITY_HOLIDAY_LEVEL_LIMIT",{level=event.level}))
	end
	local exchangeTimes = G_Me.activityData.holiday:getExchangeTimesById(event.id)
	if exchangeTimes == -1 then
		self._leftTimeLabel:setText("")
		self:getButtonByName("Button_duihuan"):setTouchEnabled(false)
	else
		--[[
			    self._buycountLabel:setText(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
			else
			    self._buycountLabel:setText(G_lang:get("LANG_PURCHASE_AVAILABLE_NUM",{num=(maxNum-itemNum)})
		]]
		if exchangeTimes >= event.num then
			self._leftTimeLabel:setText(G_lang:get("LANG_ACTIVITY_HOLIDAY_DUI_HUAN_CI_SHU_MAX"))
			--兑换次数不够
			self:getButtonByName("Button_duihuan"):setTouchEnabled(false)
		else
			self._leftTimeLabel:setText(G_lang:get("LANG_ACTIVITY_HOLIDAY_DUI_HUAN_CI_SHU",{num=(event.num - exchangeTimes)}))
			self:getButtonByName("Button_duihuan"):setTouchEnabled(true)
		end
	end

	self:_initScrollView(event)

end

function ActivityHolidayCell:_getScrollViewHeight()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().height
end

function ActivityHolidayCell:_getScrollViewWidth()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().width
end

function ActivityHolidayCell:_initScrollView(event)
	if self._scrollView then
		self._scrollView:removeAllChildrenWithCleanup(true)
	end
	if not event then
		return
	end
	local widgetWidth = 0
	local good = G_Goods.convert(G_Goods.TYPE_ITEM,event.cost_item,event.cost_num)
	if good then
		local widget = ActivityDailyCellItem.new(good)
		--如果未拥有置灰
		widget:setGray()
		widgetWidth = widget:getContentSize().width
		local height = widget:getContentSize().height
		widget:setPosition(ccp(self._space,(self:_getScrollViewHeight()-height)/2))
		self._scrollView:addChild(widget)
	else
		return
	end
	
	--添加一个等号
	--等号的x坐标
	local width = self._space*(1+1) + widgetWidth
	self._scrollView:addChild(self.denghao,10)
	self.denghao:setPositionX(width)

	local good = G_Goods.convert(event.type,event.value,event.size)
	if good then
		local widget = ActivityDailyCellItem.new(good)
		widgetWidth = widget:getContentSize().width
		local height = widget:getContentSize().height
		widget:setPosition(ccp(width + self._space,(self:_getScrollViewHeight()-height)/2))
		self._scrollView:addChild(widget)
	end

	width = width + self._space*(1+1) + widgetWidth
	--总长度
	local innerWidth = width > self:_getScrollViewWidth() and width or self:_getScrollViewWidth()
	self._scrollView:setInnerContainerSize(CCSizeMake(innerWidth,self:_getScrollViewHeight()))
end


function ActivityHolidayCell:_initEvent()
	self:registerBtnClickEvent("Button_duihuan",function()
		if not self._event then
			return
		end

		--判断活动是否已过期
		if not G_Me.activityData.holiday:checkHolidayActivate(self._holiday_id) then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_TIME_OUT_TIPS"))
			return
		end


		--判断等级
		if G_Me.userData.level < self._event.level then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_HOLIDAY_LEVEL_NOT_ENOUGH"))
			return
		end

		--判断道具数量
		local num = G_Me.bagData:getPropCount(self._event.cost_item)
		if num < self._event.cost_num then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_HOLIDAY_ITEM_NOT_ENOUGH"))
			return
		end

		local max = self._event.num
		local exchangeTimes = G_Me.activityData.holiday:getExchangeTimesById(self._event.id)
		if exchangeTimes == -1 then
			--数据异常
			return
		elseif exchangeTimes >= max then
			return
		end
		G_HandlersManager.activityHandler:sendGetHolidayEventAward(self._event.id) 
		end)
end


return ActivityHolidayCell