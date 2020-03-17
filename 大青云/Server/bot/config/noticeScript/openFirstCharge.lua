--[[
打开首冲

]]

NoticeScriptCfg:Add(
{
	name = "openfirstcharge",
	execute = function()
		if OperActivity1Btn:IsShow() then
			OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconShouchong)
		else
			FPrint(StrConfig['operactivites37'])
		end
		return true;
	end
}
);