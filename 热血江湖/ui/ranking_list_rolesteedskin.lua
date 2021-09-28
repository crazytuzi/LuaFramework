-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/steedRankBase")

-------------------------------------------------------

wnd_ranking_list_RoleSteedSkin = i3k_class("wnd_ranking_list_RoleSteedSkin",ui.wnd_steedRankBase)

local STEED_BG = 707 

function wnd_ranking_list_RoleSteedSkin:ctor()
	self._info = nil
	self._id = nil
	self._showIDs = nil
	self._tag = nil
	self._masters = nil
	self._steedSpirit = nil
	self._steedEquip = nil
end

function wnd_ranking_list_RoleSteedSkin:configure()
	-- 重写父类
	ui.wnd_steedRankBase.configure(self)
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.mashu = widgets.mashu
	self.steedJd = widgets.steedJd
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.item_scroll = widgets.item_scroll
	self.steedFightBtn = widgets.steedFightBtn
	self.steedSpiritBtn = widgets.steedSpiritBtn
	self.steedSpiritRoot = widgets.steedSpiritRoot

	widgets.skinBtn:stateToPressed()
end

function wnd_ranking_list_RoleSteedSkin:refresh(data)
	-- 重写父类
	ui.wnd_steedRankBase.setSteedRankBaseData(self, data)

	local widgets = self._layout.vars
	self._id = data.id
	self._info = data.info
	self._showIDs = data.showIDs
	self._masters = data.masters
	self._steedSpirit = data.steedSpirit
	self._steedEquip = data.steedEquip

	widgets.mashu:hide()
	widgets.steedJd:show()
	if self._masters and (next(self._masters) ~= nil or self._steedSpirit.star > 0) then
		widgets.steedFightBtn:show();
	else
		widgets.steedFightBtn:hide();
	end
	widgets.steedSpiritBtn:setVisible(self._steedSpirit.star > 0)
	widgets.steedEquipBtn:setVisible(data.roleOverview.level >= i3k_db_steed_equip_cfg.openLevel)

	self:loadScroll(self._showIDs)
end

function wnd_ranking_list_RoleSteedSkin:loadModuleAndName(cfg)
	ui_set_hero_model(self.hero_module, cfg.modelId)
	if cfg.modelRotation ~= 0 then
		self.hero_module:setRotation(cfg.modelRotation)
	end
	self.hero_module:playAction("show")
	self.battle_power:setText(g_i3k_game_context:getSteedSkinPower(cfg))
end

function wnd_ranking_list_RoleSteedSkin:loadScroll(showIDs)
	self.item_scroll:removeAllChildren()
	local sortSkins = self:sortShowIDs(showIDs)
	for i, e in pairs(sortSkins) do
		local node = require("ui/widgets/pfxxt")()
		local cfg = e.cfg
		local widget = node.vars
		widget.tag = cfg.id
		widget.select1_btn:onClick(self, self.onSelectBtn, cfg)
		widget.name:setText(cfg.name)
		widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.steedRankIconId, true))
		widget.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(STEED_BG))
		widget.attribute:setText(cfg.rideNum > 1 and i3k_get_string(15537) or i3k_get_string(15536))
		if i == 1 then
			self._tag = cfg.id
			self:loadModuleAndName(cfg)
		end
		self.item_scroll:addItem(node)
	end
	self:updateScrollSelectState()
end

function wnd_ranking_list_RoleSteedSkin:sortShowIDs(showIDs)
	local tmp = {}
	local steedShowIDs = g_i3k_game_context:getSteedShowIDs()
	for k, v in pairs(showIDs) do
		local cfg = i3k_db_steed_huanhua[k]
		table.insert(tmp, {cfg = cfg, power = g_i3k_game_context:getSteedSkinPower(cfg)})
	end
	table.sort(tmp, function (a,b)
		return a.power > b.power
	end)
	return tmp
end

function wnd_ranking_list_RoleSteedSkin:onSelectBtn(sender, cfg)
	if self._tag ~= cfg.id then
		self._tag = cfg.id
		self:loadModuleAndName(cfg)
		self:updateScrollSelectState()
	end
end

function wnd_ranking_list_RoleSteedSkin:updateScrollSelectState()
	for i, e in ipairs(self.item_scroll:getAllChildren()) do
		e.vars.is_show:setVisible(e.vars.tag == self._tag)
		if e.vars.tag == self._tag then
			e.vars.select1_btn:stateToPressed()
		else
			e.vars.select1_btn:stateToNormal()
		end
	end	
end

function wnd_create(layout)
	local wnd = wnd_ranking_list_RoleSteedSkin.new()
	wnd:create(layout)
	return wnd
end
