-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_cardPacketBack = i3k_class("wnd_cardPacketBack", ui.wnd_base)

-- 图鉴卡背
-- [eUIID_CardPacketBack]	= {name = "cardPacketBack", layout = "tujiankb", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_cardPacketBack:ctor()

end

function wnd_cardPacketBack:configure()
	self:setButtons()
end

function wnd_cardPacketBack:refresh()
	self:setScrolls()
end

function wnd_cardPacketBack:onUpdate(dTime)

end

function wnd_cardPacketBack:onShow()
	local cur = g_i3k_game_context:getCurCardBack()
end


function wnd_cardPacketBack:setImages()
	local widgets = self._layout.vars
	--	widgets.notice_info:setImage()
end

function wnd_cardPacketBack:setScrolls()
	local widgets = self._layout.vars
	local cfg = i3k_db_cardPacket_cardBack
	self:setScroll_scroll(cfg)
end


-- TODO
function wnd_cardPacketBack:setScroll_scroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/tujiankbt")()
		local cfg = v
		ui.vars.image:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageID))
		ui.vars.name:setText(v.name)

		local isUnlocked = g_i3k_game_context:getCardBackUnlock(cfg.id)
		if not isUnlocked then
			ui.vars.unlockBtn:show()
			ui.vars.useBtn:hide()
			ui.vars.unlockBtn:onClick(self, self.onUnlockBtn, cfg.id)
			local canUnlock = g_i3k_game_context:checkCardPacketBackCanUnlock(k)
			ui.vars.lockRed:setVisible(canUnlock) -- 解锁红点 TODO
		else
			ui.vars.unlockBtn:hide()
			ui.vars.useBtn:show()
			ui.vars.useBtn:onClick(self, self.onUseBtn, cfg.id)
			if g_i3k_game_context:getCurCardBack() == cfg.id then
				ui.vars.useBtn:disableWithChildren()
				ui.vars.useText:setText("使用中")
			end
		end
		scroll:addItem(ui)
	end
end

function wnd_cardPacketBack:onUnlockBtn(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_CardPacketUnlock)
	g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketUnlock, g_CARD_PACKET.UNLOCK_CARD_BACK, id)
end


function wnd_cardPacketBack:onUseBtn(sender, id)
	i3k_sbean.selectCardBack(id)
end

function wnd_cardPacketBack:setButtons()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.oncloseBtn)
end

function wnd_cardPacketBack:oncloseBtn(sender)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_cardPacketBack.new()
	wnd:create(layout, ...)
	return wnd;
end
