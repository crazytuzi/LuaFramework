local tbUi = Ui:CreateClass("QYHMatchingPanel");
tbUi.tbRankIcon = {"Rank_top1", "Rank_top2", "Rank_top3"}
function tbUi:OnOpen()
	QunYingHuiCross:SynMatchData()
	self:RefreshUi()
end

function tbUi:RefreshUi()
	self:CloseUpdateTimer()
	local tbFirstWinAward, nFirstId = QunYingHuiCross:GetWinAward(QunYingHuiCross.nShowWinCount)
	local itemframe1 = self["itemframe1"]
	if tbFirstWinAward then
		self.pPanel:SetActive("itemframe1", true)
		itemframe1.pPanel:SetActive("ItemLayer",true)
		itemframe1:SetGenericItem(tbFirstWinAward[1])
		itemframe1.fnClick = itemframe1.DefaultClick;
	end
	local tbTenJoinAward, nTenId = QunYingHuiCross:GetJoinAward(QunYingHuiCross.nShowJoinCount)
	local itemframe2 = self["itemframe2"]
	if tbTenJoinAward then
		self.pPanel:SetActive("itemframe2", true)
		itemframe2.pPanel:SetActive("ItemLayer",true)
		itemframe2:SetGenericItem(tbTenJoinAward[1])
		itemframe2.fnClick = itemframe2.DefaultClick;
	end
	local tbMatchData = QunYingHuiCross:GetMatchData()
	local nMyRank = tbMatchData.nRank
	local nMyFightTime = tbMatchData.nFightTime or 0
	local nMyFightCount = tbMatchData.nFightCount or 0
	local nMyState = tbMatchData.nState or QunYingHuiCross.STATE_NONE
	local nMyWinRate = tbMatchData.nWinRate or 0
	local nMyWinCount = tbMatchData.nWinCount or 0
	local szMyName = me.szName
	local nServerIdx = tbMatchData.nServerIdx or "-"
	local nMyFaction = tbMatchData.nFaction or 0
	local tbMyGetWinAwardFlag = tbMatchData.tbGetWinAwardFlag or {}
	local tbMyGetJoinAwardFlag = tbMatchData.tbGetJoinAwardFlag or {}
	local szMyKinName = tbMatchData.szKinName
	local nMyType = tbMatchData.nType
	local bCanMatch = (tbMatchData.nProcess == QunYingHuiCross.MATCH_OPEN) and true or false
	self.pPanel:Sprite_SetGray("BtnMatching", not bCanMatch)
	
	self.nMatchTime = tbMatchData.nMatchTime or 0
	self.pPanel:Label_SetText("Time", Lib:TimeDesc3(self.nMatchTime))
	if self.nMatchTime > 0 then
		self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.UpdateTime, self);
	end
	local bGetFirst = tbMyGetWinAwardFlag[nFirstId] and true or false
	self.pPanel:Sprite_SetGray("itemframe1Bg", bGetFirst)
	self.pPanel:SetBoxColliderEnable("itemframe1Bg", not bGetFirst)
	local bGetJoin = tbMyGetJoinAwardFlag[nTenId] and true or false
	self.pPanel:Sprite_SetGray("itemframe2Bg", bGetJoin)
	self.pPanel:SetBoxColliderEnable("itemframe2Bg", not bGetJoin)
	local szStateTxt = ""
	if nMyType == QunYingHuiCross.TYPE_SINGLE then
		szStateTxt = "当前为[EE0000]单人匹配[-]状态"
	elseif nMyType == QunYingHuiCross.TYPE_TEAM then
		szStateTxt = "当前为[EE0000]组队匹配[-]状态"
	end
	self.pPanel:Label_SetText("StateTxt", string.format(szStateTxt))
	self.pPanel:Label_SetText("itemframe2txt2", string.format("(%s/%s)", nMyFightCount, QunYingHuiCross.nShowJoinCount))
	local itemObj = self["QYHRankItem8"].pPanel
	itemObj:SetActive("RankIcon", false)
	itemObj:SetActive("RankLabel2", false)
	itemObj:SetActive("RankLabel", false)
	if nMyRank then
		if nMyRank < 4 then
			local szRankIcon = self.tbRankIcon[nMyRank]
			if szRankIcon then
				itemObj:SetActive("RankIcon", true)
				itemObj:Sprite_SetSprite("RankIcon", szRankIcon);
			end
		else
			itemObj:SetActive("RankLabel", true)
			itemObj:Label_SetText("RankLabel", nMyRank);
		end
	else
		itemObj:SetActive("RankLabel2", true)
	end
	itemObj:Label_SetText("Name", szMyName);
	local szMyServerKin = (not Lib:IsEmptyStr(szMyKinName)) and string.format("%s服-%s", nServerIdx, szMyKinName) or string.format("%s服", nServerIdx)
	itemObj:Label_SetText("Server", szMyServerKin);
	local szMyWinRate = string.format("%s/%s([FFFE0D]%s[-])", nMyWinCount, nMyFightCount, string.format("%.2f%%", (nMyFightCount == 0 and 0 or (nMyWinCount / nMyFightCount * 100))))
	itemObj:Label_SetText("WinningRate", szMyWinRate);
	itemObj:Label_SetText("Time", Lib:TimeDesc3(nMyFightTime));
	local SpFaction = Faction:GetIcon(nMyFaction)
	if not Lib:IsEmptyStr(SpFaction) then
		itemObj:SetActive("Faction", true)
		itemObj:Sprite_SetSprite("Faction",  SpFaction);
	else
		itemObj:SetActive("Faction", false)
	end

	self.pPanel:SetActive("BtnMatching", nMyState ~= QunYingHuiCross.STATE_MATCHING)
	self.pPanel:SetActive("HeadState", nMyState == QunYingHuiCross.STATE_MATCHING)
	self.pPanel:SetActive("BtnCancel", nMyState == QunYingHuiCross.STATE_MATCHING)


	local tbRank = tbMatchData.tbRank or {}
	local fnSetItem = function(itemObj, nIdx)
		local tbRankInfo = tbRank[nIdx]
		local nRank = tbRankInfo.nRank or 0
		local szName = tbRankInfo.szName or "-"
		local nWinRate = tbRankInfo.nWinRate or 0
		local nFightTime = tbRankInfo.nFightTime or 0
		local nServerIdx = tbRankInfo.nServerIdx or "-"
		local szName = tbRankInfo.szName or "-"
		local nFaction = tbRankInfo.nFaction or 0
		local nWinCount = tbRankInfo.nWinCount or 0
		local nFightCount = tbRankInfo.nFightCount or 0
		local szKinName = tbRankInfo.szKinName or ""

		itemObj.pPanel:SetActive("RankIcon", false)
		itemObj.pPanel:SetActive("RankLabel", false)
		if nRank < 4 then
			local szRankIcon = self.tbRankIcon[nRank]
			if szRankIcon then
				itemObj.pPanel:SetActive("RankIcon", true)
				itemObj.pPanel:Sprite_SetSprite("RankIcon", szRankIcon);
			end
		else
			itemObj.pPanel:SetActive("RankLabel", true)
			itemObj.pPanel:Label_SetText("RankLabel", nRank);
		end
		itemObj.pPanel:Label_SetText("Name", szName);
		local szServerKin = (not Lib:IsEmptyStr(szKinName)) and string.format("%s服-%s", nServerIdx , szKinName) or string.format("%s服", nServerIdx)
		itemObj.pPanel:Label_SetText("Server", szServerKin);
		local szWinRate = string.format("%s/%s([FFFE0D]%s[-])", nWinCount, nFightCount, string.format("%.2f%%", (nFightCount == 0 and 0 or (nWinCount / nFightCount * 100))))
		itemObj.pPanel:Label_SetText("WinningRate", szWinRate);
		itemObj.pPanel:Label_SetText("Time", Lib:TimeDesc3(nFightTime));
		local SpFaction = Faction:GetIcon(nFaction)
		if SpFaction then
			itemObj.pPanel:SetActive("Faction", true)
			itemObj.pPanel:Sprite_SetSprite("Faction",  SpFaction);
		else
			itemObj.pPanel:SetActive("Faction", false)
		end
	end
	self.RankQYHScrollView:Update(tbRank, fnSetItem)
