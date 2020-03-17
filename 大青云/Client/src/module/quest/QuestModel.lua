--[[
任务Model
lizhuangzhuang
2014年8月8日17:34:10
]]

_G.QuestModel = Module:new();

QuestModel.questList = {};
-- 主线任务当前章节
QuestModel.chapter = nil;
-- 今日已完成信息（SC_DailyQuestResult）
QuestModel.dailyFinishInfo = nil;
-- 日环任务状态
QuestModel.dqState = nil;
-- 今日猎魔已完成信息（SC_DailyQuestResult）
QuestModel.lieMoFinishInfo = nil;
-- 猎魔任务状态
QuestModel.lmState = nil;
-- 本次登录的主线任务计数
QuestModel.trunkNum = 0;
--等级任务数量
QuestModel.LvQuestCount = 0;
-- 本次登录是否设置不提醒日环任务传送次数扣除
-- QuestModel.noDqTeleportComfirm = false -- 已去掉 2015年8月13日16:14:30
--空白奇遇任务的ID
QuestModel.noneRandomQuestID = QuestConsts.RandomQuestPrefix .. "0";
--完成的奇遇任务数量
QuestModel.randomQuestFinishedCount = 0;

-- 结构:SC_QueryQuestResult接收 msg.quests
function QuestModel:AddQuests(questInfoList)
	for i, questInfo in pairs(questInfoList) do
		self:AddQuest(questInfo.id, questInfo.flag, questInfo.state, questInfo.goals, false, false);
	end
	self:sendNotification(NotifyConsts.QuestRefreshList);
end

function QuestModel:GetAchievementQuestNum()
	local num = 0
	for _, quest in pairs(self.questList) do
		if quest:GetType() == QuestConsts.Type_Achievement then
			num = num + 1
		end
	end
	return num
end

--添加任务
--@param id: 任务id
--@param flag: 不同任务不同意义，参见各任务parseFlag方法
--@param state: 任务状态
--@param goals: 任务目标列表
--@param notify: 本次添加任务是否sendNotificition同步更新显示 -- 可选
--@param showRefresh: 本次添加任务是否播放刷新特效 -- 可选, 默认播放
function QuestModel:AddQuest(id, flag, state, goals, notify, showRefresh)
	if notify == nil then notify = true end -- 默认发送notifiction
	if self:GetQuest(id) ~= nil then
		self:UpdateQuest(id, flag, state, goals)
		return
	end
	local quest = QuestFactory:CreateQuest(id, flag, state, goals, showRefresh)
	if not quest then return end
	if self.questList[id] then
		Debug('已有任务不能添加:id' .. id);
		return
	end

	---------------- 奇遇任务删除重复-------------------------
	if quest:GetType() == QuestConsts.Type_Random then
		if self.questList[self.noneRandomQuestID] then
			self.questList[self.noneRandomQuestID] = nil;
		end
	end

	--------------------------------------------------------


	self.questList[id] = quest;
	quest:OnAdded()
	if notify then
		self:sendNotification(NotifyConsts.QuestAdd, { id = id, questType = quest:GetType() });
	end
	return quest
end

-- 参数说明参见AddQuest
function QuestModel:UpdateQuest(id, flag, state, goals)
	local quest = self:GetQuest(id)
	if not quest then return end
	local oldNpcId = quest:GetCurrNPC()
	quest:SetState(state)
	local newNpcId = quest:GetCurrNPC()
	local goalInfo = goals[1]
	if goalInfo then
		quest:SetGoalInfo(goalInfo);
		quest:SetGoalCount(goalInfo.current_count);
	end
	self:sendNotification(NotifyConsts.QuestUpdate, { id = id, questType = quest:GetType() })
	return quest, newNpcId, oldNpcId
end

function QuestModel:FinishQuest(id)
	local quest = QuestModel:GetQuest(id);
	if not quest then return end
	quest:Finish()
	self:sendNotification(NotifyConsts.QuestFinish, { id = id, questType = quest:GetType() });
end

