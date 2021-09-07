ShenBingData = ShenBingData or BaseClass()

ShenBingDanId = {
	ZiZhiDanId = 22106,
}

ShenBingMaxLevel = 1000

ShenBingShuXingDanCfgType = {
	Type = 11
}

function ShenBingData:__init()
	if ShenBingData.Instance then
		print_error("[ShenBingData] Attemp to create a singleton twice !")
		return
	end
	ShenBingData.Instance = self
	self.shenbing_info = {}
	self.shenbing_cfg = ConfigManager.Instance:GetAutoConfig("shenbingconfig_auto")
	RemindManager.Instance:Register(RemindName.PlayerShenBing, BindTool.Bind(self.GetRemind, self))
	self.shenbing_level_cfg = ListToMap(self.shenbing_cfg.level_attr or {}, "level")
end

function ShenBingData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerShenBing)
	ShenBingData.Instance = nil
	self.shenbing_info = {}
end

function ShenBingData:GetRemind()
	return (OpenFunData.Instance:CheckIsHide("player_role_shenbing") and ( self:GetShenBingLevelRemind() or self:GetShenBingZiZhiRemind()) ) and 1 or 0
end

function ShenBingData:GetShenBingLevelRemind()
	if next(self.shenbing_info) then
		if self.shenbing_info.level >= ShenBingMaxLevel then return false end
		for i=1,3 do
	    	local cur_item_id = self:GetUpLevelCfg(i - 1).up_level_item_id
			local num = ItemData.Instance:GetItemNumInBagById(cur_item_id)
			if num > 0 then return true end
	    end
	end
    return false
end

function ShenBingData:GetShenBingZiZhiRemind()
    return ItemData.Instance:GetItemNumInBagById(ShenBingDanId.ZiZhiDanId) > 0
end

function ShenBingData:SetShenBingInfo(protocol)
	self.shenbing_info.level = protocol.level
	self.shenbing_info.use_image = protocol.use_image
	self.shenbing_info.shuxingdan_count = protocol.shuxingdan_count
	self.shenbing_info.exp = protocol.exp
end

function ShenBingData:GetShenBingInfo()
	return self.shenbing_info
end

function ShenBingData:GetShenBingCfg()
	return self.shenbing_cfg
end

function ShenBingData:GetIsActive(skill_index)
	if next(self.shenbing_info) then
		for k,v in pairs(self.shenbing_cfg.skill) do
			if v.skill_idx == skill_index and self.shenbing_info.level >= v.shenbing_level then
				return true
			end
		end
	end
	return false
end

function ShenBingData:GetShenBingSkillCfg(index)
	for k,v in pairs(self.shenbing_cfg.skill) do
		if index == v.skill_idx then
			return v
		end
	end
end

function ShenBingData:GetLimitXingDanCount(level)
	local level = level or self.shenbing_info.level or 1
	-- for k,v in pairs(self.shenbing_cfg.level_attr) do
	-- 	if v.level == level then
	-- 		return v.shuxingdan_limit
	-- 	end
	-- end
	if self.shenbing_level_cfg then
		return self.shenbing_level_cfg[level].shuxingdan_limit
	end
	return 0
end

function ShenBingData:GetUpLevelCfg(up_level_index)
	for k,v in pairs(self.shenbing_cfg.up_level_stuff) do
		if v.up_level_item_index == up_level_index then
			return v
		end
	end
end

function ShenBingData:GetLevelAttrCfg(level)
	-- for k,v in pairs(self.shenbing_cfg.level_attr) do
	-- 	if v.level == level then
	-- 		return v
	-- 	end
	-- end
	if self.shenbing_level_cfg then
		return self.shenbing_level_cfg[level]
	end
end

function ShenBingData:CheckSelectItem(cur_index)
	local cur_item_id = self:GetUpLevelCfg(cur_index).up_level_item_id
	local num = ItemData.Instance:GetItemNumInBagById(cur_item_id)
	if num > 0 then return cur_index end

	for k,v in pairs(self.shenbing_cfg.up_level_stuff) do
		if v.up_level_item_id ~= cur_item_id then
			local num = ItemData.Instance:GetItemNumInBagById(v.up_level_item_id)
			if num > 0 then return v.up_level_item_index end
		end
	end

	return self.shenbing_cfg.up_level_stuff[1].up_level_item_index
end

function ShenBingData:CheckPlayEffect(level)
	return next(self.shenbing_info) and self.shenbing_info.level ~= level
end


