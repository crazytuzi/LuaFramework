--[[
强化石数量变化
需求:检测背包内强化石达到5后
lizhuangzhuang
2015年5月5日11:13:47
]]


ItemNumCScriptCfg:Add(
{
	name = "strenbonechange",
	execute = function(bag,pos,tid)
		--判断所有装备是不是满级
		local fullLvl = true;
		local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
		if not bagVO then return; end
		for k,bagItem in pairs(bagVO.itemlist) do
			if EquipModel:GetStrenLvl(bagItem:GetId()) < EquipConsts.StrenMaxLvl then
				fullLvl = false;
				break;
			end
		end
		if fullLvl then
			return;
		end
		--
		if BagModel:GetItemNumInBag(tid) >= 5 then
			--UIItemGuide:Open(1);
		end
	end
}
);