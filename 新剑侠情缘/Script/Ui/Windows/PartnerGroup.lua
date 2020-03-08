
local tbUi = Ui:CreateClass("PartnerGroup")
local nTimerPartnerCount = 10;
local nTimerPartnerTime  = 2;

function tbUi:Init()
	self.tbTimerPartnerAdd = {};
	for i = 1, 4 do
		self.pPanel:SetActive("DeathMark" .. i, false);
	end

	self.bForbidPartner = false;
	self.pPanel:SetActive("Forbidden1", false);
	self.pPanel:SetActive("Forbidden2", false);
	self.pPanel:SetActive("CompanionLockTip", false);

	self.tbRegHpNotifyInfo = {};
	self.pPanel:SetActive("Group1", true);
	self.pPanel:SetActive("Group2", true);
	self.pPanel:SetActive("GroupSelect1", false);
	self.pPanel:SetActive("GroupSelect2", false);
	self.pPanel:Sprite_SetCDControl("ShowGroupCD1", 0, 0);
	self.pPanel:Sprite_SetCDControl("ShowGroupCD2", 0, 0);

	local tbPartnerPos = me.GetPartnerPosInfo();
	for nPos, nPartnerId in pairs(tbPartnerPos) do
		local tbPartner;
		if nPartnerId > 0 then
			tbPartner = me.GetPartnerInfo(nPartnerId);
		end

		if tbPartner then
			self["BgPartnerHead" .. nPos]:SetPartnerInfo(tbPartner);
		end

		self.pPanel:SetActive("Partner" .. nPos, tbPartner and true or false);
		self.pPanel:Sprite_SetFillPercent("HpInfo" .. nPos, 1);
	end

	self.pPanel:SetActive("Group1", tbPartnerPos[1] > 0 or tbPartnerPos[2] > 0);
	self.pPanel:SetActive("Group2", tbPartnerPos[3] > 0 or tbPartnerPos[4] > 0);
	self:ShowGroup(-1);
end

function tbUi:UpdatePartnerHp(nPos, nOldHp, nNewHp, nMaxHp)
	local nPersent = math.max(nNewHp / (nMaxHp or 1), 0);
	nPersent = math.min(nPersent, 1);
	self.pPanel:Sprite_SetFillPercent("HpInfo" .. nPos, nPersent);
end

function tbUi:OnRemovePartnerNpc(nNpcId)
	if self.tbRegHpNotifyInfo[nNpcId] then
		Npc:UnRegisterNpcHpEvent(nNpcId, self.tbRegHpNotifyInfo[nNpcId]);
	end

	local tbTimerInfo = self.tbTimerPartnerAdd[nNpcId];
	if tbTimerInfo and tbTimerInfo.nTimer then
		Timer:Close(tbTimerInfo.nTimer);
	end

	self.tbTimerPartnerAdd[nNpcId] = nil;
end

function tbUi:OnPartnerDeath(nPos)
	self.pPanel:SetActive("DeathMark" .. nPos, true);
end

function tbUi:OnAddPartnerNpcTimer(nNpcId)
	local tbTimerInfo = self.tbTimerPartnerAdd[nNpcId];
	if not tbTimerInfo then
		return;
	end

    local bRet = self:OnAddPartnerNpc(tbTimerInfo.nNpcId, tbTimerInfo.nPos);
    if bRet then
    	self.tbTimerPartnerAdd[nNpcId] = nil;
    	return;
    end

    if tbTimerInfo.nTimerCount <= 0 then
    	self.tbTimerPartnerAdd[nNpcId] = nil;
    	return;
    end

    return true;
end

function tbUi:OnAddPartnerNpc(nNpcId, nPos)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		local tbTimerInfo = self.tbTimerPartnerAdd[nNpcId];
		if tbTimerInfo then
			tbTimerInfo.nTimerCount = tbTimerInfo.nTimerCount - 1;
		else
			tbTimerInfo = {};
			tbTimerInfo.nNpcId = nNpcId;
			tbTimerInfo.nPos   = nPos;
			tbTimerInfo.nTimerCount = nTimerPartnerCount;
			self.tbTimerPartnerAdd[nNpcId] = tbTimerInfo;
			tbTimerInfo.nTimer = Timer:Register(nTimerPartnerTime * Env.GAME_FPS, self.OnAddPartnerNpcTimer, self, nNpcId);
		end
		return false;
	end

	local function fnOnUpdateHp(nOldHp, nNewHp, nMaxHp)
		self:UpdatePartnerHp(nPos, nOldHp, nNewHp, nMaxHp);
	end

	self.tbRegHpNotifyInfo[nNpcId] = Npc:RegisterNpcHpChange(pNpc, fnOnUpdateHp);
	return true;
end

function tbUi:Close()
	for nNpcId, nId in pairs(self.tbRegHpNotifyInfo or {}) do
		Npc:UnRegisterNpcHpEvent(nNpcId, nId);
	end

	for _, tbInfo in pairs(self.tbTimerPartnerAdd or {}) do
		if tbInfo and tbInfo.nTimer then
			Timer:Close(tbInfo.nTimer);
		end
	end

	self.tbTimerPartnerAdd = {};
end

function tbUi:ShowGroup(nGroupId)
	if self.bForbidPartner then
		return;
	end

	if not nGroupId or nGroupId <= 0 then
		if self.pPanel:IsActive("Group1") then
			nGroupId = 1;
		elseif self.pPanel:IsActive("Group2") then
			nGroupId = 2;
		else
			return;
		end
	end

	if self.pPanel:IsActive("ShowGroupCD" .. nGroupId) then
		return;
	end

	if self.pPanel:IsActive("GroupSelect" .. nGroupId) then
		return;
	end

	if IsAlone() == 1 then
		if not me.tbPartnerGroup then
			me.CenterMsg("发生异常，未发现对应同伴分组数据！");
			return;
		end

		me.tbPartnerGroup:ShowGroup(nGroupId);
		self:SwitchToGroup(nGroupId);
	else
		me.SendBlackBoardMsg("暂时不支持非单机模式！");
	end
end

function tbUi:SwitchToGroup(nGroupId, bFixGroup)
	for i = 1, 2 do
		self.pPanel:SetActive("GroupSelect" .. i, i == nGroupId);
		self.pPanel:Widget_ChangeAlpha("Partner" .. (i * 2 - 1), i == nGroupId and 1 or 0.35);
		self.pPanel:Widget_ChangeAlpha("Partner" .. (i * 2), i == nGroupId and 1 or 0.35);
	end

	local nNotSwitchGroupId = (nGroupId == 1 and 2 or 1);
	if bFixGroup then
		self.pPanel:SetActive("Group"..nNotSwitchGroupId, false);
	end

	self.pPanel:Sprite_SetCDControl("ShowGroupCD" .. nNotSwitchGroupId, Partner.tbPartnerGroup.nSwitchGroupCD, Partner.tbPartnerGroup.nSwitchGroupCD);
end

function tbUi:SetForbiddenPartner()
	self.bForbidPartner = true;
	self.pPanel:SetActive("Forbidden1", true);
	self.pPanel:SetActive("Forbidden2", true);
	self.pPanel:SetActive("Group1", false);
	self.pPanel:SetActive("Group2", false);
	self.pPanel:SetActive("CompanionLockTip", true);
	self.pPanel:Sprite_SetCDControl("ShowGroupCD1", 0, 0);
	self.pPanel:Sprite_SetCDControl("ShowGroupCD2", 0, 0);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.Group1 = function (self)
	self:ShowGroup(1);
end

tbUi.tbOnClick.Group2 = function (self)
	self:ShowGroup(2);
end
