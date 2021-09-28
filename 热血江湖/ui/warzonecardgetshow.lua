
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_warZoneCardGetShow = i3k_class("wnd_warZoneCardGetShow", ui.wnd_base)

local TIME = 4
-------------------------------------------------------
function wnd_warZoneCardGetShow:ctor()

end

function wnd_warZoneCardGetShow:configure()
  self._curtime = TIME
  self._isPlay = false
  self._curIndex = false
end

function wnd_warZoneCardGetShow:refresh(cardID)
    self:setImage(cardID)
    self._layout.anis.dk.play()
end

function wnd_warZoneCardGetShow:setImage(cardID)
    local widgets = self._layout.vars
    local cfg = i3k_db_war_zone_map_card[cardID]
    local coverImageID = i3k_db_war_zone_map_cfg.cardGrade[cfg.grade].gardeIcon
    widgets.cover:setImage(g_i3k_db.i3k_db_get_icon_path(coverImageID))
    widgets.image:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
    widgets.name:setText(cfg.name)
end

function wnd_warZoneCardGetShow:onUpdate(dTime)
	self._curtime = self._curtime + dTime
	if self._curtime >= TIME then
		self:SetPopTips()
	end 
	
end

function  wnd_warZoneCardGetShow:SetPopTips()
	if self._curIndex then
		g_i3k_game_context:removeWarZoneCardTip()
	end
	local curTipsId = g_i3k_game_context:getWarZoneCardTip()
	if not curTipsId then
		g_i3k_ui_mgr:CloseUI(eUIID_WarZoneCardGetShow)
	else
		self._curIndex = curTipsId
		self:setImage(curTipsId)
    	self._layout.anis.dk.play()
	end
	self._curtime = 0
    self._isPlay = true
end
function wnd_warZoneCardGetShow:onHide()
	g_i3k_game_context:clearWarZoneCardTip()
end

function wnd_create(layout, ...)
	local wnd = wnd_warZoneCardGetShow.new()
	wnd:create(layout, ...)
	return wnd;
end