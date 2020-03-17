--[[
等级任务任务目标
haohu
2015年5月15日21:22:42
]]

_G.LevelQuestGoalVO = setmetatable( {}, {__index = QuestGoalVO} );

function LevelQuestGoalVO:GetId()
	return 0;
end

function LevelQuestGoalVO:CreateGuideParam()
	return nil
end

--任务目标需要完成的总数量
function LevelQuestGoalVO:GetTotalCount()
	return tonumber( self.goalParam[1] ) or 0
end

--执行目标指引
function LevelQuestGoalVO:DoGoal()
	-- override
end

--获取在快捷任务显示的信息(格式)
function LevelQuestGoalVO:GetGoalLabel(size, color)
	local format = "<u><font size='%s' color='%s'>%s%s</font></u>";
	if not size then size = 14 end;
	if not color then color = QuestColor.COLOR_GREEN end;
	local strSize = tostring( size );
	local name = self:GetLabelContent();
	local count = self:GetTreeDataCount();
	return string.format( format, strSize, color, name, count );
end

--获取在快捷任务显示的信息(无格式)
function LevelQuestGoalVO:GetLabelContent()
	local quest = self.questVO
	local cfg = quest:GetCfg()
	return cfg.unFinishLink
end

function LevelQuestGoalVO:GetTreeDataCount()
	local totalCount = self:GetTotalCount();
	if totalCount <= 0 then
		return "";
	end
	return string.format( "<font color='"..QuestColor.COLOR_GREEN.."'>(%s/%s)</font>", self.currCount, totalCount );
end