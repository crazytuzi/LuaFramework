
local tbUi = Ui:CreateClass("FamilyCampPanel");
tbUi.tbOnClick = {};

function tbUi:OnOpen()
    local tbBaseInfo = Kin:GetBaseInfo() or {};
    self.nSelectKinCamp = tbBaseInfo.nKinCamp or Npc.CampTypeDef.camp_type_neutrality;
    self.pPanel:Toggle_SetChecked("Neutral", false);
    self.pPanel:Toggle_SetChecked("Song", false);
    self.pPanel:Toggle_SetChecked("Jing", false);

    if self.nSelectKinCamp == Npc.CampTypeDef.camp_type_song then
        self.pPanel:Toggle_SetChecked("Song", true);
    elseif self.nSelectKinCamp == Npc.CampTypeDef.camp_type_jin then
        self.pPanel:Toggle_SetChecked("Jing", true);
    else
        self.pPanel:Toggle_SetChecked("Neutral", true);
    end

    local nKinCampCount = tbBaseInfo.nKinCampCount or 0;
    if tbBaseInfo.nKinCampDay ~= Lib:GetLocalDay() then
        nKinCampCount = 0;
    end
        
    self.pPanel:Label_SetText("strengthenTip", string.format("消耗%s建设资金，今日还可切换%s次", Kin.Def.ChangeCampFound[nKinCampCount + 1] or "0", #Kin.Def.ChangeCampFound - nKinCampCount));
    self:CheckButton();
end

function tbUi.tbOnClick:BtnSure()
    RemoteServer.OnKinRequest("ChangeKinCamp", self.nSelectKinCamp);
end

function tbUi.tbOnClick:BtnCancel()
    Ui:CloseWindow("FamilyCampPanel");
end

function tbUi.tbOnClick:Song()
    self.nSelectKinCamp = Npc.CampTypeDef.camp_type_song;
    self:CheckButton();
end

function tbUi:CheckButton()
    local tbBaseInfo = Kin:GetBaseInfo() or {};
    local bRet = false;
    if tbBaseInfo.nKinCamp ~= self.nSelectKinCamp then
        bRet = true;
    end
        
    self.pPanel:Button_SetEnabled("BtnSure", bRet);
end

function tbUi.tbOnClick:Jing()
    self.nSelectKinCamp = Npc.CampTypeDef.camp_type_jin;
    self:CheckButton();
end

function tbUi.tbOnClick:Neutral()
    self.nSelectKinCamp = Npc.CampTypeDef.camp_type_neutrality;
    self:CheckButton();
end