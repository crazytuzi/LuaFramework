-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujueBreak = i3k_class("wnd_wujueBreak", ui.wnd_base)

-- 武诀突破
-- [eUIID_WujueBreak]	= {name = "wujueBreak", layout = "wujuetp", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_wujueBreak:ctor()
	self.canBreak = true
end

function wnd_wujueBreak:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onokBtn)
	widgets.close:onClick(self, self.onCloseUI)
	widgets.change1:setText(i3k_get_string(17711))
	widgets.change2:setText(i3k_get_string(17712))
end

function wnd_wujueBreak:refresh()
	local widgets = self._layout.vars
	local level = g_i3k_game_context:getWujueLevel()
	local rank = g_i3k_game_context:getWujueRank()
	local breakCfg = i3k_db_wujue_break[rank]
	local nextCfg = i3k_db_wujue_break[rank + 1]
	widgets.nowStage:setText(breakCfg.name)
	widgets.nextStage:setText(nextCfg.name)
	widgets.needLvl:setText(i3k_get_string(17695, nextCfg.req))
	widgets.needLvl:setTextColor(g_i3k_get_cond_color(nextCfg.req <= g_i3k_game_context:getWujueLevel()))
	self.canBreak = nextCfg.req <= g_i3k_game_context:getWujueLevel()
	widgets.from1:setText(breakCfg.levelTop)
	widgets.to1:setText(nextCfg.levelTop)
	widgets.from2:setText((breakCfg.expRate) == 0 and 0 or (breakCfg.expRate/100)..'%')
	widgets.to2:setText((nextCfg.expRate) == 0 and 0 or (nextCfg.expRate/100)..'%')
	widgets.desc:setText(i3k_get_string(17706, i3k_db_wujue.maxExpWhenMax))
	self:setNeedItem()
end

function wnd_wujueBreak:setNeedItem()
	local breakCfg = i3k_db_wujue_break[g_i3k_game_context:getWujueRank() + 1]
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	for k, v in ipairs(breakCfg.consumes) do
		local ui = require("ui/widgets/wujuejnjht")()
		ui.vars.cover:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.Item:onClick(self, self.onItemTips, v.id)
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
		if v.id == g_BASE_ITEM_DIAMOND or v.id == g_BASE_ITEM_COIN then
			ui.vars.count:setText(v.count)
		else
			ui.vars.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .."/".. (v.count))
		end
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= (v.count) then
			ui.vars.count:setTextColor(g_i3k_get_cond_color(true))
		else
			ui.vars.count:setTextColor(g_i3k_get_cond_color(false))
		end
		scroll:addItem(ui)
	end
end

function wnd_wujueBreak:onokBtn(sender)
	local nextRank = g_i3k_game_context:getWujueRank() + 1
	local nextRankCfg = i3k_db_wujue_break[nextRank]
	if not self.canBreak then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17696))
	elseif not g_i3k_db.i3k_db_wujue_consume_is_enough(nextRankCfg.consumes) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17697))
	else
		i3k_sbean.wujueUpRank(nextRank)
	end
end

function wnd_wujueBreak:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end
-----------------
function wnd_create(layout, ...)
	local wnd = wnd_wujueBreak.new()
	wnd:create(layout, ...)
	return wnd;
end
