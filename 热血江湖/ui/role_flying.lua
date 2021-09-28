-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_role_flying = i3k_class("wnd_role_flying", ui.wnd_base)

function wnd_role_flying:ctor()
	self._flyId = 1
	self._co = nil
end

function wnd_role_flying:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.flyBtn:onClick(self, self.onRoleFlyingBtn)
	for k = 1, 6 do
		self._layout.vars["btn"..k]:onClick(self, self.onFlyPositionBtn, k)
	end
end

function wnd_role_flying:refresh(id)
	self._flyId = id
	for k, v in ipairs(i3k_db_role_flying[id].flyPosId) do
		local flyPos = i3k_db_flying_position[v]
		self._layout.vars["name"..k]:setText(flyPos.name)
		if not g_i3k_game_context:isFinishFlyingPos(v) then
			self._layout.vars["icon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(flyPos.finished))
			self._layout.vars["findIcon"..k]:show()
			self._layout.vars["finishIcon"..k]:show()
		elseif not g_i3k_game_context:isFindFlyingPos(v) then
			self._layout.vars["icon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(flyPos.alreadyFind))
			self._layout.vars["findIcon"..k]:show()
			self._layout.vars["finishIcon"..k]:hide()
		else
			self._layout.vars["icon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(flyPos.notFind))
			self._layout.vars["findIcon"..k]:hide()
			self._layout.vars["finishIcon"..k]:hide()
		end
	end
	ui_set_hero_model(self._layout.vars.model, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
	if self:isFinishAllPos() then
		self._layout.vars.desc:setText(i3k_get_string(1688))
	else
		self._layout.vars.desc:setText(i3k_get_string(1687))
	end
end

function wnd_role_flying:onFlyPositionBtn(sender, posIndex)
	local id = i3k_db_role_flying[self._flyId].flyPosId[posIndex]
	g_i3k_ui_mgr:OpenUI(eUIID_RoleFlyingTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RoleFlyingTips, self._flyId, id)
end

function wnd_role_flying:onRoleFlyingBtn(sender)
	if self:isFinishAllPos() then
		i3k_sbean.soaring_task_finish(self._flyId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1691))
	end
end

function wnd_role_flying:isFinishAllPos()
	local flyData = g_i3k_game_context:getRoleFlyingData()
	if flyData and flyData[self._flyId] then
		for k, v in ipairs(i3k_db_role_flying[self._flyId].flyPosId) do
			if not (flyData[self._flyId].finishMaps and flyData[self._flyId].finishMaps[v]) then
				return false
			end
		end
	else
		return false
	end
	return true
end

function wnd_role_flying:finishFlyingHandler()
	self._layout.vars.flyBtn:disableWithChildren()
	for k = 1, 6 do
		self._layout.vars["btn"..k]:disableWithChildren()
	end
	ui_set_hero_model(self._layout.vars.model, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor(), nil, i3k_db_role_flying[self._flyId].finishAction)
	self:effectLinkChild(i3k_db_role_flying[self._flyId].finishEffect, 20, self._layout.vars.model)
	self._co = g_i3k_coroutine_mgr:StartCoroutine(function()
		g_i3k_coroutine_mgr.WaitForSeconds(i3k_db_role_flying[self._flyId].finishTimes/1000)
		g_i3k_logic:OpenMainUI(function()
			g_i3k_ui_mgr:OpenAndRefresh(eUIID_FeiSheng)
			g_i3k_ui_mgr:OpenAndRefresh(eUIID_FeishengAni)
		end)
	end)
end

function wnd_role_flying:onHide()
	if self._co then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
	end
end

function wnd_create(layout)
	local wnd = wnd_role_flying.new()
	wnd:create(layout)
	return wnd
end