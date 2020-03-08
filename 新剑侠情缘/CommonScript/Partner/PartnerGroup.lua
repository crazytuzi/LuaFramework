Partner.tbPartnerGroup = Partner.tbPartnerGroup or {};
local tbPartnerGroup = Partner.tbPartnerGroup;
tbPartnerGroup.nSwitchGroupCD = 10;

function Partner:InitPartnerGroup(pPlayer, bNotPlayerDeathEvent)
	pPlayer.tbPartnerGroup = pPlayer.tbPartnerGroup or Lib:NewClass(self.tbPartnerGroup);
	pPlayer.tbPartnerGroup:Init(pPlayer, bNotPlayerDeathEvent);
	return pPlayer.tbPartnerGroup;
end

function Partner:ClosePartner(pPlayer)
	if pPlayer.tbPartnerGroup then
		pPlayer.tbPartnerGroup:Close();
	end
end

function tbPartnerGroup:Init(pPlayer, bNotPlayerDeathEvent)
	self.nPlayerId = pPlayer.dwID;
	self.nGroupId = 0;
	self.tbPartnerInfo = {};
	self.bClose = false;
	self.bCanSwitch = true;
	self.bFixGroupID = false;

	local bHasPartner = false;
	local tbPartnerPosInfo = pPlayer.GetPartnerPosInfo();
	for nIdx, nPartnerId in pairs(tbPartnerPosInfo) do
		self.tbPartnerInfo[nIdx] = {};
		if nPartnerId > 0 then
			bHasPartner = true;
		end
	end

	self.nPartnerDeathId = PlayerEvent:Register(pPlayer, "OnPartnerDeath", self.OnPartnerDeath, self);

	if not bNotPlayerDeathEvent then
		self.nPlayerDeathId = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self);
	end

	if bHasPartner then
		pPlayer.CallClientScript("Partner:PGInit");
	end
end

function tbPartnerGroup:DoForbidPartner()
	self.bForbidPartner = true;
	self:RemovePartnerNpc();
	me.CallClientScript("Partner:PGForbiddenPartner");
end

function tbPartnerGroup:GetPlayer()
	return KPlayer.GetPlayerObjById(self.nPlayerId or 0);
end

function tbPartnerGroup:OnPlayerDeath()
	if self.bClose or self.nGroupId <= 0 or self.nGroupId > 2 then
		return;
	end

	local pPlayer = self:GetPlayer();
	if not pPlayer then
		self:Close();
		return;
	end

	local tbPartnerPosInfo = pPlayer.GetPartnerPosInfo();
	for i = 1, 2 do
		local nPos = (self.nGroupId - 1) * 2 + i;
		local nPartnerId = tbPartnerPosInfo[nPos];
		if nPartnerId and nPartnerId > 0 and self.tbPartnerInfo[nPos] and not self.tbPartnerInfo[nPos].bIsDeath then
			local pNpc = KNpc.GetById(self.tbPartnerInfo[nPos].nNpcId or 0);
			if pNpc then
				pNpc.Delete();
			end

			self:OnPartnerDeath(nPartnerId);
		end
	end
end

function tbPartnerGroup:OnPartnerDeath(nPartnerId)
	local pPlayer = self:GetPlayer();
	if not pPlayer then
		self:Close();
		return;
	end

	local tbPartnerPosInfo = pPlayer.GetPartnerPosInfo();
	local nCurPos;
	for nPos, nPosId in pairs(tbPartnerPosInfo) do
		if nPosId == nPartnerId then
			nCurPos = nPos;
			break;
		end
	end

	if not nCurPos then
		return;
	end

	self.tbPartnerInfo[nCurPos].bIsDeath = true;
	self.tbPartnerInfo[nCurPos].nCurLife = 0;
	self.tbPartnerInfo[nCurPos].nAnger = 0;
	self.tbPartnerInfo[nCurPos].nNpcId = 0;
	pPlayer.CallClientScript("Partner:PGPartnerDeath", nCurPos);
end

function tbPartnerGroup:RemovePartnerNpc()
	if self.bClose then
		return;
	end

	local pPlayer = self:GetPlayer();

	self.nGroupId = 0;
	for nPos = 1, 4 do
		if self.tbPartnerInfo[nPos] and self.tbPartnerInfo[nPos].nNpcId and self.tbPartnerInfo[nPos].nNpcId > 0 then
			local pNpc = KNpc.GetById(self.tbPartnerInfo[nPos].nNpcId);
			if pNpc then
				self.tbPartnerInfo[nPos].nCurLife = pNpc.nCurLife;
				self.tbPartnerInfo[nPos].nAnger = pNpc.nAnger;
				pNpc.Delete();

				if pPlayer then
					pPlayer.CallClientScript("Partner:PGPartnerNpcChange", false, pNpc.nId);
				end
			end
		end
	end
