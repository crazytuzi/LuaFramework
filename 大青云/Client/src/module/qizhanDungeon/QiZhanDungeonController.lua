--[[
骑战副本 Controller
2015年11月13日23:57:59
houxudong
]]
--------------------------------------------------------------

_G.QiZhanDungeonController = setmetatable( {}, {__index = IController} )
QiZhanDungeonController.name = "QiZhanDungeonController";
QiZhanDungeonController.playAnimal = true;  --是否播放动画
QiZhanDungeonController.currentLayer = 0;
QiZhanDungeonController.sceneChangeCallBack = nil
function QiZhanDungeonController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackQiZhanDungeonDate,self,self.OnBackQiZhanDungeonDate);			--返回骑战副本date
	MsgManager:RegisterCallBack(MsgType.SC_BackQiZhanDungeonEnter,self,self.OnBackQiZhanDungeonEnter);			--返回骑战副本进入结果
	MsgManager:RegisterCallBack(MsgType.SC_BackQiZhanDungeonQuit,self,self.OnBackQiZhanDungeonQuit);			--返回骑战副本退出结果
	MsgManager:RegisterCallBack(MsgType.SC_BackQiZhanDungeonResult,self,self.OnBackQiZhanDungeonResult);		--返回骑战副本通关结果
	
	MsgManager:RegisterCallBack(MsgType.SC_BackQiZhanDungeonInfo,self,self.OnBackQiZhanDungeonInfo);			--返回骑战副本挑战过程
	
	
	MsgManager:RegisterCallBack(MsgType.SC_BackQiZhanDungeonTeamConfirm,self,self.OnBackQiZhanDungeonTeamConfirm);--返回打开骑战副本组队进入确认框
	MsgManager:RegisterCallBack(MsgType.SC_BackQiZhanDungeonTeamConfirmData,self,self.OnBackQiZhanDungeonTeamConfirmData);--返回骑战副本组队进入确认框信息
	MsgManager:RegisterCallBack(MsgType.SC_QiZhanDungeonContinue,self,self.OnBackQiZhanDungeonContinueResult);  --继续挑战返回
	MsgManager:RegisterCallBack(MsgType.SC_TeamChanllegeRewardUpdate,self,self.OnBackChanllegeRewardUpdate);  --组队挑战累计奖励列表
end

function QiZhanDungeonController:InitWall()
	QiZhanWallView:Show(QiZhanWallView.TYPE_WALL);
end

-- 切换场景完成后的回调
function QiZhanDungeonController:OnChangeSceneMap() 
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	if mapCfg.type == 21 then
		AutoBattleController:SetAutoHang();  --自动挂机
	end
end

function QiZhanDungeonController:OnBackQiZhanDungeonDate(msg)
	--print("---------------返回爬塔副本所需数据---------------")
	--trace(msg)
	local dungeonData = {};
	dungeonData.enterNum 		= msg.enterNum;				--进入进入次数
	dungeonData.nowBestLayer 	= msg.nowBestLayer;			--今日挑战的最好成绩
	dungeonData.bestLayer 		= msg.bestLayer;			--自己历史最好成绩
	dungeonData.bestTeamLayer 	= msg.bestTeamLayer;		--全服历史最好成绩
	dungeonData.bestTeamList 	= msg.bestTeamList;			--最强通关队伍列表
	dungeonData.rankList 		= msg.rankList;				--排行榜列表
	
	QiZhanDungeonModel:QiZhanDungeonUpDate(dungeonData);
	
	Notifier:sendNotification(NotifyConsts.QiZhanDungeonUpDate);
end

function QiZhanDungeonController:OnBackChanllegeRewardUpdate( msg )
	QiZhanDungeonModel:QiZhanDungeonUpDateReward(msg.rewardList);
	Notifier:sendNotification(NotifyConsts.QiZhanDungeonRewardUpDate);
end

