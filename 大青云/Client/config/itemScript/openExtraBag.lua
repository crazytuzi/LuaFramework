--[[
打开UI
参数：name,UI名字
houxudong
2016年9月12日14:56:25
]]

ItemScriptCfg:Add(
{
	name = "UIBagOpen",
	execute = function(bag,pos,name)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local useSize = bagVO:GetUseSize();  --已经使用的格子数
	local size = bagVO:GetSize();        --背包格子的大小
		if UIBagOpen:IsShow() then
			return true;
		else
			UIBagOpen:Open(BagConsts.BagType_Bag,size);
		end
		return true;
	end
}
);