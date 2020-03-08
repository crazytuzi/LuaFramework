Require("CommonScript/Battle/Battle.lua")

Battle.tbClass = Battle.tbClass or {}

function Battle:CreateClass(szClass, szBaseClass)
	if szBaseClass and self.tbClass[szBaseClass] then
		self.tbClass[szClass] = Lib:NewClass(self.tbClass[szBaseClass])
	else
		self.tbClass[szClass] = {}
	end

	local tbClassInst = self.tbClass[szClass];
	local tbSeting = self.tbAllBattleSetting[szClass]
	if tbSeting then --基类只初始化一次
		self.tbDotaCom.Setup(tbClassInst, tbSeting)
	end

	return tbClassInst
end

function Battle:GetClass(szClassName)
	return self.tbClass[szClassName]
end

local tbBase = Battle:CreateClass("BattleComBase")

function tbBase:Start()
	self.STATE_TRANS = Battle.STATE_TRANS[self.tbBattleSetting.nUseSchedule]
	self.nSchedulePos = 0;
	self:StartSchedule();
end

function tbBase:StartSchedule()
	local tbLastSchedule = self.STATE_TRANS[self.nSchedulePos]
	if tbLastSchedule then
		Lib:CallBack({ self[tbLastSchedule.szFunc], self, tbLastSchedule.tbParam })
	end

	self.nMainTimer = nil; --nMainTimer 这样不为空时说明还有定时器未执行，

	self.nSchedulePos = self.nSchedulePos + 1;

	local tbNextSchedule = self.STATE_TRANS[self.nSchedulePos];
	if not tbNextSchedule then --后面没有timer 就断了
		return
	end

	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )
end

--直接多少miao后进入指定步骤
function tbBase:DirGotoSchedule(nPos)
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil;
	end

	self.nSchedulePos = nPos;
	local tbNextSchedule = self.STATE_TRANS[nPos];
	if not tbNextSchedule then --后面没有timer 就断了
		return
	end

	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )
end

--schd
function tbBase:StartFight()
	self.nFirstBloodPlayerId = nil;
	self.tbTeamScore = {0, 0}; -- A 队，B 队的分数
	self.tbUpdateTeamScoreTime = {0, 0} --修改队伍积分的时间，判断谁先到达某一分数

	self.bRankUpdate = true

	local nTimeNow = GetTime()
	local fnNofiy = function (pPlayer)
		pPlayer.CenterMsg("战斗开始！请各位前往前线")
		local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
		tbInfo.nInBackCampTime = nTimeNow;
		pPlayer.CallClientScript("Battle:UpdateBattleUiState", self.nSchedulePos + 1)
	end
	self:ForEachInMap(fnNofiy)

	self.nBattleOpen = 1
	self.nStartTime = nTimeNow

	self.nActiveTimer = Timer:Register(Env.GAME_FPS, function ()
		self:Active()
		return true
	end)
	self:OnStartFight()

end

--重载
function tbBase:OnStartFight(  )
	-- body
end

--schd
function tbBase:StopFight()
end

--sche 整个比赛结束清场了
function tbBase:CloseBattle()
end

function tbBase:Active()
end

function tbBase:InitPlayerBattleInfo(tbInfo)
	tbInfo.nScore 			= 0;
	tbInfo.nRank 			= 1;
	tbInfo.nKillPlayer 		= 0;				--击杀玩家数
	tbInfo.nKillNpc 		= 0;				--击杀npc数
	tbInfo.nDeathCount 		= 0;				--死亡次数
	tbInfo.nComboCount  	= 0;                -- 当前连斩数
    tbInfo.nMaxCombo    	= 0;                -- 最高连斩数
    tbInfo.nComboLevel 		= 1;				--连斩数对应超神那些等级，用于变化时的战场公告
    tbInfo.nTitleLevel      = 1;                -- 根据连斩给的称号等级, 1级对应称号就是0
    tbInfo.nKillCount		= 0;				--杀敌数，只包括玩家
    tbInfo.nInBackCampTime  = 0; 	    -- 上次呆在后营的时间，0则是不再后营
end

