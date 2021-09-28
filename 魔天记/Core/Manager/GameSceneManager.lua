require "Core.Scene.SceneMap";
require "Core.Module.Loading.Loading"
GameSceneManager = class("GameSceneManager")

GameSceneManager.MESSAGE_SCENE_CHANGE_BEFORE = "MESSAGE_SCENE_CHANGE_BEFORE";
GameSceneManager.MESSAGE_SCENE_CHANGE = "MESSAGE_SCENE_CHANGE";
GameSceneManager.MESSAGE_SCENE_ENTER = "MESSAGE_SCENE_ENTER";
GameSceneManager.MESSAGE_SCENE_BEFORE_EXIT = "MESSAGE_SCENE_BEFORE_EXIT";
GameSceneManager.MESSAGE_SCENE_START = "MESSAGE_SCENE_START";
GameSceneManager.MESSAGE_SCENE_END = "MESSAGE_SCENE_END";
GameSceneManager.MESSAGE_SCENE_AFTER_INIT = "MESSAGE_SCENE_AFTER_INIT";
GameSceneManager.MESSAGE_SCENE_LINE_CHANGE = "MESSAGE_SCENE_LINE_CHANGE";

GameSceneManager.MESSAGE_ADD_ROLE = "MESSAGE_ADD_ROLE";
GameSceneManager.MESSAGE_REMOVE_ROLE = "MESSAGE_REMOVE_ROLE";

GameSceneManager.cmdIndex = 0
GameSceneManager.map = nil;
GameSceneManager.id = nil;
GameSceneManager.to = nil;
local afterInitScene = {}
GameSceneManager.goingToScene = false;
GameSceneManager.gotoSceneForFollow = false;

GameSceneManager.scenelineData = nil -- 当前场景分线
GameSceneManager.mpaTerrain = MapTerrain.GetInstance() --地形
GameSceneManager.debug = GameConfig.instance.debugFlg

function GameSceneManager.SetSceneLine(data)
	
	GameSceneManager.scenelineData = data
	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_LINE_CHANGE);
end
function GameSceneManager.hasSceneLine()
	if GameSceneManager.scenelineData == nil then return false end
	if GameSceneManager.map and GameSceneManager.map.info.type ~= 1 then return false end
	return GameSceneManager.scenelineData.ln > 0
end
local phy = nil
local insert = table.insert
local projectorShadowPath
GameSceneManager.gotoScene_resultHandler = nil;
--[[GameSceneManager.to =
            {
                portal = 传送门id;
                sid 场景id
                x，y动到坐标x;
            }
            ]]
function GameSceneManager.InitGameScene()
	SceneManager.GetIns():InitGameScene();
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CheckScene, GameSceneManager.CheckSceneResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GotoScene, GameSceneManager.GotoSceneResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RedirectScene, GameSceneManager.RedirectScenePos);
	
	Resourcer.maxNum = 128
	Resourcer.clearCacheTime = 180
	Resourcer.checkCacheFrame = 300
end

function GameSceneManager.SetGotoSceneHandler(resultHandler, handlerTarget)
	
	if resultHandler == nil then
		GameSceneManager.gotoScene_resultHandler = nil;
	else
		GameSceneManager.gotoScene_resultHandler = {handler = resultHandler, target = handlerTarget};
	end
	
end

--0x0322强制跳转到场景
function GameSceneManager.RedirectScenePos(cmd, data)
	local info = data.scene;
	local sid = tonumber(info.sid);
	local toScene = {};
	toScene.sid = sid;
	toScene.position = Convert.PointFromServer(info.x, info.y, info.z);
	-- GameSceneManager.to = toScene;
	GameSceneManager.GotoScene(sid, nil, toScene);
end

--[[进入副本
fb_id  副本 id    --》 instanece

]]
function GameSceneManager.GoToFB(fb_id, npcId,tf)
	local fbCf = InstanceDataManager.GetMapCfById(fb_id);
	--Warning(fb_id .."__"..fbCf.enter_type  .. "__"..tostring(npcId))
	if fbCf.enter_type == 1 or tf == 1 then
		-- 单人
		local tx = SceneInfosGetManager.Get_ins():GetRandom(fbCf.position_x);
		local ty = 0;
		local tz = SceneInfosGetManager.Get_ins():GetRandom(fbCf.position_z);
		
		local toScene = {};
		toScene.sid = fbCf.map_id;
		toScene.position = Convert.PointFromServer(tx, ty, tz);
		toScene.rot = fbCf.toward + 0;
		
		-- GameSceneManager.to = toScene;
		GameSceneManager.GotoScene(fbCf.map_id, nil, toScene,tf);
	elseif(fbCf.enter_type == 2) then
		-- 多人
		if fbCf.type == InstanceDataManager.InstanceType.type_endlessTry
		and PartData.GetMyTeamNunberNum() == 1 then
			local conf = function() LSInstanceProxy.TryStarTeamFB(fb_id) end
			MsgUtils.ShowConfirm(nil, "EndlessTry/alone", nil, conf)
			return
		end
		LSInstanceProxy.TryStarTeamFB(fb_id);
	elseif(fbCf.enter_type == 3) then
		if(fbCf.type == InstanceDataManager.InstanceType.type_MingZhuRuQing) then
			LSInstanceProxy.SendSetNpc(npcId)
		elseif(fbCf.type == InstanceDataManager.InstanceType.type_ZongMenLiLian) then
			
			ZongMenLiLianProxy.ZongMenLiLianGetToNPC();
			
		else
			GameSceneManager.GotoScene(fbCf.map_id);
		end
		
	end
