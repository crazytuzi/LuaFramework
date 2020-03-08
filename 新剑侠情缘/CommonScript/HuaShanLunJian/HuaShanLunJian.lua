Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef             = HuaShanLunJian.tbDef;
local tbFinalsDef       = tbDef.tbFinalsGame;
local tbGuessingDef     = tbDef.tbChampionGuessing;
local tbPreDef          = tbDef.tbPrepareGame;

function HuaShanLunJian:IsPrepareGamePeriod()
    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay < tbDef.tbPrepareGame.nStartMonthDay or nMonthDay > tbDef.tbPrepareGame.nEndMothDay then
        return false;
    end

    return true;
end


function HuaShanLunJian:IsFinalsPlayGamePeriod()
    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay ~= tbFinalsDef.nMonthDay then
        return false;
    end

    return true;
end


function HuaShanLunJian:GetGuessingVipLimit(nVip)
    return tbGuessingDef.nMaxOneNote;
end

function HuaShanLunJian:GetPreGameJoinCount(nStartWeekDay)
    local nMaxCount = (Lib:GetLocalWeek() - nStartWeekDay + 1) * tbPreDef.nPerWeekJoinCount;
    nMaxCount = math.max(tbPreDef.nPerWeekJoinCount, nMaxCount);
    nMaxCount = math.min(tbPreDef.nMaxPlayerJoinCount, nMaxCount);
    nMaxCount = math.floor(nMaxCount);
    return nMaxCount;
end