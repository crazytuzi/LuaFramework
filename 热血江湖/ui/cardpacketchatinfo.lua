-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_cardPacketChatInfo = i3k_class("wnd_cardPacketChatInfo", ui.wnd_base)

-- 图鉴聊天分享展示界面
-- [eUIID_CardPacketChatInfo]	= {name = "cardPacketChatInfo", layout = "tujian4", order = eUIO_TOP_MOST,},
-------------------------------------------------------
function wnd_cardPacketChatInfo:ctor()

end

function wnd_cardPacketChatInfo:configure()
    local widgets = self._layout.vars
    widgets.close:onClick(self, self.onCloseUI)
end

function wnd_cardPacketChatInfo:refresh(cardID, cardBackID)
    self:setImage(cardID, cardBackID)
    self._layout.anis.dk.play()
end

function wnd_cardPacketChatInfo:setImage(cardID, cardBackID)
    local widgets = self._layout.vars
    local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(cardID)
    widgets.image:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageID))
    widgets.cover:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.coverImageID))
    local backCfg = g_i3k_db.i3k_db_cardPacket_get_card_back_cfg(cardBackID)
    -- widgets.back:setImage(g_i3k_db.i3k_db_get_icon_path(backCfg.imageID))
end



function wnd_create(layout, ...)
	local wnd = wnd_cardPacketChatInfo.new()
	wnd:create(layout, ...)
	return wnd;
end
