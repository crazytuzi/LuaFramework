-- CrossWarWinAwardItem
-- This class represents an award item for winning streak

local CrossWarWinAwardItem = class("CrossWarWinAwardItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_WinAwardItem.json")
end)

require("app.cfg.contest_points_winning_info")
local Goods = require("app.setting.Goods")
local DropInfo = require("app.scenes.common.dropinfo.DropInfo")

function CrossWarWinAwardItem:ctor(...)
	self._canGetAward = false

	-- create strokes for some labels
	self:enableLabelStroke("Label_WinStreak_Num", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Award_Num", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_QualityFrame", handler(self, self._onClickAwardIcon))
	self:registerWidgetClickEvent("Root", handler(self, self._onClickSelf))
end

-- update award info
function CrossWarWinAwardItem:update(awardStatus)
	-- get the winning streak award info and goods info
	local awardInfo = contest_points_winning_info.get(awardStatus.awardID)
	local goodsInfo = Goods.convert(awardInfo.item_type, awardInfo.item_value)
	self._goodsInfo = goodsInfo
	self._awardID 	= awardStatus.awardID

	-- winning streak number
	local winStreak = self:getLabelByName("Label_WinStreak_Num")
	winStreak:setText(awardInfo.name)

	-- award icon and quality
	local awardIcon = self:getImageViewByName("ImageView_AwardIcon")
	awardIcon:loadTexture(goodsInfo.icon)

	local btnQualityFrame = self:getButtonByName("Button_QualityFrame")
	local qualityTexture = G_Path.getEquipColorImage(goodsInfo.quality, goodsInfo.type)
	btnQualityFrame:loadTextureNormal(qualityTexture, UI_TEX_TYPE_PLIST)
	btnQualityFrame:loadTexturePressed(qualityTexture, UI_TEX_TYPE_PLIST)

	-- award number
	local awardNum = self:getLabelByName("Label_Award_Num")
	awardNum:setText("x" .. awardInfo.item_size)

	-- award text content
	local awardContent = self:getLabelByName("Label_Award_Content")
	awardContent:setText(goodsInfo.name .. " x " .. awardInfo.item_size)

	-- award status
	local statusTip = self:getImageViewByName("ImageView_AwardStatus")
	local maxWinStreak = G_Me.crossWarData:getMaxWinStreak()
	self._canGetAward = (maxWinStreak >= awardStatus.needWinNum and not awardStatus.alreadyGot)

	if awardStatus.alreadyGot or maxWinStreak >= awardStatus.needWinNum then
		statusTip:setVisible(true)
		local statusTex = G_Path.getTextPath(awardStatus.alreadyGot and "jqfb_yilingqu.png" or "jqfb_dianjilingqu.png")
		statusTip:loadTexture(statusTex)
	else
		statusTip:setVisible(false)
	end

	-- set award progress
	self:getLabelByName("Label_Progress"):setText(maxWinStreak .. "/" .. awardStatus.needWinNum)
end

-- the click event of the award icon frame
function CrossWarWinAwardItem:_onClickAwardIcon()
	DropInfo.show(self._goodsInfo.type, self._goodsInfo.value)
end

-- the click event of the 'get' button
function CrossWarWinAwardItem:_onClickSelf()
	if self._canGetAward then
		G_HandlersManager.crossWarHandler:sendFinishWinsAward(self._awardID)
	end
end

return CrossWarWinAwardItem