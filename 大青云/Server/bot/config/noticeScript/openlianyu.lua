--[[
打开地宫炼狱

]]

NoticeScriptCfg:Add(
{
	name = "openlianyu",
	execute = function()
		if not FuncManager:GetFuncIsOpen(FuncConsts.Guild) then
			local tips = FuncManager:GetFuncUnOpenTips(FuncConsts.Guild);
			if tips ~= "" then
				FloatManager:AddSkill(tips);
			end
			return;
		end

		if not UnionUtils:CheckMyUnion() then
			FloatManager:AddSkill("请先创建或加入一个帮派");
			return;
		end

		local stratum = UnionDungeonHellModel:GetCurrentStratum();
		if UIUnionDungeonHell:IsShow() then
			UIUnionDungeonHell:ShowStratum(stratum);
		else
			if not UnionDungeonUtils:GetUnionDungeonIsOpen( UnionDungeonConsts.ID_Hell ) then
				FloatManager:AddSkill("地宫炼狱尚未开启");
				return
			end
			if UIUnion:IsShow() then
				UIUnion:Hide()
			end
			UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
			UIUnionDungeonMain:SetFirstPanel( UnionDungeonConsts.TabHell );
			UIUnionDungeonHell:SetFirstShowStratum( stratum );
			UIUnionDungeonHell.willTweenNext = false;
			UIUnion:Show();
		end
		return true;
	end
}
);