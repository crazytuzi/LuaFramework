--[[
封妖管理
zhangshuhui
2014年12月04日14:20:20
]]
_G.FengYaoController = setmetatable({},{__index=IController})
FengYaoController.name = "FengYaoController";

--剩余时间定时器key
FengYaoController.lastTimerKey = nil;

function FengYaoController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FengYaoInfo,self,self.OnFengYaoInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_FengYaoLvlRefreshResult,self,self.OnFengYaoLvlRefreshResult);
	-- MsgManager:RegisterCallBack(MsgType.SC_AcceptFengYaoResult,self,self.OnAcceptFengYaoResult);
	MsgManager:RegisterCallBack(MsgType.SC_FinishFengYao,self,self.OnFinishFengYao);
	MsgManager:RegisterCallBack(MsgType.SC_GetFengYaoReward,self,self.OnGetFengYaoRewardResult);
	-- MsgManager:RegisterCallBack(MsgType.SC_GiveupFengYaoResult,self,self.OnGiveupFengYaoResult);
	MsgManager:RegisterCallBack(MsgType.SC_RefreshFengYaoList,self,self.OnRefreshhFengYaoList);
	MsgManager:RegisterCallBack(MsgType.SC_GetFengYaoBoxResult,self,self.OnGetFengYaoBoxResult);
	MsgManager:RegisterCallBack(MsgType.SC_FengYaoRefreshState,self,self.OnFengYaoRefreshStateResult);
	MsgManager:RegisterCallBack(MsgType.SC_ZhanYaoMosterCountInfo,self,self.OnZhanYaoMosterCount);
	MsgManager:RegisterCallBack(MsgType.SC_ZhanYaoTimeLeftInfo,self,self.OnZhanYaoTimeLeft);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求封妖列表
function FengYaoController:ReqFengYaoInfo()
	--print('======请求封妖列表')
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoController ReqFengYaoInfo')
	-- local msg = ReqFengYaoInfoMsg:new()
	-- MsgManager:Send(msg)
end
-- 难度刷新
function FengYaoController:ReqFengYaoLvlRefresh(type1)
	-- print('=======================难度刷新'..type1)
	local msg = ReqFengYaoLvlRefreshMsg:new()
	msg.type = type1
	MsgManager:Send(msg)
end
-- 接受封妖任务
-- function FengYaoController:ReqAcceptFengYao(fengyaoid)
	--print('======接受封妖任务'..fengyaoid)
	
	-- local msg = ReqAcceptFengYaoMsg:new()
	-- msg.fengyaoid = fengyaoid
	-- MsgManager:Send(msg)
-- end
-- 领取封妖奖励
function FengYaoController:ReqGetFengYaoReward(fengyaoid, type)
	--print('======领取封妖奖励'..fengyaoid)
	
	local msg = ReqGetFengYaoRewardMsg:new()
	msg.fengyaoid = fengyaoid
	-- msg.type = type;
	MsgManager:Send(msg)
end
-- 放弃封妖
-- function FengYaoController:ReqGiveupFengYao(fengyaoid)
	--print('======放弃封妖'..fengyaoid)
	
	-- local msg = ReqGiveupFengYaoMsg:new()
	-- msg.fengyaoid = fengyaoid
	-- MsgManager:Send(msg)
-- end
-- 获取封妖宝箱奖励
function FengYaoController:ReqGetFengYaoBox(boxId)
	--print('======获取封妖宝箱奖励'..boxId)
	
	local msg = ReqGetFengYaoBoxMsg:new()
	msg.boxId = boxId
	MsgManager:Send(msg)
