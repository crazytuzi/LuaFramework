--[[
骑坐骑脚本
lizhuangzhuang
2015年8月5日17:19:49
]]

QuestScriptCfg:Add(
{
	name = "ridehorse",
	stopQuestGuide = false,--停下来
	disableFuncKey = false,--屏蔽快捷键
	log = true,
	
	steps = {
		[1] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() MountController:RideMount(); return true; end,
			Break = function() return false; end
		}
	}
});