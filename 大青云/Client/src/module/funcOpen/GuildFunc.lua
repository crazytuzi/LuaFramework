--[[
帮派
ly
]]

_G.GuildFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Guild,GuildFunc);
function GuildFunc:OnBtnInit()
	self.button.mcLvlUp._visible = false;
	self:SetLvlUp()
	self:UnRegisterNotification()
	self:RegisterNotification()
	self:InitRedPoint()
end

--帮派升级提示和有新队员时提示
GuildFunc.timerKey = nil;
GuildFunc.guidLoader = nil;
function GuildFunc:InitRedPoint( )
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local isNewApply,applyNum = UnionUtils:CheckJoinNewpattern( )
		local qingtongNum,baiyinNum,huangjinNum = UnionUtils:CheckContribution()
		if UnionUtils:CheckCanUnionLvUp( ) or isNewApply or qingtongNum>0 or baiyinNum>0 or huangjinNum>0 or UnionUtils:CheckAidLevelUp() or UnionUtils:CheckPray() then   
			PublicUtil:SetRedPoint(self.button, nil, 1)
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)
		end
	end,1000,0);
end

function GuildFunc:InitRedPointForListen( listen )
	-- WriteLog(LogType.Normal,true,'-------------houxudong',listen)
	-- if listen then
	-- 	self.guidLoader = BaseUI:SetRedPoint(self.button,nil,RedPointConst.showRedPoint,RedPointConst.showExclamationPoint)
	-- 	if self.guidLoader then
	-- 		self.guidLoader._x = self.button._width;
	-- 	end
	-- else
	-- 	if self.guidLoader then 
	-- 		BaseUI:RemoveRedPoint(self.guidLoader)
	-- 		self.guidLoader = nil;
	-- 	return; end
	-- end
end

function GuildFunc:SetLvlUp()
	-- if self.state == FuncConsts.State_Open then
	-- 	if UnionModel:IsLeader() then   --判断是不是帮主
	-- 		if UnionModel.applyNum and UnionModel.applyNum > 0 then
	-- 			self.button.mcLvlUp._visible = true;
	-- 		else
	-- 			self.button.mcLvlUp._visible = false;
	-- 		end
		
	-- 	else
	-- 		self.button.mcLvlUp._visible = false;
	-- 	end
	-- else
	-- 	self.button.mcLvlUp._visible = false;
	-- end
end

function GuildFunc:OnFuncOpen()
	UnionModel:UpdateToQuest()
end

function GuildFunc:SetState(state)
	self.state = state;
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
end



--处理消息
function GuildFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.ReplyGuildNumChanged or name == NotifyConsts.UpdateLvUpGuild or name == NotifyConsts.UpdateGuildInfo then
		self:SetLvlUp()
	end
	-- if name == NotifyConsts.UpdateGuildApplyList then
	-- 	self:InitRedPointForListen(body.NewPattern)
	-- end
end

--消息处理
function GuildFunc:RegisterNotification()
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
function GuildFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function GuildFunc:ListNotificationInterests()
	return {
		NotifyConsts.ReplyGuildNumChanged,   --帮派申请人数变化
		NotifyConsts.UpdateLvUpGuild,	     --升级帮派		
		NotifyConsts.UpdateGuildInfo,        --更新帮派信息
		-- NotifyConsts.UpdateGuildApplyList,   --申请(审核)列表
	} 
end
