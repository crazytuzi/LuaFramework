-- GroupBuyMainLayer.lua

local GroupBuyCommon         = require("app.scenes.groupbuy.GroupBuyCommon")
local GroupBuyConst          = require("app.const.GroupBuyConst")
local GroupBuyGoodsInfoPanel = require("app.scenes.groupbuy.mainlayer.GroupBuyGoodsInfoPanel")
local GroupBuyGoodsItem      = require("app.scenes.groupbuy.mainlayer.GroupBuyGoodsItem")
local GroupBuyRankInfoPanel  = require("app.scenes.groupbuy.mainlayer.GroupBuyRankInfoPanel")

local table = table
local ipairs = ipairs

local GroupBuyMainLayer = class("GroupBuyMainLayer", UFCCSNormalLayer)

function GroupBuyMainLayer.create( ... )
	return GroupBuyMainLayer.new("ui_layout/groupbuy_MainLayer.json", ...)
end

function GroupBuyMainLayer:ctor( ... )
	self.super.ctor(self, ...)

	-- widgets
	self._scoreKeyLabel     = self:getLabelByName("Label_Score_Key")
	self._scoreValueLabel   = self:getLabelByName("Label_Score_Value")
	self._couponKeyLabel    = self:getLabelByName("Label_Coupon_Key")
	self._couponValueLabel  = self:getLabelByName("Label_Coupon_Value")
	self._titleLabel        = self:getLabelByName("Label_Title")
	self._descLabel         = self:getLabelByName("Label_Desc")
	self._timeKeyLabel      = self:getLabelByName("Label_Time_Key")
	self._timeValueLabel    = self:getLabelByName("Label_Time_Value")
	self._timeKeyGetLabel   = self:getLabelByName("Label_Time_Key_Get")
	self._timeValueGetLabel = self:getLabelByName("Label_Time_Value_Get")
	self._endTimeKeyLabel   = self:getLabelByName("Label_End_Time_Key")
	self._endTimeValueLabel = self:getLabelByName("Label_End_Time_Value")
	self._runningPanel      = self:getPanelByName("Panel_Running")
	self._endPanel          = self:getPanelByName("Panel_End")
	self._bottomPanel       = self:getPanelByName("Panel_Bottom")
	self._endDescLabel      = self:getLabelByName("Label_End_Desc")
	self._getButton         = self:getButtonByName("Button_Get")
	self._redPointImage     = self:getImageViewByName("Image_RedPoint")

	self._goodsInfoPanel    = nil
	self._rankInfoPanel     = nil
	self._idx               = 1
	self._scrollView        = nil
	self._scrollViewButtons = {}

	-- data
	self._data          = GroupBuyCommon.getData()
	self._handler       = GroupBuyCommon.getHandler()
	self._nowTimeStatus = self._data:getTimeStatusType() -- 活动状态
	self._lastScoreValue = 0
	self._lastCouponValue = 0

	self:_initWidgets()
	self:_initScrollView()
end

function GroupBuyMainLayer:onLayerEnter()
	self._timer = G_GlobalFunc.addTimer(1, handler(self,self._update))
	
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GROUPBUY_MAINLAYER_UPDATE, self._updateWidgets, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GROUPBUY_GET_REWARD, self._getReward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GROUPBUY_BUY_REWARD, self._buyReward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GROUPBUY_DAILY_AWARD_GET, self._onUpdateCoupon, self)

	self._nowTimeStatus = self._data:getTimeStatusType()
	if self._nowTimeStatus == GroupBuyConst.TIME_STATUS_TYPE.RUNNING then
		self._handler:sendGetGroupBuyMainInfo()
		self:_scrollViewTo()
	elseif self._nowTimeStatus == GroupBuyConst.TIME_STATUS_TYPE.REWARD then
		-- self._handler:sendGetGroupBuyEndInfo()
		self._handler:sendGetGroupBuyMainInfo()
		self:_scrollViewTo()
	end
end	

function GroupBuyMainLayer:onLayerExit()
	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
   	end
	uf_eventManager:removeListenerWithTarget(self)

	if self._lastCouponChanger then
	    self._lastCouponChanger:stop()
	    self._lastCouponChanger = nil 
	end

    if self._lastScoreChanger then
	    self._lastScoreChanger:stop()
	    self._lastScoreChanger = nil 
	end
    self.super:onLayerExit()