--移除一个任务
function QuestModel:Remove(id)
	local quest = self.questList[id]
	if quest then
		self.questList[id] = nil
		self:sendNotification(NotifyConsts.QuestRemove, { id = id, questType = quest:GetType() })
		return quest
	end
end

--获取一个任务
function QuestModel:GetQuest(id)
	return self.questList[id];
end

--获取当前主线任务章节
function QuestModel:GetChapter()
	return self.chapter;
end

--设置当前章节
function QuestModel:SetChapter(chapter, index)
	if index == 1 then
		if self.chapter ~= chapter then
			self.chapter = chapter;
			self:OnEnterNewChapter(chapter);
		end
	end
end

--获取所有任务
function QuestModel:GetAllQuest()
	return self.questList;
end

--获取排序的所有任务
function QuestModel:GetSortedQuests()

	local list = {}
	local hasRandomQuest = false;
	for _, quest in pairs(self.questList) do
		if quest:GetType() ~= QuestConsts.Type_Level and quest:GetType() ~= QuestConsts.Type_Super then
			if quest:GetType() == QuestConsts.Type_ZhuanZhi then
				if ZhuanZhiModel:ToShowQuest() then
					table.push(list, quest)
				end
			else
				table.push(list, quest)
			end
		end
		if quest:GetType() == QuestConsts.Type_Random then
			hasRandomQuest = true;
		end
	end

	if not hasRandomQuest then
		if FuncManager:GetFuncIsOpen(FuncConsts.QuestRandom) then
			if QuestModel.randomQuestFinishedCount < RandomQuestConsts:GetRoundsPerDay() then
				local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Random, 0);
				local goals = { { current_goalsId = 0, current_count = 0 } };
				local state = QuestConsts.State_UnAccept;
				local quest = QuestFactory:CreateQuest(questId, 0, state, goals)
				if quest then
					table.push(list, quest)
				end
			end
		end
	end

	table.sort(list, function(A, B)
		local AType = A:GetType()
		local BType = B:GetType()
		if A:GetPlayRewardEffect() and B:GetPlayRewardEffect() then
			return QuestConsts.MainPageQuestIndex[AType] < QuestConsts.MainPageQuestIndex[BType];
		elseif not A:GetPlayRewardEffect() and not B:GetPlayRewardEffect() then
			return QuestConsts.MainPageQuestIndex[AType] < QuestConsts.MainPageQuestIndex[BType];
		else
			if A:GetPlayRewardEffect() then
				return true;
			else
				return false;
			end
		end
	end)
	return list
end

-- 当前有传送门任务时，返回传送门id
function QuestModel:GetQuestPortal()
	for i, questVO in pairs(self.questList) do
		local goalType = questVO:GetGoalType()
		if goalType == QuestConsts.GoalType_Potral then
			local goal = questVO:GetGoal()
			return goal:GetPortalId()
		end
	end
end

-- 当前有点击任务时,返回任务id，功能id
function QuestModel:GetCurrentClickQuest()
	for i, questVO in pairs(self.questList) do
		local goalType = questVO:GetGoalType()
		if goalType == QuestConsts.GoalType_Click then
			local goal = questVO:GetGoal()
			return questVO:GetId(), goal:GetId()
		end
	end
end

--获取主线任务VO
function QuestModel:GetTrunkQuest()
	for i, questVO in pairs(self.questList) do
		if questVO:GetType() == QuestConsts.Type_Trunk then
			return questVO;
		end
	end
	return nil;
end

-- 本次登录的主线任务计数
function QuestModel:CountTrunk()
	self.trunkNum = self.trunkNum + 1
	return self.trunkNum
end

--获取日环任务VO
function QuestModel:GetDailyQuest()
	for i, questVO in pairs(self.questList) do
		if questVO:GetType() == QuestConsts.Type_Day then
			return questVO;
		end
	end
	return nil;
end

--日环升到5星
function QuestModel:SetDailyStarFull()
	local dailyVO = self:GetDailyQuest();
	if not dailyVO then return; end
	dailyVO:FullStar();
	self:sendNotification(NotifyConsts.QuestDailyFullStar);
