--[[
	2015年1月29日, AM 11:34:28
	时间副本
	wangyanwei 
]]

_G.TimeDungeonController = setmetatable({},{__index=IController});
TimeDungeonController.name = 'TimeDungeonController';

function TimeDungeonController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackDungeonNum,self,self.OnBackEnterNum);  --返回挑战次数
	MsgManager:RegisterCallBack(MsgType.SC_BackEnterTimeDungeon,self,self.OnBackEnterTimeDungeon);  --返回进入时间副本
	MsgManager:RegisterCallBack(MsgType.SC_BackQuitTimeDungeon,self,self.OnBackQuitTimeDungeon);  --返回退出时间副本
	MsgManager:RegisterCallBack(MsgType.SC_BackTimeDungeonReward,self,self.OnBackTimeDungeonReward);  --返回时间副本信息
	MsgManager:RegisterCallBack(MsgType.SC_BackTimeDungeonInfo,self,self.OnBackTimeDungeonInfo);  --返回副本通关结果信息
	MsgManager:RegisterCallBack(MsgType.SC_BackTimeDungeonNum,self,self.OnBackTimeDungeonNum);  --返回怪物波数
	MsgManager:RegisterCallBack(MsgType.SC_BackDungeonTimeStart,self,self.OnBackTimeNum);  --返回倒计时
	
	MsgManager:RegisterCallBack(MsgType.WC_TimeDungeonRoomList,self,self.OnTimeDungeonRoomList); --服务器返回:所有房间信息
	MsgManager:RegisterCallBack(MsgType.WC_TimeDungeonRoomInfo,self,self.OnTimeDungeonRoomInfo); --服务器返回:自己房间信息
	MsgManager:RegisterCallBack(MsgType.WC_RoomPrepare,self,self.OnTimeDungeonRoomPrepare); --服务器返回:准备状态
	MsgManager:RegisterCallBack(MsgType.WC_ExitRoom,self,self.OnQuitTimeDungeonRoom); --服务器返回:退出房间
	MsgManager:RegisterCallBack(MsgType.WC_TimeDungeonStartTip,self,self.OnTimeDungeonStartTip); --服务器返回:定时副本开始提示
end

--刚进入游戏的时候请求一下副本的进入次数 
function TimeDungeonController:OnEnterGame( )
	local msg = ReqDungeonNumMsg:new();
	MsgManager:Send(msg);
end
--发送请求剩余次数
function TimeDungeonController:OnSendEnterNum()
	local msg = ReqDungeonNumMsg:new();
	MsgManager:Send(msg);
end

--发送进入副本
function TimeDungeonController:OnEnterTimeDungeon(state)
	local msg = ReqEnterTimeDungeonMsg:new();
	msg.state = state;
	MsgManager:Send(msg);
end

--发送退出副本
function TimeDungeonController:QuitTimeDungeon()
	local msg = ReqQuitTimeDungeonMsg:new();
	MsgManager:Send(msg);
end

--////////////////组队信息请求

--客户端请求：进入他人队伍
function TimeDungeonController:OnCenterTimeDungeonTeam(teamID,password)
	local msg = ReqCenterTimeDungeonTeamMsg:new();
	msg.password = password;
	msg.teamID = teamID;
	-- trace(msg);
	MsgManager:Send(msg);
end

--客户端请求：灵光封魔房间信息&组队爬塔房间信息&牧野之战房间信息
function TimeDungeonController:TimeDungeonRoom(dungeonType)
	local msg = ReqTimeDungeonRoomMsg:new();
	msg.dungeonType = dungeonType;
	MsgManager:Send(msg);
end

--客户端请求组队副本单人进入：灵光封魔房间信息&组队爬塔房间信息&牧野之战房间信息
function TimeDungeonController:AllZuiduiDungeonSignalEnter(dungeonType,state)
	local func = function() 
		local msg = ReqEnterCommDungeonMsg:new();
		msg.type = dungeonType;
		if not state then state = 1 end
		msg.state = state           --默认为1，截止2016/12/5号之前保持，这个字段的无效性
		-- FloatManager:AddNormal("测试阶段，不对外开放!")
		MsgManager:Send(msg);
	end
	if TeamUtils:RegisterNotice( UIWaterDungeon,func ) then
		return
	end
	func()
end


--客户端请求：灵光封魔&爬塔副本&牧野之战快速房间
function TimeDungeonController:QuickTimeDungeonRoom(dungeonType)
	local msg = ReqQuickTimeDungeonRoomMsg:new();
	msg.dungeonType = dungeonType
	MsgManager:Send(msg);
