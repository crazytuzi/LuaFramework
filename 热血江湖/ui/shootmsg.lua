-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_shootMsg = i3k_class("wnd_shootMsg", ui.wnd_base)

--弹幕规则限制
local nameCountTable = {
	[g_SHOOT_MSG_TYPE_FACTION] = {worldMax = i3k_db_common.shootMsg.worldMax, wordMin = i3k_db_common.shootMsg.wordMin},
	[g_SHOOT_MSG_TYPE_HEGEMONY] = {worldMax = i3k_db_five_contend_hegemony.shootMsg.worldMax, wordMin = i3k_db_five_contend_hegemony.shootMsg.wordMin}
}
function wnd_shootMsg:ctor()
end

function wnd_shootMsg:configure()
    self._layout.vars.cancel:onClick(self, self.onCloseUI)
end
function wnd_shootMsg:refresh(shootType, arg)
    ---帮派弹幕格式匹配规则
    self._layout.vars.ok:onClick(
        self,
        function()
            local content = self._layout.vars.content:getText()
            local namecount = i3k_get_utf8_len(content)

            if namecount > nameCountTable[shootType].worldMax then
                g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16967, nameCountTable[shootType].worldMax))
                return
            end

            if namecount < nameCountTable[shootType].wordMin then
                g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16966, nameCountTable[shootType].wordMin))
                return
            end

            if not g_i3k_game_context:isCanSendShootMsg(shootType) then
                g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16969))
                return
            end
            if shootType == g_SHOOT_MSG_TYPE_HEGEMONY then
				i3k_sbean.five_hegemony_send_barrage(content, arg)
			elseif shootType == g_SHOOT_MSG_TYPE_FACTION then
				i3k_sbean.request_sect_popmsg_add_req(content)
			end
            
        end
    )
	if shootType == g_SHOOT_MSG_TYPE_FACTION then
    local myMsg = g_i3k_game_context:getMyShootMSg()
    if myMsg then
        self._layout.vars.content:setText(myMsg)
		end
	end
end
function wnd_create(layout, ...)
    local wnd = wnd_shootMsg.new()
    wnd:create(layout, ...)
    return wnd
end
