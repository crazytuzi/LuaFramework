--[[
收集类任务目标
lizhuangzhuang
2014年9月11日15:54:31
]]

_G.AgoraCollectQuestGoalVO = setmetatable( {}, { __index = QuestGoalVO } );

function AgoraCollectQuestGoalVO:GetType()
	return QuestConsts.GoalType_AgoraCollection;
end

--获取采集物id
function AgoraCollectQuestGoalVO:GetCollectId()
	if not self.goalParam[1] then return 0; end
	return tonumber( self.goalParam[1] );
end

function AgoraCollectQuestGoalVO:GetTotalCount()
	if self.goalParam[2] then
		return tonumber( self.goalParam[2] );
	end
	return 0;
end

function AgoraCollectQuestGoalVO:CreateGoalParam()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg()
	local goals = GetPoundTable(cfg.questGoals);
	local goal = goals[1];
	if #goals>1 then
		goal = goals[MainPlayerModel.humanDetailInfo.eaProf];
	end
	return split( goal, "," )
end
function AgoraCollectQuestGoalVO:CreateGuideParam()
	return nil;
end
function AgoraCollectQuestGoalVO:GetLabelContent()
	local collectId = self:GetCollectId()
	local collectionCfg = t_collection[ collectId ];
	if not collectionCfg then return ""; end
	local format = "<u><font color='%s'>%s</font></u>";
	local name = string.format( format, self.linkColor, collectionCfg.name );
	local questCfg = self.questVO:GetCfg();
	return string.format( questCfg.finishLink, name );
end

function AgoraCollectQuestGoalVO:GetNoticeLable()
	local collectId = self:GetCollectId()
	local collectionCfg = t_collection[ collectId ];
	if not collectionCfg then return ""; end

	return string.format( self.questVO:GetCfg().finishLink, collectionCfg.name) .. string.format("(%s/%s)", self.currCount, self:GetTotalCount())
end

function AgoraCollectQuestGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	local collectId = self:GetCollectId()
	local completeFuc = function()
		local result, flag = CollectionController:Collect( collectId )
		if result == false and flag == -1 then -- 采集失败:-1,找不到采集物
			local callback = function()
				TimerManager:RegisterTimer( function()
					CollectionController:Collect( collectId )
				end, 1000, 1 )
			end
			CollectionController:AddCollectionAddCallBack( callback )
		end
	end
	MainPlayerController:DoAutoRun( point.mapId, _Vector3.new(point.x, point.y, 0), completeFuc, nil, nil, nil, point.range ~= 0 and point.range or nil );
	MainPlayerController:GetPlayer():DoNpcGuildMoveToPos(point);
end

-- 是否可传送
function AgoraCollectQuestGoalVO:CanTeleport()
	return true
end

function AgoraCollectQuestGoalVO:GetPos()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg();
	if not cfg then return; end
	local point = QuestUtil:GetQuestPos(toint(cfg.postion));
	return point;
end