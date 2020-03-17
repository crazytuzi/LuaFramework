--[[
回收物品类任务目标
lizhuangzhuang
2014年9月11日15:55:55
]]

_G.GetItemQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

function GetItemQuestGoalVO:GetType()
	return QuestConsts.GoalType_GetItem;
end

function GetItemQuestGoalVO:GetTotalCount()
	if self.goalParam[2] then
		return toint(self.goalParam[2]);
	end
	return 0;
end

function GetItemQuestGoalVO:GetLabelContent()
	if not self.goalParam[1] then return""; end
	local itemCfg = t_item[toint(self.goalParam[1])];
	if not itemCfg then return ""; end
	local name = "<u><font color='"..self.linkColor.."'>"..itemCfg.name.."</font></u>";
	local questCfg = self.questVO:GetCfg();
	return string.format(questCfg.unFinishLink,name);
end

function GetItemQuestGoalVO:DoGoal()
	--todo 执行脚本
	
end