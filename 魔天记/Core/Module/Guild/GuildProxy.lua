require "Core.Module.Pattern.Proxy"
require "net/CmdType"
require "net/SocketClientLua"
local insert = table.insert

GuildProxy = Proxy:New();
function GuildProxy:OnRegister()
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Info, GuildProxy._RspGuildInfo);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_List, GuildProxy._RspGuildList);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Find, GuildProxy._RspFind);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Create, GuildProxy._RspCreate);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Join, GuildProxy._RspJoin);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Member, GuildProxy._RspGuildMember);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Verify_List, GuildProxy._RspGuildVertifyList);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Verify, GuildProxy._RspGuildVertify);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Verify_AllRefuse, GuildProxy._RspGuildVertifyAllRefuse);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Verify_Set, GuildProxy._RspGuildVertifySet);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Quit, GuildProxy._RspGuildQuit);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Dissolve, GuildProxy._RspGuildDissolve);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_SetNotice, GuildProxy._RspGuildSetNotice);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_GetEnemyList, GuildProxy._RspEnemyList);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_SetEnemy, GuildProxy._RspSetEnemy);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_CancelEnemy, GuildProxy._RspCancelEnemy);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Kick, GuildProxy._RspKick);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_SetIdentity, GuildProxy._RspSetIdentity);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_LogList, GuildProxy._RspLogList);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Act_Info, GuildProxy._RspActInfo);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Task_MoBaiNum, GuildProxy._RspGuildMoBaiNum);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Invite, GuildProxy._RspGuildInvite);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_AnsInvite, GuildProxy._RspGuildAnsInvite);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_NewReqJoin, GuildProxy._RspNewReqJoin);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_InGuild, GuildProxy._RspInGuild);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_OutGuild, GuildProxy._RspOutGuild);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_NewMember, GuildProxy._RspNewMember);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_BeRefuseJoin, GuildProxy._RspBeRefuse);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_Identity_Chg, GuildProxy._RspIdentityChg);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_GuildLevelUp, GuildProxy._RspLevelUp);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_MyGuildInfo, GuildProxy._RspUpdateMyGuildInfo);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_BeInvite, GuildProxy._RspBeInvite);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Notify_InfoUpdate, GuildProxy._RspGuildInfoUpdate);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Research_Skill, GuildProxy._RspResearchSkill);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.HongBaoNotify, GuildProxy._RspHongBaoNotify);
	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ShowHongBao, GuildProxy._RspShowHongBao);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SendHongBao, GuildProxy._RspSendHongBao);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetGuildHongBaoData, GuildProxy._RspGetGuildHongBaoData);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Get_Salary, GuildProxy._RspGetSalary);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Get_Salary_Status, GuildProxy._RspGetSalaryStatus);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Learn_Skill, GuildProxy._RspLearnSkill);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetGuildAssignInfo, GuildProxy._RspAwardInfo);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Task_GetNum, GuildProxy._RspTaskGetMoBaiNum);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_MoBaiActive, GuildProxy._RspMoBaiActive);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_MoBaiOpt, GuildProxy._RspMoBaiOpt);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_MoBaiInfo, GuildProxy._RspMoBaiInfo);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GUild_Get_TuoJi_Exp, GuildProxy._GUild_Get_TuoJi_ExpRes);
end

function GuildProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Info, GuildProxy._RspGuildInfo);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_List, GuildProxy._RspGuildList);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Find, GuildProxy._RspFind);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Create, GuildProxy._RspCreate);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Join, GuildProxy._RspJoin);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Member, GuildProxy._RspGuildMember);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Verify_List, GuildProxy._RspGuildVertifyList);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Verify, GuildProxy._RspGuildVertify);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Verify_AllRefuse, GuildProxy._RspGuildVertifyAllRefuse);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Verify_Set, GuildProxy._RspGuildVertifySet);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Quit, GuildProxy._RspGuildQuit);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Dissolve, GuildProxy._RspGuildDissolve);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_SetNotice, GuildProxy._RspGuildSetNotice);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_GetEnemyList, GuildProxy._RspEnemyList);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_SetEnemy, GuildProxy._RspSetEnemy);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_CancelEnemy, GuildProxy._RspCancelEnemy);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Kick, GuildProxy._RspKick);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_SetIdentity, GuildProxy._RspSetIdentity);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_LogList, GuildProxy._RspLogList);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Act_Info, GuildProxy._RspActInfo);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Task_MoBaiNum, GuildProxy._RspGuildMoBaiNum);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Invite, GuildProxy._RspGuildInvite);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_AnsInvite, GuildProxy._RspGuildAnsInvite);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_NewReqJoin, GuildProxy._RspNewReqJoin);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_InGuild, GuildProxy._RspInGuild);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_OutGuild, GuildProxy._RspOutGuild);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_NewMember, GuildProxy._RspNewMember);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_BeRefuseJoin, GuildProxy._RspBeRefuse);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_Identity_Chg, GuildProxy._RspIdentityChg);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_GuildLevelUp, GuildProxy._RspLevelUp);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_MyGuildInfo, GuildProxy._RspUpdateMyGuildInfo);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_BeInvite, GuildProxy._RspBeInvite);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Notify_InfoUpdate, GuildProxy._RspGuildInfoUpdate);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Research_Skill, GuildProxy._RspResearchSkill);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.HongBaoNotify, GuildProxy._RspHongBaoNotify);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ShowHongBao, GuildProxy._RspShowHongBao);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SendHongBao, GuildProxy._RspSendHongBao);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetGuildHongBaoData, GuildProxy._RspGetGuildHongBaoData);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Get_Salary, GuildProxy._RspGetSalary);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Get_Salary_Status, GuildProxy._RspGetSalaryStatus);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Learn_Skill, GuildProxy._RspLearnSkill);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetGuildAssignInfo, GuildProxy._RspAwardInfo);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Task_GetNum, GuildProxy._RspTaskGetMoBaiNum);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_MoBaiOpt, GuildProxy._RspMoBaiOpt);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_MoBaiActive, GuildProxy._RspMoBaiActive);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_MoBaiInfo, GuildProxy._RspMoBaiInfo);
     SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GUild_Get_TuoJi_Exp, GuildProxy._GUild_Get_TuoJi_ExpRes);
end

function GuildProxy.ReqExitZone()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLastSceneId, GuildProxy._OnGetLastSceneId);
	SocketClientLua.Get_ins():SendMessage(CmdType.GetLastSceneId);
end

function GuildProxy._OnGetLastSceneId(cmd, data)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLastSceneId, GuildProxy._OnGetLastSceneId);
	local info = data.scene;
	local sid = tonumber(info.sid);
	local toScene = {};
	toScene.sid = sid;
	toScene.position = Convert.PointFromServer(info.x, info.y, info.z);
	-- GameSceneManager.to = toScene;
	GameSceneManager.GotoScene(sid,nil,toScene);
end

-- 工会信息
function GuildProxy.ReqInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Info, nil);
end

-- 工会列表
function GuildProxy.ReqGuildList(page, isEnemy)
	GuildProxy.reqEnemy = isEnemy ~= nil;
	-- 是否包括敌对数据.
	GuildProxy.tmpReqPage = page;
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_List, {idx = page});
end
-- 查找工会.
function GuildProxy.ReqFind(findStr, isEnemy)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Find, {id = findStr});
end
-- 创建工会
function GuildProxy.ReqCreate(gName)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Create, {name = gName});
end
-- 申请加入工会
function GuildProxy.ReqJoin(gid)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Join, {id = gid});
end
-- 请求工会成员
function GuildProxy.ReqMember()
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Member, nil);
end
-- 请求审核列表
function GuildProxy.ReqVertifyList()
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Verify_List, nil);
end
-- 审核
function GuildProxy.ReqVertify(id, result)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Verify, {id = id, f = result and 1 or 0});
end
-- 审核全部拒绝
function GuildProxy.ReqVertifyAllRefuse(id, result)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Verify_AllRefuse, nil);
end
-- 设置自动审核
function GuildProxy.ReqVertifySet(auto)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Verify_Set, {t = auto and - 1 or 0});
end
-- 进入领地
function GuildProxy.ReqEnterZone()
	--  GameSceneManager.GotoScene(GuildDataManager.mapId);
	if GuildDataManager.InGuild() == false then
		MsgUtils.ShowTips("guild/zone/0");
		return;
	end
	if TaskUtils.InMap(GuildDataManager.mapId) then
		return;
	end
	-- GameSceneManager.to = nil;
	GameSceneManager.GotoSceneByLoading(GuildDataManager.mapId);
