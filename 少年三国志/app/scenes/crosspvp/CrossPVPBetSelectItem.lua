local CrossPVPBetSelectItem = class("CrossPVPBetSelectItem", function()
	return CCSItemCellBase:create("ui_layout/crosspvp_BetSelectItem.json")
end)

require("app.cfg.knight_info")

function CrossPVPBetSelectItem:ctor(callback)
	self._callback = callback
	self._data     = nil

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1)
	self:registerBtnClickEvent("Button_QualityFrame", handler(self, self._onClickHead))
	self:registerBtnClickEvent("Button_Select", handler(self, self._onClickSelect))
end

function CrossPVPBetSelectItem:update(data)
	self._data = data
	local knightInfo = knight_info.get(data.main_role)

	-- set head icon
	local resID = G_Me.dressData:getDressedResidWithClidAndCltm(data.main_role, data.dress_id,
		rawget(data,"clid"),rawget(data,"cltm"),rawget(data,"clop"))
	self:getImageViewByName("Image_Icon"):loadTexture(G_Path.getKnightIcon(resID))

	local qualityTex = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
	self:getButtonByName("Button_QualityFrame"):loadTextureNormal(qualityTex, UI_TEX_TYPE_PLIST)

	-- set name and server name
	local nameLabel = self:getLabelByName("Label_name")
	nameLabel:setText(data.name)
	nameLabel:setColor(Colors.qualityColors[knightInfo.quality])

	local serverName = data.sname == "" and G_lang:get("LANG_CROSS_WAR_SERVER_NO_REACTION")
										 or "[" .. string.gsub(data.sname, "^.-%((.-)%)", "%1") .. "]"
	self:showTextWithLabel("Label_ServerName", serverName)

	-- set last rank, flower num and egg num
	self:showTextWithLabel("Label_LastRank_Value", tostring(data.sp2))
	self:showTextWithLabel("Label_GetFlower_Value", tostring(data.sp3))
	self:showTextWithLabel("Label_GetEgg_Value", tostring(data.sp4))

	-- update board color
	local isSameID = tostring(data.id) == tostring(G_Me.userData.id)
	local isSameServer = tostring(data.sid) == tostring(G_PlatformProxy:getLoginServer().id)
	self:_updateBoardColor(isSameID and isSameServer)

	-- update bet state
	self:_updateBetState(data)
end

function CrossPVPBetSelectItem:_updateBetState(data)
	local stateImg = self:getImageViewByName("Image_State")
	local selButton = self:getButtonByName("Button_Select")

	-- get current betting target
	local flowerTarget = G_Me.crossPVPData:getFlowerTarget()
	local eggTarget = G_Me.crossPVPData:getEggTarget()

	-- compare current target with this item
	if flowerTarget and tostring(flowerTarget.id) == tostring(data.id)
					and tostring(flowerTarget.sid) == tostring(data.sid) then
		stateImg:setVisible(true)
		stateImg:loadTexture(G_Path.getTextPath("kfds_yixianhua.png"))
		selButton:setTouchEnabled(false)
		self:getImageViewByName("Image_Select"):showAsGray(true)
	elseif eggTarget and tostring(eggTarget.id) == tostring(data.id)
					  and tostring(eggTarget.sid) == tostring(data.sid) then
		stateImg:setVisible(true)
		stateImg:loadTexture(G_Path.getTextPath("kfds_yirendan.png"))
		selButton:setTouchEnabled(false)
		self:getImageViewByName("Image_Select"):showAsGray(true)
	else
		stateImg:setVisible(false)
		selButton:setTouchEnabled(true)
		self:getImageViewByName("Image_Select"):showAsGray(false)
	end
end

function CrossPVPBetSelectItem:_updateBoardColor(isMe)
	if isMe then
		self:getPanelByName("Root"):setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
		self:getPanelByName("Panel_Info"):setBackGroundImage("list_board_red.png", UI_TEX_TYPE_PLIST)
	else
		self:getPanelByName("Root"):setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
		self:getPanelByName("Panel_Info"):setBackGroundImage("list_board.png", UI_TEX_TYPE_PLIST)
	end
end

function CrossPVPBetSelectItem:_onClickHead()
	if self._data then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
		G_HandlersManager.crossWarHandler:sendGetPlayerTeam(self._data.sid, self._data.id)
	end
end

function CrossPVPBetSelectItem:_onClickSelect()
	if self._callback and self._data then
		self._callback(self._data)
	end
end

function CrossPVPBetSelectItem:_onRcvPlayerTeam(data)
	if data.user_id == self._data.id and data.sid == self._data.sid then
		local user = rawget(data, "user")
		if user ~= nil then
			local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
			uf_sceneManager:getCurScene():addChild(layer)
		end
	end

	uf_eventManager:removeListenerWithTarget(self)
end

return CrossPVPBetSelectItem