function tbBase:AddScore(pPlayer, nAddScore)
	if self.nBattleOpen ~= 1 then
		return
	end
	local dwRoleId = pPlayer.dwID
	local tbInfo = self.tbPlayerInfos[dwRoleId]
	tbInfo.nScore = tbInfo.nScore + nAddScore

	-- 现在是积分变化会变化称号
	local nNewTitleLevel = tbInfo.nTitleLevel;
	for i = nNewTitleLevel + 1, #Battle.tbTitleLevelSet do
		local v = Battle.tbTitleLevelSet[i]
		if tbInfo.nScore < v.nNeedScore then
			break;
		else
			nNewTitleLevel = i
		end
	end

	if tbInfo.nTitleLevel ~= nNewTitleLevel then
		self:UpdatePlayerTitle(pPlayer, nNewTitleLevel, tbInfo.nTitleLevel)
		tbInfo.nTitleLevel = nNewTitleLevel
	end

	self:AddTeamScore(tbInfo.nTeamIndex, nAddScore)
end

function tbBase:UpdatePlayerTitle(pPlayer, nTitleLevel, nDelTitleLevel)
end

function tbBase:AddTeamScore(nTeam, nAddScore)
	if self.nBattleOpen ~= 1 or not self.tbTeamScore[nTeam] then
		return
	end

	self.tbTeamScore[nTeam] = self.tbTeamScore[nTeam] + nAddScore;
	self.tbUpdateTeamScoreTime[nTeam] = GetTime();
    self.bRankUpdate = true;
end

function tbBase:UpdatePlayerRank()
	for _, tbRankInfo in ipairs(self.tbBattleRank) do
        local tbInfo = self.tbPlayerInfos[tbRankInfo.dwID]
        tbRankInfo.nScore = tbInfo.nScore;
        tbRankInfo.nKillCount = tbInfo.nKillCount
        tbRankInfo.nMaxCombo = tbInfo.nMaxCombo
        tbRankInfo.nComboCount = tbInfo.nComboCount
        tbRankInfo.nFaction = tbInfo.nFaction
    end

    local fnSort = function (tbRankA, tbRankB)
        return tbRankA.nScore > tbRankB.nScore;
    end

    table.sort(self.tbBattleRank, fnSort);

    for i, tbRankInfo in ipairs(self.tbBattleRank) do
        self.tbPlayerInfos[tbRankInfo.dwID].nRank = i;
    end
end

function tbBase:ComboKill(pPlayer, tbInfo)
	tbInfo = tbInfo or self.tbPlayerInfos[pPlayer.dwID]
	tbInfo.nComboCount = tbInfo.nComboCount + 1

	if tbInfo.nComboCount > tbInfo.nMaxCombo then
		tbInfo.nMaxCombo = tbInfo.nComboCount
		if not MODULE_GAMECLIENT then
			if tbInfo.nComboCount == 10 then
				Achievement:AddCount(pPlayer, "Battle_Combo1", 1, true)
			elseif tbInfo.nComboCount == 20 then
				Achievement:AddCount(pPlayer, "Battle_Combo2", 1, true)
			elseif tbInfo.nComboCount == 50 then
				Achievement:AddCount(pPlayer, "Battle_Combo3", 1, true)
			elseif tbInfo.nComboCount == 100 then
				Achievement:AddCount(pPlayer, "Battle_Combo4", 1, true)
			end	
		end
	end


	pPlayer.CallClientScript("Ui:ShowComboKillCount", tbInfo.nComboCount, true)

	local nNewComboLevel = tbInfo.nComboLevel
	for i = nNewComboLevel + 1, #Battle.tbComboLevelSet do
		local v = Battle.tbComboLevelSet[i]
		if tbInfo.nComboCount < v.nComboCount then
			break;
		else
			nNewComboLevel = i
		end
	end
	if tbInfo.nComboLevel ~= nNewComboLevel then
		local tbComboInfo = Battle.tbComboLevelSet[nNewComboLevel]
		tbInfo.nComboLevel = nNewComboLevel
	    self:BattleFieldTips(string.format(tbComboInfo.szNotify, tbInfo.szName));	
	end

    self.bRankUpdate = true
end

function tbBase:ForEachInMap(fnFunction)
end

function tbBase:BlackMsg(szMsg)
	local fnExcute = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	self:ForEachInMap(fnExcute);
end

function tbBase:BattleFieldTips(szMsg)
	local fnNofiy = function (pEveryOne)
        pEveryOne.CallClientScript("Ui:OpenWindow", "BattleFieldTips", szMsg)
    end
    self:ForEachInMap(fnNofiy);
end

