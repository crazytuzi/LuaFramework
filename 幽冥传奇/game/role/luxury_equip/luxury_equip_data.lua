LuxuryEquipData = LuxuryEquipData or BaseClass()

function LuxuryEquipData:__init()
	if LuxuryEquipData.Instance then
		ErrorLog("[LuxuryEquipData] attempt to create singleton twice!")
		return
	end
	LuxuryEquipData.Instance = self
end

function LuxuryEquipData:__delete()
end

function LuxuryEquipData:GetRewardRemind()
	return 0
end

function LuxuryEquipData:GetUpgradeCfg(pos, item_id)
	for i = EquipData.EquipSlot.itMinLuxuryEquipPos, EquipData.EquipSlot.itMaxLuxuryEquipPos do
		EquipData.Instance:GetEquipDataBySolt(i)
	end
end


function LuxuryEquipData:GetCurAttrBySuitLevel(type,suitLevel)
	local config = SuitPlusConfig[type]
	if config then
		local cur_config = config.list[suitLevel]
		if cur_config then
			return cur_config.attrs
		end
	end
	return {}
end