end

function GroupBuyMainLayer:adapterLayer()
	self:adapterWidgetHeight("Panel_Bottom", "Panel_Top", "", 14, 0)
end

function GroupBuyMainLayer:_initWidgets()
	-- top
	GroupBuyCommon.setKeyValueLabelByLeft(self._scoreKeyLabel, self._scoreValueLabel, "LANG_GROUP_BUY_ALL_SCORE", self._data:getScore())
	GroupBuyCommon.setKeyValueLabelByLeft(self._couponKeyLabel, self._couponValueLabel, "LANG_GROUP_BUY_ALL_COUPON", self._data:getCoupon())

	self._titleLabel:setText(G_lang:get("LANG_GROUP_BUY_TITLE"))
	self._titleLabel:createStroke(Colors.strokeBrown, 1)

	self._redPointImage:setVisible(self._data:isCanReward())

	-- desc
	if self._richText == nil then
	    self._richText = CCSRichText:create(440, 100)
	    self._richText:setFontSize(self._descLabel:getFontSize())
	    self._richText:setFontName(self._descLabel:getFontName())
	    self._richText:setAnchorPoint(ccp(0, 1))
	    local x, y = self._descLabel:getPosition()
	    self._richText:setPosition(ccp(x - 10, y + 15))
	    self:getImageViewByName("Image_Desc"):addChild(self._richText)
	end
	self._richText:clearRichElement()
	self._richText:appendXmlContent(G_lang:get("LANG_GROUP_BUY_DESC"))
	self._richText:reloadData()
	self._descLabel:setVisible(false)

	-- time
	self:_setTimeInfo(self._timeKeyLabel, self._timeValueLabel, "acivity_time")
	self:_setTimeInfo(self._timeKeyGetLabel, self._timeValueGetLabel, "get_time")
	self:_setTimeInfo(self._endTimeKeyLabel, self._endTimeValueLabel, "acivity_time")

	-- goods info
	if self._goodsInfoPanel == nil then
		self._goodsInfoPanel = GroupBuyGoodsInfoPanel.create()
		self._goodsInfoPanel:setPosition(ccp(10, 15))
		self:getPanelByName("Panel_Goods_Info"):addNode(self._goodsInfoPanel)
	end

	-- rank info
	if self._rankInfoPanel == nil then
		self._rankInfoPanel = GroupBuyRankInfoPanel.create()
		self._rankInfoPanel:setPosition(ccp(10, -50))
		self:getPanelByName("Panel_Goods_Info"):addNode(self._rankInfoPanel)
	end

	self._getButton:setVisible(false)
	self:registerBtnClickEvent("Button_Help", handler(self, self._showHelpLayer))
	self:registerBtnClickEvent("Button_Award", handler(self, self._showAwardLayer))
	-- 排行榜暂时隐藏掉
	self:registerBtnClickEvent("Button_Rank", handler(self, self._showRankLayer))
	
	self:_updateShowStatus()
end

-- 刷新UI状态
function GroupBuyMainLayer:_updateShowStatus()
	self._goodsInfoPanel:setVisible(true)
	self._rankInfoPanel:setVisible(false)
	self._runningPanel:setVisible(true)
	self._endPanel:setVisible(false)
	self._bottomPanel:setVisible(true)
end

--刷新Scroview
function GroupBuyMainLayer:_initScrollView()
    if self._scrollView == nil then
        self._scrollView = self:getScrollViewByName("ScrollView_List")
        self._scrollView:setScrollEnable(true)
    end
    self._scrollView:removeAllChildrenWithCleanup(true)
    self._scrollViewButtons = {}
    local space = 0 --间隙
    local size = self._scrollView:getContentSize()
    local itemWidth = 0
    local goodsItems = self._data:getGoodsItems()
    for i, v in ipairs(goodsItems) do
        self._scrollViewButtons[i] = GroupBuyGoodsItem.new(v.id, string.format("ButtonName_%d", v.id))
        itemWidth = self._scrollViewButtons[i]:getWidth()
        self._scrollViewButtons[i]:setPosition(ccp(itemWidth*(i-1)+i*space,(size.height-itemWidth)/2))
        self._scrollView:addChild(self._scrollViewButtons[i])
        self:registerBtnClickEvent(self._scrollViewButtons[i]:getButtonName(),function(widget) 
            -- 点击事件
            self:_scrollViewTo(i)
        end )
    end
    local _scrollViewWidth = itemWidth*#goodsItems+space*(#goodsItems+1)
    self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
