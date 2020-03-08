local tbUi = Ui:CreateClass("QingRenJieDazuoPanel")

function tbUi:RegisterEvent()
    return {
        {UiNotify.emNOTIFY_QINGRENJIE_TEXIAO, self.PlayTexiao, self},
    }
end

function tbUi:PlayTexiao()
    self.pPanel:SetActive("QiXiHuoDongHuaBan", false)
    self.pPanel:SetActive("QiXiHuoDongHuaBan", true)
end

function tbUi:OnOpenEnd()
    self.pPanel:SetActive("QiXiHuoDongHuaBan", false)
    self.pPanel:SetActive("QiXiHuoDongHuaBan", true)
end