-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_garrison_donate_ranks = i3k_class("wnd_garrison_donate_ranks",ui.wnd_base)

local WIDGET_ZDGXB = "ui/widgets/zdgxb"
local z_rankImg = {2718, 2719, 2720} --1,2,3 排名图片

function wnd_garrison_donate_ranks:ctor()
	self._conditionWidgets = {}
end

function wnd_garrison_donate_ranks:configure()
	local widgets = self._layout.vars
	
	widgets.closeBtn:onClick(self, self.onCloseUI)
	self.scroll = widgets.scroll2
end

function wnd_garrison_donate_ranks:refresh(ranks)
	self:loadScroll(ranks)
end

function wnd_garrison_donate_ranks:loadScroll(ranks)
	self.scroll:removeAllChildren()
	local sortRanksData = self:sortRanks(ranks)
	for i, e in ipairs(sortRanksData) do
		local node = require(WIDGET_ZDGXB)()
		local widget = node.vars
		if i <= 3 then
			widget.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(z_rankImg[i]))
		else
			widget.rankLabel:setText(i..".")
		end
		widget.rankImg:setVisible(i<=3)
		widget.rankLabel:setVisible(i>3)
		widget.playerName:setText(e.name)
		widget.donateCount:setText(e.buildTimes)
		self.scroll:addItem(node)
	end
end

function wnd_garrison_donate_ranks:sortRanks(ranks)
	local sort_items = {} --排序
	for _, v in pairs(ranks) do
		table.insert(sort_items, v)
	end
	table.sort(sort_items, function (a,b)
		return a.buildTimes > b.buildTimes
	end)
	return sort_items
end
	
function wnd_create(layout)
	local wnd = wnd_garrison_donate_ranks.new()
	wnd:create(layout)
	return wnd
end
