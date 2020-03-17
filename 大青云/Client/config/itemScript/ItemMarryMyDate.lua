--[[
结婚使用请柬
wangyanwei
2015年10月19日16:59:21
]]

ItemScriptCfg:Add(
{
	name = "ItemMarryMyDate",
	execute = function(bag,pos,str)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		local num = BagModel:GetItemNumInBag(item:GetTid());
		local state = MarriageModel:GetMyMarryState()
		if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then --单身 离婚
			FloatManager:AddNormal(StrConfig["marriage097"])
			return 
		end;
		if state == MarriageConsts.marryMarried then 
			FloatManager:AddNormal(StrConfig["marriage220"])
			return 
		end;
		local time = MarriageModel:GetMyMarryTime();
		if time <= 0 then 
			FloatManager:AddNormal(StrConfig["marriage200"])
			return 
		end;
		UIMarryCardMyData:SetNum(num,item:GetTid())
		UIMarryCardMyData:Show();		
		return true
	end
}
);