module(..., package.seeall)

--GS2C--

function GS2CNotifyQuestion(pbdata)
	local type = pbdata.type --1-随机,2-积分,3-学霸
	local status = pbdata.status --1-准备,2-正在,3-结束
	local desc = pbdata.desc --提示描述
	local end_time = pbdata.end_time --提示结束时间戳
	local server_time = pbdata.server_time --服务器当前时间戳
	--todo
	g_TimeCtrl:SyncServerTime(server_time)
	if type == 3 then
		g_SceneExamCtrl:NotifyQuestion(pbdata)
	else
		local oCtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
		oCtrl:NotifyQuestion(pbdata)
	end
end

function GS2CQuestionInfo(pbdata)
	local id = pbdata.id --id
	local type = pbdata.type --1-随机,2-积分,3-学霸
	local desc = pbdata.desc --问题描述
	local end_time = pbdata.end_time --结束时间戳
	local base_reward = pbdata.base_reward --基础奖励
	local answer_list = pbdata.answer_list --答案列表
	local server_time = pbdata.server_time --服务器当前时间戳
	--todo
	g_TimeCtrl:SyncServerTime(server_time)
	if type == 3 then
		g_SceneExamCtrl:AddQuestionInfo(pbdata)
	else
		local oCtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
		oCtrl:AddQuestionInfo(pbdata)
	end
end

function GS2CAnswerResult(pbdata)
	local id = pbdata.id --题目id
	local type = pbdata.type --1-随机,2-积分
	local result = pbdata.result --0-错误,1-正确
	local answer = pbdata.answer --题目选项
	local reward = pbdata.reward --获得奖励
	local time = pbdata.time --回答时间
	local extra_info = pbdata.extra_info --额外信息
	local role = pbdata.role --玩家信息
	--todo
	if type == 3 then
		g_SceneExamCtrl:AnswerResult(pbdata)
	else
		local oCtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
		oCtrl:AnswerResult(pbdata)
	end
end

function GS2CScoreRankInfoList(pbdata)
	local id = pbdata.id --所在分组id
	local score_list = pbdata.score_list --积分信息
	local type = pbdata.type --1-随机,2-积分,3-学霸
	--todo
	if type == 3 then
		g_SceneExamCtrl:SetRankList(id, score_list)
	else
		local oCtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
		oCtrl:SetSARankList(id, score_list)
	end
end

function GS2CScoreInfoChange(pbdata)
	local id = pbdata.id --分组id
	local score_info = pbdata.score_info --积分信息
	local type = pbdata.type --1-随机,2-积分,3-学霸
	--todo
	local oCtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
	oCtrl:UpdateSARankList(id, score_info)
end

function GS2CQuestionEndReward(pbdata)
	local status = pbdata.status --0-未领取，1-已领取
	--todo
	local oCtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
	oCtrl:SetSAReward(status)
end

function GS2CSceneAnswerList(pbdata)
	local results = pbdata.results
	--todo
	g_SceneExamCtrl:AddResult(results)
end

function GS2CQtionSceneStatus(pbdata)
	local status = pbdata.status --0-离开，1-进入
	--todo
	g_SceneExamCtrl:SetOpen(status)
end

function GS2CHuoDongStatus(pbdata)
	local hd_id = pbdata.hd_id --活动ID boss=1001
	local status = pbdata.status --状态 1:开启,0关闭
	--todo
	g_ActivityCtrl:SetOpen(hd_id, status==1)
end

function GS2CBossMain(pbdata)
	local hp_max = pbdata.hp_max
	local hp = pbdata.hp
	local state = pbdata.state --活动状态 1,在开始,0,活动结束
	local ranklist = pbdata.ranklist
	local myrank = pbdata.myrank --自己的排名信息
	local rank = pbdata.rank --自己排名
	local daycnt = pbdata.daycnt
	local lefttime = pbdata.lefttime --剩余时间-秒
	local bosshape = pbdata.bosshape --次元妖兽造型
	local killer = pbdata.killer --击杀者名字
	local skill_list = pbdata.skill_list --BOSS
	local bigboss = pbdata.bigboss --1-bigboss
	--todo
	g_ActivityCtrl:SetWorldBossShape(bosshape)
	g_ActivityCtrl:RefreshBossHP(hp, hp_max)
	g_ActivityCtrl:SetWorldBossBigboss(bigboss)
	local dMyRank = {rank = rank}
	table.update(dMyRank, myrank)
	local lRank = {}
	for i, v in ipairs(ranklist) do
		local dData = table.copy(v)
		table.insert(lRank, dData)
	end
	g_ActivityCtrl:SetWorldBossRank(lRank, dMyRank)
	local oView = CWorldBossView:GetView()
	if oView then
		oView:SetBoss(bosshape, state, bigboss)
		oView:SetKillerName(killer)
		oView:SetTime(lefttime)
	else
		CWorldBossView:ShowView(function(oView)
			oView:SetBoss(bosshape, state, bigboss)
			oView:SetRankData(lRank, dMyRank)
			oView:SetKillerName(killer)
			oView:SetTime(lefttime)
		end)
	end
end

function GS2CBossHPNotify(pbdata)
	local hp_max = pbdata.hp_max
	local hp = pbdata.hp
	--todo

	local info = g_ActivityCtrl:GetWolrdBossInfo()
	g_ActivityCtrl:RefreshBossHP(hp, hp_max)
end

function GS2CBossWarEnd(pbdata)
	local hit = pbdata.hit --本次伤害
	local all_hit = pbdata.all_hit --今天总伤害
	local hit_per = pbdata.hit_per --伤害百分比 x/100=整数,x%100 = 小数点
	local rank = pbdata.rank
	local gold = pbdata.gold
	--todo
	local per =hit_per/100
	--local sText = string.format("本次讨伐造成伤害:%d\r\n今日讨伐总伤害:%d 相当于boss血量:%d%%\r\n当前伤害排名:%d", hit, all_hit, per, rank)
	local lContent = {
		[1] = string.format("本次讨伐造成伤害:%d", hit),
		[2] = string.format("今日讨伐总伤害:%d", all_hit),
		[3] = string.format("相当于boss血量:%d%%", per),
		[4] = string.format("当前伤害排名:%d", rank),
	}
	g_WarCtrl:SetResultValue("content", lContent)
	g_WarCtrl:SetResultValue("bosscoin", gold)
end

function GS2CWorldBossLeftTime(pbdata)
	local left = pbdata.left
	--todo
	g_ActivityCtrl:OnWolrdBossLeftTime(left)
end

function GS2CInWorldBossScene(pbdata)
	--todo
	g_ActivityCtrl:SetInWorldBossFB(true)
end

function GS2CLeaveWorldBossScene(pbdata)
	--todo
	g_ActivityCtrl:SetInWorldBossFB(false)
end

function GS2CWorldBossRank(pbdata)
	local ranklist = pbdata.ranklist
	local myrank = pbdata.myrank --自己的排名信息
	local dead_cost = pbdata.dead_cost
	--todo
	local dMyRank = {rank = rank}
	table.update(dMyRank, myrank)
	local lRank = {}
	for i, v in ipairs(ranklist) do
		local dData = table.copy(v)
		table.insert(lRank, dData)
	end
	g_ActivityCtrl:SetWorldBossRank(lRank, dMyRank, dead_cost)
end

function GS2CWorldBossDeath(pbdata)
	local boss_npc = pbdata.boss_npc --npc_type
	--todo
	g_ActivityCtrl:WorldBossDeathAnim(boss_npc)
end

function GS2CPataUIInfo(pbdata)
	local curlv = pbdata.curlv --玩家当前层数
	local maxlv = pbdata.maxlv --玩家历史到达最高层数
	local info = pbdata.info --好友信息
	local restcnt = pbdata.restcnt --剩余重置次数
	local tglist = pbdata.tglist --已领取的首通奖励
	--todo
	g_PataCtrl:CtrlGS2CPataUIInfo(curlv, maxlv, info, restcnt, tglist)
end

function GS2CPataInviteInfo(pbdata)
	local cnt = pbdata.cnt --玩家当前可邀请次数
	local frdlist = pbdata.frdlist --玩家好友邀请信息
	--todo
	g_PataCtrl:CtrlGS2CPataInviteInfo(cnt, frdlist)
