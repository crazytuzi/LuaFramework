local tbUi = Ui:CreateClass("BossReferral")

function tbUi:OnOpen(szName1, szName2, szContent, bHideBg)
    if not szName1 or not szName2 or not szContent then
        return 0
    end

    if bHideBg then
        self.pPanel:SetActive("Bg1", false);
        self.pPanel:SetActive("Bg2", false);
    end
end

function tbUi:OnOpenEnd(szName1, szName2, szContent)
    self.pPanel:Label_SetText("Name1", szName1 or "")
    self.pPanel:Label_SetText("Name2", szName2 or "")
    self.pPanel:Label_SetText("Describe", szContent or "")

    self.pPanel:Tween_Play("Bg1")
    self.pPanel:Tween_Play("Bg2")
end

function tbUi:OnClose()
    self.pPanel:SetActive("Bg1", true);
    self.pPanel:SetActive("Bg2", true);
    self.pPanel:Tween_Reset("Bg1")
    self.pPanel:Tween_Reset("Bg2")
end