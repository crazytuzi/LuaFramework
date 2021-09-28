
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleDesertItemTips = i3k_class("wnd_battleDesertItemTips",ui.wnd_base)

function wnd_battleDesertItemTips:ctor()
	self.id = nil
end

function wnd_battleDesertItemTips:configure()
	local widgets = self._layout.vars
	widgets.globel_bt:onClick(self, self.onCloseUI)

	widgets.btn1:onClick(self, self.onDestroyItem)
	widgets.btn2:onClick(self, self.onUseItem)
end

function wnd_battleDesertItemTips:refresh(id)
	local widgets = self._layout.vars
	self.id = id

	widgets.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.desc:setText(g_i3k_db.i3k_db_get_common_item_desc(id))
	widgets.grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
end

--销毁道具
function wnd_battleDesertItemTips:onDestroyItem(sender)
	local itemName = g_i3k_db.i3k_db_get_common_item_name(self.id)
	local desc = i3k_get_string(17625, itemName)
	local fun = (function(ok)
		if ok then
			local items = {}
			local _t = i3k_sbean.DummyGoods.new()
			_t.id = self.id
			_t.count = g_i3k_game_context:GetDesertBattleItemCount(self.id)
			table.insert(items, _t)

			i3k_sbean.survive_destoryitems(items)
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
end

--使用加血药品
function wnd_battleDesertItemTips:useItemHp()
	local curHp, maxHP = g_i3k_game_context:GetRoleHp()
	if curHp == maxHP then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17647))
	elseif i3k_game_get_time() - g_i3k_game_context:GetDesertLastUseDrugTime() < i3k_db_common.drug.drugTime.cTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17648))
	else
		i3k_sbean.survive_usedrug(self.id)
	end
	return true
end

local useItemTypeTbl =
{
	[UseItemHp] = wnd_battleDesertItemTips.useItemHp,
}

function wnd_battleDesertItemTips:onUseItem(sender)
	local itemCfg = g_i3k_db.i3k_db_get_desert_item_cfg(self.id)
	local func = useItemTypeTbl[itemCfg.type]
	if func and func(self) then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDesertItemTips)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_battleDesertItemTips.new()
	wnd:create(layout, ...)
	return wnd;
end

