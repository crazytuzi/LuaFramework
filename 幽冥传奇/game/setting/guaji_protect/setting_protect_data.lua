SettingProtectData = SettingProtectData or BaseClass()
function SettingProtectData:__init()
	if SettingProtectData.Instance ~= nil then
		ErrorLog("[SettingProtectData] Attemp to create a singleton twice !")
	end
	SettingProtectData.Instance = self
end

function SettingProtectData:__delete()

end

function SettingProtectData.CheckPickFallItemSetting(fall_item)
	if nil == fall_item then return false end
	-- 自动拾取的物品列表
	local auto_pick_up_list = SettingData.Instance:GetAutoPickUpList()
	local _, _, _, _, money_select = SettingData.Instance:GetSelectOptionData()
	-- if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_COIN) and 0 == fall_item.item_id and fall_item.item_num >= (SettingData.MONEY[money_select + 1] or 0) then
	-- 	return true
	-- end
	if nil ~= auto_pick_up_list[fall_item.item_id] then
		return auto_pick_up_list[fall_item.item_id]
	elseif ItemData.GetIsDrug(fall_item.item_type) then
		if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_DRUG) then
			return true
		end
	elseif ItemData.GetIsStuff(fall_item.item_type) then
		if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_STUFF) then
			return true
		end
	
	elseif ItemData.GetIsBasisEquip(fall_item.item_id) then -- 判断是否是"基础"装备
		if SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_EQUIP) then
			local _, _, _, pick_eq_select = SettingData.Instance:GetSelectOptionData()
			local data = SettingData.PICK_EQLV[pick_eq_select + 1]
			local item_cfg = ItemData.Instance:GetItemConfig(fall_item.item_id)
			if data and item_cfg.orderType and item_cfg.orderType >= data then
				return true
			end
		end
	 elseif ItemData.IsPeerlessEquip(fall_item.item_type) then -- 判断是否是"传世"装备

		return SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_CS_EQUIP)
		
	elseif SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_PICKUP_OTHER) then
		return true
	end
	return false
end

function SettingProtectData.HasSpecificDrug()
	local hp_select, mp_select = SettingData.Instance:GetSelectOptionData()
	if not BagData.Instance:GetItemNumInBagById(SettingData.DRUG_T[hp_select + 1]) then
		return false
	end
	if not BagData.Instance:GetItemNumInBagById(SettingData.DRUG_T[mp_select + 1]) then
		return false
	end

	return false
end

SettingProtectData.per_shop_cfg = nil -- 快捷商店配置
function SettingProtectData.GetUsableDrugCfg(is_remission)
	if nil == SettingProtectData.per_shop_cfg then
		SettingProtectData.per_shop_cfg = ConfigManager.Instance:GetServerConfig("store/ShangPu/5ShiZhuangShenQi")[1].items
	end

	for k,v in pairs(SettingProtectData.per_shop_cfg) do
		if is_remission then
			local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
			local cur_circle = 0
			local item_id = SettingData.REMISSION_DRUG[1]
			for k,v in pairs(SettingData.REMISSION_DRUG) do
				local lv, circle = ItemData.GetItemLevel(v)
				if circle <= role_circle and cur_circle <= circle then 
					cur_circle = circle
					item_id = v
				end
			end
			if v.item == item_id then
				local obj_attr_index = ShopData.GetMoneyObjAttrIndex(v.price[1].type)
				local role_money = RoleData.Instance:GetAttr(obj_attr_index) or 0
				if role_money >= v.price[1].price * v.buyOnceCount then
					return v
				end
			end
		elseif not is_remission and SettingProtectData.IsSpectficDrug(v.item) then
			local hp_select, mp_select = SettingData.Instance:GetSelectOptionData()
			local drug_id_hp =	SettingData.DRUG_T[hp_select + 1]
			local drug_id_mp =	SettingData.DRUG_T[mp_select + 1]
			local obj_attr_index = ShopData.GetMoneyObjAttrIndex(v.price[1].type)
			local role_money = RoleData.Instance:GetAttr(obj_attr_index) or 0
			if drug_id_hp == v.item and role_money >= v.price[1].price * v.buyOnceCount and not BagData.Instance:GetOneItem(drug_id_hp) then
				return v
			end
			if drug_id_mp == v.item and role_money >= v.price[1].price * v.buyOnceCount and not BagData.Instance:GetOneItem(drug_id_mp) then
				return v
			end

		end
	end
	return nil
end

function SettingProtectData.IsSpectficDrug(item_id)
	for k,v in pairs(SettingData.DRUG_T) do
		if v == item_id then
			return true
		end
	end
	return false
end

function SettingProtectData.SettingPlayNow(channel)
	if SettingData.Instance:GetOneSysSetting(SETTING_TYPE.NEAR_C_SPEECH) and channel == CHANNEL_TYPE.NEAR then
		return true
	elseif SettingData.Instance:GetOneSysSetting(SETTING_TYPE.WORLD_C_SPEECH) and channel == CHANNEL_TYPE.WORLD then
		return true
	elseif SettingData.Instance:GetOneSysSetting(SETTING_TYPE.GUILD_C_SPEECH) and channel == CHANNEL_TYPE.GUILD then
		return true
	elseif SettingData.Instance:GetOneSysSetting(SETTING_TYPE.TEAM_C_SPEECH) and (channel == CHANNEL_TYPE.TEAM or channel == CHANNEL_TYPE.BIGTEAM) then
		return true
	elseif SettingData.Instance:GetOneSysSetting(SETTING_TYPE.PRIVATE_C_SPEECH) and channel == CHANNEL_TYPE.PRIVATE then
		return true
	elseif SettingData.Instance:GetOneSysSetting(SETTING_TYPE.SPEAKER_C_SPEECH) and channel == CHANNEL_TYPE.SPEAKER then
		return true
	end
	return false

end