module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_jinlanShare = i3k_class("wnd_jinlanShare", ui.wnd_base)

function wnd_jinlanShare:ctor()
	
end

function wnd_jinlanShare:configure()
	self.ui = self._layout.vars
	self.ui.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_jinlanShare:refresh(id, names)
	self.ui.descTxt:setText(i3k_get_string(5504))
	self.ui.item2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.spanNeedId))
	self.ui.item1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.worldNeedId))
	self.ui.item1:onClick(self, function() g_i3k_ui_mgr:ShowCommonItemInfo(i3k_db_common.chat.worldNeedId) end)
	self.ui.item2:onClick(self, function() g_i3k_ui_mgr:ShowCommonItemInfo(i3k_db_common.chat.spanNeedId) end)
	self.ui.frame2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_common.chat.spanNeedId))
	self.ui.frame1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_common.chat.worldNeedId))
	self.ui.normalBtn:onClick(self, function() self:sendMsg(global_world, id, names) end)
	self.ui.superBtn:onClick(self, function() self:sendMsg(global_span, id, names) end)
end

function wnd_jinlanShare:checkSend(state)
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

function wnd_jinlanShare:checkTime(sendTime, limitTime)
	if sendTime == nil then
		return true
	end
	if i3k_game_get_time() - sendTime>=limitTime then
		return true
	end
	return false
end

function wnd_jinlanShare:sendMsg(state, id, names)
	if not self:checkSend(state) then
		return
	end
	local str = ""
	for _, v in ipairs(names) do
		str = str..','..v
	end
	str = string.format("#SR%s%s#", id, str)
	local b = i3k_sbean.msg_send_req.new()
	b.id = g_i3k_game_context:GetRoleId()
	b.msg = str
	b.type = state
	b.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	b.isShareJinlanCard = true
	i3k_game_send_str_cmd(b, "msg_send_res")
end

function wnd_create(layout)
	local wnd = wnd_jinlanShare.new()
	wnd:create(layout)
	return wnd
end
