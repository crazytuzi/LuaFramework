--[[
转职
chenyujia
]]

_G.ZhuanZhiModel = Module:new();

ZhuanZhiModel.count = 0
ZhuanZhiModel.zhuanzhiComInfo = {}
ZhuanZhiModel.zhuanzhiTask = nil
ZhuanZhiModel.zhuanzhiLv=0;


function ZhuanZhiModel:UpDateZhuanZhiInfo(count)
	self.count = count or 0
end

function ZhuanZhiModel:IsGetReward(id)
	return self.count >= id
end

function ZhuanZhiModel:GetCount()
	return self.count
end

function ZhuanZhiModel:UPDateZhuanZhiCom(id, state, value)
	if not FuncManager:GetFuncIsOpen(FuncConsts.ZhuanZhi) then return; end
	state = state == 1 and QuestConsts.State_CanFinish or QuestConsts.State_Going
	if self.zhuanzhiTask and self.zhuanzhiTask:GetId() == id then
		if self.zhuanzhiLv == ZhuanZhiConsts.MaxLv then
			QuestModel:Remove(self.zhuanzhiTask:GetId());
		else
			self.zhuanzhiTask:SetGoalCount(value)
			self.zhuanzhiTask:SetState(state, true)
			local goals = { { current_goalsId = 0, current_count = value } };
			QuestModel:UpdateQuest( id, 0, state, goals )
		end
	else
		if self.zhuanzhiTask then
			if self.zhuanzhiTask:GetId() ~= id then
				--清除之前的任务
				QuestModel:Remove(self.zhuanzhiTask:GetId());
			end
		end

		if self.zhuanzhiLv < ZhuanZhiConsts.MaxLv then
			self.zhuanzhiTask = QuestModel:AddQuest( id, nil, state, {{current_goalsId = 0, current_count = value}});
		end
	end
	self:sendNotification(NotifyConsts.ZhuanZhiUpdate)
end

function ZhuanZhiModel:ToShowQuest()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local zzLv = self.zhuanzhiLv + 1;
	if zzLv >= ZhuanZhiConsts.MaxLv then zzLv = ZhuanZhiConsts.MaxLv; end
	if t_transferattr[zzLv].limit - myLevel <= 1 then return true; end
end

function ZhuanZhiModel:getTask()
	return self.zhuanzhiTask
end

function ZhuanZhiModel:SetLv(zhuanzhiLv)
	self.zhuanzhiLv = zhuanzhiLv or 0
	if self.zhuanzhiLv == ZhuanZhiConsts.MaxLv then
		if self.zhuanzhiTask then
			--清除之前的任务
			QuestModel:Remove(self.zhuanzhiTask:GetId());
		end
	end
end

--获得当前转生处于几转的状态
function ZhuanZhiModel:GetLv()
	return self.zhuanzhiLv or 0
end
--获取到当前任务中转职的奖励
function ZhuanZhiModel:GetShowTaskReward()
	for k, v in pairs(t_transfer) do
		if v.number == self.zhuanzhiTask:GetId() then
			local randomList = RewardManager:Parse( v.reward );
			return randomList;
		end
	end
end

-- 获取应该显示在任务引导中的转职任务
function ZhuanZhiModel:GetShowTask()
	local nextLv = self.zhuanzhiLv  + 1
	if nextLv > ZhuanZhiConsts.MaxLv then
		return nil
	end
	-- if t_transferattr[nextLv].limit > MainPlayerModel.humanDetailInfo.eaLevel then
	-- 	return nil
	-- end
	if not FuncManager:GetFuncIsOpen(FuncConsts.ZhuanZhi) then
		return nil
	end

	return self.zhuanzhiTask
end

function ZhuanZhiModel:AskGetReward(taskid)
	for k, v in pairs(t_transfer) do
		if v.number == taskid then
			ZhuanZhiController:AskGetReward(v.id)
		end
	end
end

function ZhuanZhiModel:IsHaveRewardCanGet()
	if not FuncManager:GetFuncIsOpen(FuncConsts.ZhuanZhi) then
		return false
	end
	if not self.zhuanzhiTask then return false end
	local id = self.zhuanzhiTask:GetId()
	for k, v in pairs(t_transfer) do
		if v.id == self.count + 1 and id == v.number and self.zhuanzhiTask:GetState() == QuestConsts.State_CanFinish then
			return true
		end
	end
end