module(..., package.seeall)

--GS2C--

function GS2COpenArena(pbdata)
	local arena_point = pbdata.arena_point --比武积分
	local weeky_medal = pbdata.weeky_medal --本周已获得的荣誉数
	local rank_info = pbdata.rank_info --排行榜前20名信息（排名，头像，名字，积分）
	local rank = pbdata.rank --玩家当前排名
	local open_watch = pbdata.open_watch --0true为开启观战，false为关闭观战
	--todo
	g_ArenaCtrl:OnShowArena(arena_point, weeky_medal, rank_info, rank, open_watch)
end

function GS2CArenaReplay(pbdata)
	--todo
end

function GS2CArenaHistory(pbdata)
	local history_info = pbdata.history_info --72小时内战斗记录，最多30场
	local history_onshow = pbdata.history_onshow --玩家当前展示的战斗记录，1场
	--todo
	g_ArenaCtrl:OnReceiveArenaHistory(history_info, history_onshow)
end

function GS2CArenaSetShowing(pbdata)
	local fid = pbdata.fid --展示的战斗数据的id
	--todo
	g_ArenaCtrl:OnReceiveSetShowing(fid)
end

function GS2CArenaOpenWatch(pbdata)
	local grade_record_info = pbdata.grade_record_info --4个段位的对战记录
	--todo
	g_ArenaCtrl:OnReceiveWatch(grade_record_info)
end

function GS2CArenaLeftTime(pbdata)
	local left = pbdata.left --剩余时间
	--todo
	g_ArenaCtrl:OnReceiveLeftTime(left)
end

function GS2CShowArenaWarConfig(pbdata)
	local plist = pbdata.plist
	--todo
	g_ArenaCtrl:ShowWarStartView(plist)
end

function GS2CArenaStartMath(pbdata)
	local result = pbdata.result --1匹配,0 关闭匹配
	--todo
	g_ArenaCtrl:OnReceiveMatchResult(result)
end

function GS2CArenaMatch(pbdata)
	local rankInfo = pbdata.rankInfo --对战玩家信息(名字，头像，积分)
	--todo
	g_ArenaCtrl:OnReceiveMatchPlayer(rankInfo)
end

function GS2CArenaFight(pbdata)
	--todo
end

function GS2CArenaFightResult(pbdata)
	local point = pbdata.point --获得的积分
	local medal = pbdata.medal --获得的荣誉
	local result = pbdata.result --胜利阵营 1,2
	local currentpoint = pbdata.currentpoint --当前总积分
	local weeky_medal = pbdata.weeky_medal --本周已获得的荣誉数
	local info = pbdata.info
	--todo
	g_ArenaCtrl:OnReceiveFightResult(point, medal, result, currentpoint, weeky_medal, info)
end

function GS2COpenEqualArena(pbdata)
	local arena_point = pbdata.arena_point --比武积分
	local weeky_medal = pbdata.weeky_medal --本周已获得的荣誉数
	local parid = pbdata.parid --出战伙伴配置
	local open_watch = pbdata.open_watch --开启观战
	--todo
	g_EqualArenaCtrl:OnShowArena(arena_point, weeky_medal, open_watch, parid)
end

function GS2CSetEqualArenaParner(pbdata)
	local partner = pbdata.partner
	--todo
	g_EqualArenaCtrl:OnChangePartner(partner)
end

function GS2CEqualArenaStartMath(pbdata)
	local result = pbdata.result --1匹配,0 关闭匹配
	--todo
	g_EqualArenaCtrl:OnReceiveMatchResult(result)
end

function GS2CEqualArenaMatch(pbdata)
	local rankInfo = pbdata.rankInfo --对战玩家信息(名字，头像，积分)
	--todo
	g_EqualArenaCtrl:OnReceiveMatchPlayer(rankInfo)
end

function GS2CCloseEqualArenaUI(pbdata)
	--todo
	g_EqualArenaCtrl:OnEvent(define.EqualArena.Event.OnCloseEqualArenaUI)
end

