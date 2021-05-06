local CWarCtrl = class("CWarCtrl", CCtrlBase)
define.War = {
	SpeedFactor = 0.7,
	MainPartnerPos = 5,
	Event = {
		AutoWar = 1,
		AutoMagic = 2,
		StatusChange = 3, --血量，造型等
		AliveChange = 4,
		HeroBuff = 5,
		Prepare = 7,
		CommandStart = 8,
		SpeedInit = 9,
		SpeedChange = 10,
		PartnerChange = 11,
		Replace = 12,
		SP = 13,
		Pause = 14,
		CommandDone = 15,
		BoutEnd = 16,
		BoutStart = 17,
		ResultInfo = 18,
		StartWar = 19,
		EndWar = 20,
		OnTestStep = 21, -- 测试用
		StartTime = 22, --战斗开始时间
		PlaySpeed = 23, --战斗速速
		SectionStart = 24, --小回合开始
		SectionEnd = 25, --小回合结束
	},
	Atk_Distance = 1.5,

	Status = {
		Alive = 1,
		Died = 2,
	},
	Type= {
		NPC = 1,
		PVP = 2,
		Boss = 3,
		Pata = 4,
		EndlessPVE = 5,
		Arena = 6,
		Lilian = 7,
		EquipFuben = 8,
		AnLei = 9,
		OrgBoss = 10,
		EqualArena = 11,
		Terrawar = 12,
		YjFuben = 13,
		FieldBoss = 14,
		FieldBossPVP = 15,
		PEFuben = 16,
		ChapterFuBen = 17,
		Convoy = 18,
		TeamPvp = 19,
		MonsterAtkCity = 20,
		ShiMen = 21,
		BossKing = 22,--BOSS王
		DailyTrain = 23, --每日训练
		OrgWar = 24,
		ClubArena = 25,
		GuideBoss = 9001,--客户端自定义
		Guide1 = 10001,	--战役1-1
		Guide2 = 10004,	--战役1-2
		Guide3 = 14008,
		Guide4 = 10003,	--战役1-3
	},
	Buff_Sub = {
		BoutEnd = 1,
		Attack = 2,
	},
	Infinite_Buff_Bout = 255,
	ExceptViews = {"CYJFbResultView", "CEmojiLinkView", "CChatMainView", "CFriendMainView",
		"CForgeMainView", "CPartnerMainView", "CPartnerHireView", "CHuntPartnerSoulView",
		"CNpcShopView", "CScheduleMainView", "CRankView", "CAchieveMainView", "CWelfareView",
		"CLimitRewardView", "CPowerGuideMainView", "CSysSettingView", "CMingLeiTipsView"}
}
--Wave > Bout > Section
function CWarCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Root = nil
	self.m_ViewSide = nil --以哪一边的视角观看战斗
	self.m_IsPlayRecord = false -- 是否是录像
	self.m_IsClientRecord = false -- 是否是客户端录像
	self.m_LockPreparePartner = {} -- 锁定出场伙伴 ｛wartype-bool｝
	--测试用
	self.m_IsTestMode = false
	--测试用end---------------
	self.m_CanMoveNext = false
	self.m_NextStep = 0
	self:InitValue()
end

function CWarCtrl.IsVaildProto(self, iWarID)
	if (self.m_WarID ~= iWarID) or (self.m_EnterWar == false) then
		return false
	end
	return true
end

function CWarCtrl.InitValue(self)
	self.m_WarID = nil -- 战斗ID
	self.m_EnterWar= false
	self.m_WarType = nil --战斗类型
	self.m_IsInResult = false --是否在战斗结算界面
	self.m_WaitSectionStart = false --是否正在等待回合开始
	self.m_AllyCmap = nil --所处视角阵容ID
	self.m_HeroWid = nil --所处视角玩家战士ID
	self.m_HeroPid = nil --所处视角玩家pid
	self.m_Warriors = {} --所有战士
	self.m_InstanceID2Warrior = {}
	self.m_CmdList = {} --warcmd队列
	self.m_MainActionList = {} --存入单个action
	self.m_SubActionsDict = {} --存入actionlist，多个战士同时执行动作时使用
	self.m_CmdIdx = 0 --递增计数器
	self.m_ActionFlag = 0 --执行Action标记
	self.m_CurBout = 0 -- 回合数
	self.m_IsWarStart = true --是否刚刚开始战斗
	self.m_VaryCmd = nil
	self.m_IsPause = false
	self.m_HeroWid = nil
	self.m_AlreadyWarPartner = {} --已参战伙伴
	self.m_Pos2PartnerWid = {} --在战场中的伙伴
	self.m_SumWave = 0
	self.m_CurWave = 0
	self.m_EnemyNpcCnt = 0
	self.m_AnimSpeed = Utils.GetActiveSceneName() == "editorMagic" and 1 or tonumber(IOTools.GetRoleData("war_speed")) or 2
	self.m_SpeedList = {}
	self.m_SP = 0
	self.m_ForcePrepareDone = false
	self.m_IsReplace = false
	self.m_IsEscape = false
	--站位
	self.m_Lineup = 0 --站位0:默认,1:single,2:team,3:boss,4:yjfuben(lineup编辑器)
	self.m_AllyPlayerCnt = 0
	self.m_EnemyPlayerCnt = 0
	self.m_EnemyPartnerWids = {}
	self.m_AllyPartnerWids = {}
	self.m_ReplaceInfos = {}
	self.m_FillFullPos = false
	self.m_IsReceiveDone = false
	self.m_FakeIdx = 0
	self.m_CurSection = 0
	--当前协议
	self.m_ProtoWave = 0
	self.m_ProtoBout = 0
	self.m_ProtoSection = 0

	self.m_WarCmdIDList = {} -- 保证部分指令按顺序执行
	self.m_ReciveResultProto = false
	self.m_WillActWids = {} --每个回合将要操作的wid
	self.m_MagicInfos = {}
	self.m_BoutFloatInfo = {}
	self.m_BoutEnd = {}
	self.m_ResultInfo = {wid=nil, exp_list={}, item_list={}, desc="", resultspr=nil}
	self.m_ShowSceneEndWar = false
	self.m_WatchAnimSpeed = 1
	self.m_CacheWarBattleCmd = {}
	self.m_StartTime = nil
end

function CWarCtrl.IsCanChangeSpeed(self)
	if not self.m_WarID or not self.m_WarType then
		return false
	end
	if self:GetViewSide() then
		return true
	end
	--[[
	local types = define.War.Type
	if self.m_WarType == types.PVP or 
		self.m_WarType == types.FieldBossPVP or 
		self.m_WarType == types.Arena or
		self.m_WarType == types.EqualArena or
		self.m_WarType == types.TeamPvp or
		self.m_WarType == types.Guide3 or
		self.m_WarType == types.Terrawar then
		return false
	end
	if self.m_EnemyPlayerCnt > 0 then
		--用敌人是玩家判断
		return false
	end
	]]
	--[[
	if self.m_AllyPlayerCnt > 1 then
		--组队加速类型
		if self.m_WarType == types.NPC or 
			self.m_WarType == types.AnLei or
			self.m_WarType == types.YjFuben or 
			self.m_WarType == types.EndlessPVE or
			self.m_WarType == types.FieldBoss or 
			self.m_WarType == types.MonsterAtkCity then 
			return true
		end 
		return false
	end
	]]
	return true
end

function CWarCtrl.UpdateTimeScale(self)
	if (not self:IsCanChangeSpeed()) or 
		(not self:IsInAction()) or 
		self.m_IsInResult then
		UnityEngine.Time:SetTimeScale(1)
	else
		local iSpeed = 1
		if self:GetViewSide() then 
			iSpeed = math.max(1, self.m_WatchAnimSpeed*define.War.SpeedFactor)
		else
			iSpeed = math.max(1, self.m_AnimSpeed*define.War.SpeedFactor)
		end
		UnityEngine.Time:SetTimeScale(iSpeed)
	end
	self:OnEvent(define.War.Event.PlaySpeed)