end
-- 状态刷新
function FengYaoController:ReqRefreshFengYaoState()
	--print('======状态刷新')
	
	local msg = ReqFengYaoRefreshStateMsg:new()
	MsgManager:Send(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回封妖信息
function FengYaoController:OnFengYaoInfoResult(msg)
	-- WriteLog(LogType.Normal,true,"============返回封妖信息")
	-- trace(msg)
	local fengyaoinfo = {};
	fengyaoinfo.fengyaoId = msg.fengyaoId;
	if msg.fengyaoId==0 then
		fengyaoinfo.fengyaoGroup = msg.fengyaoGroup
	else
		fengyaoinfo.fengyaoGroup = t_fengyao[msg.fengyaoId].group_id;
	end
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoInfo fengyaoGroup:',msg.fengyaoId)
	-- WriteLog(LogType.Normal,true,'--------------------FengYaoModel:SetFengYaoInfo fengyaoId:',t_fengyao[msg.fengyaoId].group_id)
	fengyaoinfo.curState = msg.curState;
	fengyaoinfo.finishCount = msg.finishCount;
	fengyaoinfo.curScore = msg.curScore;
	local list = {};
	for i,vo in pairs(msg.boxList) do
		if vo then
			table.push(list,vo.boxId);
		end
	end
	fengyaoinfo.boxedlist = list;
	
	--设置封妖信息
	FengYaoModel:SetFengYaoInfo(fengyaoinfo);
	--是否显示完成提示
	if fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		--RemindController:AddRemind(RemindConsts.Type_FengYao,1);
	end
	
	-- self:StartLastTimer();
end
-- 返回难度刷新
function FengYaoController:OnFengYaoLvlRefreshResult(msg)
	-- print("============返回难度刷新",msg.result)
	-- trace(msg)
	
	if msg.result == 0 then
		FengYaoModel:SetFengYaoId(msg.fengyaoid)
		FengYaoModel:SetFengYaoState(msg.fengyaoid, FengYaoConsts.ShowType_Accepted);
	end
end
-- 返回接受封妖活动
-- function FengYaoController:OnAcceptFengYaoResult(msg)
	-- print("============返回接受封妖活动")
	-- trace(msg)
	
	-- FengYaoModel:SetFengYaoState(msg.fengyaoid, FengYaoConsts.ShowType_Accepted);
-- end
-- 封妖活动可领奖
function FengYaoController:OnFinishFengYao(msg)
	-- print('=======封妖活动可领奖')
	-- trace(msg)
	
	--加个判断 判断当前封妖菜单是否可见，如果不可见，那在打开的时候显示封印特效
	if UIFengYao then
		if not UIFengYao.bShowState then
			UIFengYao.isopenfengyin = true;
		end
	end
	
	FengYaoModel:SetFengYaoFinishState(msg.fengyaoid, FengYaoConsts.ShowType_NoAward);
	
	--RemindController:AddRemind(RemindConsts.Type_FengYao,1);
	
	UIFengyaoReward:Show()
	--关闭邀请提示框
	UIFengYaoConfirmView:Hide();
end
-- 返回领取封妖奖励结果
function FengYaoController:OnGetFengYaoRewardResult(msg)
	-- print('=======返回领取封妖奖励结果',msg.result)
	-- trace(msg)
	
	if msg.result == 0 then
		FengYaoModel:SetFengYaoScoreState(msg.fengyaoid, msg.curScore, FengYaoConsts.ShowType_Awarded)
		--RemindController:AddRemind(RemindConsts.Type_FengYao,0);
		-- FengYaoModel.curKillMonserNum = 0;
		QuestGuideManager:DoTrunkBreak();
	end
end
-- 返回放弃封妖结果
-- function FengYaoController:OnGiveupFengYaoResult(msg)
	-- print('=======返回放弃封妖结果')
	-- trace(msg)
	
	-- if msg.result == 0 then
		-- FengYaoModel:SetFengYaoState(msg.fengyaoid, FengYaoConsts.ShowType_NoAccept);
		
		--关闭邀请提示框
		-- UIFengYaoConfirmView:Hide();
	-- end
-- end
--自动刷新封妖列表
function FengYaoController:OnRefreshhFengYaoList(msg)
	-- print('=====================自动刷新封妖列表')
	-- trace(msg)
	
	FengYaoModel:SetFengYaoGroup(msg.fengyaoId, msg.fengyaoGroup, FengYaoConsts.ShowType_NoAccept)
end
-- 返回获取封妖宝箱结果
function FengYaoController:OnGetFengYaoBoxResult(msg)
	-- print('返回获取封妖宝箱结果')
	-- trace(msg)
	
	if msg.result == 0 then
		FengYaoModel:Addbox(msg.boxId);
	elseif msg.result == 3 then
		FloatManager:AddNormal( StrConfig["fengyao41"]);
	end
end
-- 返回状态刷新结果
function FengYaoController:OnFengYaoRefreshStateResult(msg)
	-- print('返回状态刷新结果')
	-- trace(msg)
end
-- 返回当前杀怪数量
function FengYaoController:OnZhanYaoMosterCount(msg)
	FengYaoModel:SetCurKillMonserNum(msg.num)
	self:sendNotification(NotifyConsts.FengYaoKillMonsterNum);
	-- WriteLog(LogType.Normal,true,'------------------返回当前杀怪数量',msg.num)
	-- trace(msg)
end
-- 返回当前剩余秒数
function FengYaoController:OnZhanYaoTimeLeft(msg)
	FengYaoModel.curHasTime = msg.seconds
	FengYaoModel.getAServerTime = GetServerTime();
	self:sendNotification(NotifyConsts.FengYaoTimeLeft);
	-- WriteLog(LogType.Normal,true,'-----------------当前剩余秒数',msg.seconds)
	-- trace(msg)
	if FengYaoModel.curHasTime ==0 then
		local state = FengYaoModel.fengyaoinfo.curState;
		if state == FengYaoConsts.ShowType_Awarded or state == FengYaoConsts.ShowType_NoAccept then
			 --判断银两够不够
			if FengYaoUtil:IsHaveGoldRefresh() == false then
				return;
			end
			UIFengyaoGetTask:Show()
		end
	else
		if UIFengyaoGetTask:IsShow() then
			UIFengyaoGetTask:Hide()
		end
		self:StartTimer()
	end
end

function FengYaoController:StartLastTimer()
	if not self.lastTimerKey then
		self.lastTimerKey = TimerManager:RegisterTimer( self.DecreaseTimeLast, 1000, 0 );
	end
end

--倒计时自动
function FengYaoController.DecreaseTimeLast( count )
	--距离下次刷新的时间
	local istoday, shijian, isupdate = FengYaoUtil:GetTimeNextRefresh();
	--如果到点了并且当前状态是已领完奖励  客户端模拟任务列表显示已刷新
	if isupdate == true and FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
		if FengYaoModel.fengyaoinfo.finishCount < FengYaoConsts.FengYaoMaxCount then
			if not UIFengYao:IsShow() then
				FengYaoModel:SetFengYaoState(FengYaoModel.fengyaoinfo.fengyaoId, FengYaoConsts.ShowType_NoAccept);
			end
		end
	end
	
	--零点
	local curtime = GetDayTime();
	local curhour,curmin,cursec = CTimeFormat:sec2format(curtime);
	if curhour == 0 and curmin == 0 and cursec == 0 then
		if not UIFengYao:IsShow() and FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
			FengYaoModel:SetFengYaoState(FengYaoModel.fengyaoinfo.fengyaoId, FengYaoConsts.ShowType_Awarded);
		end
	end
	
	--每分钟一次
	if cursec == 0 and istoday == true then
		--当前已领取奖励并且未达到上限
		if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded and FengYaoModel.fengyaoinfo.finishCount < FengYaoConsts.FengYaoMaxCount then
			FengYaoModel:SetQuestDaoJiShiState();
		end
	end
end
local time;
local timerKey;
function FengYaoController:StartTimer()
	time =FengYaoModel.curHasTime - (GetServerTime()-FengYaoModel.getAServerTime);
	local func = function() self:OnTimer(); end
	if not timerKey then
		timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	end
end

function FengYaoController:OnTimer()
	time = FengYaoModel.curHasTime - (GetServerTime()-FengYaoModel.getAServerTime);
	FengYaoModel:SetQuestDaoJiShiState();
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
		return;
	end
		--当前已领取奖励并且未达到上限
	-- if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
	-- end
end

function FengYaoController:OnTimeUp()
	FengYaoModel.curHasTime=0
	if not UIFengYao:IsShow() and FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_Awarded then
		-- FengYaoModel:SetFengYaoState(FengYaoModel.fengyaoinfo.fengyaoId, FengYaoConsts.ShowType_Awarded);
	end
end

function FengYaoController:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
end