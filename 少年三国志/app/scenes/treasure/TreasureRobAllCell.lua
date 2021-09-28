local TreasureRobAllCell = class("TreasureRobAllCell", function()
	return CCSItemCellBase:create("ui_layout/treasure_TreasureRobAllCell.json")
end)

require("app.cfg.treasure_fragment_info")
require("app.cfg.treasure_info")
require("app.cfg.knight_info")

TreasureRobAllCell.ROB_DETAIL	= 1
TreasureRobAllCell.USE_SPIRIT = 2
TreasureRobAllCell.LACK_SPIRIT= 3
TreasureRobAllCell.ROB_FINISH = 4
TreasureRobAllCell.TYPE_MAX	= 4

TreasureRobAllCell.GAP 		= 5

function TreasureRobAllCell:ctor(cellType, treasureID, fragmentID, robCount, robResult)
	self._cellType		= cellType
	self._treasureID 	= treasureID
	self._fragmentID	= fragmentID
	self._robCount		= robCount
	self._robResult		= robResult

	-- show relative panel
	for i = 1, TreasureRobAllCell.TYPE_MAX do
		self:showWidgetByName("Panel_" .. i, i == self._cellType)
	end

	-- initialize content
	self:_initContent()
end

function TreasureRobAllCell:_initContent()
	if self._cellType == TreasureRobAllCell.ROB_DETAIL then
		local isSuccess = self._robResult.rob_result

		-- set rob times
		local strTimes = G_lang:get("LANG_DUNGEON_GATENUM", {num = self._robCount})
		self:showTextWithLabel("Label_Times", strTimes)
		self:enableLabelStroke("Label_Times", Colors.strokeBrown, 1)

		-- set rob detail
		local userName = self._robResult.rob_name
		local fragInfo = treasure_fragment_info.get(self._fragmentID)
		local fragName = fragInfo.name
		local str = isSuccess and G_lang:get("LANG_ONE_KEY_ROB_SUCCESS", {user = userName, fragment = fragName})
							   or G_lang:get("LANG_ONE_KEY_ROB_FAIL", {user = userName, fragment = fragName})
		self:showTextWithLabel("Label_RobDetail", str)

		-- exp and money
		self:showTextWithLabel("Label_ExpNum", self._robResult.rewards[1].size)
		self:showTextWithLabel("Label_MoneyNum", self._robResult.rewards[2].size)
		self:showTextWithLabel("Label_rookieBuffValue",G_Me.userData:getExpAdd( self._robResult.rewards[1].size))

		-- extra item award
		local award = self._robResult.turnover_reward
		local goods = G_Goods.convert(award.type, award.value, award.size)
		self:showTextWithLabel("Label_RobExtraItem", goods.name .. "x" .. goods.size)

		self:showWidgetByName("Label_RobSuccess", isSuccess)
		self:showWidgetByName("Label_RobFail", not isSuccess)

		if isSuccess then
			templateLabel = self:getLabelByName("Label_RobSuccess")
			parent = templateLabel:getParent()
			local fragColor = Colors.qualityDecColors[fragInfo.quality]
			content = G_lang:get("LANG_ONE_KEY_ROB_FRAGMENT_SUCCESS", { fragmentColor = fragColor, fragment = fragName})
			GlobalFunc.createRichTextFromTemplate(templateLabel, parent, content, Colors.strokeBrown, kCCTextAlignmentLeft)
		else
			self:enableLabelStroke("Label_RobFail", Colors.strokeBrown, 1)
		end
	elseif self._cellType == TreasureRobAllCell.ROB_FINISH then
		templateLabel = self:getLabelByName("Label_RobFinish")
		parent = templateLabel:getParent()
		local treasureInfo = treasure_info.get(self._treasureID)
		local treasureColor = Colors.qualityDecColors[treasureInfo.quality]
		local content = G_lang:get("LANG_ONE_KEY_ROB_FINISH", {color = treasureColor, treasure = treasureInfo.name})
		GlobalFunc.createRichTextFromTemplate(templateLabel, parent, content, Colors.strokeBrown, kCCTextAlignmentLeft)
	end
end

function TreasureRobAllCell:getRealHeight()
	return self:getPanelByName("Panel_" .. self._cellType):getContentSize().height
end

return TreasureRobAllCell