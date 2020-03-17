--[[
帮派战场，
wangshuai
]]

NoticeScriptCfg:Add(
{
	name = "openZhuansheng",
	execute = function()
		local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
		if myLevel < 51 then
			--等级不够，提示
			FloatManager:AddNormal(StrConfig["zhuansheng016"]);
			return false;
		end;
		if UIZhuanshOpen:IsShow() then 
			if not UIZhuanSheng:IsShow() then 
				UIZhuanSheng:Show();
				return true;
			end;
		else
			--已转生完成；
			return true;
		end;
	end
}
);