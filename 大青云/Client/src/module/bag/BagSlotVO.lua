--[[
背包格子VO(显示层VO)
lizhuangzhuang
2014年7月31日21:27:49
]]

_G.BagSlotVO = {}

BagSlotVO.bagType = -1;--背包类型
BagSlotVO.uiPos = 1; --UI格子索引,从1开始
BagSlotVO.pos = 0; --逻辑格子索引,从0开始
BagSlotVO.opened = false;--格子是否开启
BagSlotVO.hasItem = false;--格子上是否有物品
BagSlotVO.id = 0; --格子id
BagSlotVO.tid = 0;--物品id
BagSlotVO.count = 0;--物品数量
BagSlotVO.bindState = 0;--绑定状态
BagSlotVO.strenLvl = -1;--强化等级
BagSlotVO.flags = 0;--物品标志位
BagSlotVO.equipGroupId = 0; --装备套装id
BagSlotVO.customIconUrl = "";
BagSlotVO.relicLv = 0
function BagSlotVO:new()
	local obj = {};
	for k,v in pairs(BagSlotVO) do
		obj[k] = v;
	end
	return obj;
end

--获取图标路径
function BagSlotVO:GetIconUrl(bRole)
	if not self.opened then return ""; end
	if not self.hasItem then return ""; end
	if bRole then
		return BagUtil:GetEquipIcon(self.tid);
	else
		return BagUtil:GetItemIcon(self.tid);
	end
end

--是否显示数量
function BagSlotVO:GetIsShowCount()
	if not self.opened then return false; end
	if not self.hasItem then return false; end
	if BagUtil:GetItemShowType(self.tid) == BagConsts.ShowType_Equip then
		return false;
	end
	local itemConfig = t_item[self.tid];
	if not itemConfig then return false; end
	if itemConfig.repeats > 1 then
		return true;
	end
	return false;
end

--获取物品品质
function BagSlotVO:GetQualityUrl(bRole)
	if not self.opened then return ""; end
	if not self.hasItem then return ""; end
	local size = nil
	if bRole then
		if self.uiPos == 1 or self.uiPos == 3 then
			size = "big"
		elseif self.uiPos == 2 or self.uiPos == 4 or self.uiPos == 5 or self.uiPos == 6 or self.uiPos == 7 then
			size = "mid"
		else
			size = "small"
		end
	end

	if BagUtil:GetItemShowType(self.tid) == BagConsts.ShowType_Equip then
		if t_equip[self.tid] then
			return ResUtil:GetSlotQuality(t_equip[self.tid].quality, size);
		else
			return "";
		end
	end
	local surl = BagUtil:GetSSlotQuality(self.tid);
	if surl then return surl; end
	local quality = self:GetQuality()
	if quality == 0 then
		return ""
	end
	return ResUtil:GetSlotQuality(quality, size);
end

--获取品质
function BagSlotVO:GetQuality()
	if not self.opened then return 0; end
	if not self.hasItem then return 0; end
	if t_equip[self.tid] then
		return t_equip[self.tid].quality;
	end
	local cfg = t_item[self.tid]
	if cfg then
		if cfg.sub == BagConsts.SubT_Tianshenka then
			local bagVO = BagModel:GetBag(self.bagType);
			if not bagVO then return 0;end
			local itemVO = bagVO:GetItemByPos(self.pos);
			if not itemVO then return 0; end
			return NewTianshenUtil:GetShowQuality(itemVO:GetParam())
		end
		return cfg.quality;
	end
	return 0;
end

--获取强化等级
function BagSlotVO:GetStrenLvl()
	if not self.opened then return 0; end
	if not self.hasItem then return 0; end
	if self.relicLv > 0 then
		return t_newequip[self.relicLv].lv
	end
	if self.strenLvl > 0 then
		return self.strenLvl;
	end
	return EquipModel:GetStrenLvl(self.id);
end