end

--客户端请求：灵光封魔&组队爬塔&牧野之战 请求创建
function TimeDungeonController:SendTimeDungeonRoomBuild(dungeonType,dungeonIndex,password,attLimit)
	local msg = ReqTimeDungeonRoomBuildMsg:new();
	msg.dungeonType = dungeonType;
	msg.dungeonIndex = dungeonIndex;
	msg.password = password;
	msg.attLimit = attLimit;
	-- trace(msg)
	MsgManager:Send(msg);
end

--客户端请求：切换准备状态
function TimeDungeonController:TimeDungeonRoomPrepare(dungeonType,prepare)
	local msg = ReqTimeDungeonPrepareMsg:new();
	msg.dungeonType = dungeonType;
	msg.prepare = prepare;
	MsgManager:Send(msg);
end

--客户端请求：退出房间
function TimeDungeonController:QuitTimeDungeonRoom(dungeonType)
	local msg = ReqQuitTimeDungeonRoomMsg:new();
	msg.dungeonType = dungeonType;
	MsgManager:Send(msg);
end

--更换副本难度
function TimeDungeonController:OnChangeRoomDiff(diff)
	local msg = ReqChangeRoomDiffMsg:new();
	msg.dungeonIndex = diff;
	MsgManager:Send(msg);
end

--灵光魔冢-是否人满自动开始
function TimeDungeonController:OnIsmaxPlayerAutuStart()
	local msg = ReqChangeRoomAutoStartMsg:new()
	local data = TimeDungeonModel:GetSelfTeamData()
	if data.autoStart == 0 then
		msg.autoStart = 1;
	else
		msg.autoStart = 0;
	end
	MsgManager:Send(msg);
end

-- 组队爬塔副本-是否人满自动开始
function TimeDungeonController:OnIsmaxPlayerAutuStartJustForPata()
	local msg = ReqChangeRoomAutoStartMsg:new()
	local data = TimeDungeonModel:GetPataSelfTeamData()
	if data.autoStart == 0 then
		msg.autoStart = 1;
	else
		msg.autoStart = 0;
	end
	MsgManager:Send(msg);
end

-- 牧野之战副本-是否人满自动开始
function TimeDungeonController:OnIsmaxPlayerAutuStartJustForMakinoBattle()
	local msg = ReqChangeRoomAutoStartMsg:new()
	local data = TimeDungeonModel:GetMakinobattleTeamData()  --自己队伍信息
	if data.autoStart == 0 then   --状态的一个互相转换 1-0，or 0-1
		msg.autoStart = 1;
	else
		msg.autoStart = 0;
	end
	MsgManager:Send(msg);
end

--灵光魔冢请求房间开始
function TimeDungeonController:OnSendEnterRoomStart()
	local msg = ReqRoomStartMsg:new();
	MsgManager:Send(msg);
end

--爬塔副本请求房间开始
function TimeDungeonController:OnSendEnterPataRoomStart()
	local msg = ReqRoomStartMsg:new();
	MsgManager:Send(msg);
end

--牧野之战副本请求房间开始
function TimeDungeonController:OnSendEnterMakinoRoomStart()
	local msg = ReqRoomStartMsg:new();
	MsgManager:Send(msg);
end


--返回提示操作
--state  0 确认  1 拒绝
function TimeDungeonController:OnSendTipData(state)
	local state = state;
	local msg = ReqTimeDungeonPreparedMsg:new();
	msg.state = state;
	MsgManager:Send(msg);
end
---------------------================================-------------------------

--返回挑战次数
function TimeDungeonController:OnBackEnterNum(msg)
	TimeDungeonModel:OnSetEnterNum(msg.num)
end

--返回进入时间副本
function TimeDungeonController:OnBackEnterTimeDungeon(msg)
	TimeDungeonModel:OnBackEnterDungeon(msg);
	
	if UITimeDungeonStartTip:IsShow() then
		UITimeDungeonStartTip:Hide();
	end
end

--返回退出时间副本
function TimeDungeonController:OnBackQuitTimeDungeon(msg)
	TimeDungeonModel:OnBackQuitDungeon(msg.result);
	UIDungeonNpcChat:Hide();
	UITimerDungeonInfo:Hide();
	TimeDungeonController:OnSendEnterNum()
	if UITimeTopSec:IsShow() then
		UITimeTopSec:Hide();
	end
end

--返回时间副本信息
function TimeDungeonController:OnBackTimeDungeonReward(msg)
	TimeDungeonModel:OnBackDungeonInfo(msg);
