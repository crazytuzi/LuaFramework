local CrossWarBetSelectItem = class("CrossWarBetSelectItem", function()
	return CCSItemCellBase:create("ui_layout/crosswar_BetSelectItem.json")
end)

function CrossWarBetSelectItem:ctor(betIndex, ...)
	self._betIndex = betIndex

	-- create strokes for some labels
	self:enableLabelStroke("Label_UserName", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Select", handler(self, self._onClickSelect))
	self:registerWidgetTouchEvent("Image_HeadBkg", handler(self, self._onTouchHead))
end

function CrossWarBetSelectItem:update(index)
	local betUser = G_Me.crossWarData:getBetUserInList(index)
	local knightInfo = knight_info.get(betUser.main_role)
	self._serverId = betUser.sid
	self._userId = betUser.user_id

	-- set user name and server name
	self:showTextWithLabel("Label_UserName", betUser.name)
	self:showTextWithLabel("Label_ServerName", "[" .. betUser.sname .. "]")
	self:getLabelByName("Label_UserName"):setColor(Colors.qualityColors[knightInfo.quality])

	-- head icon
	local resID = G_Me.dressData:getDressedResidWithClidAndCltm(betUser.main_role, betUser.dress_id,
		rawget(betUser,"clid"),rawget(betUser,"cltm"),rawget(betUser,"clop"))
	self:getImageViewByName("Image_Head"):loadTexture(G_Path.getKnightIcon(resID))

	-- quality frame
	local qualityTex = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(qualityTex, UI_TEX_TYPE_PLIST)

	-- fight value and follow rate
	local power = G_GlobalFunc.ConvertNumToCharacter(betUser.fight_value)
	self:showTextWithLabel("Label_Power_Num", power)
	self:showTextWithLabel("Label_Follow_Num", betUser.follow)

	-- if already bet as the same rank, disable the button
	local alreadyBetUser = G_Me.crossWarData:getBetUser(self._betIndex)
	local sameAsPrev = alreadyBetUser and alreadyBetUser.user_id == betUser.user_id and alreadyBetUser.sid == betUser.sid
	self:getButtonByName("Button_Select"):setTouchEnabled(not sameAsPrev)

	-- if already selected by me
	self._isSelected = betUser.betIndex and betUser.betIndex > 0
	self:showWidgetByName("Image_Selected", self._isSelected)
	self:showWidgetByName("Label_Selected", self._isSelected)
	if self._isSelected then
		self:showTextWithLabel("Label_Selected", G_lang:get("LANG_CROSS_WAR_BET_AS", {num = betUser.betIndex}))
	end

	if not sameAsPrev then 
		self:getButtonByName("Button_Select"):loadTextureNormal(self._isSelected and "btn-small-blue.png" or "btn-small-red.png", UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_Select"):loadTexture(G_Path.getSmallBtnTxt(self._isSelected and "genghuan_1.png" or "xuanze.png"))
	end

	-- update board color
	self:_updateBoardColor(betUser.user_id == G_Me.userData.id)
end

function CrossWarBetSelectItem:_updateBoardColor(isMe)
	if isMe then
		self:getPanelByName("Root"):setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board_red.png", UI_TEX_TYPE_PLIST)
	else
		self:getPanelByName("Root"):setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board.png", UI_TEX_TYPE_PLIST)
	end
end

function CrossWarBetSelectItem:_onClickSelect()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_BET_SOMEONE, self._onRcvBetSomeone, self)
	G_HandlersManager.crossWarHandler:sendBetSomeone(self._serverId, self._userId, self._betIndex)
end

function CrossWarBetSelectItem:_onTouchHead(widget, event)
	if event == TOUCH_EVENT_ENDED then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
		G_HandlersManager.crossWarHandler:sendGetPlayerTeam(self._serverId, self._userId)
	end
end

function CrossWarBetSelectItem:_onRcvPlayerTeam(data)
	if data.user_id == self._userId and data.sid == self._serverId then
		local user = rawget(data, "user")
		if user ~= nil then
			local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
			uf_sceneManager:getCurScene():addChild(layer)
		end
	end

	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarBetSelectItem:_onRcvBetSomeone()
	if self._isSelected then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_CHANGE_SUCCESS"))
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_SELECT_SUCCESS"))
	end
end

return CrossWarBetSelectItem