module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_jinlanMsg = i3k_class("wnd_jinlanMsg", ui.wnd_base)


function wnd_jinlanMsg:configure()
	self.ui = self._layout.vars
	self.ui.close:onClick(self, self.onCloseUI)
	--self.ui.msg:setMaxLength(self._maxWords * 2)
end

--#2成功发送时执行的回调(#1 修改后的寄语)
function wnd_jinlanMsg:refresh(message)
	self.ui.origin:setText(message or "")
	self.ui.got:setText(g_i3k_game_context:GetDiamondCanUse())
	self.ui.need:setText(i3k_db_sworn_system.msgChangeCost)
	self.ui.confirm:onClick(self, self.btn)
end
function wnd_jinlanMsg:btn()
		local giftMsg = self.ui.msg:getText()
		--local giftMsg = string.trim(giftMsg)
		local len = string.utf8len(giftMsg)
		if len == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5514))
			return
		end
		
	if len > i3k_db_common.inputlen.jinlanMaxMsgLen or len <= i3k_db_common.inputlen.jinlanMinMsgLen then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5524, i3k_db_common.inputlen.jinlanMinMsgLen, i3k_db_common.inputlen.jinlanMaxMsgLen + 1))
			return
		end

	if g_i3k_game_context:GetDiamondCanUse() < i3k_db_sworn_system.msgChangeCost then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15072))
			return
		end
		
	i3k_sbean.change_sworn_message(giftMsg)
end

function wnd_create(layout)
	local wnd = wnd_jinlanMsg.new()
	wnd:create(layout)
	return wnd
end