--返回骑战副本进入结果
QiZhanDungeonController.qizhandungeonInState = false;
QiZhanDungeonController.nextJiguanId = 0;
function QiZhanDungeonController:OnBackQiZhanDungeonEnter(msg)
	local result = msg.result ;		--进入结果 0成功
	local layer  = msg.layer ;		--进入层
	local state  = msg.state ;		--盖层挑战状态 0未挑战 1已挑战
	self.currentLayer = layer;
	-- trace(msg)
	if result == 0 then
		UIDungeonMain:Hide()
		UIDungeonNpcChat:Hide();
		UIQiZhanDungeonTip:Hide();
		self.qizhandungeonInState = true;
		MainMenuController:HideRight();
		MainMenuController:HideRightTop();			--//隐藏功能界面及任务界面
		UIQiZhanDungeon:Hide();						--//关闭主UI
		UIQiZhanDungeonInfo:Open(layer,state);			--//打开信息界面
		UIQiZhanDungeonResult:Hide();			--//关闭结局界面
		QiZhanDungeonDieTip:Hide();				--//关闭死亡提示
		--刚进入的时候处理机关
		--[[
		local cfg = t_ridedungeon[layer]
		if not cfg then return; end
		local jiGuanId = cfg.jiguan;
		self.nextJiguanId = cfg.jiguan_c;
		if self.playAnimal then
			CPlayerMap:PlayGimmickById(jiGuanId,false)
			end
		]]
		if not self.dealyTime then
			self:OnPlayTimeDown(1000)
		end	
		local isNextBoss = t_ridedungeon[self.currentLayer].boss;
		if isNextBoss == 0 then
			QiZhanWallView:ToNext(QiZhanWallView.TYPE_WALL);
		else
			QiZhanWallView:ToNext(QiZhanWallView.TYPE_BOSS_WALL);
		end
		if state == 1 then
			UIQiZhanDungeonTip:Open(1);
		elseif state == 0 then
			local cfg = t_ridedungeon[layer];
			if cfg.duntalk and cfg.duntalk ~= 0 then
				UIDungeonNpcChat:Open(cfg.duntalk);
			end
		end

		--显示墙
		self:InitWall();
		return;
	end
	if result == 1 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6001'] );
	elseif result == 2 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6002'] );
	elseif result == 3 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6003'] );
	elseif result == 4 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6004'] );
	elseif result == 5 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6005'] );
	elseif result == 6 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6006'] );
	elseif result == 7 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6007'] );
	elseif result == 8 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6008'] );
	end
end

--adder:houxudong date:2016/7/15
--进入封妖试炼副本播放倒计时
--@num = 10 在播放完机关特效5秒后，开始刷新怪物倒计时，时间为10秒
function QiZhanDungeonController:OnPlayTimeDown(dealyNum)
	local num = 0
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			self.playAnimal = true;
			--开启info界面的的倒计时
			UIQiZhanDungeonInfo:OnTimeHandler(false)
		end
		if num == 10 then
			UITimeTopSec:Open(1,num);  --timeTopSec倒计时10s
			--取消info界面的的倒计时
			UIQiZhanDungeonInfo:ONCloseTimer()
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

--返回退出骑战副本
function QiZhanDungeonController:OnBackQiZhanDungeonQuit(msg)
	local result = msg.result ;		--退出结果 0成功
	if result == 0 then
		UIDungeonNpcChat:Hide();
		UIQiZhanDungeonTip:Hide();
		self.qizhandungeonInState = false;
		MainMenuController:UnhideRight();
		MainMenuController:UnhideRightTop();
		
		UIQiZhanDungeonResult:Hide();			--//关闭结局界面
		UIQiZhanDungeonInfo:Hide();
		
		QiZhanDungeonDieTip:Hide();				--//关闭死亡提示

		QiZhanWallView:Destroy();
		
		self:SendQiZhanDungeonData();   	--退出的时候再次请求一下骑战副本数据
	end
end

function QiZhanDungeonController:OpenStartTime( )
	UIQiZhanDungeonInfo:RestartTimer()
