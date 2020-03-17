--[[
	2016年11月14日, PM 18:17:25
	houxudong
]]

_G.GodDynastyDungeonController = setmetatable({},{__index=IController})

GodDynastyDungeonController.name = 'GodDynastyDungeonController';
GodDynastyDungeonController.sceneChangeCallBack = nil

function GodDynastyDungeonController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackZXZ,self,self.OnBackGodDynastyInfo);                     --返回诛仙阵信息
	MsgManager:RegisterCallBack(MsgType.SC_BackZXZRankingListInfo,self,self.OnBackGodDynastyListInfo);  --服务器通知：诛仙阵排行榜信息
	MsgManager:RegisterCallBack(MsgType.SC_BackZXZNowInfo,self,self.OnBackGodDynastyResult);            --服务器通知：进入诛仙阵副本结果
	MsgManager:RegisterCallBack(MsgType.SC_BackZXZResultInfo,self,self.OnBackGodDynastyResultInfo);     --服务器通知：通关结果
	MsgManager:RegisterCallBack(MsgType.SC_BackZXZOut,self,self.OnBackGodDynastyROut);                  --服务器通知：退出诛仙阵副本
end

-- 切换场景完成后的回调
function GodDynastyDungeonController:OnChangeSceneMap()
	-- self.sceneChangeCallBack()
end

-----------------------------以下是客户端请求数据信息---------------------
--------------------------------------------------------------------------
--确认是否在诛仙阵中
GodDynastyDungeonController.IsGodDynasty = false;
function GodDynastyDungeonController:GetIsInGodDynasty()
	return self.IsGodDynasty;
end
--(打开UI)请求诛仙阵信息
function GodDynastyDungeonController:OnGetGodDynastyInfo()
	local msg = ReqGetZXZInfoMsg:new();
	MsgManager:Send(msg);
end

--刚进入游戏时请求诛仙阵信息
function GodDynastyDungeonController:OnEnterGame()
	-- local msg = ReqGetZXZInfoMsg:new();
	-- MsgManager:Send(msg);
end

--请求诛仙阵排行榜信息
function GodDynastyDungeonController:OnGetGodDynastyRankList()
	local msg = ReqGetZXZRankingListMsg:new();
	MsgManager:Send(msg);
end

--请求进入诛仙阵
function GodDynastyDungeonController:OnGetEnterGodDynasty()
	local msg = ReqEnterZXZIntoMsg:new();
	MsgManager:Send(msg);
end

-- 请求退出诛仙阵
GodDynastyDungeonController.lastState = 0;
function GodDynastyDungeonController:OnOutGodDynasty(state)
	local msg = ReqOutZXZMsg:new();
	self.lastState = state;
	msg.state = state;
	MsgManager:Send(msg);
end
-----------------------------以下是服务器返回-----------------------------
--------------------------------------------------------------------------

-- 返回诛仙阵信息
function GodDynastyDungeonController:OnBackGodDynastyInfo(msg)
	local data = {};
	data.maxLayer        = msg.maxLayer;		  --当前挑战最高层
	data.maxHistoryLayer = msg.maxHistoryLayer;   --历史挑战最高层
	data.layer           = msg.layer;			  --返回的是第几层
	data.maxTier         = msg.maxTier;			  --最佳通关人物的名字
	data.minTime         = msg.minTime;			  --最佳通关时间
	data.myTime          = msg.myTime;			  --我的时间
	GodDynastyDungeonModel:UpDataGodDynastyInfo(data);
end

--返回诛仙阵排行榜
function GodDynastyDungeonController:OnBackGodDynastyListInfo(msg)
	local list = msg.list;
	GodDynastyDungeonModel:BackRankData(list);
end

--服务器通知：进入诛仙阵副本结果
function GodDynastyDungeonController:OnBackGodDynastyResult(msg)
	local result = msg.result;
	if result == -1 then
		FloatManager:AddNormal( StrConfig['babel10001'] );
		return
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['babel10002'] );
		return
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['babel10003'] );
		return
	elseif result == -4 then
		FloatManager:AddNormal( StrConfig['babel10004'] );
		return
	elseif result == -5 then
		FloatManager:AddNormal( StrConfig['babel10005'] );
		return
	elseif result == -6 then
		FloatManager:AddNormal( StrConfig['babel10006'] );
		return
	elseif result == -7 then
		FloatManager:AddNormal( StrConfig['babel10007'] );
		return
	elseif result == -8 then
		FloatManager:AddNormal( StrConfig['babel10008'] );
		return
	end
	if result ~= 0 then
		FloatManager:AddNormal( StrConfig['babel10009'] );
		return
	end
	-- self.sceneChangeCallBack = function()
	AutoBattleController:OpenAutoBattle()  --自动挂机
	-- end
	GodDynastyDungeonModel:OnBackLayer(msg);   --相关信息
	-- self:OnWaitMonster(1000)   -- 在这里开启10秒刷怪倒计时
	UIGodDynastyInfo:startDownTime( )
	self.IsGodDynasty = true;  --记录状态
end

-- 每层在刷新怪物之前显示5秒倒计时
function GodDynastyDungeonController:OnWaitMonster(dealyNum)
	local num = 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			UIGodDynastyInfo:startDownTime( )
			--开启info界面的的倒计时
		end
		if num == 5 then
			UITimeTopSec:Open(1,5);  --timeTopSec倒计时10s
			UIGodDynastyInfo:OnCloseTimes( )
			--取消info界面的的倒计时
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,dealyNum)
	func()
end


--5秒延迟弹出结算界面
function GodDynastyDungeonController:OnBackGodDynastyResultInfo(msg)
	-- self:OnPlayTimeDown(1000,msg)
	if self.IsGodDynasty then
		GodDynastyDungeonModel:OnBackLayerResultInfo(msg);
	end
end

-- 暂时不调用这个函数 2016/10/17 17:11:36
--返回通关结果
function GodDynastyDungeonController:OnPlayTimeDown(dealyTime,msg)
	local num = 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			if self.IsGodDynasty then
				GodDynastyDungeonModel:OnBackLayerResultInfo(msg);
				if msg.state == 0 then
					SoundManager:PlaySfx(2020);
				else
					SoundManager:PlaySfx(2019);
				end
			end
		end
		if num == 5 then
			UITimeTopSec:Open(2);  
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,dealyTime)
end

--返回退出诛仙阵
function GodDynastyDungeonController:OnBackGodDynastyROut(msg)
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	GodDynastyDungeonModel:OnOutGodDynastyBack(msg);
	self.IsGodDynasty = false;
end