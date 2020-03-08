ChouJiang.tbActInfo = ChouJiang.tbActInfo or {}
ChouJiang.tbRankSprite = 
{
	[1] = {"Reword_04","icon_egg04"},
	[2] = {"Reword_01","icon_egg03"},
	[3] = {"Reword_02","icon_egg02"},
	[4] = {"Reword_03","icon_egg01"},
}

function ChouJiang:GetRankSprite(nRank)
	return ChouJiang.tbRankSprite[nRank]
end

function ChouJiang:OnSynActTime(nStartTime,nEndTime)
	ChouJiang.tbActInfo.nStartTime = nStartTime
	ChouJiang.tbActInfo.nEndTime = nEndTime
end

function ChouJiang:GetStartTime()
	if ChouJiang.tbActInfo.nEndTime and GetTime() < ChouJiang.tbActInfo.nEndTime then
		return ChouJiang.tbActInfo.nStartTime or 0
	end
	return 0
end

function ChouJiang:OnUseNewYearJiangQuan()
	Ui:OpenWindow("ChouJiangEffectPanel")
end

function ChouJiang:GetDayShowAward()
	local nLastExeDay = ChouJiang:GetLastExeDay(ChouJiang.tbActInfo.nStartTime)
	if nLastExeDay == 0 then
		return
	end
	local nLotteryTime = tonumber(os.date("%Y%m%d", ChouJiang.tbActInfo.nStartTime + (nLastExeDay - 1)* 24 * 3600 ))
	local tbAwardData
	for _,tbInfo in ipairs(ChouJiang.tbDayShowAward) do
		local szTimeFrame = tbInfo[1]
		local nTimeFrame = tonumber(os.date("%Y%m%d", CalcTimeFrameOpenTime(szTimeFrame)))
		if nTimeFrame > nLotteryTime then
			break
		else
			tbAwardData = tbInfo[2]
		end
	end
	return tbAwardData
end

function ChouJiang:GetBigShowAward()
	if not ChouJiang.tbActInfo.nStartTime or ChouJiang.tbActInfo.nStartTime == 0 then
		return
	end
	local nLotteryTime = tonumber(os.date("%Y%m%d", ChouJiang.tbActInfo.nStartTime + (ChouJiang.nBigExecuteDay - 1)* 24 * 3600 ))
	local tbAwardData
	for _,tbInfo in ipairs(ChouJiang.tbBigShowAward) do
		local szTimeFrame = tbInfo[1]
		local nTimeFrame = tonumber(os.date("%Y%m%d", CalcTimeFrameOpenTime(szTimeFrame)))
		if nTimeFrame > nLotteryTime then
			break
		else
			tbAwardData = tbInfo[2]
		end
	end
	return tbAwardData	
end

function ChouJiang:GetDayLotteryDate()
	local szDate = "无抽奖活动"
	local nLastExeDay = ChouJiang:GetLastExeDay(ChouJiang.tbActInfo.nStartTime)
	if nLastExeDay == 0 then
		return szDate
	end
	local tbTime = Lib:SplitStr(ChouJiang.szDayTime, ":")
	if ChouJiang.tbDayLotteryDate[nLastExeDay] then
		szDate = "下次开奖将在" ..ChouJiang.tbDayLotteryDate[nLastExeDay] ..string.format("%s时",tbTime[1] or "-")
	end
	return szDate
end

function ChouJiang:OnCheckData()
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHOUJIANG_CHECK_DATA)
end