LoginAwards.LOGIN_AWARDS_GROUP = 19;
LoginAwards.LAST_LOGIN_TIME    = 1; --上次登录时间
LoginAwards.LOGIN_DAYS         = 2; --登录的天数
LoginAwards.RECEIVE_FLAG       = 3; --未领取奖励，最多31位(一个月的天数)

LoginAwards.REFRESH_TIME       = 4*60*60
LoginAwards.SHOW_LEVEL         = 5 --显示在首页上的等级

LoginAwards.CREATE_TIME_14 = Lib:ParseDateTime("2016-11-30 00:00:00")

LoginAwards.NEWYEAR_ACT_LEVEL = 40

function LoginAwards:Init()
	local tbSettings 	= LoadTabFile("Setting/WelfareActivity/LoginAwards.tab", "dsdd", nil, {"nDayIdx", "szType", "nItemId", "nCount"});
	self.tbAwardsInfo 	= {};

	local nCreateTime = GetServerCreateTime()
	for _, tbSet in ipairs(tbSettings or {}) do
		if (nCreateTime <= self.CREATE_TIME_14 and tbSet.nDayIdx <= 7) or (nCreateTime > self.CREATE_TIME_14) then
			if not self.tbAwardsInfo[tbSet.nDayIdx] then
				self.tbAwardsInfo[tbSet.nDayIdx] = {};
			end

			if tbSet.nItemId > 0 then
				table.insert(self.tbAwardsInfo[tbSet.nDayIdx], {tbSet.szType, tbSet.nItemId, tbSet.nCount});
			else
				table.insert(self.tbAwardsInfo[tbSet.nDayIdx], {tbSet.szType, tbSet.nCount});
			end
		end
	end

	self.nMaxDays = #self.tbAwardsInfo;
end

function LoginAwards:GetDayAward(nDayIdx)
	if not self.tbAwardsInfo then
		self:Init()
	end
	return self.tbAwardsInfo[nDayIdx]
end

function LoginAwards:GetActLen()
	if not self.tbAwardsInfo then
		self:Init()
	end
	return self.nMaxDays
end

--For NewYearLoginAct
function LoginAwards:GetSaveInfo(nIdx, nBeginSave)
    nBeginSave = nBeginSave or 0
    local nSaveApp = nBeginSave + math.ceil((nIdx-0.1)/32) - 1
    local nFlagIdx = math.ceil((nIdx-0.1)%32)
    return nSaveApp, nFlagIdx
end

function LoginAwards:GetCurDayIdx(nStartTime)
	return math.max(1, Lib:GetLocalDay(GetTime() - LoginAwards.REFRESH_TIME) - Lib:GetLocalDay(nStartTime - LoginAwards.REFRESH_TIME) + 1)
end