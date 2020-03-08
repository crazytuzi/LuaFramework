local tbUi = Ui:CreateClass("HomeScreenCommunity");

function tbUi:OnOpenEnd()
	self.pPanel:SetActive("BtnQQ", Sdk:IsLoginByQQ() or version_th);
	self.pPanel:SetActive("Btnweixin", Sdk:IsLoginByWeixin());
	self.pPanel:SetActive("BtnGiftCenter", Sdk:IsLoginByQQ());
	self.pPanel:SetActive("BtnHousekeeper", false)
	self.pPanel:SetActive("BtnGaming", false);

	if Sdk:IsLoginByWeixin() then
		self.pPanel:SetActive("BtnPrivilege", not Sdk:IsOuterChannel());
		self.pPanel:Button_SetSprite("BtnPrivilege", "Weixin_01");
	elseif Sdk:IsLoginByQQ() then
		self.pPanel:SetActive("BtnPrivilege", not Sdk:IsOuterChannel());
		self.pPanel:Button_SetSprite("BtnPrivilege", "QQ_01");
	else
		self.pPanel:SetActive("BtnPrivilege", false);
	end

	if Sdk:IsMsdk() then
		if Sdk:IsOuterChannel() then
			self.pPanel:SetActive("Btnxinyue", false);
			self.pPanel:ChangePosition("BtnGaming", -119, -8);
			self.pPanel:Widget_SetSize("Bg", 330, 190);
		else
			self.pPanel:SetActive("Btnxinyue", true);
			self.pPanel:ChangePosition("BtnGaming", -198, -8);
			self.pPanel:Widget_SetSize("Bg", 409, 190);
		end
	else
		if version_kor then
			local bShowGoogle = ANDROID and (Sdk:GetChannelId() ~= "ejonestore");
			self.pPanel:SetActive("Btnxinyue", bShowGoogle and true or false);
			self.pPanel:SetActive("BtnCustomerService", ANDROID and true or false);
			self.pPanel:SetActive("BtnWebsite", ANDROID and true or false);
			self.pPanel:Widget_SetSize("Bg", bShowGoogle and 330 or 250, 100);
		elseif version_xm then
			self.pPanel:Widget_SetSize("Bg", 330, 190);
		else
			self.pPanel:Widget_SetSize("Bg", 409, 100);
		end
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnSyncQQBuluoUrl(szUrl)
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi:OnSuperVipChange()
	Sdk:OpenUrl("http://www.jxqy.org");
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnCustomerService()
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi.tbOnClick:BtnWebsite()
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi.tbOnClick:Btnweixin()
	Sdk:OpenUrl("http://www.jxqy.org");
	Ui:ClearRedPointNotify("WxCircle");
end

function tbUi.tbOnClick:BtnQQ()
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi.tbOnClick:BtnRestaurant()
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi.tbOnClick:Btnxinyue()
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi.tbOnClick:BtnPrivilege()
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi.tbOnClick:BtnGiftCenter()
	Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi.tbOnClick:BtnGaming()
	Sdk:OpenUrl("http://www.jxqy.org");
end


if version_xm then
	function tbUi.tbOnClick:BtnFB()
		Sdk:OpenUrl("http://www.jxqy.org");

	end

	function tbUi.tbOnClick:BtnCorporation()
		Sdk:OpenUrl("http://www.jxqy.org");
	end

	function tbUi.tbOnClick:BtnWebsite2()
		Sdk:OpenUrl("http://www.jxqy.org");
	end
end

function tbUi.tbOnClick:BtnHousekeeper()
	Ui:ClearRedPointNotify("SuperVip")
		Sdk:OpenUrl("http://www.jxqy.org");
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_QQ_BULUO_URL,  self.OnSyncQQBuluoUrl},
		{ UiNotify.emNOTIFY_SUPERVIP_CHANGE, self.OnSuperVipChange},
	};

	return tbRegEvent;
end

