--[[
改名道具
]]

ItemScriptCfg:Add(
{
	name = "itemChangeRoleName",
	execute = function(bag,pos,tid)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		if BagModel:GetItemCanUseNum(tid) == 0 then
			return;
		end
		
		if not UIPlayerNameEditPanel:IsShow() then
			UIPlayerNameEditPanel:Show(item:GetId());		
		end
		
		return true
	end
}
);