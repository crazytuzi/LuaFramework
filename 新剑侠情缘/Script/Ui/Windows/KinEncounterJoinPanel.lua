local tbUi = Ui:CreateClass("KinEncounterJoinPanel")

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnTeam = function(self)
		RemoteServer.KinEncounterReq("Join")
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen()
	self:UpdateRecord()
	RemoteServer.KinEncounterReq("UpdateRecords")

	self.pPanel:Label_SetText("IntroducesTxt", [[
		·跨服匹配[FFFE0D]实力相近[-]家族进行对战，[FFFE0D]60级[-]以上大侠可参与。
		·占领[FFFE0D]龙柱[-]获得己方积分增长，积分先到达[FFFE0D]10000点[-]或者时间结束[FFFE0D]积分高[-]的一方胜出，越到[FFFE0D]后期[-]占领龙柱获得的积分[FFFE0D]增速越快[-]。
		·占领两处[FFFE0D]神木[-]皆可获得己方木材数量增长，木材可以用来制造[FFFE0D]作战军械[-]，提高己方作战能力。
		·占领两处[FFFE0D]粮仓[-]皆可使己方[FFFE0D]全体成员[-]获得强力增益。
		·准备时间结束时家族报名人数达到[FFFE0D]8人[-]方能参与匹配对战。
		·战斗结束后按照[FFFE0D]杀敌排行[-]给家族成员发放奖励，[FFFE0D]获胜方[-]会获得更多奖励。
		·整个活动结束后按照家族在[FFFE0D]8场[-]对战中的胜场数给家族[FFFE0D]领袖[-]、[FFFE0D]族长[-]发放限时称号。
		]])
	self:Refresh()
	self:StartTimer()
end

function tbUi:OnClose()
	self:StopTimer()
end

function tbUi:Refresh()
	local nTimeLeft = (KinEncounter.nPrepareEndTime or 0) - GetTime()
	self.pPanel:Label_SetText("TxtTime", nTimeLeft <= 0 and "不在准备阶段" or Lib:TimeDesc3(nTimeLeft))
end

function tbUi:StartTimer()
	self:StopTimer()
	self.nTimer = Timer:Register(Env.GAME_FPS, function()
		self:Refresh()
		return true
	end)
end

function tbUi:StopTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

function tbUi:UpdateRecord()
	if KinEncounter.tbRecord then
		local nFail, nDraw, nWin = unpack(KinEncounter.tbRecord)
		self.pPanel:Label_SetText("VictoryOrDefeat", string.format("本家族胜场：%d/负场：%d/平场：%d", nWin or 0, nFail or 0, nDraw or 0))
	else
		self.pPanel:Label_SetText("VictoryOrDefeat", "")
	end
end
