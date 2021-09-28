-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_warZoneCardShow = i3k_class("wnd_warZoneCardShow", ui.wnd_base)

-- 图鉴聊天分享展示界面
-- [eUIID_CardPacketChatInfo]	= {name = "cardPacketChatInfo", layout = "tujian4", order = eUIO_TOP_MOST,},
-------------------------------------------------------
function wnd_warZoneCardShow:ctor()

end

function wnd_warZoneCardShow:configure()
    local widgets = self._layout.vars
    widgets.close:onClick(self, self.onCloseUI)
    widgets.go:onClick(self, self.onGotoCard)
end

function wnd_warZoneCardShow:refresh(cardID, isGoTo)
    local widgets = self._layout.vars
    widgets.go:onClick(self, self.onGotoCard, cardID)
    self:setImage(cardID)
    self._layout.vars.go:setVisible(isGoTo)
    self._layout.anis.dk.play()
end

function wnd_warZoneCardShow:setImage(cardID)
    local widgets = self._layout.vars
    local cfg = i3k_db_war_zone_map_card[cardID]
    local coverImageID = i3k_db_war_zone_map_cfg.cardGrade[cfg.grade].gardeIcon
    widgets.cover:setImage(g_i3k_db.i3k_db_get_icon_path(coverImageID))
    widgets.image:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
    widgets.name:setText(cfg.name)
end

function wnd_warZoneCardShow:onGotoCard(sender, id)
    local roleLevel = g_i3k_game_context:GetLevel();
    if roleLevel >= i3k_db_war_zone_map_cfg.needLvl then
        i3k_sbean.global_world_sect_panel(function ()
            g_i3k_logic:OpenWarZoneCard(nil, id)
            g_i3k_ui_mgr:CloseUI(eUIID_WarZoneCardShow)
        end, true)
       
    else
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5770, i3k_db_war_zone_map_cfg.needLvl))
    end
end


function wnd_create(layout, ...)
	local wnd = wnd_warZoneCardShow.new()
	wnd:create(layout, ...)
	return wnd;
end
