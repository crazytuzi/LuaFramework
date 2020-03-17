--[[
任务目标：到达传送门
haohu
2015年5月20日19:09:52
]]

_G.PortalQuestGoalVO = setmetatable( {}, {__index = QuestGoalVO} );

function PortalQuestGoalVO:GetType()
	return QuestConsts.GoalType_Potral;
end

function PortalQuestGoalVO:DoGoal()
	local point = self:GetPos();
	if not point then return; end
	MainPlayerController:DoAutoRun( point.mapId, _Vector3.new( point.x, point.y, 0 ) );
end

-- 是否可传送
function PortalQuestGoalVO:CanTeleport()
	return true
end

--获取任务位置信息
-- @return {mapId, x, y};
function PortalQuestGoalVO:GetPos()
	local guideParam = self.guideParam[1];
	if not guideParam then return; end
	local posId = tonumber( guideParam );
	return QuestUtil:GetQuestPos(posId);
end

--获取目标传送门坐标
function PortalQuestGoalVO:GetToPortalPos()
	local goalParam = self.goalParam[2]
	local portalId = tonumber( goalParam )
	local portalCfg = t_portal[portalId]
	local posTable = portalCfg and portalCfg.target_pos
	if not posTable then return end
	return posTable[1], posTable[2]
end

--获取在快捷任务显示的信息(格式)
function PortalQuestGoalVO:GetGoalLabel(size, color)
	local format = "<font size='%s' color='%s'>%s</font>";
	if not size then size = 14 end;
	if not color then color = "#ffffff" end;
	local strSize = tostring( size );
	local name = self:GetLabelContent();
	return string.format( format, strSize, color, name );
end

--获取在快捷任务显示的信息(无格式)
function PortalQuestGoalVO:GetLabelContent()
	local portalId = self:GetPortalId()
	if not portalId then return "" end
	local portalCfg = t_portal[ portalId ]
	local portalName = portalCfg.name
	local quest = self.questVO
	local cfg = quest:GetCfg()
	return string.format( cfg.unFinishLink, portalName );
end

function PortalQuestGoalVO:GetPortalId()
	return tonumber( self.goalParam[2] )
end