
local tbUi = Ui:CreateClass("MessageBox");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_REFRESH_MESSAGE_BOX, self.OnRefreshContent, self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnOk = function (self, tbGameObj)
		local bRemainOpen, _;
		if self.tbOKCallback then
			_, bRemainOpen = Lib:CallBack(self.tbOKCallback)
		end
		if not bRemainOpen then
			Ui:CloseWindow(self.UI_NAME);
		end

		if self.szNotTipsType then
			local bChecked = self.pPanel:Toggle_GetChecked("CheckTips")
			Ui:SetNotShowTips(self.szNotTipsType, bChecked);
		end
	end,
	BtnClose = function (self, tbGameObj)
		local nRet;
		if self.tbCancelCallback then
			nRet = Lib:CallBack(self.tbCancelCallback)
		end
		if nRet ~= 0 then
			Ui:CloseWindow(self.UI_NAME);
		end

		if self.szNotTipsType then
			local bChecked = self.pPanel:Toggle_GetChecked("CheckTips")
			Ui:SetNotShowTips(self.szNotTipsType, bChecked);
		end
	end,

	BtnX = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end
}

tbUi.tbOnClick.BtnCenter = tbUi.tbOnClick.BtnOk

function tbUi:OnOpen(szText, tbProc, tbBtnTxt, szNotTipsType, nTime, bInfoLayer, tbLight, bShowSingleClose)
	local szInfo = string.format(szText, nTime or 0);

	if string.find(szInfo, "#%d+") then
		self.pPanel:ChangePivot("TextInfo", 0)
	else
		self.pPanel:ChangePivot("TextInfo", 4)
	end

	self.TextInfo:SetLinkText(szInfo);

	if nTime and nTime > 0 then
		self.nEndTime = GetTime() + nTime;
		self.nTimerId = Timer:Register(Env.GAME_FPS, function ()
			if self.nEndTime - GetTime() < 0 then
				self.nTimerId = nil;
				if self.tbTimerEndCallback then
					Lib:CallBack(self.tbTimerEndCallback);
				end
				return;
			end

			local nCurTime = math.max(self.nEndTime - GetTime(), 0);
			self.TextInfo:SetLinkText(string.format(szText, nCurTime));
			return true;
		end);
	end

	if tbProc then
		self.tbOKCallback = tbProc[1];
		self.tbCancelCallback = tbProc[2];
		self.tbTimerEndCallback = tbProc[3];
	else
		self.tbOKCallback = nil;
		self.tbCancelCallback = nil;
		self.tbTimerEndCallback = nil;
	end

	tbLight = tbLight or {};
	tbBtnTxt = tbBtnTxt or {"确定", "取消"};

	self.szNotTipsType = szNotTipsType;
	local _, bChoosed = Ui:CheckNotShowTips(self.szNotTipsType)
	local bNever = Ui:IsTipsNeverShow(szNotTipsType)
	self.pPanel:Toggle_SetChecked("CheckTips", (not bNever and bChoosed) or false);
	self.pPanel:SetActive("CheckTips", self.szNotTipsType and true or false);

	self.pPanel:Label_SetText("RepeatTips", bNever and "以后不再提醒" or "今日不再提醒")

	self.pPanel:Label_SetText("TextCenter", tbBtnTxt[1] or "确定");
	self.pPanel:Label_SetText("TextOk", tbBtnTxt[1] or "确定");
	self.pPanel:Label_SetText("TextClose", tbBtnTxt[2] or "取消");

	local isSingle = tbProc and (tbProc[2] == nil) or false;
	self.pPanel:SetActive("BtnCenter", isSingle)
	if isSingle then
		self.pPanel:Sprite_SetSprite("BtnCenter", tbLight[1] and "BtnMain_03" or "BtnMain_01");
	end

	self.pPanel:SetActive("BtnOk", not isSingle);
	self.pPanel:SetActive("BtnClose", not isSingle);
	if not isSingle then
		self.pPanel:Sprite_SetSprite("BtnOk", tbLight[1] and "BtnMain_03" or "BtnMain_01");
		self.pPanel:Sprite_SetSprite("BtnClose", tbLight[2] and "BtnMain_03" or "BtnMain_01");
	end

	self.pPanel:SetActive("BtnX", bShowSingleClose or false)
end

function tbUi:OnOpenEnd(szText, tbProc, tbBtnTxt, szNotTipsType, nTime, bInfoLayer)
	if bInfoLayer then
		Ui.UiManager.ChangeUiLayer(self.UI_NAME, Ui.LAYER_INFO);
	else
		Ui.UiManager.ChangeUiLayer(self.UI_NAME, Ui.LAYER_POPUP);
	end
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
end

function tbUi:OnRefreshContent(szText)
	self.TextInfo:SetLinkText(szText)
end
