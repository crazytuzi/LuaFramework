-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_cardPacketShow = i3k_class("wnd_cardPacketShow", ui.wnd_base)

-- 图鉴解锁卡牌展示
-- [eUIID_CardPacketShow]	= {name = "cardPacketShow", layout = "tujian2", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_cardPacketShow:ctor()

end

function wnd_cardPacketShow:configure()
	self:setButtons()
end

function wnd_cardPacketShow:setButtons()
	local widgets = self._layout.vars
	widgets.unlock:onClick(self, self.onunlockBtn)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_cardPacketShow:refresh(cardID)
	local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(cardID)
	self._cardID = cardID
	self:setLabels(cardID)
	self:setImages(cfg.imageID, cfg.coverImageID)
	self:checkButtonVisable(cfg)
end


function wnd_cardPacketShow:setImages(imageID, backID)
	local widgets = self._layout.vars
	widgets.back:setImage(g_i3k_db.i3k_db_get_icon_path(backID))
	widgets.image:setImage(g_i3k_db.i3k_db_get_icon_path(imageID))
	widgets.cover:hide()
end

function wnd_cardPacketShow:setLabels(cardID)
	local text = g_i3k_db.i3k_db_cardPacket_get_unlock_desc(cardID)
	local widgets = self._layout.vars
	widgets.name:setText(text)
end

function wnd_cardPacketShow:onunlockBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_CardPacketUnlock)
	g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketUnlock, g_CARD_PACKET.UNLOCK_CARD, self._cardID)
end

function wnd_cardPacketShow:checkButtonVisable(cfg)
	local widgets = self._layout.vars
	if cfg.type == g_CARD_PACKET.UNLOCK_TYPE_ITEM then
		widgets.unlock:show()
	else
		widgets.unlock:hide()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_cardPacketShow.new()
	wnd:create(layout, ...)
	return wnd;
end
