local tbUi = Ui:CreateClass("HomeScreenTeam");

function tbUi:Init()
	local tbMembers = TeamMgr:GetTeamMember(true);
	local tbLastData = nil;
	for ith = 1, TeamMgr.MAX_MEMBER_COUNT do
		local tbMemberData = tbMembers[ith-1];
		if ith == 1 then
			tbMemberData = TeamMgr:GetMyTeamMemberData();
		end

		local tbNode = self["TeamNode" .. ith]
		if tbMemberData or tbLastData then
			tbNode.pPanel:SetActive("Main", true);
			tbNode.pPanel:SetActive("Death", false)
			tbNode.pPanel:SetActive("Current", false)
			tbNode:InitTeamHead(tbMemberData);
		else
			tbNode.pPanel:SetActive("Main", false);
		end
		tbLastData = tbMemberData;
	end

    self:UpdateShowTeamNumber();
end

function tbUi:UpdateShowTeamNumber()
    local bRet = self:IsShowTeamNumber();
    self.pPanel:SetActive("BtnNumber", bRet);
    local tbMembers = TeamMgr:GetTeamMember(true);
    tbMembers = tbMembers or {};
    if bRet then
        local nCount = Lib:CountTB(tbMembers) + 1;
        self.pPanel:ChangePosition("BtnNumber", 110, 70 - nCount * 60);
    end 
end

function tbUi:IsShowTeamNumber()
    local tbSyncData = Player:GetServerSyncData("TeamBtNum");
    if not tbSyncData then
        return false;
    end

    if tbSyncData.nMapTID ~= me.nMapTemplateId then
        return false;
    end

    local bHasTeam = TeamMgr:HasTeam();
    if not bHasTeam then
        return false;
    end    

    return true, tbSyncData; 
end

function tbUi:UpdatePartnerShowInfo()
    for ith = 1, TeamMgr.MAX_MEMBER_COUNT do
    	if self["TeamNode" .. ith].pPanel:IsActive("Main") then
    		self["TeamNode" .. ith]:UpatePartnerFight();
    	end		
    end		
end


function tbUi:InDifferBattleUpdateNode(tbNode, tbMemberData, bFollow)
	local bShowDeath = false
	if InDifferBattle:IsPlayerDeath(tbMemberData.nPlayerID) then
		bShowDeath = true
		--头衔至灰色 现在死亡到界面重新打开应该是不会变的，就不重置状态了
		tbNode.pPanel:Button_SetSprite("TeammateSelect", "TaskBg3")
		local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbMemberData.nPortrait);
		tbNode.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szHead, szAtlas);
		--显示已阵亡按钮时不显示跟战按钮不然看不见
		tbNode.pPanel:SetActive("Follow", false);	
	else
		tbNode.pPanel:SetActive("Current", not bFollow)	
		tbNode.pPanel:Label_SetText("Current", string.format("%d号区域", InDifferBattle:GetMemberRoomIndex(tbMemberData.nPlayerID)))
	end
	if InDifferBattle.dwAliveMemberNpcId and tbMemberData.nNpcID == InDifferBattle.dwAliveMemberNpcId then
		tbNode.pPanel:SetActive("Current", false)	
	end					
end

function tbUi:KeyQuestFubenUpdateNode(tbNode, tbMemberData, bFollow )
	local nKeyFloor = Fuben.KeyQuestFuben:IsMemberHasKey(tbMemberData.nPlayerID)
	if nKeyFloor then
		local szSp = Fuben.KeyQuestFuben.DEFINE.KEY_TEAM_SPRITE[nKeyFloor]
		tbNode.pPanel:SetActive("DeliverySymbol", true)
		tbNode.pPanel:Sprite_SetSprite("DeliverySymbol", szSp)
		if tbNode.pPanel:IsActive("Follow") then
			tbNode.pPanel:ChangePosition("Follow", 280, self.tbOldFollowPos.y)
		end
	end
