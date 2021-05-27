--------------------------------------------------------
--神装
--------------------------------------------------------
GodEquipData = GodEquipData or BaseClass(BaseData)
local GodEquipConfig = GodEquipConfig
function GodEquipData:__init()
	if GodEquipData.Instance then
		ErrorLog("[GodEquipData] Attemp to create a singleton twice !")
	end
	GodEquipData.Instance = self

	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetAnyEquipCanUp, self), RemindName.GodEquipCanUp)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetAnyEquipCanDecompose, self), RemindName.GodEquipCanDecompose)
end

function GodEquipData:__delete()
	GodEquipData.Instance = nil
end

function GodEquipData.GetFitEqItemId(cfg_eqs, prof, sex)
	if #cfg_eqs == 3 then
		return cfg_eqs[prof]
	else
		return cfg_eqs[((prof - 1) * 2) + (sex + 1)]
	end
end

function GodEquipData.GetConsumeItemId()
	return GodEquipConfig.godEquipList[1][1].upConsume[1].id
end

-- 获取到一下个属性更高的红装
function GodEquipData:GetNextGodEquip(slot)
	local equip_data = EquipData.Instance:GetEquipDataBySolt(slot)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	if equip_data then
		local cur_eq_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
		local cur_eq_score = ItemData.Instance:GetItemScore(cur_eq_cfg)

		local god_eq_list = GodEquipConfig.godEquipList[slot + 1] or {}
		local item_id
		for k, v in ipairs(god_eq_list) do
			item_id = GodEquipData.GetFitEqItemId(v.itemId, prof, sex)
			if item_id then
				local cfg = ItemData.Instance:GetItemConfig(item_id)
				local score = ItemData.Instance:GetItemScore(cfg)
				if score > cur_eq_score then
					local eq = CommonStruct.ItemDataWrapper()
					eq.item_id = item_id
					return eq, v
				end
			end
		end
		return nil
	else
		local god_eq_list = GodEquipConfig.godEquipList[slot + 1] or {}
		local item_id
		for k, v in ipairs(god_eq_list) do
			item_id = GodEquipData.GetFitEqItemId(v.itemId, prof, sex)
			if item_id then
				local eq = CommonStruct.ItemDataWrapper()
				eq.item_id = item_id
				return eq, v
			end
		end
	end
end

function GodEquipData:IsEnoughToUp(equip_slot)
	local _, equip_cfg = GodEquipData.Instance:GetNextGodEquip(equip_slot)
	local equip_data = EquipData.Instance:GetEquipDataBySolt(equip_slot)
	local is_god_equip = equip_data and ItemData.Instance:IsGodEquip(equip_data.item_id) or false
	if equip_cfg then
		local consume_cfg = is_god_equip and equip_cfg.upConsume or equip_cfg.forgeConsume
		if consume_cfg and consume_cfg[1] then
			local need_num = consume_cfg[1].count
			local bag_num = BagData.Instance:GetItemNumInBagById(consume_cfg[1].id)
			return bag_num >= need_num
		end
	end
	return false
end

-- 有神装可提升
function GodEquipData:GetAnyEquipCanUp()
	for i = EquipData.EquipSlot.itWeaponPos, EquipData.EquipSlot.itBaseEquipMaxPos do
		if self:IsEnoughToUp(i) then
			return 1
		end
	end
	return 0
end

-- 有神装可提分解
function GodEquipData:GetAnyEquipCanDecompose()
	local cfg = EquipDecomposeConfig[EQUIP_DECOMPOSE_TYPES.GOD_EQUIP]
	local item_map = cfg.itemList
	local item_data_list = {}
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		if item_map[v.item_id] then
			return 1
		end
	end

	return 0
end
