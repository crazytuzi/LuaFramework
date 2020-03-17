--[[
结婚
wangshuai
]]

NoticeScriptCfg:Add(
{
	name = "openMarry",
	execute = function()
		local roleLvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local cfg = t_funcOpen[85];
		local openLvl = cfg.open_level;
		if roleLvl >= openLvl then 
			UIRole:Show(UIRole.MARRY)
		else
			FloatManager:AddNormal(StrConfig["marriage105"]);
		end;
		return true;
	end
}
);