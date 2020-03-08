local tbUi = Ui:CreateClass("ChangBaiZhiDianSignUpPanel")

tbUi.tbOpenTime = {
	{"13:30", "13:45"},
	{"16:00", "16:15"},
	{"20:00", "20:15"},
}

function tbUi:GetNextOpenTime()
	local nNow = GetTime()
	local nNext = 1
	for nIdx, tbTimeInfo in ipairs(self.tbOpenTime) do
		if nNow < Lib:ParseTodayTime(tbTimeInfo[1]) + Lib:GetTodayZeroHour() then
			nNext = nIdx
			break
		end
	end
	return self.tbOpenTime[nNext]
end

function tbUi:OnOpen()
	self:Update()
	RemoteServer.ChangBaiClientCall("RequestMatchTime")
end

function tbUi:Update()
	if self.nTimerReady then
		Timer:Close(self.nTimerReady)
		self.nTimerReady = nil
	end

	local nCount = ChangBaiZhiDian:GetJoinCount(me)
	self.pPanel:Label_SetText("Type", string.format("剩余参与次数：%d", nCount))

	local tbMatchTime = ChangBaiZhiDian.tbMatchTime
	if not tbMatchTime or not next(tbMatchTime) then
		local tbNextOpenTime = self:GetNextOpenTime()
		self.pPanel:Label_SetText("OpenTime", string.format("下场开启时间：%s~%s", tbNextOpenTime[1], tbNextOpenTime[2]))
	else
		self:UpdateLeftTime()
	end
end

function tbUi:UpdateLeftTime()
	if self.nTimerReady then
		Timer:Close(self.nTimerReady)
		self.nTimerReady = nil
	end

	local bOpen = false
	local tbMatchTime = ChangBaiZhiDian.tbMatchTime
	if not tbMatchTime or not next(tbMatchTime) then
		local tbNextOpenTime = self:GetNextOpenTime()
		self.pPanel:Label_SetText("OpenTime", string.format("下场开启时间：%s~%s", tbNextOpenTime[1], tbNextOpenTime[2]))
		return
	end
	for _, nTime in ipairs(tbMatchTime) do
		if nTime - GetTime() > 0 then
			--准备时间文字设置为剩余时间
			bOpen = true
			self.nLeftTime = nTime - GetTime()
			self.nTimerReady = Timer:Register(Env.GAME_FPS, self.TimerUpdate, self)
			self.pPanel:Label_SetText("OpenTime", string.format("本场准备时间：[FFFE0D]%s[-]", Lib:TimeDesc(self.nLeftTime)))
			break
		end
	end
	if not bOpen then
		local tbNextOpenTime = self:GetNextOpenTime()
		self.pPanel:Label_SetText("OpenTime", string.format("下场开启时间：%s~%s", tbNextOpenTime[1], tbNextOpenTime[2]))
	end
end

function tbUi:TimerUpdate()
	self.nLeftTime = self.nLeftTime - 1
	if self.nLeftTime < 0 then
		self:Update()
		return
	end
	self.pPanel:Label_SetText("OpenTime", string.format("本场准备时间：[FFFE0D]%s[-]", Lib:TimeDesc(self.nLeftTime)))
	return true
end

function tbUi:OnClose()
	if self.nTimerReady then
		Timer:Close(self.nTimerReady)
		self.nTimerReady = nil
	end
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnPersonJoin()
	if TeamMgr:HasTeam() then
		me.CenterMsg("您当前已经有队伍了！")
		return
	end
	if Map:GetClassDesc(me.nMapTemplateId) == "fight" and me.nFightMode ~= 0 then
		local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
		if nX and nY then
			me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
			Ui:CloseWindow(self.UI_NAME)
			AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function() Ui:OpenWindow(self.UI_NAME) end)
			return
		else
			me.CenterMsg("当前区域不允许参与，请返回安全区再报名！")
			Ui:CloseWindow(self.UI_NAME)
			return
		end
	end
	RemoteServer.ChangBaiClientCall("SingleSignUp")
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnRanksJoin()
	if not TeamMgr:HasTeam() then
		me.CenterMsg("您当前没有队伍！")
		return
	end
	if Map:GetClassDesc(me.nMapTemplateId) == "fight" and me.nFightMode ~= 0 then
		local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
		if nX and nY then
			me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
			Ui:CloseWindow(self.UI_NAME)
			AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function() Ui:OpenWindow(self.UI_NAME) end)
			return
		else
			me.CenterMsg("当前区域不允许参与，请返回安全区再报名！")
			Ui:CloseWindow(self.UI_NAME)
			return
		end
	end
	RemoteServer.ChangBaiClientCall("TeamSignUp")
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnBack()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_SYNC_CHANGBAI_MATCH_TIME, self.UpdateLeftTime},
	}
	return tbRegEvent
end