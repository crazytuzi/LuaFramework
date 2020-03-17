--[[
帮派战场，
wangshuai
]]

NoticeScriptCfg:Add(
{
	name = "unionwarpath",
	execute = function()
		if UIUnionRight:IsShow() then 
			UIUnionRight:LookPathfun(3)
		end;
	end
}
);