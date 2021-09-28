-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--------------------------------------------------------
-- 修改收徒宣言界面处理函数
master_modify_annc = i3k_class("master_modify_annc", ui.wnd_base)

function master_modify_annc:ctor()
	
end

function master_modify_annc:configure()
	local widgets = self._layout.vars
	self.announce = widgets.announce
	widgets.sure_btn:onClick(self,self.onClickOK)
	widgets.close_btn:onClick(self,self.onCloseUI)
end

function wnd_create(layout)
	local wnd = master_modify_annc.new()
	wnd:create(layout)
	return wnd
end

function master_modify_annc:refresh()
	self.announce:setText(g_i3k_game_context:GetMasterAnnounce())
end

function master_modify_annc:onClickOK()
	local ann = self.announce:getText()
	if ann and string.utf8len(ann)>0 then
		--判断字符串长度
		if string.utf8len(ann)>i3k_db_master_cfg.cfg.announce_max_length then
			g_i3k_ui_mgr:PopupTipMessage("宣言文字长度太长了，最多" .. i3k_db_master_cfg.cfg.announce_max_length .. "字" )
			return
		end
		i3k_sbean.master_modify_announce( self.announce:getText() )
	end
	self:onCloseUI()
end
