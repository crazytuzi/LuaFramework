--[[
	主宰之路控制器
	2015年5月27日, PM 03:53:26
	wangyanwei
]]

_G.DominateRouteController = setmetatable({},{__index=IController})

DominateRouteController.name = 'DominateRouteController';

function DominateRouteController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_DominateRouteData, self, self.DominateRouteData )-- 服务端通知: 返回UI信息
	MsgManager:RegisterCallBack( MsgType.SC_DominateRouteUpDate, self, self.DominateRouteUpDate )-- 服务端通知: 刷新
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteChallenge, self, self.BackDominateRouteChallenge )-- 服务端通知: 返回挑战
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteQuit, self, self.BackDominateRouteQuit )-- 服务端通知: 返回退出
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteInfo, self, self.BackDominateRouteInfo )-- 服务端通知: 返回追踪信息
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteWipe, self, self.BackDominateRouteWipe )-- 服务端通知: 返回扫荡
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteVigor, self, self.BackDominateRouteVigor )-- 服务端通知: 返回购买精力
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteBoxReward, self, self.BackDominateRouteBoxReward )-- 服务端通知: 返回领取宝箱奖励
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteMopupEnd, self, self.BackDominateRouteMopupEnd )-- 服务端通知: 返回扫荡结束
	MsgManager:RegisterCallBack( MsgType.SC_BackDominateRouteEnd, self, self.BackDominateRouteEnd )-- 服务端通知: 返回通关结果
	
	
	MsgManager:RegisterCallBack( MsgType.SC_ZhuZaiRoadFirstChallenge, self, self.BackZhuZaiRoadFirstChallenge )-- 服务端通知: 返回挑战首通结果
	
	MsgManager:RegisterCallBack(MsgType.SC_BackJingLiBuyNum,self,self.OnBackJingLiBuyNum);  --服务器返回：精力购买次数
end

--C 
--请求UI信息
function DominateRouteController:SendDominateRoute()
	local msg = ReqDominateRouteMsg:new();
	MsgManager:Send(msg);
end

--请求挑战
function DominateRouteController:SendDominateRouteChallenge(id)
	local msg = ReqDominateRouteChallengeMsg:new();
	msg.id = id;

	local fun = function() 
		MsgManager:Send(msg);
	end;
	if TeamUtils:RegisterNotice(UIDominateRoute,fun) then 
		return
	end;
	MsgManager:Send(msg);
end

--请求退出
function DominateRouteController:SendDominateRouteQuit()
	local msg = ReqDominateRouteQuitMsg:new();
	MsgManager:Send(msg);
end

--请求扫荡
function DominateRouteController:SendDominateRouteWipe(id,num)
	local msg = ReqDominateRouteWipeMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end

--请求一键扫荡
function DominateRouteController:SendDominateQuicklySaodang( )
	local msg = ReqDominateRouteImmediatelyMsg:new();
	MsgManager:Send(msg);
end

--请求购买精力
function DominateRouteController:SendDominateRouteVigor()
	local msg = ReqDominateRouteVigorMsg:new();
	MsgManager:Send(msg);
end

--领取宝箱奖励
function DominateRouteController:SendDominateRouteBoxReward(id)
	local msg = ReqDominateRouteBoxRewardMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end

--请求一键扫荡
function DominateRouteController:SendDominateRouteImmediately()
	local msg = ReqDominateRouteImmediatelyMsg:new();
	MsgManager:Send(msg);
end

--请求领取首通宝箱奖励
function DominateRouteController:ReqDominateRouteBoxReward(id)
	local msg = ReqDominateRouteBoxRewardMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end

--S

-- 服务端通知: 返回UI信息
DominateRouteController.DominateRouteIsData = false;
function DominateRouteController:DominateRouteData(msg)
	self.DominateRouteIsData = true;
	local enterNum = msg.enterNum;
	-- local veilList = msg.veillist;
	local stageList = msg.stagelist;
	DominateRouteModel:OnSetDominateRouteData(stageList,enterNum);
	Notifier:sendNotification(NotifyConsts.DominateRouteNewOpen);	--侦听是否有新开启未通关的副本
	UIMainYunYingFunc:DrawLayout()
end

-- 服务端通知: 刷新
function DominateRouteController:DominateRouteUpDate(msg)
	print("-- 服务端通知: 刷新")
	-- trace(msg)
	-- debug.debug();
	DominateRouteModel:OnDominateUpData(msg.num,msg.state,msg.time,msg.id)
	Notifier:sendNotification(NotifyConsts.DominateRouteUpData);
