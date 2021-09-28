-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

--------------------------------------------------------
-- 徒弟拜师界面
local LAYER_MASTER = "ui/widgets/baishit"
local ROW_COUNT = 2 --每行显示的数量

local l_refresh_index = -1
--------------------------------------------------------

master_baishi = i3k_class("master_baishi", ui.wnd_base)

function master_baishi:ctor()
end

function master_baishi:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self,self.onCloseUI)
	self.scroll_masters = widgets.master_scroll
	widgets.refreshBtn:onClick(self,self.onClickRefreshList)
end

function master_baishi:refresh()
	l_refresh_index = -1
	i3k_sbean.master_refresh_masters(l_refresh_index)
end

function wnd_create(layout)
	local wnd = master_baishi.new()
	wnd:create(layout)
	return wnd
end
-----------------------------------------------------
	-- res is i3k_sbean.master_list_res
function master_baishi:updateMasterList(res)
	if res==nil or res.retCode~=0 then
		return
	end
	l_refresh_index = res.startIndex
	self.scroll_masters:removeAllChildren()
	if res.totalCount==0 then
		return
	end
	if res.masters==nil then
		return
	end
	local count = #res.masters
	local children = self.scroll_masters:addChildWithCount(LAYER_MASTER, ROW_COUNT, count)
	for i,v in ipairs(children) do
		local m=res.masters[i] -- m is i3k_sbean.MasterDetail
		local r=m.overview  -- i3k_sbean.RoleOverView
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(r.headIcon,g_i3k_db.eHeadShapeQuadrate)	
		if hicon and hicon > 0 then
			v.vars.imgHeadIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		v.vars.imgHeadBgrd:setImage(g_i3k_get_head_bg_path(r.bwType, r.headBorder))
		v.vars.txtName:setText(r.name)
		v.vars.imgCls:setImage( g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[r.type].classImg) )
		v.vars.txtLevel:setText("Lv. " .. r.level)
		v.vars.applyBtn:onClick(self,self.onClickMasterInfo,m)
	end
end
-----------------------------------------------------
--刷新按钮
function master_baishi:onClickRefreshList()
	i3k_sbean.master_refresh_masters(l_refresh_index)
end

-- 点击师傅列表条,master is i3k_sbean.MasterDetail
function master_baishi:onClickMasterInfo(sender,master)
	-- 发送消息，弹出拜师界面
	g_i3k_ui_mgr:OpenUI(eUIID_Master_mstrInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_Master_mstrInfo)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_mstrInfo,"updateUI",master)
end