end

function GS2CPataFrdPtnInfo(pbdata)
	local target = pbdata.target
	local partlist = pbdata.partlist
	--todo
	g_PataCtrl:CtrlGS2CPataFrdPtnInfo(target, partlist)
end

function GS2CPataRwItemUI(pbdata)
	local itemlist = pbdata.itemlist --道具奖励列表
	local curlv = pbdata.curlv --当前层数
	--todo
	g_PataCtrl:CtrlGS2CPataRwItemUI(curlv, itemlist)
end

function GS2CPataWarUI(pbdata)
	local iWin = pbdata.iWin --胜利与否
	local itemlist = pbdata.itemlist --道具奖励
	local curlv = pbdata.curlv --玩家当前层数
	local invitecnt = pbdata.invitecnt --邀请次数
	--todo
	g_PataCtrl:CtrlGS2CPataWarUI(iWin, itemlist, curlv, invitecnt)
end

function GS2CSweepInfo(pbdata)
	local infos = pbdata.infos
	local begintime = pbdata.begintime --开始时间
	--todo
	g_PataCtrl:CtrlGS2CSweepInfo(begintime, infos)
end

function GS2CSweepLevel(pbdata)
	local endlv = pbdata.endlv --到达层数
	--todo
	g_PataCtrl:CtrlGS2CSweepLevel(endlv)
end

function GS2CTgRewardResult(pbdata)
	local level = pbdata.level --领取了哪一层
	--todo
	g_PataCtrl:CtrlGS2CTgRewardResult(level)
end

function GS2CEndlessFightList(pbdata)
	local fight_list = pbdata.fight_list --列表
	--todo
	g_EndlessPVECtrl:OnReceiveChipList(fight_list)
end

function GS2CWarRingInfo(pbdata)
	local ring = pbdata.ring --第几波
	local end_time = pbdata.end_time --结束的时间戳
	--todo
	g_EndlessPVECtrl:OnReceiveWarRingInfo(ring, end_time)
end

function GS2CEndlessWarEnd(pbdata)
	local pass_ring = pbdata.pass_ring --通过波数
	--todo
	g_EndlessPVECtrl:WarEnd(pass_ring)
end

function GS2COpenEquipFubenMain(pbdata)
	local brief = pbdata.brief
	local remain = pbdata.remain --剩余次数
	--todo
	g_EquipFubenCtrl:CtrlGS2COpenEquipFubenMain(brief, remain)
end

function GS2COpenEquiFuben(pbdata)
	local brief = pbdata.brief
	local floor = pbdata.floor --只发已通过的层数列表,未通过不发
	local max_floor = pbdata.max_floor
	local remain = pbdata.remain --剩余次数
	--todo
	g_EquipFubenCtrl:CtrlGS2COpenEquiFuben(brief, floor, max_floor, remain)
end

function GS2CRefreshEquipFBfloor(pbdata)
	local brief = pbdata.brief
	local floor = pbdata.floor
	--todo
end

function GS2CRefreshEquipFBScene(pbdata)
	local mask = pbdata.mask
	local floor = pbdata.floor --楼层
	local time = pbdata.time --剩余时间(秒)
	local auto = pbdata.auto --是否自动战斗
	local scene_id = pbdata.scene_id --场景ID
	local estimate = pbdata.estimate --评价 0x1-通关, 0x2 - 无死亡 0x4-没超时 estimate =  通关|死亡|超时
	local nid_list = pbdata.nid_list --npc_id_list
	local count = pbdata.count
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(pbdata, "equipFbInfo")
	table.print(dDecode)
	g_EquipFubenCtrl:CtrlGS2CRefreshEquipFBScene(dDecode.floor, dDecode.time,
	 dDecode.auto, dDecode.scene_id, dDecode.estimate, dDecode.nid_list, dDecode.count)
end

function GS2CEquipFBWarResult(pbdata)
	local star = pbdata.star
	local sum_star = pbdata.sum_star
	local estimate = pbdata.estimate --评价 0x1-通关, 0x2 - 无死亡 0x4-没超时 estimate =  通关|死亡|超时
	local item = pbdata.item --奖励道具
	local use_time = pbdata.use_time
	local floor = pbdata.floor
	--todo
	g_EquipFubenCtrl:CtrlGS2CEquipFBWarResult(star, sum_star, estimate, item, use_time, floor)
end

function GS2CEndFBScene(pbdata)
	--todo
	g_EquipFubenCtrl:CtrlGS2CEndFBScene()
end

function GS2CSweepEquipFBResult(pbdata)
	local sweep = pbdata.sweep
	--todo
	g_EquipFubenCtrl:CtrlGS2CSweepEquipFBResult(sweep)
end

function GS2CShowNormalReward(pbdata)
	local rewardinfo = pbdata.rewardinfo
	local times = pbdata.times
	local sessionidx = pbdata.sessionidx
	--todo
	g_TreasureCtrl:OpenTreasureNormalView(rewardinfo, times, sessionidx)
end

function GS2CRemoveHuodongNpc(pbdata)
	local npcid = pbdata.npcid
	local flag = pbdata.flag --0-其他，1-暗雷
	--todo
	if flag == 1 then
		g_AnLeiCtrl:CtrlGS2CRemoveHuodongNpc(npcid)
	else
		g_TreasureCtrl:RemoveHuodongNpc(npcid)
		g_DialogueCtrl:CloseView()	
	end	
end

function GS2CCreateHuodongNpc(pbdata)
	local npcinfo = pbdata.npcinfo
	--todo
	local flag = 0
	if npcinfo then 
		flag = npcinfo.flag or 0
	end
	--暗雷怪稀有怪
	printc(" flag  ", flag)
	if flag == 1 then
		g_AnLeiCtrl:CtrlGS2CCreateHuodongNpc(npcinfo)
	else
		g_TreasureCtrl:CreateHuodongNpc(npcinfo)
	end
end

function GS2CHuntInfo(pbdata)
	local freeinfo = pbdata.freeinfo
	local npcinfo = pbdata.npcinfo
	local soulinfo = pbdata.soulinfo
	--todo
	g_HuntPartnerSoulCtrl:UpdateHuntInfo(pbdata)
end

function GS2CLoginHuodongInfo(pbdata)
	local npcinfo = pbdata.npcinfo
	local convoyinfo = pbdata.convoyinfo
	local dailytrain = pbdata.dailytrain
	local huntinfo = pbdata.huntinfo
	local hireinfo = pbdata.hireinfo
	--todo
	local npcList1 = {}
	local npcList2 = {}
	for i = 1, #npcinfo do
		local npc = npcinfo[i]
		if npc.flag == 1 then
			table.insert(npcList1, npc)
		else
			table.insert(npcList2, npc)
		end
	end
	--g_AnLeiCtrl:LoginHuodongInfo(npcList1)
	g_TreasureCtrl:LoginHuodongInfo(npcList2)
	g_ConvoyCtrl:UpdateConvoyInfo(convoyinfo)
	g_ActivityCtrl:LoginHuodongInfo(dailytrain)
	g_HuntPartnerSoulCtrl:UpdateHuntInfo(huntinfo)
	g_PartnerCtrl:InitHireData(hireinfo)
end

function GS2CUpdateConvoyInfo(pbdata)
	local convoyinfo = pbdata.convoyinfo
	--todo
	g_ConvoyCtrl:UpdateConvoyInfo(convoyinfo)
end

function GS2CShowConvoyMainUI(pbdata)
	local convoyinfo = pbdata.convoyinfo
	--todo
	g_ConvoyCtrl:UpdateConvoyInfo(convoyinfo)
	if g_ConvoyCtrl:IsConvoying() then
		g_NotifyCtrl:FloatMsg("请先完成当前护送任务")
	else
		CConvoyView:ShowView()
	end
end

function GS2CTreasureNormalResult(pbdata)
	local idx = pbdata.idx
	local type = pbdata.type
	--todo
	g_TreasureCtrl:SetTreasureResult(idx, type)
end

