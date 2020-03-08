Require("Script/Ui/Logic/Notify.lua");
local RepresentMgr = luanet.import_type("RepresentMgr");

AutoFight.OperationType = {
	Manual = 1;
	Auto   = 2;
};

AutoFight.MANUAL_SKILL_TYPE =
{
	DIR = 1,
	POS = 2,
	NPC = 3,
};

AutoFight.nManualSkillTimeOut = 2
AutoFight.nRadius = 600	--野外自动战斗范围的半径

local OperationType = AutoFight.OperationType;
local MANUAL_SKILL_TYPE = AutoFight.MANUAL_SKILL_TYPE;

AutoFight.nFightState = AutoFight.nFightState or OperationType.Manual;
AutoFight.tbCheckFactionSkill = --限制技能释放
{
	[6] = 
	{
		tbSkill = 
		{
			[708] = 1;
			[722] = 1;
			[740] = 1;
		};
		nFrame = 18;
		fnCheck = function (nSkillId)
			local pNpc = me.GetNpc();
		    local tbState = pNpc.GetState(Npc.STATE.NPC_HIDE);
		    local nCurFrme = GetFrame();
		    AutoFight.nCheckSkillFrame = AutoFight.nCheckSkillFrame or 0;
		    if (not tbState or tbState.nRestFrame <= 0) and nCurFrme >= AutoFight.nCheckSkillFrame then
		    	return true;
		    end

		    local tbData = AutoFight.tbCheckFactionSkill[me.nFaction];
		    if not tbData or not tbData.tbSkill then
		    	return true;
		    end

		    if tbData.tbSkill[nSkillId] then
		    	return false;
		    end

		    if (nCurFrme >= AutoFight.nCheckSkillFrame) or (tbState and tbState.nRestFrame > 0) then
		    	AutoFight.nCheckSkillFrame = nCurFrme + tbData.nFrame;
		    end

		    AutoFight.nCheckSkillFrame = math.min(AutoFight.nCheckSkillFrame, nCurFrme + tbData.nFrame + 1);
		    return true;
		end;
	};
	[19] = {
		tbSkill = {
			[5611] = 3;
		};
		fnCheck = function (nSkillId)
			local tbData = AutoFight.tbCheckFactionSkill[me.nFaction]
		    if not tbData or not tbData.tbSkill or not tbData.tbSkill[nSkillId] then
		    	return true;
		    end
		    local nPerPoint = tbData.tbSkill[nSkillId]
		    local nPoint = me.GetNpc().GetUsePoint(nSkillId)
		    local nMaxPoint = me.GetNpc().GetMaxPoint(nSkillId)
		    return nPoint > 0 and ((nPoint % nPerPoint) == 0 or nPoint >= nMaxPoint)
		end
	}
}

function AutoFight:CheckFactionSkill(nSkillId)
	local tbData = self.tbCheckFactionSkill[me.nFaction];
	if not tbData then
		return true;
	end

	local bRet = tbData.fnCheck(nSkillId);
	return bRet;
end

function AutoFight:LoadSetting()
	local tbFile = LoadTabFile("Setting/Map/AutoFightSetting.tab", "dd", nil, {"nMapId", "nAutoFight"});

	self.tbMapSetting = {};
	for _, tbInfo in pairs(tbFile) do
		self.tbMapSetting[tbInfo.nMapId] = tbInfo.nAutoFight;
	end
end

AutoFight:LoadSetting();

function AutoFight:OnEnterMap(nMapTemplateId)
	if not self.tbMapSetting[nMapTemplateId] then
		return;
	end

	local nAutoType = self.tbMapSetting[nMapTemplateId] == 1 and AutoFight.OperationType.Auto or AutoFight.OperationType.Manual;
	Log("AutoFight:OnEnterMap", nAutoType);
	AutoFight:ChangeState(nAutoType, true);
end

function AutoFight:SwitchState()
	local nFightState = self.nFightState % 2 + 1;
	self:ChangeState(nFightState);
end

function AutoFight:GetFightState()
	return self.nFightState;
end

-- 请与AutoFight:CancelForbid() 成对使用
function AutoFight:ForbidAutoFight()
	self.bForbidAutoFight = true;
end

function AutoFight:CancelForbid()
	self.bForbidAutoFight = false;
end

function AutoFight:IsAuto()
	return AutoFight.nFightState ~= OperationType.Manual or AutoFight:IsFollowTeammate();
end

function AutoFight:ResetFightState()
	if AutoFight:IsFollowTeammate() or self.nChangingMapForTeammateNpcId then
		return;
	end

	-- 骑马状态下不进行重置
	local nActMode = me.GetActionMode();
	if nActMode ~= Npc.NpcActionModeType.act_mode_none then
		self.nLastFightState = self:GetFightState();
		return;
	end

	if self.nLastFightState then
		AutoFight:ChangeState(self.nLastFightState);
	end
end

function AutoFight:ChangeState(nFightState, bForce)
	if me.nFightMode == 0 and not bForce then
		self.nLastFightState = nFightState;
		return;
	end

	if self.bForbidAutoFight then
		return;
	end

	self.orgPos = nil
	self.nLastFightState = nFightState;
	if nFightState == OperationType.Manual then
		AutoFight:Stop();
		return;
	end

	AutoFight:StopFollowTeammate();

	if self.nTimer then
		Timer:Close(self.nTimer);
	end

	self.nTimer = Timer:Register(3, self.Activate, self);
	AutoAI.SetTargetIndex(0);
	AutoFight:StopGoto();

	local nCurDstX, nCurDstY = Operation:GetTargetPos();
	if nCurDstX then
		AutoFight:GotoPosition(nCurDstX, nCurDstY);
	end

	AutoFight:UpdateAutoSkillList();
	self.nFightState = nFightState;
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT);
end

