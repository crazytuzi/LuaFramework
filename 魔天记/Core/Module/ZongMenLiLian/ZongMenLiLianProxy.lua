require "Core.Module.Pattern.Proxy"

require "Core.Manager.Item.ZongMenLiLianDataManager"

ZongMenLiLianProxy = Proxy:New();



function ZongMenLiLianProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.OpenZongMenLiLian, ZongMenLiLianProxy.OpenZongMenLiLianResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetZongMenLiLianPreInfo, ZongMenLiLianProxy.GetZongMenLiLianPreInfoResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ZongMenLiLianCanGotoFb, ZongMenLiLianProxy.ZongMenLiLianCanGotoFbResult);
	
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ZongMenLiLianGameOver, ZongMenLiLianProxy.ZongMenLiLianGameOverResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ZongMenLiLianYaoQing, ZongMenLiLianProxy.ZongMenLiLianYaoQingResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetZongMenInfo, ZongMenLiLianProxy.GetZongMenInfoResult);
	
	
	TeamMatchDataManager.OnRegister();
	
end

function ZongMenLiLianProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.OpenZongMenLiLian, ZongMenLiLianProxy.OpenZongMenLiLianResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetZongMenLiLianPreInfo, ZongMenLiLianProxy.GetZongMenLiLianPreInfoResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ZongMenLiLianCanGotoFb, ZongMenLiLianProxy.ZongMenLiLianCanGotoFbResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ZongMenLiLianYaoQing, ZongMenLiLianProxy.ZongMenLiLianYaoQingResult);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ZongMenLiLianGameOver, ZongMenLiLianProxy.ZongMenLiLianGameOverResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetZongMenInfo, ZongMenLiLianProxy.GetZongMenInfoResult);
	TeamMatchDataManager.OnRemove();
	
end


function ZongMenLiLianProxy.ZongMenLiLianGetToNPC()
	SocketClientLua.Get_ins():SendMessage(CmdType.ZongMenLiLianGetToNPC, {});
end

ZongMenLiLianProxy.hanhuanCallTime = GetTime();

function ZongMenLiLianProxy.ZongMenLiLianYaoQing(type, min_lv, max_lv)
	
	
	if min_lv > max_lv then
		local b0 = min_lv;
		local b1 = max_lv;
		min_lv = b1;
		max_lv = b0;
	end
	
	
	-- 如果 自己没有队伍，那么就不能行话
	local mt = PartData.GetMyTeam();
	if mt == nil then
		MsgUtils.ShowTips("ZongMenLiLian/ZongMenLiLianProxy/label5");
		return;
	end
	
	
	
	-- http://192.168.0.8:3000/issues/1678
	-- 冷却时间：12秒
	local tem_time = GetTime();
	local d_time = tem_time - ZongMenLiLianProxy.hanhuanCallTime;
	d_time = math.ceil(d_time);
	if d_time < 12 then
		MsgUtils.ShowTips("ZongMenLiLian/ZongMenLiLianProxy/label4", {n = 12 - d_time});
		return;
	end
	
	ZongMenLiLianProxy.hanhuanCallTime = tem_time;
	
	
	SocketClientLua.Get_ins():SendMessage(CmdType.ZongMenLiLianYaoQing, {t = type, min_lv = min_lv, max_lv = max_lv});
end


function ZongMenLiLianProxy.ZongMenLiLianYaoQingResult(cmd, data)
	
	if(data.errCode == nil) then
		MsgUtils.ShowTips("ZongMenLiLian/ZongMenLiLianProxy/label3");
	end
end


----------------------------------------
function ZongMenLiLianProxy.GetZongMenInfo()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetZongMenInfo, {});
end

--[[ S <-- 17:14:58.518, 0x1613, 29, {"t":0,"a":0}

]]
function ZongMenLiLianProxy.GetZongMenInfoResult(cmd, data)
	
	if(data.errCode == nil) then
		ZongMenLiLianDataManager.SetSampleData(data);
	end
end

-------------------------------------------------------------------------------------------------------------------
function ZongMenLiLianProxy.OpenZongMenLiLian()
	
	-- log("------------------------------------------ZongMenLiLianProxy.OpenZongMenLiLian-----------------------------------------------------------------------------");
	SocketClientLua.Get_ins():SendMessage(CmdType.OpenZongMenLiLian, {});
end

function ZongMenLiLianProxy.GetZongMenLiLianPreInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetZongMenLiLianPreInfo, {});
end

--[[输出：
t:当前轮次多少次
npc：npcId
mid：map_id地图id
x：坐标
y：坐标
r：朝向

]]
function ZongMenLiLianProxy.OpenZongMenLiLianResult(cmd, data)
	if(data.errCode == nil) then
		-- 因为 1614 没有 f 字段， 那么需要补灵
		data.f = 0;
		
		ZongMenLiLianDataManager.SetZongMenLiLianPreInfo(data);
		
		-- 关闭 当前 窗口
		ModuleManager.SendNotification(ZongMenLiLianNotes.CLOSE_ZONGMENLILIANPANEL);
		
		-- 关闭活动界面
		ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
		
		if(cmd == CmdType.OpenZongMenLiLian) then
			if(data.mid and data.mid ~= - 1) then
				
				MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianProxy/label2"));
				
				ZongMenLiLianProxy.TryMoto(data);
				
			end
		end
	end
