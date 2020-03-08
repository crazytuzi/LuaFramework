function RankBattleCross:UpdateTenPlayer(tbTen, tbSelfInfo, nTimerAward)
	self.tbTen = tbTen;
	self.tbSelfInfo = tbSelfInfo;
	self.nTimerAward = nTimerAward;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANK)
end

function RankBattleCross:UpdateEnemy(tbEnemy, nFrashEnemyCD)
	self.tbEnemy = tbEnemy;
	self.nFrashEnemyCD = nFrashEnemyCD;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANK)
end

function RankBattleCross:SynRankData(szTimeFrame, nStartTime)
	self.szTimeFrame = szTimeFrame
	self.nStartTime = nStartTime
	print("SynRankData->",self.szTimeFrame,self.nStartTime)
end

function RankBattleCross:UpdateLeave(bShow)
	if bShow then
		Ui:SetMapCloseUI(me.nMapTemplateId, {"LeavePanel"})
		Ui:OpenWindow("LeavePanel", "认输", "您确认投降认输么？", {
			function () 
				RemoteServer.EndAsyncBattle()
			end});
	else
		Ui:CloseWindow("LeavePanel");
	end
end