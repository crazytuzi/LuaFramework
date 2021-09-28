
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_tripWizardSharePhoto = i3k_class("wnd_tripWizardSharePhoto",ui.wnd_base)

function wnd_tripWizardSharePhoto:ctor()
	self._msg = nil
	self._index = nil;
end

function wnd_tripWizardSharePhoto:configure()
	local widgets = self._layout.vars
	self.descTxt = widgets.descTxt
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_tripWizardSharePhoto:refresh(msg, index)
	self._msg = msg;
	self._index = index;
	self.descTxt:setText(i3k_get_string(17076))
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

function wnd_tripWizardSharePhoto:checkSend(state)
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

function wnd_tripWizardSharePhoto:checkTime(sendTime, limitTime)
	if sendTime == nil then
		return true
	end
	if i3k_game_get_time() - sendTime>=limitTime then
		return true
	end
	return false
end

function wnd_tripWizardSharePhoto:sendMsg(sender, state)
	if not self:checkSend(state) then
		return
	end
	if self._msg and #self._msg > 0 then
		i3k_sbean.wizardTripSharePhoto(state, self._index,i3k_game_get_server_name(i3k_game_get_login_server_id()), self._msg)
	end
end

function wnd_tripWizardSharePhoto:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_tripWizardSharePhoto.new()
	wnd:create(layout, ...)
	return wnd;
end

