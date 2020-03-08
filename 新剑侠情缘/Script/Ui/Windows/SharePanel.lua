local tbUi = Ui:CreateClass("SharePanel");

function tbUi:OnOpen()
	if Sdk:IsLoginByGuest() then
		me.CenterMsg("暂时无法进行分享");
		return 0;
	end
end

function tbUi:OnOpenEnd(szShareTag, szOpenShareTag, szShowOffType, nExtraParam)
	self.szShareTag = szShareTag;
	self.szShowOffType = szShowOffType;
	self.nExtraParam = nExtraParam;
	self:SetButtonState(true);

	if Sdk:IsMsdk() then
		local bLoginByQQ = Sdk:IsLoginByQQ();
		self.pPanel:Label_SetText("TxtShareFriend", bLoginByQQ and "分享给QQ好友" or "分享给微信好友");
		self.pPanel:Label_SetText("TxtShareCircle", bLoginByQQ and "分享到QQ空间" or "分享到朋友圈");

		if not bLoginByQQ and szOpenShareTag == "ForbidWXMo" then
			self.pPanel:SetActive("BtnShareCircle", false);
		end
	elseif Sdk:CanShowOffShare() then
		self.pPanel:Label_SetText("TxtShareCircle", "分享到Facebook");
		if version_kor then
			self.pPanel:ChangePosition("BtnShareCircle", 0, -263, 0);
		end
	end
end

function tbUi:SetButtonState(bShow)
	self.pPanel:SetActive("BtnShareFriend", bShow and Sdk:IsMsdk());
	self.pPanel:SetActive("BtnShareCircle", bShow);
	self.pPanel:SetActive("BtnBack", bShow);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnShareFriend()
	local szType = Sdk:IsLoginByQQ() and "QQ" or "WX";
	if not Sdk:CheckShareType(szType) then
		return;
	end
	self:SetButtonState(false);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
	Sdk:TlogShare(self.szShowOffType, self.nExtraParam);
	Timer:Register(2, function ()
		Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_FRIEND_HIGH_SCORE");
	end)

	Timer:Register(5, function ()
		Ui:CloseWindow(self.UI_NAME);
	end)
end

function tbUi.tbOnClick:BtnShareCircle()
	if Sdk:IsMsdk() then
		local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo";
		if not Sdk:CheckShareType(szType) then
			return;
		end

		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Sdk:TlogShare(self.szShowOffType, self.nExtraParam);
		Timer:Register(2, function ()
			Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_MOMENT_HIGH_SCORE");
		end)
	elseif Sdk:IsEfunHKTW() then
		local szHKUrl = "http://www.jxqy.org";
		local szTWUrl = "http://www.jxqy.org";
		local szContent = "同伴募集，帮派聚义，号令江湖！";
		if Ui:WindowVisible("HonorLevelUp") == 1 then
			szContent = "二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！";
		end

		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Timer:Register(3, function ()
			Sdk:XGSharePhoto(
				"剑侠情缘手游",
				"",
				szContent,
				szContent,
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

	Timer:Register(5, function ()
		Ui:CloseWindow(self.UI_NAME);
	end)
end

function tbUi.tbOnClick:BtnBack()
	Ui:CloseWindow(self.UI_NAME);
end
