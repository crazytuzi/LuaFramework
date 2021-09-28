-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

--------------------------------------------------------
-- 徒弟活跃列表界面

local LAYER_ACTIVITY = "ui/widgets/tdhyt"

--------------------------------------------------------
master_apprtc_activity = i3k_class("master_apprtc_activity", ui.wnd_base)

function master_apprtc_activity:ctor()
end

function master_apprtc_activity:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self,self.onCloseUI)
	self.scroll_activity = widgets.scrollActivity
end

function master_apprtc_activity:refresh()
	-- 发送协议
	i3k_sbean.master_get_apprtc_active()
end

function wnd_create(layout)
	local wnd = master_apprtc_activity.new()
	wnd:create(layout)
	return wnd
end
-----------------------------------------------------
-- data is list of i3k_sbean.ApprenticeDetail
function master_apprtc_activity:updateActivity(data)
	if data==nil then
		return
	end
	self.scroll_activity:removeAllChildren()
	for i=1,#data do
		local m = data[i]
		local r = m.overview
		local layer=require(LAYER_ACTIVITY)()
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(r.headIcon,g_i3k_db.eHeadShapeQuadrate)	
		if hicon and hicon > 0 then
			layer.vars.imgHeadIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		layer.vars.imgHeadBgrd:setImage(g_i3k_get_head_bg_path(r.bwType, r.headBorder))
		layer.vars.txtName:setText(r.name)
		layer.vars.imgCls:setImage( g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[r.type].classImg) )
		layer.vars.txtLevel:setText( "Lv. " .. r.level )
		if m.online then
			layer.vars.txtOnline:setText("线上")
		else
			layer.vars.txtOnline:setText("离线")
		end
		layer.vars.txtHistoryActv:setText( "" .. m.historyActivity )
		layer.vars.txtHistoryPoint:setText( "" .. m.historyPoint )
		layer.vars.txtScore:setText( "" .. m.score )
		self.scroll_activity:addItem(layer)
	end
end
