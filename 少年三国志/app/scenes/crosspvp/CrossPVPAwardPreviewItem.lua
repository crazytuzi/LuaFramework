local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local CrossPVPAwardPreviewItem = class("CrossPVPAwardPreviewItem", function()
	return CCSItemCellBase:create("ui_layout/crosspvp_AwardPreviewItem.json")
end)

function CrossPVPAwardPreviewItem:ctor()
	self._tScrollView = self:getWidgetByName("ScrollView_Award")
    self._tScrollView = tolua.cast(self._tScrollView,"ScrollView")
end

-- nField 战场
function CrossPVPAwardPreviewItem:updateItem(tTmpl)
	if not tTmpl then
		return
	end

	CommonFunc._updateLabel(self, "Label_Stage", {text=tTmpl.name})

	local tAwardList = {}
	for i=1, 4 do
		local nType = tTmpl["award_type_"..i] or 0
		local nValue = tTmpl["award_value_"..i] or 0
		local nSize = tTmpl["award_size_"..i] or 0
		if nType ~= 0 then
			local tAward = {type=nType, value=nValue, size=nSize}
			table.insert(tAwardList, #tAwardList + 1, tAward)
		end
	end
	self:_initScrollView(tAwardList)
end

function CrossPVPAwardPreviewItem:_initScrollView(listData)
    self._tScrollView:removeAllChildren()

    local itemScale = 0.8
    local itemWidth = self._tScrollView:getContentSize().height * itemScale
    local space = 15 --间隙
    local curX = 0

    for i,v in ipairs(listData) do
        local btnName = "gift_item" .. "_" .. i
        local widget = require("app.scenes.giftmail.GiftMailIconCell").new(v,btnName)
        widget:setScale(itemScale)
        widget:updateData(v)
        widget:setPositionXY(curX, 0)
        self._tScrollView:addChild(widget)

        curX = curX + itemWidth + space
    end
end

return CrossPVPAwardPreviewItem