module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_dragon_hole_award = i3k_class("wnd_dragon_hole_award", ui.wnd_base)

local personal = 1
local faction = 2

local LXJLT = "ui/widgets/lxjlt"
local rankIcon = {2718, 2719, 2720}

function wnd_dragon_hole_award:ctor()
	self.index = personal
end

function wnd_dragon_hole_award:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self.scroll = self._layout.vars.scroll
	self.personBtn = self._layout.vars.personBtn
	self.factionBtn = self._layout.vars.factionBtn
end

function wnd_dragon_hole_award:refresh()
	self.personBtn:onClick(self, self.changeState, personal)
	self.factionBtn:onClick(self, self.changeState, faction)
	self:updataAward()
end

function wnd_dragon_hole_award:changeState(sender, btn)
	if self.index ~= btn then
		self.index = btn
		self:updataAward()
	end
end

function wnd_dragon_hole_award:updataAward()
	local award = {}
	if self.index == personal then
		award = i3k_db_dragon_hole_award
		self.personBtn:stateToPressed()
		self.factionBtn:stateToNormal()
	else
		award = i3k_db_dragon_hole_sect_award
		self.personBtn:stateToNormal()
		self.factionBtn:stateToPressed()
	end
	self.scroll:removeAllChildren()
	local rank = 1
	for _, v in ipairs(award) do
		local node = require(LXJLT)()
		if rank <= 3 then
			node.vars.rankImg:setImage(i3k_db_icons[rankIcon[rank]].path)
			node.vars.rankLabel:hide()
		else
			node.vars.rankImg:hide()
			node.vars.rankLabel:show()
			node.vars.rankLabel:setText(string.format("%s~%s", rank, v.rank))
		end
		rank = v.rank + 1
		for i = 1, 5 do
			if v.award[i] then
				local awardItem = v.award[i]
				node.vars["root"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(awardItem.itemId))
				node.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(awardItem.itemId))
				node.vars["lock"..i]:setVisible(awardItem.itemId > 0)
				node.vars["btn"..i]:onClick(self, self.onItemInfo, awardItem.itemId)
				if math.abs(awardItem.itemId) == g_BASE_ITEM_COIN then
					if awardItem.itemCount >= 10000 then
						node.vars["countLabel"..i]:setText(string.format("x%s万", math.floor(awardItem.itemCount/10000)))
					else
						node.vars["countLabel"..i]:setText(string.format("x%s", awardItem.itemCount))
					end
				else
					node.vars["countLabel"..i]:setText(string.format("x%s", awardItem.itemCount))
				end
			else
				node.vars["root"..i]:hide()
			end
		end
		self.scroll:addItem(node)
	end
end

function wnd_dragon_hole_award:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_dragon_hole_award.new();
		wnd:create(layout);
	return wnd;
end
