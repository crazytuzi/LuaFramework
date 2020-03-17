--[[
活跃度特效
zhangshuhui
2015年3月28日18:00:00
]]

_G.HuoYueDuFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.HuoYueDu,HuoYueDuFunc);

HuoYueDuFunc.timerKey = nil;
HuoYueDuFunc.huoyueduLoader = nil;
function HuoYueDuFunc:OnBtnInit()
	-- if self.button.initialized then
	-- 	if self.button.effect.initialized then
	-- 		if HuoYueDuUtil:GetIsHaveNotGetReward() == true then
	-- 			self.button.effect:playEffect(0);
	-- 		end
	-- 	else
	-- 		self.button.effect.init = function()
	-- 			if HuoYueDuUtil:GetIsHaveNotGetReward() == true then
	-- 				self.button.effect:playEffect(0);
	-- 			end
	-- 		end
	-- 	end
	-- end
	
	-- self:UnRegisterNotification();
	-- self:RegisterNotification();
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		if HuoYueDuController:GetXianjieUpdate() then
			-- PublicUtil:SetRedPoint(self.button, nil, 1)
			self.button.redpointNum._visible = true;
		else
			-- PublicUtil:SetRedPoint(self.button, nil, 0)
			self.button.redpointNum._visible = false;
		end
	end,1000,0); 

end

--处理消息
function HuoYueDuFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.HuoYueDuFinishUpdata or
	   name == NotifyConsts.HuoYueDuAwardUpdata then
		self:HuoYueDuPlayEffect(HuoYueDuUtil:GetIsHaveNotGetted());
	end
end

--消息处理
function HuoYueDuFunc:RegisterNotification()
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
function HuoYueDuFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function HuoYueDuFunc:ListNotificationInterests()
	return {
		NotifyConsts.HuoYueDuFinishUpdata,
		NotifyConsts.HuoYueDuAwardUpdata} 
end

function HuoYueDuFunc:HuoYueDuPlayEffect(isplay)
	if not self.button then return; end
	if isplay == true then
		if self.button.effect then
			if self.button.effect.initialized then
				self.button.effect:playEffect(0);
			end
		else
			self.button.effect.init = function()
				self.button.effect:playEffect(0);
			end
		end
	else
		if self.button.effect then
			if self.button.effect.initialized then
				self.button.effect:stopEffect()
			else
				self.button.effect.init = function()
					self.button.effect:stopEffect();
				end
			end
		end
	end
end

--是否已添加到任务
HuoYueDuFunc.hasAddToQuest = false;
function HuoYueDuFunc:OnFuncOpen()
	--[[
	--不在任务区域显示仙阶的任务了 yanghongbin/jianghaoran 2016-7-20
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_HuoYueDu, 0 );
	-- WriteLog(LogType.Normal,true,'----HuoYueDuFunc:OnFuncOpen',questId);
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

function HuoYueDuFunc:OnQuestClick()
	 FuncManager:OpenFunc(FuncConsts.HuoYueDu);
end

function HuoYueDuFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
	
end
