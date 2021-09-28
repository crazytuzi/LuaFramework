-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_single_dungeon_tips = i3k_class("wnd_single_dungeon_tips", ui.wnd_base)

function wnd_single_dungeon_tips:ctor()
	
end

function wnd_single_dungeon_tips:configure(...)
	self.tag_root = self._layout.vars.tag_root 
	self.target = self._layout.vars.target 
	self.tag_desc = self._layout.vars.tag_desc 
	
	self.desc_root = self._layout.vars.desc_root 
	self.desc = self._layout.vars.desc 
end

function wnd_single_dungeon_tips:onShow()
	
end

function wnd_single_dungeon_tips:refresh(tagId,battleId)
	self:updateTagDesc(tagId)
	self:updateDesc(battleId)
end 

function wnd_single_dungeon_tips:updateTagDesc(id)
	if id == 0 then
		self.tag_root:hide()
	else
		self.tag_root:show()
		self.tag_desc:setText(i3k_get_string(id))
	end
end 

function wnd_single_dungeon_tips:updateDesc(id)
	if id == 0 then
		self.desc_root:hide()
	else
		self.desc_root:show()
		self.desc:setText(i3k_get_string(id))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_single_dungeon_tips.new();
		wnd:create(layout, ...);

	return wnd;
end

