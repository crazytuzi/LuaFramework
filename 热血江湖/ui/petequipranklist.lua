
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_petEquipRankList = i3k_class("wnd_petEquipRankList",ui.wnd_base)

--拥有佣兵 选中效果
local HAVE_PET		= 707
local SELECT_BG		= 706

local petstar_icon = {405,409,410,411,412,413}

--随从榜、神兵榜、内甲榜、坐骑榜tips
local petPower_rank = 3

function wnd_petEquipRankList:ctor()
	self._info = {}
	self._id = 0
	self._equipParts = {}
end

function wnd_petEquipRankList:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	self:initPetEquipWidget(widgets)
end

function wnd_petEquipRankList:refresh(info, equipParts, id)
	self._info = info
	self._id = id
	self._equipParts = equipParts
	
	local firstNode = self:setInfo(id, info)
	if firstNode then
		self:updateSelectedListItem(firstNode.vars.select1_btn)
	end
end

--初始化宠物装备控件
function wnd_petEquipRankList:initPetEquipWidget(widgets)
	self.pet_equip = {}
	for i = 1, g_PET_EQUIP_PART_COUNT do
		local equip_btn = "equip" .. i
		local equip_icon = "equip_icon" .. i
		local grade_icon = "grade_icon" .. i
		local is_select = "is_select" .. i
		local level_label = "qh_level" .. i
		local red_tips = "tips" .. i

		self.pet_equip[i] = {
			equip_btn = widgets[equip_btn],
			equip_icon = widgets[equip_icon],
			grade_icon = widgets[grade_icon],
			is_select = widgets[is_select],
			level_label = widgets[level_label],
			red_tips = widgets[red_tips],
		}
	end
end

--设置装备信息
function wnd_petEquipRankList:updateProfile(petID)
	local group = i3k_db_mercenaries[petID].petGroup
	if not self._equipParts[group] then
		self._equipParts[group] = {petGroupID = group, equip = {}, upLvls = {}}
	end
	local petEquips = self._equipParts[group].equip
	local upLvls = self._equipParts[group].upLvls

	for i, v in ipairs(self.pet_equip) do
		if i <= #i3k_db_pet_equips_part then
			local equipID = petEquips[i]
			local upLvl = upLvls[i] or 0
			if equipID then
				local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(equipID)
				v.equip_btn:enable()
				v.equip_icon:show()
				v.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
				v.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
				v.equip_btn:onClick(self, self.onSelectEquip, {id = equipID, group = group, partID = i, isOut = true, isRankList = true, upLvl = upLvl})
				if upLvl then
					v.level_label:setVisible(upLvl ~= 0)
					v.level_label:setText("+" .. upLvl)
				end
			else
				v.equip_btn:disable()
				v.equip_icon:hide()
				v.grade_icon:setImage(g_i3k_get_icon_frame_path_by_pos(i))
				v.level_label:hide()
			end
		else
			v.equip_icon:setImage()--一张灰化的图
			v.grade_icon:setImage(g_i3k_get_icon_frame_path_by_pos(i))
			v.level_label:hide()
			v.equip_btn:onClick(self, function()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1537))
			end)
		end
		v.red_tips:hide()
		v.is_select:hide()
	end
end

function wnd_petEquipRankList:onSelectEquip(sender, data)
	for i, v in ipairs(self.pet_equip) do
		v.is_select:setVisible(i == data.partID)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_PetEquipInfoTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipInfoTips, data)
end

function wnd_petEquipRankList:updateSelectedListItem(sender)
	for i, e in ipairs(self._layout.vars.item_scroll:getAllChildren()) do
		if e.vars.select1_btn.actType == sender.actType then
			e.vars.is_show:show()
			e.vars.select1_btn:stateToPressed()
		else
			e.vars.select1_btn:stateToNormal()
			e.vars.is_show:hide()
		end
	end
end

function wnd_petEquipRankList:setInfo(id, info)
	local firstNode = self:setPetsInfo(id,info)
	return firstNode
end

--设置佣兵的信息
function wnd_petEquipRankList:setPetsInfo(id,info)
	self._layout.vars.item_scroll:removeAllChildren()
	local firstNode
	for i,v in ipairs(info) do
		local pht = require("ui/widgets/scxxt")()--sbxxt,zqxxt
		pht.vars.select1_btn.actType = i
		if i == 1 then
			firstNode = pht
			self._layout.vars.battle_power:setText(v.fightPower)-- 战力
			local cfg = g_i3k_db.i3k_db_get_pet_cfg(v.id).modelID
			if v.awakeUse and v.awakeUse.use and v.awakeUse.use == 1 then
				cfg = i3k_db_mercenariea_waken_property[v.id].modelID
			end
			self:SetModule(cfg, true)
			self:updateProfile(v.id)
		end
		local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(v.id)
		local iconid = cfg_data.icon
		if v.awakeUse and v.awakeUse.use and v.awakeUse.use == 1 then
			iconid = i3k_db_mercenariea_waken_property[v.id].headIcon;
		end
		local name = v.name ~= "" and v.name or cfg_data.name
		pht.vars.name:setText(name)
		pht.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconid, true))

		pht.vars.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(HAVE_PET))
		pht.vars.qlvl:setText(v.level)

		local transfer_lvl = 0
		for i,e in ipairs (i3k_db_suicong_transfer) do
			if v.level >= e.maxLvl then
				transfer_lvl = e.level
			end
		end
		local str = i3k_get_string(1538, transfer_lvl)
		pht.vars.attribute:setText(str)
		pht.vars.slvl:setImage(g_i3k_db.i3k_db_get_icon_path(petstar_icon[v.star + 1]))--star_icon[starlvl + 1]

		if v.id < 0 then --机器人
			local robot = i3k_db_arenaRobot[math.abs(v.id)]
			v.fightPower = robot.power
		end

		pht.vars.select1_btn:setTag(v.id)
		pht.vars.select1_btn:onClick(self, self.checkRoleInfo, {fightPower =v.fightPower,index =petPower_rank, awakeUse = v.awakeUse})
		self._layout.vars.item_scroll:addItem(pht)
	end
	return firstNode
end

function wnd_petEquipRankList:checkRoleInfo(sender, needValue)
	self:updateSelectedListItem(sender)
	local myId = g_i3k_game_context:GetRoleId()
	local targetId = sender:getTag()
	self._layout.vars.battle_power:setText(needValue.fightPower)-- 战力

	local cfg = g_i3k_db.i3k_db_get_pet_cfg(targetId).modelID
	if needValue.awakeUse and needValue.awakeUse.use and needValue.awakeUse.use == 1 then
		cfg = i3k_db_mercenariea_waken_property[targetId].modelID;
	end
	self:SetModule(cfg, true)
	self:updateProfile(targetId)
end

--添加模型 id
function wnd_petEquipRankList:SetModule(id, isRotation)----模型id
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self._layout.vars.hero_module:setSprite(path)
	self._layout.vars.hero_module:setSprSize(uiscale)
	self._layout.vars.hero_module:playAction("stand")
	if isRotation then
		self._layout.vars.hero_module:setRotation(2);
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_petEquipRankList.new()
	wnd:create(layout, ...)
	return wnd;
end

