--[[
打开组队挑战之战界面
参数:FuncConsts.teamDungeon  123
houxudong
2016年11月6日23:48:25
]]

NoticeScriptCfg:Add(
{
	name = "openuzdtz",
	execute = function()
		if not FuncManager:GetFuncIsOpen(FuncConsts.Dungeon) then return true; end  
			FuncManager:OpenFunc(FuncConsts.Dungeon, false, FuncConsts.teamDungeon);
		return true;
	end
}
);