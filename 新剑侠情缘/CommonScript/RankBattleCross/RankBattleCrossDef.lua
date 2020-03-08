RankBattleCross.bTest = false
RankBattleCross.bOpen = true
RankBattleCross.bOpenStartSchedule = true 					-- 是否开放开启活动的定时器触发接口（如果用指令触发活动活动之后应该设置关闭防止重复触发）
RankBattleCross.szOpenTimeFrame = "OpenLevel49"
RankBattleCross.nJoinLevel = 12
RankBattleCross.DEF_ROOM_NO = 95
RankBattleCross.DEF_NO = 2001

RankBattleCross.FIGHT_TYPE_NPC = 1
RankBattleCross.FIGHT_TYPE_PLAYER = 2

RankBattleCross.FRESH_CD_TIME = 5 				-- 刷新对手时间间隔
RankBattleCross.nAliveTime = 227 * 60 * 60 		-- 活动持续时间
RankBattleCross.NO_LIMIT_RANK = 5;
--竞技场地图
RankBattleCross.FIGHT_MAP = 1003

RankBattleCross.WIN_AWARD = 12;
RankBattleCross.LOST_AWARD = 8
RankBattleCross.ENTER_POINT = {1900, 2450}
RankBattleCross.BATTLE_TIME_OUT = 90

RankBattleCross.tbRankAward = 
{
	[1] = {1, {{"Item", 10781, 6}}}, 		-- N名以下（包括N名）的奖励
	[2] = {2, {{"Item", 10781, 5}}}, 
	[3] = {5, {{"Item", 10781, 4}}}, 
	[4] = {10, {{"Item", 10781, 3}}}, 
	[5] = {20, {{"Item", 10781, 2}}}, 		-- N名以下（包括N名）的奖励
	[6] = {50, {{"Item", 10782, 3}}}, 
	[7] = {100, {{"Item", 10782, 2}}}, 
	[8] = {150, {{"Item", 10782, 1}}}, 
	[9] = {200, {{"Energy", 2500}}}, 
	[10] = {3000, {{"Energy", 1000}}}, 
}

RankBattleCross.nOpenDay = 16 							-- 几号开启
RankBattleCross.nCloseDay = 25 							-- 几号结束

RankBattleCross.nNewMsgTime = 15*60*60
RankBattleCross.szNewMsgContent = string.format([[
跨服武神殿将于[FFFE0D]今日13：00[-]开启。
开启时间：[FFFE0D]7月%d日-7月%d日[-]
参与资格：本月重置后至活动正式开始前在本服武神殿中达到过前[FFFE0D]50[-]名的玩家。
参与方式：在原武神殿的界面增加了[FFFE0D]跨服[-]分页，切换分页即可进行跨服挑战，和本战区其他服的高手切磋。
参与次数：参与次数和本服共用，暂不给予额外的参与次数。
活动奖励：每晚22：00根据您在跨服武神殿中的排名，给予不同数量不同品质的[FFFE0D]跨服武神宝箱[-]奖励，具体可在跨服武神殿页面对您当前排名奖励进行预览。]], RankBattleCross.nOpenDay, RankBattleCross.nCloseDay)

RankBattleCross.nNotifyDay = 16 						-- 几号发最新消息
RankBattleCross.nNotify2Start = 5* 3600 				-- 从发最新消息到活动开始要多久

RankBattleCross.nMaxReportServerCount = 20 				-- 最大尝试上报服务器信息的次数
RankBattleCross.nMaxReportPlayerCount = 5

function RankBattleCross:CheckNotifyOpenDay()
	if not RankBattleCross.bOpen then
		return false
	end
	local nCurDay = Lib:GetMonthDay()
	if nCurDay == self.nNotifyDay then
		return true
	end
	return false
end

function RankBattleCross:CheckOpenDay()
	if not RankBattleCross.bOpen then
		return false
	end
	local nCurDay = Lib:GetMonthDay()
	if nCurDay == self.nOpenDay then
		return true
	end
	return false
end

function RankBattleCross:CheckCloseDay()
	local nCurDay = Lib:GetMonthDay()
	if nCurDay == self.nCloseDay then
		return true
	end
	return false
end

-- todo
function RankBattleCross:CheckOpen()
	if not RankBattleCross.bOpen then
		return false
	end
	if GetTimeFrameState(RankBattleCross.szOpenTimeFrame) ~= 1 then
		return false
	end
	local nCrossStartTime = 0
	if MODULE_GAMESERVER then
		local tbSaveData = RankBattle:GetSaveActData()
		nCrossStartTime = tbSaveData.nCrossStartTime or 0
	else
		nCrossStartTime = self.nStartTime or 0
	end
	local nNowTime = GetTime()
	if nNowTime >= nCrossStartTime and nNowTime <= nCrossStartTime + RankBattleCross.nAliveTime then
		return true
	end

	return false
end

function RankBattleCross:CheckVersionDistance(nVersion, nBestRankVersion)
	if nVersion == 0 or nBestRankVersion == 0 then
		return false
	end
	-- 针对合服情况，不同服的版本时间可以不一样，兼容在相差6 * 60 * 60之内都算同一个活动版本
	return math.abs(nVersion - nBestRankVersion) <= 60 * 60 and true or false
end

function RankBattleCross:HaveCrossQualification(pPlayer)
	local nVersion = RankBattle:GetActVersion()
	if nVersion == 0 then
		return false
	end
	local nBestRankVersion = pPlayer.GetUserValue(RankBattle.SAVE_GROUP, RankBattle.nRankActBestRankVersion)
	if nBestRankVersion == 0 then
		return false
	end
	if not RankBattleCross:CheckVersionDistance(nVersion, nBestRankVersion) then
		return false
	end
	local nRank = pPlayer.GetUserValue(RankBattle.SAVE_GROUP, RankBattle.nRankActBestRank)
	if nRank == 0 then
		return false
	end
	return nRank <= RankBattle.nJoinCrossRank
end

function RankBattleCross:CanJoin(pPlayer)
	return RankBattleCross:CheckOpen() and RankBattleCross:HaveCrossQualification(pPlayer)
end

function RankBattleCross:Log(szLog, ...)
    Log("RankBattleCross ", szLog, ...);
end

function RankBattleCross:GetDefNo()
	return RankBattleCross.DEF_NO
end

function RankBattleCross:GetDefRoom()
	return RankBattleCross.DEF_ROOM_NO
end

function RankBattleCross:GetRankAward(nRank)
	local tbAllReward = {}

	for _,tbInfo in ipairs(RankBattleCross.tbRankAward) do
		if nRank <= tbInfo[1] and tbInfo[2] then
			tbAllReward = tbInfo[2]
			break
		end
	end

	return self:FormatReward(tbAllReward)
end

function RankBattleCross:FormatReward(tbAllReward)
	tbAllReward = Lib:CopyTB(tbAllReward or {})

	local tbFormatReward = {}
	for _,tbReward in ipairs(tbAllReward) do
		if tbReward[1] == "AddTimeTitle" then
			tbReward[3] = tbReward[3] + GetTime()
		end
		table.insert(tbFormatReward,tbReward)
	end

	return tbFormatReward
end