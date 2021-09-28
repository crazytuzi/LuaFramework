local ActivityUserReturn = class("ActivityUserReturn", UFCCSNormalLayer)

require("app.cfg.return_level_gift_info")
local ReturnGiftItem = require("app.scenes.activity.ActivityUserReturnGift")

function ActivityUserReturn.create()
	return ActivityUserReturn.new("ui_layout/activity_ActivityUserReturn.json", nil)
end

function ActivityUserReturn:ctor(json, func)
	self._canGetVip = G_Me.activityData.userReturn:canGetVipExp()
	self._canGetGift = false --G_Me.activityData.userReturn:canGetGift()

	self._tabs = nil
	self._giftList = nil	-- list view for gifts
	self._sortedGifts = nil	-- sorted gift ids

	self:_prepareAndSortGifts()

	self.super.ctor(self, json, func)
end

function ActivityUserReturn:onLayerLoad()
	self:_initTabs()

	self:enableLabelStroke("Label_Time", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_TimeDetail", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Cond", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CondDetail", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_VipDesc2", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_VipExp", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_VipExp_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_VipLevel", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_VipLevel_Num", Colors.strokeBrown, 1)

	-- button events
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))
	self:registerBtnClickEvent("Button_GetVip", handler(self, self._onClickGet))
end

function ActivityUserReturn:onLayerEnter()
	-- set activity time
	local startTime, endTime = G_Me.activityData.userReturn:getActivityTime()
	local loginTime = G_Me.activityData.userReturn:getLoginLimitTime()
	local startDate = G_ServerTime:getDateObject(startTime)
	local endDate   = G_ServerTime:getDateObject(endTime)
	local loginDate = G_ServerTime:getDateObject(loginTime)
	local strStart  = G_lang:get("LANG_BAG_ITEM_DEAD_TIME", 
					  {year = startDate.year, month = startDate.month, day = startDate.day, hour = startDate.hour})
	local strEnd    = G_lang:get("LANG_BAG_ITEM_DEAD_TIME",
					  {year = endDate.year, month = endDate.month, day = endDate.day, hour = endDate.hour})
	self:showTextWithLabel("Label_TimeDetail", strStart .. "——" .. strEnd)
	self:showTextWithLabel("Label_CondDetail", G_lang:get("LANG_ACTIVITY_USER_RETURN_COND",
											   {m1 = loginDate.month, d1 = loginDate.day,
											    m2 = startDate.month, d2 = startDate.day}))

	-- set vip exp and level
	local exp, level = G_Me.activityData.userReturn:getVipExpAndLevel()
	self:showTextWithLabel("Label_VipExp_Num", G_lang:get("LANG_POINT", {num = exp}))
	self:showTextWithLabel("Label_VipLevel_Num", G_lang:get("LANG_LEVEL_INFO_FORMAT", {levelValue = level}))

	-- update red tips and button state
	self:_updateBtnState()
	self:_updateRedTips()

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_OLD_USER_GIFT, self._onRcvGift, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_OLD_USER_VIP_AWARD, self._onRcvVip, self)
end

function ActivityUserReturn:_prepareAndSortGifts()
	self._sortedGifts = {}

	-- init gift ids
	local giftLen = return_level_gift_info.getLength()
	for i = 1, giftLen do
		self._sortedGifts[#self._sortedGifts + 1] = i
	end

	-- sort
	local sortFunc = function(a, b)
		local hasGotA = G_Me.activityData.userReturn:hasGotGift(a)
		local hasGotB = G_Me.activityData.userReturn:hasGotGift(b)

		if hasGotA ~= hasGotB then
			return not hasGotA
		end

		return a < b
	end

	table.sort(self._sortedGifts, sortFunc)
end

function ActivityUserReturn:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	self._tabs:add("CheckBox_Vip", nil, "Label_Vip")
	self._tabs:add("CheckBox_Gift", nil, "Label_Gift")
	self._tabs:checked(self._canGetGift and "CheckBox_Gift" or "CheckBox_Vip")
end

function ActivityUserReturn:_initGiftList()
	if not self._giftList then
		local panel = self:getPanelByName("Panel_ListView")
		local panelSize = panel:getSize()
		local panelX,panelY = panel:getPosition()
		local parentX,parentY = self:getPanelByName("Panel_Gift"):getPosition()

		-- adjust panel position and size
		panelY = panelY - parentY
		panel:setPositionXY(panelX, panelY)
		panel:setSize(CCSizeMake(panelSize.width, panelSize.height + parentY))
		
		-- create list view
		self._giftList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._giftList:setCreateCellHandler(function(list, index)
			return ReturnGiftItem.new()
		end)

		self._giftList:setUpdateCellHandler(function(list, index, cell)
			local realIndex = self._sortedGifts[index + 1]
			cell:update(realIndex)
		end)

		local len = return_level_gift_info.getLength()
		self._giftList:reloadWithLength(len)
	end
end

function ActivityUserReturn:_updateRedTips()
	self:showWidgetByName("Image_TipsVip", G_Me.activityData.userReturn:canGetVipExp())
	self:showWidgetByName("Image_TipsGift", G_Me.activityData.userReturn:canGetGift())
end

function ActivityUserReturn:_updateBtnState()
	local canGet = G_Me.activityData.userReturn:canGetVipExp()
	self:showWidgetByName("Button_GetVip", canGet)
	self:showWidgetByName("Image_Got", not canGet)
end

function ActivityUserReturn:_onTabChecked(szCheckBoxName)
	local showVipPanel = szCheckBoxName == "CheckBox_Vip"
	self:showWidgetByName("Panel_Vip", showVipPanel)
	self:showWidgetByName("Panel_Gift", not showVipPanel)

	-- first time to show the gift list
	if not showVipPanel and not self._giftList then
		self:_initGiftList()
	end
end

function ActivityUserReturn:_onTabUnchecked()

end

function ActivityUserReturn:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_ACTIVITY_USER_RETURN"), content = G_lang:get("LANG_ACTIVITY_USER_RETURN_HELP")},
		})
end

function ActivityUserReturn:_onClickGet()
	G_HandlersManager.activityHandler:sendGetOldUserVipAward()
end

function ActivityUserReturn:_onRcvVip()
	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(
				  {{type = G_Goods.TYPE_VIP_EXP, value = 0, size = G_Me.activityData.userReturn:getVipExpAndLevel()}})
	uf_notifyLayer:getModelNode():addChild(layer)

	self:_updateBtnState()
	self:_updateRedTips()
end

function ActivityUserReturn:_onRcvGift(giftId)
	-- pop gift info
	local giftInfo = return_level_gift_info.get(giftId)
	local awards = {}
	for i = 1, 4 do
		local awardType = giftInfo["type_" .. i]
		if awardType > 0 then
			local awardValue = giftInfo["value_" .. i]
			local awardSize  = giftInfo["size_" .. i]
			awards[#awards + 1] = {type = awardType, value = awardValue, size = awardSize}
		end
	end

	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
	uf_notifyLayer:getModelNode():addChild(layer)

	-- refresh
	self:_prepareAndSortGifts()
	self._giftList:reloadWithLength(#self._sortedGifts)
	self:_updateRedTips()
end

return ActivityUserReturn