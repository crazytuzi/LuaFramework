LuxuryEquipUpgradeData = LuxuryEquipUpgradeData or BaseClass()

function LuxuryEquipUpgradeData:__init()
	if LuxuryEquipUpgradeData.Instance then
		ErrorLog("[LuxuryEquipUpgradeData] attempt to create singleton twice!")
		return
	end
	LuxuryEquipUpgradeData.Instance = self
end

function LuxuryEquipUpgradeData:__delete()
end

function LuxuryEquipUpgradeData:GetRewardRemind()
	return 0
end

function LuxuryEquipUpgradeData:GetUpgradeCfg(pos, item_id)
	return  HoweEquipSynthesisCfg.list[pos][item_id]
end

function LuxuryEquipUpgradeData:FarmatCellData(data)
	if 0 == data.item_id then
		return {}
	end
	local item_num = BagData.Instance:GetItemNumInBagById(data.item_id)
	return {item_id = data.item_id, is_bind = 0, num = item_num, need_num = data.num or 1}
end


function LuxuryEquipUpgradeData:GetCanUpgradeByPos(equip_pos)
	local equip_data = EquipData.Instance:GetEquipDataBySolt(equip_pos) 
	local item_id = equip_data and equip_data.item_id or 0
	local cfg = self:GetUpgradeCfg(equip_pos, item_id)
	if cfg then
		local num = 0
		for k, v in pairs(cfg.consume or {}) do
			if v.type > 0 then
				if RoleData.Instance:GetMainMoneyByType(v.type) >= v.count then
					num = num + 1
				end
			else
				local count = v.count
				if #cfg.consume >=2 then
					if cfg.consume[1].id == (cfg.consume[2] and cfg.consume[2].id or -1)  then -- ID
						count = cfg.consume[1].count + cfg.consume[2].count
					end
				end
				if BagData.Instance:GetItemNumInBagById(v.id, nil) >= count then
					num = num + 1
				end
			end
		end
		if num >= #cfg.consume  then
			return true
		end
	end
	return false
end

LuxuryEquipUpgradeData_Pos = {
	[1] = {
		{equip_slot = EquipData.EquipSlot.itSubmachineGunPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itOpenCarPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
	},
	[2] = {
		{equip_slot = EquipData.EquipSlot.itAnCrownPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itGoldChainPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itGoldPipePos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itRolexPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itDiamondRingPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
	},
	[3] = {
		{equip_slot = EquipData.EquipSlot.itJazzHatPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itGoldDicePos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itGoldenSkullPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itGlobeflowerPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itGentlemenBootsPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
	}
}


function LuxuryEquipUpgradeData:GetCanUpIndex(index)
	if ViewManager.Instance:CanOpen(ViewDef.CrossBoss.LuxuryEquipCompose) then

		local cfg = LuxuryEquipUpgradeData_Pos[index]
		if cfg ~= nil then
			for k,v in pairs(cfg) do
				if self:GetCanUpgradeByPos(v.equip_slot) then
					return 1
				end
			end
		end
		return 0
	end
end