end

function CWarCtrl.SetAnimSpeed(self, iSpeed)
	if self.m_AnimSpeed ~= iSpeed then
		self.m_AnimSpeed = iSpeed
		if g_TeamCtrl:IsJoinTeam() then
			if not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave(g_AttrCtrl.pid) then
				--不需要保存组队的加速
				return 
			end
		end
		self:SetPlaySpeedToServer(self.m_WarID, iSpeed)
		IOTools.SetRoleData("war_speed", iSpeed)
	end
	--self:UpdateTimeScale()
end

function CWarCtrl.SetPlaySpeedToServer(self, iSpeed)
	if self.m_WarID and g_LoginCtrl:HasLoginRole() then
		netwar.C2GSWarSetPlaySpeed(self.m_WarID, iSpeed)
	end
end

function CWarCtrl.GetAnimSpeed(self)
	return self.m_AnimSpeed
end

function CWarCtrl.AppendWarCmdID(self, id)
	self:RemoveWarCmdID(id)
	table.insert(self.m_WarCmdIDList, id)
end

function CWarCtrl.RemoveWarCmdID(self, id)
	local idx = table.index(self.m_WarCmdIDList, id)
	if idx then
		table.remove(self.m_WarCmdIDList, idx)
	end
end

function CWarCtrl.WaitWarCmdID(self, id)
	local first = self.m_WarCmdIDList[1]
	return first
end

function CWarCtrl.SetBoutFloatInfo(self, dFloatInfo)
	table.safeset(self.m_BoutFloatInfo, dFloatInfo, self.m_ProtoWave, self.m_ProtoBout)
end

function CWarCtrl.IsGuideWar(self)
	if self.m_WarType then
		return self.m_WarType > 10000
	else
		return false
	end
end

function CWarCtrl.IsAllPartnerDead(self)
	for i,oPartner in ipairs(g_PartnerCtrl:GetPartnerList()) do
		local iState = self:GetPartnerState(oPartner.m_ID)
		if iState ~= define.Partner.State.Died then
			return false
		end
	end
	return true
end

function CWarCtrl.SetLockPreparePartner(self, iWarType, bLock)
	self.m_LockPreparePartner[iWarType] = bLock
end

function CWarCtrl.IsLockPreparePartner(self)
	return self.m_LockPreparePartner[self.m_WarType]
end

function CWarCtrl.RefreshResultInfo(self, dPlayerExp, lPartnerExps, lItems, wintips, failtips, apply)
	self.m_ResultInfo.war_id = self.m_WarID
	local dInfo = WarTools.GetResultInfo(dPlayerExp, lPartnerExps, lItems)
	if self.m_ResultInfo.wintips == "" then
		dInfo.wintips = wintips
	end
	if self.m_ResultInfo.failtips == "" then
		dInfo.failtips = failtips
	end
	dInfo.apply = apply
	table.update(self.m_ResultInfo, dInfo)
	self:DelayEvent(define.War.Event.ResultInfo)
end

function CWarCtrl.SetResultValue(self, k, v)
	self.m_ResultInfo[k] = v
end

function CWarCtrl.IsPlayRecord(self)
	return self.m_IsPlayRecord
end

function CWarCtrl.IsClientRecord(self)
	return self.m_IsClientRecord
end

function CWarCtrl.GetViewSide(self)
	return self.m_ViewSide
end

function CWarCtrl.IsObserverView(self)
	return self.m_ViewSide == 1 or self.m_ViewSide == 2
end

function CWarCtrl.GetWarType(self)
	return self.m_WarType
end

function CWarCtrl.IsFirstWarrior(self)
	local oWarrior = self:GetWarrior(self.m_HeroWid)
	if oWarrior and oWarrior.m_CampPos == 1 then
		return true
	else
		return false
	end
end

function CWarCtrl.AddMagicInfo(self, atkid, vicids, maigic, idx, cmdid)
	local dSectionInfo = table.safeget(self.m_MagicInfos, self.m_ProtoWave, self.m_ProtoBout, self.m_ProtoSection)
	if not dSectionInfo then
		dSectionInfo = {info_list= {}}
	end
	local tInfo = {maigic=maigic, idx=idx, cmd_id = cmdid, atkid = atkid, vicids = vicids, is_end_idx = true, is_first_idx=true}
	local dLastInfo = dSectionInfo.info_list[#dSectionInfo.info_list]
	if dLastInfo then
		if dLastInfo.maigic == maigic then
			if idx ~= 1 then
				dLastInfo.is_end_idx = false
				--上一法术idx为1, 或上一法术不是first_idx则表是这是链式中个一个
				if dLastInfo.idx == 1 or (dLastInfo.is_first_idx == false) then
					tInfo.is_first_idx = false
				end
			end
		end
	end
	table.insert(dSectionInfo.info_list, tInfo)
	local iCurIndex = #dSectionInfo.info_list
	for k, vicid in ipairs(vicids) do
		local list = dSectionInfo[vicid] or {}
		table.insert(list, {cmd_id=cmdid, info_index=iCurIndex})
		dSectionInfo[vicid] = list
	end
	table.safeset(self.m_MagicInfos, dSectionInfo, self.m_ProtoWave, self.m_ProtoBout, self.m_ProtoSection)
end

function CWarCtrl.GetBoutMagicInfo(self, iCmd, iOffSet)
	local dSectionInfo = table.safeget(self.m_MagicInfos, self.m_CurWave, self.m_CurBout, self.m_CurSection)
	if dSectionInfo then
		for i, v in ipairs(dSectionInfo.info_list) do
			if v.cmd_id == iCmd then
				local idx = i + iOffSet
				local dInfo = dSectionInfo.info_list[idx]
				return dInfo
			end
		end
	end
end

--下一次施放法术的受击者
function CWarCtrl.GetNextCmdVics(self, iCmd)
	local dSectionInfo = table.safeget(self.m_MagicInfos, self.m_CurWave, self.m_CurBout, self.m_CurSection)
	local bFindNext = false
	local vics = {}
	if dSectionInfo then
		for i, v in ipairs(dSectionInfo.info_list) do
			if bFindNext then
				if v.vicids then
					vics = v.vicids
					break
				end
			elseif v.cmd_id == iCmd then
				bFindNext = true
			end
		end
	end
	return vics
end

function CWarCtrl.GetNexCmdRunTime(self, vic, cmdid)
	local dSectionInfo = table.safeget(self.m_MagicInfos, self.m_CurWave, self.m_CurBout, self.m_CurSection)
	if not dSectionInfo then
		return
	end
	local list = dSectionInfo[vic]
	if not list then
		return
	end
	local dCurInfo, dNexInfo
	for i, dInfo in ipairs(list) do
		if dInfo.cmd_id == cmdid then
			local idx = dInfo.info_index
			dCurInfo = dSectionInfo.info_list[idx]
			dNexInfo = dSectionInfo.info_list[idx+1]
			break
		end
	end
	if not (dCurInfo and dNexInfo) then
		return
	end
	if dCurInfo.atkid == dNexInfo.atkid then
		return
	end
	local time1 = g_MagicCtrl:GetMagcAnimEndTime(dCurInfo.maigic, dCurInfo.idx)
	if time1 then
		local time2 = g_MagicCtrl:GetMagcAnimStartTime(dNexInfo.maigic, dNexInfo.idx)
		if time2 then
			local time = math.max(0, time1 - time2)
			print("当前技能", dCurInfo.maigic, "下一技能", dNexInfo.maigic)
			return time
		end
	end
end


function CWarCtrl.SetInResult(self, bResult)
	self.m_IsInResult = bResult
end

function CWarCtrl.GetFakeWid(self)
	self.m_FakeIdx = self.m_FakeIdx - 1
	return self.m_FakeIdx
end

function CWarCtrl.GetWillActWids(self, bAlly)
	local list = {}
	-- if g_WarOrderCtrl:IsCanOrder() then
		-- for i, oWarrior in pairs(self:GetWarriors()) do
			-- if oWarrior and ((not bAlly) or (oWarrior:IsAlly() == bAlly)) and g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID) then
				-- table.insert(list, oWarrior.m_ID)
			-- end
		-- end
		-- table.sort(list, WarTools.GetSortFuncSpeed(false))
	-- else
	-- 	local lBoutWids = table.safeget(self.m_WillActWids, self.m_CurWave, self.m_CurBout)
	-- 	if lBoutWids then
	-- 		for i, wid in ipairs(lBoutWids) do
	-- 			local oWarrior = self:GetWarrior(wid)
	-- 			if oWarrior and ((not bAlly) or (oWarrior:IsAlly() == bAlly)) then
	-- 				table.insert(list, wid)
	-- 			end
	-- 		end
	-- 	end
	-- end
	for i, info in ipairs(self.m_SpeedList) do
		local oWarrior  = self:GetWarrior(info.wid)
		if oWarrior then
			table.insert(list, {wid=oWarrior.m_ID, action=info.action})
		end
	end
	return list
