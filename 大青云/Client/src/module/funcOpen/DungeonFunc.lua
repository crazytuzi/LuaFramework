--[[
副本功能
author:houxudong
date:2016/8/3
]]

_G.DungeonFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.singleDungeon, DungeonFunc);
DungeonFunc.timerKey = nil;

function DungeonFunc:OnBtnInit()
	if self.button.initialized then
		if self.button.effect.initialized then
			self:CheckBtnCanShowEffect()
		else
			self.button.effect.init = function()
				self:CheckBtnCanShowEffect()
			end
		end
	end
	
	self:UnRegisterNotification();
	self:RegisterNotification();

	self:RegisterTimes();
	self:initRedPoint();
end

function DungeonFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function DungeonFunc:initRedPoint()
	self.timerKey = TimerManager:RegisterTimer(function()
		local canIn,num = DungeonUtils:GetDungeonCanCome()
		if canIn then
			PublicUtil:SetRedPoint(self.button,RedPointConst.showNum,num)
		else
			PublicUtil:SetRedPoint(self.button,RedPointConst.showNum,0)
		end
	end,1000,0); 
end


--副本大厅按钮的特效显示的监控 
function DungeonFunc:CheckBtnCanShowEffect( netMsg )
	if netMsg and DungeonUtils:GetDungeonCanCome() then
		-- self.button.effect:playEffect(0);  --暂时屏蔽           --有新的触发机制时触发特效
		return;
	end
	if DungeonUtils:GetDungeonCanCome() then
		-- self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect(0);
	end
end

--点击按钮  重写父类的点击方法
function DungeonFunc:OnBtnClick()
	if self.state == FuncConsts.State_Open then
		FuncManager:OpenFunc(self:GetId(),true);
	end
	self.button.effect:stopEffect(0);  --点击的时候特效消息
end


--处理消息
function DungeonFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	--判断副本大厅这个按钮有没有开启，但是现在即使副本大厅开启了，但是里面的子功能也有可能没有开启，
	--已经不能用这个方法来判断了，真是个蛋疼的问题

	-- if name == NotifyConsts.HuoYueDuFinishUpdata or
	   -- name == NotifyConsts.HuoYueDuAwardUpdata then
		-- self:HuoYueDuPlayEffect(HuoYueDuUtil:GetIsHaveNotGetted());
	-- end
	if name == NotifyConsts.PlayerAttrChange then
		-- self:OnFuncOpen()
		if body.type == enAttrType.eaLevel then
			self:CheckBtnCanShowEffect(true)
		end
	end
end

--消息处理
function DungeonFunc:RegisterNotification()
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
function DungeonFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function DungeonFunc:ListNotificationInterests()
	return {
		-- NotifyConsts.HuoYueDuFinishUpdata,
		-- NotifyConsts.HuoYueDuAwardUpdata,
		NotifyConsts.PlayerAttrChange,} 
end

--是否已添加到任务
DungeonFunc.hasAddToQuest = false;
function DungeonFunc:OnFuncOpen()
	--[[
	-- 不显示了 废弃
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Single_Dungeon, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if self.hasAddToQuest then
		QuestModel:UpdateQuest( questId, 0, state, goals )
	else
		QuestModel:AddQuest( questId, 0, state, goals )
		self.hasAddToQuest = true;
	end
	]]
end

function DungeonFunc:OnQuestClick()
	 FuncManager:OpenFunc(FuncConsts.singleDungeon);
end

function DungeonFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
	-- WriteLog(LogType.Normal,true,'----DungeonFunc:SetState',state);
end
