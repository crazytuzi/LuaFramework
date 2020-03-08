function Calendar:OnDivisionChange(szAct, nNotifyLevel)
    if (not Fuben.tbSafeMap[me.nMapTemplateId] and Map:GetClassDesc(me.nMapTemplateId) ~= "fight") or
        (Map:GetClassDesc(me.nMapTemplateId) == "fight" and me.nFightMode ~= 0) then
        Calendar.tbShowDivisionChange = {szAct, nNotifyLevel}
        return
    end

    Ui:OpenWindow("AthleticsHonorAni", szAct, nNotifyLevel)
end

function Calendar:OnMapLoaded(nMapTemplateId)
    if not self.tbShowDivisionChange then
        return
    end

    self:OnDivisionChange(unpack(self.tbShowDivisionChange))
    self.tbShowDivisionChange = nil
end

--nTickType: 1:月度 2:季度 3:年度
Calendar.tbTicketFunc = {
    Battle = function (nTickType, bNotNext)
        local tbType = {"BattleMonth", "BattleSeason"}
        local szType = tbType[nTickType] 
        if not szType then
            return
        end
        return Battle:IsQualifyBattleByType(me, szType, bNotNext)
    end,

    TeamBattle = function (nType, nTime)
        local tbType = TeamBattle:GetSeqType();
        return TeamBattle:CheckTicket(me, tbType[nType], nTime);
    end,

    InDifferBattle = function (nType)
        local tbType = { "Month", "Season" };
        local szType = tbType[nType] 
        if not szType then
            return
        end
        return InDifferBattle:IsQualifyInBattleType(me, szType) --检查资格一般是默认是当前是否有
    end,

    FactionBattle = function (nType)
        if nType == 1 then
            return FactionBattle:IsCanJoinMonthBattle()
        elseif nType == 2 then
            return FactionBattle:IsCanJoinSeasonBattle()
        end
    end,
    HuaShanLunJian = function (nType)
        if nType ~= 3 then
            return false
        end
        return WuLinDaHui:IsHasTicket()
    end,

}
function Calendar:CheckPlayerTicket(szAct, nTickType, ...)
    local fn = self.tbTicketFunc[szAct]
    if fn then
        return fn(nTickType, ...)
    end
    return false
end

Calendar.tbGetNextTimeFn = {
    Battle = function (nType, bNotNext)
        local nOpenTime
        if nType == 1 then
            nOpenTime = Battle:GetQualifyMatchTimeMonth(not bNotNext)
        elseif nType == 2 then
            nOpenTime = Battle:GetQualifyMatchTimeSeason(not bNotNext)
        end
        if nOpenTime then
            return nOpenTime, Lib:TimeDesc11(nOpenTime)
        end
    end,

    TeamBattle = function (nType, nTime)
        local tbType = TeamBattle:GetSeqType();
        local nOpenTime = TeamBattle:GetNextOpenTime(tbType[nType], nTime);
        if nOpenTime then
            return nOpenTime, Lib:GetTimeStr4(nOpenTime);
        end
    end,

    InDifferBattle = function (nType, bNotNext)
        local tbType = { "Month", "Season" };
        local nNow = GetTime()
        if bNotNext then
            nNow = nNow - 3600
        end
        local nTime = InDifferBattle:GetNextOpenTime(tbType[nType], nNow)
        if nTime then
            return nTime, Lib:GetTimeStr3(nTime)
        end
    end,

    FactionBattle = function (nType)
        local nTime
        if nType == 1 then
            nTime = FactionBattle:GetNextMonthlyBattleTime()
        elseif nType == 2 then
            nTime = FactionBattle:GetNextSeasonBattleTime()
        end
        if nTime then
            return nTime, Lib:GetTimeStr3(nTime)
        end
    end,
    
    HuaShanLunJian = function ( )
        return true;
    end;

}
--nType:1.月度 2.季度 3.年度
function Calendar:GetNextOpenTime(szAct, nType, ...)
    local fn = self.tbGetNextTimeFn[szAct]
    if fn then
        return fn(nType, ...)
    end
