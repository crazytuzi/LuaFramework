local tbUi = Ui:CreateClass("CeremonyInvitationPanel");

function tbUi:OnOpen()
    self.pPanel:Texture_SetTexture("Texture", "UI/Textures/NewYearInvitationBg.jpg")
	self.pPanel:Label_SetText("Name", me.szName);
	if version_tx then
        local bLoginByQQ = Sdk:IsLoginByQQ();
        self.pPanel:Label_SetText("Txt1", bLoginByQQ and "分享给QQ好友" or "分享给微信好友");
        self.pPanel:Label_SetText("Txt2", bLoginByQQ and "分享到QQ空间" or "分享到朋友圈");
    end
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow("CeremonyInvitationPanel");
end

tbUi.tbOnClick.BtnSave = function (self)
    self:TakeScreenShot(function ()
        local szFileName = string.format("CeremonyInvitation_%d.jpg", os.time());
        Ui.ToolFunction.SaveScreenShot(szFileName);
        Ui:AddCenterMsg("已保存至相册");
    end);
end

tbUi.tbOnClick.BtnShare1 = function (self)
    self:TakeScreenShot(function ()
        Sdk:TlogShare("CeremonyInvitation");
        local szType = Sdk:IsLoginByQQ() and "QQ" or "WX";
        Sdk:SharePhoto(szType);
    end);
end

tbUi.tbOnClick.BtnShare2 = function (self)
    self:TakeScreenShot(function ()
        Sdk:TlogShare("CeremonyInvitation");

        local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo";
        Sdk:SharePhoto(szType, nil, nil, nil, "CereInvitationPanel");
    end);
end

function tbUi:TakeScreenShot(fnTake)
    self.pPanel:SetActive("Button", false);
    self.pPanel:SetActive("BtnClose",false);

    UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);

    Timer:Register(3, function ()
        fnTake();

        return false;
    end);

    Timer:Register(8, function ()
        self.pPanel:SetActive("Button", true);
        self.pPanel:SetActive("BtnClose",true);
        return false;
    end);
end