end
-- 退出工会
function GuildProxy.ReqQuit()
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Quit, nil);
end
-- 设置公告
function GuildProxy.ReqSetNotice(str)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_SetNotice, {n = str});
end
-- 获取敌对列表
function GuildProxy.ReqEnemyList(page)
	GuildProxy.tmpReqPage = page;
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_GetEnemyList, nil);
end
-- 设置敌视
function GuildProxy.ReqSetEnemy(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_SetEnemy, {id = id});
end
-- 取消敌视
function GuildProxy.ReqCancelEnemy(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_CancelEnemy, {id = id});
end
-- 踢出工会
function GuildProxy.ReqKick(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Kick, {id = id});
end
-- 设置职位
function GuildProxy.ReqSetIdentity(id, idt)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_SetIdentity, {id = id, s = idt});
end
-- 日志.
function GuildProxy.ReqLogList(page)
	GuildProxy.tmpLogPage = page;
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_LogList, {idx = page});
end

function GuildProxy.ReqGuildActInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Act_Info, nil);
end
-- 查询膜拜的任务信息
function GuildProxy.ReqGuildMoBaiNum()
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Task_MoBaiNum, nil);
end

function GuildProxy.ReqInvate(pid)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Invite, {id = pid});
end

function GuildProxy.ReqAnsInvite(tid, opt)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_AnsInvite, {tid = tid, f = opt});
end

