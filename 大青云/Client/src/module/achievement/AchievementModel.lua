--[[
	成就Model
	2015年5月20日, AM 11:32:58
	wangyanwei
]]

_G.AchievementModel = Module:new();

AchievementModel.achievementPointIndex = 0;

--收到面板信息
function AchievementModel:OnUpData(msg)
	self.achievementPointIndex = msg.pointIndex or self.achievementPointIndex;
	-- self:OnSupplementAchievement(msg.Achievement)
	if #msg.Achievement < 1 then
		self:OnInitAchievement();
	else
		self:OnInitAchievementList(msg.Achievement);
	end
	WingController:OnAchievementChange()
end

--默认生成所有成就list数据表
AchievementModel.allAchievementData = {};			--所有成就的数据
AchievementModel.IDNumConsts = 100000;
function AchievementModel:OnInitAchievementList(achievementList)

	--先将接收过来的数据做处理，排序，比同一类型最大ID小的并且为发送即为已领取
	local _achievementList = {};
	
	local achievementMaxPoint = {};		--最大的断点值
	
	for i , achievement in ipairs(achievementList) do
		local _achievement = t_achievement[achievement.id];
		if not _achievement then
			print('achievement no id !!!!!!')
		-- return end
		else
			if not _achievementList[_achievement.group] then 
				_achievementList[_achievement.group] = {};
				_achievementList[_achievement.group].group = _achievement.group;
				_achievementList[_achievement.group].achievementList = {};
				if not achievementMaxPoint[_achievement.group] or achievementMaxPoint[_achievement.group] < achievement.id then
					achievementMaxPoint[_achievement.group] = achievement.id;
				end
			end
			if _achievement.id == achievement.id then
				_achievementList[_achievement.group].achievementList[toint(achievement.id % self.IDNumConsts)] = achievement;
			end
		end
	end
	
	self.allAchievementData = {};
	for id , achievement in pairs(t_achievement) do
		if achievementMaxPoint[achievement.group] then
			if not self.allAchievementData[achievement.group] then
				self.allAchievementData[achievement.group] = {};
			end
			local vo = {};
			if not _achievementList[achievement.group].achievementList[toint(id % self.IDNumConsts)] then
				vo.state = 0;
				vo.value = 0;
				vo.id = id;
			else
				vo = _achievementList[achievement.group].achievementList[toint(id % self.IDNumConsts)];
			end
			table.push(self.allAchievementData[achievement.group],vo);
		end
	end
	self:AddAchievementDate();
	-- for i , v in ipairs(self.allAchievementData) do
		-- table.sort(v,function(A,B)
			-- return A.id < B.id;
		-- end)
	-- end
	-- for i , v in ipairs(self.allAchievementData) do
		-- trace(v)
		-- debug.debug();
	-- end
	-- debug.debug();
end

--检测未发成就列表
function AchievementModel:AddAchievementDate()
	for index , achievementStage in ipairs(t_achievementstage) do
		if not self.allAchievementData[achievementStage.id] then
			self:StageAchievementDateInit(achievementStage.id);
		end
	end
end

function AchievementModel:StageAchievementDateInit(group)
	local list = {};
	for i , achievement in pairs(t_achievement) do
		if math.floor(achievement.id / self.IDNumConsts) == group then
			local vo = {};
			vo.id = achievement.id;
			vo.state = 0;
			vo.value = 0;
			table.push(list,vo)
		end
	end
	table.sort(list,function(A,B)
		return A.id < B.id
	end)
	self.allAchievementData[group] = {};
	self.allAchievementData[group] = list;
end

-----------------自己生成默认数据----↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
function AchievementModel:OnInitAchievement()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	for i , v in pairs(t_achievement) do
		local stage = toint(v.id/100000);
		if not self.allAchievementData[stage] then
			self.allAchievementData[stage] = {};
		end
		local vo ={};
		vo.state = 0;
		vo.value = 0;
		vo.id = v.id;
		table.push(self.allAchievementData[stage],vo);
	end
	for i , v in ipairs(self.allAchievementData) do
		table.sort(v,function(A,B)
			return A.id < B.id;
		end)
	end
end

