local tbUi = Ui:CreateClass("MarriagePaperPanel")
local NpcViewMgr = luanet.import_type("NpcViewMgr")
tbUi.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnVideo = function (self)
		local nLoveId = Wedding:GetLover(me.dwID)
		if not nLoveId then
			me.CenterMsg("没有录像数据", true)
			return
		end
		RemoteServer.OnWeddingRequest("ReplayWedding");
	end,
}

tbUi.tbSettings = {
	tbPosDirs = {
		{-60, -32, -100, 0, 180, 0},
		{138.07, -32, -100, 0, 180, 0},
	},
	tbLevelNpcIds = {
		{601, 602},
		{590, 603},
		{591, 604},
	},
}

function tbUi:OnClickLinkNpc(nNpcTemplateId, nMapTemplateId)
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
    return {
        {UiNotify.emNOTIFY_WND_OPENED, self.OnWndOpened},
		{UiNotify.emNOTIFY_WND_CLOSED, self.OnWndClosed},
		{UiNotify.emNOTIFY_CLICK_LINK_NPC, self.OnClickLinkNpc},
    }
end

tbUi.tbHideWnds = {
	GeneralHelpPanel = true,
	MapLoading = true;
}
function tbUi:OnWndOpened(szWndName)
	if not self.tbHideWnds[szWndName]  then
		return
	end
	self:SetModelsVisible(false)
end

function tbUi:OnWndClosed(szWndName)
	if not self.tbHideWnds[szWndName]  then
		return
	end
	self:SetModelsVisible(true)
end

function tbUi:OnOpen(nItemId, tbSpecifiedData)
	tbSpecifiedData = tbSpecifiedData or {}
	local szHusbandName = tbSpecifiedData.szHusbandName
	local szWifeName = tbSpecifiedData.szWifeName
	local szHusbandPledge = tbSpecifiedData.szHusbandPledge
	local szWifePledge = tbSpecifiedData.szWifePledge
	local nTimestamp = tbSpecifiedData.nTimestamp
	local nLevel = tbSpecifiedData.nLevel

	self.bSpecified = true

	if nItemId then
		local pItem = KItem.GetItemObj(nItemId)
		if not pItem then
			Log("[x] MarriagePaperPanel:OnOpen item nil", nItemId)
			return 0
		end

		szHusbandName = pItem.GetStrValue(Wedding.nMPHusbandNameIdx)
		szWifeName = pItem.GetStrValue(Wedding.nMPWifeNameIdx)
		szHusbandPledge = pItem.GetStrValue(Wedding.nMPHusbandPledgeIdx)
		szWifePledge = pItem.GetStrValue(Wedding.nMPWifePledgeIdx)
		nTimestamp = pItem.GetIntValue(Wedding.nMPTimestamp)
		nLevel = pItem.GetIntValue(Wedding.nMPLevel)

		self.bSpecified = false
	end

	if not szHusbandName or not szWifeName or not szHusbandPledge or not szWifePledge or not nTimestamp or not nLevel then
		Log("[x] MarriagePaperPanel:OnOpen value nil", tostring(szHusbandName), tostring(szWifeName),
			tostring(szHusbandPledge), tostring(szWifePledge), tostring(nTimestamp), tostring(nLevel),
			tostring(nItemId), tostring(tbSpecifiedData))
		return 0
	end

	self.pPanel:SetActive("BtnVideo", not self.bSpecified)
	self.pPanel:Label_SetText("Name1", szHusbandName)
	self.pPanel:Label_SetText("Name2", szWifeName)
	self.pPanel:Label_SetText("Declaration1", szHusbandPledge)
	self.pPanel:Label_SetText("Declaration2", szWifePledge)
	self.pPanel:Label_SetText("Time", string.format("成婚时间：%s，已成婚[FFFE0D]%d天[-]", Lib:TimeDesc11(nTimestamp), Lib:SecondsToDays(GetTime()-nTimestamp) + 1))

	local nNow = GetTime()
	local nCurMaxMonth = Wedding:GetMaxMemorialMonth(nTimestamp, nNow)
	local nCfgMaxMonth = Wedding:GetMemorialCfgMaxMonth()
	local szNextMemorialDay = nil
	for i=nCurMaxMonth, nCfgMaxMonth do
		if Wedding.tbMemorialMonthRewards[i] then
			local nGuessTimestamp = nTimestamp+24*3600*28*i
			local nGuessMaxTimestamp = nTimestamp+24*3600*31*i
			for nTmpTime=nGuessTimestamp, nGuessMaxTimestamp, 24*3600 do
				if Wedding:GetMaxMemorialMonth(nTimestamp, nTmpTime)==i then
					if Lib:GetLocalDay(nNow)>=Lib:GetLocalDay(nTmpTime) then
						break
					end
					szNextMemorialDay = Lib:TimeDesc11(nTmpTime)
					break
				end
			end

			if szNextMemorialDay then
				break
			end
		end
	end
	local szTips = szNextMemorialDay and string.format("下个纪念日：%s [00FF00][url=openwnd:纪念日奖励, GeneralHelpPanel, 'MarriageMDHelp'][-]", szNextMemorialDay) or "下个纪念日：你们已经是老夫老妻了，祝恩爱百年！"
	self.Time1:SetLinkText(szTips)
	self.pPanel:SetActive("Time1", not self.bSpecified)

	self:ShowModels(nLevel)
end

function tbUi:SetModelsVisible(bVisible)
	self.tbViewModelIds = self.tbViewModelIds or {}
	for _,v in ipairs(self.tbViewModelIds) do
		NpcViewMgr.SetUiViewFeatureActive(v, bVisible)
	end
end

function tbUi:ShowModels(nLevel)
	self.tbViewModelIds = self.tbViewModelIds or {}
	if #self.tbViewModelIds>0 and self.nLevel==nLevel then
		self:SetModelsVisible(true)
		return
	end
	self.nLevel = nLevel
	
	for i=1,2 do
		local nX, nY, nZ, rX, rY, rZ = unpack(self.tbSettings.tbPosDirs[i])
		local nShowId = self.tbViewModelIds[i]
		if nShowId then
			NpcViewMgr.SetUiViewFeatureActive(nShowId, true)	
			NpcViewMgr.SetModePos(nShowId, nX, nY, nZ)
			NpcViewMgr.ChangeAllDir(nShowId, rX, rY, rZ, false)
		else
			nShowId = NpcViewMgr.CreateUiViewFeature(nX, nY, nZ, rX, rY, rZ)
			self.tbViewModelIds[i] = nShowId
		end

		NpcViewMgr.SetScale(nShowId, ViewRole:GetScale(self))

		local nNpcId = self.tbSettings.tbLevelNpcIds[nLevel][i]
		NpcViewMgr.ChangePartBody(nShowId, nNpcId, true)
	end
end


function tbUi:OnClose()
	self:SetModelsVisible(false)
end

function tbUi:OnDestroyUi()
	for _,v in ipairs(self.tbViewModelIds or {}) do
		NpcViewMgr.DestroyUiViewFeature(v)
	end
end