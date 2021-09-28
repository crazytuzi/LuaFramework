-- 招财符明细条目

local ActivityDailyFortuneDetailItem = class("ActivityDailyFortuneDetailItem", function (  )
	return CCSItemCellBase:create("ui_layout/activity_DailyFortuneDetailItem.json")
end)

require "app.cfg.fortune_info"

ActivityDailyFortuneDetailItem.MAX_MULTI_TYPE = 3

function ActivityDailyFortuneDetailItem:ctor(  )
	local templateLabel = self:getLabelByName("Label_Info")
	local parent = templateLabel:getParent()
	self._richText = GlobalFunc.createRichTextFromTemplate(templateLabel, parent, "", nil, kCCTextAlignmentLeft)
	self._fortuneInfo = fortune_info.get(1)
end

function ActivityDailyFortuneDetailItem:update( data )
	local descIdx = 1

	for i=1, ActivityDailyFortuneDetailItem.MAX_MULTI_TYPE do
		if tostring(self._fortuneInfo["strike_value_" .. i]) == tostring(data.multi) then
			descIdx = i
			break
		end
	end

	self._richText:clearRichElement()
	self._richText:appendContent(G_lang:get("LANG_ACTIVITY_FORTUNE_DETAIL_INFO",
	{
		-- time = G_ServerTime:getTimeString(data.time),
		time = G_ServerTime:getDataObjectFormat("%X", data.time),
		desc = self._fortuneInfo["description_" .. descIdx],
		gold = data.gold,
		silver = data.silver,
	}), Colors.uiColors.WHITE)
	self._richText:reloadData()
end


return ActivityDailyFortuneDetailItem