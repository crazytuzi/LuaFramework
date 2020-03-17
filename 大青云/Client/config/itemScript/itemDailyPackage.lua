--[[
特殊道具使用弹窗2
wangshuai
2015年10月23日16:51:02
]]

ItemScriptCfg:Add(
{
	isremind = true;
	name = "ItemDailyPackage",
	execute = function(bag,pos,str)
		local bagVO = BagModel:GetBag(bag);
		local item = bagVO:GetItemByPos(pos);
		if not item then return false end;
		local isremind = ItemScriptCfg["ItemDailyPackage"].isremind
		local itemCfg = item:GetCfg();
		if item:GetTodayUse() >= itemCfg.reuse_day then 
			FloatManager:AddNormal(StrConfig['bag53']);
			return 
		end;
		local xiaocfg = t_itemcard[item:GetTid()];
		if not xiaocfg then 
			--找不到消耗
			return false;
		end;
		local cost = split(xiaocfg.cost,"#")
		local curCost = split(cost[item:GetUseCnt() + 1],",");
		if curCost and toint(curCost[1]) ~= 0 then 
			--有消耗类型
			local okfun = function (desc) 
				ItemScriptCfg["ItemDailyPackage"].isremind = not desc;
				BagController:SplitUseItem(bag,pos,1)
			end;
			local nofun = function () end;
			local na = enAttrTypeName[toint(curCost[1])];
			if isremind then  
				UIConfirm:Open(string.format(StrConfig["equip1301"],curCost[2]..na),okfun,nofun);
			else
				BagController:SplitUseItem(bag,pos,1)
			end;
		else
			--没有消耗类型，直接消耗
			BagController:SplitUseItem(bag,pos,1)
		end;
		return true
	end
}
);