end

function tbUi:Update()
	local bHasTeam = TeamMgr:HasTeam();
	self.pPanel:SetActive("NoTeamContainer", not bHasTeam);
	self.pPanel:SetActive("HaveTeamContainer", bHasTeam);
    self:UpdateShowTeamNumber();

	if not bHasTeam then
		local bIsMatching = next(TeamMgr:GetMatchingActivityIds()) and true or false;
		self.pPanel:SetActive("BeingMatchedTip", bIsMatching);
		return;
	end

	local nNow = GetTime();
	local bHasFollowed = false;
	local tbMembers = TeamMgr:GetTeamMember(true);
	local nFollowNpcId = AutoFight:GetFollowingNpcId();
	local tbLastData = nil;
	for ith = 1, TeamMgr.MAX_MEMBER_COUNT do
		local tbMemberData = tbMembers[ith - 1];
		if ith == 1 then
			tbMemberData = TeamMgr:GetMyTeamMemberData();
		end
		local tbNode = self["TeamNode" .. ith]
		if tbMemberData or tbLastData then
			tbNode.pPanel:SetActive("Main", true);
			if tbMemberData then
				local bFollow = (nFollowNpcId == tbMemberData.nNpcID);
				local szFollowIcon = "BtnFollow";

				local nFollowingValidTime = tbMemberData.nFollowingValidTime or 0;
				if nFollowingValidTime > nNow and not bFollow then
					bHasFollowed = true;
					bFollow = true;
					szFollowIcon = "BtnFollow2";
				end

				tbNode:Update(tbMemberData.nHpPercent or 100, tbMemberData.nMapID or 0);

				tbNode.pPanel:SetActive("Current", false)
				tbNode.pPanel:SetActive("Death", false)	
				tbNode.pPanel:SetActive("DeliverySymbol", false)	
				if bFollow then
					tbNode.pPanel:SetActive("Follow", true);
					if not self.tbOldFollowPos then
						local tbPos = tbNode.pPanel:GetPosition("Follow")
						self.tbOldFollowPos = tbPos
					end
					tbNode.pPanel:ChangePosition("Follow", self.tbOldFollowPos.x, self.tbOldFollowPos.y)

					tbNode.pPanel:Button_SetSprite("Follow", szFollowIcon);
					tbNode.pPanel:Sprite_SetSprite("Follow", szFollowIcon);
				else
					tbNode.pPanel:SetActive("Follow", false);
				end
				
				if InDifferBattle.bRegistNotofy then
					self:InDifferBattleUpdateNode(tbNode, tbMemberData, bFollow)
				elseif Fuben.KeyQuestFuben.bRegistNotofy then
					self:KeyQuestFubenUpdateNode(tbNode, tbMemberData, bFollow)
				end
				
			end
		else
			tbNode.pPanel:SetActive("Main", false);
		end
		tbLastData = tbMemberData;
	end

	if bHasFollowed and not self.nFollowedUpdateTimer then
		self.nFollowedUpdateTimer = Timer:Register(Env.GAME_FPS * TeamMgr.Def.nFollowFightStateLastingTime / 2, self.FollowedUpdate, self);
	elseif not bHasFollowed and self.nFollowedUpdateTimer then
		Timer:Close(self.nFollowedUpdateTimer);
		self.nFollowedUpdateTimer = nil;
	end

	return bHasFollowed;
end

function tbUi:FollowedUpdate()
	if not Ui:WindowVisible("HomeScreenTask") or not self.pPanel:IsActive("Main") then
		self.nFollowedUpdateTimer = nil;
		return
	end

	local bContinue = self:Update();
	if not bContinue then
		self.nFollowedUpdateTimer = nil;
	end
	return bContinue;
end