end

-- 这里是 判断 队长或者 队员 跟随 动作 入口
function ZongMenLiLianProxy.TryMoto(data)
	
	local team = PartData.GetMyTeam();
	if team == nil then
		log(" not team ");
		return;
	end
	
	local mapCf = ConfigManager.GetMapById(GameSceneManager.id);
	
	
	--  log("   ZongMenLiLianProxy.TryMoto " ..GameSceneManager.id);
	if mapCf.type == InstanceDataManager.MapType.Field or mapCf.type == InstanceDataManager.MapType.Main then
		
		
		-- 在副本中的时候， 不能马上 去找 npc ， 必须等 结束副本才去找 npc
		if ZongMenLiLianDataManager.positionCheckManager ~= nil then
			ZongMenLiLianDataManager.positionCheckManager.curr_hd_type = PositionCheckManager.HD_TYPE_NULL;
		end
		
		ZongMenLiLianDataManager.autoFightForZMLL = true;
		
		
		
		-- 如果自己是队长
		local mi_ist = PartData.MeIsTeamLeader();
		if mi_ist then
			HeroController:GetInstance():MoveToNpc(data.npc, data.mid, MapTerrain.SampleTerrainPosition(Convert.PointFromServer(data.x, 0, data.z)));
			
		else
			local ld = PartData.FindTeamLeader();
			-- 获取队长信息
			if ld ~= nil then
				HeroController:GetInstance():StartFollow(ld.pid, HeroController.FOLLOWTYPE_FOR_TEAM);
			end
		end
		
		
		ZongMenLiLianProxy.waitDoData = nil;
		-- 这个必须设置为 nil
	else
		-- 不在副本中， 马上去找 npc
		ZongMenLiLianProxy.waitDoData = data;
	end
	-- 有一种情况就是， 自己不是队长，而且现在还在 宗门 副本中， 队长已经在外面场景 再次开启 历练， 那么就会收到
	--  这个消息，但是 自己要等到 已经出了副本场景 才能 继续
end


function ZongMenLiLianProxy.CheckZongMenLiLianData()
	if ZongMenLiLianProxy.waitDoData ~= nil then
		ZongMenLiLianProxy.TryMoto(ZongMenLiLianProxy.waitDoData)
	end
end

--[[输出：
t:当前轮次多少次
npc：npcId
mid：map_id地图id
x：坐标
y：坐标
r：朝向

]]
function ZongMenLiLianProxy.GetZongMenLiLianPreInfoResult(cmd, data)
	if(data.errCode == nil) then
		ZongMenLiLianDataManager.SetZongMenLiLianPreInfo(data)
		if(cmd == CmdType.OpenZongMenLiLian) then
			if(data.mid and data.mid ~= - 1) then
				-- 关闭 当前 窗口
				ZongMenLiLianProxy.TryMoto(data);
				
			end
		end
	end
end




function ZongMenLiLianProxy.ZongMenLiLianCanGotoFbResult(cmd, data)
	
	
	if(data.errCode == nil) then
		
		if ZongMenLiLianDataManager.npc_fb_id ~= 0 then
			
			HeroController.GetInstance():StopAction(3);
			HeroController.GetInstance():Stand();
			
			local selectCfData = InstanceDataManager.GetMapCfById(ZongMenLiLianDataManager.npc_fb_id);
			if selectCfData == nil then
				log("ZongMenLiLianCanGotoFbResult error fb_id " .. ZongMenLiLianDataManager.npc_fb_id);
			end
			
			local tx = SceneInfosGetManager.Get_ins():GetRandom(selectCfData.position_x);
			local ty = 0;
			local tz = SceneInfosGetManager.Get_ins():GetRandom(selectCfData.position_z);
			
			local toScene = {};
			toScene.sid = selectCfData.map_id;
			toScene.position = Convert.PointFromServer(tx, ty, tz);
			toScene.rot = selectCfData.toward + 0;
			
			-- GameSceneManager.to = toScene;
			GameSceneManager.GotoScene(selectCfData.map_id, nil, to);
		end
		
	end
	
end


---------------------------------------------- ZongMenLiLianCancelGetNpc ---------------------------------------------------------
function ZongMenLiLianProxy.ZongMenLiLianCancelGetNpc()
	SocketClientLua.Get_ins():SendMessage(CmdType.ZongMenLiLianCancelGetNpc, {});
end

------------------------------------ ZongMenLiLianGameOverResult --------------------------------------
--[[宗门历练 副本 结束通知
1C 宗门历练结束更新进度通知（服务端发出）
输出：
t:当前轮次多少次

]]
ZongMenLiLianProxy.zmllIsOverInfo = nil;
function ZongMenLiLianProxy.ZongMenLiLianGameOverResult(cmd, data)
	
	if(data.errCode == nil) then
		
		
		--  log("----------------------------ZongMenLiLianProxy.ZongMenLiLianGameOverResult---------------------------------------------");
		ZongMenLiLianProxy.zmllIsOverInfo = data;
		ZongMenLiLianDataManager.CheckGoOnZongMengLiLian()
		
	end
	
end 