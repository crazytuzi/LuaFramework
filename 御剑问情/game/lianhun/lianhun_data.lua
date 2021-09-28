LianhunData = LianhunData or BaseClass(BaseEvent)

function LianhunData:__init()
	if LianhunData.Instance then
		print_error("[LianhunData] Attempt to create singleton twice!")
		return
	end
	LianhunData.Instance = self
	local equipforge_auto_cfg = ConfigManager.Instance:GetAutoConfig("equipforge_auto")
	self.Lianhun_cfg = ListToMap(equipforge_auto_cfg.equipment_lianhun, "equip_index", "lianhun_level")
	self.lianhun_suit_cfg = ListToMap(equipforge_auto_cfg.equipment_lianhun_suit, "suit_level")
	RemindManager.Instance:Register(RemindName.Lianhun, BindTool.Bind(self.GetLianhunRemind, self))
end

function LianhunData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Lianhun)
	LianhunData.Instance = nil
end

function LianhunData:GetEquipLianhuncfg(equip_index, lianhun_level)
	if self.Lianhun_cfg[equip_index] then
		return self.Lianhun_cfg[equip_index][lianhun_level]
	end
	return nil
end

function LianhunData:GetEquipLianhunSuitcfg(suit_level)
	return self.lianhun_suit_cfg[suit_level]
end

function LianhunData:GetEquipLianhunSuitName(suit_level)
	if self.lianhun_suit_cfg[suit_level] then
		return self.lianhun_suit_cfg[suit_level].name
	end
	return ""
end

function LianhunData:GetEquipLianhunLevelName(equip_index, lianhun_level)
	if self.Lianhun_cfg[equip_index] and self.Lianhun_cfg[equip_index][lianhun_level] then
		return self.Lianhun_cfg[equip_index][lianhun_level].name
	end
	return ""
end

function LianhunData:GetLianhunRemind()
	local data_list = EquipData.Instance:GetGridInfo()
	for k, v in pairs(data_list) do
		local lianhun_level = v.lianhun_level or 0
		local cur_cfg = LianhunData.Instance:GetEquipLianhuncfg(k, lianhun_level)
		local next_cfg = LianhunData.Instance:GetEquipLianhuncfg(k, lianhun_level + 1)
		if cur_cfg and next_cfg then
			local num = ItemData.Instance:GetItemNumInBagById(cur_cfg.stuff_id)
			if cur_cfg.stuff_count <= num then
				return 1
			end
		end
	end
	return 0
end