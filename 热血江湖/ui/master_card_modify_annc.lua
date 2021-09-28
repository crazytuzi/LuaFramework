-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--------------------------------------------------------
-- 修改收徒宣言界面处理函数
wnd_master_card_modify_annc = i3k_class("wnd_master_card_modify_annc", ui.wnd_base)

function wnd_master_card_modify_annc:ctor()
	
end

function wnd_master_card_modify_annc:configure()
	local widgets = self._layout.vars
	self.announce = widgets.announce
	widgets.sure_btn:onClick(self,self.onClickOK)
	widgets.close_btn:onClick(self,self.onCloseUI)
	local consume = i3k_db_master_cfg.cfg.modify_announce
	widgets.icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(consume.id, g_i3k_game_context:IsFemaleRole()))
	widgets.icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(consume.id, g_i3k_game_context:IsFemaleRole()))
	widgets.suo1:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(consume.id))
	widgets.suo2:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(consume.id))
	widgets.need:setText(consume.count)
	widgets.have:setText(g_i3k_game_context:GetCommonItemCanUseCount(consume.id))
	widgets.have:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(consume.id) >= consume.count))
	widgets.desc:setText(i3k_get_string(5520))
end

function wnd_create(layout)
	local wnd = wnd_master_card_modify_annc.new()
	wnd:create(layout)
	return wnd
end

function wnd_master_card_modify_annc:refresh(curTxt)
	self._layout.vars.txt:setText(curTxt)
end

function wnd_master_card_modify_annc:onClickOK()
	local ann = self.announce:getText()
	if ann and string.utf8len(ann) > i3k_db_common.inputlen.masterDeclarationMin then
		--判断字符串长度
		if string.utf8len(ann) > i3k_db_common.inputlen.masterDeclarationMax then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5524, i3k_db_common.inputlen.masterDeclarationMin, i3k_db_common.inputlen.masterDeclarationMax))
			return
		end
		local consume = i3k_db_master_cfg.cfg.modify_announce
		if g_i3k_game_context:GetCommonItemCanUseCount(consume.id) < consume.count then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
		else
			i3k_sbean.master_card_change_declaration( self.announce:getText() )
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5514))
	end
end
