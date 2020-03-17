--[[
灵力丹推荐使用
lizhuangzhuang
2015年8月11日20:20:39
]]

ItemNumCScriptCfg:Add(
{
	name = "linglidanchange",
	execute = function(bag,pos,tid)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		if BagModel:GetItemNumInBag(tid) < 100 then
			return;
		end
		--如果达到每日上限,不提醒
		if BagModel:GetItemCanUseNum(tid) == 0 then
			return;
		end
		UIItemGuideUse:Open(item:GetId());
	end
}
);