function AutoFight:Stop()
	if self.nFightState == OperationType.Manual then
		return;
	end

	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end

	AutoFight:StopGoto();
	AutoAI.SetTargetIndex(0);
	self.nFightState = OperationType.Manual;
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT);
end

function AutoFight:CheckUseJiu()
	--有篝火buff时 自动使用酒
	if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" then
		return
	end
	if not self.nCheckJiuFrame then
		self.nCheckJiuFrame = 1;
		self.nJiuItemLevel = 99
		local nJiuId = Item:GetClass("jiu").nTemplateId
		local tbBaseInfo = KItem.GetItemBaseProp(nJiuId)
		if tbBaseInfo then
			self.nJiuItemLevel = tbBaseInfo.nRequireLevel
		end
	end
	if me.nLevel < self.nJiuItemLevel then
		return
	end
	self.nCheckJiuFrame = self.nCheckJiuFrame + 1;
	if  self.nCheckJiuFrame % 30 == 0 and  not Client:GetFlag("NotAutoUseJiu") then
		if me.GetNpc().GetSkillState(Npc:GetClass("GouHuoNpc").nGouhuoSkillId)
		and not me.GetNpc().GetSkillState(Item:GetClass("jiu").nJiuSkillId) then
			local tbJius = me.FindItemInBag("jiu")
			if next(tbJius) then
				if #tbJius == 1 and tbJius[1].nCount == 1 then
					if not Ui:CheckNotShowTips("ShowAutoBuyJiu|NEVER") then
						local dwTemplateId = tbJius[1].dwTemplateId
						local fnConfirm = function ()
							Shop:AutoChooseItem(dwTemplateId)
						end
						me.MsgBox("[FFFE0D]陈年女儿红[-]已经饮完，是否前往购买？",
							{{"前往购买", fnConfirm}, {"暂不购买"}}, "ShowAutoBuyJiu|NEVER")
					end
				end

				RemoteServer.UseItem(tbJius[1].dwId);
			end
		end
	end
end

function AutoFight:FindCastSkill()
	if Faction:IsMultiWeaponFaction(me.nFaction) then
		local nCurWeapon = FightSkill:GetWeaponType();
		local bOtherWeapon
		local nCurBase
		for _, tbSkillInfo in ipairs(self.tbSkillList) do
			local nSkillId = unpack(tbSkillInfo);
			if nSkillId > 0 and me.CanCastSkill(nSkillId) and AutoFight:CheckFactionSkill(nSkillId) then
				local tbSkillFactionInfo = FightSkill:GetSkillFactionInfo(nSkillId) or {}
				if tbSkillFactionInfo.IsAnger == 1 then
					return nSkillId
				end

				local nWeapon = FightSkill:GetSkillWeapon(me.nFaction, nSkillId)
				if nWeapon == nCurWeapon then
					if not FightSkill:IsBaseSkill(me.nFaction, nSkillId) then
						return nSkillId
					end
					nCurBase = nSkillId
				else
					if not FightSkill:IsBaseSkill(me.nFaction, nSkillId) then
						bOtherWeapon = true
					end
				end
			end
		end
		if bOtherWeapon and self.tbSwitchWeapon[nCurWeapon] then
			local nSkillId = self.tbSwitchWeapon[nCurWeapon]
			if me.CanCastSkill(nSkillId) and AutoFight:CheckFactionSkill(nSkillId) then
				return nSkillId
			end
		end
		if nCurBase and me.CanCastSkill(nCurBase) and AutoFight:CheckFactionSkill(nCurBase) then
			return nCurBase
		end
	else
		for _, tbSkillInfo in ipairs(self.tbSkillList) do
			local nSkillId = unpack(tbSkillInfo);
			if nSkillId > 0 and me.CanCastSkill(nSkillId) and AutoFight:CheckFactionSkill(nSkillId) then
				return nSkillId
			end
		end
	end
end

function AutoFight:Activate()
	if me.nFightMode == 0 or not self:IsAuto() then
		self.nTimer = nil;
		self.nLastFightState = self:GetFightState();
		AutoFight:Stop();
		return false;
	end

	local nDoing = me.GetDoing();
	if nDoing == Npc.Doing.sit then
		return true;
	end

	if AutoAI.IsOnManualGo() and not self.bGuiding then
		-- 处理手动寻路时的卡住问题
		local _, nX, nY = me.GetWorldPos();
		if self.nLastX == nX and self.nLastY == nY then
			self.nStopFrame = self.nStopFrame or 1;
			self.nStopFrame = self.nStopFrame + 1;
		else
			self.nStopFrame = nil;
		end

		self.nLastX = nX;
		self.nLastY = nY;

		if self.nStopFrame and self.nStopFrame > 3 then
			self.nStopFrame = nil;
			AutoFight:StopGoto();
			Operation:SetPositionEffect(false);
		end
		self.orgPos = nil

		return true;
	end

	self:CheckUseJiu();

	if not AutoFight:FindTarget() then
		if me.IsInGuaJiMap() then
			self:FightTarget(0)
			self:GotoPosition(self.orgPos.x, self.orgPos.y)
			self.bGuiding = true
		end
		return true;
	end

	local nSkillId = self:FindCastSkill()
	if nSkillId then
		if me.GetNpc().IsCanSkill() then
			local nSelector = Operation:SkillSelectorTarget(nSkillId);
			if nSelector then
				AutoAI.SetTargetIndex(nSelector)
			end
			AutoAI.SetActiveSkill(nSkillId);
		end
		return true
	end
	return true;
end

function AutoFight:GetOrgPos()
	if not self.orgPos then
		local _,x,y = me.GetWorldPos()
		self.orgPos = {
			x = x,
			y = y,
		}
	end
	return self.orgPos
