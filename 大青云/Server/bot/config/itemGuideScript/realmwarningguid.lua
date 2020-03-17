--[[
境界警告
wangyanwei
]]

QuestScriptCfg:Add(
{
	name = "realmwarningguid",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Realm); return true; end,
			complete = function() return UIRealmMainView:IsFullShow(); end,
			Break = function() return false; end
		},		
	}
})