end

function tbPartnerGroup:SetPosition(nX, nY)
	local pPlayer = self:GetPlayer();
	if not pPlayer then
		return;
	end

	local m, x, y = pPlayer.GetWorldPos();
	nX = nX or x;
	nY = nY or y;

	for nPos = 1, 4 do
		if self.tbPartnerInfo[nPos] and self.tbPartnerInfo[nPos].nNpcId and self.tbPartnerInfo[nPos].nNpcId > 0 then
			local pNpc = KNpc.GetById(self.tbPartnerInfo[nPos].nNpcId);
			if pNpc then
				pNpc.SetPosition(nX, nY);
			end
		end
	end
end

function tbPartnerGroup:AllPartnerExcute(fnExcute, ...)
	for nPos = 1, 4 do
		if self.tbPartnerInfo[nPos] and self.tbPartnerInfo[nPos].nNpcId and self.tbPartnerInfo[nPos].nNpcId > 0 then
			local pNpc = KNpc.GetById(self.tbPartnerInfo[nPos].nNpcId);
			if pNpc then
				fnExcute(pNpc, ...);
			end
		end
	end
end

function tbPartnerGroup:ShowGroup(nGroupId, bFixGroupID)
	if self.bClose or self.bFixGroupID then
		return;
	end

	if not nGroupId or nGroupId < 0 or nGroupId > 2 or nGroupId == self.nGroupId then
		return;
	end

	if not self.bCanSwitch then
		local nLastTime = Timer:GetRestTime(self.nSwitchGroupTimerId);
		nLastTime = math.max(nLastTime or 1, 1);
		me.CenterMsg(string.format("还要%d秒才能切换另一组同伴！", nLastTime));
		return;
	end

	local pPlayer = self:GetPlayer();
	if not pPlayer then
		self:Close();
		return;
	end

	self:RemovePartnerNpc();

	self.nGroupId = nGroupId;
	self.bFixGroupID = bFixGroupID;

	local tbPartnerNpc = {};
	for i = 1, 2 do
		local nPos = i + (self.nGroupId - 1) * 2
		if self.tbPartnerInfo[nPos] and not self.tbPartnerInfo[nPos].bIsDeath then
			local pNpc = pPlayer.CreatePartnerByPos(nPos);
			if pNpc then
				self.tbPartnerInfo[nPos].nNpcId = pNpc.nId;
				pNpc.nPartnerPos = nPos;
				pNpc.nFightMode = 1;

				if self.tbPartnerInfo[nPos].nCurLife and self.tbPartnerInfo[nPos].nCurLife > 0 then
					pNpc.SetCurLife(self.tbPartnerInfo[nPos].nCurLife);
				end

				if self.tbPartnerInfo[nPos].nAnger and self.tbPartnerInfo[nPos].nAnger > 0 then
					pNpc.AddAnger(self.tbPartnerInfo[nPos].nAnger);
				end

				tbPartnerNpc[i] = pNpc.nId;
				pPlayer.CallClientScript("Partner:PGPartnerNpcChange", true, pNpc.nId, nPos);
			end
		end
	end

	if self.nSwitchGroupTimerId then
		Timer:Close(self.nSwitchGroupTimerId);
	end

	self.bCanSwitch = false;
	self.nSwitchGroupTimerId = Timer:Register(Env.GAME_FPS * self.nSwitchGroupCD, function () self.nSwitchGroupTimerId = nil; self.bCanSwitch = true; end)

	pPlayer.CallClientScript("Partner:PGSwitchToGroup", nGroupId, self.bFixGroupID, tbPartnerNpc[1] or 0, tbPartnerNpc[2] or 0);
end

function tbPartnerGroup:Close()
	local pPlayer = self:GetPlayer();
	if pPlayer and self.nPartnerDeathId then
		PlayerEvent:UnRegister(pPlayer, "OnPartnerDeath", self.nPartnerDeathId);
		self.nPartnerDeathId = nil;
	end

	if pPlayer and self.nPlayerDeathId then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", self.nPlayerDeathId);
		self.nPlayerDeathId = nil;
	end

	if self.nSwitchGroupTimerId then
		Timer:Close(self.nSwitchGroupTimerId);
		self.nSwitchGroupTimerId = nil;
	end

	self:RemovePartnerNpc();
	pPlayer.tbPartnerGroup = nil;
	self.bClose = true;

	pPlayer.CallClientScript("Partner:PGClose");
end
