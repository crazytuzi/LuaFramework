-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_creed = i3k_class("wnd_faction_creed", ui.wnd_base)

function wnd_faction_creed:ctor()

end


function wnd_faction_creed:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local sure_btn = self._layout.vars.sure_btn
	sure_btn:onTouchEvent(self,self.onModified)
	self.desc = self._layout.vars.desc
	self.desc:setMaxLength(i3k_db_common.inputlen.factionboardlen)
end

function wnd_faction_creed:onShow()

end

function wnd_faction_creed:refresh()
	self:updateText()
end

function wnd_faction_creed:updateText()
	self.desc:setText(g_i3k_game_context:GetFactionCreed())
end

function wnd_faction_creed:onModified(sender,eventType)
	if eventType == ccui.TouchEventType.ended then


		local text = self.desc:getText()
		local textcount = i3k_get_utf8_len(text)
		if textcount <= i3k_db_common.inputlen.factionboardlen then
			local data = i3k_sbean.sect_changecreed_req.new()
			data.creed = text
			i3k_game_send_str_cmd(data,i3k_sbean.sect_changecreed_res.getName())
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(351))
		end
		--g_i3k_ui_mgr:CloseUI(eUIID_FactionCreed)
	end
end

--[[function wnd_faction_creed:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionCreed)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_creed.new();
		wnd:create(layout, ...);

	return wnd;
end