end

--获取日环今日完成信息
function QuestModel:GetDailyFinishInfo()
	return self.dailyFinishInfo;
end

--设置日环今日完成信息
function QuestModel:SetDailyFinishInfo(finishInfo)
	self.dailyFinishInfo = finishInfo;
	self:sendNotification(NotifyConsts.QuestDayFinish);
end

-- 设置日环任务是否抽奖状态(DQ：dailyQuest)
function QuestModel:SetDQState(state)
	if self.dqState ~= state then
		self.dqState = state
		self:sendNotification(NotifyConsts.QuestDailyStateChange)
	end
	if self.dqState == QuestConsts.QuestDailyStateFinish then
		QuestGuideManager:OnDayFinish();
	end
end

function QuestModel:GetDQState()
	if not self.dqState then
		local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
		if playerLevel < QuestConsts:GetDQOpenLevel() then
			self.dqState = QuestConsts.QuestDailyStateNone;
		else
			self.dqState = QuestConsts.QuestDailyStateFinish;
		end
	end
	return self.dqState;
end

------------------ 猎魔相关---------------------------------
function QuestModel:SetLMState(state)
	if self.lmState ~= state then
		self.lmState = state
		self:sendNotification(NotifyConsts.QuestLieMoStateChange)
	end
	if self.lmState == QuestLieMoConsts.QuestLieMoStateFinish then
		QuestGuideManager:OnLieMoFinish();
	end
end

function QuestModel:GetLMState()
	if not self.lmState then
		local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
		if playerLevel < QuestLieMoConsts:GetLMOpenLevel() then
			self.lmState = QuestLieMoConsts.QuestLieMoStateNone;
		else
			self.lmState = QuestLieMoConsts.QuestLieMoStateFinish;
		end
	end
	return self.lmState;
end

function QuestModel:SetLieMoFinishInfo(finishInfo)
	self.lieMoFinishInfo = finishInfo;
	self:sendNotification(NotifyConsts.QuestLieMoFinish);
end

function QuestModel:GetLieMoQuest()
	for i, questVO in pairs(self.questList) do
		if questVO:GetType() == QuestConsts.Type_LieMo then
			return questVO;
		end
	end
	return nil;
end

----------------- 本次登录日环任务银两双倍领提示、元宝三倍领提示是否开启设置--------------------
QuestModel.payGetSetting = { [2] = true, [3] = true };
function QuestModel:SetPayGetRewardPrompt(multiple, open)
	self.payGetSetting[multiple] = open;
end

function QuestModel:GetPayGetRewardPrompt(multiple)
	return self.payGetSetting[multiple];
end


--------------------------------- 进入新章节----------------------------------
function QuestModel:OnEnterNewChapter(chapter)
	-- UIQuestChapter:Show();
end





------------------------------- 等级任务------------------------
function QuestModel:GetLevelQuests()
	local list = {}
	QuestModel.LvQuestCount = 0;
	for _, quest in pairs(self.questList) do
		if quest:GetType() == QuestConsts.Type_Level then
			QuestModel.LvQuestCount = QuestModel.LvQuestCount + 1;
			table.push(list, quest)
		end
	end
	table.sort(list, function(A, B)
		if A:GetPlayRewardEffect() and B:GetPlayRewardEffect() then
			return A:GetId() < B:GetId()
		elseif not A:GetPlayRewardEffect() and not B:GetPlayRewardEffect() then
			return A:GetId() < B:GetId()
		else
			if A:GetPlayRewardEffect() then
				return true;
			else
				return false;
			end
		end
	end)

	return list
end

function QuestModel:HasLevelQuest()
	for _, quest in pairs(self.questList) do
		if quest:GetType() == QuestConsts.Type_Level then
			return true
		end
	end
	return false
end

---------------------------------- 历练 奇遇任务----------------------------------------------
function QuestModel:HasRandomQuest(list)
	if not list then
		list = self.questList;
	end

	for k, v in pairs(list) do
		if v:GetType() == QuestConsts.Type_Random then
			return true;
		end
	end
	return false;