tbUi.tbOnClick = {
	CreatTeam = function ()
        local nForbidMap = Player:GetServerSyncData("ForbidTeamAllInfo") or 0;
		if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) or nForbidMap == me.nMapTemplateId then
			me.CenterMsg("当前地图不允许组队");
			return;
		end

		if not TeamMgr:CanTeam(me.nMapTemplateId) then
			me.CenterMsg("当前地图不允许组队");
			return;
		end

		local OnOk = function ()
			TeamMgr:CreateOnePersonTeam();
		end

		me.MsgBox("你确定要创建一个队伍吗？", { {"确认", OnOk}, {"取消"}});
	end;

	NearTeam = function()
        local nForbidMap = Player:GetServerSyncData("ForbidTeamAllInfo") or 0;
        if nForbidMap == me.nMapTemplateId then
            me.CenterMsg("当前地图不允许操作");
            return;
        end
        if TeamMgr.tbForibitNearbyMap[me.nMapTemplateId] then
        	me.CenterMsg("当前地图不允许操作");
        	return
        end

		Ui:OpenWindow("NearbyTeamPanel")
	end;

    BtnNumber = function (self)
        Ui:OpenWindow("PlayerNumberPanel");
    end;
}

local tbTeamHead = Ui:CreateClass("HomeScreenTeamHead");

function tbTeamHead:InitTeamHead(tbMemberData)
	local tbMapSetting = Map:GetMapSetting(me.nMapTemplateId)
	self.pPanel:Button_SetSprite("TeammateSelect", "TaskBg")
	self.pPanel:SetActive("Teammate", tbMemberData and true or false);
	self.pPanel:SetActive("AddMember", not tbMemberData and tbMapSetting.TeamForbidden == 0);
	self.pPanel:SetActive("AssistPartner", false);
	self.nPlayerID = nil;
	self:ClosePartnerTimer();
	if not tbMemberData then
		return;
	end

	self.nPlayerID = tbMemberData.nPlayerID;
	self.tbMemberData = tbMemberData;
	self.pPanel:Label_SetText("lbLevel", tbMemberData.nLevel);
    local szName = tbMemberData.szName;
    if tbMemberData.bOffLine then
        szName = szName.."(离开)";
    end
	self.pPanel:Label_SetText("PlayerName", szName);
	local szFactionIcon = Faction:GetIcon(tbMemberData.nFaction);
	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbMemberData.nPortrait);
	self.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon);
    if not tbMemberData.bOffLine then
        self.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas);
    else
        self.pPanel:Sprite_SetSpriteGray("SpRoleHead", szHead, szAtlas);
    end

	if self.nPlayerID then
		self.pPanel:SetActive("FlagMaster", TeamMgr:IsCaptain(self.nPlayerID));
	end

	self:UpatePartnerFight();
end

function tbTeamHead:GetPartnerShowInfo(nPlayerID)
    local tbShowInfo = Player:GetServerSyncData("TeamShowPartner");
    if not tbShowInfo or tbShowInfo.nMapTID ~= me.nMapTemplateId then
    	return;
    end

   local tbParnerInfo = Player:GetServerSyncData("TeamPartner:"..nPlayerID);
    if nPlayerID == me.dwID then
    	local tbInfo = {};
    	local nFightPartnerID = me.GetFightPartnerID();
    	if nFightPartnerID <= 0 then
    		return;
    	end
    		
    	tbInfo = me.GetPartnerInfo(nFightPartnerID);
    	if tbParnerInfo then
    		tbInfo.nNpcId = tbParnerInfo.nNpcId;
    		tbInfo.bDeath = tbParnerInfo.bDeath;
    	end

    	tbParnerInfo = tbInfo;
    end	

    return tbParnerInfo;	
end

