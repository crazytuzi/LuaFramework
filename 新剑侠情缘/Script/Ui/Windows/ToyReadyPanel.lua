local tbUi = Ui:CreateClass("ToyReadyPanel")
tbUi.tbOnClick =
{
    Btn = function(self)
        if not self.szClass then
            return
        end
        if not self.bReady then
            Toy:Ready(self.szClass)
        else
            Toy:CancelReady(self.szClass)
        end
    end,
}

function tbUi:OnOpen(szClass)
    self.szClass = szClass
    self:OnReadyChange(false)
end

function tbUi:OnReadyChange(bReady)
    self.bReady = bReady
    self.pPanel:Label_SetText("Label", bReady and "移动" or "接龙")
end