---------------------------[[response]]
-- 工会信息
function GuildProxy._RspGuildInfo(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.Update(data.tong, data.tm);
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_INFO, nil);
end
-- 敌对列表
function GuildProxy._RspEnemyList(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	local tmp = {};
	for i, v in ipairs(data.l) do
		local g = GuildInfo.New(v);
		insert(tmp, g);
	end
	GuildProxy.enemy = tmp;
	GuildDataManager.enemyNum = #tmp;
	GuildProxy.ReqGuildList(GuildProxy.tmpReqPage, true);
end
-- 工会列表
function GuildProxy._RspGuildList(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	local gs = {};
	
	local checkEnemy = false;
	local tmpEnemy = {};
	if GuildProxy.reqEnemy == true and GuildProxy.tmpReqPage == 1 then
		checkEnemy = true;
		for i, v in ipairs(GuildProxy.enemy) do
			tmpEnemy[v.id] = v;
			insert(gs, v);
		end
	end
	
	GuildDataManager.SetReqNum(data.am);
	
	for i, v in ipairs(data.tongs) do
		local g = GuildInfo.New(v);
		if checkEnemy == false or tmpEnemy[g.id] == nil then
			insert(gs, g);
		end
	end
	if GuildProxy.tmpReqPage > 1 and #gs == 0 then
		return;
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_LIST, {p = GuildProxy.tmpReqPage, d = gs});
end
-- 查找列表.
function GuildProxy._RspFind(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	local gs = {};
	for i, v in ipairs(data.tongs) do
		local g = GuildInfo.New(v);
		insert(gs, g);
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_FIND, gs);
end
-- 创建
function GuildProxy._RspCreate(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.Init(data.tong, data.tm);
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_CREATE, nil);
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_CHG);
end
-- 申请加入
function GuildProxy._RspJoin(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	if data.am then
		GuildDataManager.SetReqNum(data.am);
	end
	
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_JOIN, data.id);
end
--- 获取成员列表
function GuildProxy._RspGuildMember(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	local list = {};
	local iNum = {};
	for i, v in ipairs(data.l) do
		local m = GuildMemberInfo.New(v);
		list[i] = m;
		if iNum[m.identity] then
			iNum[m.identity] = iNum[m.identity] + 1;
		else
			iNum[m.identity] = 1;
		end
	end
	GuildDataManager.iNum = iNum;
	GuildDataManager.data.helpNum = data.thc or 0;
	GuildDataManager.reqVertifyNum = data.n or 0;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG);
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_MEMBERS, list);
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_REDPOINT, nil);
end
-- 获取审核列表
function GuildProxy._RspGuildVertifyList(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	local list = {};
	for i, v in ipairs(data.l) do
		list[i] = GuildMemberInfo.New();
		list[i]:InitWithReqMember(v);
	end
	GuildDataManager.reqVertifyNum = #data.l;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG);
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_VERTIFY_LIST, {list = list, autoVertify = data.ck == - 1});
end
-- 审核
function GuildProxy._RspGuildVertify(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		-- 出错时刷新审核列表.
		GuildProxy.ReqVertifyList();
		return;
	end
	GuildDataManager.reqVertifyNum = GuildDataManager.reqVertifyNum - 1;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG);
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_VERTIFY, data.id);
end
-- 一键拒绝
function GuildProxy._RspGuildVertifyAllRefuse(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.reqVertifyNum = 0;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG);
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_VERTIFY_REFUSEALL, nil);
end
-- 设置是否审核
function GuildProxy._RspGuildVertifySet(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	local b = data.t == - 1;
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_VERTIFY_SET, b);
end
-- 退出
function GuildProxy._RspGuildQuit(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.ExitGuild();
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_QUIT);
end
-- 解散
function GuildProxy._RspGuildDissolve(cmd, data)
	GuildDataManager.ExitGuild();
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_DISSOLVE);
end
-- 设置公告
function GuildProxy._RspGuildSetNotice(cmd, data)
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_NOTICE, data.n);
end
-- 设置敌视
function GuildProxy._RspSetEnemy(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.enemyNum = GuildDataManager.enemyNum + 1;
	local enemyTime = GetTime() + data.gt;
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_ENEMY_CHG, {id = data.id, t = enemyTime});
end
-- 取消敌视
function GuildProxy._RspCancelEnemy(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.enemyNum = GuildDataManager.enemyNum - 1;
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_ENEMY_CHG, {id = data.id, t = - 1});
end

-- 踢出工会
function GuildProxy._RspKick(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_KICK);
end

-- 职位调整
function GuildProxy._RspSetIdentity(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	local list = data.l;
	
	for i, v in ipairs(list) do
		if v.id == PlayerManager.playerId then
			GuildDataManager.info.identity = v.s;
		end
	end
	-- 转让.
	if #list > 1 then
		MsgUtils.ShowTips("guild/tips/transfer");
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_SET_IDENTITY);
end
-- 日志列表
function GuildProxy._RspLogList(cmd, data)
	local list = data.l;
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_LOGLIST, list);
end

function GuildProxy._RspActInfo(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.act = data;
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_ACTINFO);
end

-- 更新膜拜数据
function GuildProxy._RspGuildMoBaiNum(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_MOBAI_TASKNUM, data);
end

function GuildProxy._RspGuildInvite(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	MsgUtils.ShowTips("common/invite/suc");
end

-- 应答被邀请加入仙盟
function GuildProxy._RspGuildAnsInvite(cmd, data)
	
end

--[[ 通知类 ]]
function GuildProxy._RspNewReqJoin(cmd, data)
	GuildDataManager.reqVertifyNum = 1;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG);
end

-- 被 审核加入工会
function GuildProxy._RspInGuild(cmd, data)
	GuildDataManager.Init(data.tong, data.tm);
	MsgUtils.ShowTips("guild/joinGuild");
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_CHG);
end
-- 有人被踢出工会
function GuildProxy._RspOutGuild(cmd, data)
	if data and data.id == PlayerManager.playerId then
		MsgUtils.ShowTips("guild/tips/beKick");
		GuildDataManager.ExitGuild();
	else
		-- 有人被踢出工会, 人数减1.
		GuildDataManager.data.num = GuildDataManager.data.num - 1;
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_MEMBERS_CHG);
end
-- 有新成员加入
function GuildProxy._RspNewMember(cmd, data)
	-- 有人加入工会, 人数加1.
	GuildDataManager.data.num = GuildDataManager.data.num + 1;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_MEMBERS_CHG);
