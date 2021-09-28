-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_faction_fate_ranks = i3k_class("wnd_faction_fate_ranks",ui.wnd_base)

local WIDGET_BPQY = "ui/widgets/bpqy"

function wnd_faction_fate_ranks:ctor()
	self._conditionWidgets = {}
end

function wnd_faction_fate_ranks:configure()
	local widgets = self._layout.vars
	
	widgets.closeBtn:onClick(self, self.onCloseUI)
	self.scroll = widgets.scroll
	widgets.refreshBtn:onClick(self, self.onRefresh)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
end

function wnd_faction_fate_ranks:refresh(sectList)
	self:loadScroll(sectList)
end

function wnd_faction_fate_ranks:loadScroll(sectList)
	self.scroll:removeAllChildren()
	local sortRanksData = self:sortRanks(sectList)
	for i, e in ipairs(sortRanksData) do
		local node = require(WIDGET_BPQY)()
		local widget = node.vars
		local sectData = e.sect
		widget.rankID:setText(i)
		widget.name:setText(sectData.name)
		widget.factionOwnerName:setText(sectData.chiefName)
		widget.value:setText(e.destiny)
		widget.enterBtn:onClick(self, self.onEnter, sectData.sectId)
		self.scroll:addItem(node)
	end
end

function wnd_faction_fate_ranks:sortRanks(ranks)
	table.sort(ranks, function (a,b)
		return a.destiny > b.destiny
	end)
	return ranks
end

function wnd_faction_fate_ranks:onEnter(sender, sectId)
	if g_i3k_game_context:GetLevel() >= i3k_db_faction_garrison.openCondition.enterLimitLvl then
		local function func()
			i3k_sbean.sect_zone_enter(sectId)
		end
		g_i3k_game_context:CheckMulHorse(func)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16628, i3k_db_faction_garrison.openCondition.enterLimitLvl))
	end
end

function wnd_faction_fate_ranks:onRefresh(sender)
	i3k_sbean.sect_zone_list() --刷新
end

function wnd_faction_fate_ranks:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16763, i3k_db_faction_dragon.dragonCfg.factionMaxNum))
end
	
function wnd_create(layout)
	local wnd = wnd_faction_fate_ranks.new()
	wnd:create(layout)
	return wnd
end
