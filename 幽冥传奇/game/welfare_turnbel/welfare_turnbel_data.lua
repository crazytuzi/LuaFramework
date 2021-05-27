WelfareTurnbelData = WelfareTurnbelData or BaseClass()

WelfareTurnbelData.INFO_CHANGE = "welfare_info_change"
WelfareTurnbelData.GET_AWARD = "welfare_get_award"
function WelfareTurnbelData:__init()
	if WelfareTurnbelData.Instance then
		ErrorLog("[WelfareTurnbelData] attempt to create singleton twice!")
		return
	end

    --数据派发组件
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	WelfareTurnbelData.Instance = self

	self.start_time = 0
end

function WelfareTurnbelData:__delete()
end

function WelfareTurnbelData:GetAllOnlineTime()
	return self.all_online_time + (Status.NowTime - self.start_time)
end

function WelfareTurnbelData:SetData(info)
	self.score = info.score
	self.all_online_time = info.all_online_time
	self.kill_boss_num = info.kill_boss_num
	self.flags = WelfareTurnbelData.PraseFlag(info.flag)
	self.award = info.award and info.award or self.award
	self.records = info.records and info.records or self.records
	self:DispatchEvent(WelfareTurnbelData.INFO_CHANGE)
	if self.award and self.award > 0 then
		self:DispatchEvent(WelfareTurnbelData.GET_AWARD, {idx = self.award})
		self.award = 0
	end
	GameCondMgr.Instance:CheckCondType(GameCondType.IsWelfreTurnbelOpen)
end

function WelfareTurnbelData:IsShow()
	return nil ~= self:GetCurrDrawIdx()
end

function WelfareTurnbelData:GetCurrDrawIdx()
	local num = 0
	if nil == self.flags then return end
	for k,v in pairs(self.flags.is_draw) do
		if v then
			num = num + 1
		end
	end
	return num < #WelfareTable.points and num + 1 or nil
end

function WelfareTurnbelData.PraseFlag(flag)
	local t = {}
	t.is_draw = {}
	for i = 1, #WelfareTable.points do
		t.is_draw[i] = bit:_and(1, bit:_rshift(flag, i - 1)) == 1
	end
	t.is_lingqu_online = bit:_and(1, bit:_rshift(flag, 30)) == 1
	t.is_lingqu_boss = bit:_and(1, bit:_rshift(flag, 31)) == 1
	return t
end

function WelfareTurnbelData:IsCanLqOnline()
	return (not self.flags.is_lingqu_online) and self:GetAllOnlineTime() >= WelfareTable.OnlineDura.itmes
end

function WelfareTurnbelData:IsCanLqBoss()
	return (not self.flags.is_lingqu_boss )and self.kill_boss_num >= WelfareTable.BossPoint.bosscount
end

function WelfareTurnbelData:IsCanDraw()
	local idx = self:GetCurrDrawIdx()
	return idx and self.score >= WelfareTable.points[idx]
end

function WelfareTurnbelData:GetRewardRemind()
	if self:IsCanLqBoss() or self:IsCanLqOnline() or self:IsCanDraw() then
		return 1
	end
	return 0
end
