local tbUi = Ui:CreateClass("CeremonyPanel");

function tbUi:OnOpen()
    
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow("CeremonyPanel");
end

tbUi.tbOnClick.Btn1 = function (self)
    Ui:OpenWindow("CeremonyInvitationPanel");
end

tbUi.tbOnClick.Btn2 = function (self)
    Sdk:OpenTXLiveUrl();
end
