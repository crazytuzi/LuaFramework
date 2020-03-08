local tbUi = Ui:CreateClass("ChangBaiZhiDianIntegralInfo")

function tbUi:OnOpen()
	if self.nUpdataTimer then
		Timer:Close(self.nUpdataTimer)
		self.nUpdataTimer = nil
	end
	self:Update()
	self.nUpdataTimer = Timer:Register(Env.GAME_FPS, self.Update, self)
end

function tbUi:Update()
	local nScore = ChangBaiZhiDian.nScore or 0
	local nRank = ChangBaiZhiDian.nRank or 1
	local szInfo = string.format("积分：%d\n排名：%d", nScore, nRank)
	local nReviveTime = (ChangBaiZhiDian.nReviveTimePoint or 0) - GetTime()
	if nReviveTime > 0 then
		szInfo = szInfo..string.format("\n复活时间：%d秒", nReviveTime)
	end
	self.pPanel:Label_SetText("TxtRank", szInfo)
	return true
end

function tbUi:OnClose()
	if self.nUpdataTimer then
		Timer:Close(self.nUpdataTimer)
		self.nUpdataTimer = nil
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {}

function tbUi.tbOnClick:BtnViewBattleReport()
	ChangBaiZhiDian:ReadTeamReport()
end

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_CHANGBAI_UPDATE_RANK_SCORE, self.Update},
	}
	return tbRegEvent
end