function GS2CShowPlayBoyWnd(pbdata)
	local createtime = pbdata.createtime
	local rewardinfo = pbdata.rewardinfo
	local haschangepos = pbdata.haschangepos
	local dialog = pbdata.dialog
	local cost = pbdata.cost
	local sessionidx = pbdata.sessionidx
	--todo
	g_TreasureCtrl:OpenTreasurePlayBoyView(createtime, rewardinfo, haschangepos, dialog, cost, sessionidx)
end

function GS2CShowCaiQuanWnd(pbdata)
	local sessionidx = pbdata.sessionidx
	local npcid = pbdata.npcid
	local record = pbdata.record
	--todo
	g_TreasureCtrl:OpenTreasureCaiQuanView(sessionidx, pbdata.record)
end

function GS2CGetLegendTeam(pbdata)
	--todo
	g_TeamCtrl:AutoCreatAndMatch(define.Team.TaskID.ChuanShuoHuoBan)
end

function GS2CShowCaiQuanResult(pbdata)
	local syschoice = pbdata.syschoice --1-剪刀  2-石头 3-布
	local result = pbdata.result --1-赢 0-输 2-平局
	local sessionidx = pbdata.sessionidx
	--todo
	g_TreasureCtrl:SetCaiQuanResult(syschoice, result, sessionidx)
end

function GS2CNpcBeenDefeate(pbdata)
	local npcid = pbdata.npcid
	--todo
	CTreasureCaiQuanView:CloseView()
	g_NotifyCtrl:FloatMsg("这个幻象已经被打败了")
end

function GS2CCaiQuanGameEnd(pbdata)
	local result = pbdata.result
	--todo
	g_TreasureCtrl:CaiQuanGameEnd(result)
end

function GS2CMainPEFuben(pbdata)
	local fb_id = pbdata.fb_id --副本类型
	local open_floor = pbdata.open_floor --通关最大层数(0-10)
	local select_part = pbdata.select_part --选中部位
	local select_equip = pbdata.select_equip --选中符文
	local lock = pbdata.lock --上锁 0-没有,1-部位,2-装备
	local reset_cost = pbdata.reset_cost
	local energy = pbdata.energy --tili
	local remain = pbdata.remain --剩余挑战次数
	local floors = pbdata.floors --层数信息
	--todo
	g_ActivityCtrl:GetPEFbCtrl():ShowMainView(pbdata)
end

function GS2CPELockResult(pbdata)
	local fb_id = pbdata.fb_id
	local lock = pbdata.lock
	--todo
	g_ActivityCtrl:GetPEFbCtrl():UpdateLockResult(fb_id, lock)
end

function GS2CPETurnResult(pbdata)
	local fb_id = pbdata.fb_id
	local select_part = pbdata.select_part
	local select_equip = pbdata.select_equip
	local enter = pbdata.enter --是否进入游戏,1-进入战斗,2-扫荡
	--todo
	g_ActivityCtrl:GetPEFbCtrl():UpdateTurnResult(pbdata)
end

function GS2CPEFuBenSchedule(pbdata)
	local fd_list = pbdata.fd_list --副本列表
	local cur_fb = pbdata.cur_fb --当前副本
	--todo
	CPEFbDropView:ShowView(function (oView)
		oView:SetType(cur_fb, fd_list)
	end)
end

function GS2CTrapmineStatus(pbdata)
	local status = pbdata.status --0-非探索,1-探索,2-打怪(稀有,宝箱怪),3-服务端离线托管
	--todo
	g_AnLeiCtrl:CtrlGS2CTrapmineStatus(status)
end

function GS2CTrapmineTotalReward(pbdata)
	local itemlist = pbdata.itemlist --奖励列表
	--todo
	g_AnLeiCtrl:CtrlGS2CTrapmineTotalReward(itemlist)
end

function GS2CTramineOfflineInfo(pbdata)
	local offline_second = pbdata.offline_second --离线时间,单位秒
	local cost_point = pbdata.cost_point --消耗探索点
	local itemlist = pbdata.itemlist --奖励列表
	--todo
	g_AnLeiCtrl:CacheOffLineRewardList({itemlist=itemlist, time=offline_second, cost=cost_point})
end

function GS2CLoginTrapmine(pbdata)
	local npc_list = pbdata.npc_list --玩家刷出的暗雷怪
	local rare_monster = pbdata.rare_monster --稀有怪
	--todo
	g_AnLeiCtrl:LoginHuodongInfo(npc_list, rare_monster)
end

function GS2CGetMingleiTeam(pbdata)
	--todo
	g_ActivityCtrl:CtrlGS2CGetMingleiTeam()
end

function GS2COpenMingleiUI(pbdata)
	local totaltime = pbdata.totaltime
	local buytime = pbdata.buytime
	local donetime = pbdata.donetime
	local leftbuytime = pbdata.leftbuytime
	local npctype = pbdata.npctype
	local npcid = pbdata.npcid
	--todo
	local config = {}
	config.npctype = npctype
	config.totaltime = totaltime
	config.buytime = buytime
	config.donetime = donetime
	config.leftbuytime = leftbuytime
	config.npcid = npcid
	g_ActivityCtrl:CtrlGS2COpenMingleiUI(config)	
end

function GS2CRefreshMingleiTime(pbdata)
	local totaltime = pbdata.totaltime
	local buytime = pbdata.buytime
	local donetime = pbdata.donetime
	local leftbuytime = pbdata.leftbuytime
	--todo
	local oView = CMingLeiReadyFightView:GetView()
	if oView then
		oView:RefreshTime(totaltime, buytime, donetime, leftbuytime)
	end
end

function GS2CRefreshMinglei(pbdata)
	--todo
	g_GuideCtrl:CtrlGS2CRefreshMinglei()
end

function GS2CLoginRewardInfo(pbdata)
	local login_day = pbdata.login_day --登录累积天数
	local rewarded_day = pbdata.rewarded_day --签到天数，位运算
	local breed_val = pbdata.breed_val --活跃点
	local breed_rwd = pbdata.breed_rwd --1-已领取孵化奖励
	--todo
	g_LoginRewardCtrl:RefreshLoginRewardInfo(login_day, rewarded_day, breed_val, breed_rwd)
end

function GS2CLoginRewardDay(pbdata)
	local rewarded_day = pbdata.rewarded_day --签到天数，位运算
	--todo
	g_LoginRewardCtrl:RefreshLoginRewardDay(rewarded_day)
end

function GS2CShowLoginRewardUI(pbdata)
	local next_day = pbdata.next_day --次日
	--todo
	g_LoginRewardCtrl:OpenNextView(next_day)
end

function GS2CShowBuyTimeWnd(pbdata)
	local lefttime = pbdata.lefttime
	local per_cost = pbdata.per_cost
	local maxtime = pbdata.maxtime
	--todo
	g_ActivityCtrl:CtrlGS2CShowBuyTimeWnd(lefttime, per_cost, maxtime)
end

function GS2CTerraWarsMainUI(pbdata)
	local personal_points = pbdata.personal_points --个人积分
	local org_points = pbdata.org_points --工会积分
	local time = pbdata.time
	local contribution = pbdata.contribution --个人贡献度
	local status = pbdata.status --据点战开启状态，1为已开始，0为未开始,2为预热
	--todo
	g_TerrawarCtrl:OpenTerrawarMain(personal_points, org_points, time, contribution, status)
end

function GS2CTerrawarMapInfo(pbdata)
	local map_id = pbdata.map_id --据点地图id
	local terrainfo = pbdata.terrainfo
	--todo
	g_TerrawarCtrl:SetTerrawarMapInfo(map_id, terrainfo)
end

function GS2CMyTerraInfo(pbdata)
	local terrainfo = pbdata.terrainfo
	--todo
	g_TerrawarCtrl:SetTerrawarMine(terrainfo)
end

function GS2CTerraInfo(pbdata)
	local terrainfo = pbdata.terrainfo
	local lingli_info = pbdata.lingli_info
	--todo
	g_TerrawarCtrl:OpenTerraWarState(terrainfo, lingli_info)
end

function GS2CTerrawarsCountDown(pbdata)
	local endtime = pbdata.endtime
	local type = pbdata.type --1：继续战斗  2：占领成功
	--todo
	g_TerrawarCtrl:TerrawarsCountDown(endtime, type)
