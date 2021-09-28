-- AICellVo
AICellVo =BaseClass()

--判定条件
AICellVo.DecisionType =
{
	No = 0,					--无条件
	SelfHpLess = 1,			--自身血量低于%
	PlayerHpLess = 2,	 	--玩家血量低于%
	MonsterHpLess = 3,  	--怪物血量低于%
	DistanceLess = 4,	 	--与玩家距离小于
	DistanceGreater  = 5,	--与玩家距离大于
}

--目标类型
AICellVo.TargetType =
{
	Player = 0,				--玩家
	Monster = 1,			--怪物
	Buff = 2,	 			--BUFF
}

--目标选取
AICellVo.TargetChoice =
{
	NearSelect = 0,			--就近选取
	Hatest = 1,				--仇恨最高
	HpLeast = 2,	 		--血量最低
}

--行为类型
AICellVo.ActionType =
{
	No = 0,					--释放技能
	SelfHpLess = 1,			--定点移动
	PlayerHpLess = 2,	 	--选取移动
	MonsterHpLess = 3,  	--跟随玩家
	DistanceLess = 4,	 	--瞬移玩家
}

function AICellVo:__init(determinationId)
	self.determinationData = AICellVo.GetDeterminationData(tonumber(determinationId))
	self.executionData = AICellVo.GetExecutionData(tonumber(self.determinationData.actionId))
end

--获取AI判断数据
--@param determinationId cfg_aidetermination表中的Id
function AICellVo.GetDeterminationData(determinationId)
	local determinationData = GetCfgData("aidetermination"):Get(determinationId)
	if determinationData then 
		return determinationData
	else 
		error("AICellVo:GetDeterminationData() get a nil data, id:"..determinationId)
	end
end

--获取AI执行数据
--@param executionId cfg_aiexecution表中的Id
function AICellVo.GetExecutionData(executionId)
	local executionData = GetCfgData("aiexecution"):Get(executionId)
	if executionData then 
		return executionData
	else 
		error("AICellVo:GetExecutionData() get a nil data, id:"..determinationId)
	end
end