end

function AutoFight:FindTargetInCircle()
	local orgPos = self:GetOrgPos()
	return Operation:GetNearestEnemyIdByPos(self:GetAutoRadius(), orgPos.x, orgPos.y)
end

function AutoFight:FightTarget(nTargetID)
	nTargetID = nTargetID or 0
	AutoAI.SetTargetIndex(nTargetID)
	Operation:SetNpcSelected(nTargetID)
	Operation:SetPositionEffect(false)
	AutoFight:StopGoto()
end

function AutoFight:IsOutRange()
	local _,meX,meY = me.GetWorldPos()
	local orgPos = self:GetOrgPos()
	return Lib:GetDistance(meX, meY, orgPos.x, orgPos.y)>=self:GetAutoRadius()
end

function AutoFight:GetAutoRadius()
	return Map:GetAutoFightRadius(me.nMapTemplateId, me.nMapId) or self.nRadius
end

function AutoFight:FindTarget()
	local bInGuaJiMap = me.IsInGuaJiMap()
	if bInGuaJiMap and self:IsOutRange() then
		return false
	end
	local nTargetID = AutoAI.GetTargetIndex() or 0;
	local nSkillID = AutoAI.GetActiveSkillId() or 0;
	if me.CheckSkillAvailable2Npc(nSkillID, nTargetID) and AutoFight:CheckFactionSkill(nSkillID) then
		return true
	end

	if bInGuaJiMap then
		nTargetID = self:FindTargetInCircle()
		if nTargetID and nTargetID>0 then
			self:FightTarget(nTargetID)
			return true
		end
	else
		-- 找敌人
		nTargetID = Operation:GetNearestEnemyId();
		if nTargetID and nTargetID ~= 0 then
			self:FightTarget(nTargetID)
			return true;
		end

		--找指引点
		local nGuidX, nGuidY = Fuben:GetTargetPos();
		if nGuidX and nGuidY then
			AutoFight:GotoPosition(nGuidX, nGuidY);
			self.bGuiding = true;
		end
	end
	return false;
end

function AutoFight:OnNpcDeath(nNpcID)
	if nNpcID ~= AutoAI.GetTargetIndex() then
		return;
	end

	local npcRep = RepresentMgr.GetNpcRepresent(nNpcID);
	if npcRep then
		npcRep:SetSelectedEffect(false, true);
	end
end

function AutoFight:ManualAttack(nSkillID, nType, nParam1, nParam2)
	--[[if AutoFight:IsFollowTeammate() then
		return;
	end]]

	if nType == MANUAL_SKILL_TYPE.NPC and not nParam1 and not AutoFight:FindTarget() then -- 找不到目标时, 点攻击无效
		AutoAI.SetNextActiveSkill(0);
		return;
	end

	AutoAI.SetNextActiveSkill(nSkillID, AutoFight.nManualSkillTimeOut, nType, nParam1 or 0, nParam2 or 0);
	AutoFight:StopGoto();
	Operation:SetPositionEffect(false);
end

function AutoFight:ClearManualAttack()
	AutoAI.SetNextActiveSkill(0);
end

function AutoFight:ManualJumpTo(nJumpSkillId, nX, nY, bSlide, bTrap)
	AutoAI.ManualJumpTo(nJumpSkillId, nX, nY, bSlide and true or false, bTrap and true or false);
end

function AutoFight:SelectNpc(nNpcID)
	if not self:IsAuto() or not nNpcID or nNpcID == 0 then
		return;
	end

	if me.CheckSkillAvailable2Npc(self.nMainAttackSkillId, nNpcID) then
		AutoAI.SetTargetIndex(nNpcID);
	end

	Operation:SetNpcSelected(nNpcID);
end

function AutoFight:StopGoto()
	self.bGuiding = false;
	AutoAI.GotoPosition(-1, -1);
end

function AutoFight:GotoPosition(nX, nY)
	if AutoFight:IsFollowTeammate() then
		AutoFight:FollowteammateGoto(nX, nY);
		return;
	end

	self.bGuiding = false;
	return AutoAI.GotoPosition(nX, nY);
end

function AutoFight:GoDirection(nDir, nFrame)
	if AutoFight:IsFollowTeammate() then
		return;
	end

	self.bGuiding = false;
	AutoAI.SetTargetIndex(0); -- 自动战斗时按摇杆方向走，则清空目标
	return AutoAI.GoDirection(nDir, nFrame);
end

function AutoFight:GetClientSave()
	local tbSetting, tbFactionData;
	if not me.IsUserValueValid() then --无差别时使用另一套自动战斗
		tbSetting = Client:GetUserInfo("AutoFightAvatar", -1);
		tbFactionData = Client:GetUserInfo("AutoFightFactionAvatar", -1);
		if not next(tbFactionData) then
			Lib:CopySetTB(tbSetting, Client:GetUserInfo("AutoFight"))
			Lib:CopySetTB(tbFactionData, Client:GetUserInfo("AutoFightFaction"))
		end
	else
		tbSetting = Client:GetUserInfo("AutoFight")
		tbFactionData = Client:GetUserInfo("AutoFightFaction")
	end
	return tbSetting, tbFactionData
end