end

function GS2CSetGuard(pbdata)
	local terraid = pbdata.terraid
	local end_time = pbdata.end_time
	--todo
	g_TerrawarCtrl:OpenTerraWarLineUp(terraid, end_time)
end

function GS2CSetGuardSuccess(pbdata)
	local terraid = pbdata.terraid
	--todo
	g_TerrawarCtrl:TerraWarLineUpSuccess(terraid)
end

function GS2CGiveUpSuccess(pbdata)
	local terraid = pbdata.terraid
	--todo
	g_TerrawarCtrl:TerrawarGiveUpSuccess(terraid)
end

function GS2CListInfo(pbdata)
	local terraid = pbdata.terraid
	local helplist = pbdata.helplist
	local attacklist = pbdata.attacklist
	local name = pbdata.name
	local orgid = pbdata.orgid
	--todo
	g_TerrawarCtrl:OpenTerraWarQueue(terraid, helplist, attacklist, name, orgid)
end

function GS2CTerraQueueStatus(pbdata)
	local status = pbdata.status
	--todo
	g_TerrawarCtrl:SetTerraWarQueue(status)
end

function GS2CTerraWarState(pbdata)
	local state = pbdata.state --2为预热，1为显示，0为关闭
	local time = pbdata.time
	--todo
	g_TerrawarCtrl:SetTerraWarState(state, time)
end

function GS2CMainYJFuben(pbdata)
	local remain_times = pbdata.remain_times --剩余挑战次数
	local buy_times = pbdata.buy_times --今天能够购买的挑战次数
	local type = pbdata.type --1-打开主界面 2-打开购买界面
	--todo
	if type == 1 then
		CYJMainView:ShowView(function (oView)
			oView:RefreshData(remain_times, buy_times)
			oView:SetChangeType(g_ActivityCtrl:GetYJFbCtrl():GetDefaultType())
		end)
	elseif type == 2 then
		CYJFbBuyView:ShowView(function (oView)
			oView:RefreshData(remain_times, buy_times)
		end)
	end
end

function GS2CEnterYJFuben(pbdata)
	local end_time = pbdata.end_time --提示结束时间戳
	local npclist = pbdata.npclist
	local autowar = pbdata.autowar --true-自动 false-不自动
	local stip = pbdata.stip
	--todo
	g_ActivityCtrl:GetYJFbCtrl():EnterFuben(end_time, npclist, autowar, stip)
end

function GS2CLeaveYJFuben(pbdata)
	--todo
	g_ActivityCtrl:GetYJFbCtrl():CloseFuben()
end

function GS2CYJFubenView(pbdata)
	local monsterlist = pbdata.monsterlist
	local npclist = pbdata.npclist
	--todo
	local oView = CYJFbWarView:GetView()
	if oView then
		--oView:RefreshData(npclist)
		oView:RefreshFight(monsterlist)
	else
		CYJFbWarView:ShowView(function(oView)
			oView:RefreshData(npclist)
			oView:RefreshFight(monsterlist, npclist)
		end)
	end
end

function GS2CFieldBossHPNotify(pbdata)
	local hp_max = pbdata.hp_max
	local hp = pbdata.hp
	--todo
	g_FieldBossCtrl:RefreshBossHP(hp, hp_max)
end

function GS2CFieldBossBattle(pbdata)
	local org_info = pbdata.org_info
	local playercnt = pbdata.playercnt
	local bossname = pbdata.bossname
	local bossid = pbdata.bossid
	local reward_endtime = pbdata.reward_endtime
	local reward_amount = pbdata.reward_amount
	--todo
	g_FieldBossCtrl:RefreshData(pbdata)
end

function GS2CTerraReadyInfo(pbdata)
	local ready = pbdata.ready
	local end_time = pbdata.end_time
	--todo
	g_TerrawarCtrl:OpenCTerraReady(ready, end_time)
end

function GS2CFieldBossMainUI(pbdata)
	local boss_status = pbdata.boss_status
	--todo
	CFieldBossView:ShowView(function (oView)
		oView:UpdateBoss(boss_status)
	end)
end

function GS2CFieldBossInfo(pbdata)
	local bossid = pbdata.bossid
	local status = pbdata.status
	local hpinfo = pbdata.hpinfo
	local left_time = pbdata.left_time
	--todo
	local oView = CFieldBossView:GetView()
	if oView then
		oView:UpdateBossDetail(pbdata)
	end
end

function GS2CLeaveFieldBoss(pbdata)
	--todo
	g_FieldBossCtrl:LeaveFieldBoss()
end

function GS2CStartPick(pbdata)
	local time = pbdata.time
	local sessionidx = pbdata.sessionidx
	--todo
	local function confirm()
		netother.C2GSCallback(sessionidx, 1)
	end
	local function cancel()
		--netother.C2GSCallback(sessionidx, 0)
	end
	CItemTipsProgressView:ShowView(function (oView)
		oView:SetData()
		oView:SetCallBackFunc(confirm)
		oView.m_ActionBtn:ClearEffect()
		oView:OnAction()
	end)
end

function GS2CNewFieldBoss(pbdata)
	local bossid = pbdata.bossid
	--todo
	g_FieldBossCtrl:AddBoss(bossid)
end

function GS2CFieldBossDied(pbdata)
	local bossid = pbdata.bossid
	--todo
	g_FieldBossCtrl:DelBoss(bossid)
end

function GS2CFieldBossAttack(pbdata)
	local damage = pbdata.damage
	local max_hp = pbdata.max_hp
	local killer = pbdata.killer
	local teamdamage = pbdata.teamdamage
	local reward_times = pbdata.reward_times
	local coin_reward = pbdata.coin_reward
	--todo
	g_FieldBossCtrl:SetWarResult(pbdata)
end

function GS2CSocialDisplayInfo(pbdata)
	local social_display = pbdata.social_display --社交展示
	--todo
	g_SocialityCtrl:Play(social_display, g_MapCtrl:GetHero())
	g_SocialityCtrl:OnEvent(define.Sociality.Event.OnReceivePlay)
end

function GS2CDailySignInfo(pbdata)
	local sign_info = pbdata.sign_info --签到信息了列表
	--todo
	g_WelfareCtrl:OnReceiveDailySign(sign_info)
end

function GS2COnlineGift(pbdata)
	local status = pbdata.status
	local onlinetime = pbdata.onlinetime
	local reward = pbdata.reward
	--todo
	g_OnlineGiftCtrl:UpdateStatus(status)
	g_OnlineGiftCtrl:UpdateReward(reward)
	g_OnlineGiftCtrl:UpdateTime(onlinetime)
end

function GS2COnlineGiftStatus(pbdata)
	local status = pbdata.status
	--todo
	g_OnlineGiftCtrl:UpdateStatus(status)
end

function GS2CLoginChapterInfo(pbdata)
	local totalstar_info = pbdata.totalstar_info
	local extrareward_info = pbdata.extrareward_info
	local finalchapter = pbdata.finalchapter
	local energy_buytime = pbdata.energy_buytime
	--todo
	g_ChapterFuBenCtrl:OnReceiveLoginChapterInfo(totalstar_info, extrareward_info, finalchapter, energy_buytime)
end

function GS2CChapterOpen(pbdata)
	local chapter = pbdata.chapter
	local level = pbdata.level
	local type = pbdata.type
	--todo
	g_ChapterFuBenCtrl:OnReceiveChapterOpen(type, chapter, level)
end

function GS2CUpdateChapterTotalStar(pbdata)
	local info = pbdata.info
	--todo
	g_ChapterFuBenCtrl:OnReceiveUpdateChapterTotalStar(info)
end

function GS2CUpdateChapterExtraReward(pbdata)
	local info = pbdata.info
	--todo
	g_ChapterFuBenCtrl:OnReceiveUpdateChapterExtraReward(info)
end

function GS2CChapterInfo(pbdata)
	local info = pbdata.info
	--todo
	g_ChapterFuBenCtrl:OnReceiveChapterInfo(info)
end

function GS2CUpdateChapter(pbdata)
	local info = pbdata.info
	--todo
	g_ChapterFuBenCtrl:OnReceiveUpdateChapter(info)
