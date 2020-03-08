

local tbGuideUI = Ui:CreateClass("RockerGuideNpcPanel");

function tbGuideUI:OnOpen(szText)
    self.pPanel:Label_SetText("Dialogue", szText or "");
    local tbSize = self.pPanel:Label_GetSize("Dialogue");
    self.pPanel:Widget_SetSize("Sprite", tbSize.x + 30, tbSize.y + 40);
end    