--获取物品的剩余CD时间
function BagSlotVO:GetCD()
	if not self.opened then return 0; end
	if not self.hasItem then return 0; end
	local bagVO = BagModel:GetBag(self.bagType);
	if not bagVO then return 0;end
	local itemVO = bagVO:GetItemByPos(self.pos);
	if not itemVO then return 0; end
	local cfg = itemVO:GetCfg();
	if cfg and cfg.cd and cfg.cd>0 then
		return BagModel:GetItemCD(self.tid);
	end
	return 0;
end

--获取物品的总CD时间
function BagSlotVO:GetTotalCD()
	if not self.opened then return 0; end
	if not self.hasItem then return 0; end
	local bagVO = BagModel:GetBag(self.bagType);
	if not bagVO then return 0;end
	local itemVO = bagVO:GetItemByPos(self.pos);
	if not itemVO then return 0; end
	local cfg = itemVO:GetCfg();
	if cfg and cfg.cd and cfg.cd>0 then
		return BagModel:GetItemTotalCD(self.tid);
	end
	return 0;
end

--获取拖拽类型
function BagSlotVO:GetDragType()
	if self.bagType == BagConsts.BagType_Tianshen then
		return BagConsts.Drag_Item_Tianshen
	end
	if t_item[self.tid] then
		return BagConsts.Drag_Item;
	end
	local equipCfg = t_equip[self.tid];
	if equipCfg then
		return 2000+equipCfg.pos;
	end
	return 0;
end

--获取接受的拖入类型
function BagSlotVO:GetDragAcceptType()
	if self.bagType == BagConsts.BagType_Role then
		if self.pos>=0 and self.pos<=11 then
			return {2000+self.pos};
		else
			return {0};
		end
	elseif self.bagType == BagConsts.BagType_Horse then
		if self.pos>=0 and self.pos<=4 then
			return {2020+self.pos};
		else
			return {0};
		end
	elseif self.bagType ==BagConsts.BagType_LingShou then
		if self.pos>=0 and self.pos<=4 then
			return {2030+self.pos};
		else
			return {0};
		end
	elseif self.bagType ==BagConsts.BagType_LingShouHorse then
		if self.pos>=0 and self.pos<=4 then
			return {2040+self.pos};
		else
			return {0};
		end
	elseif self.bagType ==BagConsts.BagType_LingZhenZhenYan then
		if self.pos>=0 and self.pos<=9 then
			return {2050+self.pos};
		else
			return {0};
		end
	elseif self.bagType ==BagConsts.BagType_QiZhan then
		if self.pos>=0 and self.pos<=9 then
			return {2070+self.pos};
		else
			return {0};
		end	
	-- elseif self.bagType ==BagConsts.BagType_ShenLing then
	-- 	if self.pos>=0 and self.pos<=9 then
	-- 		return {2090+self.pos};
	-- 	else
	-- 		return {0};
	-- 	end
	elseif self.bagType == BagConsts.BagType_MingYu then
		if self.pos>=0 and self.pos<=4 then
			return {2100+self.pos};
		else
			return {0};
		end
	elseif self.bagType == BagConsts.BagType_Armor then
		if self.pos>=0 and self.pos<=4 then
			return {2120+self.pos};
		else
			return {0};
		end
	elseif self.bagType == BagConsts.BagType_MagicWeapon then
		if self.pos>=0 and self.pos<=4 then
			return {2130+self.pos};
		else
			return {0};
		end
	elseif self.bagType == BagConsts.BagType_LingQi then
		if self.pos>=0 and self.pos<=4 then
			return {2140+self.pos};
		else
			return {0};
		end
	elseif self.bagType == BagConsts.BagType_RoleItem then
		return {1000+self.pos};
	elseif self.bagType == BagConsts.BagType_RELIC then
		return {BagConsts.Drag_Item_Shengqi}
	elseif self.bagType == BagConsts.BagType_Tianshen then
		return {BagConsts.Drag_Item_Tianshen}
	else
		return BagConsts.AllDragType;
	end
