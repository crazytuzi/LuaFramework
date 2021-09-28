module(..., package.seeall)

local require = require;

local ui = require("ui/base");

--------------------------------------------------------
-- 拜师，师傅基本信息界面

master_mstr_info = i3k_class("master_mstr_info", ui.wnd_base)

function master_mstr_info:ctor()
end

function master_mstr_info:configure()
	local widgets = self._layout.vars
	
	widgets.btnClose:onClick(self,self.onCloseUI)
	widgets.btnEnroll:onClick(self,self.onClickEnroll)
end

function master_mstr_info:refresh()
end

function wnd_create(layout)
	local wnd = master_mstr_info.new()
	wnd:create(layout)
	return wnd
end
-----------------------------------------------------
	-- 更新界面,m is i3k_sbean.MasterDetail
function master_mstr_info:updateUI(m)
	if m==nil or m.overview==nil then
		return
	end
	local r=m.overview --i3k_sbean.RoleOverView
	local widgets = self._layout.vars
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(r.headIcon,g_i3k_db.eHeadShapeQuadrate)	
	if hicon and hicon > 0 then
		widgets.imgHeadIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	end
	widgets.imgHeadBgrd:setImage(g_i3k_get_head_bg_path(r.bwType, r.headBorder))
	widgets.txtName:setText(r.name)
	widgets.imgCls:setImage( g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[r.type].classImg) )
	widgets.txtLevel:setText("Lv. " .. r.level)
	widgets.txtVip:setText( "" .. m.vip)
	widgets.txtPower:setText( "" .. r.fightPower )
	if m.online then
		widgets.txtOnline:setText( "线上" )
	else
		widgets.txtOnline:setText( "离线" )
	end
	widgets.txtApprtcNum:setText( "" .. m.apprenticeCount )
	widgets.txtAnnounce:setText( m.announce )
	self.master_info = m
end
-----------------------------------------------------
	-- 点击“拜师”按钮的响应
function master_mstr_info:onClickEnroll()
	if self.master_info==nil then
		return
	end
	-- 判断申请条件
	if g_i3k_game_context:IsApprtcApplyEnrollCooling(self.master_info.overview.id) then
		-- 冷却中
		g_i3k_ui_mgr:PopupTipMessage("您的申请行为过于频繁，请稍后再试。")
		return
	end
	-- 发出申请，并等待服务器回应
	local widgets = self._layout.vars
	i3k_sbean.master_request_master(self.master_info.overview.id,"BAISHI_UI")
	widgets.btnEnroll:disableWithChildren()
end
