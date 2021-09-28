-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_star_lock = i3k_class("wnd_star_lock",ui.wnd_base)

function wnd_star_lock:ctor()
	self._rank = 0;
end

function wnd_star_lock:configure()
	local widgets = self._layout.vars
	self.ok			= widgets.ok
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_star_lock:onActivateBtn(sender, arg)
	local count = 0;
	for i,e in ipairs(arg.needItem) do
		if g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) >= e.needItemCount then
			count = count + 1;
		end
	end
	if count == #arg.needItem then
		i3k_sbean.StarQuickActivate(arg.starID, arg.needItem)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end
end

function wnd_star_lock:refresh(starID)
	self:updateNeedItem(starID)
end

function wnd_star_lock:updateNeedItem(starID)
	local star =  i3k_db_star_soul[starID]
	local needItem = i3k_db_star_soul_gears[star.rank].needItem;
	if star and needItem then
		self._rank = star.rank;
		local times = g_i3k_game_context:GetActiveTimes(star.rank) + 1;
		local item = {}
		for i,e in ipairs(needItem) do
			table.insert(item, {needItemID = e.needItemID, needItemCount = e.needItemCount[times]})
		end
		local arg = {starID = starID, needItem = item, times = times};
		self.ok:onClick(self, self.onActivateBtn, arg)
		local widget = self._layout.vars
		for i,e in ipairs(needItem) do
			widget["itembg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.needItemID))
			widget["itemBtn"..i]:onClick(self, self.onClickItem, e.needItemID)
			widget["itemIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.needItemID,g_i3k_game_context:IsFemaleRole()))
			widget["suo"..i]:setVisible(e.needItemID > 0)
			widget["name"..i]:setText(g_i3k_db.i3k_db_get_common_item_name(e.needItemID))
			widget["name"..i]:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.needItemID)))
			if e.needItemID == g_BASE_ITEM_DIAMOND or e.needItemID == g_BASE_ITEM_COIN then
				widget["itemCount"..i]:setText(e.needItemCount[times])
			else
				widget["itemCount"..i]:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) .."/".. e.needItemCount[times])
			end
			widget["itemCount"..i]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) >= e.needItemCount[times]))
		end
	end
end

function wnd_star_lock:updateItemNum()
	if self._rank > 0 then
		local needItem = i3k_db_star_soul_gears[self._rank].needItem;
		local times = g_i3k_game_context:GetActiveTimes(self._rank) + 1;
		local widget = self._layout.vars
		for i,e in ipairs(needItem) do
			widget["itemCount"..i]:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) .."/".. e.needItemCount[times])
			widget["itemCount"..i]:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) >= e.needItemCount[times]))
		end
	end
end

function wnd_star_lock:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_star_lock.new()
	wnd:create(layout)
	return wnd
end
	