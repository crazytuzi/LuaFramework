local tbUi = Ui:CreateClass("MedalFightWaitPanel")

tbUi.tbOnClick = {
	BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
 	BtnReady = function(self)
 		if not self.tbData then
 			me.CenterMsg("比赛时间未到，请到19:00-19:30期间再来！")
 			return
 		end
 		if self.tbData.bJoin then
 			RemoteServer.MedalFightReq("Quit")
 		else
 			RemoteServer.MedalFightReq("Join")
 		end
 	end,
}

function tbUi:OnOpen(bAutoJoin)
	if bAutoJoin then
		RemoteServer.MedalFightReq("Join")
	end

	self:Refresh()
	RemoteServer.MedalFightReq("UpdateStatus")
	self:StartTimer()
end

function tbUi:Refresh()
	self.pPanel:Label_SetText("Time", "00:00")
	self.pPanel:SetActive("State", false)
	local nMedal = Activity.MedalFightAct:GetScore(me)
	self.pPanel:Label_SetText("Medal", nMedal)
	local nJoin, nMax = Activity.MedalFightAct:GetJoinCount(me)
	self.pPanel:Label_SetText("Number", string.format("%d/%d", nJoin, nMax))

	self.pPanel:Label_SetText("TextOk", "准备")

	if not self.tbData or self.tbData.nEndTime<GetTime() then
		return
	end

	if self.tbData.bJoin then
		self.pPanel:SetActive("State", true)
		self.pPanel:Label_SetText("TextOk", "取消准备")
	end
	self:UpdateTime()
end

function tbUi:StartTimer()
	self:StopTimer()
	self.nTimer = Timer:Register(Env.GAME_FPS, function()
		self:UpdateTime()
		return true
	end)
end

function tbUi:StopTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

function tbUi:OnClose()
	self:StopTimer()
end

function tbUi:UpdateTime()
	if self.tbData then
		local nNow = GetTime()
		self.pPanel:Label_SetText("Time", Lib:TimeDesc3(math.max(0, self.tbData.nEndTime-nNow)))

		if self.tbData.nEndTime<nNow then
			self:Refresh()
		end
	end
end

function tbUi:OnUpdate(tbData)
	self.tbData = tbData
	self:Refresh()
	self:StartTimer()
end