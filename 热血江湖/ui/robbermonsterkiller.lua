-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_robber_monster_killer = i3k_class("wnd_robber_monster_killer",ui.wnd_base)

local JIANGHUDADAT = ("ui/widgets/jiangyangdadaot")

function wnd_robber_monster_killer:ctor()

end

function wnd_robber_monster_killer:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	self.killerName = widgets.killerName
	self.itemScroll = widgets.itemScroll
end

function wnd_robber_monster_killer:refresh(data)
	self.killerName:setText(i3k_get_string(16875, data.lastKillerName))
	self:loadItemScroll(data.lastKillDrops)
end

-- 物品
function wnd_robber_monster_killer:loadItemScroll(goods)
	self.itemScroll:removeAllChildren()
	local  items = self:sortItems(goods)
	local allWidget = self.itemScroll:addChildWithCount(JIANGHUDADAT, 5, #items)
	for i, e in ipairs(allWidget) do
		local id = items[i].id
		local count = items[i].count
		e.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		e.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		e.vars.count:setText(string.format("x%s", count))
		e.vars.bt:onClick(self, self.onItemTips, id)
	end
end

function wnd_robber_monster_killer:sortItems(goods)
	local items = {}
	for k, v in pairs(goods) do
		local rank = g_i3k_db.i3k_db_get_common_item_rank(k)
		table.insert(items, {id = k, count = v, rank = rank})
	end
	table.sort(items, function(a, b)
		return a.rank > b.rank
	end)
	return items
end

function wnd_robber_monster_killer:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_robber_monster_killer.new()
	wnd:create(layout)
	return wnd
end
