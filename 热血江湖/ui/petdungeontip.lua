------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_pet_dungeon_tip = i3k_class("wnd_pet_dungeon_tip",ui.wnd_base)

local iconList = i3k_db_PetDungeonBase.tipIconList
local strList = i3k_db_PetDungeonBase.tipStrList

function wnd_pet_dungeon_tip:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self,self.onCloseUI)
	widget.leftBtn:onClick(self, self.onNextPage, -1)
	widget.rightBtn:onClick(self, self.onNextPage, 1)
	self.index = 1
	self:setCurPage(self.index)
end

function wnd_pet_dungeon_tip:onNextPage(sender, direction)
	local target = self.index + direction
	if iconList[target] then
		self:setCurPage(target)
	end
end

function wnd_pet_dungeon_tip:setCurPage(index)
	self.index = index
	local widget = self._layout.vars
	widget.leftBtn:setVisible(self.index ~= 1)
	widget.rightBtn:setVisible(self.index ~= #iconList)
	widget.close_btn:setVisible(self.index == #iconList)
	widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconList[index]))
	widget.desc:setText(i3k_get_string(strList[index]))
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_pet_dungeon_tip.new()
	wnd:create(layout,...)
	return wnd
end