function GS2CSelectEqualArena(pbdata)
	local info = pbdata.info --玩家信息
	local fuwen = pbdata.fuwen --提供的符文
	local partner = pbdata.partner --提供的的伙伴
	local operater = pbdata.operater --本轮操作者
	local limit_partner = pbdata.limit_partner --选择伙伴数量
	local limit_fuwen = pbdata.limit_fuwen --选择符文数量
	local left_time = pbdata.left_time --剩余时间
	--todo
	g_EqualArenaCtrl:OnSelectSection(info, fuwen, partner, operater, limit_partner, limit_fuwen, left_time)
end

function GS2CSyncSelectInfo(pbdata)
	local operater = pbdata.operater
	local select_type = pbdata.select_type --1，伙伴2，符文
	local index = pbdata.index --处理的伙伴/符文序号
	local handle_type = pbdata.handle_type --1.选中 2.取消选中
	--todo
	g_EqualArenaCtrl:OnSetSelecting(operater, select_type, index, handle_type)
end

function GS2CSyncConfig(pbdata)
	local select_par = pbdata.select_par --伙伴顺序编号 1,2,3 对应select_item的1,2,3
	local select_item = pbdata.select_item --符文顺序编号
	--todo
	g_EqualArenaCtrl:OnCombineSubmit(select_par, select_item)
end

function GS2CConfigEqualArena(pbdata)
	local pinfo = pbdata.pinfo
	local left_time = pbdata.left_time
	--todo
	g_EqualArenaCtrl:OnCombineStart(pinfo, left_time)
end

function GS2CEqualArenaConfigDone(pbdata)
	local pid = pbdata.pid
	--todo
	g_EqualArenaCtrl:OnCombineDone(pid)
end

function GS2CEqualArenaFight(pbdata)
	--todo
end

function GS2CShowEqualArenaWarConfig(pbdata)
	local plist = pbdata.plist
	--todo
	g_EqualArenaCtrl:ShowWarStartView(plist)
end

function GS2CEqualArenaFightResult(pbdata)
	local point = pbdata.point --获得的积分
	local medal = pbdata.medal --获得的荣誉
	local result = pbdata.result --//胜利阵营 1,2
	local currentpoint = pbdata.currentpoint --当前总积分
	local weeky_medal = pbdata.weeky_medal --本周已获得的荣誉数
	local info = pbdata.info
	--todo
	g_EqualArenaCtrl:OnReceiveFightResult(point, medal, result, currentpoint, weeky_medal, info)
end

function GS2CEqualArenaLeftTime(pbdata)
	local left = pbdata.left --剩余时间
	--todo
	g_EqualArenaCtrl:OnReceiveLeftTime(left)
end

function GS2CEqualArenaHistory(pbdata)
	local history_info = pbdata.history_info --72小时内战斗记录，最多30场
	local history_onshow = pbdata.history_onshow --玩家当前展示的战斗记录，1场
	--todo
	g_EqualArenaCtrl:OnReceiveArenaHistory(history_info, history_onshow)
end

function GS2CEqaulArenaSetShowing(pbdata)
	local fid = pbdata.fid --展示的战斗数据的id
	--todo
	g_EqualArenaCtrl:OnReceiveSetShowing(fid)
end

function GS2CEqualArenaOpenWatch(pbdata)
	local grade_record_info = pbdata.grade_record_info --4个段位的对战记录
	--todo
	g_EqualArenaCtrl:OnReceiveWatch(grade_record_info)
end

function GS2CEqualArenaStartWarFail(pbdata)
	local msg = pbdata.msg
	--todo
	g_NotifyCtrl:FloatMsg(msg)
	local oView = CEqualArenaPrepareView:GetView()
	if oView then
		oView:CloseView()
	end
end

function GS2CTeamPVPStartMath(pbdata)
	local result = pbdata.result --1匹配,0 关闭匹配
	local start_time = pbdata.start_time --开始匹配的时间
	--todo
	g_TeamPvpCtrl:OnReceiveStartMatch(result, startTime)
end

function GS2CTeamPVPMatch(pbdata)
	local info1 = pbdata.info1
	local info2 = pbdata.info2
	--todo
	g_TeamPvpCtrl:OnReceiveMatchInfo(info1, info2)
end

function GS2CTeamPVPSceneInfo(pbdata)
	local player = pbdata.player --队伍信息
	--todo
	g_TeamPvpCtrl:UpdataTeamData(player)
end

function GS2CLeaveTeamPVPScene(pbdata)
	--todo
	g_TeamPvpCtrl:LeaveScene()
