
local tbUi = Ui:CreateClass("AsyncPartner");

function tbUi:OnOpen()
	
	local tbPosPartner = me.GetPartnerPosInfo()
	
	self.tbShowPos = {}
	self.tbToAdd = {};
	self.tbBubleTalk = {};
	local nPos = 1;
	for i = 1 , 4 do
		if tbPosPartner[i] and tbPosPartner[i] > 0 then
			self.tbShowPos[i] = nPos;
			self.pPanel:SetActive("Partner"..nPos, true);
			self["PartnerHead"..nPos]:SetPlayerPartner(tbPosPartner[i]);
			self.pPanel:SetActive("DeathMark"..nPos, false);
			self.pPanel:Sprite_SetFillPercent("HpInfo"..nPos, 1);
			if nPos >= 3 then
				self.tbToAdd[i] = true;
			end
			nPos = nPos + 1
		end
	end

	if nPos <= 1 then
		return 0;
	end	
	
	for i = nPos, 4 do
		self.pPanel:SetActive("Partner"..i, false);
	end
	
	self:OnActiveData();
	
	Player:GetActiveRunTimeData()
	self.nTimer = Timer:Register(7, self.UpdateHp, self)
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer);
	end
end

local tbBubleTalkContent = 
{
	"终于轮到我上场了",
	"我来助你一臂之力",
}

function tbUi:OnActiveData()
	local szActiveName, tbData = Player:GetActiveRunTimeData()
	if szActiveName ~= "AsyncBattle" then
		return;
	end
	self.tbPartnerNpcId, self.tbDeath = unpack(tbData);
	self:UpdateHp();
	
	for nPos, _ in pairs(self.tbToAdd) do
		if self.tbPartnerNpcId[nPos] then
			self.tbToAdd[nPos] = nil;
			self.tbBubleTalk[nPos] = tbBubleTalkContent[MathRandom(#tbBubleTalkContent)];
		end
	end
end

function tbUi:UpdateHp()
	if not self.tbPartnerNpcId then
		return true;
	end
	for nPos, nNpcId in pairs(self.tbPartnerNpcId) do
		local nShowPos = self.tbShowPos[nPos]
		if self.tbDeath[nNpcId] then
			self.pPanel:SetActive("DeathMark"..nShowPos, true);
			self.pPanel:Sprite_SetFillPercent("HpInfo"..nShowPos, 0);
		end
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			self.pPanel:Sprite_SetFillPercent("HpInfo"..nShowPos, pNpc.nCurLife / pNpc.nMaxLife);
			if self.tbBubleTalk[nPos] then
				Ui:NpcBubbleTalk(nNpcId, self.tbBubleTalk[nPos], 3, 1)
				self.tbBubleTalk[nPos] = nil;
			end
		end
	end
	
	return true;
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,			self.OnLeaveMap},
        {UiNotify.emNOTIFY_ACTIVE_RUNTIME_DATA,	self.OnActiveData},
    };

    return tbRegEvent;
end