end

--返回骑战副本通关结果
function QiZhanDungeonController:OnBackQiZhanDungeonResult(msg)
	local layer  = msg.layer;		--通关层数
	local result  = msg.result;		--通关结果
	UIQiZhanDungeonTip:Hide();
	UIDungeonNpcChat:Hide();
	if layer >= QiZhanDungeonUtil:GetMaxDungeonLayer() then
		UIQiZhanDungeonInfo:Hide();				--//追踪关闭
	else
		UIQiZhanDungeonInfo:ResultOpen(result);		--//追踪修改
	end
	
	UIQiZhanDungeonResult:Open(result,layer);	--//打开结局
	
	QiZhanDungeonDieTip:Hide();				--//关闭死亡提示
end

--返回骑战副本挑战过程
function QiZhanDungeonController:OnBackQiZhanDungeonInfo(msg)
	local killList = msg.killList;	--//击杀列表
	QiZhanDungeonModel:SetDungeonLayerMonster(killList);
	Notifier:sendNotification(NotifyConsts.QiZhanDungeonInfoUpDate);
end

--返回打开骑战副本组队进入确认框
function QiZhanDungeonController:OnBackQiZhanDungeonTeamConfirm(msg)
	UIQiZhanDungeonTeamConfirm:Open();
end

----返回骑战副本组队进入确认框信息
function QiZhanDungeonController:OnBackQiZhanDungeonTeamConfirmData(msg)
	local palyerGuid = msg.palyerGuid;
	local state 	 = msg.state;
end

function QiZhanDungeonController:GetInQiZhanDungeonState()
	return self.qizhandungeonInState
end

--////////////////////////C TO S\\\\\\\\\\\\\\\\\\\\\\--
-- 刚进入游戏时请求副本数据
function QiZhanDungeonController:OnEnterGame()
	local msg = ReqQiZhanDungeonDateMsg:new();
	MsgManager:Send(msg);
end

--请求爬塔副本data
function QiZhanDungeonController:SendQiZhanDungeonData()
	local msg = ReqQiZhanDungeonDateMsg:new();
	MsgManager:Send(msg);
end

--请求进入骑战副本
function QiZhanDungeonController:SendEnterQiZhanDungeon()
	local msg = ReqQiZhanDungeonEnterMsg:new();
	MsgManager:Send(msg);
end

--骑战副本继续挑战
function QiZhanDungeonController:SendQiZhanDungeonContinue()
	local msg = ReqQiZhanDungeonContinueMsg:new();
	MsgManager:Send(msg)
end

--服务器返回骑战副本继续挑战结果
local inNum =0;
function QiZhanDungeonController:OnBackQiZhanDungeonContinueResult(msg)
	local result = msg.result;
	if result == 0 then
		-- 播放场景特效
		--[[
		if self.nextJiguanId then
			local result = CPlayerMap:PlayGimmickById(self.nextJiguanId,false)
			self.playAnimal = false;
		end
		]]
		-- 场景动画转到所需要的时间5秒
		local func = function( )
			if self.dealyTime then
				TimerManager:UnRegisterTimer(self.dealyTime)
				self.dealyTime = nil;
			end
			self:OnPlayTimeDown(1000)
		end
		if self.dealyTime then
			TimerManager:UnRegisterTimer(self.dealyTime)
			self.dealyTime = nil;
		end
		self.dealyTime = TimerManager:RegisterTimer(func,5000)
	elseif result == -1 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon6001'] );  --非队长
	end
end

--请求退出骑战副本
function QiZhanDungeonController:SendQuitQiZhanDungeon()
	local msg = ReqQiZhanDungeonQuitMsg:new();
	
	MsgManager:Send(msg);
end

--骑战副本发送准备状态
function QiZhanDungeonController:SendQiZhanDungeonTeamState(state)
	local msg = ReqQiZhanDungeonTeamStateMsg:new();
	msg.state = state;
	
	MsgManager:Send(msg);
end