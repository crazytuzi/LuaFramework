
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_shareMarriageCard = i3k_class("wnd_shareMarriageCard",ui.wnd_base)

function wnd_shareMarriageCard:ctor()
	self.msg = ""
end

function wnd_shareMarriageCard:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_shareMarriageCard:refresh(msg)
	self.msg = msg
	
	local widgets = self._layout.vars
	widgets.item2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.spanNeedId))
	widgets.item1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.worldNeedId))
	widgets.item1:onClick(self, self.onClickItem, i3k_db_common.chat.worldNeedId)
	widgets.item2:onClick(self, self.onClickItem, i3k_db_common.chat.spanNeedId)
	widgets.frame2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_common.chat.spanNeedId))
	widgets.frame1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_common.chat.worldNeedId))
	widgets.normalBtn:onClick(self, self.sendMsg, global_world)
	widgets.superBtn:onClick(self, self.sendMsg, global_span)
end

function wnd_shareMarriageCard:checkSend(state)
	local canSend = false
	local chatCfg = i3k_db_common.chat
	if state == global_span then--大喇叭
		canSend = self:checkTime(g_i3k_game_context:GetSpanSendTime(), chatCfg.timeSpan)
		local vipLvl = g_i3k_game_context:GetVipLevel()
		if g_i3k_game_context:GetVipLevel() < chatCfg.isOpenSpanLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(790, chatCfg.isOpenSpanLvl))
			return false
		end

		if g_i3k_game_context:GetCommonItemCanUseCount(chatCfg.spanNeedId) <= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(791))  --真言道具
			return false
		end

	elseif state == global_world then
		canSend = self:checkTime(g_i3k_game_context:GetWorldSendTime(), chatCfg.timeWorld)
		if g_i3k_game_context:GetCommonItemCanUseCount(chatCfg.worldNeedId) <= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(137, g_i3k_db.i3k_db_get_common_item_name(chatCfg.worldNeedId)))
			return false
		end
	end
	if not canSend then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
	end
	
	return canSend
end

function wnd_shareMarriageCard:checkTime(sendTime, limitTime)
	if sendTime == nil then
		return true
	end
	if i3k_game_get_time() - sendTime>=limitTime then
		return true
	end
	return false
end

function wnd_shareMarriageCard:sendMsg(sender, state)
	if not self:checkSend(state) then
		return
	end
	local send = i3k_sbean.msg_send_req.new()
	send.type = state
	send.id = math.abs(g_i3k_game_context:GetRoleId())
	send.msg = string.ltrim(self.msg)
	send.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16910))
	self:onCloseUI()
end

function wnd_shareMarriageCard:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_shareMarriageCard.new()
	wnd:create(layout, ...)
	return wnd;
end

