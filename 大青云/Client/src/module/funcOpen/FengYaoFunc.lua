--[[
封妖功能
lizhuangzhuang
2015年8月7日20:22:43
]]

_G.FengYaoFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.FengYao,FengYaoFunc);

--是否正在显示引导
FengYaoFunc.isShowGuide = false;
FengYaoFunc.closeGuideTimer = nil;

function FengYaoFunc:OnFuncOpen()
	-- TimerManager:RegisterTimer(function()
		-- self.isShowGuide = true;
		-- UIMainQuestAll:ShowQuestGuide(QuestConsts.Type_FengYao,UIFuncGuide.Type_QuestFengYao,StrConfig["funcguide002"]);
		-- self.closeGuideTimer = TimerManager:RegisterTimer(function()
			-- self.closeGuideTimer = nil;
			-- self:CloseGuide();
		-- end,30000,1);
	-- end,1000,1);
end

function FengYaoFunc:CloseGuide()
	-- if self.isShowGuide then
		-- if self.closeGuideTimer then
			-- TimerManager:UnRegisterTimer(self.closeGuideTimer);
			-- self.closeGuideTimer = nil;
		-- end
		-- self.isShowGuide = false;
		-- UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_QuestFengYao);
	-- end
end

--点击任务追踪
function FengYaoFunc:OnQuestClick()
	self:CloseGuide();
	FuncManager:OpenFunc(FuncConsts.FengYao);
end

--飞到任务栏
function FengYaoFunc:GetFlyPos()
	-- return {x=_rd.w-130,y=320};//暂时屏蔽zhumin，图标直接飞到功能处
end


function FengYaoFunc:OnBtnInit()
	
	-- if self.button.initialized then
	-- 	if self.button.effect.initialized then
	-- 		if FengYaoUtil:GetIsGetReward() == true then
	-- 			self.button.effect:playEffect(0);
	-- 		end
	-- 	else
	-- 		self.button.effect.init = function()
	-- 			if FengYaoUtil:GetIsGetReward() == true then
	-- 				self.button.effect:playEffect(0);
	-- 			end
	-- 		end
	-- 	end
	-- end
	
	self:UnRegisterNotification();
	self:RegisterNotification();

	
	self:UnRegisterTimes();
	-- self:RegisterTimeS( );
	self:initRedPoint(FengYaoUtil:GetIsGetReward());
	self:FengYaoPlayEffect(FengYaoUtil:GetIsGetReward())
end

--封妖红点提示
--adder:houxudong
--date:2016/7/29 23:33:21
FengYaoFunc.timerKey = nil;
function FengYaoFunc:initRedPoint(isShow)
	if isShow then   --FengYaoUtil:GetCanShowRedPoint( )
		PublicUtil:SetRedPoint(self.button, nil, 1)
	else
		PublicUtil:SetRedPoint(self.button, nil, 0)
	end
end

function FengYaoFunc:UnRegisterTimes( )
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

--不用了，这个情况下用比较耗，执行效率低
function FengYaoFunc:RegisterTimeS( )
	self.timerKey = TimerManager:RegisterTimer(function()
		-- self:initRedPoint();
	end,1000,0);
end

--到底是用计时器还是消息通知，这个问题需要根据实际情况来权衡这个平衡
--1.如果改变它存在的因素不经常出现。则使用消息通知
--2.如果改变它存在的因素经常出现，比如物品的变化，一秒可能有很多物品数量发生变化，建议使用计时器

--消息处理
function FengYaoFunc:RegisterNotification()
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
function FengYaoFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--处理消息
function FengYaoFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.FengYaoGetBox or
	   name == NotifyConsts.FengYaoBaoScoreAdd or
	   name == NotifyConsts.FengYaoTastFinish then
		self:FengYaoPlayEffect(FengYaoUtil:GetIsGetReward());
		self:initRedPoint(FengYaoUtil:GetIsGetReward() )
	end
end

--监听消息
function FengYaoFunc:ListNotificationInterests()
	return {
		NotifyConsts.FengYaoGetBox,
		NotifyConsts.FengYaoBaoScoreAdd,
		NotifyConsts.FengYaoTastFinish}
end

--显示按钮上的特效
function FengYaoFunc:FengYaoPlayEffect(isplay)
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