end

function tbUi:UpdateTime()
	self.nMatchTime = self.nMatchTime - 1
	self.pPanel:Label_SetText("Time", Lib:TimeDesc3(self.nMatchTime))
	if self.nMatchTime <= 0 then
		self.nUpdateTimer = nil
		return false
	end
	return true
end

function tbUi:OnClose()
	self:CloseUpdateTimer()
end

function tbUi:CloseUpdateTimer()
	if self.nUpdateTimer then
		Timer:Close(self.nUpdateTimer)
		self.nUpdateTimer = nil
	end
end

function tbUi:RegisterEvent()
    local tbRegEvent = {
        {UiNotify.emNOTIFY_QYHCROSS_SYN_MATCH_DATA, self.RefreshUi, self},
    }
    return tbRegEvent
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnMatching = function (self)
		RemoteServer.QYHCrossClientCall("JoinMatch")
	end;
	BtnCancel = function (self)
		RemoteServer.QYHCrossClientCall("QuiteMatch")
	end;
	itemframe1Bg = function (self)
		local bRet, szMsg = QunYingHuiCross:CheckGetWinAward(QunYingHuiCross.nShowWinCount)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return 
		end
		RemoteServer.QYHCrossClientCall("GetWinAward", QunYingHuiCross.nShowWinCount)
	end;
	itemframe2Bg = function (self)
		local bRet, szMsg = QunYingHuiCross:CheckGetJoinAward(QunYingHuiCross.nShowJoinCount)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return 
		end
		RemoteServer.QYHCrossClientCall("GetJoinAward", QunYingHuiCross.nShowJoinCount)
	end;
}
