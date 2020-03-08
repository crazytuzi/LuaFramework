
local tbUi = Ui:CreateClass("AgreementLinkPanel");
tbUi.szLinkTxt = "点击查看[ff5252][url=openinnerurl:<腾讯游戏用户协议>, https://game.qq.com/contract.shtml][-]和[ff5252][url=openinnerurl:<隐私保护指引>, https://game.qq.com/privacy_guide.shtml][-]"
function tbUi:OnOpenEnd()
	self:Update();
	
	local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
	if tbInfo[1] then
		self.pPanel:Button_SetText("BtnSure", "关闭")
		self.pPanel:SetActive("BtnRefuse", false)
	else
		self.pPanel:Button_SetText("BtnSure", "同意")
		self.pPanel:SetActive("BtnRefuse", true)
	end
end

function tbUi:Update()
	self.Txt2:SetLinkText(self.szLinkTxt);
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnSure = function (self)
	local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
	tbInfo[1] = true
	Client:SaveUserInfo()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnRefuse = function (self)
	local fnYes = function ()
		Sdk:DirectExit();	
	end

	me.MsgBox(string.format("您确定要拒绝用户协议和隐私保护指引吗？\n拒绝后将直接退出客户端，无法进入游戏哦。"),{
		{"取消"},
		{"确定", fnYes}
		})
	
end