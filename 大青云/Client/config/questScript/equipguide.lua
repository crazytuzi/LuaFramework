--[[
拔剑穿装备
lizhuangzhuang
2015年7月20日23:35:57
]]

QuestScriptCfg:Add(
{
	name = "equipguide",
	log = true,
	
	steps = {
		--装备武器
		[1] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() 
							local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
							if bagVO then
								local list = bagVO:GetItemListByShowType(BagConsts.ShowType_Equip);
								if #list > 0 then
									local bagItem = list[1];
									BagController:EquipItem(BagConsts.BagType_Bag,bagItem:GetPos());
								end
							end
							return true;
						end,
			Break = function() return false; end
		},
		
	}
});