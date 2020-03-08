local tbUi = Ui:CreateClass("MailDetailedPanel");

function tbUi:OnOpenEnd(tbMail)
	if not tbMail.ReadFlag then
		Mail:Record(tbMail.ID, not tbMail.bNotAutoDelete)
	end
	tbMail.ReadFlag = true
	self.tbMail = tbMail

	self:Update()
end

function tbUi:Update()
	local tbMail = self.tbMail
	self.pPanel:Label_SetText("TitleLabel", tbMail.Title)
	 local szArrangement = string.gsub(tbMail.Text, "\\n", "\n")

	self.TextDesc:SetLinkText(szArrangement)
	local tbTextSize = self.pPanel:Label_GetPrintSize("TextDesc");
	local tbSize = self.pPanel:Widget_GetSize("datagroup");
	self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
	self.pPanel:DragScrollViewGoTop("datagroup");
	self.pPanel:UpdateDragScrollView("datagroup");

	self.pPanel:Label_SetText("Sender", tbMail.From)
	self.pPanel:Label_SetText("Time", Lib:GetTimeStr3(tbMail.SendTime))
	local tbAttach = tbMail.tbAttach
	if not tbAttach then
		self.ItemGroup.pPanel:SetActive("Main", false)
		self.pPanel:SetActive("BtnBlackList", false)
	else
		--打开了这封邮件，如果是有附件的设置为已读

		self.ItemGroup.pPanel:SetActive("Main", true)
		self.pPanel:SetActive("BtnBlackList", true)

		local fnSetItem = function (itemObj, nIndex)
			local tbItem = tbAttach[nIndex];
			local itemframe = itemObj.itemframe
			itemframe:SetGenericItem(tbItem)
			itemframe.fnClick = itemframe.DefaultClick
		end
		self.ItemGroup:Update(tbAttach, fnSetItem)
	end
end

function tbUi:OnSynMailData(nMaildId, bSuccess)
	if bSuccess then
		local tbMails = Mail:GetMailData()
		for i,v in ipairs(tbMails) do
			if v.tbAttach then
				Ui:OpenWindow("MailDetailedPanel", v)
				return
			end
		end


	end
	if self.tbMail and self.tbMail.ID == nMaildId then
		self:Update()
	end
end

function tbUi:OnClose()
	self.tbMail = nil;
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnBlackList()
	if not self.tbMail.tbAttach then
		return
	end
	local bRet, szMsg = me.CheckNeedArrangeBag();
	if bRet then
		me.CenterMsg(szMsg)
		return
	end
	RemoteServer.TakeMailAttach(self.tbMail.ID);
end

function tbUi:RegisterEvent()
	return
	{
		{ UiNotify.emNOTIFY_SYNC_MAIL_DATA, self.OnSynMailData },
	};
end
