--[[
奇遇任务达到坐标类任务目标
2015年7月31日10:20:11
haohu
]]
--------------------------------------------------------------

_G.RandomGoPosGoalVO = setmetatable( {}, { __index = QuestGoalVO } )

function RandomGoPosGoalVO:GetType()
	return QuestConsts.GoalType_GoPos;
end

function RandomGoPosGoalVO:CreateGoalParam()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg()
	return tonumber( cfg.pos )
end

function RandomGoPosGoalVO:CreateGuideParam()
	return nil
end

function RandomGoPosGoalVO:GetTotalCount()
	return 1;
end

function RandomGoPosGoalVO:GetLabelContent()
	if not self.goalParam then return "" end
	local posCfg = t_position[ self.goalParam ]
	if not posCfg then return "" end
	local name = "<u><font color='"..self.linkColor.."'>"..posCfg.name.."</font></u>";
	local questCfg = self.questVO:GetCfg();
	return string.format( questCfg.stepDesc, name )
end

function RandomGoPosGoalVO:DoGoal()
	local point = self:GetPos()
	if not point then return end
	MainPlayerController:DoAutoRun( point.mapId, _Vector3.new( point.x, point.y, 0 ), nil, nil, nil, nil, point.range ~= 0 and point.range or nil );
	--
	local func = FuncManager:GetFunc(FuncConsts.RandomQuest);
	if func then
		func:OnQuestClick();
	end
end

function RandomGoPosGoalVO:GetPos()
	local posId = self.goalParam
	return QuestUtil:GetQuestPos( posId )
end