local tbUi = Ui:CreateClass("SharePanelNew");

function tbUi:OnOpen()
	if version_kor then
		return 0;
	end
end

function tbUi:OnOpenEnd(szShareType)
	self.szShareType = szShareType or "ShowOff";
	self:UpdateUserInfo();
	self:SetButtonState(true);

	if Sdk:IsMsdk() then
		local bLoginByQQ = Sdk:IsLoginByQQ();
		self.pPanel:Label_SetText("Label2", bLoginByQQ and "分享给QQ好友" or "分享给微信好友");
		self.pPanel:Label_SetText("Label1", bLoginByQQ and "分享到QQ空间" or "分享到朋友圈");
	elseif Sdk:CanShowOffShare() then
		self.pPanel:Label_SetText("Label1", "分享到Facebook");
		-- if version_kor then
		-- 	self.pPanel:ChangePosition("BtnShowOff1", 0, -283, 0);
		-- end
	end
end

function tbUi:UpdateUserInfo()
	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	self.pPanel:SetActive("Title", self.szShareType == "HonorLevelUp");
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(me.nHonorLevel)
	self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);

	local szBgDir = Faction:GetShareBgTexture(me.nFaction, me.nSex);
	self.pPanel:Texture_SetTexture("ShareBg", szBgDir);

	local nFightPower = pNpc.GetFightPower()
	self.pPanel:Label_SetText("FightingNum", nFightPower);
	self.pPanel:Label_SetText("Name", me.szName);
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%d级", me.nLevel));
	else
		self.pPanel:Label_SetText("Level", string.format("Lv.%d", me.nLevel));
	end

	local tbServerMap = Client:GetDirFileData("ServerMap" .. Sdk:GetCurPlatform());
	local szSerName = tbServerMap[SERVER_ID or 0] or "";
	self.pPanel:Label_SetText("Server", szSerName);
end

function tbUi:SetButtonState(bShow)
	self.pPanel:SetActive("BtnShowOff2", bShow and Sdk:IsMsdk() and not Sdk:IsLoginByGuest());
	self.pPanel:SetActive("BtnShowOff1", bShow and not Sdk:IsLoginByGuest() and Sdk:CanShowWXMoShare(self.szShareType));
	self.pPanel:SetActive("BtnClose", bShow);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnShowOff2()
	local szType = Sdk:IsLoginByQQ() and "QQ" or "WX";
	if not Sdk:CheckShareType(szType) then
		return;
	end

	self:SetButtonState(false);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
	Sdk:TlogShare("ShowOff");
	Timer:Register(3, function ()
		Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_FRIEND_HIGH_SCORE");
	end)

	Timer:Register(7, function ()
		Ui:CloseWindow(self.UI_NAME);
	end)
end

function tbUi.tbOnClick:BtnShowOff1()
	if Sdk:IsMsdk() then
		local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo";
		if not Sdk:CheckShareType(szType) then
			return;
		end

		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Sdk:TlogShare("ShowOff");
		Timer:Register(3, function ()
			Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_MOMENT_HIGH_SCORE", nil, nil, self.szShareType);
		end)
	elseif Sdk:IsEfunHKTW() then
		local szHKUrl = "http://www.jxqy.org";
		local szTWUrl = "http://www.jxqy.org";

		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Timer:Register(3, function ()
			Sdk:XGSharePhoto(
				"剑侠情缘手游",
				"",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				version_hk and szHKUrl or szTWUrl);
		end)
	elseif version_xm then
		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Timer:Register(3, function ()
			Sdk:XGSharePhoto(
				"剑侠情缘手游",
				"",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"http://www.jxqy.org");
		end)
	elseif version_kor then
		Sdk:XGShareInfo(
			"剑侠情缘手游",
			"https://image.kingsoftgame.com/image/jxqykr-share.jpg",
			"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
			"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
			"http://www.jxqy.org");
	end

	Timer:Register(10, function ()
		Ui:CloseWindow(self.UI_NAME);
	end)
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end
