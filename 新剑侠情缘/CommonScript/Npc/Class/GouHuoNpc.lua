
local tbGouhuoNpc = Npc:GetClass("GouHuoNpc");

tbGouhuoNpc.nFieldNpcId			= 1073;		-- 野外篝火npc的Id
tbGouhuoNpc.nGouhuoSkillId		= 198;		-- 篝火的技能Id  todo
tbGouhuoNpc.nNoJiu_GouhuoSkillId = 1502;	-- 不能用酒的篝火技能ID todo
tbGouhuoNpc.nTeamGouHuoDis      = 1800;     --队伍的篝火经验分享距离
-- tbGouhuoNpc.BASE_EXP_FILE 		= "setting/player/attrib_level.txt";		-- 基准奖励文件
tbGouhuoNpc.KIND_EVERYONE		= 0;
tbGouhuoNpc.KIND_TEAM			= 1;
tbGouhuoNpc.KIND_KIN			= 2;
tbGouhuoNpc.KIND_TONG			= 3;
tbGouhuoNpc.KIND_TASK			= 4;
tbGouhuoNpc.KIND_EVENT			= 5;	--活动
tbGouhuoNpc.KIND_TEAMFUBEN		= 6;

--如果Key是Table类型
tbGouhuoNpc.nKeyTypeTeam = 1;
tbGouhuoNpc.nKeyTypePlayer = 2;


function tbGouhuoNpc:CallTeamGouhuoNpc(pPlayer, nX, nY, nExistentTime, nBaseMultip, nPeriodTime, nCanUseXiuLianZhu)
    local pNpc	= KNpc.Add(self.nFieldNpcId, 1, 0, pPlayer.nMapId, nX, nY);		-- 获得篝火Npc
    local tbKey = {};
    if pPlayer.dwTeamID > 0 then
    	tbKey.nType = tbGouhuoNpc.nKeyTypeTeam;
    	tbKey.nValue = pPlayer.dwTeamID;
    else
    	tbKey.nType = tbGouhuoNpc.nKeyTypePlayer;
    	tbKey.nValue = pPlayer.dwID;
    end

	self:InitGouHuo(pNpc.nId, tbGouhuoNpc.KIND_TEAM, tbKey, nExistentTime, nPeriodTime or 5, tbGouhuoNpc.nTeamGouHuoDis, nBaseMultip, 1, 0, nCanUseXiuLianZhu);
	self:StartNpcTimer(pNpc.nId)

	Activity:OnPlayerEvent(pPlayer, "Act_CallTeamGouhuoNpc")
	Log("GouhuoNpc CallTeamGouhuoNpc", pPlayer.dwID, pPlayer.nMapTemplateId, nX, nY, nExistentTime, nBaseMultip);
end

--初始化数据：类型，持续时间，每次加经验时间，范围， 经验倍数
function tbGouhuoNpc:InitGouHuo(nNpcId, nType, nKey, nRestTime, nPeriodTime, nAddExpDis, nBaseMultip, nCanUseJIu, nTimes, nCanUseXiuLianZhu)
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return 0
		end

		local tbTmp = {}
		tbTmp.nType				= nType;					--类型:0,所有人,1队伍,2家族,3帮会,4任务专用
		tbTmp.nCanUseJIu 		= nCanUseJIu or 0;			--酒是否有效,无效用0,只有队伍有效
		tbTmp.nPeriodTime 		= nPeriodTime or 5;
		tbTmp.nRestTime 		= nRestTime or 60;
		tbTmp.nAddExpDis		= nAddExpDis or 40;
		tbTmp.nCanUseXiuLianZhu = nCanUseXiuLianZhu or 0; 	--修炼珠是否有效
		tbTmp.nBaseMultip		= nBaseMultip; 				--经验倍率
		tbTmp.nQuotiety			= 100;						--酒的加成百分比
		tbTmp.nAnnouce			= 0;						--公告与否
		tbTmp.nJiuMax			= 0;						--最大酒数量
		tbTmp.szJiuName			= "";						--最大酒名称
		tbTmp.nKey 				= nKey; 				---篝火的拥有者 或者是家族id
		tbTmp.nTimes			= nTimes;
		pNpc.tbTmp = tbTmp

		if nType ~= tbGouhuoNpc.KIND_TEAM then
			local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, nAddExpDis);
			if tbPlayer then
				for _, pPlayer in pairs(tbPlayer) do
					pPlayer.Msg("篝火已点燃，可持续获得经验")
				end
			end
		end
