-- CrossWarRankItem
-- This class represents an item of user info in the ranking list

local CrossWarRankItem = class("CrossWarRankItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_RankItem.json")
end)

local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

local RankCrownImages = { "ui/top/mrt_huangguan1.png",
						  "ui/top/mrt_huangguan2.png",
						  "ui/top/mrt_huangguan3.png" }

function CrossWarRankItem:ctor(rankType)
	self._rankType = rankType

	self._rankCrown = self:getImageViewByName("Image_RankCrown")
	self._rankLabel = self:getLabelBMFontByName("BitmapLabel_Rank")

	-- hide winning streak if necessary
	self:showWidgetByName("Image_Win", self._rankType == CrossWarCommon.RANK_SCORE)

	-- NOTE:现在暂时关闭押注功能
	self:showWidgetByName("Label_Other", self._rankType == CrossWarCommon.RANK_SCORE)
	self:showWidgetByName("Label_OtherNum", self._rankType == CrossWarCommon.RANK_SCORE)

	-- set fixed texts
	self:_setFixedTexts()

	-- create strokes for the player name
	self:enableLabelStroke("Label_UserName", Colors.strokeBlack, 2)
	self:enableLabelStroke("Label_WinNum", Colors.strokeBlack, 2)

	-- register touch event of the head icon
	self:registerWidgetTouchEvent("Image_HeadBkg", handler(self, self._onTouchHead))
end

-- set fixed texts
function CrossWarRankItem:_setFixedTexts()
	-- set the text of "power"
	self:showTextWithLabel("Label_Power", G_lang:get("LANG_INFO_FIGHT") .. "：")

	-- set the text of "score" or "follow rate"
	local other = self:getLabelByName("Label_Other")
	local lang = (self._rankType == CrossWarCommon.RANK_SCORE and "LANG_JIFEN" or "LANG_CROSS_WAR_FOLLOW_RATE")
	other:setText(G_lang:get(lang))

	self:getLabelByName("Label_OtherNum"):setPositionX(other:getPositionX() + other:getContentSize().width)
end

function CrossWarRankItem:_setRankNum(rank)
	-- if rank is top 3, show the crown icon
	-- or, show the num label
	local isTop3 = (rank <= 3)
	self._rankCrown:setVisible(isTop3)
	self._rankLabel:setVisible(not isTop3)

	if isTop3 then
		self._rankCrown:loadTexture(RankCrownImages[rank])
	else
		self._rankLabel:setText(tostring(rank))
	end
end

function CrossWarRankItem:update(rank, data)
	if not data then return end
-- ############## SET COMMON INFO ##############
	local knightInfo = knight_info.get(data.main_role)
	self._uid = data.user_id
	self._sid = data.sid

	-- set rank icon or number
	self:_setRankNum(rank)

	-- set user name and server name
	self:showTextWithLabel("Label_UserName", data.name)
	self:getLabelByName("Label_UserName"):setColor(Colors.qualityColors[knightInfo.quality])
	
	local serverName = ""
	if data.sname == "" then
		serverName = G_lang:get("LANG_CROSS_WAR_SERVER_NO_REACTION")
	else
		serverName = "[" .. string.gsub(data.sname, "^.-%((.-)%)", "%1") .. "]"
	end
	self:showTextWithLabel("Label_ServerName", serverName)

	-- power value
	local power = G_GlobalFunc.ConvertNumToCharacter(data.fight_value)
	self:showTextWithLabel("Label_PowerNum", power)

	-- head icon
	local resID = knightInfo.res_id

	resID = G_Me.dressData:getDressedResidWithClidAndCltm(data.main_role, data.dress_id,
		rawget(data,"clid"),rawget(data,"cltm"),rawget(data,"clop"))

	self:getImageViewByName("Image_Head"):loadTexture(G_Path.getKnightIcon(resID))

	-- quality frame
	local qualityTex = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(qualityTex, UI_TEX_TYPE_PLIST)

	-- update board color
	local isSameID = tostring(data.user_id) == tostring(G_Me.userData.id)
	local isSameServer = tostring(data.sid) == tostring(G_PlatformProxy:getLoginServer().id)
	self:_updateBoardColor(isSameID and isSameServer)

-- ############## SET TYPE-RELATED INFO ##############
	if self._rankType == CrossWarCommon.RANK_SCORE then
		-- score and winning streak
		self:showTextWithLabel("Label_OtherNum", tostring(data.score))
		self:showTextWithLabel("Label_WinNum", tostring(data.max_wins))
	else
		-- follow rate
		self:showTextWithLabel("Label_OtherNum", tostring(data.follow))
	end
end

function CrossWarRankItem:_updateBoardColor(isMe)
	if isMe then
		self:getPanelByName("Root"):setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board_red.png", UI_TEX_TYPE_PLIST)
	else
		self:getPanelByName("Root"):setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board.png", UI_TEX_TYPE_PLIST)
	end
end

function CrossWarRankItem:_onTouchHead(widget, event)
	if event == TOUCH_EVENT_ENDED then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
		G_HandlersManager.crossWarHandler:sendGetPlayerTeam(self._sid, self._uid)
	end
end

function CrossWarRankItem:_onRcvPlayerTeam(data)
	if data.user_id == self._uid and data.sid == self._sid then
		local user = rawget(data, "user")
		if user ~= nil then
			local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
			uf_sceneManager:getCurScene():addChild(layer)
		end
	end

	uf_eventManager:removeListenerWithTarget(self)
end

return CrossWarRankItem