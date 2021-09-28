local ActivityUserReturnGift = class("ActivityUserReturnGift", function()
	return CCSItemCellBase:create("ui_layout/activity_ActivityUserReturnGift.json")
end)

require("app.cfg.return_level_gift_info")

local ITEM_INTERVAL = 5

function ActivityUserReturnGift:ctor()
	self._index = 1
	self._giftInfo = nil
	self._awardList = nil
	self._scrollView = self:getScrollViewByName("ScrollView_Award")

	-- create a rich text to show level limit
	local root 	   = self:getRootWidget()
	local template = self:getLabelByName("Label_LevelLimit")
	self._richText = GlobalFunc.createRichTextFromTemplate(template, root, "")

	-- register btn click
	self:registerBtnClickEvent("Button_GetAward", handler(self, self._onClickGet))
end

function ActivityUserReturnGift:update(index)
	self._index = index
	self._giftInfo = return_level_gift_info.indexOf(index)

	-- level request
	local content = GlobalFunc.formatText(G_lang:get("LANG_ACTIVITY_RETURN_LEVEL_LIMIT"),
										  {level = self._giftInfo.level})
	self._richText:clearRichElement()
	self._richText:appendContent(content, Colors.uiColors.WHITE)
	self._richText:reloadData()

	-- update gift list
	self:_updateGiftList()

	-- update button state
	self:_updateBtnState()
end

function ActivityUserReturnGift:_updateGiftList()
	self._scrollView:removeAllChildrenWithCleanup(true)
	
	-- prepare gift data
	self._awardList = {}
	for i = 1, 4 do
		local awardType = self._giftInfo["type_" .. i]
		if awardType > 0 then
			local awardValue = self._giftInfo["value_" .. i]
			local awardSize  = self._giftInfo["size_" .. i]
			self._awardList[#self._awardList + 1] = {type = awardType, value = awardValue, size = awardSize}
		end
	end

	-- create award items
	local x = ITEM_INTERVAL
	local itemWidth = self._scrollView:getContentSize().height
	for i, v in ipairs(self._awardList) do
		local itemName = "gift_item_" .. i
		local item = require("app.scenes.giftmail.GiftMailIconCell").new(v, itemName)
		item:updateData(v)
		item:setPositionXY(x, 0)
		self._scrollView:addChild(item)

		x = x + itemWidth + ITEM_INTERVAL
	end
end

function ActivityUserReturnGift:_updateBtnState()
	local hasGot = G_Me.activityData.userReturn:hasGotGift(self._index)
	local getBtn = self:getButtonByName("Button_GetAward")
	getBtn:setVisible(not hasGot)
	self:showWidgetByName("Image_AlreadyGot", hasGot)

	if not hasGot then
		local isLevelReach = G_Me.userData.level >= self._giftInfo.level
		getBtn:setTouchEnabled(isLevelReach)
		self:getImageViewByName("Image_Get"):showAsGray(not isLevelReach)
	end
end

function ActivityUserReturnGift:_onClickGet()
	G_HandlersManager.activityHandler:sendGetOldUserGift(self._index)
end

return ActivityUserReturnGift