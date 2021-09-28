-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/steedRankBase")

-------------------------------------------------------

wnd_ranking_list_RoleSteedFight = i3k_class("wnd_ranking_list_RoleSteedFight",ui.wnd_steedRankBase)

local STEED_BG = 707 

function wnd_ranking_list_RoleSteedFight:ctor()
	self._info = nil
	self._id = nil
	self._showIDs = nil
	self._tag = nil
	self._masters = nil
	self._steedSpirit = nil
	self._steedEquip = nil
end

function wnd_ranking_list_RoleSteedFight:configure()
	-- 重写父类
	ui.wnd_steedRankBase.configure(self)
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.mashu = widgets.mashu
	self.steedJd = widgets.steedJd
	self.steedSpiritRoot = widgets.steedSpiritRoot
	self.battle_power = widgets.battle_power
	self.fight_power = widgets.fight_power
	self.lvl = widgets.lvl;
	self.scroll = widgets.scroll

	widgets.steedFightBtn:stateToPressed()
end

function wnd_ranking_list_RoleSteedFight:refresh(data)
	-- 重写父类
	ui.wnd_steedRankBase.setSteedRankBaseData(self, data)

	local widgets = self._layout.vars
	self._id = data.id
	self._info = data.info
	self._showIDs = data.showIDs
	self._masters = data.masters
	self._steedSpirit = data.steedSpirit
	self._steedEquip = data.steedEquip

	widgets.mashu:show()
	widgets.steedJd:hide()
	widgets.lvl:setText("坐骑精通等级："..#self._masters.."级")
	widgets.battle_power:hide()
	if self._masters and (next(self._masters) ~= nil or self._steedSpirit.star > 0) then
		widgets.steedFightBtn:show();
	else
		widgets.steedFightBtn:hide();
	end
	widgets.steedSpiritBtn:setVisible(self._steedSpirit.star > 0)
	widgets.steedEquipBtn:setVisible(data.roleOverview.level >= i3k_db_steed_equip_cfg.openLevel)
	self:loadScroll(self._masters)
end

function wnd_ranking_list_RoleSteedFight:loadModuleAndName(cfg)
	self.battle_power:setText(g_i3k_game_context:getSteedSkinPower(cfg))
end

function wnd_ranking_list_RoleSteedFight:Sort(tbl)
	local _cmp = function(d1, d2)
		return d1.propID < d2.propID;
	end
	table.sort(tbl, _cmp);
end

function wnd_ranking_list_RoleSteedFight:loadScroll(masters)
	self.scroll:removeAllChildren()
	local data = {}
	local propTb = {}
	local prop = {}		
	for i, e in ipairs(masters) do
		local mastersData = i3k_db_steed_fight_up_prop[i];
		for k,v in pairs(e.unLocks) do
			if mastersData.propTb[k] then
				table.insert(data, mastersData.propTb[k])
			end
		end
	end
	
	for _, e in ipairs(data) do
		for __, ee in ipairs(e) do
			if ee.propID ~= 0 then
				if propTb[ee.propID] then
					propTb[ee.propID] = propTb[ee.propID] + ee.propValue
				else
					propTb[ee.propID] = ee.propValue
				end
			end
		end
	end
	self.fight_power:setText(g_i3k_db.i3k_db_get_battle_power(propTb, true))
	for k,v in pairs(propTb) do
		table.insert(prop, {propID = k, propValue = v})
	end
	local children = self.scroll:addChildWithCount("ui/widgets/qtxxt2", 2, #prop)
	self:Sort(prop);
	for i, e in ipairs(prop) do
		local widget = children[i].vars	
		local icon = g_i3k_db.i3k_db_get_property_icon(e.propID)
		widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(e.propID))
		widget.propertyValue:setText(i3k_get_prop_show(e.propID, e.propValue))
	end
end

function wnd_create(layout)
	local wnd = wnd_ranking_list_RoleSteedFight.new()
	wnd:create(layout)
	return wnd
end