end
-- 被拒绝加入
function GuildProxy._RspBeRefuse(cmd, data)
	GuildDataManager.SetReqNum(data.am);
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_BEREFUSE, data.id);
end
-- 身份变了.
function GuildProxy._RspIdentityChg(cmd, data)
	local list = data.l;
	for i, v in ipairs(list) do
		if v.id == PlayerManager.playerId then
			GuildDataManager.info.identity = v.s;
			MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_IDENTITY_CHG);
		end
	end
end

function GuildProxy._RspLevelUp(cmd, data)
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_NTF_LEVELUP);
end

-- 后台通知我的信息发生改变.
function GuildProxy._RspUpdateMyGuildInfo(cmd, data)
	GuildDataManager.UpdateInfo(data);
end

-- 后台通知被邀请了.
function GuildProxy._RspBeInvite(cmd, data)
	GuildDataManager.OnBeInvite(data);
end

function GuildProxy._RspGuildInfoUpdate(cmd, data)
	GuildDataManager.UpdateGuildInfo(data);
end

-- 请求膜拜数据
function GuildProxy.ReqMoBaiInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_MoBaiInfo, nil);
end

function GuildProxy._RspMoBaiInfo(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_MOBAI_INFO, data);
end

function GuildProxy.Try_Get_TuoJi_ExpRes()
	SocketClientLua.Get_ins():SendMessage(CmdType.GUild_Get_TuoJi_Exp, nil);
end

function GuildProxy._GUild_Get_TuoJi_ExpRes(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
    MsgUtils.ShowTips("guild/info/tfecHasGet");


    GuildDataManager.Set_tfec(data.tfec);
end


-- 请求膜拜操作
function GuildProxy.ReqMoBaiOpt()
	
	
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_MoBaiOpt, nil);
end

function GuildProxy._RspMoBaiOpt(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_MOBAI_OPT, 1);
end

-- 请求膜拜激活次数
function GuildProxy.ReqMoBaiActive()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_MoBaiActive, nil);
end

function GuildProxy._RspMoBaiActive(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_MOBAI_ACTIVE, 1);
end

-- 领取膜拜任务次数
function GuildProxy.ReqTaskGetMoBaiNum()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Task_GetNum, nil);
end

function GuildProxy._RspTaskGetMoBaiNum(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_MOBAI_GETNUM, nil);
	TaskManager.OnUpdateTaskData(data);
end




function GuildProxy.ReqSendJoinNotice()
	-- SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Guild_Send_Join_Notice, GuildProxy._RspSendJoinNotice);
	local time = GetTime();
	local lastTime = 0;
	lastTime = Util.GetFloat("SendGuildJoinNotice_" .. PlayerManager.playerId, lastTime);
	-- log("当前时间:"..time);
	-- log("上次喊话时间:"..lastTime);
	if time - lastTime > 60 * 10 then
		SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Send_Join_Notice, nil);
		Util.SetFloat("SendGuildJoinNotice_" .. PlayerManager.playerId, time);
	else
		MsgUtils.ShowTips("guild/sendJoinNotice/cd");
	end
end

function GuildProxy._RspSendJoinNotice()
	-- SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Guild_Send_Join_Notice, GuildProxy._RspSendJoinNotice);
	-- if(data == nil or data.errCode ~= nil) then
	--    return;
	-- end
end

function GuildProxy.ReqAwardInfo()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetGuildAssignInfo, nil);
end

function GuildProxy._RspAwardInfo(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	local l = data.l;
	local t_num = 0;
	-- 因为 data.l 数量为 0  但还是有数据
	for key, value in pairs(l) do
		if value.num > 0 then
			t_num = t_num + 1;
		end
	end
	
	GuildDataManager.awardFpNum = t_num;
	GuildDataManager.awardMyNum = #data.l2;
	
	
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_AWARD_INFO, nil);
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_REDPOINT, nil);
	
