-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_get_collection = i3k_class("wnd_get_collection", ui.wnd_base)

function wnd_get_collection:ctor()
	
end

function wnd_get_collection:configure()
	
end

function wnd_get_collection:onShow()
	
end

function wnd_get_collection:refresh(collectionId)
	self._layout.vars.okBtn:onClick(self, function ()
		if self._callback then
			self._callback()
		end
		g_i3k_ui_mgr:CloseUI(eUIID_GetCollection)
	end)
	local collection = i3k_db_collection[collectionId]
	self._layout.vars.gradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(collection.rank))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(collection.iconID))
	self._layout.vars.nameLabel:setText(collection.name)
end

function wnd_get_collection:addMessageBox(totalRewards)
	self._callback = function ()
		g_i3k_ui_mgr:ShowGainItemInfo(totalRewards)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_get_collection.new()
	wnd:create(layout, ...)
	return wnd;
end