end

function QuestModel:AddNoneRandomQuest()
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Random, 0);
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_UnAccept;
	QuestModel:AddQuest(questId, 0, state, goals)
end

--获取奇遇任务VO
function QuestModel:GetRandomQuest()
	for i, questVO in pairs(self.questList) do
		if questVO:GetType() == QuestConsts.Type_Random then
			return questVO;
		end
	end
	return nil;
end

--------------------------------- 讨伐任务------------------------------------------------------
function QuestModel:GetTaoFaQuest()
	for i, questVO in pairs(self.questList) do
		if questVO:GetType() == QuestConsts.Type_TaoFa then
			return questVO;
		end
	end
	return nil;
end

function QuestModel:AddTaoFaQuest()
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_TaoFa, 0);
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	local quest = QuestModel:AddQuest(questId, 0, state, goals)
	if quest then
		quest:GenerateNPCAndPosition();
	end
end

function QuestModel:RemoveTaoFaQuest()
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_TaoFa, 0);
	QuestModel:Remove(questId);
end

function QuestModel:UpdateTaoFaQuest()
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_TaoFa, 0);
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	local quest = QuestModel:UpdateQuest(questId, 0, state, goals)
	if quest then
		quest:GenerateNPCAndPosition();
	end
end

--------------------------------- 集会所 新屠魔 新悬赏任务------------------------------------------------------
function QuestModel:GetAgoraQuest()
	for i, questVO in pairs(self.questList) do
		if questVO:GetType() == QuestConsts.Type_Agora then
			return questVO;
		end
	end
	return nil;
end

function QuestModel:AddAgoraQuest(state, currentCount)
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Agora, 0);
	local goals = { { current_goalsId = 0, current_count = currentCount } };
	local quest = QuestModel:AddQuest(questId, 0, state, goals)
end

function QuestModel:RemoveAgoraQuest()
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Agora, 0);
	QuestModel:Remove(questId);
end

function QuestModel:UpdateAgoraQuest(state, currentCount)
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Agora, 0);
	local goals = { { current_goalsId = 0, current_count = currentCount } };
	local quest = QuestModel:UpdateQuest(questId, 0, state, goals)
end

--------------------------------- 挂机任务赏任务------------------------------------------------------
function QuestModel:GetHangQuest()
	for i, questVO in pairs(self.questList) do
		if questVO:GetType() == QuestConsts.Type_Hang then
			return questVO;
		end
	end
	return nil;
end

function QuestModel:AddHangQuest(state, currentCount)
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Hang, 0);
	local goals = { { current_goalsId = 0, current_count = currentCount } };
	local quest = QuestModel:AddQuest(questId, 0, state, goals)
end

function QuestModel:RemoveHangQuest()
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Hang, 0);
	QuestModel:Remove(questId);
end

function QuestModel:UpdateHangQuest(state, currentCount)
	local questId = QuestUtil:GenerateQuestId(QuestConsts.Type_Hang, 0);
	local goals = { { current_goalsId = 0, current_count = currentCount } };
	local quest = QuestModel:UpdateQuest(questId, 0, state, goals)
end

function QuestModel:CheckHangQuest()
	local hasHang = false;
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	for k, v in pairs(t_guaji) do
		if lv >= v.minlv and lv <= v.maxlv then
			hasHang = true;
			break;
		end
	end
	local trunk = QuestModel:GetTrunkQuest();
	if not trunk then return; end
	local questHang = QuestModel:GetHangQuest();
	if not questHang and trunk:GetState() == QuestConsts.State_CannotAccept then
		if hasHang then
			QuestModel:AddHangQuest(QuestConsts.State_Going, 0)
		end
	else
		if hasHang and trunk:GetState() == QuestConsts.State_CannotAccept then
			QuestModel:UpdateHangQuest(QuestConsts.State_Going, 0)
		else
			QuestModel:RemoveHangQuest()
		end
	end
end