end

function CWarCtrl.SetSpeedList(self, speedList)
	self.m_SpeedList = speedList
	for i, info in ipairs(speedList) do
		local oWarrior = self:GetWarrior(info.wid)
		if oWarrior then
			oWarrior:SetSpeed(info.speed)
			oWarrior:SetActionDone(info.action == 1)
		end
	end
	--self:DelayEvent(define.War.Event.SpeedInit) --没发现有地方响应SpeedInit，暂时屏蔽
	self:DelayEvent(define.War.Event.SpeedChange)
end

function CWarCtrl.ShowSceneEndWar(self)
	if self:IsWar() then
		local oCmd = CWarCmd.New("End")
		g_WarCtrl:InsertCmd(oCmd)
		self.m_ShowSceneEndWar = true
		self.m_IsReceiveDone = true
		g_NetCtrl:SetCacheProto("warend", true)
		if g_NetCtrl:IsRecord() and Utils.IsEditor() then
			if not self:IsClientRecord() then
				g_NetCtrl:SaveRecordsToLocal("war"..os.date("%y_%m_%d(%H_%M_%S)", g_TimeCtrl:GetTimeS()), {side=self:GetAllyCamp()})
			end
			g_NetCtrl:SetRecordType(nil)
		end
	end
end

function CWarCtrl.SetVaryCmd(self, oCmd)
	self.m_VaryCmd = oCmd
end

function CWarCtrl.GetVaryCmd(self)
	return self.m_VaryCmd
end

function CWarCtrl.Clear(self)
	for i, oWarrior in pairs(self.m_Warriors) do
		oWarrior:Destroy()
	end
	if self.m_LoadingBg then
		self.m_LoadingBg:Destroy()
	end
	self:InitValue()
end

function CWarCtrl.IsWar(self)
	return self.m_WarID ~= nil
end

function CWarCtrl.GetWarID(self)
	return self.m_WarID
end

function CWarCtrl.StopCachedProto(self)
	g_NetCtrl:SetCacheProto("warend", false)
	g_NetCtrl:ClearCacheProto("warend", true)
end

function CWarCtrl.SimulateMagicCmd(self, magicid, idx, bInsert, oRefCmd, start_func, end_func)
	local oCmd = CWarCmd.New("Magic")
	oCmd.atkid_list = {self.m_HeroWid}
	oCmd.vicid_list = {}
	oCmd.magic_id = magicid
	oCmd.magic_index = idx
	oCmd.ref_war_cmd = oRefCmd
	oCmd.start_func = start_func
	oCmd.end_func = end_func
	printc("SimulateMagicCmd->", magicid, idx, bInsert, start_func, end_func)
	if bInsert then
		self:InsertCmd(oCmd)
	else
		oCmd:Excute()
	end
end

function CWarCtrl.Start(self, iWarID, iWarType)
	if g_HouseCtrl:IsInHouse() then
		g_HouseCtrl.m_House:Destroy()
		g_HouseCtrl.m_House = nil
		g_HouseCtrl.m_IsInHouse = false
		g_DialogueAniCtrl:StopAllDialogueAni()
		g_ViewCtrl:CloseAll()
		g_HouseCtrl:SetPushing(false)
	end
	self:Clear()
	if self.m_IsTestMode and CTestWarView:GetView() == nil then
		CTestWarView:ShowView()
	end
	local oCamera = g_CameraCtrl:GetWarCamera()
	if oCamera then
		oCamera:SetFieldOfView(26)
	end
	
	g_ResCtrl:MoveToSecondary()
	Utils.SetShaderLight("war")
	WarTools.ClearDebugInfo()
	g_WarTouchCtrl:SetLock(false)
	g_WarOrderCtrl:InitValue()
	g_SysSettingCtrl:SetSolveKaJiEnabled(false)
	self.m_WarID = iWarID
	self.m_WarType = iWarType
	self:StopCachedProto()
	g_NetCtrl:SetCacheProto("waring", true)
	g_MapCtrl:Clear(false)
	g_MagicCtrl:Clear("war")
	if self.m_WarType == define.War.Type.BossKing then
		g_CameraCtrl:PlayAction("guide_boss")
	else
		g_CameraCtrl:PlayAction("war_default")
	end
	
	self:SwitchEnv(true)
	self.m_ActionFlag = 1
	self.m_IsWarStart = true
	self.m_HasGC = false
	self.m_IsClientRocord = g_NetCtrl:IsProtoRocord()
	self:LoadWarMap()
	g_GuideCtrl:StopWar5Guide()
	g_GuideCtrl:ResetAutoWarGuide()
	g_GuideCtrl:TriggerCheck("war")


	if iWarType == define.War.Type.PEFuben then
		g_ActivityCtrl:GetPEFbCtrl():SetEndCallback()
	end

	if self:IsCanChangeSpeed() and not self:GetViewSide() then
		if g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsLeader() then 
			self:SetPlaySpeedToServer(self.m_WarID, 2)
		elseif not g_TeamCtrl:IsJoinTeam() then
			self:SetPlaySpeedToServer(self.m_WarID, self:GetAnimSpeed())
		end
	end
	self:OnEvent(define.War.Event.StartWar)
end

function CWarCtrl.LoadWarMap(self)
	if self.m_WarType == define.War.Type.Arena or self.m_WarType == define.War.Type.EqualArena then
		g_MapCtrl:Load(5010, 1)
	elseif self.m_WarType == define.War.Type.Pata or self.m_WarType == define.War.Type.EquipFuben then
		g_MapCtrl:Load(5000, 1)
	elseif self.m_WarType == define.War.Type.GuideBoss then
		g_MapCtrl:Load(5090, 1)
	elseif self.m_WarType == define.War.Type.BossKing then
		g_MapCtrl:Load(5090, 1)
	else
		g_MapCtrl:Load(5020, 1)
	end
end