end

function GS2CSweepChapterReward(pbdata)
	local reward = pbdata.reward
	local chapter = pbdata.chapter
	local level = pbdata.level
	local type = pbdata.type
	--todo
	g_ChapterFuBenCtrl:OnReceiveSweepChapterReward(reward, chapter, level, type)
end

function GS2CChapterFbWinUI(pbdata)
	local war_id = pbdata.war_id
	local player_exp = pbdata.player_exp
	local partner_exp = pbdata.partner_exp
	local firstpass_reward = pbdata.firstpass_reward
	local stable_reward = pbdata.stable_reward
	local random_reward = pbdata.random_reward
	local win = pbdata.win --1:win 0:fail
	local star = pbdata.star
	local condition = pbdata.condition
	local coin = pbdata.coin
	--todo
	g_ChapterFuBenCtrl:OnReceiveChapterFbWinUI(war_id, win, player_exp, partner_exp, firstpass_reward, stable_reward, random_reward, star, condition, coin)
end

function GS2CChargeGiftInfo(pbdata)
	local mask = pbdata.mask
	local czjj_is_buy = pbdata.czjj_is_buy --是否购买成长基金,1:pid已购买,2:本帐号已购买
	local czjj_grade_list = pbdata.czjj_grade_list --成长基金领取状态,key:grade_gift1_0
	local charge_card = pbdata.charge_card --yk,zsk信息
	--todo
	local pbdata = g_NetCtrl:DecodeMaskData(pbdata, "GS2CChargeGiftInfo")
	if pbdata.czjj_is_buy then
		g_WelfareCtrl:SetCzjjData("buy_flag", pbdata.czjj_is_buy)
	end
	if pbdata.czjj_grade_list then
		local dict = {}
		for k, v in ipairs(pbdata.czjj_grade_list) do
			dict[v.key] = v.val
		end
		g_WelfareCtrl:SetCzjjData("get_flags", dict)
	end
	if pbdata.charge_card then
		for i, cardinfo in ipairs(pbdata.charge_card) do
			g_WelfareCtrl:SetYueKaData(cardinfo.type, cardinfo)
		end
	end
end

function GS2CChargeRefreshUnit(pbdata)
	local unit = pbdata.unit
	--todo
	local dFlags = g_WelfareCtrl:GetCzjjData("get_flags") or {}
	dFlags[unit.key] = unit.val
	g_WelfareCtrl:SetCzjjData("get_flags", dFlags)
end

function GS2CChargeCard(pbdata)
	local charge_card = pbdata.charge_card
	--todo
	-- message ChargeCard {
	--     optional string type = 1;                           //yk,zsk
	--     optional uint32 val = 2;                           //0:不可领取(未充值),1:可领取,2:已领取
	--     optional uint32 left_count = 3;                //剩余领取次数,zsk忽略
	-- }
	g_WelfareCtrl:SetYueKaData(charge_card.type, charge_card) 
end

function GS2CPopBuyMonthCard(pbdata)
	local left_day = pbdata.left_day --剩余天数
	--todo
	local msgStr = string.format("月卡还有%d天到期,是否前往购买？", left_day)
	local t = {
		msg = msgStr,
		okStr = "是",
		cancelStr = "否",
		okCallback = function ()
			g_OpenUICtrl:OpenYueKa()
		end}
	g_WindowTipCtrl:SetWindowConfirm(t)
end

function GS2CAddAttackMoster(pbdata)
	local npcinfo = pbdata.npcinfo
	--todo
	g_MonsterAtkCityCtrl:AddMonsterInfo(npcinfo)
end

function GS2CMultiAttackMoster(pbdata)
	local npclist = pbdata.npclist
	--todo
	g_MonsterAtkCityCtrl:LoginMonsterInfo(npclist)
end

function GS2CDelAttackMoster(pbdata)
	local idlist = pbdata.idlist
	--todo
	g_MonsterAtkCityCtrl:DelMonsterInfos(idlist)
end

function GS2COpenMsAttackUI(pbdata)
	local open = pbdata.open
	local defend = pbdata.defend
	local defend_max = pbdata.defend_max
	local nexttime = pbdata.nexttime --下一个时间戳  --0 表示没有下一波怪物了
	local wave = pbdata.wave --波数
	local endtime = pbdata.endtime --结束时间戳
	--todo
	g_MonsterAtkCityCtrl:OnReceiveCityDefend(open, defend, defend_max, nexttime, wave, endtime)
end

function GS2CMSBossWarEnd(pbdata)
	local hit = pbdata.hit --本次伤害
	local all_hit = pbdata.all_hit --今天总伤害
	local hit_per = pbdata.hit_per --伤害百分比 x/100=整数,x%100 = 小数点
	local coin = pbdata.coin
	--todo
	g_MonsterAtkCityCtrl:OnReceiveMSBossWarEnd(hit, all_hit, hit_per, coin)
end

function GS2CMSBossHPNotify(pbdata)
	local hp_max = pbdata.hp_max
	local hp = pbdata.hp
	--todo
	g_MonsterAtkCityCtrl:OnReceiveMSBossHP(hp_max, hp)
end

function GS2CMSBossTip(pbdata)
	local starttime = pbdata.starttime
	local endtime = pbdata.endtime
	--todo
	g_MonsterAtkCityCtrl:SetYure(starttime, endtime)
end

function GS2CRushRankInfo(pbdata)
	local rush = pbdata.rush
	--todo
	g_RankCtrl:UpdateTimeLimitRankInfo(rush)
end

function GS2CTrainInfo(pbdata)
	local reward_info = pbdata.reward_info
	local clientnpc = pbdata.clientnpc
	local reward_times = pbdata.reward_times
	local ring = pbdata.ring
	local reward_siwtch = pbdata.reward_siwtch --1-close    0-open
	--todo
	g_ActivityCtrl:CtrlGS2CTrainInfo(reward_info, clientnpc, reward_times, ring, reward_siwtch)
end

function GS2CTrainRewardSwitch(pbdata)
	local close = pbdata.close
	--todo
	g_ActivityCtrl:CtrlGS2CTrainRewardSwitch(close)
end

function GS2COrgWarTip(pbdata)
	local starttime = pbdata.starttime
	local endtime = pbdata.endtime
	--todo
	g_OrgWarCtrl:UpdateTime(starttime, endtime)
end

function GS2COrgWarState(pbdata)
	local state = pbdata.state --1-进攻状态 2-防守状态 3-取消状态
	--todo
	g_OrgWarCtrl:UpdateStatus(state)
end

function GS2COrgWarEnterSc(pbdata)
	local type = pbdata.type --1-预备场景 2-正式场景
	--todo
	g_OrgWarCtrl:EnterScene(type)
end

function GS2COrgWarLeaveSc(pbdata)
	local type = pbdata.type --1-预备场景 2-正式场景
	--todo
	g_OrgWarCtrl:LeaveScene(type)
end

function GS2COrgWarUI(pbdata)
	local my = pbdata.my
	local enemy = pbdata.enemy
	--todo
	g_OrgWarCtrl:OnUpdateBlood(my, enemy)
end

function GS2COrgWarList(pbdata)
	local list = pbdata.list
	--todo
	g_OrgWarCtrl:OnReceiveFightList(list)
end

function GS2COrgWarRevive(pbdata)
	local end_time = pbdata.end_time
	--todo
	g_OrgWarCtrl:UpdateReviveTime(end_time)
end

function GS2CFastCreateTeam(pbdata)
	local target = pbdata.target
	--todo
	g_ActivityCtrl:CtrlGS2CFastCreateTeam(target)
end

function GS2CRefreshTrainTimes(pbdata)
	local times = pbdata.times
	--todo
	g_ActivityCtrl:CtrlGS2CRefreshTrainTimes(times)
end

function GS2CHuntSuccess(pbdata)
	local level = pbdata.level
	local next_active = pbdata.next_active --0:下一档次激活  1：下一档次未激活
	--todo
	g_HuntPartnerSoulCtrl:UpdateNpc(level, next_active)
end

function GS2CDelHuntSoul(pbdata)
	local createtime = pbdata.createtime
	--todo
	g_HuntPartnerSoulCtrl:OnDelPartnerSoul(createtime)
