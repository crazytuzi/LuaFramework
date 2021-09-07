SuperVipData = SuperVipData or BaseClass()

function SuperVipData:__init()
	if SuperVipData.Instance then
		print_error("[SuperVipData] Attempt to create singleton twice!")
		return
	end
	SuperVipData.Instance = self
end

function SuperVipData:__delete()
	SuperVipData.Instance = nil
end

function SuperVipData:GetNeedChongzhiNum()
	local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto")
	return cfg.super_vip[1].svip_charge_gold or 0
end

function SuperVipData:GetShowLevel()
	local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto")
	return cfg.super_vip[1].show_level or 0
end