end

--篝火火类型（all/kin），范围， 几秒一加，一分钟基准经验（/100）， 能否用酒, 加经验次数
function tbGouhuoNpc:OnCreate(szParam)
	local _, _, szType, nRange, nPeriodTime, nExpRate, nCanUseJIu, nTimes = string.find(szParam, "^(.-)|(.-)|(.-)|(.-)|(.-)|(%d+)$");
	nRange = tonumber(nRange);
	nPeriodTime = tonumber(nPeriodTime);
	nExpRate = tonumber(nExpRate);
	nCanUseJIu = tonumber(nCanUseJIu);
	nTimes = tonumber(nTimes);

	if (szType == "all") then
		print(him.nId, szParam, szType, nRange, nPeriodTime, nExpRate);
		self:InitGouHuo(him.nId, self.KIND_EVERYONE, 0, -1, nPeriodTime, nRange, nExpRate, nCanUseJIu, nTimes);
		self:StartNpcTimer(him.nId);
	elseif szType == "kin" then
		self:InitGouHuo(him.nId, self.KIND_KIN, 0, Kin.GatherDef.ActivityTime, nPeriodTime, nRange, nExpRate, nCanUseJIu, nTimes);
		self:StartNpcTimer(him.nId);
	elseif szType == "teamfuben" then
		print(him.nId, szParam, szType, nRange, nPeriodTime, nExpRate);
		self:InitGouHuo(him.nId, self.KIND_TEAMFUBEN, 0, -1, nPeriodTime, nRange, nExpRate, nCanUseJIu, nTimes);
		self:StartNpcTimer(him.nId);
	end
end

