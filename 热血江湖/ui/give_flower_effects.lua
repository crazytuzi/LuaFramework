-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_give_flower_effects = i3k_class("wnd_give_flower_effects",ui.wnd_base)

function wnd_give_flower_effects:ctor()
	self.item_id = nil
end

function wnd_give_flower_effects:configure()
	
end

function wnd_give_flower_effects:refresh(count)
	self:playEffect(count)
end

function wnd_give_flower_effects:playEffect(count)
	if count >= i3k_db_common.give_flower.lessEffect and count < i3k_db_common.give_flower.moreEffect then
		self._layout.anis.c_diji.play()
	elseif count >= i3k_db_common.give_flower.moreEffect then
		self._layout.anis.c_gaoji.play()
	end
end

function wnd_create(layout)
	local wnd = wnd_give_flower_effects.new()
	wnd:create(layout)
	return wnd
end
