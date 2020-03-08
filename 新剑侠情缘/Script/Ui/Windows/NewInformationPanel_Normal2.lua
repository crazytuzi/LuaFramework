local tbNormalUi = Ui:CreateClass("NewInformationPanel_Normal2")
function tbNormalUi:OnOpen(tbData)
    local tbDef = WuLinDaHui.tbDef;
    self.pPanel:Label_SetText("Content1", tbDef.szNewsContent1)
    local tbTextSize1 = self.pPanel:Label_GetPrintSize("Content1")
    local tbTimeTabSize = self.pPanel:Widget_GetSize("Form");
    self.pPanel:Label_SetText("Content2", tbDef.szNewsContent2)
    local tbTextSize2 = self.pPanel:Label_GetPrintSize("Content2")

    for i=1,6 do
        local szTxt = tbDef["szNewsContentTime" .. i]
        self.pPanel:Label_SetText("Time" .. i, szTxt)
    end
    
    local tbSize = self.pPanel:Widget_GetSize("datagroup");
    self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize1.y + tbTimeTabSize.y + tbTextSize2.y);
    self.pPanel:DragScrollViewGoTop("datagroup");
    self.pPanel:UpdateDragScrollView("datagroup");
end
