-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_callBackTips = i3k_class("wnd_callBackTips", ui.wnd_base)

function wnd_callBackTips:ctor()
end

function wnd_callBackTips:configure()
	self._layout.vars.globel_bt:onClick(self,self.onClose)
end

function wnd_callBackTips:refresh(data)
	local scroll = self._layout.vars.listView
	scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_CENTER)
	for k,v in ipairs(data) do
		local _item = require("ui/widgets/huiguitipst")()
		if v.isRandom then
			_item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(5556))
			_item.vars.num:setVisible(false)
			_item.vars.lock:setVisible(false)
		else
			_item.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			_item.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
			_item.vars.btn:onClick(self,function ()
				g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
			end)
			_item.vars.num:setText("X" .. v.num)
			if v.id < 0 then
				_item.vars.lock:setVisible(false)
			end
		end
		scroll:addItem(_item)
	end
end

function wnd_callBackTips:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_CallBackTips)
end

function wnd_create(layout, ...)
	local wnd = wnd_callBackTips.new()
	wnd:create(layout, ...)
	return wnd
end
