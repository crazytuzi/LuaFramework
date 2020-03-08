local tbUi = Ui:CreateClass("MarriageRequestPanel");
function tbUi:OnOpen(nProposeId, nBeProposeId, szOtherName, nProposeIndex)
	self.nProposeId = nProposeId 											-- 被求婚者才有值
	self.nBeProposeId = nBeProposeId		 								-- 求婚者才有值	
	self.szOtherName = szOtherName 											-- 对方名字
	self.nCountDown = Wedding.nProposeDecideTime
	self.pPanel:SetActive("BtnAccept", self.nProposeId)
	self.pPanel:SetActive("BtnRefuse", self.nProposeId)
	self.pPanel:SetActive("Time1", self.nProposeId)
	self.pPanel:SetActive("Time2", self.nBeProposeId)
	--self.pPanel:SetActive("BtnCancel", self.nBeProposeId)
	local szProposeName = self.nBeProposeId and me.szName or self.szOtherName
	local szBeProposeName = self.nProposeId and me.szName or self.szOtherName
	self.pPanel:Label_SetText("RequesterName", string.format("[c8fe00]%s[-]", szProposeName))
	local szContent = "[ff72c5]愿得一人心，白首不相离！\n[-]亲爱的[c8fe00]%s[-]，我们在一起吧？\n愿与您携手共度剑侠的每一天！"
	local szPromise = Wedding.tbProposePromise[nProposeIndex]
	if szPromise then
		szContent = szPromise
	end
	self.pPanel:Label_SetText("RequestContent", string.format(szContent, szBeProposeName))
	self:CloseTimer()
	self.nTimer = Timer:Register(Env.GAME_FPS, self.CountDown, self);
	self.pPanel:SetActive("huaban", true)
	self.pPanel:SetActive("Describe", true)
end

function tbUi:CountDown()
	self.nCountDown = self.nCountDown - 1
	if self.nCountDown <= 0 then
		self.nTimer = nil;
		self:Refuse()
		Ui:CloseWindow(self.UI_NAME)
		return false
	else
		if self.nProposeId then
			self.pPanel:Label_SetText("Time1", string.format("%d秒", self.nCountDown))
		else
			self.pPanel:Label_SetText("Time2", string.format("等待对方回应（%d秒）", self.nCountDown))
		end
		
		return true
	end
end

function tbUi:Refuse()
	if self.nProposeId then
		me.SendBlackBoardMsg(string.format(Wedding.szBeProposeTimeoutTip, self.szOtherName), true)
	else
		me.SendBlackBoardMsg(string.format(Wedding.szProposeTimeoutTip, self.szOtherName), true)
	end
	Wedding:EndProposeState()
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:CloseTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

tbUi.tbOnClick = {
	BtnAccept = function (self)
		if not self.nProposeId then
			me.CenterMsg("被求婚者才可操作", true)
		else
			RemoteServer.OnWeddingRequest("ProposeResult", self.nProposeId, Wedding.PROPOSE_OK);
		end
		
	end;
	BtnRefuse = function (self)
		if not self.nProposeId then
			me.CenterMsg("被求婚者才可操作", true)
		else
			RemoteServer.OnWeddingRequest("ProposeResult", self.nProposeId, Wedding.PROPOSE_REFUSE);
		end
	end;
	-- BtnCancel = function (self)
	-- 	if not self.nBeProposeId then
	-- 		me.CenterMsg("求婚者才可操作", true)
	-- 	else
	-- 		RemoteServer.OnWeddingRequest("CancelPropose", self.nBeProposeId);
	-- 	end
	-- end;
}