end

function GS2CTeamPVPRank(pbdata)
	local rank = pbdata.rank --排行信息
	local myscore = pbdata.myscore --我的积分
	local mywin = pbdata.mywin --我的胜利次数
	local myfail = pbdata.myfail --我的失败次数
	local myrank = pbdata.myrank
	--todo
	local playerRankData = {
		score = myscore,
		win = mywin,
		fail = myfail,
		rank = myrank,
	}
	g_TeamPvpCtrl:UpdataRankData(rank, playerRankData)
end

function GS2CShowTeamPVPWarConfig(pbdata)
	local plist1 = pbdata.plist1
	local plist2 = pbdata.plist2
	--todo
	g_TeamPvpCtrl:ShowWarStartView(plist1, plist2)
end

function GS2CTeamPVPFightResult(pbdata)
	local point = pbdata.point --获得的积分
	local result = pbdata.result --胜利阵营 1,2
	local currentpoint = pbdata.currentpoint --当前总积分
	local info1 = pbdata.info1
	local info2 = pbdata.info2
	--todo
	g_TeamPvpCtrl:OnReceiveFightResult(point, result, currentpoint, info1, info2)
end

function GS2CShowTeamPVPInvite(pbdata)
	local plist = pbdata.plist
	--todo
	g_TeamPvpCtrl:OnReveiceInviteList(plist)
end

function GS2CRefreshTeamArenaLeftTime(pbdata)
	local start_time = pbdata.start_time
	local end_time = pbdata.end_time
	--todo
	g_TeamPvpCtrl:RefreshLeftTime(start_time, end_time)
end

function GS2CClubArenaMainUI(pbdata)
	local club = pbdata.club --所属武馆
	local cd_fight = pbdata.cd_fight --挑战冷却时间
	local coin_reward = pbdata.coin_reward --每次发放奖励数量金币
	local gold_reward = pbdata.gold_reward --累计奖励
	local max_times = pbdata.max_times --最大挑战次数
	local use_times = pbdata.use_times --已用次数
	local master = pbdata.master --#白银-王者
	--todo
	g_ClubArenaCtrl:OnShowArena(club, cd_fight, coin_reward, gold_reward, max_times, use_times, master)
end

function GS2CClubArenaInfo(pbdata)
	local club = pbdata.club
	local power = pbdata.power
	local enemy = pbdata.enemy --对手信息
	local master = pbdata.master --馆主
	local win = pbdata.win --胜利次数
	--todo
	g_ClubArenaCtrl:ReceiveClubArenaInfo(club, power, enemy, master, win)
end

function GS2CClubArenaDefenseLineUp(pbdata)
	local parlist = pbdata.parlist --伙伴ID 对应的位置1-4
	--todo
	g_ClubArenaCtrl:ReceiveDefenseLineUp(parlist)
end

function GS2CClubArenaHistory(pbdata)
	local info = pbdata.info
	--todo
	g_ClubArenaCtrl:OnReceiveArenaHistory(info)
end

function GS2CShowClubArenaWarConfig(pbdata)
	local plist = pbdata.plist
	--todo
	g_ClubArenaCtrl:ShowWarStartView(plist)
end

function GS2CClubArenaFightResult(pbdata)
	local medal = pbdata.medal --获得的荣誉
	local result = pbdata.result --胜利阵营 1,2
	local info1 = pbdata.info1
	local info2 = pbdata.info2
	--todo
	g_ClubArenaCtrl:OnReceiveFightResult(medal, result, info1, info2)
end


--C2GS--

function C2GSOpenArena()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSOpenArena", t)
end

function C2GSArenaMatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSArenaMatch", t)
end

function C2GSArenaCancelMatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSArenaCancelMatch", t)
end

function C2GSArenaDetailRank()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSArenaDetailRank", t)
end

function C2GSArenaReplayByPlayerId(id, iView)
	local t = {
		id = id,
		iView = iView,
	}
	g_NetCtrl:Send("arena", "C2GSArenaReplayByPlayerId", t)
end

