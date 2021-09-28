local CrossWarBetResultItem = class("CrossWarBetResultItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_BetResultItem.json")
end)

function CrossWarBetResultItem:ctor(...)

end

function CrossWarBetResultItem:update(_rank)
	-- use different background by different rank
	local bgTex = "ui/vip/fubentiaozhan_list" .. (_rank % 2 == 0 and 1 or 2) .. ".png"
	self:getPanelByName("Root"):setBackGroundImage(bgTex)

	-- if is top 3, show the crown icon
	local isTop3 = _rank <= 3
	local crown  = self:getImageViewByName("Image_Crown")

	crown:setVisible(isTop3)
	if isTop3 then
		local tex = G_Path.getRankTopThreeIcon(_rank)
		crown:loadTexture(tex)
	end

	-- set rank number
	self:showTextWithLabel("Label_Rank", G_lang:get("LANG_ARENA_RANKING", {rank = _rank}))

	-- set player name of this rank
	local rankUser = G_Me.crossWarData:getTopRankUser(_rank)
	local rankName = rankUser and rankUser.name or ""
	self:showTextWithLabel("Label_RankName", rankName)

	-- set player name I bet as this rank
	local betUser = G_Me.crossWarData:getBetUser(_rank)
	local betName = betUser and betUser.name or G_lang:get("LANG_CROSS_WAR_NOT_BET")
	self:showTextWithLabel("Label_BetName", betName)

	-- check if the bet result is right
	local checkMark = self:getImageViewByName("Image_Check")
	local isBet	= betUser ~= nil

	checkMark:setVisible(isBet)
	if isBet then
		local isRight = (rankUser and rankUser.user_id == betUser.user_id and rankUser.sid == betUser.sid)
		local markTex = isRight and "gou_big.png" or "cha.png"
		checkMark:loadTexture(markTex, UI_TEX_TYPE_PLIST)
	end
end

return CrossWarBetResultItem