-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/steedRankBase")

-------------------------------------------------------

wnd_ranking_list_RoleSteedEquip = i3k_class("wnd_ranking_list_RoleSteedEquip",ui.wnd_steedRankBase)

local RowitemCount = 1

function wnd_ranking_list_RoleSteedEquip:ctor()
	self._info = nil
	self._id = nil
	self._showIDs = nil
	self._tag = nil
	self._masters = nil
	self._steedSpirit = nil
	self._steedEquip = nil

	self.steed_equip = {}
end

function wnd_ranking_list_RoleSteedEquip:configure()
	-- 重写父类
	ui.wnd_steedRankBase.configure(self)	

	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.mashu = widgets.mashu
	self.steedJd = widgets.steedJd
	self.steedSpiritRoot = widgets.steedSpiritRoot
	self.battle_power = widgets.battle_power
	self.battle_power2 = widgets.battle_power2
	self.fight_power = widgets.fight_power
	self.lvl = widgets.lvl;
	self.scroll = widgets.scroll
	self.steedFightBtn = widgets.steedFightBtn
	self.steedSpiritBtn = widgets.steedSpiritBtn
	self.steedEquipRoot = widgets.steedEquipRoot

	widgets.steedEquipBtn:stateToPressed()

	self:initSteedEquipWidget(widgets)
end

--初始化宠物装备控件
function wnd_ranking_list_RoleSteedEquip:initSteedEquipWidget(widgets)
	for i = 1, g_STEED_EQUIP_PART_COUNT do
		local equip_btn = "equip" .. i
		local equip_icon = "equip_icon" .. i
		local grade_icon = "bg_icon" .. i
		local is_select = "is_select" .. i
		local level_label = "qh_level" .. i
		local red_tips = "tips" .. i

		self.steed_equip[i] = {
			equip_btn = widgets[equip_btn],
			equip_icon = widgets[equip_icon],
			grade_icon = widgets[grade_icon],
			is_select = widgets[is_select],
			level_label = widgets[level_label],
			red_tips = widgets[red_tips],
		}
	end
end

function wnd_ranking_list_RoleSteedEquip:refresh(data)
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
	widgets.steedJd:hide()
	if self._masters and (next(self._masters) ~= nil or self._steedSpirit.star > 0) then
		widgets.steedFightBtn:show();
	else
		widgets.steedFightBtn:hide();
	end
	widgets.steedSpiritBtn:setVisible(self._steedSpirit.star > 0)
	widgets.steedEquipBtn:setVisible(data.roleOverview.level >= i3k_db_steed_equip_cfg.openLevel)
	widgets.steedEquipRoot:show()

	self:updateUI()
end

function wnd_ranking_list_RoleSteedEquip:updateUI()
	self:updateEquipUI()
	self:updateSuitScroll()
	self:updateSteedModel()
	self:setBattlePower()
end

--设置装备信息
function wnd_ranking_list_RoleSteedEquip:updateEquipUI()
	local steedEquips = self._steedEquip.curClothes
	for i, v in ipairs(self.steed_equip) do
		if i <= g_STEED_EQUIP_PART_COUNT then
			local equipID = steedEquips[i]
			if equipID then
				v.equip_btn:enable()
				v.equip_icon:show()
				v.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
				v.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
				v.equip_btn:onClick(self, self.onSelectEquip, {partID = i, equipID = equipID})
				v.level_label:hide()
			else
				v.equip_btn:disable()
				v.equip_icon:hide()
				v.grade_icon:setImage(g_i3k_get_steed_equip_icon_frame_path_by_pos(i))
				v.level_label:hide()
			end
		else
			v.equip_icon:setImage()--一张灰化的图
			v.grade_icon:setImage(g_i3k_get_steed_equip_icon_frame_path_by_pos(i))
			v.level_label:hide()
			v.equip_btn:onClick(self, function()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1537))
			end)
		end
		v.red_tips:hide()
		v.is_select:hide()
	end
	self:updateSuitUI()
end