end

--获取是否显示绑定图标
function BagSlotVO:GetShowBind()
	if self.bindState==BagConsts.Bind_GetBind or self.bindState==BagConsts.Bind_Bind then
		return true;
	end
	return false;
end

--是否是更好装备
function BagSlotVO:GetIsBetter()
	if not self.opened then return false; end
	if not self.hasItem then return false; end
	if self.bagType==BagConsts.BagType_Bag or self.bagType==BagConsts.BagType_Storage then
		return BagUtil:CheckBetterEquip(self.bagType,self.pos)
	elseif self.bagType == BagConsts.BagType_Tianshen then
		-- 天神卡是否资质更高
		return NewTianshenUtil:IsBetterCard(self.id)
	else
		return false;
	end
end

--获取是否显示格子开启特效
function BagSlotVO:GetShowOpenEffect()
	if self.bagType==BagConsts.BagType_Bag or self.bagType==BagConsts.BagType_Storage then
		local bagVO = BagModel:GetBag(self.bagType);
		if not bagVO then return false; end
		if bagVO:GetSize() == self.pos then
			if self.pos+1 <= BagConsts:GetBagTimeSize(self.bagType) then
				return true;
			else
				return false;
			end
		else
			return false;
		end
	else
		return false;
	end
end

--获取格子是否被锁定
function BagSlotVO:GetItemLock()
	if not self.opened then return false; end
	if not self.hasItem then return false; end
	if self.bagType ~= BagConsts.BagType_Bag then return false; end
	if UIBag.isQuickSell then
		local cfg = t_item[self.tid] or t_equip[self.tid];
		if cfg and not cfg.sell then
			return true;
		end
	end
	if bit.band(self.flags,BagItem.Flag_Lock) == BagItem.Flag_Lock then
		return true;
	end
	return false;
end

--装备卓越星级
function BagSlotVO:GetSuper()
	if not self.opened then return 0; end
	if not self.hasItem then return 0; end
	if BagUtil:GetItemShowType(self.tid) == BagConsts.ShowType_Equip then
		if t_equip[self.tid].pos > 10 then
			return 0
		end
		local quality = self:GetQuality();
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

--标识路径
function BagSlotVO:GetBiaoshi() 
	if not self.opened then return "" end;
	if not self.hasItem then return "" end;
	return BagUtil:GetItemBiaoShiUrl(self.tid) 
end;


--获取是否有套装
function BagSlotVO:GetIsShowEquipGroup()
	if not self.opened then return "" end
	if not self.hasItem then return "" end
	if self.bagType == BagConsts.BagType_Role and self.pos == BagConsts.Equip_WuQi then
		return ResUtil:GetShenWuSlotIcon(ShenWuModel:GetLevel(), ShenWuModel:GetStar())
	end
	local val = EquipUtil:GetEquipGroupId(self.tid) 
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