end

-- 服务端通知: 返回挑战
function DominateRouteController:BackDominateRouteChallenge(msg)
	print("-- 服务端通知: 返回挑战")
	-- trace(msg)
	
	if msg.result == 1 then
		UIDominateRouteInfo:Show();
		UIDominateRoute:Hide();
		UIDominateRouteQuickMopup:Hide();
		MainMenuController:HideRight();
		MainMenuController:HideRightTop();
		UIDominateRouteInfo:Open(msg.id);
		-- DominateRouteModel:OnCutEnterNum();  --扣除剩余从次数  -1;
		-- UIConfirm:Open("点击确定按钮退出场景", function()
			-- self:SendDominateRouteQuit()
		-- end)
		return
	else
		FloatManager:AddNormal( StrConfig['dominateRoute0212'] );
	end
end

-- 服务端通知: 返回退出
function DominateRouteController:BackDominateRouteQuit(msg)
	print("服务端通知: 返回退出")
	-- trace(msg)
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	UIDominateRouteInfo:Hide();
	if UIDominateResult:IsShow() then
		UIDominateResult:Hide();
	else
		UIDominateResult:CloseOpenTime();
	end
	-- 通关退出后主动打开剧情副本界面
--	if not UIDominateRoute:IsShow() then
--		UIDominateRoute:Show()
--	end
	Notifier:sendNotification(NotifyConsts.DominateRouteNewOpen);	--侦听是否有新开启未通关的副本
end

-- 服务端通知: 返回追踪信息
function DominateRouteController:BackDominateRouteInfo(msg)
	print("服务端通知: 返回追踪信息")
end

-- 服务端通知: 返回扫荡
function DominateRouteController:BackDominateRouteWipe(msg)
	print("服务端通知: 返回扫荡")
	if msg.result == 0 then
		DominateRouteModel:OnHaveDominateRouteMopup(msg.id,msg.num)
		DominateRouteModel:OnCutEnterNum(msg.total_num);
		Notifier:sendNotification(NotifyConsts.DominateRouteMopupUpData);
		return 
	end
	print('请求扫荡失败')
end

--服务端通知: 返回一键扫荡结束 
function DominateRouteController:BackDominateRouteMopupEnd(msg)
	if msg.result ~= 0 then  --扫荡失败
		print('请求扫荡失败.........')
		return
	end
	-- print("返回一键扫荡结果.........")
	-- trace(msg.stagelist)
	DominateRouteModel:OnHaveDominateQuicklySaodang(msg.stagelist,msg.total_num)
	Notifier:sendNotification(NotifyConsts.DominateQuicklySaodangBackUpData);
end

-- 服务端通知: 返回购买精力
function DominateRouteController:BackDominateRouteVigor(msg)
	-- print("服务端通知: 返回购买精力")
	if msg.result == 0 then
		FloatManager:AddNormal( StrConfig['dominateRoute0202'] );
	elseif	msg.result == 1 then
		FloatManager:AddNormal( StrConfig['dominateRoute0203'] );
	elseif msg.result == 2 then
		FloatManager:AddNormal( StrConfig['dominateRoute0204'] );
	elseif msg.result == 3 then
		FloatManager:AddNormal( StrConfig['dominateRoute0205'] );
	else
		FloatManager:AddNormal( StrConfig['dominateRoute0206'] );
	end
end

-- 服务端通知: 返回领取宝箱奖励
function DominateRouteController:BackDominateRouteBoxReward(msg)
	-- print("服务端通知: 返回领取宝箱奖励")
	trace(msg)
	if msg.result == 0 then
		DominateRouteModel:RodBoxRewardUpData(msg.id,msg.state)
	end
	Notifier:sendNotification(NotifyConsts.DominateRouteBoxUpData);
end



--返回通关结果
function DominateRouteController:BackDominateRouteEnd(msg)
	UIDominateRouteInfo:Hide();
	UIDominateResult:Open(msg.result,msg.level,msg.time);
	if msg.result == 1 then
		DominateRouteModel:OnUpDataLevel(UIDominateRouteInfo:GetID(),msg.level);
		DominateRouteModel:addDominateRouteData(UIDominateRouteInfo:GetID());
		
	end
end

--返回首次通关结果
function DominateRouteController:BackZhuZaiRoadFirstChallenge(msg)
	UIDominateRouteGetEuip:Open(msg.id);
end

--精力购买次数
function DominateRouteController:OnBackJingLiBuyNum(msg)
	local num = msg.num;
	DominateRouteModel:OnBackJingliBuyNum(num);
end