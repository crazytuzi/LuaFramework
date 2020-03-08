local tbUi = Ui:CreateClass("KinMailPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.Update, self},
		{ UiNotify.emNOTIFY_WND_CLOSED, self.OnCloseEmotionLink, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	local nSendMailFee = Kin:GetSendMailFee();
	if nSendMailFee > Kin:GetFound() then
		me.CenterMsg("建设资金不足，无法发送家族邮件");
		return 0;
	end

	self.pPanel:SetActive("Toggle", version_tx and true or false)

	self.pPanel:Toggle_SetChecked("Toggle", false)
	self.pPanel:UIInput_SetCharLimit("InputField", Kin.Def.nMaxMailLength);
	
	Kin:UpdateMailInfo();
	self:Update("MailCount");
end

function tbUi:Update(szType)
	if szType ~= "MailCount" then
		return;
	end

	local nMailLeftCount = Kin:GetLeftMailCount() or 0;
	self.pPanel:Label_SetText("TxtMailLeftCount", string.format("%d/%d", nMailLeftCount, Kin.Def.nMaxMailCount));
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnCloseEmotionLink(szWndName)
	if szWndName == "ChatEmotionLink" then
		self.pPanel:ChangePosition("Main", 0, 0);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
	Ui:CloseWindow("ChatEmotionLink");
end

function tbUi.tbOnClick:BtnEmotionLink()
	if Ui:WindowVisible("ChatEmotionLink") == 1 then
		Ui:CloseWindow("ChatEmotionLink");
	else
		self.pPanel:ChangePosition("Main", 0, 70);
		Ui:OpenWindow("ChatEmotionLink", self, "Emotion", true);
	end
end

function tbUi.tbOnClick:BtnSend()
	local szMsg = self.pPanel:Input_GetText("InputField") or "";

	if not Kin:CheckMyAuthority(Kin.Def.Authority_Mail) then
		me.CenterMsg("你没有权限发送家族邮件");
		return false;
	end

	local nMailCount = Kin:GetLeftMailCount();
	if nMailCount <= 0 then
		me.CenterMsg("今日家族邮件次数已用尽");
		return false;
	end

	if not szMsg or szMsg == "" then
		me.CenterMsg("请输入邮件内容");
		return false;
	end

	local nSendMailFee = Kin:GetSendMailFee();
	if nSendMailFee > Kin:GetFound() then
		me.CenterMsg("建设资金不足，无法发送家族邮件");
		return;
	end

	if Lib:Utf8Len(szMsg) > Kin.Def.nMaxMailLength then
		me.CenterMsg("输入内容超出字数上限");
		return;
	end

	
	local fnSend = function ()
		local bSendPhoneNotify = self.pPanel:Toggle_GetChecked("Toggle")
		if Kin:SendKinMail(szMsg, bSendPhoneNotify) then
			self.pPanel:Input_SetText("InputField", "");
			me.CenterMsg("发送家族邮件成功");
			self.tbOnClick.BtnClose(self);
		end
	end

	me.MsgBox(string.format("确定消耗[FFFE0D]%d建设资金[-]发送家族邮件吗？", nSendMailFee), {{"确定", fnSend}, {"取消"}});
end

function tbUi.tbOnClick:Toggle()
	local bChecked = self.pPanel:Toggle_GetChecked("Toggle")
	if bChecked then
		Dialog:SendBlackBoardMsg(me, "提示：离线的成员通过手机接收本次邮件内容")
	end
end