function AutoFight:GetSetting()
	local tbSetting, tbFactionData = self:GetClientSave()
	if not tbFactionData.nFaction then
		tbFactionData.nFaction = me.nFaction;
	end

	local tbOrgSetting = self.tbOrgSetting;
	self.tbOrgSetting = nil;
	if tbFactionData.nFaction ~= me.nFaction then
		local tbCurOrg = AutoFight:ClearAutoSetting();
		tbFactionData.nFaction = me.nFaction;
		AutoFight:SaveSetting();

		if not tbOrgSetting then
			tbOrgSetting = tbCurOrg;
		end
	end

	if not next(tbSetting) then
		tbOrgSetting = tbOrgSetting or {};

		local nCount = Lib:CountTB(tbSetting);
		local tbSkillInfo = FightSkill:GetFactionSkill(me.nFaction);
		for _, tbInfo in pairs(tbSkillInfo) do
			if (tbInfo.IsAnger == 1 or string.find(tbInfo.BtnName, "Skill")) and
			 tbInfo.BtnName ~= "SkillDodge" then
				local nMutexSkill, bPriority = FightSkill:GetMutexSkill(tbInfo.SkillId)
				if not nMutexSkill or not bPriority then
					table.insert(tbSetting, {
						nSkillId = tbInfo.SkillId;
						szName = tbInfo.BtnName,
						bActive = false;
						nWeapon = tbInfo.WeaponType,
					});
				end
			end
		end

		table.sort(tbSetting, function (a, b)
			if a.nWeapon == b.nWeapon then
				return a.szName < b.szName;
			end
			return a.nWeapon < b.nWeapon
		end);

		for nI, tbSetInfo in pairs(tbSetting) do
			if tbOrgSetting and tbSetInfo.szName and tbOrgSetting[tbSetInfo.szName] then
				tbSetInfo.bActive = tbOrgSetting[tbSetInfo.szName].bActive;
			end
		end

		if nCount == 0 then
			AutoFight:SaveSetting();
			Log("AutoFight ChangeSetting SaveSetting");
		end
	end
	return tbSetting;
end

function AutoFight:ClearAutoSetting()
	local tbOrgPos = {};
	local tbSetting = self:GetClientSave()
	for nI, tbSetInfo in pairs(tbSetting) do
		if tbSetInfo.szName and not Lib:IsEmptyStr(tbSetInfo.szName) then
			local tbInfo = {};
			tbInfo.bActive = tbSetInfo.bActive;
			tbOrgPos[tbSetInfo.szName] = tbInfo;
		end
	end

	for i = 1, 10 do
		tbSetting[i] = nil
	end

	return tbOrgPos;
end

function AutoFight:SaveSetting()
	Client:SaveUserInfo();
end

function AutoFight:CheckUpdateSkillSetting()
    local tbSkillSetting = AutoFight:GetSetting() or {};
	local tbAllSkill= FightSkill:GetFactionSkill(me.nFaction) or {};
	for _, tbSkill1 in pairs(tbSkillSetting) do
		local bClear = true;
	    for _, tbSkill2 in pairs(tbAllSkill) do
	        if tbSkill1.nSkillId == tbSkill2.SkillId then
	        	bClear = false;
	        	break;
	        end
	    end

	    if bClear then
	    	return true;
	    end
	end

	return false;
end

function AutoFight:UpdateSkillSetting()
	local bRet = AutoFight:CheckUpdateSkillSetting();
	if not bRet then
		return;
	end

	local tbOrgPos = AutoFight:ClearAutoSetting();
	AutoFight.tbOrgSetting = tbOrgPos;
	AutoFight:GetSetting()
	AutoFight.tbOrgSetting = nil;

	AutoFight:SaveSetting();
end

function AutoFight:ClearAutoFightTarget()
	AutoAI.SetTargetIndex(0);
	AutoFight:StopGoto();
end

function AutoFight:UpdateAutoSkillList()
	self.tbSkillList = {};
	self.tbSwitchWeapon = {};
	local tbSwitchSkill = FightSkill:GetSwitchWeaponSkill(me.nFaction);
	local tbSetting = self:GetSetting();
	for _, tbSkillInfo in ipairs(tbSetting) do
		local nSkillId = tbSkillInfo.nSkillId;
		local nSkillLevel = me.GetSkillLevel(nSkillId);
		if tbSkillInfo.bActive and nSkillLevel > 0 then
			if tbSwitchSkill[0] == nSkillId or tbSwitchSkill[1] == nSkillId then
				local nWeapon = FightSkill:GetSkillWeapon(me.nFaction, nSkillId)
				self.tbSwitchWeapon[nWeapon] = nSkillId
			else				
				local tbSkillSetting = FightSkill:GetSkillSetting(nSkillId, nSkillLevel);
				local bNeedTarget = FightSkill:IsTeamFollowAttackNeedTarget(nSkillId);
				table.insert(self.tbSkillList, {nSkillId, bNeedTarget, tbSkillSetting.AttackRadius});
				local nMutexSkill, bPriority = FightSkill:GetMutexSkill(nSkillId)
				if nMutexSkill and not bPriority then
					local tbSkillSetting = FightSkill:GetSkillSetting(nMutexSkill, nSkillLevel);
					local bNeedTarget = FightSkill:IsTeamFollowAttackNeedTarget(nMutexSkill);
					table.insert(self.tbSkillList, {nMutexSkill, bNeedTarget, tbSkillSetting.AttackRadius});
				end
			end
		end
	end

	local tbBaseSkill = FightSkill:GetSkillIdByBtnName(me.nFaction, "Attack");
	for _, nSkillId in pairs(tbBaseSkill) do
		table.insert(self.tbSkillList, {nSkillId});
	--	self.nMainAttackSkillId = nSkillId;
	end
end

--------------------跟战---------------------------

function AutoFight:FollowteammateGoto(nX, nY)
	local tbTeammate = TeamMgr:GetMemberData(self.nFollowTeammateNpcId);
	if tbTeammate then
		tbTeammate.nTargetNpcId = nil;
	end

	me.GotoPosition(nX, nY);
end