--pPlayer 或假玩家 杀死玩家时 ,
function tbBase:OnKillPlayer(pPlayerNpc, pDeader, nComboLevel, nTitleLevel)
	if not self.nFirstBloodPlayerId then
		self.nFirstBloodPlayerId = true
		self:BattleFieldTips(string.format("%s击败了%s，拿到第一滴血", pPlayerNpc.szName, pDeader.szName))
	end

	local tbDeadTitileInfo = Battle.tbComboLevelSet[nComboLevel]

	if tbDeadTitileInfo.szKilledNotify then
		self:BattleFieldTips(string.format(tbDeadTitileInfo.szKilledNotify, pPlayerNpc.szName, pDeader.szName))
	end

	local dwRoleId = pPlayerNpc.dwID
	local tbKillerInfo = self.tbPlayerInfos[dwRoleId]

	--现在击杀玩家是根据对方的头衔
	local nScore =  Battle.tbTitleLevelSet[nTitleLevel].nKillAddScore
	tbKillerInfo.nKillCount = tbKillerInfo.nKillCount + 1

	self:AddScore(pPlayerNpc, nScore) --todo 传分数可以直接传 dwId

	self:ComboKill(pPlayerNpc, tbKillerInfo);
end

--对于在后营待太久的移到到前线
function tbBase:CheckStayInCamp(nTimeNow)
	local fnCheck = function (pPlayer)
		local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
		if tbInfo.nInBackCampTime ~= 0 and  nTimeNow - tbInfo.nInBackCampTime > self.tbBattleSetting.BACK_IN_CAMP_TIME then
			self:GotoFrontBattle(pPlayer)
		end
	end
	self:ForEachInMap(fnCheck);
end

-- 传送到大营
function tbBase:GotoFrontBattle(pPlayer)
	if not pPlayer.dwID then --NPC 踩也会调用
		return
	end
	
	if self.bShowItemBoxInBackCamp then
		pPlayer.CallClientScript("Ui:CloseWindow", "NormalTopButton")
	end

    local tbInfo = self.tbPlayerInfos[pPlayer.dwID];
    if self.tbBattleSetting.tbPosBattle then
    	local tbPos = self.tbBattleSetting.tbPosBattle[tbInfo.nTeamIndex]
    	pPlayer.SetPosition(unpack( tbPos[MathRandom(#tbPos)] ))
    	--给一个复活的buff
    	local nSkillId, nSkillLevel, nSkillTime = unpack(Battle.tbRevieBuff)
		pPlayer.AddSkillState(nSkillId, nSkillLevel,  0 , nSkillTime * Env.GAME_FPS)
    end

    pPlayer.SetPkMode(3, tbInfo.nTeamIndex)
    tbInfo.nInBackCampTime = 0;
end


function tbBase:SetWinTeam(nWinTeam)
	self.nBattleOpen = 0;
	if not nWinTeam then
		if self.tbTeamScore[1] > self.tbTeamScore[2]  then
			nWinTeam = 1
		elseif self.tbTeamScore[1] < self.tbTeamScore[2]  then
			nWinTeam = 2
		else
			if self.tbUpdateTeamScoreTime[1] < self.tbUpdateTeamScoreTime[2] then
				nWinTeam = 1
			else
				nWinTeam = 2
			end
			Log("Battle StopFight result", self.nMapId, unpack(self.tbUpdateTeamScoreTime))
		end
	end

	--对赢的一方所有人加分，只是影响显示 最后显示的战报里的积分是这里的，不是playerInfo里的
	local nWinAddPer = Battle.WIN_ADD_SCORE_PER
	for _, v in ipairs(self.tbBattleRank) do
		local tbInfo = self.tbPlayerInfos[v.dwID]
		if tbInfo.nTeamIndex == nWinTeam then
			v.nScore = math.floor(v.nScore * nWinAddPer)
			tbInfo.nScore = v.nScore
		end
	end

    self.bRankUpdate = true
    self:SyncAllInfo(GetTime());

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end

	Log("BattleWinTeam", self.nMapId,  nWinTeam,  self.tbTeamScore[1] , self.tbTeamScore[2])
    return nWinTeam;
end

-- 只是比赛结算时回后营
function tbBase:GotoBackBattle(pPlayer)
    local tbInfo = self.tbPlayerInfos[pPlayer.dwID];
    pPlayer.SetPosition(unpack( Battle:GetRandInitPos(tbInfo.nTeamIndex, self.tbBattleSetting)))
    pPlayer.SetPkMode(0)
    tbInfo.nInBackCampTime = GetTime();
end
