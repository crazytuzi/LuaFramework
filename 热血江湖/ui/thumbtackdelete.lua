module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_thumbtackDelete = i3k_class("wnd_thumbtackDelete", ui.wnd_base)

function wnd_thumbtackDelete:ctor()
	self._mapID = 0
	self._index = 0
end

function wnd_thumbtackDelete:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onDeleteBt)
	widgets.quxiao:onClick(self, self.onModifyThumbtackBt)
	widgets.edit:addEventListener(function(eventType)
		if eventType == "ended" then		
			local str = widgets.edit:getText()
			
			if str ~= "" then  
				widgets.desc:hide()
			else
				widgets.desc:show()
			end
		end
	end)
	widgets.edit:setMaxLength(i3k_db_common.tuDingInfo.strNum)
end

function wnd_thumbtackDelete:refresh(curItem)
	self._mapID = curItem.mapId
	self._index = curItem.index
	local widgets = self._layout.vars
	local mapName = i3k_db_dungeon_base[self._mapID].desc
	widgets.name:setText(mapName .. self._index)
	widgets.desc:setText(i3k_get_string(17291))
end

function wnd_thumbtackDelete:onDeleteBt()
	i3k_sbean.thumbtack_Delete(self._mapID, self._index)
	self:onCloseUI()
end

function wnd_thumbtackDelete:onModifyThumbtackBt()	
	local widgets = self._layout.vars
	local remarks = widgets.edit:getText()
	i3k_sbean.thumbtack_Modify(self._mapID, self._index, remarks)
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_thumbtackDelete.new();
	wnd:create(layout);
	return wnd;
end
