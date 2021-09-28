-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_petRaceSkillDesc = i3k_class("wnd_petRaceSkillDesc", ui.wnd_base)

function wnd_petRaceSkillDesc:ctor()

end

function wnd_petRaceSkillDesc:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.item_count:setText(i3k_get_string(16012))
	-- widgets.bosstx:setImage()
end

function wnd_petRaceSkillDesc:onShow()
	self:setScroll()
end

function wnd_petRaceSkillDesc:setScroll()
	local widgets = self._layout.vars
	local items = i3k_db_common.petRace.useItems
	for k, v in ipairs(items) do
		local node = require("ui/widgets/bsjnmst2")()
		node.vars.cover:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v, i3k_game_context:IsFemaleRole()))
		node.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(v))
		node.vars.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v)))
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(v)
		local descString = string.gsub(cfg.desc, "purple", "hlgreen")
		node.vars.desc:setText(descString)
		widgets.bsjnsm:addItem(node)
	end
end

function wnd_petRaceSkillDesc:refresh()

end


function wnd_create(layout, ...)
	local wnd = wnd_petRaceSkillDesc.new()
	wnd:create(layout, ...)
	return wnd;
end
