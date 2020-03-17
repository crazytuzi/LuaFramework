--[[
    Created by Sublime
    User: houxudong
    Date: 2016年8月2日
    Time: 14:14:14
   ]]

ItemScriptCfg:Add(
	{
		name = "openMagic",
		execute = function(bag,pos, skillType)
			if not FuncManager:GetFuncIsOpen(FuncConsts.MagicSkill) then return; end
			UIBag:Hide();
			FuncManager:OpenFunc(FuncConsts.MagicSkill, false, skillType);
			return true;
		end
	}
);