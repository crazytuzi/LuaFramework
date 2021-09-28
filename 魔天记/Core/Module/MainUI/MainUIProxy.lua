require "Core.Module.Pattern.Proxy"

MainUIProxy = Proxy:New();

MainUIProxy.MESSAGE_GETFBSTAR_CALLBACK = "MESSAGE_GETFBSTAR_CALLBACK";
MainUIProxy.MESSAGE_RECAUTOFIGHTEXP_CALLBACK = "MESSAGE_RECAUTOFIGHTEXP_CALLBACK";

function MainUIProxy:OnRegister()
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AskForStarTeamFBRec, MainUIProxy.AskForStarTeamFBRecResult, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.CanStarTeamFB, MainUIProxy.CanStarTeamFBResult, self);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryStarTeamFBErr, MainUIProxy.TryStarTeamFBErrResult, self);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RevChatMessage, MainUIProxy.RevChatMessageResult);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RecBeAddFriend, MainUIProxy.RecBeAddFriendResult);
	
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.AskForStarTeamFB, MainUIProxy.AskForStarTeamFBResult);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryRecForShouHu, MainUIProxy.TryRecForShouHuResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetAchievementReward, MainUIProxy.GetAchievementRewardCallBack);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.EnterExitMirror, MainUIProxy.EnterExitMirror);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.PlayerRelive, MainUIProxy.PlayerReliveCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetMyFriendsList, MainUIProxy.GetMyFriendsListCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetPrivChatMsgData, MainUIProxy.GetPrivChatMsgDataCallBack);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ScenePropChange, MainUIProxy.ScenePropChangeCallBack);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryGetFBStar, MainUIProxy.TryGetFBStarCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RecAutoFightExp, MainUIProxy.RecAutoFightExpCallBack);
	
   -- SocketClientLua.Get_ins():AddDataPacketListener(CmdType.FormationUpdate, MainUIProxy.FormationUpdate)

     SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WorldBossEnd, MainUIProxy.WorldBossEndHandler)
	
end

function MainUIProxy:OnRemove()
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AskForStarTeamFBRec, MainUIProxy.AskForStarTeamFBRecResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.CanStarTeamFB, MainUIProxy.CanStarTeamFBResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryStarTeamFBErr, MainUIProxy.TryStarTeamFBErrResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RevChatMessage, MainUIProxy.RevChatMessageResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RecBeAddFriend, MainUIProxy.RecBeAddFriendResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.AskForStarTeamFB, MainUIProxy.AskForStarTeamFBResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryRecForShouHu, MainUIProxy.TryRecForShouHuResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetAchievementReward, MainUIProxy.GetAchievementRewardCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.EnterExitMirror, MainUIProxy.EnterExitMirror);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.PlayerRelive, MainUIProxy.PlayerReliveCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetMyFriendsList, MainUIProxy.GetMyFriendsListCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetPrivChatMsgData, MainUIProxy.GetPrivChatMsgDataCallBack);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ScenePropChange, MainUIProxy.ScenePropChangeCallBack);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryGetFBStar, MainUIProxy.TryGetFBStarCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RecAutoFightExp, MainUIProxy.RecAutoFightExpCallBack);
	
   -- SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.FormationUpdate, MainUIProxy.FormationUpdate)

     SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WorldBossEnd, MainUIProxy.WorldBossEndHandler)
end

function MainUIProxy.SetMainUIOperateEnable(enable)
	MessageManager.Dispatch(MainUINotes, MainUINotes.OPERATE_ENABLE, enable);
end

function MainUIProxy.EnterExitMirror(cmd, data)
	-- t：0 进入镜像，1 离开镜像
	MainCameraController.GetInstance():WaterWaveEffect(data.t == 0)
end

function MainUIProxy.GetAchievementRewardCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local temp = {}
		temp[1] = {}
		temp[1].id = data.id
		temp[1].st = 2
		temp[1].num = 0
		AchievementManager.SetAchievementData(temp)
	end
end

function MainUIProxy.SendGetAchievementReward(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.GetAchievementReward, {id = id});
end

function MainUIProxy.SendChangeTitle(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.ChangeTitle, {id = id});
end


--[[0A 收到守护药园邀请（服务端发出）
输出：
id：玩家id
name：玩家呢陈

S <-- 16:03:27.786, 0x140A, 0, {"name":"\u5211\u5E38\u575A","id":"20100002"}

]]
function MainUIProxy.TryRecForShouHuResult(cmd, data)
	if(data.errCode == nil) then
		YaoyuanProxy._0x140AData[data.id] = data;
		MessageManager.Dispatch(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_0X140ADATA);
	end
