
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_selectWeapon = i3k_class("wnd_selectWeapon",ui.wnd_base)

function wnd_selectWeapon:ctor()

end

function wnd_selectWeapon:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	self.scroll = widgets.scroll
end

function wnd_selectWeapon:refresh()
	self:refreshShenbingData()
end

function wnd_selectWeapon:refreshShenbingData()
	self.scroll:removeAllChildren()
	local allShenbing = self:sortShenbing(g_i3k_game_context:GetShenbingData())
	local ListItems = self.scroll:addItemAndChild("ui/widgets/shenbingqht", 3, table.nums(allShenbing))
	local index = 1
	local useId = g_i3k_game_context:GetSelectWeapon()
	for _, v in pairs(allShenbing) do
		local node = ListItems[index]
		if g_i3k_game_context:IsShenBingAwake(v.id) then
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[v.id].awakeWeaponIcon))
			node.vars.weaponBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[v.id].awakeBackground))
		else
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[v.id].icon))
		end
		node.vars.btn:onClick(self, self.onUseShenbingBtn, v.id)
		node.vars.equip:setVisible(v.id == useId)
		index = index + 1
	end
end
function wnd_selectWeapon:sortShenbing(allShenbing)
	local sortTb = {}
	for k, v in pairs(allShenbing) do
		local sortId = v.qlvl * 1000 + v.slvl * 100 + 100 - k
		table.insert(sortTb, {id = k, sortId = sortId})
	end
	table.sort(sortTb, function(a, b)
		return a.sortId > b.sortId
	end)
	return sortTb
end

function wnd_selectWeapon:onUseShenbingBtn(sender, id)
	local useId = g_i3k_game_context:GetSelectWeapon()
	if id == useId then
		return g_i3k_ui_mgr:PopupTipMessage("已装备该神兵")
	end
	local hero = i3k_game_get_player_hero()
	if hero._superMode.valid then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(129))
		return
	end
	i3k_sbean.goto_weapon_select(id, i3k_db_shen_bing[id].showModuleID, useId)--装备协议
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_selectWeapon.new()
	wnd:create(layout, ...)
	return wnd;
end

