Partner.PartnerTalk = Partner.PartnerTalk or {};

local PartnerTalk = Partner.PartnerTalk;

PartnerTalk.nTimeout = 30;
PartnerTalk.tbAllHPInfo = {
	[50] = 1,
	[20] = 2,
};

PartnerTalk.EVENT_TIMEOUT = 100;

function PartnerTalk:LoadSetting()
	local tbFile = LoadTabFile("Setting/Partner/PartnerTalk.tab", "dds", nil, {"nType", "nEventId", "szInfo"})
	self.tbAllMsg = {};
	for _, tbRow in pairs(tbFile) do
		self.tbAllMsg[tbRow.nType] = self.tbAllMsg[tbRow.nType] or {};
		self.tbAllMsg[tbRow.nType][tbRow.nEventId] = self.tbAllMsg[tbRow.nType][tbRow.nEventId] or {};
		table.insert(self.tbAllMsg[tbRow.nType][tbRow.nEventId], tbRow.szInfo);
	end

	tbFile = LoadTabFile("Setting/Partner/PartnerTalkType.tab", "dd", nil, {"nPartnerId", "nType"});
	self.tbPartnerType = {};
	for _, tbInfo in pairs(tbFile) do
		self.tbPartnerType[tbInfo.nPartnerId] = tbInfo.nType;
	end
end
PartnerTalk:LoadSetting();

function PartnerTalk:GetMsg(nPartnerTemplateId, nEventId)
	local nType = self.tbPartnerType[nPartnerTemplateId];
	if not nType or not self.tbAllMsg[nType] or not self.tbAllMsg[nType][nEventId] then
		return;
	end

	local tbAllMsg = self.tbAllMsg[nType][nEventId];
	return tbAllMsg[MathRandom(#tbAllMsg)];
end

function PartnerTalk:GetHpEventId(nHp, nMaxHp)
	if not self.tbHpInfo then
		self.tbHpInfo = {};
		for nHpInfo, nEventId in pairs(self.tbAllHPInfo) do
			table.insert(self.tbHpInfo, nHpInfo);
		end
		table.sort(self.tbHpInfo, function (a, b) return a > b; end);
	end

	local nPercent = nHp * 100 / nMaxHp;
	local nLP = 0;
	for _, np in ipairs(self.tbHpInfo) do
		if nPercent <= np then
			nLP = self.tbAllHPInfo[np];
		else
			break;
		end
	end

	return nLP;
end

-- 血量 每 %5 一个阶段
function PartnerTalk:OnPlayerHpChange(nOldHp, nNewHp, nMaxHp)
	local nOldEventId = self:GetHpEventId(nOldHp, nMaxHp);
	local nNewEventId = self:GetHpEventId(nNewHp, nMaxHp);
	if nOldEventId == nNewEventId or nNewEventId <= 0 then
		return;
	end

	self:OnEvent(nNewEventId);
end

function PartnerTalk:OnMapLoaded()
	if not self:CheckNeedPartnerTalk() then
		return;
	end

	self:SetTimeout();
end

function PartnerTalk:CheckNeedPartnerTalk()

	-- 关卡需要
	if Fuben:GetFubenInstance(me) and IsAlone() == 1 then
		return true;
	end

	return false;
end

function PartnerTalk:OnEvent(nEventId)
	if not self:CheckNeedPartnerTalk() then
		return;
	end

	self:SetTimeout();

	local tbAllPartnerNpc = me.GetAllPartnerNpc();
	if #tbAllPartnerNpc <= 0 then
		return;
	end

	local nIdx = MathRandom(#tbAllPartnerNpc);
	local pPartnerNpc = tbAllPartnerNpc[nIdx];
	local szMsg;

	local tbAllPartner = me.GetAllPartner();
	for nPartnerId, tbInfo in pairs(tbAllPartner) do
		if tbInfo.nNpcTemplateId == pPartnerNpc.nTemplateId then
			szMsg = self:GetMsg(tbInfo.nTemplateId, nEventId);
			break;
		end
	end

	if not szMsg then
		return;
	end

	pPartnerNpc.BubbleTalk(szMsg, "3")
end

function PartnerTalk:SetTimeout()
	if self.nTimeoutId then
		Timer:Close(self.nTimeoutId);
		self.nTimeoutId = nil;
	end

	self.nTimeoutId = Timer:Register(Env.GAME_FPS * self.nTimeout, function ()
		self.nTimeoutId = nil;
		self:OnEvent(self.EVENT_TIMEOUT);
	end);
end


PlayerEvent:RegisterGlobal("OnHpChange",	Partner.PartnerTalk.OnPlayerHpChange, Partner.PartnerTalk);
