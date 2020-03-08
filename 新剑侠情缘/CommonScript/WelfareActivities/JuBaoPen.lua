JuBaoPen.SAVE_GROUP = 42
JuBaoPen.SAVE_KEY_TAKE = 1; --领取聚宝盆的时间


JuBaoPen.OPEN_LEVEL = 999; --开放等级
JuBaoPen.MAX_MONEY = 50000; --聚宝盆银两上限
JuBaoPen.TIME_INTERVAL = 1800 --增长间隔
JuBaoPen.TAKE_MONEY_CD = 8 * 3600 --领取银两CD



--聚宝事件概率
JuBaoPen.tbEventProp = 
{
	{Money = 500,  nProb = 0.74},
	{Money = 1000, nProb = 0.23},
	{Money = 5000, nProb = 0.03},
}


-- <= 0 就是无CD
function JuBaoPen:GetTakeMoneyCDTime(pPlayer)
	local nLastTakeTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_TAKE)
	local nCurTime = GetTime()
	return nLastTakeTime + self.TAKE_MONEY_CD - nCurTime
end