end

--[[有进度条加载 后， 条场景

http://192.168.0.8:3000/issues/487

]]
function GameSceneManager.GotoSceneByLoading(id, to)
	
	-- 如果在 跟隨狀態的話， 不能进行 其他操作
	local isFl = HeroController.GetInstance():IsFollowAiCtr();
	if isFl then
		MsgUtils.ShowTips("SequenceCommand/label1");
		return;
	end
	
	--[[    local ifm = HeroController.GetInstance():IsOnFMount();
    if ifm then
        MsgUtils.ShowTips("GameSceneManager/label1");
        return;
    end
    ]]
	local act = HeroController.GetInstance():GetAction();
	if(act == nil or(act ~= nil and(not act.isAcrossMap))) then
		HeroController.GetInstance():Stand(true)
	end
	HeroController.GetInstance():PauseAutoFight();
	
	ModuleManager.SendNotification(BusyLoadingNotes.OPEN_BUSYLOADINGPANEL, {
		type = BusyLoadingPanel.TYPE_FOR_GOTOSCENE,
		tile = LanguageMgr.Get("GameSceneManger/tranfering"),
		hd = GameSceneManager.GotoSceneHandler,
		hd_tg = nil,
		hd_data = {id = id, to = to}
	});
	
end

function GameSceneManager.GotoSceneHandler(data)
	GameSceneManager.GotoScene(data.id, nil, data.to)
end

function GameSceneManager.CheckTeamLdSendGotoScene(id)
	local teamNum = PartData.GetMyTeamNunberNum();
	if teamNum > 1 then
		local meIsLd = PartData.MeIsTeamLeader();
		if meIsLd then
			
			local position = {x = 0, y = 0, z = 0};
			
			if GameSceneManager.to ~= nil then
				position = GameSceneManager.to.position;
			end
			
			FriendProxy.SendLaderGotoScene(id, position.x, position.y, position.z);
		end
	end
end

function GameSceneManager.GetMapId()
	return GameSceneManager.map and GameSceneManager.map:GetMapId() or - 1
end

function GameSceneManager.GetId()
	return GameSceneManager.map and GameSceneManager.map:GetId() or - 1
end

-- 需要判断 是否自动 战斗
function GameSceneManager.Check_autoFight()
	if GameSceneManager.id ~= nil then
		
		local mid = GameSceneManager.id + 0;
		local fbCf = ConfigManager.GetMapById(mid);
		
		-- 我是否 是 队长
		local isld = PartData.MeIsTeamLeader();
		
		if fbCf.is_stopFollow and not isld then
			local _followAiCtr = HeroController:GetInstance():GetFollowAiCtr();
			if _followAiCtr ~= nil then
				HeroController:GetInstance():StopFollow();
				FriendProxy.AnswerLdAskGenShui(0, 0)
			end
		end
		
		if fbCf.is_autoFight then
			PlayerManager.hero:StartAutoFight();
		end
		
	end
end
function GameSceneManager.CheckSceneLoaded(map)
	if PlayerManager.hero and not AppSplitDownProxy.Loaded() then
		local path = "Scenes/" .. map	
		if not AssetsBehaviour.instance:InAppSource(path) and not AppSplitDownProxy.SysCheckLoad(nil, PlayerManager.GetPlayerLevel()) then return false end
	end
	return true
end