function CWarCtrl.End(self)
	if not self:IsWar() then
		return
	end
	if self.m_ViewSide then
		if self.m_IsClientRecord then
			g_NetCtrl:ResetReceiveRecord()
			netplayer.C2GSLeaveWatchWar()
		end
	end
	UITools.ShowUI()
	local obj = g_MapCtrl:GetCurMapObj()
	if obj then
		obj:SetActive(true)
	end
	local oCam = g_CameraCtrl:GetWarCamera()
	oCam:SetBackgroudColor(Color.black)
	g_MagicCtrl:Clear("war")
	g_HudCtrl:SetRootActive(true)
	if g_WarCtrl.m_WarType == define.War.Type.GuideBoss then
		g_HudCtrl:SetPanelActive("CBloodHud", true)
	else
		self:SectionHudShow(true)
	end
	self:Clear()
	self:SwitchEnv(false)
	self:CheckWarEndAfterCallback()
	self:StopCachedProto()
	g_NetCtrl:SetCacheProto("waring", false)
	g_NetCtrl:ClearCacheProto("waring", true)
	if self:IsPlayRecord() then
		self.m_IsPlayRecord = false
		g_NetCtrl:ResetReceiveRecord()
	end
	self.m_ViewSide = nil
	g_GuideCtrl:TriggerCheck("war")
	self:OnEvent(define.War.Event.EndWar)
	self:UpdateTimeScale()
end


function CWarCtrl.SwitchEnv(self, bWar)
	-- --像机
	-- g_CameraCtrl:AutoActive()
	g_ViewCtrl:CloseAll(define.War.ExceptViews, not bWar)
	
	if bWar then
		if not g_WarCtrl:IsPlayRecord() then
			CWarFloatView:ShowView()
		end
		if self:GetViewSide() then
			CWarWatchView:ShowView()
		else
			CWarMainView:ShowView()
		end
	else
		CMainMenuView:ShowView(function ()
			self:AfterMainMenuViewShow()
		end)
	end
	g_AnLeiCtrl:SwitchEnv(bWar)
	g_EquipFubenCtrl:SwitchEnv(bWar)
	g_PataCtrl:SwitchEnv(bWar)
	g_ActivityCtrl:DCSwitchEnv(bWar)
	g_GuideCtrl:SwitchEnv(bWar)
end

function CWarCtrl.SetWarEndAfterCallback(self, cb)
	self.m_WarEndAfterCallback = cb
end

function CWarCtrl.CheckWarEndAfterCallback(self)
	if self.m_WarEndAfterCallback then
		self.m_WarEndAfterCallback()
		self.m_WarEndAfterCallback = nil
	end
end

function CWarCtrl.GetRoot(self)
	if Utils.IsNil(self.m_Root) then
		self.m_Root = CWarRoot.New()
		self.m_Root:SetOriginPos(Vector3.zero)
	end
	return self.m_Root
end

function CWarCtrl.AddWarrior(self, wid, oWarrior)
	if self.m_Warriors[wid] then
		self.m_Warriors[wid]:Destroy()
	end
	local iOldWid = self.m_Pos2PartnerWid[oWarrior.m_CampPos]
	if iOldWid and iOldWid < 0 then
		self:DelWarrior(iOldWid)
	end
	local oRoot = self:GetRoot()
	oWarrior:SetParent(oRoot.m_Transform, false)
	self.m_Warriors[wid] = oWarrior
	self.m_InstanceID2Warrior[oWarrior:GetInstanceID()] = oWarrior
	self.m_ReplaceInfos[wid] = nil
	local bProcessAnim = false
	if oWarrior.m_Type == define.Warrior.Type.Partner then
		if oWarrior.m_OwnerWid == self.m_HeroWid then
			self.m_Pos2PartnerWid[oWarrior.m_CampPos] = oWarrior.m_ID
			if not table.index(self.m_AlreadyWarPartner, oWarrior.m_PartnerID) then
				table.insert(self.m_AlreadyWarPartner, oWarrior.m_PartnerID)
			end
			if g_WarOrderCtrl:IsCanOrder() then
				g_WarOrderCtrl:AddWaitWid(wid)
				g_WarOrderCtrl:ShowNext()
			end
			if oWarrior:IsAlive() then
				bProcessAnim = true
				oWarrior:CrossFade("show")
			end
			self:DelayEvent(define.War.Event.PartnerChange)
			self:DelayEvent(define.War.Event.SpeedChange)
		end
	end
	if oWarrior:IsAlive() then
		oWarrior:Play("idleWar")
	else
		oWarrior:Die(1)
	end
	oWarrior:UpdateOriginPos()
	oWarrior:CheckWarBattleCmd()
	g_WarOrderCtrl:DelayCall(0.1, "ShowSelectTarget")
end

function CWarCtrl.ReplacePartner(self, wid, parid)
	local oWarrior = self:GetWarrior(wid)
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	local dReplaceInfo = self.m_ReplaceInfos[wid]
	local bReplace = true
	if dReplaceInfo then
		if dReplaceInfo.parid == parid then
			self:ResumeWarrior(wid, dReplaceInfo)
			bReplace=false
		end
	else
		dReplaceInfo = {name=oWarrior:GetName(), model_info=oWarrior:GetCurDesc(), parid=oWarrior.m_PartnerID, state=oWarrior:GetState()}
		self.m_ReplaceInfos[wid]= dReplaceInfo
	end
	if bReplace then
		local dModelInfo = oPartner:GetValue("model_info")
		oWarrior.m_PartnerID = parid
		oWarrior:SetMatColor(Color.white)
		oWarrior:ChangeShape(dModelInfo.shape, dModelInfo)
		oWarrior:CrossFade("show")
		oWarrior:SetName(oPartner:GetValue("name"))
	end
	self:DelayEvent(define.War.Event.PartnerChange)
	self:DelayEvent(define.War.Event.SpeedChange)
end

function CWarCtrl.IsInReplceInfos(self, parid)
	for wid, info in pairs(self.m_ReplaceInfos) do
		if info.parid == parid then
			return true
		end
	end
	return false
end

function CWarCtrl.ResumeAfterReplace(self)
	for wid, dInfo in pairs(self.m_ReplaceInfos) do
		self:ResumeWarrior(wid, dInfo)
	end
	self.m_ReplaceInfos = {}
	for wid, oWarrior in pairs(self.m_Warriors) do
		if wid < 0 then
			self:DelWarrior(wid)
		end
	end
end

function CWarCtrl.ResumeWarrior(self, wid, dInfo)
	local oWarrior = self:GetWarrior(wid)
	if oWarrior then
		oWarrior.m_PartnerID = dInfo.parid
		local model_info = dInfo.model_info
		if model_info then
			oWarrior:ChangeShape(model_info.shape, model_info)
			oWarrior:Play(dInfo.state, 1)
		end
		oWarrior:SetName(dInfo.name)
	end
end

function CWarCtrl.GetPartnerWid(self, parid)
	for pos, wid in pairs(self.m_Pos2PartnerWid) do
		local oWarrior = self:GetWarrior(wid)
		if oWarrior and oWarrior.m_PartnerID == parid then
			return wid
		end
	end
end

function CWarCtrl.GetPartnerState(self, parid)
	for pos, wid in pairs(self.m_Pos2PartnerWid) do
		local oWarrior = self:GetWarrior(wid)
		if oWarrior then
			if oWarrior.m_PartnerID == parid then
				return define.Partner.State.InWar
			end
		end
	end
	if table.index(self.m_AlreadyWarPartner, parid) then
		return define.Partner.State.AlreadyWar
	end
	if self.m_WarType == define.War.Type.Pata then
		local oPartner = g_PartnerCtrl:GetPartner(parid)
		if oPartner	then
			local hp = oPartner:GetValue("patahp") or 0
			if hp <= 0 then
				return define.Partner.State.Died
			end
		end
	end
end

