--[[
打开帮派
lizhuangzhuang
2015年7月2日14:54:25
]]

NoticeScriptCfg:Add(
{
	name = "openGuild",
	execute = function()
		if not FuncManager:GetFuncIsOpen(FuncConsts.Guild) then
			local tips = FuncManager:GetFuncUnOpenTips(FuncConsts.Guild);
			if tips ~= "" then
				FloatManager:AddSkill(tips);
			end
			return;
		end
		--
		if UnionUtils:CheckMyUnion() then
			UIUnion:SetFirstTab(UnionConsts.TabUnionList);
			UIUnionManager:Show();
		else
			UIUnionCreate:Show();
		end
	end
}
);