function AutoFight:RegisterTeamFollow(nNpcId, nMapId)
    local tbTeammate = TeamMgr:GetMemberData(nNpcId);
	self.tbRegisterTeamFollow = nil;
	if tbTeammate and nMapId == tbTeammate.nMapId then
		AutoFight:StartFollowTeammate(nNpcId)
		return;
	end

	self.tbRegisterTeamFollow = {};
	self.tbRegisterTeamFollow.nNpcId = nNpcId;
	self.tbRegisterTeamFollow.nMapId = nMapId;
end

function AutoFight:OnUpdateTeamInfo()
    if self.tbRegisterTeamFollow then
    	local nNpcId = self.tbRegisterTeamFollow.nNpcId;
    	local tbTeammate = TeamMgr:GetMemberData(nNpcId);
    	if not tbTeammate then
    		self.tbRegisterTeamFollow = nil;
    	else
    		AutoFight:RegisterTeamFollow(nNpcId, self.tbRegisterTeamFollow.nMapId);
    	end
    end
end

function AutoFight:StartFollowTeammate(nNpcId, bIgnoreNotice)
	local tbAttachParam = me.GetNpc().GetNpcAttachParam();
	if tbAttachParam and tbAttachParam.nType ~= Npc.AttachType.npc_attach_type_none then
		me.CenterMsg("当前状态不能跟战")
		return
	end

	local tbTeammate = TeamMgr:GetMemberData(nNpcId);
	local nMapId = me.GetWorldPos();
	if not tbTeammate then
		if not bIgnoreNotice then
			me.CenterMsg("无法找到队友");
		end
		return;
	end

	if nMapId ~= tbTeammate.nMapId 
		and not self:FollowTeammateChangeMap(tbTeammate)
		then
		return;
	end

	AutoFight:Stop();
	AutoFight:StopFollowTeammate();

	Log("StartFollowTeammate", nNpcId, bIgnoreNotice)

	self.nFollowTeammateNpcId = nNpcId;

	AutoFight:UpdateAutoSkillList();

	self.nFollowTeammateTimer = Timer:Register(3, self.FollowTeammateActive, self);
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE);
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT);
	me.CenterMsg(string.format("已跟战[FFFE0D]「%s」[-]", tbTeammate.szName));
	Player:UpdateHeadState();

	self.nChangingMapForTeammateNpcId = nil;
end

function AutoFight:StartFollowNpc(nNpcId, nFollowDistance)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	AutoFight:Stop();
	AutoFight:StopFollowTeammate();--和跟战队友同一个timer 和stop

	Log("StartFollowNpc", nNpcId, bIgnoreNotice)
	self.nFollowNpcId = nNpcId;
	self.nFollowNpcDistance = nFollowDistance

	self.nFollowTeammateTimer = Timer:Register(3, self.FollowNpcActive, self);
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE);
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT);
	Player:UpdateHeadState();
end

function AutoFight:IsFollowTeammate()
	return self.nFollowTeammateTimer and true or false;
end

function AutoFight:GetFollowingNpcId()
	return self.nFollowTeammateNpcId;
end

function AutoFight:StopFollowTeammate(bWeakStop)
	if self.nFollowTeammateTimer then
		Timer:Close(self.nFollowTeammateTimer);
		self.nFollowTeammateTimer = nil;
		self.nFollowTeammateNpcId = nil;
		self.nFollowNpcId = nil;
		UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE);
		Player:UpdateHeadState();
		UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT);
	end

	if not bWeakStop then
		self.nChangingMapForTeammateNpcId = nil;
	end
end

function AutoFight:FollowTeammateChangeMap(tbTeammate)
	local tbGoTargetInfo = AutoPath:GetGoTargetNextActInfo(tbTeammate.nMapTemplateId, me.nMapTemplateId);
	if tbGoTargetInfo then
		local nNow = GetTime();
		if self.nNextFollowFightChangingMapActive and self.nNextFollowFightChangingMapActive > nNow then
			return true;
		end

		if tbGoTargetInfo.tbPos then
			local _, nMyPosX, nMyPosY = me.GetWorldPos();
			local nMinLen = math.huge;
			local tbTargePos = nil;
			for _, tbPos in ipairs(tbGoTargetInfo.tbPos) do
				local nLenSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, tbPos[1], tbPos[2]);
				if nLenSquare < nMinLen then
					nMinLen = nLenSquare;
					tbTargePos = tbPos;
				end
			end

			if tbTargePos then
				me.GotoPosition(unpack(tbTargePos));
				self.nNextFollowFightChangingMapActive = nNow + 1;
				return true;
			end
		elseif tbGoTargetInfo.szOperation == "DoScript" then
			local fn = loadstring(tbGoTargetInfo.szParams);
			if fn then
				fn();
				self.nNextFollowFightChangingMapActive = nNow + 3;
				return true;
			end
		elseif tbGoTargetInfo.szOperation == "WhiteTigerFuben" then
			self.nNextFollowFightChangingMapActive = nNow + 1;
			return Fuben.WhiteTigerFuben:FollowOperation(tbTeammate.nMapId, tbGoTargetInfo.szParams)
		end
	end

	-- 原普通跟战切地图流程
	AutoFight:StopFollowTeammate();

	local nMapId = tbTeammate.nMapId;
	if tbTeammate.nMapTemplateId == Kin.Def.nKinMapTemplateId and tbTeammate.nKinId == me.dwKinId then
		nMapId = tbTeammate.nMapTemplateId;
	end

	AutoPath:GotoAndCall(nMapId, tbTeammate.nPosX, tbTeammate.nPosY, function ()
		AutoFight:StartFollowTeammate(self.nChangingMapForTeammateNpcId, true);
	end, 10000, tbTeammate.nMapTemplateId);
	
	self.nChangingMapForTeammateNpcId = tbTeammate.nNpcID;
	return false;
