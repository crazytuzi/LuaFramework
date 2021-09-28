-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_friends_charm = i3k_class("wnd_friends_charm",ui.wnd_base)

local LAYER_MEILIT = "ui/widgets/hymlt"

function wnd_friends_charm:ctor()
	self._info = info
end

function wnd_friends_charm:configure()
	local widgets = self._layout.vars
	
	self.charm_value = widgets.charm_value
	self.charm_level = widgets.charm_level
	self.bar_value = widgets.bar_value
	self.charm_name = widgets.charm_name
	self.titleBg = widgets.titleBg
	self.charm_bar = widgets.charm_bar
	self.scroll = widgets.scroll
	self.name_label = widgets.name_label
	self.head_icon = widgets.head_icon
	self.headBg = widgets.headBg
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_friends_charm:refresh(info, acceptFlower)
	self._info = info
	self:updateData()
	self:updateScroll(acceptFlower)
end

function wnd_friends_charm:updateData()
	local overview = self._info.overview
	local nowCharmValue = self._info.charm
	local level, needValue, titleCfg = g_i3k_db.i3k_db_get_charm_name(nowCharmValue, overview.gender)
	local nowValue = g_i3k_db.i3k_db_get_now_charm_value(nowCharmValue)
	self.headBg:setImage(g_i3k_get_head_bg_path(overview.bwType, overview.headBorder))
	self.charm_value:setText(nowCharmValue)
	self.bar_value:setText(string.format("%s/%s", nowValue, needValue))
	self.charm_name:setVisible(nowCharmValue ~= 0)
	self.titleBg:setVisible(nowCharmValue ~= 0)
	self.charm_name:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.name))
	self.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.iconbackground))
	self.charm_bar:setPercent(nowValue/needValue*100)
	self.charm_level:setText(string.format("%s级", level))
	self.head_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(overview.headIcon, true))
	self.name_label:setText(overview.name)
end

function wnd_friends_charm:updateScroll(info)
	self.scroll:removeAllChildren()
	table.sort(info, function (a,b)
		return a.charm > b.charm
	end)
	for i, e in pairs(info) do
		local _layer = require(LAYER_MEILIT)()
		self:updateWidgets(_layer.vars, e)
		self.scroll:addItem(_layer)
	end
end

function wnd_friends_charm:updateWidgets(widget, data)
	local overview = data.overview
	widget.headBg:setImage(g_i3k_get_head_bg_path(overview.bwType, overview.headBorder))
	widget.level_label:setText(overview.level)
	widget.name_label:setText(overview.name)
	widget.contribution:setText(data.contribution)
	widget.head_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(overview.headIcon, true))
	widget.vip_level:setText(string.format("贵族 %s", data.vipLvl))
	local level, needValue, titleCfg = g_i3k_db.i3k_db_get_charm_name(data.charm, overview.gender)
	widget.charm_lvl:setText(string.format("%s级", level))
	widget.charm_name:setVisible(data.charm ~= 0)
	widget.titleBg:setVisible(data.charm ~= 0)
	widget.charm_name:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.name))
	widget.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.iconbackground))
end

--[[function wnd_friends_charm:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FriendsCharm)
end--]]

function wnd_create(layout)
	local wnd = wnd_friends_charm.new()
	wnd:create(layout)
	return wnd
end
