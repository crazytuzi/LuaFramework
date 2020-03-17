--[[
装备格子展示VO
lizhuangzhuang
2015年1月21日20:21:13
]]

_G.ShowEquipSlotVO = {};

ShowEquipSlotVO.hasItem = false;--是否有东西
ShowEquipSlotVO.pos = 0;--格子位置
ShowEquipSlotVO.tid = 0;--物品id
ShowEquipSlotVO.bagType = 0;--展示的背包类型(人物or坐骑or人物道具)
ShowEquipSlotVO.strenLvl = 0;--强化等级
ShowEquipSlotVO.bindState = 0;--绑定状态
ShowEquipSlotVO.count = 0;--数量，默认不显示
ShowEquipSlotVO.equipGroupId = 0; --装备套装id’
ShowEquipSlotVO.shenWuLevel = 0; --神武等级
ShowEquipSlotVO.shenWuStar = 0; --神武星级

function ShowEquipSlotVO:new()
	local obj = {};
	for k,v in pairs(ShowEquipSlotVO) do
		obj[k] = v;
	end
	obj.bindState = BagConsts.Bind_Bind;
	return obj;
end

function ShowEquipSlotVO:GetShowBind()
	if self.bindState==BagConsts.Bind_GetBind or self.bindState==BagConsts.Bind_Bind then
		return true;
	end
	return false;
end

function ShowEquipSlotVO:GetQuality()
	if not self.hasItem then return 0; end
	if t_equip[self.tid] then
		return t_equip[self.tid].quality;
	end
	if t_item[self.tid] then
		return t_item[self.tid].quality;
	end
	return 0;
end

function ShowEquipSlotVO:GetQualityUrl(bOtherRole)
	if not self.hasItem then return ""; end
	local size = nil

	local pos = self.pos + 1
	if bOtherRole then
		if pos == 1 or pos == 3 then
			size = 128
		elseif pos == 2 or pos == 4 or pos == 5 or pos == 6 or pos == 7 then
			size = 96
		end
	end

	if not self.hasItem then return ""; end
	if BagUtil:GetItemShowType(self.tid) == BagConsts.ShowType_Equip then
		if t_equip[self.tid] then
			return ResUtil:GetSlotQuality(t_equip[self.tid].quality, size), size or 0;
		else
			return "", size or 0;
		end
	end
	if t_item[self.tid] then
		return ResUtil:GetSlotQuality(t_item[self.tid].quality, size), size or 0;
	end
	return "", size or 0;
end

function ShowEquipSlotVO:GetSuper()
	if not self.hasItem then return 0; end
	if BagUtil:GetItemShowType(self.tid) == BagConsts.ShowType_Equip then
		local quality = self:GetQuality();
		if t_equip[self.tid].pos > 10 then
			return 0;
		end
		if quality == BagConsts.Quality_Green1 then
			return 1;
		elseif quality == BagConsts.Quality_Green2 then
			return 2;
		elseif quality == BagConsts.Quality_Green3 then
			return 3;
		end
		return 0;
	end
	return 0;
end

--获取是否有套装
function ShowEquipSlotVO:GetIsShowEquipGroup()
	if not self.hasItem then return "" end
	if self.pos == BagConsts.Equip_WuQi and self.shenWuLevel > 0 then
		return ResUtil:GetShenWuSlotIcon(self.shenWuLevel, self.shenWuStar)
	end
	local val = EquipModel:GetGroupId2(self.id);
	local groupId = 0;
	if self.equipGroupId and self.equipGroupId > 0 then 
		groupId = self.equipGroupId;
	else
		groupId = val;
	end;
	if groupId and groupId > 0 then 
		local cfg = t_equipgroup[groupId]
		if cfg  then 
			return ResUtil:GetNewEquipGrouNameIcon(cfg.nameicon,nil,true)
		end;
		return ""
	end;
	return "";
end;

function ShowEquipSlotVO:GetUIData(bOtherRole)
	local data = {};
	data.pos = self.pos;
	if self.bagType==BagConsts.BagType_Role or self.bagType==BagConsts.BagType_Horse
		or self.bagType == BagConsts.BagType_LingShou or self.bagType == BagConsts.BagType_LingShouHorse or
			self.bagType == BagConsts.BagType_MingYu or
			self.bagType == BagConsts.BagType_Armor or
			self.bagType == BagConsts.BagType_MagicWeapon or
			self.bagType == BagConsts.BagType_LingQi then
		data.zbwPos = BagUtil:GetEquipAtBagPos(self.bagType,self.pos);
	elseif self.bagType == BagConsts.BagType_RoleItem then
		data.zbwPos = 50;
	elseif self.bagType == BagConsts.BagType_RELIC then
		data.zbwPos = 75 + self.pos
	end
	if self.hasItem then
		data.hasItem = true;
		data.bagType = self.bagType
		data.tid = self.tid;
		data.count = 1
		data.showCount = false
		data.iconUrl = bOtherRole and BagUtil:GetEquipIcon(self.tid) or BagUtil:GetItemIcon(self.tid);
		data.qualityUrl, data.size = self:GetQualityUrl(bOtherRole)
		data.quality = self:GetQuality();
		data.biaoshiUrl = "";
		data.strenLvl = self.strenLvl;
		data.super = self:GetSuper();
		data.showBind = self:GetShowBind();
		data.count = self.count;
		data.groupBsUrl = self:GetIsShowEquipGroup();
	else
		data.hasItem = false;
	end
	return UIData.encode(data);
end

