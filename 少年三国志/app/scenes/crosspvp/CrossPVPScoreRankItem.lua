local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local CrossPVPScoreRankItem = class("CrossPVPScoreRankItem", function()
	return CCSItemCellBase:create("ui_layout/crosspvp_ScoreRankItem.json")
end)


function CrossPVPScoreRankItem:ctor(showWinRate)
	self._showWinRate = showWinRate
	self._uid = nil
	self._sid = nil

	self:showWidgetByName("Label_WinRate", showWinRate)
	self:showWidgetByName("Label_WinRate_Value", showWinRate)

	self:registerBtnClickEvent("Button_QualityFrame", handler(self, self._onClickHead))
end

--[[
message CrossUser {
  required uint32 id = 1;
  required uint64 sid = 2;
  optional string name = 3;
  optional string sname = 4;
  optional uint32 dress_id = 5;
  optional uint32 main_role = 6;
  optional uint32 fight_value = 7;
  optional uint32 sp1 = 8;//特殊字段 前后端对应 模块内对应
  optional uint32 sp2 = 9;
  optional uint32 fight_pet = 10;//战宠
  optional uint32 level = 11;//等级 //这个后面补的 有些地方还是都需要等级的 之前有2个模块用了SP2字段作为等级
  optional uint32 fid = 12;//头像框
  optional uint32 vip = 13;//
}

]]

-- sp1积分， sp2排名
function CrossPVPScoreRankItem:updateItem(tRank, rank)
	if not tRank then
		return
	end
	
	-- 记下这个武将的ID
	self._uid = tRank.id
	self._sid = tRank.sid

	local nBaseId = tRank.main_role or 1
	local tKnightTmpl = knight_info.get(nBaseId) 
    if not tKnightTmpl then
    	return
    end

	local nQuality = tKnightTmpl.quality
	local szName = tRank.name
	local nServerId = tRank.sid
	local szServerName = tRank.sname
	local nScore = tRank.sp1
	local nUserId = tRank.id
	local nRank = rank

	-- 头像
	local nResId = G_Me.dressData:getDressedResidWithClidAndCltm(tRank.main_role, tRank.dress_id,
		rawget(tRank,"clid"),rawget(tRank,"cltm"),rawget(tRank,"clop"))
	CommonFunc._updateImageView(self, "ImageView_HeadIcon", {texture=G_Path.getKnightIcon(nResId)})
	-- 玩家名字
	CommonFunc._updateLabel(self, "Label_PlayerName", {text=szName, color=Colors.qualityColors[nQuality], stroke=Colors.strokeBrown})
	-- 玩家区服
	CommonFunc._updateLabel(self, "Label_ServerName", {text=szServerName})
	-- 玩家积分
	CommonFunc._updateLabel(self, "Label_Score_Value", {text=nScore})
	-- 排名
	self:_showCrown(nRank)

	-- 品质框
	local qualityTex = G_Path.getEquipColorImage(nQuality, G_Goods.TYPE_KNIGHT)
	self:getButtonByName("Button_QualityFrame"):loadTextureNormal(qualityTex, UI_TEX_TYPE_PLIST)

	-- 胜率
	if self._showWinRate then
		local percent = (tRank.sp5 or 0) / 10
		local str = string.format(percent == 100 and "%.0f%%" or "%.1f%%", percent)
		CommonFunc._updateLabel(self, "Label_WinRate_Value", {text=str})
	end

	-- 背景框
	local isSameID = tostring(tRank.id) == tostring(G_Me.userData.id)
	local isSameServer = tostring(tRank.sid) == tostring(G_PlatformProxy:getLoginServer().id)
	self:_updateBoardColor(isSameID and isSameServer)
end

function CrossPVPScoreRankItem:_showCrown(nRank)
	local imgCrown = self:getImageViewByName("Image_Rank")
	local labelRank = self:getLabelBMFontByName("BitmapLabel_Rank")
	if imgCrown then
		if nRank <=3 then
			imgCrown:loadTexture(G_Path.getRankCrownImage(nRank), UI_TEX_TYPE_LOCAL)
			imgCrown:setVisible(true)
		else
			imgCrown:setVisible(false)
		end
	end
	if labelRank then
		labelRank:setText(nRank)
		labelRank:setVisible(nRank > 3)
	end
end

function CrossPVPScoreRankItem:_updateBoardColor(isMe)
	if isMe then
		self:getPanelByName("Root"):setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
	else
		self:getPanelByName("Root"):setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
	end
end

function CrossPVPScoreRankItem:_onClickHead()
	if self._sid and self._uid then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
		G_HandlersManager.crossWarHandler:sendGetPlayerTeam(self._sid, self._uid)
	end
end

function CrossPVPScoreRankItem:_onRcvPlayerTeam(data)
	if data.user_id == self._uid and data.sid == self._sid then
		local user = rawget(data, "user")
		if user ~= nil then
			local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
			uf_sceneManager:getCurScene():addChild(layer)
		end
	end

	uf_eventManager:removeListenerWithTarget(self)
end

return CrossPVPScoreRankItem