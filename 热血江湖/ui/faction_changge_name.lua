-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_changge_name = i3k_class("wnd_faction_changge_name", ui.wnd_base)

function wnd_faction_changge_name:ctor()

end

function wnd_faction_changge_name:configure(...)
	local cancel_btn  = self._layout.vars.cancel_btn
	if cancel_btn then
		cancel_btn:onTouchEvent(self,self.onCancel)
	end

	local changge_btn = self._layout.vars.changge_btn
	changge_btn:onTouchEvent(self,self.onChangeBtn)

	self._layout.vars.input_label:setMaxLength(i3k_db_common.inputlen.factionlen)
end

function wnd_faction_changge_name:onShow()
	local needGold = i3k_db_common.faction.update_faction_name
	self._layout.vars.countLabel:setText("x"..needGold)

	if self:isHaveNameCard() then
		self:setNameCardUI()
	end
end

function wnd_faction_changge_name:onCancel(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionChangeName)
	end
end

function wnd_faction_changge_name:onChangeBtn(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		local input_label = self._layout.vars.input_label
		local text = input_label:getText()
		local error_code,desc = g_i3k_name_rule(text)
		if error_code ~= 1 then
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return
		end
		if not self:isHaveNameCard() then
			local needGold = i3k_db_common.faction.update_faction_name
			local totalGold = g_i3k_game_context:GetDiamond(true) -- 非绑元宝
			if needGold > totalGold then
				g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(10082))
				return
			end
		end
		local namecount = i3k_get_utf8_len(text)
		if namecount <= i3k_db_common.inputlen.factionlen then
			local fun = (function(ok)
				if ok then
					local data = i3k_sbean.sect_changename_req.new()
					data.name = text
					data.useItem = self:isHaveNameCard() and 1 or 0
					i3k_game_send_str_cmd(data,i3k_sbean.sect_changename_res.getName())
				end
			end)
			local desc = "确定修改帮派名字吗"
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(234))
		end

	end
end

function wnd_faction_changge_name:isHaveNameCard()
	local cardID = i3k_db_common.faction.chageNameItemID
	local count = g_i3k_game_context:GetCommonItemCount(cardID)
	return count > 0
end

function wnd_faction_changge_name:setNameCardUI()
	local cardID = i3k_db_common.faction.chageNameItemID
	local grade = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cardID)
	local widgets = self._layout.vars
	widgets.itemImg:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cardID, g_i3k_game_context:IsFemaleRole()))
	widgets.itemCoverImg:setImage(grade)
	widgets.itemCoverImg:show()
	self._layout.vars.countLabel:setText("x1")
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_changge_name.new();
		wnd:create(layout, ...);

	return wnd;
end
