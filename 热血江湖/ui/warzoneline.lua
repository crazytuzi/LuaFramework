-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_warZoneLine = i3k_class("wnd_warZoneLine",ui.wnd_base)

function wnd_warZoneLine:ctor()
	self._lineType = 0 -- 1 和平 2 乱斗
	self._mapID = 0
end

function wnd_warZoneLine:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)

	self._typePageWidget = { 
		{btn = widgets.peacePage, icon = widgets.peaceIcon},
		{btn = widgets.fightPage, icon = widgets.fightIcon},
	}
	for i, e in ipairs(self._typePageWidget) do
		e.btn:onClick(self, self.onTypeChange, i)
	end
end

function wnd_warZoneLine:refresh(worlds)
	self._worlds = worlds
	if self._lineType == 0 then
		local fightType = g_i3k_game_context:getGoldCoastMapType()
		self:changeType(fightType)
	else
		self:loadScroll()
	end
end

function wnd_warZoneLine:loadScroll()
	local mapID = i3k_db_war_zone_map_type[self._lineType].mapID
	local maxNumber = i3k_db_war_zone_map_fb[mapID].maxNumber
	local worldMapID = g_i3k_game_context:GetWorldMapID()
	local curLine = g_i3k_game_context:GetCurrentLine()
	self._mapID = mapID
	if self._worlds[mapID] then
		local linesInfo = self._worlds[mapID].lines
		self._layout.vars.scroll:removeAllChildren()
		for _, e in ipairs(linesInfo) do
			local node = require("ui/widgets/hjhahxt")()
			local line = e.line % 10000
			local txtID = self._lineType == g_GOLD_COAST_PEACE and 5782 or 5783
			node.vars.lineName:setText(i3k_get_string(txtID, line))
			node.vars.lineDesc:setVisible(e.roleCnt >= maxNumber)
			if e.roleCnt >= maxNumber or (worldMapID == mapID and curLine == e.line) then
				node.vars.enterBtn:disableWithChildren()
			end
			node.vars.enterBtn:onClick(self, self.onChnageLine, e.line)
			self._layout.vars.scroll:addItem(node)
		end
	end
end

function wnd_warZoneLine:onTypeChange(sender, lineType)
	self:changeType(lineType)
end

-- 类型按钮页签状态 点击 正常 icon
local typeStateIcon = {
	[g_GOLD_COAST_PEACE] = {9444, 9445},
	[g_GOLD_COAST_FIGHT] = {9446, 9447},
}

function wnd_warZoneLine:changeType(lineType)
	if self._lineType ~= lineType then
		self._lineType = lineType
		self:loadScroll()
		for i, e in ipairs(self._typePageWidget) do
			local iconCfg = typeStateIcon[i]
			local iconID = lineType == i and iconCfg[1] or iconCfg[2]
			e.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
			e.btn[lineType == i and "stateToPressed" or "stateToNormal"](e.btn)
		end
	end
end

function wnd_warZoneLine:onChnageLine(sender, line)
	if not g_i3k_game_context:IsInFightTime() then --战斗状态下不能换线
		local mapID = self._mapID
		local function callBackFunc()
			i3k_sbean.global_world_change(mapID, line)
		end
		g_i3k_logic:OpenWorldLineProcessBarUI(callBackFunc)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(537))
	end
end

function wnd_create(layout)
	local wnd = wnd_warZoneLine.new()
	wnd:create(layout)
	return wnd
end
