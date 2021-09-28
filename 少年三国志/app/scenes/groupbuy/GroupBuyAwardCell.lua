-- GroupBuyAwardCell.lua

require("app.cfg.group_buy_award_info")
local GroupBuyCommon = require("app.scenes.groupbuy.GroupBuyCommon")

local string = string
local table = table

local GroupBuyConst = require("app.const.GroupBuyConst")
local ActivityDailyCellItem = require("app.scenes.activity.ActivityDailyCellItem")

local GroupBuyAwardCell = class("GroupBuyAwardCell",function()
    return CCSItemCellBase:create("ui_layout/groupbuy_AwardCell.json")
end)

function GroupBuyAwardCell:ctor(...)
	self._space = 10

	self._scrollView       = self:getScrollViewByName("ScrollView_duihuan")
	self._conditionLabel   = self:getLabelByName("Label_condition")
	self._progressTagLabel = self:getLabelByName("Label_progressTag")
	self._progressLabel    = self:getLabelByName("Label_progress")
	self._getButton        = self:getButtonByName("Button_lingqu")
	self._haveGetImage     = self:getImageViewByName("Image_yilingqu")

	self._data    = G_Me.groupBuyData
	self._handler = G_HandlersManager.groupBuyHandler

	self._conditionLabel:setText("")
	self._progressTagLabel:setText(G_lang:get("LANG_GROUP_BUY_DAILY_AWARD_PROGRESS"))
	self._progressLabel:setText("")

	self:attachImageTextForBtn("Button_lingqu","Image_25")

	self._richText = nil
end

function GroupBuyAwardCell:updateItem(cellData)
	self._cellData = cellData
	if not self._cellData then return end
	--先设定默认按钮状态
	self:getButtonByName("Button_lingqu"):setTouchEnabled(true)

	self._progressLabel:setVisible(true)
	self._progressTagLabel:setVisible(true)
	-- 进度
	local progress = 0
	if self._cellData.task_type == GroupBuyConst.DAILY_AWARD_TYPE.SELF then
		self._conditionLabel:setText(G_lang:get("LANG_GROUP_BUY_DAILY_AWARD_SELF", {score = self._cellData.condition}))
		progress = self._data:getScore()
	elseif self._cellData.task_type == GroupBuyConst.DAILY_AWARD_TYPE.ALL then
		self._conditionLabel:setText(G_lang:get("LANG_GROUP_BUY_DAILY_AWARD_ALL", {score = self._cellData.condition}))
		progress = self._data:getServerBuyCount()
	else
		self._conditionLabel:setText(G_lang:get("LANG_GROUP_BUY_AWARD_BACK_GOLD"))
		self._progressLabel:setVisible(false)
		self._progressTagLabel:setVisible(false)
	end

	self._progressLabel:setText(string.format("%d/%d", progress > self._cellData.condition and self._cellData.condition or progress, self._cellData.condition))
	self._progressTagLabel:setPositionX(-self._progressLabel:getContentSize().width)

	if self._data:isDailyAwardAlreadyGet(self._cellData.id) then
		self._getButton:setVisible(false)
		self._haveGetImage:setVisible(true)
	elseif progress >= self._cellData.condition then
		self._getButton:setVisible(true)
		self._haveGetImage:setVisible(false)
	else
		self._getButton:setVisible(true)
		self._getButton:setTouchEnabled(false)
		self._haveGetImage:setVisible(false)
	end

	self:registerBtnClickEvent("Button_lingqu",function()
		if progress < self._cellData.condition then
			return
		end
		if self._data:isDailyAwardAlreadyGet(self._cellData.id) then
			return
		end
		for i = 1, 3 do
			local type_ = self._cellData[string.format("type_%d", i)]
			if type_ and type_ > 0 then
				local value = cellData[string.format("value_%d", i)]
				local size = cellData[string.format("size_%d", i)]
				if GroupBuyCommon.checkBagisFull(type_, size) then
					return
				end
			end
		end
		self._handler:sendGetGroupBuyTaskAward(self._cellData.id)
	end)

	self:_initScrollView()

end

function GroupBuyAwardCell:_getScrollViewHeight()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().height
end

function GroupBuyAwardCell:_getScrollViewWidth()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().width
end

function GroupBuyAwardCell:_initScrollView(cellData)
	local cellData = self._cellData
	if self._scrollView then
		self._scrollView:removeAllChildrenWithCleanup(true)
	else
		return
	end
	local goodList = {}

	--scrollview的滑动宽度
	local innerWidth = 0

	local widgetWidth = 0  --icon的宽度
	for i = 1, 3 do
		local _type = cellData[string.format("type_%d", i)]
		if _type > 0 then
			local value = cellData[string.format("value_%d", i)]
			local size = cellData[string.format("size_%d", i)]
			local good = G_Goods.convert(_type,value,size)
			if good then
				table.insert(goodList,good)
				local widget = ActivityDailyCellItem.new(good)
				widgetWidth = widget:getContentSize().width
				local height = widget:getContentSize().height
				widget:setPosition(ccp(self._space*i + (i-1)*widgetWidth,(self:_getScrollViewHeight()-height)/2))
				self._scrollView:addChild(widget)
			end
		end
	end
	--总长度
	local width = self._space*(#goodList+1) + #goodList*widgetWidth
	innerWidth = width > self:_getScrollViewWidth() and width or self:_getScrollViewWidth()
	self._scrollView:setInnerContainerSize(CCSizeMake(innerWidth,self:_getScrollViewHeight()))
end


return GroupBuyAwardCell