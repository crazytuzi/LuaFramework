--[[
打开牧野之战界面
参数:FuncConsts.muyeDungeon  123
houxudong
2016年11月6日23:48:25
]]

NoticeScriptCfg:Add(
{
	name = "openmuyewar",
	execute = function()
		if not FuncManager:GetFuncIsOpen(FuncConsts.Dungeon) then return true; end  
			FuncManager:OpenFunc(FuncConsts.Dungeon, false, FuncConsts.muyeDungeon);
		return true;
	end
}
);