end

Calendar.tbTicketOpenTF = {
    Battle = {Battle.tbAllBattleSetting.BattleMonth.OpenTimeFrame,
              Battle.tbAllBattleSetting.BattleSeason.OpenTimeFrame,
              },
    TeamBattle = {TeamBattle.szLeagueOpenTimeFrame,
                TeamBattle.szLeagueOpenTimeFrame,
                TeamBattle.szLeagueOpenTimeFrame},
    InDifferBattle = {
        InDifferBattle.tbBattleTypeSetting.Month.szOpenTimeFrame,
        InDifferBattle.tbBattleTypeSetting.Season.szOpenTimeFrame,
    },
    FactionBattle = {FactionBattle.CROSS_MONTHLY_FRAME,
                FactionBattle.CROSS_MONTHLY_FRAME,
                FactionBattle.CROSS_MONTHLY_FRAME},
    HuaShanLunJian = { nil, nil, HuaShanLunJian.tbDef.szOpenTimeFrame },                
}
function Calendar:GetTicketOpenTimeFrame(szAct, nType)
    return self.tbTicketOpenTF[szAct] and self.tbTicketOpenTF[szAct][nType] or "NerverOpenTF"
end

Calendar.tbCheckMarkTypeFn = {
    Battle = function (nType, bJustCheckDay)
        local bCanJoin = Calendar:CheckPlayerTicket("Battle", nType)
        if not bCanJoin then
            return
        end
        local nTime = Calendar:GetNextOpenTime("Battle", nType)
        if not nTime or Lib:GetLocalDay() ~= Lib:GetLocalDay(nTime) then
            return
        end
        return bJustCheckDay or math.abs(Lib:GetTodaySec(nTime) - Lib:GetTodaySec()) < 3600*2
    end,

    TeamBattle = function (nType)
        local nCheckTime = GetTime() - 3600 --开始了通天塔时获取到的信息为下一场的信息，故此处往前一点时间
        local bCanJoin = Calendar:CheckPlayerTicket("TeamBattle", nType, nCheckTime)
        if not bCanJoin then
            return
        end

        local nTime = Calendar:GetNextOpenTime("TeamBattle", nType, nCheckTime)
        if not nTime then
            return
        end
        return Lib:GetLocalDay() == Lib:GetLocalDay(nTime)
    end,
    InDifferBattle = function (nType, bJustCheckDay)
        local bCanJoin = Calendar:CheckPlayerTicket("InDifferBattle", nType)
        if not bCanJoin then
            return
        end
        local nTime = Calendar:GetNextOpenTime("InDifferBattle", nType, true)
        if not nTime or Lib:GetLocalDay() ~= Lib:GetLocalDay(nTime) then
            return
        end
        return bJustCheckDay or math.abs(Lib:GetTodaySec(nTime) - Lib:GetTodaySec()) < 3600*2
    end;
    FactionBattle = function (nType)
        local bCanJoin = Calendar:CheckPlayerTicket("FactionBattle", nType)
        if not bCanJoin then
            return
        end
        if nType == 1 then
            return FactionBattle:IsMonthBattleOpen();
        elseif nType == 2 then
            return FactionBattle:IsSeasonBattleOpen();
        end
    end;
}

--bJustCheckDay 只检查是否当天
function Calendar:GetMarkTypeOfPlayer(szAct, bJustCheckDay)
    if not self.tbHonorInfo[szAct] then
        return
    end
    for nType = 1, 3 do
        local szTF = self:GetTicketOpenTimeFrame(szAct, nType)
        if GetTimeFrameState(szTF) == 1 then
            local fn = self.tbCheckMarkTypeFn[szAct]
            if fn and fn(nType, bJustCheckDay) then
                return nType
            end
        end
    end
end

function Calendar:GetActOpenInfo(szAct)
    local nId = self:GetActivityId(szAct)
    if not nId then
        return
    end
    local tbSettting = self.tbCalendarSetting[nId]
    return tbSettting.szTimeFrameOpen, tbSettting.nLevelMin
end