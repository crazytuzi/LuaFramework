local tbUi = Ui:CreateClass("WeekendQuizPanel");

local tbActUi = Activity:GetUiSetting("WeekendQuestion")

local nClueCount = 3
function tbUi:OnOpen()
	tbActUi:SynData()
	if not tbActUi:GetData() then
		return
	end
end

function tbUi:OnOpenEnd()
	self:UpdateUi()
end

function tbUi:UpdateUi()
	self.tbLinkData = nil
	local tbData = tbActUi:GetData() or {}
	local szTip = tbData.szTips or "无"
	local tbLinkData = tbData.tbLinkData or {}
	local nScore = tbData.nScore and tbData.nScore + 1 or -99
	local tbTip = tbData.tbTip or {}

	local nCount = Activity.WeekendQuestion:GetComplete(me)
	self.pPanel:Label_SetText("Progress", string.format("%d/%d",nCount,Activity.WeekendQuestion.MAX_COUNT));

	for i=1,nClueCount do
		self.pPanel:SetActive("Light" ..i,false)
	end

	local szHitText = tbTip[nScore]
	local nHitIndex = nClueCount - nScore + 1



	for i=1,nClueCount do
		self.pPanel:SetActive("Clue" ..i, true);
		self.pPanel:SetActive("Mask" ..i, false);
		if i == nHitIndex and szHitText then
			if nScore == 3 then 
				local tbMapSetting = Map:GetMapSetting(tbLinkData.nMapId);
				if tbMapSetting then
					local szNpcName = tbLinkData.szNpcName or ""
					self.pPanel:Label_SetText("Clue" ..i, string.format("<%s、%s(%d、%d)>",szNpcName,tbMapSetting.MapName,tbLinkData.nX*Map.nShowPosScale,tbLinkData.nY*Map.nShowPosScale));
					self.tbLinkData = tbLinkData
				end
			else
				self.pPanel:Label_SetText("Clue" ..i, szHitText);
			end
		else
			if nScore == 3 then
				local szClue = tbTip[nClueCount - i + 1] or "未解锁线索"
				self.pPanel:Label_SetText("Clue" ..i, szClue);
			else
				self.pPanel:SetActive("Clue" ..i, false);
				self.pPanel:SetActive("Mask" ..i, true);
			end
		end
		
		self.pPanel:SetActive("Light" ..i,i == nHitIndex)
	end

end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	AllRightItem1 = function(self)
		if self.tbLinkData and self.tbLinkData.nMapId and self.tbLinkData.nX and self.tbLinkData.nY then
			Ui.HyperTextHandle:Handle(string.format("[url=pos:text, %d, %d, %d]",self.tbLinkData.nMapId,self.tbLinkData.nX,self.tbLinkData.nY), 0, 0);
		end
	end
}

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_WEEKEND_QUIZ_SYN,           self.UpdateUi},
    };

    return tbRegEvent;
end
