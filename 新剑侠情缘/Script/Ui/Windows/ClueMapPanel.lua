local tbUi = Ui:CreateClass("ClueMapPanel");
local ValueCompose = Compose.ValueCompose
tbUi.nMaxClue = 9
function tbUi:OnOpen(nSeqId, nCluePos)
	local tbSeqInfo = ValueCompose:GetSeqInfo(nSeqId)
	if not tbSeqInfo then
		return
	end
	self.nSeqId = nSeqId
	self.nCluePos = nCluePos
	self.tbSeqInfo = tbSeqInfo
	self:InitMap(tbSeqInfo)
	self:Update()
end

function tbUi:InitMap(tbSeqInfo)
	for i = 1, self.nMaxClue do
		local szTexture = tbSeqInfo["ItemTexture" ..i] or ""
		if not Lib:IsEmptyStr(szTexture) then
			self.pPanel:Texture_SetTexture("ScrollFragment" ..i, szTexture)
			self.pPanel:Texture_SetTexture("ScrollFragmentTips" ..i, szTexture)
		end
	end
	self.pPanel:Label_SetText("Title", tbSeqInfo.szDirTitle)
end

function tbUi:Update()
	local tbTipPos = ValueCompose.tbTipPos[self.nSeqId] or {}
	local nAllPos = Compose.ValueCompose:GetHaveValueNum(me, self.nSeqId);
	local nTipPos = tbTipPos[nAllPos] or -1
	for nCluePos = 1, self.nMaxClue do
		local bHadClue = ValueCompose:CheckIsHaveValue(me, self.nSeqId, nCluePos)
		self.pPanel:SetActive("ScrollFragment" ..nCluePos, bHadClue)
		self.pPanel:SetActive("ScrollFragmentTips" ..nCluePos, false)
		if nCluePos == nTipPos then
			self.pPanel:SetActive("ScrollFragmentTips" .. nCluePos, true)
			self.pPanel:Label_SetText(string.format("Tips%dTxt", nTipPos), self.tbSeqInfo["szItemDes" ..nTipPos] or "")
		end
	end
	local bIsFinish = ValueCompose:CheckIsFinish(me, self.nSeqId, true)
	self.pPanel:SetActive("BtnCompose", bIsFinish)
	if self.nCluePos then
		self.pPanel:Tween_Play("ScrollFragment" ..self.nCluePos);
	end
	self.pPanel:SetActive("Effect", false)
end

function tbUi:OnValueComposeFinish()
	self.pPanel:SetActive("Effect", true)
	self:CloseEffectTimer()
	self.nEffectTimer = Timer:Register(Env.GAME_FPS * 2, function () Ui:CloseWindow(self.UI_NAME) end )

end

function tbUi:OnClose()
	self:CloseEffectTimer()
end

function tbUi:CloseEffectTimer()
	if self.nEffectTimer then
		Timer:Close(self.nEffectTimer)
		self.nEffectTimer = nil
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_VALUE_COMPOSE_FINISH, self.OnValueComposeFinish, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnCompose = function (self)
		if not self.nSeqId then
			me.CenterMsg("请选择需要合成的物品");
			return;
		end
		ValueCompose:TryComposeValue(self.nSeqId);
	end,
	ScrollFragmentBg = function (self)
		local nAllPos = Compose.ValueCompose:GetHaveValueNum(me, self.nSeqId);
		local szTip = self.tbSeqInfo["szItemTip" ..nAllPos]
		if not szTip then
			return
		end
		me.SendBlackBoardMsg(szTip)
	end;
}