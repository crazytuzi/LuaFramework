-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_role_flying_tips = i3k_class("wnd_role_flying_tips", ui.wnd_base)

function wnd_role_flying_tips:ctor()
	self._flyId = 1
	self._mapId = 0
end

function wnd_role_flying_tips:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.findwayBtn:onClick(self, self.onFindWayBtn)
end

function wnd_role_flying_tips:refresh(flyId, mapId)
	self._flyId = flyId
	self._mapId = mapId
	self._layout.vars.name:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_flying_position[mapId].title))
	self._layout.vars.desc:setText(i3k_db_flying_position[mapId].desc)
	local flyingData = g_i3k_game_context:getRoleFlyingData()
	if flyingData and flyingData[flyId] then
		if flyingData[flyId].finishMaps and flyingData[flyId].finishMaps[mapId] then
			self._layout.vars.stateText:setText(i3k_get_string(1682))
			self._layout.vars.stateText:setTextColor("ff31f9c7")
			self._layout.vars.stateText:enableOutline("ff0a6f5b")
			self._layout.vars.findwayBtn:hide()
			self._layout.vars.finishText:hide()
		elseif flyingData[flyId].roadMaps and flyingData[flyId].roadMaps[mapId] then
			self._layout.vars.stateText:setText(i3k_get_string(1681))
			self._layout.vars.stateText:setTextColor("ffff993e")
			self._layout.vars.stateText:enableOutline("ffbb342d")
			self._layout.vars.findwayBtn:show()
			self._layout.vars.findText:setText(i3k_get_string(1696))
			self._layout.vars.finishText:hide()
			--self._layout.vars.finishText:setText(i3k_get_string(1683))
		else
			self._layout.vars.stateText:setText(i3k_get_string(1680))
			self._layout.vars.stateText:setTextColor("ffff8392")
			self._layout.vars.stateText:enableOutline("ffbb342d")
			self._layout.vars.findwayBtn:hide()
			self._layout.vars.finishText:show()
			self._layout.vars.finishText:setText(i3k_get_string(1683))
		end
	end
end

function wnd_role_flying_tips:onFindWayBtn(sender)
	local position = i3k_db_at_any_moment[self._mapId].position
	local point = {x = position[1], y = position[2],z = position[3]}
	local transport = {flage = 6, mapId = i3k_db_at_any_moment[self._mapId].mapId, areaId = self._mapId}
	g_i3k_game_context:SeachPathWithMap(i3k_db_at_any_moment[self._mapId].mapId, point, nil, nil, transport)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleFlying)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleFlyingTips)
end

function wnd_create(layout)
	local wnd = wnd_role_flying_tips.new()
	wnd:create(layout)
	return wnd
end