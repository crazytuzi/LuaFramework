local tbAct = Activity.DumplingBanquetAct

function tbAct:UpdateRankData()
	local tbData = self:GetRankData()
	RemoteServer.DumplingBanquetCall("UpdateRankData", tbData.nVersion)
end

function tbAct:GetRankData()
	return self.tbRankData or {nVersion=0}
end

function tbAct:OnUpdateRankData(tbData)
	self.tbRankData = tbData
	table.sort(self.tbRankData.tbRankData, function(tbA, tbB)
		return tbA[4] > tbB[4] or (tbA[4]==tbB[4] and tbA[5]<tbB[5]) or (tbA[4]==tbB[4] and tbA[5] == tbB[5] and tbA[1] < tbB[1])
	end)
	self.nMyRank = 0;
	for i = 1, #self.tbRankData.tbRankData do
		if self.tbRankData.tbRankData[i][1] == me.dwID then
			self.tbMyRank = self.tbRankData.tbRankData[i];
			self.nMyRank = i;
			break;
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_DUMPLINGBANQUET_RANK);
end

function tbAct:GetMyRank()
	return self.tbMyRank or {}
end

function tbAct:UpdateCurrentStageData()
	RemoteServer.DumplingBanquetCall("SynDumplingData")
end

function tbAct:OnUpdateCurrentStageData(tbData)
	self.tbCurrentStageInfo = tbData;
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_DUMPLINGBANQUET_CURRENTSTAGEINFO)
end

function tbAct:GetCurrentStageData()
	return self.tbCurrentStageInfo or {}
end

function tbAct:OnUpdateStageData(tbData)
	self.tbStageInfo = tbData;
end

function tbAct:GetStageData()
	return self.tbStageInfo or {}
end

function tbAct:OnUpdateIngredientsData(tbData)
	self.tbIngredientsInfo = tbData;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SETINGREDIENTS)
end

function tbAct:GetIngredientsData()
	return self.tbIngredientsInfo or {}
end

function tbAct:OnShowNpcBubbleTalk(tbData)
	self:StopBubbleTimer();
	self.nTotalBubbleTimer = Timer:Register(tbData.nTotalTime * Env.GAME_FPS, self.StopBubbleTimer, self);
	self.tbNpcBubbleInfo = tbData;
	Ui:NpcBubbleTalk(self.tbNpcBubbleInfo.nNpcId, self.tbNpcBubbleInfo.szMsg, self.tbNpcBubbleInfo.nBubbleTime)
	self:StartBubbleTimer();
end

function tbAct:StartBubbleTimer()
	Ui:NpcBubbleTalk(self.tbNpcBubbleInfo.nNpcId, self.tbNpcBubbleInfo.szMsg, self.tbNpcBubbleInfo.nBubbleTime)
	if self.nTimer then
		Timer:Close(self.nTimer)
	end
	self.nTimer = Timer:Register(self.tbNpcBubbleInfo.nBubbleIntervalTime * Env.GAME_FPS, self.StartBubbleTimer, self);
end

function tbAct:StopBubbleTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
	if self.nTotalBubbleTimer then
		Timer:Close(self.nTotalBubbleTimer)
		self.nTotalBubbleTimer = nil;
	end
end

function tbAct:OnLogout()
	self.tbMyRank = {};
	self.tbRankData = {};
	self.tbStageInfo = {};
end

