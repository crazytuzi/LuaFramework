--[[
 挖宝
 wangshuai 
]]

_G.WaBaoModel = Module:new();

WaBaoModel.WaBaoInfo = {};
--是否已添加到任务中
WaBaoModel.hasAddToQuest = false;
WaBaoModel.isIng = false;

--设置挖宝数据
function WaBaoModel:SetWaBaoInfo(pos1,pos2,wabaoid,getlvl,lastNum,lookPoint)
	local vo = {};
	vo.pos1 = pos1;
	vo.pos2 = pos2;
	vo.wabaoid = wabaoid * 10000 + getlvl;
	vo.getlvl = getlvl;
	vo.lastNum = lastNum;
	vo.lookPoint = lookPoint;
	self.WaBaoInfo = vo;
	Notifier:sendNotification(NotifyConsts.WabaoinfoUpdata);
	if vo.lastNum == 0 then 
		self.isIng = true;
		if wabaoid == 0 then 
			self.isIng = false;
		end;
	end;
	self:UpdataToQuest();
end;

--同步到任务追踪
function WaBaoModel:UpdataToQuest()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_WaBao, 0 )
	local goals = { { current_goalsId = 0, current_count = 0 } }
	local state = QuestConsts.State_CanAccept;
	if self.WaBaoInfo.wabaoid~=0 and self.WaBaoInfo.getlvl~=0 then
		state = QuestConsts.State_Going;
	end
	if self.hasAddToQuest then
		if self:GetWabaoNum2() == 0 then
			QuestModel:Remove(questId);
			self.hasAddToQuest = false;
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if self:GetWabaoNum2() == 0 then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
		self.hasAddToQuest = true;
	end
end

--挖宝今日是否已完成
function WaBaoModel:GetTodayFinish2()
	if not FuncManager:GetFuncIsOpen(FuncConsts.WaBao) then
		return false;
	end
	if self:GetWabaoNum2() == 0 then
		return true;
	end
	return false;
end

function WaBaoModel:GetWabaoNum2()
	local vo = self.WaBaoInfo.lastNum or 10
	if self.isIng then 
		return vo + 1;
	end;
	return self.WaBaoInfo.lastNum or 10
end;


--挖宝今日是否已完成
function WaBaoModel:GetTodayFinish()
	if not FuncManager:GetFuncIsOpen(FuncConsts.WaBao) then
		return false;
	end
	if self:GetWabaoNum() == 0 then
		return true;
	end
	return false;
end

function WaBaoModel:GetWabaoNum()
	return self.WaBaoInfo.lastNum or 10
end;

function WaBaoModel:SetWaBaoInfoLookPoint(id)
	self.WaBaoInfo.lookPoint = id;
	Notifier:sendNotification(NotifyConsts.WabaoinfoPointUpdata);
end

--  清空
function WaBaoModel:ClaerData()
	self:SetWaBaoInfo(0,0,0,0,self.WaBaoInfo.lastNum,0)
	if self.WaBaoInfo.lastNum == 0 then 
		self.isIng = false;
	end;
	Notifier:sendNotification(NotifyConsts.WabaoinfoCancel)
end;

function WaBaoModel:GetWaBoaInfo()
	return self.WaBaoInfo;
end;


