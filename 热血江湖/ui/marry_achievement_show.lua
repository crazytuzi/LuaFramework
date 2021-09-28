-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_marry_achievement_show = i3k_class("wnd_marry_achievement_show", ui.wnd_base)

function wnd_marry_achievement_show:ctor()
	
end

function wnd_marry_achievement_show:configure()
	
end

function wnd_marry_achievement_show:refresh(index)
	local itemId = 0
	if g_i3k_game_context:IsFemaleRole() then
		itemId = i3k_db_marry_achieveRewards[index].femaleId
	else
		itemId = i3k_db_marry_achieveRewards[index].maleId
	end
	self._layout.vars.itemDesc_label:setText(i3k_get_string(17488, i3k_db_marry_achieveRewards[index].needPoint))
	self._layout.vars.extra_text:hide()
	self._layout.vars.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	self._layout.vars.itemName_label:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
	self._layout.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	self._layout.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId))
end

function wnd_create(layout)
	local wnd = wnd_marry_achievement_show.new()
		wnd:create(layout)
	return wnd
end