--自己补充因从未获取过而不发的成就类型
function AchievementModel:OnSupplementAchievement(list)
	if #list < 1 then return end
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	for i , v in pairs(list) do
		local stage = toint(v.id/100000);
		if not AchievementConsts[stage] then
			AchievementConsts[stage] = AchievementVO:new();
		end
		AchievementConsts[stage].achievementId = v.id;
		AchievementConsts[stage].achievementValue = v.value;
		AchievementConsts[stage].achievementState = v.state;
		-- 任务列表显示相关
		self:UpdateQuest( v.id, v.value, v.state )
	end
	-- 任务列表显示相关
	self:TryAddQuest()
end

-----------------自己生成默认数据-----↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

--进度刷新某项
function AchievementModel:OnUpDataAchievement(id,value,state)
	local group = toint(id / self.IDNumConsts);
	local achievementTypeData = self:OnGetAchievementTypeData(group);
	for i , v in pairs(self.allAchievementData) do
		for j , k in pairs(v) do
			if k.id == id then
				k.id = id;
				local cfg = t_achievement[id];
				if not cfg then
					print('not AchievementID Error');
					return
				end
				local val = 0;
				if value > cfg.val then
					val = cfg.val;
				else
					val = value;
				end
				k.value = val;
				k.state = state;
			end
		end
	end
end

--突然完成某项
function AchievementModel:OnCompleteAchievement(id)
	local group = toint(id / self.IDNumConsts);
	local achievementTypeData = self:OnGetAchievementTypeData(group);
	for i , v in pairs(self.allAchievementData) do
		for j , k in pairs(v) do
			if k.id == id then
				k.state = 1;
				k.value = t_achievement[k.id].val;
			end
		end
	end
	WingController:OnAchievementChange()
end

--根据group求该成就类型的data
function AchievementModel:OnGetAchievementTypeData(group)
	return self.allAchievementData[group]
end

--返回领取某项奖励
function AchievementModel:OnBackAchievementReward(msg)
	local id = msg.id;
	local group = toint(id / self.IDNumConsts);
	local achievementTypeData = self:OnGetAchievementTypeData(group);
	for i , v in pairs(self.allAchievementData) do
		for j , k in pairs(v) do
			if k.id == id then
				k.state = 2;
			end
		end
	end
end

--返回点数奖励
function AchievementModel:onBackAchievementPointIndex(index)
	self.achievementPointIndex = index + 1;
end

--------panel get data ↓↓↓↓↓↓↓↓↓↓↓↓↓

--获取点数奖励的阶段
function AchievementModel:GetPointIndex()
	return self.achievementPointIndex
end

--获取list内显示所需要的数据
function AchievementModel:GetAchievenmentListData()
		self:OnInitAchievement();
	local list = {};
	for i,vo in pairs(AchievementConsts) do
		table.push(list,vo);
	end
	return list
end

--获取在现在的成就列表内是否还有存在已完成未领取的
function AchievementModel:GetInComplete()
	for i , v in pairs(self.allAchievementData) do
		for j , k in pairs(v) do
			if k.state == 1 then
				return true
			end
		end
	end
	return false
end

--根据索引判断这大项中是有有已完成未领取的
function AchievementModel:GetIndexIsReward(index)
	for i , v in pairs(self.allAchievementData) do
		if i == index then
			for j , k in pairs(v) do
				if k.state == 1 then
					return true
				end
			end
		end
	end
	return false;
end

--获取点数奖励是否未领取
function AchievementModel:GetInCompletePointReward()
	local myPoint = self:GetAchievenmentAllPoint();
	local achievement = t_achievementstage[self:GetPointIndex()];
	if not achievement then
		return false;
	end
	if myPoint >= achievement.point then
		return true
	else
		return false
	end
end

--获取总点数
function AchievementModel:GetAchievenmentAllPoint()
	local num = 0;
	for i , v in ipairs(self.allAchievementData) do
		for j , k in ipairs (v) do
			if k.state == 2 then
				num = num + t_achievement[k.id].point;
			end
		end
	end
	return num;
end

