local tbUi = Ui:CreateClass("SpecialLife");

tbUi.MAX_SHOW_COUNT = 5;
tbUi.tbBloodSp = 
{
	[0] = "BossBloodBackground",
	[1] = "StripGreen",
	[2] = "StripPurple",
	[3] = "StripBlue",
	[4] = "StripRed",
	[5] = "StripOrange",
	[6] = "StripRed",
	[7] = "StripOrange",
	[8] = "StripRed",
	[9] = "StripOrange",
	[10] = "StripRed",
}

tbUi.nSpeed = 0.5; -- 播放速度 (每秒播放一条血的比例)
function tbUi:OnOpen(nNpcId, nBloodLevel)
end

function tbUi:OnOpenEnd(nNpcId, nBloodLevel)
	self.nNpcId = nNpcId;
	self.nBloodLevel = math.min(nBloodLevel or 1, self.MAX_SHOW_COUNT);
	self.nCurRangePt = 1 / self.nBloodLevel;
	self.nRealPercent = 1;
	self.nCurPercent = 1;
	self.nCurBL = self.nBloodLevel;
	self.nShowPt = 1;

	self:SetPercent(self.nRealPercent);
	self:InitNpcBlood();
end

function tbUi:InitNpcBlood()
	local pNpc = KNpc.GetById(self.nNpcId or 0);
	if not pNpc then
		Ui:CloseWindow("SpecialLife");
		return;
	end

	self.pPanel:Label_SetText("TargetName", pNpc.szName);
	local function fnOnUpdateHp(nOldHp, nNewHp, nMaxHp)
		self:SetBlood(nOldHp, nNewHp, nMaxHp);
	end

	self.nRegisterId = Npc:RegisterNpcHpChange(pNpc, fnOnUpdateHp);

	if not self.nCheckTimerId then
		self:CheckNpc();
	end
end

function tbUi:CheckNpc()
	local pNpc = KNpc.GetById(self.nNpcId or 0);
	if not pNpc then
		self.nCheckTimerId = nil;
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	self.nCheckTimerId = Timer:Register(2 * Env.GAME_FPS, self.CheckNpc, self);
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	if self.nCheckTimerId then
		Timer:Close(self.nCheckTimerId);
		self.nCheckTimerId = nil;
	end

	Npc:UnRegisterNpcHpEvent(self.nNpcId, self.nRegisterId);
	self.nNpcId = nil;
	self.nRegisterId = nil;
end

function tbUi:SetBlood(nOldHp, nNewHp, nMaxHp)
	self.nRealPercent = nNewHp / nMaxHp;
	if self.nTimerId then
		return;
	end

	self:SetPercent(math.max(nOldHp, nNewHp) / nMaxHp);
	self:UpdateBlood();
end

function tbUi:GetPosInfo(nPercent)
	local nCount = math.floor(nPercent / self.nCurRangePt);
	local nShowPt = (nPercent % self.nCurRangePt) / self.nCurRangePt;
	if nCount > 0 and math.abs(nShowPt) <= 0.00001 then
		nCount = nCount - 1;
		nShowPt = 1;
	end

	return nCount, nShowPt;
end

function tbUi:SetPercent(nPercent, bNotClose)
	self.nCurPercent = nPercent;

	self.nCurBL, self.nShowPt = self:GetPosInfo(nPercent);
	self.pPanel:Sprite_SetSprite("ForSp", self.tbBloodSp[self.nCurBL + 1]);
	self.pPanel:Sprite_SetSprite("BgSp", self.tbBloodSp[self.nCurBL]);
	self.pPanel:Sprite_SetFillPercent("ForSp", self.nShowPt);
	self.pPanel:Sprite_SetFillPercent("MidSp", 0);

	if not bNotClose and self.nCurPercent <= 0.00005 then
		Ui:CloseWindow("SpecialLife");
	end
end

function tbUi:UpdateBlood()
	Log("UpdateBlood -->> ", self.nCurPercent or 0, self.nRealPercent or 0);
	if math.abs(self.nCurPercent - self.nRealPercent) <= 0.00005 then
		self.nTimerId = nil;
		self:SetPercent(self.nRealPercent);
		return;
	end

	if self.nRealPercent > self.nCurPercent then
		self.nTimerId = nil;
		self:SetPercent(self.nRealPercent);
		return;
	end

	self:SetPercent(self.nCurPercent - 0.00001, true);

	local nRealBL, nRealShowPt = self:GetPosInfo(self.nRealPercent);
	local nShowPt = nRealBL < self.nCurBL and 0 or nRealShowPt;
	local nTime = (self.nShowPt - nShowPt) / self.nSpeed;

	self.pPanel:Tween_FillAmountPlay("MidSp", self.nShowPt, nShowPt, nTime);
	self.nCurPercent = self.nCurPercent - (self.nShowPt - nShowPt) * self.nCurRangePt;

	self:SetPercent(self.nCurPercent + 0.00001, true);

	self.nTimerId = Timer:Register(Env.GAME_FPS * nTime + 2, self.UpdateBlood, self);
end
