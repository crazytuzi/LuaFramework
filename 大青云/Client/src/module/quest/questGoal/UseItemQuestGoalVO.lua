--[[
使用物品类任务目标
lizhuangzhuang
2014年9月11日15:58:59
]]

_G.UseItemQuestGoalVO = setmetatable({},{__index=QuestGoalVO});

UseItemQuestGoalVO.questPoint = nil;

function UseItemQuestGoalVO:GetType()
	return QuestConsts.GoalType_UseItem;
end

function UseItemQuestGoalVO:OnCreate()
	local posId = toint(self.guideParam[1]);
	self.questPoint = QuestUtil:GetQuestPos(posId);
	--
	if self.questVO:GetState() ~= QuestConsts.State_Going then
		return;
	end
end

function UseItemQuestGoalVO:GetTotalCount()
	return 1;
end

--获取使用物品id
function UseItemQuestGoalVO:GetUseItemId()
	return toint(self.goalParam[1],-1);
end

function UseItemQuestGoalVO:GetLabelContent()
	local questCfg = self.questVO:GetCfg();
	local str = questCfg.unFinishLink;
	str = string.gsub(str,"<u>","<u><font color='"..self.linkColor.."'>");
	str = string.gsub(str,"</u>","</font></u>");
	return str;
end

function UseItemQuestGoalVO:DoGoal()
	if not self.guideParam[1] then return; end
	local point = self:GetPos();
	if not point then return end;
	local completeFuc = function()
		BagController:UseItemByTid( BagConsts.BagType_Bag, toint( self.goalParam[1] ), 1 );
	end
	MainPlayerController:DoAutoRun( point.mapId, _Vector3.new( point.x, point.y, 0 ), completeFuc );
end

-- 是否可传送
function UseItemQuestGoalVO:CanTeleport()
	return true
end

function UseItemQuestGoalVO:GetPos()
	local guideParam = self.guideParam[1];
	if not guideParam then return; end
	local posId = toint( guideParam );
	return QuestUtil:GetQuestPos(posId);
end