function tbGouhuoNpc:StartNpcTimer(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return
	end
	local tbTmp = pNpc.tbTmp;
	tbTmp.nTimerId = Timer:Register(tbTmp.nPeriodTime * Env.GAME_FPS, self.OnNpcTimer, self, nNpcId);
end

function tbGouhuoNpc:OnNpcTimer(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return false;
	end
	local tbTmp = pNpc.tbTmp;
	if tbTmp.nRestTime ~= -1 then 	--限时篝火,nRestTime==-1为任务篝火,无限时.
		if (tbTmp.nRestTime <= tbTmp.nPeriodTime) then		-- 时间到，表示要关闭此Timer
			tbTmp.nTimerId = nil;
			pNpc.Delete();
			return false;
		end
		tbTmp.nRestTime = tbTmp.nRestTime - tbTmp.nPeriodTime;
		if tbTmp.nRestTime < 0 then
			tbTmp.nRestTime = 0;
		end
	end

	return self:AddAroundPlayersExp(nNpcId);							-- 给Npc周围队伍玩家加经验
end


-- 功能:	给Npc周围队伍玩家加经验
-- 参数:	pNpc	篝火Npc
function tbGouhuoNpc:AddAroundPlayersExp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return false;
	end
	local tbTmp		= pNpc.tbTmp;
	-- local tbJiuItem	= Item:GetClass("jiu");
	if tbTmp.nType == self.KIND_EVERYONE then
		self:AddAroundExp_Everyone(nNpcId)
	elseif tbTmp.nType == self.KIND_TEAM then
		self:AddAroundExp_Team(nNpcId)
	elseif tbTmp.nType == self.KIND_KIN then
		self:AddAroundExp_Kin(nNpcId)
	elseif tbTmp.nType == self.KIND_TEAMFUBEN then
		self:AddAroundExp_TeamFuben(nNpcId);
	end

	tbTmp.nCurTimes = (tbTmp.nCurTimes or 0) + 1;
	if tbTmp.nTimes and tbTmp.nTimes > 0 and tbTmp.nCurTimes >= tbTmp.nTimes then
		tbTmp.nTimerId = nil;
		pNpc.Delete();
		return false;
	end

	return true;
end

function tbGouhuoNpc:AddAroundExp_TeamFuben(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end

	local tbTmp	= pNpc.tbTmp;
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbPlayerId = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			if not pPlayer.tbNoNpcDropMapInfo or not pPlayer.tbNoNpcDropMapInfo[pPlayer.nMapId] then
				table.insert(tbPlayerId, pPlayer.dwID);
			end
		end
	end

	for _, nPlayerId in pairs(tbPlayerId) do
		self:AddExp2Player(nPlayerId, nNpcId, tbTmp.nAnnouce);
	end
	tbTmp.nAnnouce = 0; --只提示一次
end

--所有
function tbGouhuoNpc:AddAroundExp_Everyone(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp	= pNpc.tbTmp;
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbPlayerId = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			table.insert(tbPlayerId, pPlayer.dwID);
		end
	end
	for _, nPlayerId in pairs(tbPlayerId) do
		self:AddExp2Player(nPlayerId, nNpcId, tbTmp.nAnnouce);
	end
	tbTmp.nAnnouce = 0; --只提示一次
end

function tbGouhuoNpc:CheckPlayerDis(nMapId, nX, nY, pPlayer, nDis)
	if not pPlayer then
		return false;
	end

	local nPlayerMapId, nPlayerX, nPlayerY	= pPlayer.GetWorldPos();
	if nPlayerMapId ~= nMapId then
		return false;
	end

	local nDisSquare = Lib:GetDistsSquare(nX, nY, nPlayerX, nPlayerY);
	if nDisSquare > nDis * nDis then
		return false;
	end

	return true;
end

--队伍
function tbGouhuoNpc:AddAroundExp_Team(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end

	local nNpcMapId, nNpcX, nNpcY = pNpc.GetWorldPos();
	local tbTmp	= pNpc.tbTmp;
	local tbJiuItem	 = Item:GetClass("jiu");
	local tbKeyInfo  = {};
	if type(tbTmp.nKey) == "table" then
		tbKeyInfo = tbTmp.nKey;
	else
		local pKeyPlayer = KPlayer.GetPlayerObjById(tbTmp.nKey)
		if not pKeyPlayer then
			return;
		end

		if pKeyPlayer.dwTeamID > 0 then
    		tbKeyInfo.nType = tbGouhuoNpc.nKeyTypeTeam;
    		tbKeyInfo.nValue = pKeyPlayer.dwTeamID;
    	else
    		tbKeyInfo.nType = tbGouhuoNpc.nKeyTypePlayer;
    		tbKeyInfo.nValue = pKeyPlayer.dwID;
   		end
	end

	local tbPlayer = {};
	local tbTeams = {};
	local pOwnner  = nil;
	if tbKeyInfo.nType == tbGouhuoNpc.nKeyTypeTeam then
		local tbTeam = TeamMgr:GetTeamById(tbKeyInfo.nValue)
		if not tbTeam then
			return;
		end

    	local nCaptainId = tbTeam:GetCaptainId();
    	local tbMember = tbTeam:GetMembers();
    	for _, nPlayerID in pairs(tbMember) do
        	local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        	if pMember then
        		tbTeams[pMember.dwID] = pMember;
        		if self:CheckPlayerDis(nNpcMapId, nNpcX, nNpcY, pMember, tbTmp.nAddExpDis / 2) then
	    			tbPlayer[pMember.dwID] = pMember;
	    			if not pOwnner or pMember.dwID == nCaptainId then
	    				pOwnner = pMember;
	    			end
	        	end
        	end

       end
	else
		pOwnner = KPlayer.GetPlayerObjById(tbKeyInfo.nValue)
		if not pOwnner then
			return;
		end
		tbTeams[pOwnner.dwID] = pOwnner;

		local bRet = self:CheckPlayerDis(nNpcMapId, nNpcX, nNpcY, pOwnner, tbTmp.nAddExpDis / 2);
		if bRet then
			tbPlayer[pOwnner.dwID] = pOwnner;
		end
	end

	if not Lib:HaveCountTB(tbPlayer) or not pOwnner then
		return;
	end

	local nTeamId = pOwnner.dwTeamID;
	tbTmp.nAnnouce = 0; --是否公告酒的提示
	if tbTmp.nCanUseJIu ~= 0 then
		local nJiuMax, nQuotiety, szJiuName =  tbJiuItem:CalcQuotiety(tbPlayer);
		if tbTmp.szJiuName == "" then
			tbTmp.szJiuName = nil;
		end
		if tbTmp.nQuotiety ~= nQuotiety or tbTmp.szJiuName ~= szJiuName then
			-- tbTmp.nAnnouce 	 = 1;
			tbTmp.nQuotiety  = nQuotiety;
			tbTmp.nJiuMax 	 = nJiuMax;
			tbTmp.szJiuName  = szJiuName;
			tbTmp.tbQuotiety = tbPlayerName;
			local szLastGuohuoTipContent = nil;
			if szJiuName and nQuotiety and nJiuMax then
				if nTeamId ~= 0 then
					--szLastGuohuoTipContent = string.format("现在有%d名队伍成员分享了%s，获得%d%%的篝火经验", nJiuMax, szJiuName, nQuotiety)
					--if pOwnner.szLastGuohuoTipContent ~= szLastGuohuoTipContent then
					--	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szLastGuohuoTipContent, nTeamId)
					--end
				else
					szLastGuohuoTipContent = string.format("当前处于饮酒状态，获得%d%%的篝火经验", nQuotiety)
					if pOwnner.szLastGuohuoTipContent ~= szLastGuohuoTipContent then
						pOwnner.Msg(szLastGuohuoTipContent)
					end
				end
			else
				szLastGuohuoTipContent = "酒劲已过，获得100%的篝火经验"
				if pOwnner.szLastGuohuoTipContent ~= szLastGuohuoTipContent then
					--ChatMgr:SendTeamOrSysMsg(pOwnner, szLastGuohuoTipContent);
				end
			end
			for _, pPlayer in pairs(tbTeams) do
				pPlayer.szLastGuohuoTipContent = szLastGuohuoTipContent
			end
		end
	end

	for _, pPlayer in pairs(tbPlayer) do
		self:AddExp2Player(pPlayer.dwID, nNpcId, 0);
	end
end

--家族
function tbGouhuoNpc:AddAroundExp_Kin(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp	= pNpc.tbTmp;
	local tbPlayer = KNpc.GetAroundPlayerList(nNpcId, tbTmp.nAddExpDis);
	local tbKinPlayerId = {};
	if tbPlayer then
		for _, pPlayer in pairs(tbPlayer) do
			local memberData = Kin:GetMemberData(pPlayer.dwID);
			if tbTmp.nKey ~= 0 then
				if pPlayer.dwKinId ~= tbTmp.nKey or not memberData then
					Log("AddAroundExp_Kin Fail", pPlayer.dwKinId, tbTmp.nKey, memberData);
				end
				table.insert(tbKinPlayerId, pPlayer.dwID);
			end
		end
	end

	if #tbKinPlayerId ~= 0 then
		tbTmp.nExtraKinAddRate = (math.ceil(#tbKinPlayerId / 5) - 1) * 5; -- 参与人数的经验加成规则
		tbTmp.nExtraKinAddRate = math.min(tbTmp.nExtraKinAddRate, Kin.GatherDef.MaxExtraMemberExpBuff - 100);
		tbTmp.nExtraAddRate = tbTmp.nExtraKinAddRate;
		if tbTmp.nQuotiety + tbTmp.nExtraAddRate > Kin.GatherDef.MaxExtraExpBuff then
			tbTmp.nExtraAddRate = Kin.GatherDef.MaxExtraExpBuff - tbTmp.nQuotiety;
		end
		for _, nPlayerId in pairs(tbKinPlayerId) do
			if tbTmp.bKinGather then
				Kin.Gather:AddJoinReward(nPlayerId);
			end
			self:AddExp2Player(nPlayerId, nNpcId, 0, true);
		end
	end
end

function tbGouhuoNpc:AddExp2Player(nPlayerId, nNpcId, nAnnouce, bKinGather)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end

	local tbTmp       = pNpc.tbTmp;
	local nBaseMultip = tbTmp.nBaseMultip;
	local nQuotiety   = tbTmp.nQuotiety;
	local nExtraAddRate = tbTmp.nExtraAddRate or 0;

	pPlayer.AddSkillState(self.nGouhuoSkillId, 1, FightSkill.STATE_TIME_TYPE.state_time_normal, (tbTmp.nPeriodTime + 1) * Env.GAME_FPS, 0, 1);

	local nBaseExp = pPlayer.GetBaseAwardExp()
	local nExp = math.floor(nBaseExp * (nBaseMultip / 100) * ((nQuotiety + nExtraAddRate)/ 100) / (60 / tbTmp.nPeriodTime));

	if bKinGather then
		local tbLabaSoupItem = Item:GetClass("LabaSoup")
		local nAddRate = tbLabaSoupItem:GetExpAddRate(pPlayer)
		if nAddRate>0 then
			local nAdd = math.floor(nBaseExp*nAddRate)
			nExp = nExp + nAdd
			Log("tbGouhuoNpc:AddExp2Player, LabaSoup", nPlayerId, nAddRate, nBaseExp, nAdd, nExp)
		end
		Activity:OnPlayerEvent(pPlayer, "Act_KinGatherAddExp")
	end

	if tbTmp.nCanUseXiuLianZhu == 1 then
		Player:AddXiuLianExp(pPlayer, nExp);
	else
		pPlayer.AddExperience(nExp, Env.LogWay_Guohuo);
	end

	if nAnnouce == 1 then
		local szMsg = self:CreateAnnouce(nNpcId);
		pPlayer.Msg(szMsg);
	end
end

function tbGouhuoNpc:CreateAnnouce(nNpcId, tbPlayerName, szEventJiuName)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbTmp			= pNpc.tbTmp;
	local nBaseMultip 	= tbTmp.nBaseMultip;
	local nQuotiety		= tbTmp.nQuotiety;
	local nAnnouce		= tbTmp.nAnnouce;
	local nJiuMax		= tbTmp.nJiuMax;
	local szJiuName		= tbTmp.szJiuName;

	local szMsg;
	local szMsg2;
	if nAnnouce == 1 then
		if nJiuMax == 0 then
			if szEventJiuName then
				szMsg = string.format(XT("使用[1AB8E1]%s[-]，"), szEventJiuName);
			else
				szMsg = string.format(XT("没有使用酒，"));
			end
			szMsg = string.format(XT("%s篝火现在获得经验的倍数为[1AB8E1]%s[-]。"), szMsg, nQuotiety)
		else
			if szEventJiuName then
				szMsg = string.format(XT("队友正在分享%s和%s，经验加成为%s％"), szJiuName, szEventJiuName, nQuotiety)
			else
				szMsg = string.format(XT("队友正在分享%s，经验加成为%s％"), szJiuName, nQuotiety)
			end
			if tbPlayerName ~= nil then
				szMsg2 = "";
				for szJiu, tbName in pairs(tbPlayerName) do
					for ni, szName in ipairs(tbName) do
						--酒的名字只显示3个字，把陈年去掉，这种方法比较搓，但临时用吧
						local szJiu2 = string.sub(szJiu,5,-1)
						szMsg2 = string.format("%s%s-%s\n", szMsg2, szName, szJiu2);
					end
				end
			end
		end
	end
	return szMsg, szMsg2;
end

