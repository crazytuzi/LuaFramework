local tbUi = Ui:CreateClass("PrivilegePanel");

local tbTitle = {
	[Sdk.ePlatform_Weixin]  = "微信游戏中心启动用户精彩特权";
	[Sdk.ePlatform_QQ]      = "手Q游戏中心启动用户精彩特权";
	[Sdk.ePlatform_Guest]   = "游客登录精彩特权";
}

local tbContent = {
	{
		[Sdk.ePlatform_Weixin]  = "尊贵游戏中心，\n启动用户身份展示";
		[Sdk.ePlatform_QQ]      = "尊贵游戏中心，\n启动用户身份展示";
		[Sdk.ePlatform_Guest]   = "尊贵游客登录用户身份展示";
	},
	{
		[Sdk.ePlatform_Weixin]  = "游戏中心启动用\n户，独享额外签\n到奖励";
		[Sdk.ePlatform_QQ]      = "游戏中心启动用\n户，独享额外签\n到奖励";
		[Sdk.ePlatform_Guest]   = "尊贵游客登录用户，独享额外签到奖励";
	},
	{
		[Sdk.ePlatform_Weixin]  = "游戏中心启动用户，摇钱树获得银两+5%";
		[Sdk.ePlatform_QQ]      = "游戏中心启动用户，摇钱树获得银两+5%";
		[Sdk.ePlatform_Guest]   = "尊贵游客登录用户，摇钱树获得银两+5%";
	}
}

function tbUi:OnOpenEnd(nLaunchPlatform)
	self.pPanel:Sprite_SetSprite("TitleIcon", Sdk.Def.tbPlatformIcon[nLaunchPlatform]);
	self.pPanel:Sprite_SetSprite("Icon1", Sdk.Def.tbPlatformIcon[nLaunchPlatform]);
	self.pPanel:Label_SetText("TitleTxt", tbTitle[nLaunchPlatform]);
	self.pPanel:Label_SetText("Txt1", tbContent[1][nLaunchPlatform]);
	self.pPanel:Label_SetText("Txt2", tbContent[2][nLaunchPlatform]);
	self.pPanel:Label_SetText("Txt3", tbContent[3][nLaunchPlatform]);
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