end

function GS2CAddHuntSoul(pbdata)
	local type = pbdata.type
	local id = pbdata.id
	local createtime = pbdata.createtime
	--todo
	g_HuntPartnerSoulCtrl:OnAddPartnerSoul(pbdata)
end

function GS2CRefreshHireInfo(pbdata)
	local parid = pbdata.parid
	local times = pbdata.times
	--todo
	g_PartnerCtrl:UpdateHireData(parid, times)
	local oView = CPartnerHireView:GetView()
	if oView then
		oView:UpdateHireData(parid)
	end
end

function GS2CQuitTrain(pbdata)
	--todo
	g_ActivityCtrl:CtrlGS2CQuitTrain()
end

function GS2CExpressEnterUI(pbdata)
	local stip = pbdata.stip
	--todo
	g_MarryCtrl:OpenApplyView(stip)
end

function GS2CExpressWaitUI(pbdata)
	local result = pbdata.result --true-成功进入等待 false-未成功
	local endtime = pbdata.endtime --等待时间
	--todo
	g_MarryCtrl:OnOpenResponse(result, endtime)
end

function GS2CExpressPop(pbdata)
	local name = pbdata.name --表白方名字
	local content = pbdata.content --表白内容
	local endtime = pbdata.endtime --等待时间
	--todo
	g_MarryCtrl:OpenComfirmView(content, name, endtime)
end

function GS2CExpressResult(pbdata)
	local result = pbdata.result --true-接受　false-拒绝
	--todo
	g_MarryCtrl:OnExpressResult(result)
end

function GS2CExpressOver(pbdata)
	--todo
	g_MarryCtrl:TimeUp()
end

function GS2CLoversTitleUI(pbdata)
	local postfix = pbdata.postfix --称呼后缀
	local cost = pbdata.cost --花费
	local name = pbdata.name --情侣名称
	--todo
	g_MarryCtrl:OpenEditTitleView(postfix, cost, name)
end

function GS2CExpressAction(pbdata)
	local hugid = pbdata.hugid --拥抱者
	local hugedid = pbdata.hugedid --被抱者
	local endtime = pbdata.endtime --超过这个时间点到周围　看不到
	--todo
	g_MarryCtrl:OnExpressAction(hugid, hugedid, endtime)
end

function GS2CHeroBoxMainUI(pbdata)
	local item = pbdata.item
	--todo
	CHeroboxView:ShowView(function (oView)
		oView:SetData(item)
	end)
end

function GS2CTerrawarsLog(pbdata)
	local log = pbdata.log
	--todo
	g_TerrawarCtrl:SetTerraWarLog(log)
end

function GS2CHeroBoxRecord(pbdata)
	local npcid = pbdata.npcid
	--todo
	g_MapCtrl:HeroBoxRecord(npcid)
end

function GS2CGradeGiftInfo(pbdata)
	local grade = pbdata.grade --等级
	local endtime = pbdata.endtime --结束时间戳
	local buy_gift = pbdata.buy_gift --付费物品
	local old_price = pbdata.old_price --原价
	local now_price = pbdata.now_price --现价
	local discount = pbdata.discount --折扣,80-表示80%
	local status = pbdata.status --0-预告,1-正在购买，2-结束
	local free_gift = pbdata.free_gift --免费物品
	local open_ui = pbdata.open_ui --1-强制打开
	local payid = pbdata.payid --android的payid
	local ios_payid = pbdata.ios_payid --ios的payid
	--todo
	g_GradeGiftCtrl:UpdataInfo(grade, endtime, buy_gift, old_price, now_price, discount, status, free_gift, open_ui, payid, ios_payid)
end

function GS2CChargeScore(pbdata)
	local cur_id = pbdata.cur_id --当前活动ID
	local status = pbdata.status --当前活动状态  0为未开启，1为开启
	local score_info = pbdata.score_info
	local start_time = pbdata.start_time
	local end_time = pbdata.end_time
	--todo
	pbdata = table.copy(pbdata)
	cur_id = pbdata.cur_id
	status = pbdata.status
	score_info = pbdata.score_info
	start_time = pbdata.start_time
	end_time = pbdata.end_time
	g_WelfareCtrl:SetChargeScore(cur_id, status, score_info, start_time, end_time)
end

function GS2CUpdateCSBuyTimes(pbdata)
	local id = pbdata.id
	local buy_times = pbdata.buy_times
	local score = pbdata.score
	--todo
	pbdata = table.copy(pbdata)
	id = pbdata.id
	buy_times = pbdata.buy_times
	score = pbdata.score
	g_WelfareCtrl:GS2CUpdateCSBuyTimes(id, buy_times, score)
end

function GS2CChargeRewrad(pbdata)
	local start_time = pbdata.start_time
	local end_time = pbdata.end_time
	local schedule = pbdata.schedule --方案
	local reward_info = pbdata.reward_info
	--todo
	g_WelfareCtrl:InitChargeBack(reward_info, start_time, end_time, schedule)
end

function GS2CRefreshChargeReward(pbdata)
	local reward_info = pbdata.reward_info
	--todo
	g_WelfareCtrl:UpdateChargeBack(reward_info)
end

function GS2COneRMBGift(pbdata)
	local gift = pbdata.gift --礼包信息
	local starttime = pbdata.starttime --开始时间戳
	local endtime = pbdata.endtime --结束时间戳
	--todo
	g_WelfareCtrl:UpdateYiYuanLiBaoList(gift, starttime, endtime)
end

function GS2CUpdateOneRMBGift(pbdata)
	local gift = pbdata.gift
	--todo
	g_WelfareCtrl:UpdateYiYuanLiBao(gift)
end

function GS2CHDAddChargeInfo(pbdata)
	local list = pbdata.list --列表
	local progress = pbdata.progress --累计充值进度
	local starttime = pbdata.starttime --开始时间戳
	local endtime = pbdata.endtime --结束时间戳
	--todo
	g_WelfareCtrl:UpdateRushRecharge(list, progress, starttime, endtime)
end

function GS2CHDAddChargeProgress(pbdata)
	local progress = pbdata.progress --累计充值进度
	--todo
	g_WelfareCtrl:UpdateRushRechargeProgress(progress)
end

function GS2CHDUpdateAddCharge(pbdata)
	local unit = pbdata.unit
	--todo
	g_WelfareCtrl:UpdateRushRechargeList(unit)
end

function GS2CCloseHuodong(pbdata)
	local name = pbdata.name --活动名
	--todo
	if name == "daycharge" then
		CLimitRewardView:CloseView()
	end
end

function GS2CHDDayChargeInfo(pbdata)
	local list = pbdata.list --列表
	local progress = pbdata.progress --累计充值进度
	local starttime = pbdata.starttime --开始时间戳
	local endtime = pbdata.endtime --结束时间戳
	local code = pbdata.code --校验码
	--todo
	g_WelfareCtrl:SetLoopPayInfo(list, progress, starttime, endtime, code)
end

function GS2CHDDayChargeProgress(pbdata)
	local progress = pbdata.progress --累计充值进度
	--todo
	g_WelfareCtrl:UpdateLoopPayProgress(progress)
end

function GS2CHDUpdateDayCharge(pbdata)
	local unit = pbdata.unit
	--todo
	g_WelfareCtrl:UpdateLoopPayUnit(unit)
end

function GS2CRefreshTimeResume(pbdata)
	local resume_amount = pbdata.resume_amount
	local rewardinfo = pbdata.rewardinfo
	--todo
	g_WelfareCtrl:RefreshLimitPay(resume_amount, rewardinfo)
end

function GS2CTimeResumeInfo(pbdata)
	local start_time = pbdata.start_time
	local end_time = pbdata.end_time
	local plan_id = pbdata.plan_id
	--todo
	g_WelfareCtrl:UpdateLimitPayTime(start_time, end_time, plan_id)
end

function GS2CRankBack(pbdata)
	local starttime = pbdata.starttime
	local endtime = pbdata.endtime
	--todo
	g_WelfareCtrl:UpdateRankBack(starttime, endtime)
end

