--[[
打开活动btn4

]]

NoticeScriptCfg:Add(
{
	name = "openactivity4",
	execute = function()
		if OperActivity4Btn:IsShow() then
			OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconHuodong2)
		else
			FloatManager:AddNormal(StrConfig['operactivites37']);
		end
		return true;
	end
}
);