local CrossWarServerAwardItem = class("CrossWarServerAwardItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_ServerAwardItem.json")
end)

require("app.cfg.contest_server_award_info")
require("app.cfg.item_info")

local Goods = require("app.setting.Goods")
local DropInfo = require("app.scenes.common.dropinfo.DropInfo")

function CrossWarServerAwardItem:ctor()
	self:enableLabelStroke("Label_Rank", Colors.strokeBrown, 2)

	self:registerBtnClickEvent("Button_Get", handler(self, self._onClickGet))
	self:registerBtnClickEvent("Button_QualityFrame", handler(self, self._onClickAward))
end

function CrossWarServerAwardItem:update(index)
	local user = G_Me.crossWarData:getTopRankUser(index)
	local awardInfo = contest_server_award_info.get(index)
	local goodsInfo = Goods.convert(awardInfo.item_type, awardInfo.item_value)

	self._itemInfo = item_info.get(awardInfo.item_value)
	self._index = index

	-- update rank
	self:showTextWithLabel("Label_Rank", G_lang:get("LANG_ARENA_RANKING", {rank = index}))

	-- update award icon, and its quality frame
	local resID = G_Me.dressData:getDressedResidWithClidAndCltm(user.main_role, user.dress_id,
		rawget(user,"clid"),rawget(user,"cltm"),rawget(user,"clop"))
	self:getImageViewByName("Image_Icon"):loadTexture(goodsInfo.icon)

	local btnQualityFrame = self:getButtonByName("Button_QualityFrame")
	local qualityTexture = G_Path.getEquipColorImage(goodsInfo.quality, goodsInfo.type)
	btnQualityFrame:loadTextureNormal(qualityTexture, UI_TEX_TYPE_PLIST)
	btnQualityFrame:loadTexturePressed(qualityTexture, UI_TEX_TYPE_PLIST)

	self:showTextWithLabel("Label_AwardNum", "x" .. awardInfo.item_size)

	-- update player name and server name
	self:showTextWithLabel("Label_ServerName", "[" .. string.gsub(user.sname, "^.-%((.-)%)", "%1") .. "]")
	self:showTextWithLabel("Label_UserName", user.name)

	-- update award state
	local isInChampionship 	= G_Me.crossWarData:isInChampionship()
	local isAlreadyGet		= G_Me.crossWarData:isServerAwardGet(index)
	local isSameServer		= tostring(user.sid) == tostring(G_PlatformProxy:getLoginServer().id)

	self:showTextWithLabel("Label_NotOver", G_lang:get("LANG_CROSS_WAR_CHAMPIONSHIP_NOT_OVER"))
	self:showWidgetByName("Label_NotOver", isInChampionship)
	self:showWidgetByName("Image_Status", not isInChampionship and (isAlreadyGet or not isSameServer))
	self:showWidgetByName("Button_Get", not isInChampionship and not isAlreadyGet and isSameServer)

	local statusImg = G_Path.getTxt(isAlreadyGet and "jqfb_yilingqu.png" or "weidacheng.png")
	self:getImageViewByName("Image_Status"):loadTexture(statusImg)
end

function CrossWarServerAwardItem:_onClickGet()
	G_HandlersManager.crossWarHandler:sendFinishServerAward(self._index)
end

function CrossWarServerAwardItem:_onClickAward()
	local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(self._itemInfo)
    uf_sceneManager:getCurScene():addChild(layer)
end

return CrossWarServerAwardItem