end

--[[13 加入副本消息(服务端发出)
输出：
fid：副本id
n：队长name
tid:队伍ID
(队长点击进入副本时触发)
0x0B13

]]
function MainUIProxy.AskForStarTeamFBResult(cmd, data)
	if(data.errCode == nil) then
		PartData.ReSetAllAccept();
		local res = {instId = data.fid, tid = data.tid, mc = data.mc};
		ModuleManager.SendNotification(LSInstanceNotes.OPEN_LSWAITFORJOINPANEL, res);
	end
end

--[[07 被添加为好友通知（服务端发出）
输出：
id：玩家ID
name:玩家昵称
t:类型（1:好友 2：仇人 3:陌生人）

]]
function MainUIProxy.RecBeAddFriendResult(cmd, data)
	
	if(data.errCode == nil) then
		local t = data.t;
		
		if t == 1 then
			MsgUtils.ShowTips(nil, nil, nil, data.name .. LanguageMgr.Get("MainUIProxy/addFriend"));
		end
		
		
	end
	
end

--  S <-- 11:20:51.932, 0x0204, 0, {"msg":"dfgdfgrd","s_id":"20102690","c":4,"t":1,"time":"2016-05-30 11:17:07","s_name":"宇文英基"}
function MainUIProxy.RevChatMessageResult(cmd, data)
	
	if(data.errCode == nil) then
		local c = data.c;
		
		if c == FriendDataManager.chat_channel_self then
			FriendDataManager.AddChatMsg(data.s_id, data, true, true);
		end
		
	end
	
end


--[[04 加入副本限制广播（服务器发出）
输出：
l:等级限制列表[玩家ID]
t:次数限制列表[玩家ID]
0x0F04

S <-- 17:18:19.958, 0x0F04, 0, {"t":[],"l":["10100374"]}
]]
function MainUIProxy:TryStarTeamFBErrResult(cmd, data)
	
	if(data.errCode == nil) then
		MainUIProxy.StarTeamFBErrMsgs = {};
		
		
		
		local l_arr = data.l;
		local t_arr = data.t;
		local o_arr = data.o;
		
		local l_len = table.getn(l_arr);
		local t_len = table.getn(t_arr);
		local o_len = table.getn(o_arr);
		
		local id = nil;
		
		for i = 1, l_len do
			id = l_arr[i];
			local team_mb = PartData.FindMyTeammateData(id)
			if team_mb ~= nil then
				MsgUtils.ShowTips(nil, nil, nil, team_mb.n .. LanguageMgr.Get("mianUI/MainUIProxy/tip1"));
			end
			
		end
		
		for i = 1, t_len do
			id = t_arr[i];
			local team_mb = PartData.FindMyTeammateData(id)
			if team_mb ~= nil then
				MsgUtils.ShowTips(nil, nil, nil, team_mb.n .. LanguageMgr.Get("mianUI/MainUIProxy/tip2"));
			end
		end
		
		--  广播 不符合条件的 条件
		for i = 1, o_len do
			id = o_arr[i];
			local team_mb = PartData.FindMyTeammateData(id)
			if team_mb ~= nil then
				MsgUtils.ShowTips(nil, nil, nil, team_mb.n .. LanguageMgr.Get("mianUI/MainUIProxy/tip3"));
			end
		end
		
		
	end
	
end

--[[ S <-- 14:29:44.974, 0x0B15, 0, {"s":1,"id":"10100372","n":"姑苏墨"}
]]
function MainUIProxy:AskForStarTeamFBRecResult(cmd, data)
	PartData.Setready(data.id, data.s);
	
	if data.s == 1 then
		MsgUtils.ShowTips(nil, nil, nil, data.n .. LanguageMgr.Get("mianUI/MainUIProxy/tip4"));
	else
		MsgUtils.ShowTips(nil, nil, nil, data.n .. LanguageMgr.Get("mianUI/MainUIProxy/tip5"));
		ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL);
	end
	
	
end