--根据ID获取某项
function AchievementModel:GetAchievenment(id)
	local group = toint(id / self.IDNumConsts);
	local achievementTypeData = self:OnGetAchievementTypeData(group);
	-- if not achievementTypeData[id] then print('not achievement id ') return end
	for i , v in pairs(achievementTypeData) do
		if v.id == id then
			return v;
		end
	end
end

--获取已完成的成就
function AchievementModel:GetEndAchievement()
	local num = 0;
	for i , v in ipairs(self.allAchievementData) do
		for j , k in ipairs (v) do
			if k.state == 2 then
				num = num + 1;
			end
		end
	end
	return num;
end

--是不是全部完成
function AchievementModel:GetIsAllEnd()
	for _,achievement in pairs(AchievementConsts) do
		if achievement:GetRewardState() ~= 2 then
			return false;
		end
	end
	return true;
end

--按从小到大排序得到哪个成就有完成未领取的
function AchievementModel:OnGetIsOpenRewardIndex()
	local allAchievementData = self.allAchievementData;
	for _ , achievementData in ipairs(allAchievementData) do
		for i , achievement in ipairs(achievementData) do
			if achievement.state == 1 then
				return _;
			end
		end
	end
	return 1;
end

-------------------------------------------------任务追踪列表相关处理-----------------------------------------

function AchievementModel:TryAddQuest()
	for _, achievement in pairs(AchievementConsts) do
		local state = achievement:GetRewardState()
		if state == 0 or state == 1 then --0:未完成 or 1:已完成未领奖
			local id = achievement:GetAchievementId()
			local count = achievement:GetAchievementValue()
			if QuestModel:GetQuest(id) ~= nil then
				self:UpdateQuest( id, count, state )
			else
				self:AddQuest(id, count, state)
			end
		end
	end
end

function AchievementModel:AddQuest( id, count, state )
	if QuestModel:GetAchievementQuestNum() < QuestConsts:GetMaxAchievementQNum() then
		local questState = self:ParseState(state)
		if questState == QuestConsts.State_Finished then
			self:FinishQuest(id)
			return
		end
		local goals = {}
		table.push( goals, { current_goalsId = 0, current_count = count } )
		QuestModel:AddQuest( id, nil, questState, goals, true, false )
	end
end

function AchievementModel:UpdateQuest( id, count, state )
	if QuestModel:GetQuest(id) == nil then
		return
	end
	local questState = self:ParseState(state)
	if questState == QuestConsts.State_Finished then
		self:FinishQuest(id)
		return
	end
	local goals = {}
	table.push( goals, { current_goalsId = 0, current_count = count } )
	QuestModel:UpdateQuest( id, nil, questState, goals )
end

function AchievementModel:ParseState( state )
	if state == 0 then -- 进行中
		return QuestConsts.State_Going
	elseif state == 1 then  -- 已完成未领奖
		return QuestConsts.State_CanFinish
	elseif state == 2 then  -- 已完成已领奖
		return QuestConsts.State_Finished
	end
end

function AchievementModel:FinishQuest( id )
	self:sendNotification( NotifyConsts.QuestFinish, { id = id } );
	QuestModel:Remove( id )
	self:TryAddQuest()
end
--根本id获得某项成就的完成状态
function AchievementModel:GetState(id)
	for i , v in pairs(self.allAchievementData) do
		for j , k in pairs(v) do
			if k.id == id then
				return k.state
			end
		end
	end
end

-------------------------------------------------========================--------------------------------------------------
--突然完成某项
-- function AchievementModel:OnCompleteAchievement(id)
	-- for i , v in pairs(AchievementConsts) do
		-- if v:GetAchievementId() == id then
			-- local state = 1 -- 1：完成，未领奖
			-- local count = t_achievement[id].val or 0
			-- v:SetRewardState( state );
			-- v:SetAchievementValue( count );
			-- 任务列表显示相关
			-- self:UpdateQuest( id, count, state )
			-- return
		-- end
	-- end
-- end

--返回领取某项奖励
-- function AchievementModel:OnBackAchievementReward(msg)
	-- for i , v in pairs(AchievementConsts) do
		-- if v:GetAchievementId() == msg.id then
			-- v.achievementState = 2;
			-- 任务列表显示相关
			-- self:FinishQuest( msg.id )
			-- return
		-- end
	-- end
-- end