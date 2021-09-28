------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_battle_desert_award = i3k_class("wnd_battle_desert_award",ui.wnd_base)

local AWARD_WIDGET = "ui/widgets/juezhanhuangmot"
local f_rankImg = {2718, 2719, 2720}
local decoration = {5201, 5202, 5203}

local awardTb = {
	i3k_db_desert_battle_show_award.personAward,
	i3k_db_desert_battle_show_award.teamAward,
}

function wnd_battle_desert_award:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	widgets.personBtn:onClick(self,self.onTabBtnClick,1)
	widgets.teamBtn:onClick(self,self.onTabBtnClick,2)
	widgets.tab1Title:setText(i3k_get_string(17657))
	widgets.tab2Title:setText(i3k_get_string(17658))
end

function wnd_battle_desert_award:setItems(cfg,widgets)
	for i=1,5 do
		widgets['root'..i]:setVisible(cfg[i] and true or false)
		if cfg[i] then
			widgets['icon'..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg[i].itemId))
			widgets['btn'..i]:onClick(self,self.onItemTips, cfg[i].itemId)
			widgets['countLabel'..i]:setText("x"..cfg[i].itemCount)
			widgets['lock'..i]:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(cfg[i].itemId))
		end
	end
end

function wnd_battle_desert_award:refresh(index)
	local index = index or 1
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	if index == 1 then
		widgets.personBtn:stateToPressed()
		widgets.teamBtn:stateToNormal()
		widgets.desc:setText(i3k_get_string(17657))
	else
		widgets.personBtn:stateToNormal()
		widgets.teamBtn:stateToPressed()
		widgets.desc:setText(i3k_get_string(17658))
	end
	local cfg = awardTb[index]
	for i, v in ipairs(cfg) do
		local widget = require(AWARD_WIDGET)()
		if i <= 3 and index == 2 then
			widget.vars.sharder:setImage(g_i3k_db.i3k_db_get_icon_path(decoration[i]))
			widget.vars.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[i]))
			widget.vars.rankLabel:hide()
		else
			widget.vars.rankLabel:setText(v.des)
			widget.vars.rankImg:hide()
		end
		self:setItems(v.items, widget.vars)
		widgets.scroll:addItem(widget)
	end
end

function wnd_battle_desert_award:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_battle_desert_award:onTabBtnClick(sender, tbIndex)
	self:refresh(tbIndex)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_battle_desert_award.new()
	wnd:create(layout,...)
	return wnd
end