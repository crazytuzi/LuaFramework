require "Core.Module.Pattern.Proxy"

local battleCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_CONFIG);

ArathiProxy = Proxy:New();
ArathiProxy.readyMapId = 707101;

function ArathiProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiSignupTips, ArathiProxy._ArathiSignupTipsHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiData, ArathiProxy._ArathiDataHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiLastNotify, ArathiProxy._ArathiLastNotifyHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiEnter, ArathiProxy._ArathiEnterHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiExit, ArathiProxy._ArathiExitHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiWarData, ArathiProxy._ArathiWarDataHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiResChage, ArathiProxy._ArathiResChageHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiMineChage, ArathiProxy._ArathiMineChageHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiBuffChage, ArathiProxy._ArathiBuffChageHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiOccupyMine, ArathiProxy._ArathiOccupyMineHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiOccupyBuff, ArathiProxy._ArathiOccupyBuffHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiSignup, ArathiProxy._ArathiSignupHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiWarRank, ArathiProxy._ArathiWarRankHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiOverResult, ArathiProxy._ArathiOverResultHandler, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ArathiReadyTime, ArathiProxy.RspReadyInfo, self);
end

function ArathiProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiSignupTips, ArathiProxy._ArathiSignupTipsHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiData, ArathiProxy._ArathiDataHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiLastNotify, ArathiProxy._ArathiLastNotifyHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiEnter, ArathiProxy._ArathiEnterHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiExit, ArathiProxy._ArathiExitHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiWarData, ArathiProxy._ArathiWarDataHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiResChage, ArathiProxy._ArathiResChageHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiMineChage, ArathiProxy._ArathiMineChageHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiBuffChage, ArathiProxy._ArathiBuffChageHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiOccupyMine, ArathiProxy._ArathiOccupyMineHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiOccupyBuff, ArathiProxy._ArathiOccupyBuffHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiSignup, ArathiProxy._ArathiSignupHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiWarRank, ArathiProxy._ArathiWarRankHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiOverResult, ArathiProxy._ArathiOverResultHandler, self);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ArathiReadyTime, ArathiProxy.RspReadyInfo, self);
end


-- 获取上界争霸报名信息
function ArathiProxy:_ArathiSignupTipsHandler(cmd, data)
	if data and data.errCode == nil then
		local map = GameSceneManager.map
		if(map == nil or(map ~= nil and map.info.type ~= InstanceDataManager.MapType.Novice)) then
			ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHISIGNUPTIPSPANEL);
			ArathiProxy.ArathiData();
		end
	end
end

-- 获取上界争霸报名信息
function ArathiProxy:_ArathiDataHandler(cmd, data)
	-- if data and data.errCode == nil then
	MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIDATA, data);
	-- end
end

function ArathiProxy:_ArathiLastNotifyHandler(cmd, data)
	local map = GameSceneManager.map;
	if(map == nil or(map ~= nil and map.info.type ~= InstanceDataManager.MapType.Field and map.info.type ~= InstanceDataManager.MapType.Main and map.info.type ~= InstanceDataManager.MapType.Guild)) then
		ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIENTERTIPSPANEL)
	end
end

-- 上界争霸匹配成功，可进场景通知
function ArathiProxy:_ArathiEnterHandler(cmd, data)
	if data and data.errCode == nil then
		local map = GameSceneManager.map;
		if map and map.info.id == ArathiProxy.readyMapId then
			local hero = PlayerManager.hero;
			hero.info.camp = data.camp;
			hero:StopAutoFight();
			hero:StopAutoKill();
			hero:StopAttack();
			hero:StopAction(3);
			ModuleManager.SendNotification(DialogNotes.CLOSE_ALL_DIALOGPANEL)
			DramaDirector.Clear()
			
			ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
			ModuleManager.SendNotification(MapNotes.CLOSE_MAPPANEL)
			ModuleManager.SendNotification(MapNotes.CLOSE_MAPWORLDPANEL);
			ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIPANEL);
			ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHISIGNUPPANEL);
			ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIHELPPANEL);
			ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHITIPSPANEL);
			
			GameSceneManager.GotoScene(battleCfg[1].map_id);
		end
	end
end

-- 离开战场
function ArathiProxy:_ArathiExitHandler(cmd, data)
	if data and data.errCode == nil then
		-- GameSceneManager.to = {}
		-- GameSceneManager.to.sid = data.sid;
		-- GameSceneManager.to.position = Convert.PointFromServer(data.x, data.y, data.z);
		local to = {}
		to.sid = data.sid;
		to.position = Convert.PointFromServer(data.x, data.y, data.z);
		GameSceneManager.GotoScene(data.sid, nil, to);
	end
