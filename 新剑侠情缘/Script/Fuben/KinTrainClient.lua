--家族试炼
Fuben.KinTrainMgr = Fuben.KinTrainMgr or {}
local KinTrainMgr = Fuben.KinTrainMgr
KinTrainMgr.MAPTEMPLATEID   = 1048--地图ID

function KinTrainMgr:OnFubenStartFail()
    me.CenterMsg("人数不足，家族试炼开启失败")
end

function KinTrainMgr:OnFubenOver(szMsg)
    me.CenterMsg(szMsg)
    Fuben:SetFubenProgress(-1, "家族试炼已结束")
    Fuben:ShowLeave()
end

function KinTrainMgr:ShowMeterialInfo(...)
    if Ui:WindowVisible("KinTrainMatPanel") then
        UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_TRAIN_MAT, {...})
    else
        Ui:OpenWindow("KinTrainMatPanel", {...})
    end
end

local fnOpenFubenUi = function (bShowLeave, nEndTime)
    Ui:OpenWindow("HomeScreenFuben", "KinTrain")
    if bShowLeave then
        Fuben:ShowLeave()
    end
    
    Fuben:SetEndTime(nEndTime)
end
function KinTrainMgr:OnEntryMap(bShowLeave, nEndTime)
    fnOpenFubenUi(bShowLeave, nEndTime)
end

function KinTrainMgr:OnTrainBegin(bShowLeave, nEndTime)
    fnOpenFubenUi(bShowLeave, nEndTime)
end

function KinTrainMgr:OnMapLoaded(nMapTemplateId)
    if nMapTemplateId ~= self.MAPTEMPLATEID then
        return
    end

    UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
end

function KinTrainMgr:OnCreateMatBoss(nBossTID, nBossId)
    self.nMaterialBoss = nBossId
    local pNpc = KNpc.GetById(self.nMaterialBoss)
    if pNpc then
        pNpc.SetHideNpc(1)
    end
    Ui:OpenWindow("TaskStoryBlackPanel", nil, "受伤的宋兵来报：\n完颜洪烈亲率精兵偷袭襄阳城，请诸位大侠速回襄阳城，助朝廷击退金贼！", function ()
        Fuben.KinTrainMgr:OnBossAniEnd()
    end)
    local nX, nY = unpack(self.DefendFubenDef.tbBossPos)
    local pTmp = KNpc.Add(nBossTID, 1, 0, me.nMapId, nX, nY, 0, 17)
    pTmp.SetAiActive(0)
    local pLZTmp = KNpc.Add(2762, 1, 0, me.nMapId, 15536, 8278)
    self.tbTmpNpc = {}
    table.insert(self.tbTmpNpc, pTmp.nId)
    table.insert(self.tbTmpNpc, pLZTmp.nId)
    Timer:Register(Env.GAME_FPS, function ()
        for _, nNpcId in ipairs(self.tbTmpNpc) do
            local pTmpNpc = KNpc.GetById(nNpcId)
            if pTmpNpc then
                pTmpNpc.SetActiveForever(1)
            end
        end
        local _, x, y = me.GetWorldPos()
        self.tbMyTmpPos = {x, y}
        me.SetPosition(nX, nY)
        Ui.CameraMgr.MoveCameraToPosition(1, nX, nY, 0)

    end)
    Timer:Register(Env.GAME_FPS*2, function ()
        me.SetPosition(unpack(self.tbMyTmpPos))
    end)
end

function KinTrainMgr:OnBossAniEnd()
    Timer:Register(Env.GAME_FPS*3, function ()
        local pNpc = KNpc.GetById(self.nMaterialBoss)
        if pNpc then
            pNpc.SetHideNpc(0)
        end
        for _, nId in ipairs(self.tbTmpNpc or {}) do
            local pTmpNpc = KNpc.GetById(nId)
            if pTmpNpc then
                pTmpNpc.Delete()
            end
        end
        self.nMaterialBoss = nil
        self.tbTmpNpc = {}
        Ui.CameraMgr.LeaveCameraAnimationState()
    end)
end