--战场中的伙伴
function CWarCtrl.GetPartnersInWar(self, bRealPartner)
	local list = {}
	for pos, wid in pairs(self.m_Pos2PartnerWid) do
		local wid = self.m_Pos2PartnerWid[pos]
		local oWarrior = self:GetWarrior(wid)
		if oWarrior and oWarrior.m_PartnerID and oWarrior.m_PartnerID > 0 
			and oWarrior.m_OwnerWid == self.m_HeroWid then
			table.insert(list, {pos=pos, parid=oWarrior.m_PartnerID, wid=wid})
		end
	end
	return list
end

function CWarCtrl.GetHero(self)
	if self.m_HeroWid then
		return self.m_Warriors[self.m_HeroWid]
	end
end

function CWarCtrl.GetHeroPid(self)
	if self.m_HeroPid then
		return self.m_HeroPid
	elseif not self:GetViewSide() then
		return g_AttrCtrl.pid
	else
		return 0
	end
end

function CWarCtrl.GetAllyCamp(self)
	return self.m_AllyCmap
end

function CWarCtrl.DelWarrior(self, wid)
	if wid == self.m_HeroWid then
		self.m_HeroWid = nil
	end
	if self.m_ReplaceInfos[wid] then
		self.m_ReplaceInfos[wid] = nil
	end
	if g_WarOrderCtrl:IsCanOrder() then
		g_WarOrderCtrl:DelWaitWid(wid)
	end
	local oWarrior = self.m_Warriors[wid]
	if oWarrior then
		if oWarrior.m_PartnerID and oWarrior.m_OwnerWid == self.m_HeroWid then
			if self.m_Pos2PartnerWid[oWarrior.m_CampPos] == wid then
				self.m_Pos2PartnerWid[oWarrior.m_CampPos] = nil
			end
		end
		if self.m_ProtoBout == 0 then
			local idx = table.index(self.m_AlreadyWarPartner, oWarrior.m_PartnerID)
			if idx then
				table.remove(self.m_AlreadyWarPartner, idx)
			end
		end
		self:DelayEvent(define.War.Event.PartnerChange)
		self.m_InstanceID2Warrior[oWarrior:GetInstanceID()] = nil
		oWarrior:Destroy()
	end
	self.m_Warriors[wid] = nil
end

function CWarCtrl.GetWarriors(self)
	return self.m_Warriors
end

function CWarCtrl.GetWarrior(self, wid)
	return self.m_Warriors[wid]
end

function CWarCtrl.FindWarrior(self, findFunc)
	for i, oWarrior in pairs(self.m_Warriors) do
		if findFunc(oWarrior) then
			return oWarrior
		end
	end
end

function CWarCtrl.FindWarriors(self, findFunc)
	local list = {}
	for i, oWarrior in pairs(self.m_Warriors) do
		if findFunc(oWarrior) then
			table.insert(list, oWarrior)
		end
	end
	return list
end

function CWarCtrl.CheckWarBossView(self)
	local warshow = {
		define.War.Type.NPC,
		define.War.Type.Pata,
		define.War.Type.Lilian,
		define.War.Type.EquipFuben,
		define.War.Type.AnLei,
		define.War.Type.Boss,
		define.War.Type.OrgBoss,
		define.War.Type.FieldBoss,
		define.War.Type.FieldBossPVP,
		define.War.Type.PEFuben,
		define.War.Type.ChapterFuBen,
		define.War.Type.GuideBoss,
		define.War.Type.BossKing,
		define.War.Type.Guide1,
		define.War.Type.Guide2,
		define.War.Type.Guide3,
		define.War.Type.MonsterAtkCity,
		define.War.Type.YjFuben,
	}
	if not self:IsObserverView() and table.index(warshow, self.m_WarType) then
		local bossWarrior = self:FindWarrior(function(oWarrior)
				return oWarrior:IsNpcWarriorTypeBoss()
			end) 
		if bossWarrior then
			CWarBossView:ShowView(function (oView)
				oView:SetWarType(self.m_WarType)
				oView:SetBossWarrior(bossWarrior)
			end)
		
		elseif self.m_WarType == define.War.Type.FieldBossPVP then
			CWarBossView:ShowView(function (oView)
				oView:SetWarType(self.m_WarType)
			end)
		else
			CWarBossView:CloseView()
		end
	end
end

--是否正在播放回合动画
function CWarCtrl.IsInAction(self)
	return (self.m_ActionFlag > 0 or self.m_ShowSceneEndWar) and self.m_IsReceiveDone
end

function CWarCtrl.SetPause(self, bPause)
	if self.m_IsPause ~= bPause then
		self.m_IsPause = bPause
		self:OnEvent(define.War.Event.Pause)
	end
end

function CWarCtrl.IsPause(self)
	return self.m_IsPause
end

function CWarCtrl.SetPrepare(self, bPrepare, Secs)
	if bPrepare then
		for _, oWarrior in pairs(self.m_Warriors) do
			if oWarrior.m_Pid then
				oWarrior:SetReady(false)
			end
		end

		Secs = Secs or 15
		self.m_PrepareInfo = {start_time=g_TimeCtrl:GetTimeS(), prepare_time = Secs}
		self:FillEmptyPos()
	else
		self.m_PrepareInfo = nil
	end
	self:SetReplace(bPrepare)
end

function CWarCtrl.FillEmptyPos(self)
	local lPos = {}
	if self.m_WarType == define.War.Type.TeamPvp then
		local checkPos = 3
		if not self:IsFirstWarrior() then
			checkPos = 4
		end
		local wid = self.m_Pos2PartnerWid[checkPos]
		if not wid then
			table.insert(lPos, checkPos)
		end
	else
		if not self:IsFirstWarrior() then
			return
		end
		
		if self.m_AllyPlayerCnt > 1 then
			for i=3, 4 do
				if self.m_AllyPlayerCnt < i then
					local wid = self.m_Pos2PartnerWid[i]
					if not wid then
						table.insert(lPos, i)
					end
				end
			end
			local iMainPartnerPos = 5 --主战伙伴位
			local wid = self.m_Pos2PartnerWid[iMainPartnerPos]
			if not wid then
				table.insert(lPos, iMainPartnerPos)
			end
		else
			for i=2, 5 do
				local wid = self.m_Pos2PartnerWid[i]
				if not wid then
					table.insert(lPos, i)
				end
			end
		end
	end
	local iMax = self:GetMaxFightAmount()
	local max2list = {[2] = {3, 4}, [3] = {4}}
	for i, iPos in ipairs(lPos) do
		local wid = self:GetFakeWid()
		local oFakeWarrior = CWarrior.New(wid)
		oFakeWarrior.m_PartnerID = wid
		oFakeWarrior.m_OwnerWid = self.m_HeroWid
		oFakeWarrior.m_Type = define.Warrior.Type.Partner
		oFakeWarrior.m_CampID = self:GetAllyCamp()
		oFakeWarrior.m_CampPos = iPos
		oFakeWarrior:SetName("站位"..tostring(iPos))
		oFakeWarrior:ShowReplaceActor()
		oFakeWarrior:UpdateOriginPos()
		if max2list[iMax] then
			if table.index(max2list[iMax], iPos) then
				local level = data.roletypedata.FightAmount[iPos].level
				oFakeWarrior:SetLockTag(true, level)
				oFakeWarrior.m_OwnerWid = nil
			end
		end
		self:AddWarrior(wid, oFakeWarrior)
	end
end

function CWarCtrl.GetLockReplaceTip(self)
	local grade = g_AttrCtrl.grade
	local iAmount = 0
	for i = 1, 4 do
		local level = data.roletypedata.FightAmount[i].level
		if grade < level then
			return string.format("主角达到%d级可出战第%d个伙伴", level, i)
		end
	end
	return
end

function CWarCtrl.GetMaxFightAmount(self)
	local grade = g_AttrCtrl.grade
	local iAmount = 0
	for i = 1, 4 do
		if grade >= data.roletypedata.FightAmount[i].level then
			iAmount = iAmount +1
		end
	end
	return iAmount
