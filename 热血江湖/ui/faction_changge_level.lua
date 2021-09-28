-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_changge_level = i3k_class("wnd_faction_changge_level", ui.wnd_base)

local _LEVEL=i3k_db_common.faction.addLevel

local _MAX_LEVEL
local _MIN_LEVEL

function wnd_faction_changge_level:ctor()
	self.text = ""
end

function wnd_faction_changge_level:configure(...)
	--self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	local jian_btn = self._layout.vars.jian_btn
	jian_btn:onTouchEvent(self,self.onJian)

	local jia_btn = self._layout.vars.jia_btn
	jia_btn:onTouchEvent(self,self.onJia)

	local cancel_btn = self._layout.vars.cancel_btn
	cancel_btn:onTouchEvent(self,self.onCancel)

	self._layout.vars.superBtn:onClick(self, self.onSendmessage, 1)
	
	self._layout.vars.normalBtn:onClick(self, self.onSendmessage, 0)

	_MAX_LEVEL = #i3k_db_exp-2
	_MIN_LEVEL = i3k_db_common.faction.addLevel
	local level_label = self._layout.vars.level_label
	level_label:setText(_LEVEL)
	level_label:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	level_label:addEventListener(function(eventType)
		if eventType == "ended" then
		    local str = tonumber(level_label:getText()) or _MIN_LEVEL
		    if str < _MIN_LEVEL then
		    	str = _MIN_LEVEL
		    elseif str > _MAX_LEVEL then
		    	str = _MAX_LEVEL
		    end
			if str > g_edit_box_max then
				str = g_edit_box_max
			end
			if str < 1 then
				str = 1
			end
		    _LEVEL = str
		    level_label:setText(_LEVEL)
		end
	end)
	local editBox = self._layout.vars.editBox
	editBox:setMaxLength(i3k_db_common.chat.descLen)
	editBox:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = editBox:getText()
			if str ~= "" then
				self._layout.vars.rule:setText(str)
				editBox:setText("")
			else
				self._layout.vars.rule:setText(string.format("招募宣言（最多输入%s字）", i3k_db_common.chat.descLen))
			end
			self.text = str
		end
	end)
end

function wnd_faction_changge_level:refresh()
	local widget = self._layout.vars
	widget.item1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.commonConsume.id))
	widget.suo1:setVisible(i3k_db_common.chat.commonConsume.id > 0)
	widget.count1:setText(i3k_db_common.chat.commonConsume.count)
	widget.item2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.chat.superConsume.id))
	widget.suo2:setVisible(i3k_db_common.chat.superConsume.id > 0)
	widget.count2:setText(i3k_db_common.chat.superConsume.count)
	self:initialManifesto()
end

function wnd_faction_changge_level:initialManifesto()
	local cfg = g_i3k_game_context:GetUserCfg()
	local desc = self._layout.vars.rule
	local text = cfg:GetRecruitManifesto()
	if text ~= "" then
		desc:setText(text)
		self.text = text
	else
		desc:setText(string.format("招募宣言（最多输入%s字）", i3k_db_common.chat.descLen))
	end
end

function wnd_faction_changge_level:onJian(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		_LEVEL = _LEVEL - 1
		if _LEVEL <= _MIN_LEVEL then
			_LEVEL = _MIN_LEVEL
		end
		if _LEVEL < 1 then
			_LEVEL = 1
		end
		local level_label = self._layout.vars.level_label
		level_label:setText(_LEVEL)
	end
end

function wnd_faction_changge_level:onJia(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		_LEVEL = _LEVEL + 1
		if _LEVEL >= _MAX_LEVEL then
			_LEVEL = _MAX_LEVEL
		end
		local level_label = self._layout.vars.level_label
		if _LEVEL > g_edit_box_max then
			_LEVEL = g_edit_box_max
		end
		level_label:setText(_LEVEL)
	end
end

function wnd_faction_changge_level:onCancel(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionChangeLevel)
	end
end

function wnd_faction_changge_level:onSendmessage(sender, recruitType)
	if self.text == "" then
		g_i3k_ui_mgr:PopupTipMessage("留言不能为空")
		return
	elseif i3k_get_utf8_len(self.text) > i3k_db_common.chat.descLen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16946, i3k_db_common.chat.descLen))
		return
	end
	if recruitType == 0 then
		if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_common.chat.commonConsume.id) < i3k_db_common.chat.commonConsume.count then
			g_i3k_ui_mgr:PopupTipMessage("所需物品不足")
			return
		end
	else
		if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_common.chat.superConsume.id) < i3k_db_common.chat.superConsume.count then
			g_i3k_ui_mgr:PopupTipMessage("所需物品不足")
			return
		end
	end
	local factionId = g_i3k_game_context:GetFactionSectId()
	local name = g_i3k_game_context:GetFactionName()
	local msg = string.format("#S%s,%s,%s,%s#", factionId, name, recruitType, self.text)
	local callbackFunc = function(ok)
		if ok then
			local func = function()
				local send = i3k_sbean.msg_send_req.new()
				send.type = global_world
				send.id = g_i3k_game_context:GetRoleId()
				send.msg = msg
				send.callback = function()
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionChangeLevel, "sendMessageSuccess", recruitType)
				end
				send.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
				i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
			end
			local data = i3k_sbean.sect_joinlvl_req.new()
			data.level = _LEVEL
			data.callback = func
			i3k_game_send_str_cmd(data, i3k_sbean.sect_joinlvl_res.getName())
		end
	end
	local consumeStr = ""
	if recruitType == 0 then
		consumeStr = string.format("%s绑定铜钱", i3k_db_common.chat.commonConsume.count)
	else
		consumeStr = string.format("%s元宝", i3k_db_common.chat.superConsume.count)
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16911, consumeStr), callbackFunc)
end

function wnd_faction_changge_level:sendMessageSuccess(recruitType)
	g_i3k_ui_mgr:PopupTipMessage("发送成功")
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetRecruitManifesto(self.text)
	if recruitType == 0 then
		g_i3k_game_context:UseCommonItem(i3k_db_common.chat.commonConsume.id, i3k_db_common.chat.commonConsume.count, AT_USE_CHAT_ITEM)
	else
		g_i3k_game_context:UseCommonItem(i3k_db_common.chat.superConsume.id, i3k_db_common.chat.superConsume.count, AT_USE_CHAT_ITEM)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_FactionChangeLevel)
end
function wnd_create(layout, ...)
	local wnd = wnd_faction_changge_level.new();
		wnd:create(layout, ...);
	return wnd;
end