end

-- 获取战场信息
function ArathiProxy:_ArathiWarDataHandler(cmd, data)
	if data and data.errCode == nil then
		local points = GameSceneManager.map.battlefieldPoints;
		if(points and data.bl) then
			for i, v in pairs(data.bl) do
				points[v.id]:SetBuff(v.buff);
			end
		end
		MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIWARDATA, data);
	end
end

-- 胜利点变化通知
function ArathiProxy:_ArathiResChageHandler(cmd, data)
	if data and data.errCode == nil then
		MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIRESCHAGE, data);
	end
end

-- 矿点状态变化通知
function ArathiProxy:_ArathiMineChageHandler(cmd, data)
	if data and data.errCode == nil then
		MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIMINECHAGE, data);
	end
end

-- Buff点状态变化通知
function ArathiProxy:_ArathiBuffChageHandler(cmd, data)
	if data and data.errCode == nil then
		local map = GameSceneManager.map;
		if(map) then
			map:SetBattlefieldPointBuff(data.id, data.buff);
		end
		MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIBUFFCHAGE, data);
	end
end

-- 占领矿点
function ArathiProxy:_ArathiOccupyMineHandler(cmd, data)
	if data and data.errCode == nil then
		MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIOCCUPYMINESTATE, data);
	end
end

-- 获取Buff
function ArathiProxy:_ArathiOccupyBuffHandler(cmd, data)
	if data and data.errCode == nil then
		
	end
end

-- 战场报名
function ArathiProxy:_ArathiSignupHandler(cmd, data)
	if data and data.errCode == nil then
		MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHISIGNUP, data);
	end
end

-- 战局
function ArathiProxy:_ArathiWarRankHandler(cmd, data)
	if data and data.errCode == nil then
		MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIWARRANK, data);
	end
end

-- 战场结算
function ArathiProxy:_ArathiOverResultHandler(cmd, data)
	PlayerManager.hero:StopAttack();
	PlayerManager.hero:StopAction(3)
	PlayerManager.hero:Stand();
	ModuleManager.SendNotification(ConfirmNotes.CLOSE_CONFIRM1PANEL);
	ModuleManager.SendNotification(MapNotes.CLOSE_ARATHIMAPPANEL);
	ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIWARPANEL);
	ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIWARTIPSPANEL);
	ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIOVERRESULTPANEL, data)
	
	--    if data and data.errCode == nil then
	--        MessageManager.Dispatch(ArathiNotes, ArathiNotes.EVENT_ARATHIOVERRESULT, data);
	--    end
end

------------------------------------------
-- 战场报名
function ArathiProxy.ArathiData()
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiData);
end

-- 战场报名
function ArathiProxy.ArathiSignup(id)
	local data = {};
	data.id = id;
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiSignup, data);
end

-- 战局
function ArathiProxy.ArathiWarRank()
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiWarRank, {});
end

-- 获取战场信息
function ArathiProxy.RefreshArathiWarData()
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiWarData, {});
end

-- 占领矿点
function ArathiProxy.OccupyMine(id, state)
	local data = {};
	data.id = id;
	data.f = state;
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiOccupyMine, data);
end

-- 获取Buff
function ArathiProxy.OccupyBuff(id)
	local data = {};
	data.id = id;
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiOccupyBuff, data);
end

function ArathiProxy.ExitArathiWar()
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiExit, {});
end

function ArathiProxy.EnterReadyScene()
	local mapInfo = GameSceneManager.GetMapInfo(ArathiProxy.readyMapId);
	local to =
	{
		sid = mapInfo.map;
		position = Convert.PointFromServer(mapInfo.born_x, mapInfo.born_y, mapInfo.born_z);
	}
	GameSceneManager.GotoScene(ArathiProxy.readyMapId, nil, to);

	ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIPANEL)
	ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
end

function ArathiProxy.ReqReadyInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.ArathiReadyTime, nil);
end

function ArathiProxy:RspReadyInfo(cmd, data)
	if data and data.errCode == nil then
		
		local msg = nil;
		if data.t > 0 then
			local t = data.t - GetTime();
			Warning(t);
			msg = {
	            downTime = t,
	            prefix = LanguageMgr.Get("Arathi/readyTime")
	            ,
	            endMsg = ""
	            ,
	            endMsgDuration = 1
	        }
        else
        	msg = {
	            downTime = 0,
	            prefix = ""
	            ,
	            endMsg = LanguageMgr.Get("Arathi/readyTime/end")
	            ,
	            endMsgDuration = 10
	        }
        end

        MessageManager.Dispatch(SceneEventManager, DownTimer.DOWN_TIME_START, msg);
	end
end