end

function CWarCtrl.SetReplace(self, bReplace)
	local bCheckReplace = false
	if self.m_IsReplace ~= bReplace then
		bCheckReplace = true
		if bReplace then
			g_CameraCtrl:PlayAction("war_replace")
		else
			g_CameraCtrl:PlayAction("war_replace_end")
		end
		self.m_IsReplace = bReplace
	end
	self:DelayEvent(define.War.Event.Replace)
end

function CWarCtrl.CheckReplace(self, bCheck)
	for i, oWarrior in pairs(self.m_Warriors) do
		if oWarrior:IsAlly() then
			local bReplace = bCheck and oWarrior:IsCanReplace()
			if bReplace then
				oWarrior:AddBindObj("warrior_replace")
			else
				oWarrior:DelBindObj("warrior_replace")
			end
		end
	end
end

function CWarCtrl.HeroPrepareDone(self, Secs)
	if self.m_PrepareInfo then
		self.m_PrepareInfo.prepare_time = 0
	end
	self:SetReplace(false)
	self.m_FillFullPos = false
end

function CWarCtrl.IsPrepare(self)
	return self.m_PrepareInfo ~= nil
end

function CWarCtrl.IsReplace(self)
	return self.m_IsReplace
end

function CWarCtrl.GetRemainPrepareTime(self)
	if self.m_PrepareInfo then
		local iRemain = self.m_PrepareInfo.prepare_time - (g_TimeCtrl:GetTimeS() - self.m_PrepareInfo.start_time)
		return iRemain
	else
		return nil
	end
end

function CWarCtrl.CommandStart(self, wid)
	self:OnEvent(define.War.Event.CommandStart, wid)
end

--是否刚刚开始战斗
function CWarCtrl.IsWarStart(self)
	return self.m_IsWarStart
end

function CWarCtrl.RefreshAllPos(self)
	--刷新全部站位
	printc("刷新全部站位, ", self.m_WarType)
	for wid, oWarrior in pairs(self.m_Warriors) do
		oWarrior:UpdateOriginPos()
	end
	table.print(self.m_AllyPartnerWids, "ally_player:"..tostring(self.m_AllyPlayerCnt))
	table.print(self.m_EnemyPartnerWids, "enemy_player:"..tostring(self.m_EnemyPlayerCnt))
end

function CWarCtrl.CheckActivityView(self)
	--观战模式不显示血条
	if self:IsObserverView() then
		return
	end
end

function CWarCtrl.BoutStart(self, iBout)
	self.m_CurBout = iBout
	self:BoutWarrior(self.m_IsWarStart)
	if self:GetNewWaveTag() then
		self:CheckWarBossView() --新回合要重新检测是否有boss怪
		self:UpdateNewWaveTag(false)
	elseif self.m_WarType == define.War.Type.FieldBossPVP then
		self:CheckWarBossView()
	elseif self:IsGuideBoss() or self.m_WarType == define.War.Type.BossKing then
		g_CameraCtrl:PlayAction("guide_boss")
		self.m_Root:CheckObj()
	end
	local oView = CWarMainView:GetView()
	if oView then
		oView.m_LT:Bout()
	end
	self:DelayEvent(define.War.Event.BoutStart)
end

function CWarCtrl.BoutEnd(self, iBout)
	self.m_Bout = iBout
	self:DelayEvent(define.War.Event.BoutEnd)
end

function CWarCtrl.SectionHudShow(self, bShow)
	-- g_HudCtrl:SetPanelActive("CNameHud", bShow)
	-- g_HudCtrl:SetPanelActive("CStarGridHud", bShow)
end

function CWarCtrl.SectionStart(self, iSection, iOrderId, iOrderTime)
	g_HudCtrl:SetRootActive(true)
	if g_WarCtrl.m_WarType ~= define.War.Type.GuideBoss then
		self:SectionHudShow(true)
	end
	if not self.m_ForcePrepareDone then
		self.m_ForcePrepareDone = true
		self:SetPrepare(false)
		self:HeroPrepareDone()
	end
	if self.m_IsWarStart then
		self.m_ActionFlag = 0
		self.m_IsWarStart = false
		self:RefreshAllPos()
		self:CheckActivityView()
		UITools.ShowUI()
		CMainMenuView:ShowView(function ()
			self:AfterMainMenuViewShow()
		end)
	elseif self.m_CurSection ~= iSection then
		self.m_ActionFlag = self.m_ActionFlag - 1
	end
	self.m_CurSection = iSection
	--如果是录像则已经有了boutend，从缓存中取出执行
	local endfunc = table.safeget(self.m_BoutEnd, self.m_CurWave, self.m_CurBout, self.m_CurSection)
	if endfunc then 
		endfunc()
		self.m_ActionFlag = math.max(1, self.m_ActionFlag - 1)
	end
	local oWarrior = g_WarCtrl:GetWarrior(iOrderId)
	if oWarrior then
		if not self:IsInAction() and iOrderTime > 0 then
			if not endfunc then
				g_WarOrderCtrl:SetCurOrderWid(iOrderId)
				oWarrior:SetOrderDone(false)
				g_WarOrderCtrl:OrderStart(iOrderTime, oWarrior)
			end
		end
	end

	WarTools.Print("SectionStart ", self.m_CurWave, self.m_CurBout, self.m_CurSection, "flag:", self.m_ActionFlag)
	WarTools.ClearDebugInfo()
	-- g_GuideCtrl:CheckStartWarReplaceGuide(iBout)
	self:UpdateTimeScale()
	self:DelayEvent(define.War.Event.SectionStart)
end

function CWarCtrl.SectionEnd(self, iSection)
	if self.m_IsWarStart then
		self.m_ActionFlag = 1
		self.m_IsWarStart = false
		self:CheckActivityView()
		UITools.ShowUI()
		CMainMenuView:ShowView(function ()
			self:AfterMainMenuViewShow()
		end)
	else
		self.m_ActionFlag = self.m_ActionFlag + 1
	end

	local function process()
		for wid, oWarrior in pairs(self.m_Warriors) do
			if oWarrior:IsAlly() then
				oWarrior:SetOrderDone(true)
			end
		end
		self:SetReplace(false, true)
		g_WarOrderCtrl:FinishOrder()
		self:SetPause(false)

		if iSection then 
			self.m_CurSection = iSection
		end
		printc("SectionEnd.process", self.m_CurBout , self.m_CurWave)
		if self.m_WarType == define.War.Type.GuideBoss then
			g_HudCtrl:SetPanelActive("CBloodHud", false)
		else
			self:SectionHudShow(false)
		end
		-- self:DelayEvent(define.War.Event.SpeedChange)
		self:DelayEvent(define.War.Event.SectionEnd)
		self:UpdateTimeScale()
	end
	iSection = iSection or self.m_ProtoSection
	printc("SectionEnd !!", iSection, self.m_CurSection, self.m_CurBout, self.m_ProtoBout, self.m_CurWave, self.m_ProtoWave, "flag:", self.m_ActionFlag)
	if (self.m_CurWave == self.m_ProtoWave) and (self.m_CurBout == self.m_ProtoBout) and (self.m_CurSection == iSection)then
		process()
	else
		table.safeset(self.m_BoutEnd, process, self.m_ProtoWave, self.m_ProtoBout, iSection)
	end
end

function CWarCtrl.IsGuideBoss(self)
	if self.m_WarType == define.War.Type.GuideBoss then
		return true
	end
	return false
end

