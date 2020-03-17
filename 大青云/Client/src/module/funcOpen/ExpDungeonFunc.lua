--[[
    Created by IntelliJ IDEA.
    经验副本开启
    User: Hongbin Yang
    Date: 2016/8/23
    Time: 17:23
   ]]


_G.ExpDungeonFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.experDungeon, ExpDungeonFunc);

function ExpDungeonFunc:OnFuncOpen()
	--不在任务区域显示经验副本的任务了 yanghongbin/jianghaoran 2016-7-20
	--又显示了 fuck 2016-8-22
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_EXP_Dungeon, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if QuestModel:GetQuest(questId) then
		QuestModel:UpdateQuest( questId, 0, state, goals )
	else
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end

function ExpDungeonFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end

function ExpDungeonFunc:OnBtnInit()
	if self.button.initialized then
		if self.button.effect.initialized then
			self:ShowEffect()
		else
			self.button.effect.init = function()
			self:ShowEffect()
			end
		end
	end
	self:UnRegisterNotification()
	self:RegisterNotification()
end

ExpDungeonFunc.timerKey = nil;
function ExpDungeonFunc:UnRegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

-- 不采用这个方法 废除 date:2016/11/27 01:39:25
function ExpDungeonFunc:InitRedPoint()
	self.timerKey = TimerManager:RegisterTimer(function()
		local canEnter,teamExperDungeonEnterNum = DungeonUtils:CheckWaterDungenNew()
		if canEnter then
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, teamExperDungeonEnterNum)
		else
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, 0)
		end
	end,1000,0); 
end

function ExpDungeonFunc:ShowEffect()
	local canEnter,teamExperDungeonEnterNum = DungeonUtils:CheckWaterDungenNew()
	if canEnter then
		PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, teamExperDungeonEnterNum)
		-- self.button.effect:playEffect(0)  --暂时屏蔽
		self.button.effect:stopEffect()
	else
		self.button.effect:stopEffect()
		PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, 0)
	end
end

function ExpDungeonFunc:ListNotificationInterests()
	return {
		NotifyConsts.RefreshWaterdata,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.VipJihuoEffect,
	}
end

-- 需要监听进入次数的变化，物品的变化，钻石vip的变化
function ExpDungeonFunc:HandleNotification(name, body)
	if name == NotifyConsts.RefreshWaterdata then
		self:ShowEffect()
	elseif name == NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:ShowEffect()
	elseif name == NotifyConsts.VipJihuoEffect then
		if body.vipType == VipConsts.TYPE_DIAMOND then
			self:ShowEffect()
		end
	end
end

--注册消息
function ExpDungeonFunc:RegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then
		self.notifierCallBack = function(name,body)
			self:HandleNotification(name, body);
		end
	end
	for i,name in pairs(setNotificatioin) do
		Notifier:registerNotification(name, self.notifierCallBack)
	end
end

--取消消息注册
function ExpDungeonFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