end

local function GetPositionInRay(orgX, orgY, desX, desY, nLength)
	local nBevelLen = math.sqrt((orgX - desX)^2 + (orgY - desY)^2);
	local nUnitLenX = (desX - orgX) / nBevelLen;
	local nUnitLenY = (desY - orgY) / nBevelLen;

	return orgX + nUnitLenX * nLength, orgY + nUnitLenY * nLength;
end

local nFollowTeammateDistance = 650;
local nNextFollowAttackEnemeyTime = 0;
local nFollowTeammateAttackFailCount = 0;
local nNextSendFollowStateTime = 0;
AutoFight.tbDelayUse = {
	--明教跟站需马上释放第二段
	[5515] = function (nEnemyNpcId)
		Timer:Register(8, function ()
			me.UseSkill(5515, -1, nEnemyNpcId)
		end)
	end;
};

function AutoFight:FollowTeammateActive()
	local tbTeammate = TeamMgr:GetMemberData(self.nFollowTeammateNpcId);
	if not tbTeammate then
		AutoFight:StopFollowTeammate();
		AutoFight:ChangeState(OperationType.Auto);
		return false;
	end

	local nNow = GetTime();

	if nNow > nNextSendFollowStateTime then
		nNextSendFollowStateTime = nNow + TeamMgr.Def.nFollowFightStateLastingTime - 1;
		TeamMgr:SendFollowState(tbTeammate.nPlayerID);
	end

	if Map:IsMapOnLoading() then
		return true;
	end

	local nMapId, nMyPosX, nMyPosY = me.GetWorldPos();
	if nMapId ~= tbTeammate.nMapId then
		return self:FollowTeammateChangeMap(tbTeammate);
	end
	self.nChangingMapForTeammateNpcId = nil;

	--如果是在心魔里，不同房间需要专门的寻路,绝地版没有障碍就直接用通用跟战吧
	if InDifferBattle.bRegistNotofy and not InDifferBattle:IsJueDiVersion() then
		if InDifferBattle:GotoTeamateRoom(tbTeammate) then
			return true
		end
	end

	local pTeammateNpc = KNpc.GetById(self.nFollowTeammateNpcId);
	if not pTeammateNpc then
		me.GotoPosition(tbTeammate.nPosX, tbTeammate.nPosY);
		tbTeammate.nTargetNpcId = nil;
		return true;
	end

	local _, nTeammateX, nTeammateY = pTeammateNpc.GetWorldPos();
	local nDisSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, nTeammateX, nTeammateY);
	if nDisSquare > (nFollowTeammateDistance^2) then
		local nX, nY = GetPositionInRay(nTeammateX, nTeammateY, nMyPosX, nMyPosY, nFollowTeammateDistance * 0.3);
		if GetBarrierInfo(nMapId, nX, nY) == 0 then
			me.GotoPosition(nX, nY);
		else
			me.GotoPosition(nTeammateX, nTeammateY);
		end
		tbTeammate.nTargetNpcId = nil;
		nNextFollowAttackEnemeyTime = nNow + 4;
		return true;
	end

	self:CheckUseJiu();

	-- 有bug是会跟战时上马（尚未找到原因），这里检查如果在马上时就让其下马
	local nActMode = me.GetActionMode();
	if nActMode ~= Npc.NpcActionModeType.act_mode_none then
		ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_none, true);
		return true;
	end

	local nEnemyNpcId = tbTeammate.nTargetNpcId;
	if not nEnemyNpcId or nNow > tbTeammate.nAttackTimeOut then
		tbTeammate.nTargetNpcId = nil;
	end

	local pEnmemy = KNpc.GetById(nEnemyNpcId or 0);
	if not pEnmemy then
		nEnemyNpcId = me.GetNpc().GetLastDamageNpcId();
		pEnmemy = KNpc.GetById(nEnemyNpcId or 0);
		if not pEnmemy or nNow < nNextFollowAttackEnemeyTime then
			return true;
		end
	end

	if not me.CheckSkillAvailable2Npc(self.nMainAttackSkillId, nEnemyNpcId) then
		return true;
	end

	local _, nEnemyX, nEnemyY = pEnmemy.GetWorldPos();
	local nEnemyDisSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, nEnemyX, nEnemyY);
	--如果找到的技能失败就留到下一次active再找
	local nSkillId = self:FindCastSkill()
	if nSkillId then
		local nSkillLevel    = me.GetSkillLevel(nSkillId);
		local tbSkillSetting = FightSkill:GetSkillSetting(nSkillId, nSkillLevel);
		local bNeedTarget    = FightSkill:IsTeamFollowAttackNeedTarget(nSkillId);
		if bNeedTarget and nEnemyDisSquare > ((tbSkillSetting.AttackRadius * 0.8)^2) then
			me.GotoPosition(nEnemyX, nEnemyY);
			return true;
		end

		if Operation:UseSkillToNpc(nSkillId, nEnemyNpcId) then
			local fn = AutoFight.tbDelayUse[nSkillId]
			if nEnemyNpcId and fn then
				fn(nEnemyNpcId)
			end
			nFollowTeammateAttackFailCount = 0;
			return true;
		end
	end

	local nDoing = me.GetDoing();
	-- 类似天王的转转转等释放时可移动的技能，则移动到目标
	if nDoing == Npc.Doing.ctrl_run_attack then
		me.GotoPosition(nEnemyX, nEnemyY);
		return true;
	end

	nFollowTeammateAttackFailCount = nFollowTeammateAttackFailCount + 1;
	if nFollowTeammateAttackFailCount > 4
		and nDoing == Npc.Doing.stand 
		then
		me.GotoPosition(nEnemyX, nEnemyY);
	end

	return true;
end

