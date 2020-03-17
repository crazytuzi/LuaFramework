--[[
任务目标：成就任务
2015年5月28日16:45:14
haohu
]]

_G.AchievementGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function AchievementGoalVO:GetType()
	return QuestConsts.GoalType_Click
end

function AchievementGoalVO:GetId()
	local cfg = self.questVO:GetCfg()
	return cfg.funid
end

--任务目标需要完成的总数量
function AchievementGoalVO:GetTotalCount()
	local cfg = self.questVO:GetCfg()
	return cfg.val;
end

function AchievementGoalVO:DoGoal()
	local funcId = self:GetId()
	FuncManager:OpenFunc( funcId )
end

function AchievementGoalVO:GetGoalLabel(size, color)
	local format = "<u><font size='%s' color='%s'>%s</font></u>"
	if not size then size = 14 end
	if not color then color = QuestColor.COLOR_GREEN end
	local strSize = tostring( size )
	local name = self:GetLabelContent()
	return string.format( format, strSize, color, name )
end

function AchievementGoalVO:GetLabelContent()
	local cfg = self.questVO:GetCfg()
	local totalCount = self:GetTotalCount();
	if totalCount <= 0 then
		return "";
	end
	return string.format( cfg.txt, self.currCount, totalCount );
end