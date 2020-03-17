--[[
特殊道具使用弹窗
wangshuai
2015年10月23日16:51:02
]]

ItemScriptCfg:Add(
{
	isremind = true;
	name = "ItemPackageItemCost",
	execute = function(bag,pos,str)
		local bagVO = BagModel:GetBag(bag);
		local item = bagVO:GetItemByPos(pos);
		if not item then return false end;
		local isremind = ItemScriptCfg["ItemPackageItemCost"].isremind
		local cfg = item:GetCfg();
		local okfun = function (desc) 
			ItemScriptCfg["ItemPackageItemCost"].isremind = not desc;
			BagController:SplitUseItem(bag,pos,1)
		end;
		local na = enAttrTypeName[cfg.use_param_1];
		if isremind then 
			UIConfirmWithNoTip:Open(string.format(StrConfig["equip1301"],cfg.use_param_2..na),okfun);
		else
			BagController:SplitUseItem(bag,pos,1)
		end;
		return true
	end
}
);