local CrossPVPBetRankItem = class("CrossPVPBetRankItem", function()
	return CCSItemCellBase:create("ui_layout/crosspvp_BetRankItem.json")
end)

function CrossPVPBetRankItem:ctor()
	self:enableLabelStroke("Label_UserName", Colors.strokeBrown, 1)
end

function CrossPVPBetRankItem:update(rank, data)
	local knightInfo = knight_info.get(data.main_role)

	-- set rank
	local rankCrown = self:getImageViewByName("Image_RankCrown")
	local rankLabel = self:getLabelBMFontByName("BitmapLabel_Rank")
	rankCrown:setVisible(rank <= 3)
	rankLabel:setVisible(rank > 3)

	if rank <= 3 then
		rankCrown:loadTexture(G_Path.getRankTopThreeIcon(rank))
	else
		rankLabel:setText(tostring(rank))
	end

	-- set rank
	local rankCrown = self:getImageViewByName("Image_RankCrown")
	local rankLabel = self:getLabelBMFontByName("BitmapLabel_Rank")
	rankCrown:setVisible(rank <= 3)
	rankLabel:setVisible(rank > 3)

	if rank <= 3 then
		rankCrown:loadTexture(G_Path.getRankTopThreeIcon(rank))
	else
		rankLabel:setText(tostring(rank))
	end

	-- set head icon
	local resID = G_Me.dressData:getDressedResidWithClidAndCltm(data.main_role, data.dress_id,
		rawget(data,"clid"),rawget(data,"cltm"),rawget(data,"clop"))
	self:getImageViewByName("Image_Head"):loadTexture(G_Path.getKnightIcon(resID))

	local qualityTex = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(qualityTex, UI_TEX_TYPE_PLIST)

	-- set name and server name
	local nameLabel = self:getLabelByName("Label_UserName")
	nameLabel:setText(data.name)
	nameLabel:setColor(Colors.qualityColors[knightInfo.quality])

	local serverName = data.sname == "" and G_lang:get("LANG_CROSS_WAR_SERVER_NO_REACTION")
										 or "[" .. string.gsub(data.sname, "^.-%((.-)%)", "%1") .. "]"
	self:showTextWithLabel("Label_ServerName", serverName)

	-- set flower num, egg num and total num
	self:showTextWithLabel("Label_FlowerNum", tostring(data.sp1))
	self:showTextWithLabel("Label_EggNum", tostring(data.sp2))
	self:showTextWithLabel("Label_TotalNum", tostring(data.sp3))

	-- update board color
	local isSameID = tostring(data.id) == tostring(G_Me.userData.id)
	local isSameServer = tostring(data.sid) == tostring(G_PlatformProxy:getLoginServer().id)
	self:_updateBoardColor(isSameID and isSameServer)
end

function CrossPVPBetRankItem:_updateBoardColor(isMe)
	if isMe then
		self:getPanelByName("Root"):setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
		self:getPanelByName("Panel_Info"):setBackGroundImage("list_board_red.png", UI_TEX_TYPE_PLIST)
	else
		self:getPanelByName("Root"):setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
		self:getPanelByName("Panel_Info"):setBackGroundImage("list_board.png", UI_TEX_TYPE_PLIST)
	end
end

return CrossPVPBetRankItem