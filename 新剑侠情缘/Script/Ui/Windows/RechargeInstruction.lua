local tbUi = Ui:CreateClass("RechargeInstruction")
function tbUi:OnOpen()
    self:LoadFile()
    self.pPanel:Label_SetText("TxtDesc", self.szContent)

    local tbTextSize = self.pPanel:Label_GetPrintSize("TxtDesc");
    local tbSize = self.pPanel:Widget_GetSize("datagroup");
    self.pPanel:Widget_SetSize("TxtDesc", tbTextSize.x, tbTextSize.y)
    self.pPanel:Widget_SetSize("datagroup", tbSize.x, tbTextSize.y);
    self.pPanel:DragScrollViewGoTop("datagroup");
    self.pPanel:UpdateDragScrollView("datagroup");
end

function tbUi:LoadFile()
    self.szContent = ReadTxtFile("Setting/WelfareActivity/RechargeInstruction.txt");
end
tbUi:LoadFile()

tbUi.tbOnClick = {
    ["BtnGoRecharge"] = function (self)
        Ui:CloseWindow("WelfareActivity")
        Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    end
}