end

--返回副本通关结果信息
function TimeDungeonController:OnBackTimeDungeonInfo(msg)
	UITimerDungeonInfo:Hide();
	self:OnPlayTimeDown(1000,msg)
end

-- 延迟5秒打开结算界面
function TimeDungeonController:OnPlayTimeDown(dealyTime,msg)
	local num = 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			TimeDungeonModel:OnBackDungeonResult(msg);
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

--返回波数
function TimeDungeonController:OnBackTimeDungeonNum(msg)
	TimeDungeonModel:OnBackNum(msg);
end

--返回倒计时
function TimeDungeonController:OnBackTimeNum(msg)
	local num = msg.timeNum;
	TimeDungeonModel:OnBackTimeNum(num);
end

----------------------------------------------------------------------
--服务器返回:所有房间信息(同时适用于三个组队副本)
function TimeDungeonController:OnTimeDungeonRoomList(msg)
	local dungeonType = msg.dungeonType   --副本类型
	local teamList = msg.list;
	-- print("服务器返回:所有房间信息",msg.dungeonType)
	-- trace(msg);
	TimeDungeonModel:SetAllTeamData(teamList,dungeonType);
	Notifier:sendNotification(NotifyConsts.TimeDungeonTeamRooomData,{dungeonType = msg.dungeonType});
	if UITimeDungeonStartTip:IsShow() then
		UITimeDungeonStartTip:Hide();
	end
end

--服务器返回:自己房间信息
function TimeDungeonController:OnTimeDungeonRoomInfo(msg)
	-- trace(msg)
	-- WriteLog(LogType.Normal,true,'-------------服务器返回:自己房间信息,副本难度,副本类型',msg.dungeonIndex,msg.dungeonType)
	local dungeonType,dungeonIndex,lock,lockAttNum,autoStart =msg.dungeonType,msg.dungeonIndex,msg.lock,msg.lockAttNum,msg.autoStart;
	TimeDungeonModel:SetMyTeamData(dungeonType,dungeonIndex,lock,lockAttNum,autoStart);
	Notifier:sendNotification(NotifyConsts.TimeDungeonTeamMyRoom,{dungeonType = msg.dungeonType});
end

--服务器返回:准备状态
function TimeDungeonController:OnTimeDungeonRoomPrepare(msg)
	Notifier:sendNotification(NotifyConsts.TimeDungeonRoomPrepare);
end

--服务器返回：退出房间
function TimeDungeonController:OnQuitTimeDungeonRoom(msg)
	-- TimeDungeonModel:ClearMyTeamData();
	TimeDungeonModel:ClearPataTeamList();
	Notifier:sendNotification(NotifyConsts.QuitTimeDungeonRoom);
	if UITimeDungeonStartTip:IsShow() then
		UITimeDungeonStartTip:Hide();
	end
end

--定时副本开始提示
function TimeDungeonController:OnTimeDungeonStartTip(msg)
	local ndID = msg.id;		--难度ID
	UITimeDungeonStartTip:OnOpen(ndID);
end

----------------------------------------------------------------------

--进入地图
function TimeDungeonController:OnChangeSceneMap()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	-- if mapCfg.type == 7 then
	-- 	UIAutoBattleTip:Open(function()TimeDungeonController:onAutoFunc()end,true);   --屏蔽自动挂机
	-- end
end

-- 跑到一个指定位置开始挂机
function TimeDungeonController:onAutoFunc()
	local inTeam = TeamModel:IsInTeam();
	if not inTeam then
		UITimerDungeonInfo:OnClickMonster();
		return
	end
	local myTeamData = TimeDungeonModel:GetSelfTeamPlayerData();
	for _index , player in ipairs(myTeamData) do
		local roleIdData = split(player.roleID,'_');
		player.intGuid = toint(roleIdData[1]) + toint(roleIdData[2]);
	end
	table.sort(myTeamData,function (A,B)
		return A.intGuid > B.intGuid
	end)
	local myPos;
	for _index , player in ipairs(myTeamData) do
		if player.roleID == MainPlayerController:GetRoleID() then
			local posCfg = split(t_position[9201].pos,'|');
			myPos = posCfg[_index];
			break
		end
	end
	if not myPos then return end
	local mapid = CPlayerMap:GetCurMapID();
	local point = split(myPos,",");
	local completeFuc = function()
		AutoBattleController:SetAutoHang();
	end
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(point[2],point[3],0),completeFuc);
end