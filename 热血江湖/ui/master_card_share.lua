-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_master_card_share = i3k_class("wnd_master_card_share", ui.wnd_base)

function wnd_master_card_share:ctor()
	self._masterId = 0
end

function wnd_master_card_share:configure()
	local widgets = self._layout.vars
	widgets.item1:onClick(self, self.onClickItem, i3k_db_common.chat.worldNeedId)
	widgets.item2:onClick(self, self.onClickItem, i3k_db_common.chat.spanNeedId)
	widgets.normalBtn:onClick(self, self.sendMsg, global_world)
	widgets.superBtn:onClick(self, self.sendMsg, global_span)
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_master_card_share:refresh(masterId)
	self._masterId = masterId
	local widgets = self._layout.vars
	widgets.descTxt:setText(i3k_get_string(5503))
	widgets.item2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.spanNeedId))
	widgets.item1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.worldNeedId))
	widgets.frame2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_common.chat.spanNeedId))
	widgets.frame1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_common.chat.worldNeedId))
end

function wnd_master_card_share:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_master_card_share:sendMsg(sender, state)
	if not self:checkSend(state) then
		return
	end
	local send = i3k_sbean.msg_send_req.new()
	send.type = state
	send.id = math.abs(g_i3k_game_context:GetRoleId())
	send.msg = string.ltrim(string.format("#MC%d,%s#", self._masterId, g_i3k_game_context:GetRoleName()))
	send.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
	self:onCloseUI()
end

function wnd_master_card_share:checkSend(state)
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

function wnd_master_card_share:checkTime(sendTime, limitTime)
	if not sendTime then
		return true
	end
	if i3k_game_get_time() - sendTime >= limitTime then
		return true
	end
	return false
end

function wnd_create(layout)
	local wnd = wnd_master_card_share.new()
	wnd:create(layout)
	return wnd
end
