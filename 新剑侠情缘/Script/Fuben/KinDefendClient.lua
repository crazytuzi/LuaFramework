Fuben.KinDefendMgr = Fuben.KinDefendMgr or {}
local KinDefendMgr = Fuben.KinDefendMgr

function KinDefendMgr:OnFubenOver(szMsg)
    me.CenterMsg(szMsg)
    Fuben:ShowLeave()
    self:Clear()
end

function KinDefendMgr:OpenFubenUi(bShowLeave, nEndTime)
    Ui:OpenWindow("HomeScreenFuben", "KinDefendFuben")
    if bShowLeave then
        Fuben:ShowLeave()
    end
    Fuben:SetEndTime(nEndTime)
    if self.bFenShenBorn then
        Ui:OpenWindow("KinDefendStatePanel")
    end
end

function KinDefendMgr:OnEntryMap(bShowLeave, nEndTime)
    self:OpenFubenUi(bShowLeave, nEndTime)
end

function KinDefendMgr:OnLeaveMap()
    Ui:CloseWindow("HomeScreenFuben")
    Ui:CloseWindow("KinDefendStatePanel")
    Ui:CloseWindow("KinDefendSkillPanel")
    Ui:CloseWindow("KinDefendApplyPanel")
end

function KinDefendMgr:OnFubenBegin(bShowLeave, nEndTime)
    self:OpenFubenUi(bShowLeave, nEndTime)
end

function KinDefendMgr:OnFenShenBorn()
    self.bFenShenBorn = true
    Ui:OpenWindow("KinDefendStatePanel")
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DATA, "KinDefendFuben")
end

function KinDefendMgr:RefreshDifficulty()
    RemoteServer.KinDefendReq("GetDifficulty")
end

function KinDefendMgr:OnDifficultyRsp(tbInfo)
    if not Ui:WindowVisible("KinDefendPanel") then
        return
    end
    Ui("KinDefendPanel"):SetDifficulty(tbInfo)
end

function KinDefendMgr:ChooseDifficulty(nDifficulty)
    RemoteServer.KinDefendReq("SetDifficulty", nDifficulty)
end

function KinDefendMgr:ConfirmApply(nTargetId)
    RemoteServer.KinDefendReq("ConfirmApply", nTargetId)
end

function KinDefendMgr:CancelConfirmApply(nTargetId)
    RemoteServer.KinDefendReq("CancelConfirmApply", nTargetId)
end

function KinDefendMgr:UpdateChoosePanel(tbPlayers)
    if not Ui:WindowVisible("KinDefendApplyPanel") then
        return
    end
    Ui("KinDefendApplyPanel"):UpdatePlayers(tbPlayers)
end

function KinDefendMgr:OpenChoosePanel()
    RemoteServer.KinDefendReq("OpenChoosePanel")
end

function KinDefendMgr:SyncState()
    RemoteServer.KinDefendReq("SyncState")
end

function KinDefendMgr:Clear()
    self.tbStateData = nil
    self.nLastGodSkill = nil
    self.nLastHealSkill = nil
    self.bFenShenBorn = nil
end

function KinDefendMgr:OnStateChange(tbData)
    self.tbStateData = tbData
    if not Ui:WindowVisible("KinDefendStatePanel") then
        return
    end
    Ui("KinDefendStatePanel"):Refresh()
end

function KinDefendMgr:OnSkillChange(nGodSub, nHealSub)
    if not Ui:WindowVisible("KinDefendSkillPanel") then
        Ui:OpenWindow("KinDefendSkillPanel", nGodSub, nHealSub)
        return
    end
    Ui("KinDefendSkillPanel"):Refresh(nGodSub, nHealSub)
end

function KinDefendMgr:UseGodSkill()
    local nNow = GetTime()
    if nNow - (self.nLastGodSkill or 0) < self.Def.nGodSkillInterval then
        return
    end
    self.nLastGodSkill = nNow

    RemoteServer.KinDefendReq("UseGodSkill")
end

function KinDefendMgr:UseHealSkill()
    local nNow = GetTime()
    if nNow - (self.nLastHealSkill or 0) < self.Def.nHealSkillInterval then
        return
    end
    self.nLastHealSkill = nNow

    RemoteServer.KinDefendReq("UseHealSkill")
end

function KinDefendMgr:OnPlayerDeath(nReviveTime)
    Ui:OpenWindow("CommonDeathPopup", "AutoRevive", "您将在 %d 秒后复活", nReviveTime)
    Ui:CloseWindow("KinDefendSkillPanel")
end

function KinDefendMgr:CanShowApplyBtn()
    return not not (self.bFenShenBorn and Fuben.KinDefendMgr:CanOperate(me))
end
