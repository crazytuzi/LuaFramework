Fuben.KinSecretMgr = Fuben.KinSecretMgr or {}
local KinSecretMgr = Fuben.KinSecretMgr

function KinSecretMgr:OnFubenStartFail()
    me.Msg("人数不足，家族秘境开启失败", 1)
end

function KinSecretMgr:OnFubenOver(szMsg)
    me.CenterMsg(szMsg)
    Fuben:SetFubenProgress(-1, "家族秘境已结束")
    Fuben:ShowLeave()
end

local fnOpenFubenUi = function (bShowLeave, nEndTime)
    Ui:OpenWindow("HomeScreenFuben", "KinSecretFuben")
    if bShowLeave then
        Fuben:ShowLeave()
    end
    Fuben:SetEndTime(nEndTime)
end

function KinSecretMgr:OnEntryMap(bShowLeave, nEndTime)
    fnOpenFubenUi(bShowLeave, nEndTime)
end

function KinSecretMgr:OnTrainBegin(bShowLeave, nEndTime)
    fnOpenFubenUi(bShowLeave, nEndTime)
end

function KinSecretMgr:OnMapLoaded(nMapTemplateId)
    if nMapTemplateId ~= self.Def.nMapTemplateId then
        return
    end

    UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
end

function KinSecretMgr:ManualKick(nPlayerId)
    RemoteServer.KinSecretReq("ManualKick", nPlayerId)
end

function KinSecretMgr:OpenKickPanel()
    RemoteServer.KinSecretReq("OpenKickPanel")
end

function KinSecretMgr:OnSyncFubenJoinCount(nCount)
    self.nJoinCount = nCount
    UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_JOIN_COUNT_CHANGE)
end

function KinSecretMgr:OnSyncFubenDeathCount(nCount)
    self.nDeathCount = nCount
    UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_DEATH_COUNT_CHANGE)
end

function KinSecretMgr:RefreshJoinCounts()
    RemoteServer.KinSecretReq("RefreshJoinCounts")
end

function KinSecretMgr:OnJoinCountsRefreshed(tbCounts)
    if not Ui:WindowVisible("KinSecretSelectPanel") then
        return
    end
    Ui("KinSecretSelectPanel"):SetCounts(tbCounts)
end