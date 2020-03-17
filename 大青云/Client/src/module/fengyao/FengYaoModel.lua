--[[封妖Model
zhangshuhui
2014年12月04日14:20:20
]]

_G.FengYaoModel = Module:new();

--当前封妖活动信息
FengYaoModel.fengyaoinfo = {};
FengYaoModel.fengyaoinfo.fengyaoGroup = 0;
FengYaoModel.fengyaoinfo.fengyaoId = 0;
FengYaoModel.fengyaoinfo.curState = 0;
FengYaoModel.fengyaoinfo.finishCount = 0;
FengYaoModel.fengyaoinfo.curScore = 0;
FengYaoModel.curKillMonserNum = 0;
FengYaoModel.curHasTime = 0;
FengYaoModel.getAServerTime = 0
FengYaoModel.fengyaoinfo.boxedlist = {};
--当前妖怪列表
FengYaoModel.fengyaolist = {};
--是否选中复选框多倍领取提示框
FengYaoModel.isSelectTwoConfirmPanel = false;
FengYaoModel.isSelectThreeConfirmPanel = false;

--设置封妖信息
function FengYaoModel:SetFengYaoInfo(fengyaoinfo)
	self.fengyaoinfo  = fengyaoinfo;
	
	self.fengyaolist = {};
	self.fengyaolist = FengYaoUtil:GetFengYaoListByGroupid(self.fengyaoinfo.fengyaoGroup);
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoInfo:',self.fengyaoinfo.fengyaoId)
	self:UpdataToQuest();
end

--设置可选封妖Id
function FengYaoModel:SetFengYaoId(fengyaoid)
	local oldid = self.fengyaoinfo.fengyaoId;
	self.fengyaoinfo.fengyaoId = fengyaoid;
	self.fengyaoinfo.fengyaoGroup = t_fengyao[fengyaoid].group_id;
	self.fengyaolist = {};
	self.fengyaolist = FengYaoUtil:GetFengYaoListByGroupid(self.fengyaoinfo.fengyaoGroup);
	
	self:sendNotification(NotifyConsts.FengYaoListChanged);
	self:UpdataToQuest();
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoId:',self.fengyaoinfo.fengyaoId)
	self:sendNotification(NotifyConsts.FengYaoLevelRefresh,{fengyaoid=fengyaoid, oldid=oldid});
end

--设置接受封妖状态
function FengYaoModel:SetFengYaoState(fengyaoid, curState)
	self.fengyaoinfo.fengyaoId = fengyaoid;
	self.fengyaoinfo.curState = curState;
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoState:',self.fengyaoinfo.fengyaoId)
	self:sendNotification(NotifyConsts.FengYaoStateChanged);
	--
	self:UpdataToQuest();

	self:FengYaoNotice()
end

function FengYaoModel:FengYaoNotice(curKillMonserNums)
	if curKillMonserNums then
		local level = MainPlayerModel.humanDetailInfo.eaLevel
		local monsterNum = t_fengyaogroup[level].number;
		if curKillMonserNums ~= 0 then
			UIQuestNotice:ShowTaskNotice(string.format("[%s]", QuestConsts:GetTypeLabel(QuestConsts.Type_FengYao)) .. StrConfig['fengyao315'] .. string.format("(%s/%s)", curKillMonserNums, monsterNum))
			if curKillMonserNums == monsterNum then
				UIQuestNotice:ShowTaskNotice(string.format("[%s]%s", QuestConsts:GetTypeLabel(QuestConsts.Type_FengYao), StrConfig['quest1002']))
			end
		end
	elseif self.fengyaoinfo.curState == FengYaoConsts.ShowType_Accepted then
		UIQuestNotice:ShowTaskNotice(string.format("[%s]%s", QuestConsts:GetTypeLabel(QuestConsts.Type_FengYao), StrConfig['quest1001']))
	end
end