end

function GroupBuyMainLayer:_updateScrollViewCell()
    for i, v in ipairs(self._scrollViewButtons) do
    	v:updateData()
    end
end

function GroupBuyMainLayer:_updateRunningInfo() self:_scrollViewTo() end

function GroupBuyMainLayer:_updateEndInfo()
	local endInfo = self._data:getEndInfo() or {}
	local rankNum = endInfo.self_rank_id
	if rankNum and rankNum <= GroupBuyConst.AWARD_RANK_MAX_NUM then
		self._endDescLabel:setText(G_lang:get("LANG_GROUP_BUY_END_DESC_GET", {rank = rankNum}))
		self._endDescLabel:createStroke(Colors.strokeBrown, 1)
		self._getButton:setVisible(true)
		self:registerBtnClickEvent("Button_Get", function()
			local endInfo = self._data:getEndInfo() or {}
			if endInfo.is_acquired == GroupBuyConst.END_RAWARD_STATUS.UN_GET then
				self._handler:sendGetGroupBuyRankAward()
			end
		end)
		self:attachImageTextForBtn("Button_Get", "Image_Get")
		-- self._getButton:setTouchEnabled(false)
	else
		self._endDescLabel:setText(G_lang:get("LANG_GROUP_BUY_END_DESC_SEE"))
		self._endDescLabel:createStroke(Colors.strokeBrown, 1)
		self._getButton:setVisible(false)
	end
end

function GroupBuyMainLayer:_updateWidgets()
	local data = self._data
	self._lastScoreValue = data:getScore()
	self._scoreValueLabel:setText(data:getScore())
	self._lastCouponValue = data:getCoupon()
	self._couponValueLabel:setText(data:getCoupon())

	-- time
	self:_setTimeInfo(self._timeKeyLabel, self._timeValueLabel, "acivity_time")
	self:_setTimeInfo(self._timeKeyGetLabel, self._timeValueGetLabel, "get_time")
	self:_setTimeInfo(self._endTimeKeyLabel, self._endTimeValueLabel, "acivity_time")

	if self._nowTimeStatus == GroupBuyConst.TIME_STATUS_TYPE.RUNNING then
		self:_updateRunningInfo()
	elseif self._nowTimeStatus == GroupBuyConst.TIME_STATUS_TYPE.REWARD then
		self:_updateRunningInfo()
		self:_updateEndInfo()
	end
	self:_updateShowStatus()

	self:_updateScrollViewCell()
end

function GroupBuyMainLayer:_scrollViewTo(idx)
	self._idx = idx or self._idx
	if  self._scrollView == nil or self._scrollViewButtons == nil or #self._scrollViewButtons == 0 then
        return
    end
    for i, v in ipairs(self._scrollViewButtons) do
        self._scrollViewButtons[i]:setSelected(self._idx == i)
    end

    self._goodsInfoPanel:updateItemInfo(self._scrollViewButtons[self._idx]:getItemId())
end

function GroupBuyMainLayer:_update(dt)
	local nowTimeStatus = self._data:getTimeStatusType()
	if nowTimeStatus == GroupBuyConst.TIME_STATUS_TYPE.END then
		G_MovingTip:showMovingTip(G_lang:get("LANG_GROUP_BUY_END_OVER"))
    	uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
		return
	end
	if self._nowTimeStatus ~= nowTimeStatus then
		self._nowTimeStatus = nowTimeStatus
		if self._nowTimeStatus == GroupBuyConst.TIME_STATUS_TYPE.REWARD then
			-- self._handler:sendGetGroupBuyEndInfo()
			self._handler:sendGetGroupBuyTaskAwardInfo()
			self:_updateWidgets()
		else
			self:_updateWidgets()
		end
	end
