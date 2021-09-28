
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_upgrade_rune_lang_items = i3k_class("wnd_upgrade_rune_lang_items",ui.wnd_base)

function wnd_upgrade_rune_lang_items:ctor()
	self.runeLangId = nil
	self.nextLvl = nil
	self.items = nil
	self.enough = true
end

function wnd_upgrade_rune_lang_items:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.upTips:setText(i3k_get_string(983))
	widgets.up_btn:onClick(self, self.upgrade)
end

function wnd_upgrade_rune_lang_items:refresh(items, nextLvl, runeLangId, expendNum)
	self.runeLangId = runeLangId
	self.nextLvl = nextLvl
	self.items = items
	self.enough = true

	local widgets = self._layout.vars
	local all_child = widgets.scroll:addChildWithCount("ui/widgets/njfwzysjt", 2, 6)
	widgets.scroll:setBounceEnabled(false)
	local _,rune_bag = g_i3k_game_context:GetRuneBagInfo()
	local runeCfg = i3k_db_under_wear_rune
	for i,node in ipairs(all_child) do
		local vars = node.vars
		vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(items[i],i3k_game_context:IsFemaleRole()))
		vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(items[i]))
		vars.btn:onClick(self, self.onRuneTips, items[i])
		vars.name:setText(runeCfg[items[i]].runeName)
		vars.name:setTextColor( g_i3k_get_color_by_rank( g_i3k_db.i3k_db_get_common_item_rank(items[i]) ) )
		local hasCount = self:getRuneCount(rune_bag, items[i])
		vars.count:setText(hasCount.."/"..expendNum)
		if hasCount< expendNum then
			self.enough = false
			vars.count:setTextColor(g_i3k_get_red_color())
		else
			vars.count:setTextColor(g_i3k_get_green_color())
		end
	end
end

function wnd_upgrade_rune_lang_items:onRuneTips(sender, itemId)
	g_i3k_ui_mgr:OpenUI(eUIID_RuneBagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagItemInfo, nil, nil,  itemId, 3)
end

function wnd_upgrade_rune_lang_items:getRuneCount(bag, id)
	return (bag[id] or 0) + (bag[-id] or 0)
end

function wnd_upgrade_rune_lang_items:upgrade()
	if not self.enough then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(996)) --符文背包中的符文不足
	end
	i3k_sbean.rune_upgradeReq(self.runeLangId, self.nextLvl, self.items)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_upgrade_rune_lang_items.new()
	wnd:create(layout, ...)
	return wnd;
end