--设置接受封妖状态
function FengYaoModel:SetFengYaoFinishState(fengyaoid, curState)
	self.fengyaoinfo.fengyaoId = fengyaoid;
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoFinishState:',self.fengyaoinfo.fengyaoId)
	self.fengyaoinfo.curState = curState;
	
	self:sendNotification(NotifyConsts.FengYaoTastFinish);
	self:UpdataToQuest();
end

--设置任务悬赏倒计时
function FengYaoModel:SetQuestDaoJiShiState()
	self:UpdataToQuest();
end
--设置任务悬赏杀怪数目
function FengYaoModel:SetCurKillMonserNum(curKillMonserNums)
	FengYaoModel.curKillMonserNum = curKillMonserNums;
	self:UpdataToQuest();
	self:FengYaoNotice(curKillMonserNums)
end

--设置积分状态
function FengYaoModel:SetFengYaoScoreState(fengyaoid, curScore, curState)
	self.fengyaoinfo.fengyaoId = fengyaoid;
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoScoreState:',self.fengyaoinfo.fengyaoId)
	self.fengyaoinfo.curScore = curScore;
	self.fengyaoinfo.curState = curState;
	self.fengyaoinfo.finishCount = self.fengyaoinfo.finishCount + 1;
	
	self:sendNotification(NotifyConsts.FengYaoBaoScoreAdd);
	self:UpdataToQuest();
end

--设置封妖列表
function FengYaoModel:SetFengYaoGroup(fengyaoid, fengyaoGroup, curState)
	self.fengyaoinfo.fengyaoId = fengyaoid;
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoGroup:',self.fengyaoinfo.fengyaoId)
	self.fengyaoinfo.fengyaoGroup = fengyaoGroup;
	self.fengyaoinfo.curState = curState;
	
	self.fengyaolist = {};
	self.fengyaolist = FengYaoUtil:GetFengYaoListByGroupid(self.fengyaoinfo.fengyaoGroup);
	
	self:sendNotification(NotifyConsts.FengYaoListChanged);
	self:UpdataToQuest();
end

--是否已添加到任务
FengYaoModel.hasAddToQuest = false;
--同步到任务追踪
function FengYaoModel:UpdataToQuest()
--[[	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_FengYao, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if self.hasAddToQuest then
		--if self.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
		--封妖积分大于150，也就是最大积分后不显示在任务栏中了。 yanghongbin/jianghaoran/dongtu 2-16-8-22
		if FengYaoModel.fengyaoinfo.curState >= FengYaoConsts:GetMaxScore() then
			QuestModel:Remove(questId);
			self.hasAddToQuest = false;
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		--if self.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount then
		if FengYaoModel.fengyaoinfo.curState >= FengYaoConsts:GetMaxScore() then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
		self.hasAddToQuest = true;
	end]]
end

--封妖今日是否已完成
function FengYaoModel:GetTodayFinish()
	if not FuncManager:GetFuncIsOpen(FuncConsts.FengYao) then
		return false;
	end
	if not self.fengyaoinfo then
		return false;
	end
	if not self.fengyaoinfo.finishCount then
		return false;
	end
	return self.fengyaoinfo.finishCount >= FengYaoConsts.FengYaoMaxCount;
end

--添加一个空宝箱
function FengYaoModel:Addbox(boxId)
	table.push(self.fengyaoinfo.boxedlist,boxId);
	
	self:sendNotification(NotifyConsts.FengYaoGetBox,{boxId=boxId});
end

function FengYaoModel:GetIsSelectTwoConfirmPanel()
	return self.isSelectTwoConfirmPanel;
end
function FengYaoModel:SetIsSelectTwoConfirmPanel(isopen)
	self.isSelectTwoConfirmPanel = isopen;
end
function FengYaoModel:GetIsSelectThreeConfirmPanel()
	return self.isSelectThreeConfirmPanel;
end
function FengYaoModel:SetIsSelectThreeConfirmPanel(isopen)
	self.isSelectThreeConfirmPanel = isopen;
end
--是否可领奖
function FengYaoModel:HasCanReward()
	return self.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward;
end