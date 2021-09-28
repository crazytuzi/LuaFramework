local CrossPVPFieldItem = class("CrossPVPFieldItem", UFCCSNormalLayer)

local FLAG_IMG = { "ui/crosspvp/bg_chujizhanchang.png",
				   "ui/crosspvp/bg_zhongjizhanchang.png",
				   "ui/crosspvp/bg_gaojizhanchang.png",
				   "ui/crosspvp/bg_zhizunzhanchang.png" }

local FIELD_NAME = { "kfds-chujizhanchang.png",
					 "kfds-zhongjizhanchang.png",
					 "kfds-gaojizhanchang.png",
					 "kfds-zhizunzhanchang.png"}

local WATCH_COUNT_MAX = 100

function CrossPVPFieldItem.create(battleField, ...)
	return CrossPVPFieldItem.new("ui_layout/crosspvp_FieldItem.json", nil, battleField, ...)
end

function CrossPVPFieldItem:ctor(json, param, battleField, ...)
	self.super.ctor(self, json, param, ...)

	self._battleField = battleField

	self._nRound = 0
	self._nRoomId = 0

	self:_initWidgets()
end

function CrossPVPFieldItem:onLayerEnter()

end

function CrossPVPFieldItem:onLayerExit()
	-- body
end

function CrossPVPFieldItem:_initWidgets()
	-- 旗子
	local imgFlag = self:getImageViewByName("Image_Flag")
	if imgFlag then
        imgFlag:loadTexture(FLAG_IMG[self._battleField])
	end
	-- 战场名称
	local fieldName = FIELD_NAME[self._battleField]
	local imgField = self:getImageViewByName("Image_BattleField")
	if imgField then
        imgField:loadTexture(G_Path.getTextPath(fieldName))
	end

	self:attachImageTextForBtn("Button_Observe", "Image_32")

	self:registerBtnClickEvent("Button_Observe", handler(self, self._onClickObserve))
end

function CrossPVPFieldItem:_onClickObserve()
	-- 如果没有网络，就弹出断线重联界面，并且不进入观战界面
	if not G_NetworkManager:isConnected() then
		G_NetworkManager:checkConnection()
	    return
	end

	if self._nRound ~= 0 and self._nRoomId ~= 0 then
		if G_Me.crossPVPData:hasObRight() then
			G_Me.crossPVPData:setObStage(self._battleField)
			G_Me.crossPVPData:setObRoom(self._nRoomId)

			-- 有ob权限，进入观战
			local curScene = uf_sceneManager:getCurScene()
			if curScene._goToLayer then
				curScene:_goToLayer("CrossPVPFightMainLayer")
			end
		else
			G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_HAS_NO_OB_RIGHT"))
		end
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_HAS_NO_OB_RIGHT"))
	end
end

function CrossPVPFieldItem:onClick()
  

end

--[[
message CrossPvpObInfo {
	required uint32 stage = 1;//哪个场次
	required uint32 round = 2;//哪轮 海选 OR 1024...
	required uint32 room_id = 3;//房间IDe
}

]]

function CrossPVPFieldItem:updateObButton(tData)
	if tData.has_ob then
		G_Me.crossPVPData:setHasObRight(true)
		for key, val in pairs(tData.rooms) do
			if val.stage == self._battleField then
				self._nRound = val.round
				self._nRoomId = val.room_id
				break
			end
		end
	else
		self:getButtonByName("Button_Observe"):showAsGray(true)
		self:getImageViewByName("Image_32"):showAsGray(true)
	end
end

return CrossPVPFieldItem