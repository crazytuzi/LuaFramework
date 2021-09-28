-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_charm = i3k_class("wnd_charm",ui.wnd_base)

local LAYER_MEILIT = "ui/widgets/meilit"

function wnd_charm:ctor()
	self.giveData = {}
	self.acceptData = {}
	self.state = false
end

function wnd_charm:configure()
	local widgets = self._layout.vars
	
	self.charm_value = widgets.charm_value
	self.charm_level = widgets.charm_level
	self.bar_value = widgets.bar_value
	self.charm_name = widgets.charm_name
	self.titleBg = widgets.titleBg
	self.charm_bar = widgets.charm_bar
	self.scroll = widgets.scroll
	self.accept_btn = widgets.accept_btn
	self.give_btn = widgets.give_btn
	self.accept_btn:onClick(self, self.acceptBtn)
	self.give_btn:onClick(self, self.giveBtn)
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.refresh_btn:onClick(self, self.refreshBtn)
end

function wnd_charm:refresh(giveFlower, acceptFlower)
	self.giveData = giveFlower
	self.acceptData = acceptFlower
	
	self:updateData()
	self:updateScroll(acceptFlower)
end

function wnd_charm:updateData()
	local nowCharmValue = g_i3k_game_context:GetCharm()
	local level, needValue, titleCfg = g_i3k_db.i3k_db_get_charm_name(nowCharmValue, g_i3k_game_context:GetRoleGender())
	local nowValue = g_i3k_db.i3k_db_get_now_charm_value(nowCharmValue)
	self.charm_value:setText(nowCharmValue)
	self.bar_value:setText(string.format("%s/%s", nowValue, needValue))
	self.charm_name:setVisible(nowCharmValue ~= 0)
	self.titleBg:setVisible(nowCharmValue ~= 0)
	self.charm_name:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.name))
	self.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.iconbackground))
	self.charm_bar:setPercent(nowValue/needValue*100)
	self.charm_level:setText(string.format("%s级", level))
	
	self.accept_btn:stateToPressed(true)
	self.give_btn:stateToNormal(true)
end

function wnd_charm:updateScroll(info)
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

function wnd_charm:updateWidgets(widget, data)
	local overView = data.overview
	widget.headBg:setImage(g_i3k_get_head_bg_path(overView.bwType, overView.headBorder))
	widget.level_label:setText(overView.level)
	widget.name_label:setText(overView.name)
	widget.contribution:setText(data.contribution)
	widget.head_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(overView.headIcon, true))
	widget.vip_level:setText(string.format("贵族 %s", data.vipLvl))
	local level, needValue, titleCfg = g_i3k_db.i3k_db_get_charm_name(data.charm, overView.gender)
	widget.charm_lvl:setText(string.format("%s级", level))
	widget.charm_name:setVisible(data.charm ~= 0)
	widget.titleBg:setVisible(data.charm ~= 0)
	widget.charm_name:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.name))
	widget.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(titleCfg.iconbackground))
	widget.check_btn:setVisible(self.state)
	widget.check_btn:onClick(self, self.checkBtn, data)
end

function wnd_charm:acceptBtn(sender)
	self.accept_btn:stateToPressed(true)
	self.give_btn:stateToNormal(true)
	self.state = false
	self:updateScroll(self.acceptData)
end

function wnd_charm:giveBtn(sender)
	self.accept_btn:stateToNormal(true)
	self.give_btn:stateToPressed(true)
	self.state = true
	self:updateScroll(self.giveData)
end

function wnd_charm:refreshBtn(sender)
	i3k_sbean.get_flowerlog(true)
end

function wnd_charm:refreshCharmScroll(giveFlower, acceptFlower)
	self.giveData = giveFlower
	self.acceptData = acceptFlower
	if self.state then
		self:updateScroll(giveFlower)
	else
		self:updateScroll(acceptFlower)
	end
end

function wnd_charm:checkBtn(sender, data)
	i3k_sbean.get_acceptlist(data.overview.id, data)
end

--[[function wnd_charm:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Charm)
end--]]

function wnd_create(layout)
	local wnd = wnd_charm.new()
	wnd:create(layout)
	return wnd
end