end

function GroupBuyMainLayer:_getReward(data)
	if data and data.rewards then
		GroupBuyCommon.showGetItemLayer(data)
	end
end

function GroupBuyMainLayer:_buyReward(data)
	if type(data.id) ~= "number" then return end
	local item = self._data:getGoodsItemById(data.id)
	if not item then return end
	local rewards = {}
	local reward = {type = item.type, value = item.value, size = item.size}
	table.insert(rewards, reward)
	local reward = {type = G_Goods.TYPE_COUPON, value = 0, size = self._goodsInfoPanel:getGiveCouponNnum()}
	table.insert(rewards, reward)
	GroupBuyCommon.showGetItemLayer(rewards)
	self:_updateRunningInfo()
	self._redPointImage:setVisible(self._data:isCanReward())

	if self._lastScoreValue ~= self._data:getScore() then
        --增加一个变化动画
        if self._lastScoreChanger then
            self._lastScoreChanger:stop()
            self._lastScoreChanger = nil 
        end
        local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
        self._lastScoreChanger = NumberScaleChanger.new(self._scoreValueLabel,  self._lastScoreValue, self._data:getScore(),
            function(value) 
                self._scoreValueLabel:setText(GlobalFunc.ConvertNumToCharacter(value))
                self._lastScoreValue = value
            end
        )
    end
    self:_updateCouponLabelByAnim()

    self:_updateScrollViewCell()
end

function GroupBuyMainLayer:_updateCouponLabelByAnim()
	if self._lastCouponValue ~= self._data:getCoupon() then
        --增加一个变化动画

        if self._lastCouponChanger then
            self._lastCouponChanger:stop()
            self._lastCouponChanger = nil 
        end
        local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
        self._lastCouponChanger = NumberScaleChanger.new(self._couponValueLabel,  self._lastCouponValue, self._data:getCoupon(),
            function(value)
                self._couponValueLabel:setText(GlobalFunc.ConvertNumToCharacter(value))
                self._lastCouponValue = value
            end
        )
    end
end

function GroupBuyMainLayer:_onUpdateCoupon()
	self:_updateCouponLabelByAnim()
	self._redPointImage:setVisible(self._data:isCanReward())
	self._goodsInfoPanel:updateItemInfo()
end

-- 活动截止时间
function GroupBuyMainLayer:_setTimeInfo(keyLabel, valueLabel, typeStr)
	if typeStr == "acivity_time" then
		local time = G_Me.groupBuyData:getEndTime()
		local date = G_ServerTime:getDateObject(time or 0)
		GroupBuyCommon.setKeyValueLabelByUpDown(keyLabel, valueLabel, "LANG_GROUP_BUY_TIME_KEY", G_lang:get("LANG_GROUP_BUY_TIME_VALUE",{year=date.year,month=date.month,day=date.day,hour=date.hour}))
	else
		local time = G_Me.groupBuyData:getAwardEndTime()
		local date = G_ServerTime:getDateObject(time or 0)
		GroupBuyCommon.setKeyValueLabelByUpDown(keyLabel, valueLabel, "LANG_GROUP_BUY_TIME_KEY_AWARD", G_lang:get("LANG_GROUP_BUY_TIME_VALUE",{year=date.year,month=date.month,day=date.day,hour=date.hour}))
	end
end

function GroupBuyMainLayer:_showHelpLayer()
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_GROUP_BUY_END_HELP_TITLE_1"), content = G_lang:get("LANG_GROUP_BUY_END_HELP_CONTENT_1")},
			-- {title = G_lang:get("LANG_GROUP_BUY_END_HELP_TITLE_2"), content = G_lang:get("LANG_GROUP_BUY_END_HELP_CONTENT_2")},
		})
end

function GroupBuyMainLayer:_showAwardLayer()
	require("app.scenes.groupbuy.GroupBuyAwardLayer").show()
end

function GroupBuyMainLayer:_showRankLayer()
	require("app.scenes.groupbuy.GroupBuyRankLayer").show()
end

return GroupBuyMainLayer