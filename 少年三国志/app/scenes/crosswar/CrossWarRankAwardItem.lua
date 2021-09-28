local CrossWarRankAwardItem = class("CrossWarRankAwardItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_RankAwardItem.json")
end)

require("app.cfg.contest_rank_award_info")
require("app.cfg.title_info")
require("app.cfg.item_info")

local Goods = require("app.setting.Goods")
local DropInfo = require("app.scenes.common.dropinfo.DropInfo")

-- @param matchType: 1 - score match, 2 - championship
function CrossWarRankAwardItem:ctor(matchType)
	self._type = matchType
	self._itemInfo = nil
	self._titleID = 0

	-- create strokes
	self:enableLabelStroke("Label_Title", Colors.strokeBlack, 2)
	self:enableLabelStroke("Label_AwardNum", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Title", handler(self, self._onClickTitle))
	self:registerBtnClickEvent("Button_QualityFrame", handler(self, self._onClickAward))
end

function CrossWarRankAwardItem:update(index)
	local awardInfo = self:_findAwardInfo(index)
	self._itemInfo = item_info.get(awardInfo.award_value1)
	self._titleID = awardInfo.title_id

	-- set rank interval
	local lowerRank = awardInfo.rank_min
	local upperRank = awardInfo.rank_max
	local strRank = (lowerRank == upperRank) and lowerRank or (lowerRank .. "~" .. upperRank)
	self:getLabelByName("Label_Rank"):setText(G_lang:get("LANG_ARENA_RANKING", {rank = strRank}))

	-- set title info
	self:showWidgetByName("Panel_Title", self._titleID ~= 0)
	if self._titleID ~= 0 then
		local titleInfo = title_info.get(awardInfo.title_id)

		-- set player title
		local titleLabel = self:getLabelByName("Label_Title")
		titleLabel:setText(titleInfo.name)
		titleLabel:setColor(Colors.qualityColors[titleInfo.quality])
		local titleButton = self:getButtonByName("Button_Title")
		titleButton:loadTextureNormal(titleInfo.picture)

		-- set title limit time
		local day = titleInfo.effect_time / 3600 / 24
		self:showTextWithLabel("Label_TitleTime", G_lang:get("LANG_TITLE_TIME_LIMIT", {num = day}))
	end

	-- set the award
	goodsInfo = Goods.convert(awardInfo.award_type1, awardInfo.award_value1)
	self:_updateAwardInfo(goodsInfo, awardInfo.award_size1)
end

function CrossWarRankAwardItem:_findAwardInfo(index)
	local indexOfType = 1
	for i = 1, contest_rank_award_info.getLength() do
		local record = contest_rank_award_info.get(i)
		if record.type == self._type then
			if indexOfType == index then
				return record
			end
			indexOfType = indexOfType + 1
		end
	end

	return nil
end

function CrossWarRankAwardItem:_updateAwardInfo(goodsInfo, num)
	-- icon
	local icon = self:getImageViewByName("Image_AwardIcon")
	icon:loadTexture(goodsInfo.icon)

	-- icon base
	local base = self:getImageViewByName("Image_Base")
	base:loadTexture(G_Path.getEquipIconBack(goodsInfo.quality))

	-- quality frame
	local btnQualityFrame = self:getButtonByName("Button_QualityFrame")
	local qualityTexture = G_Path.getEquipColorImage(goodsInfo.quality, goodsInfo.type)
	btnQualityFrame:loadTextureNormal(qualityTexture, UI_TEX_TYPE_PLIST)
	btnQualityFrame:loadTexturePressed(qualityTexture, UI_TEX_TYPE_PLIST)

	-- number
	local numLabel = self:getLabelByName("Label_AwardNum")
	numLabel:setText("x" .. num)
end

function CrossWarRankAwardItem:_onClickTitle()
	local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(self._titleID)
	uf_sceneManager:getCurScene():addChild(dialog)
end

function CrossWarRankAwardItem:_onClickAward()
	local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(self._itemInfo)
    uf_sceneManager:getCurScene():addChild(layer)
end

return CrossWarRankAwardItem