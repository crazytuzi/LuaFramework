--[[
结婚查看请柬
wangyanwei
2015年10月19日16:59:21
]]

ItemScriptCfg:Add(
{
	name = "ItemMarryBeDate",
	execute = function(bag,pos,str)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		local cid = item:GetId();
		if not UIMarryCard:IsShow() then 
			UIMarryCard:SetCid(cid)
		end;
		return true
	end
}
);