end


function GuildProxy.ReqResearchSkill(type)
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Research_Skill, {t = type});
end

function GuildProxy._RspResearchSkill(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	if GuildDataManager.rSkill then
		for i, v in ipairs(data.skills) do
			if not table.contains(GuildDataManager.rSkill, v) then
				local cfg = GuildDataManager.GetSkillCfgById(v);
				MsgUtils.ShowTips("guild/skill/notify/2", cfg);
				break;
			end
		end
	end
	GuildDataManager.rSkill = data.skills;
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_GUILD_SKILL_CHG, nil);
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT);
end

function GuildProxy.ReqLearnSkill(type)
	
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Learn_Skill, {t = type});
end

function GuildProxy._RspLearnSkill(cmd, data)
	
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	if GuildDataManager.rSkill then
		for i, v in ipairs(data.skills) do
			if not table.contains(GuildDataManager.sSkill, v) then
				local cfg = GuildDataManager.GetSkillCfgById(v);
				MsgUtils.ShowTips("guild/skill/notify/1", cfg);
				break;
			end
		end
	end
	
	GuildDataManager.sSkill = data.skills;
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.GuideSkill)
	
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_GUILD_SKILL_CHG, nil);
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT);
end

-- 请求是否有工资可领
function GuildProxy.ReqGetSalaryStatus()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Get_Salary_Status, nil);
end

function GuildProxy._RspGetSalaryStatus(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	GuildDataManager.canGetSalary = #data.l > 0;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT, nil);
end

function GuildProxy.ReqGetSalary()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.Guild_Get_Salary, nil);
end

function GuildProxy._RspGetSalary(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	if #data.l == 0 then
		MsgUtils.ShowTips("guild/salary/no");
	end
	GuildDataManager.canGetSalary = false;
	MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT, nil);
end

-- 红包通知
function GuildProxy._RspHongBaoNotify(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildDataManager.SetHongBaoRedPoint(true)
	
	if(data.t == 1) then
		ModuleManager.SendNotification(GuildNotes.OPEN_GUILDHONGBAONOTIFYPANEL, {rpid = data.rpid})
	end
end

-- 获取红包数据
function GuildProxy.ReqGetGuildHongBaoData()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetGuildHongBaoData, nil);
end

function GuildProxy._RspGetGuildHongBaoData(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	
	local check = false
	
	if(data.ml) then
		for k, v in ipairs(data.ml) do
			if(v.st == 0) or(v.st == 1 and v.f == 0) then
				check = true			
				break
			end
		end
	end
	
	if(check == false) then
		if(data.tl) then	
			for k, v in ipairs(data.tl) do
				if(v.st == 1 and v.f == 0) then
					check = true				
					break
				end
			end
		end
	end
	--可打开——可发放——已领取(未领完)
	table.sort(data.ml, function(a, b)		
		if(a.f == b.f and a.st == b.st) then
			return a.rptid > b.rptid
		end
		
		if(a.f > b.f) then
			return false
		end
		
		if(a.f < b.f) then
			return true
		end		
		return a.st > b.st	
	end)
	GuildDataManager.SetHongBaoRedPoint(check)
	MessageManager.Dispatch(GuildNotes, GuildNotes.RSP_GUILD_HONGBAO_DATA, data);
end

-- 发红包
function GuildProxy.ReqSendHongBao(id, num)
	
	SocketClientLua.Get_ins():SendMessage(CmdType.SendHongBao, {rpid = id, num = num});
end

function GuildProxy._RspSendHongBao(cmd, data)
	
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	GuildProxy.ReqGetGuildHongBaoData()
end


-- 收、看红包
function GuildProxy.ReqShowHongBao(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.ShowHongBao, {rpid = id});
end

function GuildProxy._RspShowHongBao(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		return;
	end
	if(data.op == 1) then
		GuildProxy.ReqGetGuildHongBaoData();
	end
	ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDHONGBAONOTIFYPANEL);
	ModuleManager.SendNotification(GuildNotes.OPEN_GUILDHONGBAOINFOPANEL, data);
end 