function AutoFight:FollowNpcActive(  )
	local pNpc = KNpc.GetById(self.nFollowNpcId) 
	if not pNpc then
		AutoFight:StopFollowTeammate();
		return false
	end
	local _, nTeammateX, nTeammateY = pNpc.GetWorldPos();
	local nMapId, nMyPosX, nMyPosY = me.GetWorldPos();
	local nDisSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, nTeammateX, nTeammateY);
	if nDisSquare > (self.nFollowNpcDistance ^2) then
		local nX, nY = GetPositionInRay(nTeammateX, nTeammateY, nMyPosX, nMyPosY, self.nFollowNpcDistance * 0.3);
		if GetBarrierInfo(nMapId, nX, nY) == 0 then
			me.GotoPosition(nX, nY);
		else
			me.GotoPosition(nTeammateX, nTeammateY);
		end
		return true;
	end
	return true
end

function AutoFight:OnBreakGreneralProcess(bProcessShow)
	if not bProcessShow 
		or not self.nChangingMapForTeammateNpcId 
		then
		return;
	end

	local nMapId, nMyPosX, nMyPosY = me.GetWorldPos();
	local tbTeammate = TeamMgr:GetMemberData(self.nChangingMapForTeammateNpcId);
	if not tbTeammate or nMapId == tbTeammate.nMapId then
		return;
	end

	if Map:GetMapType(me.nMapTemplateId) == Map.emMap_Public then
		local nX, nY = Map:GetDefaultPos(me.nMapTemplateId);
		AutoPath:GotoAndCall(me.nMapId, nX, nY, function ()
			AutoFight:FollowTeammateChangeMap(tbTeammate);
		end, 100);
	else
		local _, nX, nY = me.GetWorldPos();
		me.GotoPosition(nX, nY);

		local nFollowNpcId = self.nChangingMapForTeammateNpcId;
		self.nChangingMapForTeammateNpcId = nil;

		Timer:Register(7, function ()
			AutoPath:GotoAndCall(tbTeammate.nMapId, tbTeammate.nPosX, tbTeammate.nPosY, function ()
				AutoFight:StartFollowTeammate(nFollowNpcId, true);
		end, 10000);
		end)
	end
end

function AutoFight:OnDeath(tbKillerInfo)
	if Map:GetMapType(me.nMapTemplateId) == Map.emMap_Public
		and AutoFight:IsFollowTeammate()
		and me.nPkMode ~= Player.MODE_PEACE
		then
		AutoFight:StopFollowTeammate();
	end

	if tbKillerInfo and Map:IsFieldFightMap(me.nMapTemplateId) then
		AutoFight:StartFieldMapRecord(tbKillerInfo);
	end
end

function AutoFight:ChangeHand()
    AutoFight:ChangeState(OperationType.Manual, true)
end

PlayerEvent:RegisterGlobal("OnDeath", AutoFight.OnDeath, AutoFight);

function AutoFight:StopAll(bWeakStop)
	AutoFight:Stop();
	AutoFight:StopFollowTeammate(bWeakStop);
end

----------------野外死亡挂机数据统计------------------------------------------

function AutoFight:StartFieldMapRecord(tbKillerInfo)
	if self.tbFieldMapRecordInfo then
		self:FieldMapRecordReport();
	end

	local nNow = GetTime();
	self.tbFieldMapRecordInfo = {};
	local tbRecordInfo = self.tbFieldMapRecordInfo;

	tbRecordInfo.tbKillerInfo = tbKillerInfo;
	tbRecordInfo.nEndTime = nNow + 5 * 60;
	tbRecordInfo.nDeathMapTemplate = me.nMapTemplateId;

	local _, nX, nY = me.GetWorldPos();
	tbRecordInfo.szDeathPos           = string.format("%d,%d", nX, nY);
	tbRecordInfo.nDeathTime           = nNow;
	tbRecordInfo.tbMapsTemplateIds    = {};
	tbRecordInfo.tbMapsDistances      = {};
	tbRecordInfo.tbMapsStayTime       = {};
	tbRecordInfo.nCurMapTemplateId    = nil;
	tbRecordInfo.nCurMapDistance      = 0;
	tbRecordInfo.nCurMapEnterTime     = 0;
	tbRecordInfo.tbCurMapLastPos      = nil;
	tbRecordInfo.szCurAutoFightCenter = "";

	local nTimer = Timer:Register(Env.GAME_FPS * 5, self.FieldMapRecordActive, self);
	tbRecordInfo.nTimer = nTimer;
end

function AutoFight:FieldMapRecordActive()
	if not Login.bEnterGame then
		self.tbFieldMapRecordInfo = nil;
	end

	local tbRecordInfo = self.tbFieldMapRecordInfo;
	if not tbRecordInfo then
		return false;
	end

	local nNow = GetTime();
	if nNow > tbRecordInfo.nEndTime then
		self:FieldMapRecordReport();
		return false;
	end

	local _, nX, nY = me.GetWorldPos();
	if tbRecordInfo.tbCurMapLastPos then
		tbRecordInfo.nCurMapDistance = tbRecordInfo.nCurMapDistance + math.floor(Lib:GetDistance(nX, nY, unpack(tbRecordInfo.tbCurMapLastPos)));
	end
	tbRecordInfo.tbCurMapLastPos = {nX, nY};

	if Map:IsFieldFightMap(me.nMapTemplateId) then
		local szCurAutoFightCenter = "";
		if self.nFightState == OperationType.Auto and self.orgPos then
			szCurAutoFightCenter = string.format("%d,%d", self.orgPos.x, self.orgPos.y);
		end

		if tbRecordInfo.szCurAutoFightCenter ~= szCurAutoFightCenter then
			tbRecordInfo.szCurAutoFightCenter = szCurAutoFightCenter;
			tbRecordInfo.nGoAutoFightCenterTime = nNow;
		end
	end

	return true;
