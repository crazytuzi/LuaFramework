--[[
打开每日首冲

]]

NoticeScriptCfg:Add(
{
	name = "opendaycharge",
	execute = function()
		if OperActivity2Btn:IsShow() then
			OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconShouchongDay)
		else
			FloatManager:AddNormal(StrConfig['operactivites37']);
		end
		return true;
	end
}
);