function GS2CResumeRestore(pbdata)
	local start_time = pbdata.start_time
	local end_time = pbdata.end_time
	local plan_id = pbdata.plan_id --当前方案
	--todo
	g_WelfareCtrl:InitCostSaveTime(start_time, end_time, plan_id)		
end

function GS2CRefreshResumeRestore(pbdata)
	local resume = pbdata.resume --消费水晶
	local status = pbdata.status --领取状态 1为已领取，0为未领取
	--todo
	g_WelfareCtrl:InitCostSaveGold(resume, status)	
end


--C2GS--

function C2GSAnswerQuestion(id, type, answer)
	local t = {
		id = id,
		type = type,
		answer = answer,
	}
	g_NetCtrl:Send("huodong", "C2GSAnswerQuestion", t)
end

function C2GSQuestionEnterMember()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSQuestionEnterMember", t)
end

function C2GSQuestionEndReward(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSQuestionEndReward", t)
end

function C2GSApplyQuestionScene()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSApplyQuestionScene", t)
end

function C2GSEnterQuestionScene()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSEnterQuestionScene", t)
end

function C2GSLeaveQuestionScene()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLeaveQuestionScene", t)
end

function C2GSOpenBossUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOpenBossUI", t)
end

function C2GSEnterBossWar()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSEnterBossWar", t)
end

function C2GSCloseBossUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSCloseBossUI", t)
end

function C2GSBossRemoveDeadBuff()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSBossRemoveDeadBuff", t)
end

function C2GSLeaveWorldBossScene()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLeaveWorldBossScene", t)
end

function C2GSFindWorldBoss()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSFindWorldBoss", t)
end

function C2GSBuyBossBuff(buff)
	local t = {
		buff = buff,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyBossBuff", t)
end

function C2GSWorldBoossRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSWorldBoossRank", t)
end

function C2GSPataOption(iOp)
	local t = {
		iOp = iOp,
	}
	g_NetCtrl:Send("huodong", "C2GSPataOption", t)
end

function C2GSPataEnterWar(iLevel, iSweep)
	local t = {
		iLevel = iLevel,
		iSweep = iSweep,
	}
	g_NetCtrl:Send("huodong", "C2GSPataEnterWar", t)
end

function C2GSPataInvite(target, parid)
	local t = {
		target = target,
		parid = parid,
	}
	g_NetCtrl:Send("huodong", "C2GSPataInvite", t)
end

function C2GSPataFrdInfo(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSPataFrdInfo", t)
end

function C2GSPataTgReward(level)
	local t = {
		level = level,
	}
	g_NetCtrl:Send("huodong", "C2GSPataTgReward", t)
end

function C2GSGetEndlessList()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSGetEndlessList", t)
end

function C2GSEndlessPVEStart(mode)
	local t = {
		mode = mode,
	}
	g_NetCtrl:Send("huodong", "C2GSEndlessPVEStart", t)
end

function C2GSOpenEquipFBMain()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOpenEquipFBMain", t)
end

function C2GSOpenEquipFB(f_id)
	local t = {
		f_id = f_id,
	}
	g_NetCtrl:Send("huodong", "C2GSOpenEquipFB", t)
end

function C2GSEnterEquiFB(floor)
	local t = {
		floor = floor,
	}
	g_NetCtrl:Send("huodong", "C2GSEnterEquiFB", t)
end

function C2GSGooutEquipFB()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSGooutEquipFB", t)
end

function C2GSRefreshEquipFBScene()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSRefreshEquipFBScene", t)
end

function C2GSSetAutoEquipFuBen(auto)
	local t = {
		auto = auto,
	}
	g_NetCtrl:Send("huodong", "C2GSSetAutoEquipFuBen", t)
end

function C2GSBuyEquipPlayCnt(buy_cnt, cost, fb)
	local t = {
		buy_cnt = buy_cnt,
		cost = cost,
		fb = fb,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyEquipPlayCnt", t)
end

function C2GSGetEquipFBReward(floor, equip)
	local t = {
		floor = floor,
		equip = equip,
	}
	g_NetCtrl:Send("huodong", "C2GSGetEquipFBReward", t)
end

function C2GSSweepEquipFB(floor, count)
	local t = {
		floor = floor,
		count = count,
	}
	g_NetCtrl:Send("huodong", "C2GSSweepEquipFB", t)
end

function C2GSOpenPEMain(fb_id)
	local t = {
		fb_id = fb_id,
	}
	g_NetCtrl:Send("huodong", "C2GSOpenPEMain", t)
end

function C2GSPEStartTurn(fb_id)
	local t = {
		fb_id = fb_id,
	}
	g_NetCtrl:Send("huodong", "C2GSPEStartTurn", t)
end

function C2GSPELock(fb_id, lock)
	local t = {
		fb_id = fb_id,
		lock = lock,
	}
	g_NetCtrl:Send("huodong", "C2GSPELock", t)
end

function C2GSEnterPEFuBen(fb_id, floor, type)
	local t = {
		fb_id = fb_id,
		floor = floor,
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSEnterPEFuBen", t)
end

function C2GSBuyPEFuBen(times, fb)
	local t = {
		times = times,
		fb = fb,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyPEFuBen", t)
end

function C2GSOpenPEFuBenSchedule()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOpenPEFuBenSchedule", t)
end

function C2GSCostSelectPEFuBen(fb)
	local t = {
		fb = fb,
	}
	g_NetCtrl:Send("huodong", "C2GSCostSelectPEFuBen", t)
end

function C2GSStartTrapmine(map_id)
	local t = {
		map_id = map_id,
	}
	g_NetCtrl:Send("huodong", "C2GSStartTrapmine", t)
end

function C2GSCancelTrapmine(map_id)
	local t = {
		map_id = map_id,
	}
	g_NetCtrl:Send("huodong", "C2GSCancelTrapmine", t)
end

function C2GSStartOfflineTrapmine(map_id)
	local t = {
		map_id = map_id,
	}
	g_NetCtrl:Send("huodong", "C2GSStartOfflineTrapmine", t)
end

function C2GSCancelOfflineTrapmine(map_id)
	local t = {
		map_id = map_id,
	}
	g_NetCtrl:Send("huodong", "C2GSCancelOfflineTrapmine", t)
end

function C2GSGetLoginReward(day)
	local t = {
		day = day,
	}
	g_NetCtrl:Send("huodong", "C2GSGetLoginReward", t)
end

function C2GSAddFullBreedVal()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSAddFullBreedVal", t)
end

function C2GSGetBreedValRwd()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSGetBreedValRwd", t)
end

function C2GSBuyMingleiTimes(buy_time)
	local t = {
		buy_time = buy_time,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyMingleiTimes", t)
end

function C2GSDoMingleiCmd(npcid, cmd, args)
	local t = {
		npcid = npcid,
		cmd = cmd,
		args = args,
	}
	g_NetCtrl:Send("huodong", "C2GSDoMingleiCmd", t)
end

function C2GSNpcFight(npc_id)
	local t = {
		npc_id = npc_id,
	}
	g_NetCtrl:Send("huodong", "C2GSNpcFight", t)
end

function C2GSGoToHelpTerra(id, start_time)
	local t = {
		id = id,
		start_time = start_time,
	}
	g_NetCtrl:Send("huodong", "C2GSGoToHelpTerra", t)
end

function C2GSTerrawarMain()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSTerrawarMain", t)
end

function C2GSTerrawarMapInfo(map_id)
	local t = {
		map_id = map_id,
	}
	g_NetCtrl:Send("huodong", "C2GSTerrawarMapInfo", t)
end

function C2GSTerrawarMine(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSTerrawarMine", t)
end

function C2GSTerrawarWorldRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSTerrawarWorldRank", t)
end

function C2GSTerrawarOrgRank()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSTerrawarOrgRank", t)
end

function C2GSTerrawarOperate(id, type, next_cmd)
	local t = {
		id = id,
		type = type,
		next_cmd = next_cmd,
	}
	g_NetCtrl:Send("huodong", "C2GSTerrawarOperate", t)
end

function C2GSGetTerraInfo(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSGetTerraInfo", t)
end

function C2GSAttackTerra(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSAttackTerra", t)
end

function C2GSSetGuard(id, par_id)
	local t = {
		id = id,
		par_id = par_id,
	}
	g_NetCtrl:Send("huodong", "C2GSSetGuard", t)
end

function C2GSAutoSetGuard(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSAutoSetGuard", t)
end

function C2GSGetListInfo(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSGetListInfo", t)
end

function C2GSLeaveQueue(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSLeaveQueue", t)
end

function C2GSHelpFirst(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSHelpFirst", t)
end

function C2GSEnterYJFuben(itype)
	local t = {
		itype = itype,
	}
	g_NetCtrl:Send("huodong", "C2GSEnterYJFuben", t)
end

function C2GSBuyYJFuben(amount)
	local t = {
		amount = amount,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyYJFuben", t)
end

function C2GSYJFubenOp(action)
	local t = {
		action = action,
	}
	g_NetCtrl:Send("huodong", "C2GSYJFubenOp", t)
end

function C2GSYJFubenView(npcidx)
	local t = {
		npcidx = npcidx,
	}
	g_NetCtrl:Send("huodong", "C2GSYJFubenView", t)
end

function C2GSYJFindNpc(npcidx)
	local t = {
		npcidx = npcidx,
	}
	g_NetCtrl:Send("huodong", "C2GSYJFindNpc", t)
end

function C2GSBuyLingli(buy_time, terra_id)
	local t = {
		buy_time = buy_time,
		terra_id = terra_id,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyLingli", t)
end

function C2GSYJGuidanceReward()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSYJGuidanceReward", t)
end

function C2GSGuideMingleiWar()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSGuideMingleiWar", t)
end

function C2GSOpenFieldBossUI()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOpenFieldBossUI", t)
end

function C2GSFieldBossInfo(bossid)
	local t = {
		bossid = bossid,
	}
	g_NetCtrl:Send("huodong", "C2GSFieldBossInfo", t)
end

function C2GSFieldBossPk(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSFieldBossPk", t)
end

function C2GSLeaveBattle()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLeaveBattle", t)
end

function C2GSLeaveLegendFB()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSLeaveLegendFB", t)
end

function C2GSSocailDisplay(id, target_pid)
	local t = {
		id = id,
		target_pid = target_pid,
	}
	g_NetCtrl:Send("huodong", "C2GSSocailDisplay", t)
end

function C2GSCancelSocailDisplay()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSCancelSocailDisplay", t)
end

function C2GSDailySign(key)
	local t = {
		key = key,
	}
	g_NetCtrl:Send("huodong", "C2GSDailySign", t)
end

function C2GSGetOnlineGift(rewardid)
	local t = {
		rewardid = rewardid,
	}
	g_NetCtrl:Send("huodong", "C2GSGetOnlineGift", t)
end

function C2GSGetChapterInfo(chapter, type)
	local t = {
		chapter = chapter,
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSGetChapterInfo", t)
end

function C2GSFightChapterFb(chapter, level, type)
	local t = {
		chapter = chapter,
		level = level,
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSFightChapterFb", t)
end

function C2GSSweepChapterFb(chapter, level, count, type)
	local t = {
		chapter = chapter,
		level = level,
		count = count,
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSSweepChapterFb", t)
end

function C2GSGetExtraReward(chapter, level, type)
	local t = {
		chapter = chapter,
		level = level,
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSGetExtraReward", t)
end

function C2GSGetStarReward(chapter, index, type)
	local t = {
		chapter = chapter,
		index = index,
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSGetStarReward", t)
end

function C2GSStarConvoy()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSStarConvoy", t)
end

function C2GSGiveUpConvoy()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSGiveUpConvoy", t)
end

function C2GSRefreshTarget()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSRefreshTarget", t)
end

function C2GSChargeRewardGradeGift(grade)
	local t = {
		grade = grade,
	}
	g_NetCtrl:Send("huodong", "C2GSChargeRewardGradeGift", t)
end

function C2GSChargeCardReward(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSChargeCardReward", t)
end

function C2GSFightAttackMoster(npcid)
	local t = {
		npcid = npcid,
	}
	g_NetCtrl:Send("huodong", "C2GSFightAttackMoster", t)
end

function C2GSShowConvoy()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSShowConvoy", t)
end

function C2GSReceiveEnergy(index)
	local t = {
		index = index,
	}
	g_NetCtrl:Send("huodong", "C2GSReceiveEnergy", t)
end

function C2GSContinueTraining()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSContinueTraining", t)
end

function C2GSSetTrainReward(close)
	local t = {
		close = close,
	}
	g_NetCtrl:Send("huodong", "C2GSSetTrainReward", t)
end

function C2GSOrgWarGuide()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarGuide", t)
end

function C2GSOrgWarCanCelState(state)
	local t = {
		state = state,
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarCanCelState", t)
end

function C2GSOrgWarOption(cmd)
	local t = {
		cmd = cmd,
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarOption", t)
end

function C2GSOrgWarPK(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("huodong", "C2GSOrgWarPK", t)
end

function C2GSSetHuntAutoSale(autosale)
	local t = {
		autosale = autosale,
	}
	g_NetCtrl:Send("huodong", "C2GSSetHuntAutoSale", t)
end

function C2GSCallHuntNpc(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("huodong", "C2GSCallHuntNpc", t)
end

function C2GSHuntSoul(level)
	local t = {
		level = level,
	}
	g_NetCtrl:Send("huodong", "C2GSHuntSoul", t)
end

function C2GSPickUpSoul(createtime, id)
	local t = {
		createtime = createtime,
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSPickUpSoul", t)
end

function C2GSPickUpSoulByOneKey()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSPickUpSoulByOneKey", t)
end

function C2GSSaleSoulByOneKey()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSSaleSoulByOneKey", t)
end

function C2GSQuitTrain()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSQuitTrain", t)
end

function C2GSHirePartner(parid)
	local t = {
		parid = parid,
	}
	g_NetCtrl:Send("huodong", "C2GSHirePartner", t)
end

function C2GSSendExpress(content)
	local t = {
		content = content,
	}
	g_NetCtrl:Send("huodong", "C2GSSendExpress", t)
end

function C2GSExpressResponse(result)
	local t = {
		result = result,
	}
	g_NetCtrl:Send("huodong", "C2GSExpressResponse", t)
end

function C2GSChangeLoversTitle(postfix)
	local t = {
		postfix = postfix,
	}
	g_NetCtrl:Send("huodong", "C2GSChangeLoversTitle", t)
end

function C2GSTerrawarsLog()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSTerrawarsLog", t)
end

function C2GSTerraAskForHelp(terraid)
	local t = {
		terraid = terraid,
	}
	g_NetCtrl:Send("huodong", "C2GSTerraAskForHelp", t)
end

function C2GSFindHuodongNpc(huodong_name, npc_type)
	local t = {
		huodong_name = huodong_name,
		npc_type = npc_type,
	}
	g_NetCtrl:Send("huodong", "C2GSFindHuodongNpc", t)
end

function C2GSFinishGetReward(sys_name)
	local t = {
		sys_name = sys_name,
	}
	g_NetCtrl:Send("huodong", "C2GSFinishGetReward", t)
end

function C2GSReceiveFreeGift(grade)
	local t = {
		grade = grade,
	}
	g_NetCtrl:Send("huodong", "C2GSReceiveFreeGift", t)
end

function C2GSBuyCSItem(id, times)
	local t = {
		id = id,
		times = times,
	}
	g_NetCtrl:Send("huodong", "C2GSBuyCSItem", t)
end

function C2GSReceiveAddCharge(id)
	local t = {
		id = id,
	}
	g_NetCtrl:Send("huodong", "C2GSReceiveAddCharge", t)
end

function C2GSReceiveDayCharge(id, code)
	local t = {
		id = id,
		code = code,
	}
	g_NetCtrl:Send("huodong", "C2GSReceiveDayCharge", t)
end

function C2GSGetTimeResumeReward(reward)
	local t = {
		reward = reward,
	}
	g_NetCtrl:Send("huodong", "C2GSGetTimeResumeReward", t)
end

function C2GSGetResumeRestoreReward()
	local t = {
	}
	g_NetCtrl:Send("huodong", "C2GSGetResumeRestoreReward", t)
end