function GameSceneManager.GotoScene(id, ln, to,tf)
	
	ln = ln or 0
	-- HeroController:GetInstance():StopFightStatusTimer()
	-- 可能通过寻路传送所以在每一次传送之前都要发送一个关闭地图的消息 
	ModuleManager.SendNotification(MapNotes.CLOSE_MAPPANEL)
	ModuleManager.SendNotification(DialogNotes.CLOSE_ALL_DIALOGPANEL)
	ModuleManager.SendNotification(BusyLoadingNotes.CLOSE_BUSYLOADINGPANEL)
	local mapInfo = GameSceneManager.GetMapInfo(id);
	if(mapInfo) then
		
		if GameSceneManager.goingToScene then
			-- 在正在跳场景的时候 再次 调用 此函数， 忽略
			log(" ----------------- do not go to scene again");
			return false
		end
		
		if not GameSceneManager.CheckSceneLoaded(mapInfo.map) then return false end
		
		---------------------------------------  在跳场景的时候 如果自己已经变身载具 的话， 需要检查载具是否需要取消   -----------------------------------------------------------------------------------------------
		HeroController:GetInstance():CheckOutCurrMountByGotoScene();
		
		
		-- 检测自己是否 正在飞行载具中， 如果是的话，那么就停止 飞行载具 
		HeroController.GetInstance():CheckAndOutMountNyNotSendToServer(false, true);
		----------------------------------
		local afterAction =(
		function()
			GameSceneManager.goingToScene = false;
			xpcall(function()
				GameSceneManager._GotoSceneAfterHandler(id, fid)
				GameSceneManager.CheckAfterSceneToFollow();
				GameSceneManager.CheckAfterAndCloseAllFbRresultPanel();				
				Crossing.EndCross()
			end, function() Error(debug.traceback()) end)
			-- GameSceneManager._GotoSceneAfterHandler(id, fid);
		end
		);
		
		local beforeAction =(
		function()
			xpcall(function()
				GameSceneManager.to = to
				MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_BEFORE_EXIT);
				GameSceneManager._GotoSceneBeforeHandler(id, fid);
				
				------------------------------------- 如果自己有队伍， 而且队伍成员2人以及以上的话，而且自己是队长， 那么就需要通知 其他队员 队长跳场景了  --------------------------
				GameSceneManager.CheckTeamLdSendGotoScene(id);
				
				----------------------------------------------------------------------------------------------
				DramaDirector.Clear()
				SceneEventManager.ClearCameraCache()
				local hero = HeroController.GetInstance()
				if(hero) then
					local act = hero:GetAction();
					if(act == nil or(act ~= nil and(not act.isAcrossMap))) then
						HeroController.GetInstance():Stand(true)
					end
					HeroController.GetInstance():PauseAutoFight();
				end
				Loading.Show() end, function() Error(debug.traceback()) end)
		end
		);
		
        if tf == nil then
          tf = 0;
        end 
		
		GameSceneManager.goingToScene = true;
		SceneManager.GetIns():GotoScene(id, ln, mapInfo.map, beforeAction, afterAction, Loading.OnProGress,tf);
	else
		
	end
	
	return true
end




function GameSceneManager.CheckAfterSceneToFollow()
	
	if GameSceneManager.old_id ~= nil then
		-- http://192.168.0.8:3000/issues/2615
		-- is_callFollow 从哪个副本处理， 通过 is_callFollow 判断是否i需要 队长邀请跟随
		local old_map_cf = GameSceneManager.GetMapInfo(GameSceneManager.old_id);
		if old_map_cf.is_callFollow then
			
			local b = PartData.MeIsTeamLeader();
			if b then
				FriendProxy.LdAskGenShui();
			end
		end
	end
	
end

-- 跳场景后， 需要检测 是否还有结算界面没关闭， 如果没有关闭的话， 需要关闭结算界面
-- http://192.168.0.8:3000/issues/2615  添加的功能导致 队员结算界面没关闭就被队长 拉到 其他场景， 而结束界面还没结束， 导致界面界面完成后， 再次跳场景
function GameSceneManager.CheckAfterAndCloseAllFbRresultPanel()
	
	FBResultProxy.TryCloseAllPanel();
	
end

function GameSceneManager.DestroyLoadObject()
	Loading.Hide()
end

GameSceneManager._0x0301ErrorHandler = nil;

function GameSceneManager.CheckSceneResult(cmd, data)
	
	if(data.errCode) then
		--   MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
		GameSceneManager.goingToScene = false;
		
		if GameSceneManager._0x0301ErrorHandler ~= nil then
			GameSceneManager._0x0301ErrorHandler(data);
			GameSceneManager._0x0301ErrorHandler = nil;
		end
		
		GameSceneManager.map:ResumeAllPortal()
	end
	
end


GameSceneManager._0x0302Handler = nil;
--[[进入 场景
错误 ： 返回 0x0301
正确    返回 0x0302

]]
function GameSceneManager.GotoSceneResult(cmd, data)
	
	if(data.errCode) then
		--   MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
		GameSceneManager.goingToScene = false;
	else
		if(data.camp) then
			local hero = HeroController.GetInstance();
			if(hero) then
				hero.info.camp = data.camp;
			end
		end
		if GameSceneManager._0x0302Handler ~= nil then
			GameSceneManager._0x0302Handler();
			GameSceneManager._0x0302Handler = nil;
		end
		
	end
	
