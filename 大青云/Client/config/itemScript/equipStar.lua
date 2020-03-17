--[[
	发送喇叭
	lizhuangzhuang
	2014年11月12日14:57:48
]]

ItemScriptCfg:Add(
{
	name = "equipstar",
	execute = function(bag,pos)
		local func = FuncManager:GetFunc(FuncConsts.EquipStren)
		if not func then return end
		if func:GetState() ~= FuncConsts.State_Open then
			local tips = FuncManager:GetFuncUnOpenTips(FuncConsts.EquipStren);
			if tips ~= "" then
				FloatManager:AddSkill(tips);
			end
			return;
		end
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		SmithingStarItemView:OpenView(item:GetTid(), 1)
		return true;
	end
}
);

ItemScriptCfg:Add(
{
	name = "equipmoon",
	execute = function(bag,pos)
		local func = FuncManager:GetFunc(FuncConsts.EquipStren)
		if not func then return end
		if func:GetState() ~= FuncConsts.State_Open then
			local tips = FuncManager:GetFuncUnOpenTips(FuncConsts.EquipStren);
			if tips ~= "" then
				FloatManager:AddSkill(tips);
			end
			return;
		end
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		SmithingStarItemView:OpenView(item:GetTid(), 2)
		return true;
	end
}
);