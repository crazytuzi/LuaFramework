--[[
打开活动btn3

]]

NoticeScriptCfg:Add(
{
	name = "openactivity3",
	execute = function()
		if OperActivity3Btn:IsShow() then
			OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconHuodong1)
		else
			FloatManager:AddNormal(StrConfig['operactivites37']);
		end
		return true;
	end
}
);