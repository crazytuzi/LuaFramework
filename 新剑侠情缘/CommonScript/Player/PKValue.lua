
PKValue.PKValue_GroupId = 37;
PKValue.PKValue_ValueId = 1;

PKValue.MAX_VALUE = 10;

PKValue.tbSetting = PKValue.tbSetting or {};
function PKValue:LoadSetting()
	PKValue.tbSetting = LoadTabFile("Setting/Player/PKValue.tab", "dd", "nValue", {"nValue", "nBaseExp"});
	for i = 1, self.MAX_VALUE do
		assert(PKValue.tbSetting[i]);
	end
end
PKValue:LoadSetting();

function PKValue:GetPKValue(pPlayer)
	return pPlayer.GetUserValue(self.PKValue_GroupId, self.PKValue_ValueId);
end

function PKValue:GetAddValue(pKiller, pKilled)
	if TeacherStudent:IsMyTeacher(pKiller, pKilled.dwID) then
		return 2, "你击伤了师父，恶名值增加2", "您被徒弟击为重伤！"
	end
	return 1
end

function PKValue:AddValue(pKiller, pKilled)
	local nCurValue = self:GetPKValue(pKiller);
	local nAdd, szKillerMsg, szKilledMsg = self:GetAddValue(pKiller, pKilled)
	nCurValue = math.min(nCurValue + nAdd, self.MAX_VALUE);
	pKiller.Msg(string.format("恶名值增加，当前恶名值%s", nCurValue));
	if szKillerMsg then
		pKiller.Msg(szKillerMsg)
	end
	if szKilledMsg then
		pKilled.Msg(szKilledMsg)
	end

	if nCurValue >= self.MAX_VALUE and pKiller.nPkMode == Player.MODE_KILLER then
		pKiller.SetPkMode(Player.MODE_PK);
	end

	pKiller.SetUserValue(self.PKValue_GroupId, self.PKValue_ValueId, nCurValue);
	AssistClient:ReportQQScore(pKiller, Env.QQReport_KillCount, nCurValue, 0, 1)
end

function PKValue:ReduceValue(pPlayer)
	local nCurValue = self:GetPKValue(pPlayer);
	if nCurValue <= 0 then
		return;
	end
	nCurValue = nCurValue - 1;
	pPlayer.Msg(string.format("恶名值减少，当前恶名值%s", nCurValue));
	pPlayer.SetUserValue(self.PKValue_GroupId, self.PKValue_ValueId, nCurValue);
end

function PKValue:CheckMaxValue(pPlayer)
	return self:GetPKValue(pPlayer) >= self.MAX_VALUE;
end

function PKValue:SetLostExpPercent(nPercent)
	self.nPercent = nPercent;
end

function PKValue:GetExpCount(pPlayer)
	local nPKValue = math.min(self:GetPKValue(pPlayer), self.MAX_VALUE);
	local tbSetting = self.tbSetting[nPKValue];

	local nExpCount = math.min(pPlayer.GetExp(), math.floor(math.max(self.nPercent or 1, 0) * pPlayer.GetBaseAwardExp() * tbSetting.nBaseExp / 10));
	nExpCount = math.max(nExpCount, 0);

	return nExpCount;
end