function tbTeamHead:UpatePartnerFight()
	if not self.nPlayerID then
		return;
	end

	local tbShowInfo = self:GetPartnerShowInfo(self.nPlayerID);
	if not tbShowInfo or not tbShowInfo.nNpcTemplateId then
		self.pPanel:SetActive("AssistPartner", false);

        local tbSyncInfo = Player:GetServerSyncData("TeamShowPartner");
        if self.nPlayerID == me.dwID and tbSyncInfo and tbSyncInfo.nMapTID == me.nMapTemplateId  then
            self.pPanel:SetActive("AssistPartner", true);
            self.AssistPartnerHead:Clear();
            self.pPanel:Sprite_SetFillPercent("AssistHpInfo", 1);
        end    
		return;
	end

	self.pPanel:SetActive("AssistPartner", true);
	self.AssistPartnerHead:SetPartnerInfo(tbShowInfo);

	self:ClosePartnerTimer();
	if not tbShowInfo.nNpcId then
		self.pPanel:Sprite_SetFillPercent("AssistHpInfo", 1);
	end	

	if tbShowInfo.nNpcId and not tbShowInfo.bDeath then
		self:UpdatePartnerState();
		self.nPartnerTimer = Timer:Register(Env.GAME_FPS, self.UpdatePartnerState, self);
	end

	local bMark = false;
	if tbShowInfo.bDeath then
		bMark = true;
	end
	self.pPanel:SetActive("AssistDeathMark", bMark);	
end

function tbTeamHead:UpdatePartnerState()
	if not self.nPlayerID then
		self.nPartnerTimer = nil;
		return;
	end

	local tbShowInfo = self:GetPartnerShowInfo(self.nPlayerID);
	if not tbShowInfo or not tbShowInfo.nNpcId then
		self.nPartnerTimer = nil;
		return;
	end

	local pNpc = KNpc.GetById(tbShowInfo.nNpcId);
	if pNpc then
		self.pPanel:Sprite_SetFillPercent("AssistHpInfo", pNpc.nCurLife / pNpc.nMaxLife);
	end
		
	return true;   
end	

function tbTeamHead:ClosePartnerTimer()
    if self.nPartnerTimer then
    	Timer:Close(self.nPartnerTimer);
    	self.nPartnerTimer = nil;
    end	
end

function tbTeamHead:Update(nHpPercent, nMapID)
	self.pPanel:ProgressBar_SetValue("HPBg", nHpPercent/100);
end

tbTeamHead.tbOnClick = {};

function tbTeamHead.tbOnClick:AssistPartner()
    local tbShowInfo = Player:GetServerSyncData("TeamShowPartner");
    if not tbShowInfo or tbShowInfo.nMapTID ~= me.nMapTemplateId or tbShowInfo.bForbid then
    	return;
    end

    if self.nPlayerID == me.dwID then
    	Ui:OpenWindow("AssistCompanionPanel");
    end
end

function tbTeamHead.tbOnClick:AddMember()
    local nForbidMap = Player:GetServerSyncData("ForbidTeamAllInfo") or 0;
    if nForbidMap == me.nMapTemplateId then
        me.CenterMsg("当前地图内不可进行此操作");
        return;
    end

	Ui:OpenWindow("DungeonInviteList", "TeamInvite", function (nPlayerId)
		TeamMgr:Invite(nPlayerId);
	end);
end

function tbTeamHead.tbOnClick:TeammateSelect()
	if self.nPlayerID and self.nPlayerID > 0 then
        if self.tbMemberData.bOffLine then
            me.CenterMsg("当前玩家已离开！");
            return;
        end

		local tbPos = self.pPanel:GetRealPosition("TeammateSelect");
		Ui:OpenWindowAtPos("TeammateSelectPop", tbPos.x, tbPos.y, self.tbMemberData);

		if self.nPlayerID ~= me.dwID then
			Ui:OpenWindow("RoleHeadPop",
				{
					self.tbMemberData.nPlayerID,
					self.tbMemberData.nNpcID,
					self.tbMemberData.szName,
					self.tbMemberData.nLevel,
					self.tbMemberData.nFaction,
					self.tbMemberData.nPortrait
				});
		end
	end
end
