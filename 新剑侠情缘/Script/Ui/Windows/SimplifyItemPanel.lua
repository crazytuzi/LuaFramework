local tbUi = Ui:CreateClass("SimplifyItemPanel")
tbUi.tbOnClick = 
{
    BtnUse = function(self)
        if self.fnUse then
            self.fnUse()
        end
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnOpen(szName, szDesc, fnUse, bHideUse, szNameColor)
    self.pPanel:Label_SetText("Name", szName)
    self.pPanel:Label_SetColorByName("Name", szNameColor)
    self.pPanel:Label_SetText("Txt", szDesc)
    self.fnUse = fnUse
    self.pPanel:SetActive("BtnUse", not bHideUse)
end