function CWarCtrl.BoutWarrior(self, dontBoutCD)
	self:ResumeAfterReplace()
	for wid, oWarrior in pairs(self.m_Warriors) do
		-- if oWarrior:IsAlly() and not oWarrior.m_IsSummon then
		-- 	oWarrior:SetOrderDone(false)
		-- end
		oWarrior:Bout(dontBoutCD)
	end
end

function CWarCtrl.GetBout(self)
	return self.m_CurBout 
end

function CWarCtrl.SetWave(self, curWave, sumWave)
	-- printc(string.format("SetWave:%s/%s", curWave, sumWave))
	self.m_SumWave = sumWave
	self.m_CurWave = curWave
end

--每次新的波次的第一个回合置为true
function CWarCtrl.UpdateNewWaveTag(self, bNewWave)
	printc(string.format("UpdateNewWaveTag:%s", bNewWave))
	self.m_NewWaveTag = bNewWave
end

function CWarCtrl.GetNewWaveTag(self)
	return self.m_NewWaveTag
end

function CWarCtrl.GetWaveText(self)
	if self.m_SumWave == 0 and self.m_CurWave == 0 then
		return nil
	elseif self.m_SumWave == 0 then
		return string.format("第%s波", self.m_CurWave)
	else
		return string.format("第%s/%s波", self.m_CurWave, self.m_SumWave)
	end
end

function CWarCtrl.GetLinupPos(self, isAlly, iPos)
	local iAlly = isAlly and 1 or 2
	local iMemberCnt
	local sType = "team"
	local iParCnt = nil
	if isAlly then
		iMemberCnt = math.min(self.m_AllyPlayerCnt, 4)
	else
		if self.m_WarType == define.War.Type.PVP then
			iMemberCnt = self.m_EnemyPlayerCnt
		elseif self.m_WarType == define.War.Type.Arena 
			or self.m_WarType == define.War.Type.EqualArena 
			or self.m_WarType == define.War.Type.Terrawar 
			or self.m_WarType == define.War.Type.ClubArena then
			if self.m_EnemyPlayerCnt > 0 then
				iMemberCnt = self.m_EnemyPlayerCnt
			else
				iMemberCnt = 1
				iParCnt = self.m_EnemyNpcCnt - 1
			end
		elseif self.m_WarType == define.War.Type.Boss then
			sType = "boss"
			iMemberCnt = 4
		elseif self.m_WarType == define.War.Type.YjFuben then
			sType = "yjfuben"
			iMemberCnt = 4
		elseif self.m_WarType == define.War.Type.GuideBoss then
			sType = "guideboss"
			iMemberCnt = 4
		elseif self.m_WarType == define.War.Type.BossKing then
			sType = "guideboss"
			iMemberCnt = 4
		else
			sType = data.lineupdata.LINEUP_TYPE[self.m_Lineup] or "team"
			iMemberCnt = 4
		end
	end

	local sKey, xzpos
	if iMemberCnt > 1 then
		xzpos = table.safeget(data.lineupdata.PRIOR_POS, sType, iMemberCnt, iAlly, iPos)
		if not xzpos then
			sKey = data.lineupdata.GRID_POS_KEY["team"][iMemberCnt][iAlly][iPos]
		end
	else
		if not iParCnt and not self.m_FillFullPos then
			if isAlly then
				iParCnt = table.count(self.m_AllyPartnerWids)
			else
				iParCnt = table.count(self.m_EnemyPartnerWids)
			end
		end
		if not iParCnt then
			iParCnt = 4
		end
		xzpos = table.safeget(data.lineupdata.PRIOR_POS, "single", iParCnt+1, iAlly, iPos)
		if not xzpos then
			sKey = data.lineupdata.GRID_POS_KEY["single"][iParCnt+1][iAlly][iPos]
		end
	end
	
	if xzpos then
		print("自定义站位", iPos,  xzpos.x, xzpos.z)
		return Vector3.New(xzpos.x, 0,xzpos.z)
	elseif sKey then
		print("格子站位, isAlly:",isAlly,"iPos:",iPos,"pos_key:",sKey)
		xzpos = data.lineupdata.GRID_POS_MAP[sKey]
		return Vector3.New(xzpos.x, 0,xzpos.z)
	else
		print(string.format("linup pos err: iAlly: %s, iMemberCnt:%s, iParCnt:%s, self.m_EnemyPlayerCnt:%s, self.m_AllyPlayerCnt:%s", iAlly, iMemberCnt, iParCnt, self.m_EnemyPlayerCnt, self.m_AllyPlayerCnt))
		table.print(self.m_AllyPartnerWids, "m_AllyPartnerWids")
		table.print(self.m_EnemyPartnerWids, "m_EnemyPartnerWids")
		return Vector3.zero
	end
end

function CWarCtrl.IsAllExcuteFinish(self)
	local bFinish = not g_MagicCtrl:IsExcuteMagic()
	if bFinish then
		for i, oWarrior in pairs(self.m_Warriors) do
			if oWarrior:IsBusy() then
				bFinish = false
				break
			end
		end
	end
	return bFinish
end

function CWarCtrl.GetCmds(self)
	return self.m_CmdList
end

function CWarCtrl.InsertCmd(self, oCmd)
	table.insert(self.m_CmdList, oCmd)
end

function CWarCtrl.CreateAction(self, func, ...)
	return {func, {...}, select("#", ...)}
end

function CWarCtrl.InsertAction(self, func, ...)
	local action = self:CreateAction(func, ...)
	table.insert(self.m_MainActionList, action)
end

function CWarCtrl.InsertActionFirst(self, func, ...)
	local action = self:CreateAction(func, ...)
	table.insert(self.m_MainActionList, 1, action)
end

function CWarCtrl.AddSubActionList(self, list, id)
	id = id or Utils.GetUniqueID()
	self.m_SubActionsDict[id] = list
	return id
end

function CWarCtrl.MoveActionListMainToSub(self)
	local id = Utils.GetUniqueID()
	self.m_SubActionsDict[id] = self.m_MainActionList
	self.m_MainActionList = {}
end

function CWarCtrl.WaitSectionStart(self, oSectionCmd)
	--新手引导特殊处理
	-- if g_WarCtrl:GetWarType() == define.War.Type.Guide3 and (iBoutID == 2 or iBoutID == 1) then
	-- 	netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 0)

	-- 	-- self.m_WaitSectionStart = false
	-- 	-- self:BoutStart(iBoutID, iBoutTime)
	-- 	-- return true
	-- end

	for i, oWarrior in ipairs(self:GetWarriors()) do
		if oWarrior:IsBusy() or oWarrior.m_PlayMagicID ~= nil then
			self.m_WaitSectionStart = true
			return false
		end
	end

	self.m_WaitSectionStart = false
	self:SectionStart(oSectionCmd.sction_id, oSectionCmd.order_wid, oSectionCmd.left_time)
	return true
end

function CWarCtrl.Update(self, dt)
	if self.m_WarID then
		if self.m_IsPause then
			if g_WarOrderCtrl.m_TimeInfo then
				g_WarOrderCtrl.m_TimeInfo.start_time = g_WarOrderCtrl.m_TimeInfo.start_time + dt
			end
		else
			self:UpdateActions()
			self:UpdateCmds()
		end
	end
end

function CWarCtrl.UpdateCmds(self)
	if self:IsInAction() and next(self.m_MainActionList) == nil then
		while next(self.m_CmdList) ~= nil do
			local oCmd = self.m_CmdList[1]
			if oCmd:IsUsed() then
				table.remove(self.m_CmdList, 1)
			else
				local sucess, ret = xxpcall(oCmd.Excute, oCmd)
				if not sucess then
					table.remove(self.m_CmdList, 1)
				end
				if next(self.m_MainActionList) ~= nil then
					break
				end
			end
		end
	end
end

