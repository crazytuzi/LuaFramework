local tbUi = Ui:CreateClass("KinTrainMatPanel")
function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_MAP_LEAVE, self.OnMapChange, self },
        { UiNotify.emNOTIFY_SYNC_KIN_TRAIN_MAT, self.Update, self },
    }
end

function tbUi:OnOpen(tbMatInfo)
    if not tbMatInfo or (me.nMapTemplateId ~= Fuben.KinTrainMgr.MAPTEMPLATEID and me.nMapTemplateId ~= Fuben.KinTrainMgr.MAP_TID_DEFEND) then
        return 0
    end
end

function tbUi:OnOpenEnd(tbMatInfo)
    self:Update(tbMatInfo)
    local szMatName = Lib:CountTB(tbMatInfo) == 4 and "军资" or "物资"
    self.pPanel:Label_SetText("Title", string.format("%s收集", szMatName))
    self.pPanel:Label_SetText("Tip", string.format("击败金军后勤，可获得对应%s，每种%s尽量收集到完美状态", szMatName, szMatName))
end

function tbUi:OnClose()
    RemoteServer.CancelMatUpdate()
end

local fnGetPercent = function(nPercent)
    local szContent = "严重超量"
    local szColor = "[5dddff]"
    if nPercent < 0.6 then
        szContent = "严重不足"
        szColor = "[ff4545]"
    elseif nPercent < 0.8 then
        szContent = "不足"
        szColor = "[f0a51e]"
    elseif nPercent < 1 then
        szContent = "稍稍不足"
        szColor = "[fbff05]"
    elseif nPercent == 1 then
        szContent = "完美"
        szColor = "[4eff16]"
    elseif nPercent <= 1.1 then
        szContent = "稍稍超量"
    elseif nPercent <= 1.3 then
        szContent = "超量"
    end
    return szColor .. szContent
end
function tbUi:Update(tbMatInfo)
    for i = 1, 5 do
        local nColNum   = tbMatInfo[i]
        self.pPanel:SetActive("Mat" .. i, nColNum)
        if nColNum then
            local nPerfect  = Fuben.KinTrainMgr.FubenDef.tbMaterialInfo[i]
            local nPercent  = nColNum/nPerfect
            local szPercent = fnGetPercent(nPercent)
            self.pPanel:Label_SetText("state" .. i, szPercent)

            nPercent = math.min(1, nPercent/1.3)
            self.pPanel:ProgressBar_SetValue("Slider" .. i, nPercent)
        end
    end
end

function tbUi:OnMapChange(nMapTemplateId)
    if nMapTemplateId ~= MAPTEMPLATEID then
        Ui:CloseWindow(self.UI_NAME)
    end
end

tbUi.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnComplete = function (self)
        RemoteServer.KinTrainTryDepart()
        Ui:CloseWindow(self.UI_NAME)
    end
}