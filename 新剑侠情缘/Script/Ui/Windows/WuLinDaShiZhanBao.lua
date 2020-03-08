local tbUi = Ui:CreateClass("WuLinDaShiZhanBao")
tbUi.tbContent = {
    "金军正猛攻襄阳南北两城门，形势岌岌可危，请少侠速速支援前线！",
    "城门已被攻克，如若龙柱被破，襄阳旋即失守，大宋危矣！",
}

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_WULINDASHI_SECTION, self.ShowField, self},
    };

    return tbRegEvent;
end

function tbUi:OnOpenEnd()
    self.pPanel:SetActive("BattlefieldTxt", false)
end

function tbUi:ShowField(nSection)
    if self.bShow then
        self.pPanel:SetActive("BattlefieldTxt", false)
        self.bShow = false
        return
    end
    nSection = nSection or WuLinDaShi:GetSectionInfo()
    if not nSection then
        return
    end
    self.pPanel:SetActive("BattlefieldTxt", true)
    self.pPanel:Label_SetText("BattlefieldTxt", self.tbContent[nSection] or "")
    self.bShow = true
end

tbUi.tbOnClick = {
    BtnBattlefield = function (self)
        self:ShowField()
    end
}