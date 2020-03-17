--[[
灵兽战印
wangshuai
]]

NoticeScriptCfg:Add(
{
	name = "openSpiritWarprintCfg",
	execute = function()
		FuncManager:OpenFunc(FuncConsts.Spirits,false,SpiritsConsts.Zhanying);
		return true;
	end
}
);