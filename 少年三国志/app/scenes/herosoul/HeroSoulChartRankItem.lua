local HeroSoulChartRankItem = class("HeroSoulChartRankItem", function()
	return CCSItemCellBase:create("ui_layout/herosoul_ChartRankItem.json")
end)

local HeroSoulConst = require("app.const.HeroSoulConst")

function HeroSoulChartRankItem:ctor()
	self._userData	= nil
	self._rankCrown = self:getImageViewByName("Image_RankCrown")
	self._rankLabel = self:getLabelBMFontByName("BitmapLabel_Rank")

	self:enableLabelStroke("Label_UserName", Colors.strokeBrown, 1)
	self:registerWidgetClickEvent("Image_HeadBg", handler(self, self._onClickHead))
end

function HeroSoulChartRankItem:update(rankType, rank)
	local data = G_Me.heroSoulData:getChartRankUser(rankType, rank)
	self._userData = data

	-- rank
	self:_updateRank(rank)

	-- head
	self:_updateHeadIcon(data)

	-- name, server, chart info
	self:_updateOtherInfo(rankType, data)

	-- board color
	local isSameID = tostring(data.id) == tostring(G_Me.userData.id)
	local isSameServer = tostring(data.sid) == tostring(G_PlatformProxy:getLoginServer().id)
	self:_updateBoardColor(isSameID and isSameServer)
end

function HeroSoulChartRankItem:_updateRank(rank)
	local isTop3 = (rank <= 3)
	self._rankCrown:setVisible(isTop3)
	self._rankLabel:setVisible(not isTop3)

	if isTop3 then
		self._rankCrown:loadTexture(G_Path.getRankTopThreeIcon(rank))
	else
		self._rankLabel:setText(tostring(rank))
	end
end

function HeroSoulChartRankItem:_updateHeadIcon(data)
	local knightInfo = knight_info.get(data.main_role)
	
	-- head
	local resID = G_Me.dressData:getDressedResidWithClidAndCltm(data.main_role, data.dress_id, rawget(data,"clid"),
																rawget(data,"cltm"),rawget(data,"clop"))
	self:getImageViewByName("Image_Head"):loadTexture(G_Path.getKnightIcon(resID))

	-- quality bg and quality frame
	local bgPath = G_Path.getEquipIconBack(knightInfo.quality)
	self:getImageViewByName("Image_QualityBg"):loadTexture(bgPath, UI_TEX_TYPE_PLIST)

	local framePath = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(framePath, UI_TEX_TYPE_PLIST)
end

function HeroSoulChartRankItem:_updateOtherInfo(rankType, data)
	local knightInfo = knight_info.get(data.main_role)

	-- user name
	local nameLabel = self:getLabelByName("Label_UserName")
	nameLabel:setText(data.name)
	nameLabel:setColor(Colors.qualityColors[knightInfo.quality])

	-- server name
	local showServer = (rankType == HeroSoulConst.RANK_CROSS)
	self:showWidgetByName("Label_ServerName", showServer)

	if showServer then
		local serverName = ""
		if data.sname == "" then
			serverName = G_lang:get("LANG_CROSS_WAR_SERVER_NO_REACTION")
		else
			serverName = "[" .. string.gsub(data.sname, "^.-%((.-)%)", "%1") .. "]"
		end
		self:showTextWithLabel("Label_ServerName", serverName)
	end

	-- chart value and activated chart num
	self:showTextWithLabel("Label_ChartPoint_Num", tostring(data.chartPoint))
	self:showTextWithLabel("Label_Activated_Num", tostring(data.chartNum))
end

function HeroSoulChartRankItem:_updateBoardColor(isMe)
	if isMe then
		self:getPanelByName("Root"):setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board_red.png", UI_TEX_TYPE_PLIST)
	else
		self:getPanelByName("Root"):setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board.png", UI_TEX_TYPE_PLIST)
	end
end

function HeroSoulChartRankItem:_onClickHead()
	local userServerId = self._userData.sid
	local isLocalServer = tostring(userServerId) == tostring(G_PlatformProxy:getLoginServer().id)

	if isLocalServer then
		G_HandlersManager.arenaHandler:sendCheckUserInfo(self._userData.id)
	else
		G_HandlersManager.crossWarHandler:sendGetPlayerTeam(self._userData.sid, self._userData.id)
	end
end

return HeroSoulChartRankItem