--[[  S <-- 14:29:44.977, 0x0B16, 0, {"instId":"752001"}
]]
function MainUIProxy:CanStarTeamFBResult(cmd, data)
	
	ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL);
	ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSINSTANCEPANEL);
	
	ModuleManager.SendNotification(FriendNotes.CLOSE_FRIENDPANEL);
	
	ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
	
	-- 进入游戏
	local selectCfData = InstanceDataManager.GetMapCfById(data.instId);
	
	local tx = SceneInfosGetManager.Get_ins():GetRandom(selectCfData.position_x);
	local ty = 0;
	local tz = SceneInfosGetManager.Get_ins():GetRandom(selectCfData.position_z);
	
	local toScene = {};
	toScene.sid = selectCfData.map_id;
	toScene.position = Convert.PointFromServer(tx, ty, tz);
	toScene.rot = selectCfData.toward + 0;
	
	-- GameSceneManager.to = toScene;
	GameSceneManager.GotoScene(selectCfData.map_id, nil, toScene);
	
end

function MainUIProxy.SendRelive(_t)
	if _t == 0 then SceneEventManager.ClearCameraCache() end
	SocketClientLua.Get_ins():SendMessage(CmdType.PlayerRelive, {t = _t});
	
end

function MainUIProxy.PlayerReliveCallBack(cmd, data)
	
	if(data.errCode == nil) then
		ModuleManager.SendNotification(MainUINotes.CLOSE_RELIVEPANEL)
		PlayerManager.hero:Relive();
		MessageManager.Dispatch(PlayerManager, PlayerManager.SelfHpChange);
		--    else
		--        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
	end
end

function MainUIProxy.TryGetMyFriend()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetMyFriendsList, {});
end

--  只有在配置表中设置 后台 推送  才有返回
function MainUIProxy.TryGetFBStar()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.TryGetFBStar, {});
end



function MainUIProxy.TryGetFBStarCallBack(cmd, data)
	
	if(data.errCode == nil) then
		local s = data.s;
		
		MessageManager.Dispatch(MainUIProxy, MainUIProxy.MESSAGE_GETFBSTAR_CALLBACK, s);
		
	end
	
end

function MainUIProxy.RecAutoFightExpCallBack(cmd, data)
if(data.errCode == nil) then
		
		MessageManager.Dispatch(MainUIProxy, MainUIProxy.MESSAGE_RECAUTOFIGHTEXP_CALLBACK, data);
		
	end
end



function MainUIProxy.GetMyFriendsListCallBack(cmd, data)
	
	if(data.errCode == nil) then
		local l = data.l;
		FriendDataManager.Init(l);
		MainUIProxy.TryGetPrivChatMsgData()
	end
	
end

function MainUIProxy.TryGetPrivChatMsgData()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetPrivChatMsgData, {});
	
end

function MainUIProxy.GetPrivChatMsgDataCallBack(cmd, data)
	
	if(data.errCode == nil) then
		
		local msgs = data.msgs;
		for key, value in pairs(msgs) do
			local id = value.s_id;
			value.c = ChatChannel.pirvate
			FriendDataManager.AddChatMsg(id, value, true, true);
		end
		
	end
end

--[[20 场景更新物件（服务端发出）

输入： (有需要才会请求)
t:int 1 通知服务器添加场景物件， 2 强制 通知服务器移除场景物件
id: scence_prop.lua 对应的 id

输出：
t:int 1 通知服务器添加场景物件， 2 强制 通知服务器移除场景物件
id: scence_prop.lua 对应的 id

]]
function MainUIProxy.ScenePropChangeCallBack(cmd, data)
	
	if(data.errCode == nil) then
		
		local t = data.t;
		local id = data.id;
		
		if GameSceneManager.map ~= nil then
			
			if t == 1 then
				GameSceneManager.map:AddSceneProp(id);
			elseif t == 2 then
				GameSceneManager.map:RemoveSceneProp(id);
			end
			
		end
		
	end
end

--输入： id:道具id,num：数量;   输出：id:图阵id,lev:等级,exp:经验
function MainUIProxy.SendFormationUpdate(id, spId, num)
    SocketClientLua.Get_ins():SendMessage(CmdType.FormationUpdate,{ spId = spId, id = id, num = num })
end

function MainUIProxy.FormationUpdate(cmd, data)
    if data.errCode then return end
    FormationManager.UpdateData(data)
end

MainUIProxy.MESSAGE_MAINUI_WORLDBOSSEND = "MESSAGE_MAINUI_WORLDBOSSEND";

function MainUIProxy.WorldBossEndHandler(cmd, data)
   
   MessageManager.Dispatch(MainUIProxy, MainUIProxy.MESSAGE_MAINUI_WORLDBOSSEND);

end

