-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_createFightTeam = i3k_class("wnd_createFightTeam", ui.wnd_base)

function wnd_createFightTeam:ctor()
	self._isItemEnough = false
end

function wnd_createFightTeam:configure(...)
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.input_label = widgets.input_label 
	self.input_label:setMaxLength(i3k_db_common.inputlen.namelen)
	self.scroll = widgets.scroll
	self.descLabel = widgets.descLabel
	widgets.createBtn:onClick(self, self.onCreateBtn)
end

function wnd_createFightTeam:refresh()
	self:loadConditionDesc()
	self:loadItemScroll()
end

function wnd_createFightTeam:loadConditionDesc()
	self.descLabel:setText(i3k_get_string(1203))
end

function wnd_createFightTeam:loadItemScroll()
	local items = i3k_db_fightTeam_base.team.needItems
	self.scroll:removeAllChildren()
	local num = 0
	for _, e in ipairs(items) do
		local node = require("ui/widgets/wudaohuiqmt")()
		node.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.id))
		node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.id, g_i3k_game_context:IsFemaleRole()))
		node.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.id))
		node.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.id))
		node.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.id)))
		if math.abs(e.id) == g_BASE_ITEM_DIAMOND or math.abs(e.id) == g_BASE_ITEM_COIN then
			node.vars.item_count:setText(e.id)
		else
			node.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.id).."/"..e.count)
		end
		if g_i3k_game_context:GetCommonItemCanUseCount(e.id) >= e.count then
			num = num + 1
		end
		node.vars.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.id) >= e.count))
		node.vars.tip_btn:onClick(self, self.onItemTips, e.id)
		self.scroll:addItem(node)
	end
	self._isItemEnough = num == #items
end

function wnd_createFightTeam:onCreateBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_fightTeam_base.team.requireLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1238, i3k_db_fightTeam_base.team.requireLvl))
	end
	local name = self.input_label:getText()
	local errorCode, desc = g_i3k_name_rule(name)
	if errorCode ~= 1 then
		return g_i3k_ui_mgr:PopupTipMessage(desc)
	end

	if not self._isItemEnough then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1239))
	end

	i3k_sbean.fightteam_create(name)
end

function wnd_createFightTeam:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_createFightTeam.new();
		wnd:create(layout, ...);
	return wnd;
end