--设置套装信息
function wnd_ranking_list_RoleSteedEquip:updateSuitUI()
	local widgets = self._layout.vars
	local wEquip = self._steedEquip.curClothes
	local suitData = self._steedEquip.allSuits

	widgets.des:setVisible(table.nums(wEquip) ~= 0)

	local isCanClick = false
	local suitID, count = g_i3k_db.i3k_db_get_steed_equip_need_show_suitIdAndCount(wEquip, suitData)
	if suitID and count then
		local totalNum = #i3k_db_steed_equip_suit[suitID].parts
		isCanClick = count >= totalNum

		widgets.des:setText(string.format("[%s] %s/%s", i3k_db_steed_equip_suit[suitID].name, count, totalNum))
		widgets.des:setTextColor(isCanClick and "ff1bff66" or "ffd02020")
		widgets.des:enableOutline(isCanClick and "ff443676" or "ff9fb8ff")
	end
end

function wnd_ranking_list_RoleSteedEquip:updateSuitScroll()
	local widgets = self._layout.vars
	local suitData = self._steedEquip.allSuits
	local data = {}
	for suitID in pairs(suitData) do
		table.insert(data, suitID)
	end

	table.sort(data, function(a, b)
		return a < b
	end)

	local allBars = widgets.suitScroll:addChildWithCount("ui/widgets/qtxxt4", RowitemCount, #data)
	for i, v in ipairs(allBars) do
		local suitID = data[i]
		local cfg = i3k_db_steed_equip_suit[suitID]
		v.vars.colorPoint:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imgID))
		v.vars.nameLabel:setText(cfg.name)
		v.vars.btn:disable()
	end
end

--设置骑战装备战力
function wnd_ranking_list_RoleSteedEquip:setBattlePower()
	local power = self:getSteedEquipFightPower()
	self.battle_power2:setText(power)
end

function wnd_ranking_list_RoleSteedEquip:onSelectEquip(sender, data)
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipPropCmp)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipPropCmp, data.equipID, g_STEED_EQUIP_TIPS_NONE)
end

function wnd_ranking_list_RoleSteedEquip:updateSteedModel()
	local widgets = self._layout.vars
	local showID = i3k_db_steed_equip_cfg.skinID
	local cfg = i3k_db_steed_huanhua[showID]
	ui_set_hero_model(widgets.steedModel, cfg.modelId)
	widgets.steedModel:playAction("show")
	if cfg.modelRotation ~= 0 then
		widgets.steedModel:setRotation(cfg.modelRotation)
	end
end

--当前穿戴装备总属性
function wnd_ranking_list_RoleSteedEquip:getSteedWearEquipProps()
	local props = {}
	local wEquip = self._steedEquip.curClothes
	for _, equipID in pairs(wEquip) do
		local property = g_i3k_game_context:GetOneSteedEquipBaseProps(equipID)
		for id, count in pairs(property) do
			props[id] = (props[id] or 0) + count
		end
	end
	return props
end

--已激活套装属性
function wnd_ranking_list_RoleSteedEquip:getSteedSuitProps()
	local props = {}
	local suitData = self._steedEquip.allSuits
	for suitID in pairs(suitData) do
		--套装属性
		local property = g_i3k_game_context:GetOneSteedEquipSuitProps(suitID)
		for id, count in pairs(property) do
			props[id] = (props[id] or 0) + count
		end
		--套装装备属性
		local parts = i3k_db_steed_equip_suit[suitID].parts
		for _, equipID in ipairs(parts) do
			local property = g_i3k_game_context:GetOneSteedEquipBaseProps(equipID)
			for id, count in pairs(property) do
				props[id] = (props[id] or 0) + count
			end
		end
	end
	return props
end

--骑战装备总战力
function wnd_ranking_list_RoleSteedEquip:getSteedEquipFightPower()
	--当前穿戴装备战力
	local wEquipProps = self:getSteedWearEquipProps()
	local wEquipPower = g_i3k_db.i3k_db_get_battle_power(wEquipProps, true)
	--已激活套装战力
	local suitProps = self:getSteedSuitProps()
	local suitPower = g_i3k_db.i3k_db_get_battle_power(suitProps, true)

	return wEquipPower + suitPower
end

function wnd_create(layout)
	local wnd = wnd_ranking_list_RoleSteedEquip.new()
	wnd:create(layout)
	return wnd
end
