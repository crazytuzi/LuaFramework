--[[
打开合成
lizhuangzhuang
2015年7月10日12:26:44
]]

ItemScriptCfg:Add(
{
	name = "openhecheng",
	execute = function(bag,pos)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		FuncManager:OpenFunc(FuncConsts.HeCheng,false,BagModel.compoundMap[item:GetTid()]);
		return true;
	end
}
);