local tbUi = Ui:CreateClass("PhotographPanel");
tbUi.nBtnPosStartX = 50
tbUi.nBtnPosStartY = -9
tbUi.nBtnPosEndX = -50
tbUi.nBtnPosEndY = -9
function tbUi:OnOpen()
	local tbBtnPos = self.pPanel:GetPosition("Btn")
	local bShowHeadUi
	if tbBtnPos.x == tbUi.nBtnPosStartX and tbBtnPos.y == tbUi.nBtnPosStartY then
		Player:SetAllHeadUi()
		bShowHeadUi = true
	else
		Player:SetAllHeadUi(true)
	end
		
	self.bShowHeadUi = bShowHeadUi
	local bShowShare = version_tx and true or false
	local bForeignShowShare = (version_tx or version_xm) and true or false
	self.pPanel:SetActive("BtnPhotograph", false)
	self.pPanel:SetActive("Button", true)
	self.pPanel:SetActive("BtnShareWeixin", bShowShare)
	self.pPanel:SetActive("BtnShareQQ", bForeignShowShare and Sdk:CanShowWXMoShare("PhotographPanel"))
	self.pPanel:SetActive("QRcodebg", false)
	local szPlat, szServer = "", ""
	if version_tx then
        local bLoginByQQ = Sdk:IsLoginByQQ();
        self.pPanel:Label_SetText("Txt1", bLoginByQQ and "分享给QQ好友" or "分享给微信好友");
        self.pPanel:Label_SetText("Txt2", bLoginByQQ and "分享到QQ空间" or "分享到朋友圈");
        szPlat = IOS and "ios" or "android"
        local tbServerMap = Client:GetDirFileData("ServerMap" .. Sdk:GetCurPlatform());
		szServer = tbServerMap[SERVER_ID or 0] or "";
	elseif version_xm then
		self.pPanel:Label_SetText("Txt2", "分享到Facebook");
		local tbServerMap = Client:GetDirFileData("ServerMap" .. Sdk:GetCurPlatform());
		szServer = tbServerMap[SERVER_ID or 0] or "";
    end
    self.pPanel:Label_SetText("QRcodetxt1", me.szName)
    self.pPanel:Label_SetText("QRcodetxt2", szPlat .." " ..szServer)

    self.pPanel:SetActive("Title", me.nHonorLevel > 0);

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(me.nHonorLevel)
	self.pPanel:Sprite_Animation("Title", ImgPrefix, Atlas);
end

function tbUi:ShareStart(bLogo)
	self.pPanel:SetActive("Button", false)
	self.pPanel:SetActive("BtnClose", false)
	if bLogo then
		self.pPanel:SetActive("QRcodebg", true)
	end
end

function tbUi:ShareEnd(bLogo)
	self.pPanel:SetActive("Button", true)
	self.pPanel:SetActive("BtnClose", true)
	if bLogo then
		self.pPanel:SetActive("QRcodebg", false)
	end
end

function tbUi:RegisterEvent()
	return
	{
		{UiNotify.emNOTIFY_SHARE_PHOTO, self.ShareStart, self},
		{UiNotify.emNOTIFY_SHARE_PHOTO_END, self.ShareEnd, self},
		{ UiNotify.emNOTIFY_PLAT_SHARE_RESULT, self.OnOpen, self},
	};
end

function tbUi:OnClose()
	Player:SetAllHeadUi()
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
		Operation:EndScreenShotState()
	end;
	BtnSave = function ()
		if not Operation:IsAssistMap() then
			return
		end
		Operation:TakeScreenShot(function ()
            local szFileName = string.format("CameraOperation_%d.jpg", os.time());
            Ui.ToolFunction.SaveScreenShot(szFileName);
            Ui:AddCenterMsg("拍照成功！照片已保存至相册");
        end, true);
	end;

	BtnShareWeixin = function (self)
		if not Operation:IsAssistMap() then
			return
		end
		if version_tx then
	        Operation:TakeScreenShot(function ()
	            Sdk:TlogShare("CameraOperation");
	            local szType = Sdk:IsLoginByQQ() and "QQ" or "WX";
	            Sdk:SharePhoto(szType);
	        end, true);
	    end
    end,

    BtnShareQQ = function (self)
   		if not Operation:IsAssistMap() then
			return
		end
    	if version_tx then
	        Operation:TakeScreenShot(function ()
	            Sdk:TlogShare("CameraOperation");
	            local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo";
	            Sdk:SharePhoto(szType, nil, nil, nil, "PhotographPanel");
	        end, true);
       elseif version_xm then
       		Operation:TakeScreenShot(function ()
			Sdk:XGSharePhoto(
				"剑侠情缘手游",
				"",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"http://www.jxqy.org");
			end, true);
       end
    end,
    Btn = function (self)
    	self.bShowHeadUi = not self.bShowHeadUi
    	local bHide = not self.bShowHeadUi and true or false
    	Player:SetAllHeadUi(bHide)
    end,
}