function CWarCtrl.ProcessActionList(self, list)
	local iCur = 1
	local iLen = #list
	for i = 1, iLen do
		local action = list[i]
		local func, args, arglen = unpack(action, 1, 3)
		local sucess, ret = xxpcall(func, unpack(args, 1, arglen))
		if sucess and ret == false then
			break
		end
		iCur = iCur + 1
	end
	local newlist = {}
	local iNewLen = #list
	for i=iCur, iNewLen do
		table.insert(newlist, list[i])
	end
	return newlist
end

function CWarCtrl.UpdateActions(self)
	self.m_MainActionList = self:ProcessActionList(self.m_MainActionList)
	for k, actionlist in pairs(self.m_SubActionsDict) do
		local list = self:ProcessActionList(actionlist)
		list = #list > 0 and list or nil
		self.m_SubActionsDict[k] = list
	end
end

--自动战斗
function CWarCtrl.IsAutoWar(self)
	return self:GetHeroAutoMagic() ~= nil
	--[[
	if (g_WarCtrl:GetWarType() ~= define.War.Type.Guide1) and (g_WarCtrl:GetWarType() ~= define.War.Type.Guide2) then
		return self:GetHeroAutoMagic() ~= nil
	else
		return g_GuideCtrl.m_IsCanAutoWar or false
	end
	]]
end

function CWarCtrl.GetHeroAutoMagic(self)
	local oWarrior = g_WarCtrl:GetWarrior(self.m_HeroWid)
	if oWarrior then
		return oWarrior:GetAutoMagic()
	end
end

function CWarCtrl.GetDefalutAutoMagic(self, wid)
	local list = self:GetMagicList(wid)
	return list[1] or 0
end

function CWarCtrl.AutoMagicChange(self, iWid)
	if iWid == g_WarCtrl.m_HeroWid then
		self:DelayEvent(define.War.Event.AutoWar)
	end
	self:DelayEvent(define.War.Event.AutoMagic)
end

function CWarCtrl.AddWillActWid(self, wid)
	table.safeinsert(self.m_WillActWids, wid, self.m_ProtoWave, self.m_ProtoBout)
end

--状态改变以及通知
function CWarCtrl.WarriorStatusChange(self, wid)
	self:OnEvent(define.War.Event.StatusChange, wid)
end

function CWarCtrl.WarriorAliveChange(self, wid)
	self:OnEvent(define.War.Event.AliveChange, wid)
end

--buff改变
function CWarCtrl.WarriorBuffChange(self, wid, buffid)
	if wid == self.m_HeroWid then
		self:DelayEvent(define.War.Event.HeroBuff)
	end
end

--技能
function CWarCtrl.IsCanUseMagic(self, magic)
	local dData = DataTools.GetMagicData(magic)
	if self.m_SP < dData.sp then
		return false
	end
	return true
end

function CWarCtrl.GetMagicList(self, wid)
	local oWarrior = self:GetWarrior(wid)
	if oWarrior then
		return oWarrior.m_MagicList
	else
		return {}
	end
end

function CWarCtrl.GetMagicLevel(self, wid, skid)
	local oWarrior = self:GetWarrior(wid)
	if oWarrior then
		local oPartner = g_PartnerCtrl:GetPartner(oWarrior.m_PartnerID)	
		if oPartner and self.m_WarType ~= define.War.Type.EqualArena then
			if oPartner:GetValue("awake") == 1 then
				return 100 + oPartner:GetSkillLevel(skid)
			else
				return oPartner:GetSkillLevel(skid)
			end
		end	
		--如果此伙伴不是玩家自己的伙伴或是玩家自己
		return oWarrior:GetMagicLevel(skid)
	end
	return 0
end

function CWarCtrl.GetMagicCD(self, wid, magid)
	local oWarrior = self:GetWarrior(wid)
	return oWarrior and oWarrior:GetMagicCD(magid) or 0
end

function CWarCtrl.SetSP(self, sp, bAlly, skiller, addsp)
	if bAlly then
		if self.m_Sp == sp then
			return
		end
		self.m_SP = sp
		local oWarrior = self:GetWarrior(skiller)
		if oWarrior then
			oWarrior:ShowWarriorAddSp(math.floor(addsp/10))
		end
	end
	self:OnEvent(define.War.Event.SP, {ally=bAlly, sp=sp, skiller=skiller, addsp=addsp})
end

function CWarCtrl.GetSP(self)
	return self.m_SP
end

--是否逃跑中
function CWarCtrl.SetIsEscape(self, bEscape)
	self.m_IsEscape = bEscape
end

function CWarCtrl.GetIsEscape(self)
	return self.m_IsEscape
end

--测试用,是否能进行下一步
function CWarCtrl.IsCanMoveNext(self)
	local bCanMove = false
	if not self.m_IsTestMode then
		bCanMove = true
	else
		bCanMove = self.m_CanMoveNext or (self.m_NextStep > 0)
	end

	return bCanMove
end

--技能指令
function CWarCtrl.CheckShowDefaultMagic(self, cmd)
	--自动战斗部显示
	if self:IsAutoWar() or self:IsInAction() then
		for wid, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			oWarrior:SetUseMagic(nil)
		end
		return
	end
	for i,v in ipairs(cmd) do
		local oWarrior = self:GetWarrior(v.wid)
		if oWarrior and oWarrior:IsAlly() then
			oWarrior:SetUseMagic(v.skill)
		end
	end
end

function CWarCtrl.C2GSSelectCmd(self, iWarID, wid, skill)
	netwar.C2GSSelectCmd(iWarID, wid, skill)
end

function CWarCtrl.SetCacheWarBattleCmd(self, wid, cmd)
	self.m_CacheWarBattleCmd[wid] = cmd
end

function CWarCtrl.GetCacheWarBattleCmd(self, wid)
	return self.m_CacheWarBattleCmd[wid]
end

function CWarCtrl.SetWarStartTime(self, start_time)
	self.m_StartTime = start_time
	self:OnEvent(define.War.Event.StartTime)
end

function CWarCtrl.GetWarStartTime(self)
	return self.m_StartTime
end

function CWarCtrl.IsBanRecordWarEnd(self)
	local lShow = {
		-- define.War.Type.NPC,
		-- define.War.Type.PVP,
		-- define.War.Type.Boss,
		-- define.War.Type.Pata,
		-- define.War.Type.EndlessPVE,
		-- define.War.Type.Arena,
		-- define.War.Type.Lilian,
		-- define.War.Type.EquipFuben,
		-- define.War.Type.AnLei,
		-- define.War.Type.OrgBoss,
		-- define.War.Type.EqualArena,
		-- define.War.Type.Terrawar,
		-- define.War.Type.YjFuben,
		-- define.War.Type.FieldBoss,
		-- define.War.Type.FieldBossPVP,
		-- define.War.Type.PEFuben,
		-- define.War.Type.ChapterFuBen,
		-- define.War.Type.Convoy,
		-- define.War.Type.TeamPvp,
		-- define.War.Type.MonsterAtkCity,
		-- define.War.Type.ShiMen,
		-- define.War.Type.BossKing,
		-- define.War.Type.DailyTrain,
		-- define.War.Type.OrgWar,
		-- define.War.Type.ClubArena,
		-- define.War.Type.GuideBoss,
		-- define.War.Type.Guide1,
		-- define.War.Type.Guide2,
		-- define.War.Type.Guide3,
		-- define.War.Type.Guide4,
	}
	if table.index(lShow, self.m_WarType) then
		return true
	else
		return false
	end
end

function CWarCtrl.AfterMainMenuViewShow(self)
	for k,v in pairs(g_ViewCtrl.m_Views) do
		if table.index(define.War.ExceptViews, k) then
			if v.m_GroupName == "main" then
				v:SetActive(true)
			end
		end
	end
end

return CWarCtrl