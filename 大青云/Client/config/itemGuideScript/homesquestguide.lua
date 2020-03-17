
--[[
家园任务完成
wangshuai
]]

QuestScriptCfg:Add(
{
	name = "homesquestguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.Homestead,nil,"mainQuest","ing"); return true; end,
			complete = function() return UIHomesteadMainView:IsFullShow(); end,
			Break = function() return false; end
		},
	}
})