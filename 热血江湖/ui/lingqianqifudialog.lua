------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_ling_qian_dialog = i3k_class("wnd_ling_qian_dialog",ui.wnd_base)

function wnd_ling_qian_dialog:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.get:onClick(self, self.onGetBtnClick)
end

function wnd_ling_qian_dialog:onGetBtnClick(sender)
	local now = g_i3k_get_GMTtime(i3k_game_get_time())
	if self.cfg.count - g_i3k_game_context:GetLingQianUseCount(self.prayID) < 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5461))
	elseif now < self.cfg.beginTime or now > self.cfg.endTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(778))
	elseif g_i3k_game_context:GetBagSize() - g_i3k_game_context:GetBagUseCell() < 5 then
		g_i3k_ui_mgr:PopupTipMessage("背包不足")
	else
		local bean = i3k_sbean.lingqian_get_req.new()
		bean.id = self.prayID
		bean.npcID = self.info.npcID
		i3k_game_send_str_cmd(bean, "lingqian_get_res")
	end
end

function wnd_ling_qian_dialog:refresh(info)
	local info = self.info and self.info or info
	self.info = info
	local widgets = self._layout.vars
	ui_set_hero_model(widgets.npcmodule, info.moduleID)
	local cfg = i3k_db_ling_qian[info.prayID]
	self.prayID = info.prayID
	self.cfg = cfg
	widgets.time:setText(i3k_get_string(620)..'\n'..cfg.beginTimeTxt..'\n~'..cfg.endTimeTxt)
	widgets.rule:setText(i3k_get_string(5459, cfg.count))
	widgets.leftCount:setText(i3k_get_string(15594, cfg.count - g_i3k_game_context:GetLingQianUseCount(info.prayID)))
	local isFemale = g_i3k_game_context:IsFemaleRole()
	for i=1,4 do
		if cfg.award[i] then
			local id = cfg.award[i]
			widgets['item'..i..'Root']:show()
			widgets['item'..i..'Root']:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			widgets['item'..i..'_icon']:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, isFemale))
			widgets['suo'..i]:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(id))
			widgets['item'..i..'_icon']:onClick(self, function()
					g_i3k_ui_mgr:ShowCommonItemInfo(id)
				end)
		else
			widgets['item'..i..'Root']:hide()
		end
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_ling_qian_dialog.new()
	wnd:create(layout,...)
	return wnd
end
