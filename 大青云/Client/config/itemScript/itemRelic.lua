--[[
	发送喇叭
	lizhuangzhuang
	2014年11月12日14:57:48
]]

ItemScriptCfg:Add(
{
	name = "itemRelic",
	execute = function(bag,pos)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		UIRelicView:OpenView(item)
		return true;
	end
}
);