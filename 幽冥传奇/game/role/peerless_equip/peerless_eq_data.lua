PeerlessEqData = PeerlessEqData or BaseClass()

function PeerlessEqData:__init()
	if PeerlessEqData.Instance then
		ErrorLog("[PeerlessEqData]:Attempt to create singleton twice!")
	end
	PeerlessEqData.Instance = self
	
end

function PeerlessEqData:__delete()
	PeerlessEqData.Instance = nil
end

function PeerlessEqData.InitPeerlessAttrs()
	return {
		{type = 9, value = 0},
		{type = 11, value = 0},
		{type = 13, value = 0},
		{type = 15, value = 0},
		{type = 17, value = 0},
		{type = 19, value = 0},
		{type = 21, value = 0},
		{type = 23, value = 0},
		{type = 25, value = 0},
		{type = 27, value = 0},
	}
end

function PeerlessEqData.GetPeerLessAttr()
	local peerless_attr = PeerlessEqData.InitPeerlessAttrs()
	for k,v in pairs(EquipData.Instance:GetDataList()) do
		if k >= EquipData.EquipIndex.PeerlessWeaponPos and k <= EquipData.EquipIndex.PeerlessShoesPos then
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				peerless_attr = CommonDataManager.AddAttr(peerless_attr, item_cfg.staitcAttrs)
			end
			local xuelian_cfg = EquipmentData.GetBmStrengthenAttrCfg(k - EquipData.EquipIndex.PeerlessWeaponPos + 1)
			if xuelian_cfg then
				peerless_attr = CommonDataManager.AddAttr(peerless_attr, xuelian_cfg)
			end
		end
	end
	local xuelian_add_level = RoleRuleData.GetXueLianTipsLevel()
	local xuelian_add_cfg = RoleRuleData.GetConfigData(4, xuelian_add_level)
	if xuelian_add_level > 0 and xuelian_add_cfg then
		peerless_attr = CommonDataManager.AddAttr(peerless_attr, xuelian_add_cfg.attrs)
	end
	local peerless_suit_level = EquipData.Instance:GetPeerlessEquipLevel()
	local peerless_suit_cfg = RoleRuleData.GetConfigData(5, peerless_suit_level)
	if peerless_suit_level > 0 and peerless_suit_cfg then
		peerless_attr = CommonDataManager.AddAttr(peerless_attr, peerless_suit_cfg.attrs)
	end
	return peerless_attr
end