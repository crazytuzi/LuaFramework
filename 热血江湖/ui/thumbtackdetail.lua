module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_thumbtackDetail = i3k_class("wnd_thumbtackDetail", ui.wnd_base)

function wnd_thumbtackDetail:ctor()

end

function wnd_thumbtackDetail:configure()
	local widgets = self._layout.vars
	widgets.imgBK:onClick(self, self.onCloseUI)
	widgets.quxiao:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOKBt)
	widgets.edit:addEventListener(function(eventType)
		if eventType == "ended" then		
			local str = widgets.edit:getText()
			
			if str ~= "" then  
				widgets.prompt:hide()
			else
				widgets.prompt:show()
			end
		end
	end)
end

function wnd_thumbtackDetail:refresh(index, mapID)
	local widgets = self._layout.vars
	local mapName = i3k_db_dungeon_base[mapID].desc
	local heroPos = i3k_game_get_player_hero()._curPosE
	widgets.name:setText(mapName .. index)
	widgets.pos:setText(string.format("坐标：(%d, %d, %d)", i3k_integer(heroPos.x), i3k_integer(heroPos.y), i3k_integer(heroPos.z)))
	widgets.edit:setMaxLength(i3k_db_common.tuDingInfo.strNum)
	widgets.desc:setText(i3k_get_string(17289))
end

function wnd_thumbtackDetail:onOKBt()
	local widgets = self._layout.vars
	local remarks = widgets.edit:getText()
	i3k_sbean.thumbtack_Add(remarks)
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_thumbtackDetail.new();
	wnd:create(layout);
	return wnd;
end
