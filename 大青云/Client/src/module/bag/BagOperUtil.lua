--[[
背包操作Util
lizhuangzhuang
2014年8月5日16:03:13
]]

_G.BagOperUtil = {};

--获取物品可有的操作列表
function BagOperUtil:GetOperList(bagType,pos)
	local list = {};
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return list; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return list; end
	for i,k in pairs(BagConsts.AllOper) do
		if self:CheckHasOperRights(k,item) then
			local data = {};
			data.name = BagConsts:GetOperName(k);
			data.oper = k;
			table.push(list,data);
		end
	end
	return list;
end

--检查物品是否有指定操作权限
--@param oper 操作
--@param item 物品item
function BagOperUtil:CheckHasOperRights(oper,item)
	local bagType = item:GetBagType();
	local id = item:GetTid();
	if bagType == BagConsts.BagType_Tianshen then
		if oper==BagConsts.Oper_Use then
			return true
		end
		if oper==BagConsts.Oper_Destroy then
			return true
		end
		if oper==BagConsts.Oper_CardCom then
			return true
		end
		return false
	end
	--存入和取出单独判断
	if oper==BagConsts.Oper_Store and bagType==BagConsts.BagType_Bag and UIStorage:IsShow() then
		return true;
	end
	if oper==BagConsts.Oper_UnStore and bagType==BagConsts.BagType_Storage then
		return true;
	end
	local showType = BagUtil:GetItemShowType(id);
	--装备
	if showType == BagConsts.ShowType_Equip then
		local equipCfg = t_equip[id];
		if not equipCfg then return false; end
		if oper==BagConsts.Oper_Equip and bagType==BagConsts.BagType_Bag then
			return true;
		end
		if oper==BagConsts.Oper_UnEquip and bagType==BagConsts.BagType_Role then
			return true;
		end
		if oper==BagConsts.Oper_Show then
			return true;
		end
		if oper==BagConsts.Oper_Destroy and bagType==BagConsts.BagType_Bag and equipCfg.destroy then
			return true;
		end
		if oper==BagConsts.Oper_Sell and bagType==BagConsts.BagType_Bag and equipCfg.sell then
			return true;
		end
		if oper==BagConsts.Oper_Compound then
			return false;
		end
		return false;
	end
	local itemConfig = t_item[id];
	if not itemConfig then  return false; end
	--翅膀
	if itemConfig.sub == BagConsts.SubT_Wing then
		if oper==BagConsts.Oper_EquipWing and bagType==BagConsts.BagType_Bag then
			return true;
		end
		if oper==BagConsts.Oper_Use then
			return false;
		end
	end
	if itemConfig.sub == BagConsts.SubT_Relic then
		if oper == BagConsts.Oper_EquipRelic and bagType == BagConsts.BagType_Bag then
			return true
		end
		if oper == BagConsts.Oper_RelicUp and bagType == BagConsts.BagType_Bag then
			return true
		end
		if oper == BagConsts.Oper_Use then
			return false
		end
	end
	--消耗品
	if showType == BagConsts.ShowType_Consum then
		if oper==BagConsts.Oper_Use and bagType==BagConsts.BagType_Bag and itemConfig.cuse then
			return true;
		end
		if oper==BagConsts.Oper_BatchUse and bagType==BagConsts.BagType_Bag and itemConfig.cuse and itemConfig.batch then
			return true;
		end
		if oper==BagConsts.Oper_Split and bagType==BagConsts.BagType_Bag and itemConfig.repeats>1 then
			return true;
		end
		if oper==BagConsts.Oper_Show then
			return true;
		end
		if oper==BagConsts.Oper_Destroy and bagType==BagConsts.BagType_Bag and itemConfig.destroy then
			return true;
		end
		if oper==BagConsts.Oper_Sell and bagType==BagConsts.BagType_Bag and itemConfig.sell then
			return true;
		end
		if oper==BagConsts.Oper_Compound and BagModel.compoundMap[id] then
			return true;
		end
		return false;
	end
	--任务
	if showType == BagConsts.ShowType_Task then
		if oper==BagConsts.Oper_Use and bagType==BagConsts.BagType_Bag and itemConfig.cuse then
			return true;
		end
		if oper==BagConsts.Oper_Show then
			return true;
		end
		if oper==BagConsts.Oper_Destroy and bagType==BagConsts.BagType_Bag and itemConfig.destroy then
			return true;
		end
		if oper==BagConsts.Oper_Sell and bagType==BagConsts.BagType_Bag and itemConfig.sell then
			return true;
		end
		if oper==BagConsts.Oper_Compound then
			return false;
		end
		return false;
	end
	--其他
	if showType == BagConsts.ShowType_Other then
		if oper==BagConsts.Oper_Use and bagType==BagConsts.BagType_Bag and itemConfig.cuse then
			return true;
		end
		if oper==BagConsts.Oper_Split and bagType==BagConsts.BagType_Bag and itemConfig.repeats>1 then
			return true;
		end
		if oper==BagConsts.Oper_Show then
			return true;
		end
		if oper==BagConsts.Oper_Destroy and bagType==BagConsts.BagType_Bag and itemConfig.destroy then
			return true;
		end
		if oper==BagConsts.Oper_Sell and bagType==BagConsts.BagType_Bag and itemConfig.sell then
			return true;
		end
		if oper==BagConsts.Oper_Compound and BagModel.compoundMap[id] then
			return true;
		end
		return false;
	end
	return false;
end