end


function GameSceneManager.GetMapInfo(id)
	local mpaCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP);
	return mpaCfg[tonumber(id)];
end

function GameSceneManager._GotoSceneBeforeHandler(id)
	
	ModuleManager.SendNotification(MainUINotes.HIDE_MAINUIPANEL);
	if(GameSceneManager.map) then
		GameSceneManager.map:Dispose();
		GameSceneManager.map = nil;
	end

	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE_BEFORE);
end


function GameSceneManager._GotoSceneAfterHandler(id)
	GameSceneManager.old_id = GameSceneManager.id;
	-- GameSceneManager.old_fid = GameSceneManager.fid;
	GameSceneManager.old_mapId = GameSceneManager.mapId;
	
	GameSceneManager.id = id;
	
	local inscf = InstanceDataManager.GetInsByMapId(id);
	GameSceneManager.fid = nil;
	if inscf ~= nil then
		GameSceneManager.fid = inscf.id;
	end
	
	
	GameSceneManager.map = SceneMap:New(GameSceneManager.id, GameSceneManager.fid);
	
	GameSceneManager.mapId = GameSceneManager.GetMapId()
	
	ModuleManager.SendNotification(MainUINotes.OPEN_MAINUIPANEL);
	ModuleManager.SendNotification(MainUINotes.SHOW_MAINUIPANEL);
	
	MessageManager.Dispatch(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE);
	if(table.getCount(afterInitScene) > 0) then
		for i = table.getCount(afterInitScene), 1, - 1 do
			if(afterInitScene[i]) then
				pcall(afterInitScene[i], function() Error(debug.traceback()) end)
				table.remove(afterInitScene, i)
			end
		end
	end
	phy = nil
	GameSceneManager.UpdateShowShadow(AutoFightManager.IsShowShadow())
end
function GameSceneManager.UpdateShowShadow(v)
	if v then
		local hero = HeroController.GetInstance()
		if hero then
			hero:SetShadowDirction(GameSceneManager.map:GetSceneLightDirection())
		end
		if phy then return end
		local terrain = GameObject.Find("Scene/Terrain")
		if not terrain then return end
		local ms = UIUtil.GetComponentsInChildren(terrain, "MeshCollider")
		phy = Util.FindForSubName(ms, "_phy")
		if not phy then return end
		local mr = phy:GetComponent("MeshRenderer")
		if not mr then
			--if projectorShadowPath then Resourcer.Recycle(projectorShadowPath) end
			--projectorShadowPath = "Shader/ProjectorTerrain"
			local s = Shader.Find("JTYL_Shader/ProjectorTerrain");
			-- Resourcer.GetShader(projectorShadowPath)
			--Warning(tostring(s) .. tostring(Resourcer.GetShader(projectorShadowPath)))
			local m = Material(s)
			local mr = phy.gameObject:AddComponent("MeshRenderer")
			mr.sharedMaterial = m
		end
		local mf = phy:GetComponent("MeshFilter")
		if not mf then
			local mf = phy.gameObject:AddComponent("MeshFilter")
			mf.sharedMesh = phy.sharedMesh
		end
	end
end


-- 切换场景后需要执行的函数
function GameSceneManager.SetInitSceneCallBack(fun)
	insert(afterInitScene, fun)
end

--[[纯客户端切换场景
与GameSceneManager.GotoScene不同的是GameSceneManager.GotoScene要向服务端发送切换场景x0301
SetMap是客户端自行切换场景 不告知服务端, 仅作显示3D场景用.
]]
function GameSceneManager.SetMap(mapId, onComplete)
	if(GameSceneManager.goingToScene) then
		return
	end
	local mapCfg = ConfigManager.GetMapById(mapId);
	if(GameSceneManager.map) then
		GameSceneManager.map:Dispose();
		GameSceneManager.map = nil;
	end
	
	Loading.Show()
	
	local action = function()
		
		GameSceneManager.map = SceneMap:New(mapId);
		GameSceneManager.mapId = GameSceneManager.GetMapId()
		GameSceneManager.DestroyLoadObject()
		if onComplete then
			onComplete();
		end
		GameSceneManager.goingToScene = false
	end;
	GameSceneManager.goingToScene = true 
	Warning("--->SetMap scene ------------------- " .. mapId .. "-" .. mapCfg.map);
	
	SceneLoader.instance:GotoScene(mapCfg.map, action, Loading.OnProGress)
end

function GameSceneManager.SetActive(v)
	if(GameSceneManager.map) then
		GameSceneManager.map:SetActive(v);
	end
end 