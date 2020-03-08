if not MODULE_GAMESERVER then
    Activity.ZhongQiuJie = Activity.ZhongQiuJie or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("ZhongQiuJie") or Activity.ZhongQiuJie
tbAct.szMainKey = "ZhongQiuJie"
tbAct.REFRESH_TIME          = 4*3600
tbAct.TIME_OUT              = 30
tbAct.MAX_QUESTION          = 10
tbAct.nJoinLevel = 30
tbAct.tbQuestionAward_Right = {"Contrib", 100}
tbAct.tbQuestionAward_Wrong = {"Contrib", 50}
tbAct.CLEARING_TIME         = 24*3600 - 60 --23:59
----------------------------以上为配置项----------------------------

tbAct.nSaveGroup   = 62
tbAct.DATA_TIME    = 1
tbAct.BEGIN_TIME   = 2
tbAct.COMPLETE_NUM = 3
tbAct.TOTAL_TIME   = 4
tbAct.RIGHT_NUM    = 5
tbAct.nSaveKeyScore = 6 --积分
tbAct.nMoonCakeBoxScoreTime = 7 --打开月饼礼盒获得积分次数
tbAct.nReceiveMoonCakeCount = 8 --今日收到月饼赠送次数
tbAct.nLastReceiveTime = 9  --最后收到月饼赠送时间
tbAct.nActEndTime = 10    --结束日期

tbAct.nReceiveMoonCakeCountMax = 2  --每日收到月饼赠送次数上限

function tbAct:_CheckResetReceiveMoonCakeData(pPlayer)
    local nLastTime = pPlayer.GetUserValue(self.nSaveGroup, self.nLastReceiveTime)
    if Lib:IsDiffDay(4*3600, nLastTime, GetTime()) then
        self:_SetReceiveMoonCakeCount(pPlayer, 0)
    end
end

function tbAct:_CheckResetActData(pPlayer)
    local nActEndTime = Activity:GetActEndTime(self.szKeyName)
    if nActEndTime == pPlayer.GetUserValue(self.nSaveGroup, self.nActEndTime) then
        return
    end
    pPlayer.SetUserValue(self.nSaveGroup, self.nActEndTime, nActEndTime)
    pPlayer.SetUserValue(self.nSaveGroup, self.nSaveKeyScore, 0)
    pPlayer.SetUserValue(self.nSaveGroup, self.nMoonCakeBoxScoreTime, 0)
end

function tbAct:IsReceiveMoonCakeEnough(pPlayer)
    self:_CheckResetReceiveMoonCakeData(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.nReceiveMoonCakeCount)>=self.nReceiveMoonCakeCountMax
end

function tbAct:_SetReceiveMoonCakeCount(pPlayer, nCount)
    pPlayer.SetUserValue(self.nSaveGroup, self.nReceiveMoonCakeCount, nCount)
    pPlayer.SetUserValue(self.nSaveGroup, self.nLastReceiveTime, GetTime())
end

function tbAct:AddReceiveMoonCakeCount(pPlayer, nAdd)
    self:_CheckResetReceiveMoonCakeData(pPlayer)
    local nCount = pPlayer.GetUserValue(self.nSaveGroup, self.nReceiveMoonCakeCount)
    self:_SetReceiveMoonCakeCount(pPlayer, nCount+nAdd)
end

function tbAct:GetScore(pPlayer)
    self:_CheckResetActData(pPlayer)
	return pPlayer.GetUserValue(self.nSaveGroup, self.nSaveKeyScore) or 0
end

function tbAct:AddScore(pPlayer, nAdd, szReason)
    self:_CheckResetActData(pPlayer)
    if pPlayer.nLevel<self.nJoinLevel then
        return
    end
    szReason = szReason or "中秋节"
	local nScore = self:GetScore(pPlayer)+nAdd
	pPlayer.SetUserValue(self.nSaveGroup, self.nSaveKeyScore, nScore)
    RankBoard:UpdateRankVal(self.szMainKey, pPlayer.dwID, nScore)
    pPlayer.Msg(string.format("获得%d点中秋祭月值（%s）", nAdd, szReason))
    Log("tbAct:AddScore", pPlayer.dwID, nAdd, szReason, nScore)
	return nScore
end

function tbAct:GetMoonCakeBoxScoreTime(pPlayer)
    self:_CheckResetActData(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.nMoonCakeBoxScoreTime) or 0
end

function tbAct:AddMoonCakeBoxScoreTime(pPlayer, nAdd)
    self:_CheckResetActData(pPlayer)
    local nTime = self:GetMoonCakeBoxScoreTime(pPlayer)+nAdd
    pPlayer.SetUserValue(self.nSaveGroup, self.nMoonCakeBoxScoreTime, nTime)
end

function tbAct:GetComplete(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM)
end

function tbAct:GetRightNum(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.RIGHT_NUM)
end

function tbAct:GetTotalTime(pPlayer)
    return pPlayer.GetUserValue(self.nSaveGroup, self.TOTAL_TIME)
end