function C2GSArenaPraise(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("arena", "C2GSArenaPraise", t)
end

function C2GSArenaHistory()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSArenaHistory", t)
end

function C2GSArenaSetShowing(fid)
	local t = {
		fid = fid,
	}
	g_NetCtrl:Send("arena", "C2GSArenaSetShowing", t)
end

function C2GSArenaReplayByRecordId(fid, view)
	local t = {
		fid = fid,
		view = view,
	}
	g_NetCtrl:Send("arena", "C2GSArenaReplayByRecordId", t)
end

function C2GSArenaOpenWatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSArenaOpenWatch", t)
end

function C2GSOpenEqualArena()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSOpenEqualArena", t)
end

function C2GSSetEqualArenaPartner(partner)
	local t = {
		partner = partner,
	}
	g_NetCtrl:Send("arena", "C2GSSetEqualArenaPartner", t)
end

function C2GSEqualArenaMatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSEqualArenaMatch", t)
end

function C2GSEqualArenaCancelMatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSEqualArenaCancelMatch", t)
end

function C2GSSyncSelectInfo(select_type, index, handle_type)
	local t = {
		select_type = select_type,
		index = index,
		handle_type = handle_type,
	}
	g_NetCtrl:Send("arena", "C2GSSyncSelectInfo", t)
end

function C2GSSelectEqualArena(select_par, select_item)
	local t = {
		select_par = select_par,
		select_item = select_item,
	}
	g_NetCtrl:Send("arena", "C2GSSelectEqualArena", t)
end

function C2GSConfigEqualArena(select_par, select_item, handle_type)
	local t = {
		select_par = select_par,
		select_item = select_item,
		handle_type = handle_type,
	}
	g_NetCtrl:Send("arena", "C2GSConfigEqualArena", t)
end

function C2GSEqualArenaHistory()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSEqualArenaHistory", t)
end

function C2GSEqualArenaSetShowing(fid)
	local t = {
		fid = fid,
	}
	g_NetCtrl:Send("arena", "C2GSEqualArenaSetShowing", t)
end

function C2GSEqualArenaOpenWatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSEqualArenaOpenWatch", t)
end

function C2GSGuaidArenaWar()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSGuaidArenaWar", t)
end

function C2GSTeamPVPMatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSTeamPVPMatch", t)
end

function C2GSTeamPVPCancelMatch()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSTeamPVPCancelMatch", t)
end

function C2GSOpenTeamPVPRank()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSOpenTeamPVPRank", t)
end

function C2GSGetTeamPVPInviteList(exculelist)
	local t = {
		exculelist = exculelist,
	}
	g_NetCtrl:Send("arena", "C2GSGetTeamPVPInviteList", t)
end

function C2GSTeamPVPToInviteList(plist)
	local t = {
		plist = plist,
	}
	g_NetCtrl:Send("arena", "C2GSTeamPVPToInviteList", t)
end

function C2GSTeamPVPLeaveScene()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSTeamPVPLeaveScene", t)
end

function C2GSTeamPVPLeader(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("arena", "C2GSTeamPVPLeader", t)
end

function C2GSTeamPVPLeave()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSTeamPVPLeave", t)
end

function C2GSTeamPVPKickout(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("arena", "C2GSTeamPVPKickout", t)
end

function C2GSOpenClubArenaMain()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSOpenClubArenaMain", t)
end

function C2GSOpenClubArenaInfo(club)
	local t = {
		club = club,
	}
	g_NetCtrl:Send("arena", "C2GSOpenClubArenaInfo", t)
end

function C2GSClubArenaFight(club, post, pid)
	local t = {
		club = club,
		post = post,
		pid = pid,
	}
	g_NetCtrl:Send("arena", "C2GSClubArenaFight", t)
end

function C2GSResetClubArena(club)
	local t = {
		club = club,
	}
	g_NetCtrl:Send("arena", "C2GSResetClubArena", t)
end

function C2GSClubArenaAddFightCnt()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSClubArenaAddFightCnt", t)
end

function C2GSSaveClubArenaLineup(parlist)
	local t = {
		parlist = parlist,
	}
	g_NetCtrl:Send("arena", "C2GSSaveClubArenaLineup", t)
end

function C2GSShowClubArenaHistory()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSShowClubArenaHistory", t)
end

function C2GSOpenClubArenaDefense()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSOpenClubArenaDefense", t)
end

function C2GSCleanClubArenaCD()
	local t = {
	}
	g_NetCtrl:Send("arena", "C2GSCleanClubArenaCD", t)
end