end

function AutoFight:FieldMapRecordReport()
	local tbRecordInfo = self.tbFieldMapRecordInfo;
	if Map:IsFieldFightMap(me.nMapTemplateId) then
		local nNow = GetTime();
		local nTotalTime = nNow - tbRecordInfo.nDeathTime;
		local nToFinalAutoFightTime = nTotalTime;
		local _, nX, nY = me.GetWorldPos();
		local szFinalAutoFightCenter = string.format("%d,%d", nX, nY);
		if self.nFightState == OperationType.Auto then
			nToFinalAutoFightTime = (tbRecordInfo.nGoAutoFightCenterTime or nNow) - tbRecordInfo.nReviveTime;
			if self.orgPos then
				szFinalAutoFightCenter = string.format("%d,%d", self.orgPos.x, self.orgPos.y);
			end
		end

		AutoFight:OnFieldMapRecordChangeMap(me.nMapTemplateId);

		local nMaxStayMap = tbRecordInfo.nCurMapTemplateId;
		local nMaxTime = -1;
		for i, nTime in ipairs(tbRecordInfo.tbMapsStayTime) do
			if nTime > nMaxTime then
				nMaxTime = nTime;
				nMaxStayMap = tbRecordInfo.tbMapsTemplateIds[i];
			end
		end

		local tbInfo = {
			szClientTime          = Lib:GetTimeStr4();
			nDeathMapTemplate     = tbRecordInfo.nDeathMapTemplate;
			szDeathPos            = tbRecordInfo.szDeathPos;
			nReviveCost           = tbRecordInfo.nReviveTime - tbRecordInfo.nDeathTime;
			nReviveMap            = tbRecordInfo.nReviveMap;
			szRevivePos           = tbRecordInfo.szRevivePos;
			nFirstChangeMapTime   = tbRecordInfo.nFirstChangeMapTime or -1;
			nToFinalAutoFightTime = nToFinalAutoFightTime;
			szMapsId              = table.concat(tbRecordInfo.tbMapsTemplateIds, ",");
			szMapsTime            = table.concat(tbRecordInfo.tbMapsStayTime, ",");
			szMapsDistance        = table.concat(tbRecordInfo.tbMapsDistances, ",");
			nMaxStayMap           = nMaxStayMap;
			szMaxStayPos          = szFinalAutoFightCenter;
			szKillerOpenId        = tbRecordInfo.tbKillerInfo.szAccount or "";
			nKillerId             = tbRecordInfo.tbKillerInfo.dwID or 0;
			nKillerFaction        = tbRecordInfo.tbKillerInfo.nFaction or 0;
			szKillerName          = tbRecordInfo.tbKillerInfo.szName or "";
			nKillerLevel          = tbRecordInfo.tbKillerInfo.nLevel or 0;
			nKillerFightPower     = tbRecordInfo.tbKillerInfo.nFightPower or 0;
			nTotalTime            = nTotalTime;
			nFollowFight          = AutoFight:IsFollowTeammate() and 1 or 0;
		};
		RemoteServer.TLogHangup(tbInfo);
	end
	Timer:Close(tbRecordInfo.nTimer);
	self.tbFieldMapRecordInfo = nil;
end

function AutoFight:OnFieldMapRecordChangeMap(nMapTemplateId)
	local tbRecordInfo = self.tbFieldMapRecordInfo;
	if not tbRecordInfo then
		return;
	end

	local nNow = GetTime();
	local _, nX, nY = me.GetWorldPos();
	if not tbRecordInfo.nReviveMap then
		tbRecordInfo.nReviveMap = nMapTemplateId;
		tbRecordInfo.szRevivePos = string.format("%d,%d", nX, nY);
		tbRecordInfo.nReviveTime = nNow;
	elseif not tbRecordInfo.nFirstChangeMapTime then
		tbRecordInfo.nFirstChangeMapTime = nNow - tbRecordInfo.nCurMapEnterTime;
	end

	if tbRecordInfo.nCurMapTemplateId then
		table.insert(tbRecordInfo.tbMapsTemplateIds, tbRecordInfo.nCurMapTemplateId);
		table.insert(tbRecordInfo.tbMapsDistances, tbRecordInfo.nCurMapDistance);
		table.insert(tbRecordInfo.tbMapsStayTime, nNow - tbRecordInfo.nCurMapEnterTime);
	end

	tbRecordInfo.nCurMapTemplateId = nMapTemplateId;
	tbRecordInfo.nCurMapDistance = 0;
	tbRecordInfo.nCurMapEnterTime = nNow;
	tbRecordInfo.tbCurMapLastPos = {nX, nY};
end

if AutoFight.bInitNotify then
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_BREAK_GENERALPROCESS, AutoFight);
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, AutoFight);
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LOADED, AutoFight);
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SYNC_PLAYER_SET_POS, AutoFight);
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_AUTO_SKILL_CHANGED, AutoFight);
end

UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, AutoFight.ClearAutoFightTarget, AutoFight);
UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PLAYER_SET_POS, AutoFight.ClearAutoFightTarget, AutoFight);
UiNotify:RegistNotify(UiNotify.emNOTIFY_AUTO_SKILL_CHANGED, AutoFight.UpdateAutoSkillList, AutoFight);
UiNotify:RegistNotify(UiNotify.emNOTIFY_BREAK_GENERALPROCESS, AutoFight.OnBreakGreneralProcess, AutoFight);
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, AutoFight.OnFieldMapRecordChangeMap, AutoFight);
AutoFight.bInitNotify = true;

----------------野外死亡挂机数据统计END------------------------------------------