--获取编码后的UI数据
--参数为是否是角色身上穿戴装备
function BagSlotVO:GetUIData(bRole)
	bRole = false
	local data = {};
	data.bagType = self.bagType;
	data.uiPos = self.uiPos;
	data.pos = self.pos;
	data.opened = self.opened;
	data.hasItem = self.hasItem;
	data.tid = self.tid;
	data.count = self.count;
	data.strenLvl = self:GetStrenLvl();
	data.super = self:GetSuper();
	if self.customIconUrl == "" then
		data.iconUrl = self:GetIconUrl(bRole);
	else
		data.iconUrl = self.customIconUrl;
	end

	data.dragType = self:GetDragType();
	local acceptType = self:GetDragAcceptType();
	local acceptStr = table.concat(acceptType,",");
	data.acceptType = acceptStr;
	data.showCount = self:GetIsShowCount();
	data.quality = self:GetQuality();
	data.qualityUrl = self:GetQualityUrl(bRole);
	data.lastCd = self:GetCD();
	data.totalCd = self:GetTotalCD();
	data.showBind = self:GetShowBind();
	data.biaoshiUrl = self:GetBiaoshi();
	data.groupBsUrl = self:GetIsShowEquipGroup();
	if self:GetShowOpenEffect() then
		data.openEffect = ResUtil:GetBagSlotCD();
	end
	if self.bagType==BagConsts.BagType_Role or
	   self.bagType==BagConsts.BagType_Horse or
	   self.bagType==BagConsts.BagType_LingShou or
	   self.bagType==BagConsts.BagType_LingShouHorse or 
	   self.bagType==BagConsts.BagType_LingZhenZhenYan or
	   self.bagType==BagConsts.BagType_QiZhan or
		self.bagType==BagConsts.BagType_MingYu or
		self.bagType==BagConsts.BagType_Armor or
		self.bagType==BagConsts.BagType_MagicWeapon or
		self.bagType==BagConsts.BagType_LingQi then
		data.zbwPos = BagUtil:GetEquipAtBagPos(self.bagType,self.pos);
	elseif self.bagType == BagConsts.BagType_RoleItem then
		data.zbwPos = 50;
	elseif self.bagType == BagConsts.BagType_RELIC then
		data.zbwPos = 75 + self.pos
	end
	data.isBetter = self:GetIsBetter();
	data.itemLock = self:GetItemLock();
	return UIData.encode(data);
end

--获取编码后的UI数据
--参数为是否是角色身上穿戴装备
function BagSlotVO:GetData(bRole)
	local data = {};
	data.bagType = self.bagType;
	data.uiPos = self.uiPos;
	data.pos = self.pos;
	data.opened = self.opened;
	data.hasItem = self.hasItem;
	data.tid = self.tid;
	data.count = self.count;
	data.strenLvl = self:GetStrenLvl();
	data.super = self:GetSuper();
	if self.customIconUrl == "" then
		data.iconUrl = self:GetIconUrl(bRole);
	else
		data.iconUrl = self.customIconUrl;
	end

	data.dragType = self:GetDragType();
	local acceptType = self:GetDragAcceptType();
	local acceptStr = table.concat(acceptType,",");
	data.acceptType = acceptStr;
	data.showCount = self:GetIsShowCount();
	data.quality = self:GetQuality();
	data.qualityUrl = self:GetQualityUrl(bRole);
	data.lastCd = self:GetCD();
	data.totalCd = self:GetTotalCD();
	data.showBind = self:GetShowBind();
	data.biaoshiUrl = self:GetBiaoshi();
	data.groupBsUrl = self:GetIsShowEquipGroup();
	if self:GetShowOpenEffect() then
		data.openEffect = ResUtil:GetBagSlotCD();
	end
	if self.bagType==BagConsts.BagType_Role or
	   self.bagType==BagConsts.BagType_Horse or
	   self.bagType==BagConsts.BagType_LingShou or
	   self.bagType==BagConsts.BagType_LingShouHorse or 
	   self.bagType==BagConsts.BagType_LingZhenZhenYan or
	   self.bagType==BagConsts.BagType_QiZhan or
		self.bagType==BagConsts.BagType_MingYu or
		self.bagType==BagConsts.BagType_Armor or
		self.bagType==BagConsts.BagType_MagicWeapon or
		self.bagType==BagConsts.BagType_LingQi then
		data.zbwPos = BagUtil:GetEquipAtBagPos(self.bagType,self.pos);
	elseif self.bagType == BagConsts.BagType_RoleItem then
		data.zbwPos = 50;
	elseif self.bagType == BagConsts.BagType_RELIC then
		data.zbwPos = 75 + self.pos
	end
	data.isBetter = self:GetIsBetter();
	data.itemLock = self:GetItemLock();
	return data;
end