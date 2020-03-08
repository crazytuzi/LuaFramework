local tbUi = Ui:CreateClass("TrialPanel");

tbUi.MAX_SHOW_AWARD = 3
tbUi.MAX_SHOW_BOSS = 4 


function tbUi:OnOpen()
	if SeriesFuben:IsTaskFinish() then
		return 0
	end

	self.bNpcOpen = true
	self.MaxFubenCount = SeriesFuben:GetFubenCount()
	self.nCurIndex = SeriesFuben:GetCurIdx(me)
	self.nCurIndex = self.nCurIndex > self.MaxFubenCount and self.MaxFubenCount or self.nCurIndex
	self.nCurShowIndex = self.nCurIndex
end

function tbUi:OnOpenEnd()
	self:Refresh()
end

function tbUi:Refresh()

	self:UpdateRight();
	self:UpdateLeft();
	self:UpdateView()
end

function tbUi:UpdateView()
	self.pPanel:NpcView_Open("PartnerView");
	local tbInfo = SeriesFuben:GetFubenInfo(self.nCurShowIndex) 
	local nFaceId, nResId, nBigFaceId = KNpc.GetNpcShowInfo(tbInfo.BossTemplateId or 0);
	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	local szNpcName = KNpc.GetNameByTemplateId(tbInfo.BossTemplateId);
	self.pPanel:Label_SetText("DekaronTarget", szNpcName or "");
end

function tbUi:UpdateLeft()
	for i=1,self.MAX_SHOW_BOSS do
		 self.pPanel:SetActive("Lock" ..i,false)
	end

	for i=1,self.MAX_SHOW_BOSS do
		 self.pPanel:SetActive("Head" ..i,false)
	end

	local function fnClickItem(itemObj)
		local tbFubenInfo = itemObj.tbFubenInfo
		self.nCurShowIndex = tbFubenInfo.FubenIdx
		self:UpdateRight();
		self:UpdateView()
	end

	local tbFubenInfo = self:GetFubenInfo()
	for index,tbInfo in ipairs(tbFubenInfo) do
		self.pPanel:SetActive("Head" ..index,true)
		local szAtlas, szSprite = Npc:GetFaceResourceByNpcTemplateId(tbInfo.BossTemplateId)

		self["Head" ..index].pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas);
		self["Head" ..index].pPanel:Label_SetText("lbLevel", (tbInfo.BossLevel or 99));
		self["Head" ..index].pPanel:SetActive("SpFaction",false)
		self["Head" ..index].pPanel.OnTouchEvent = fnClickItem;
		self["Head" ..index].tbFubenInfo = tbInfo
		if tbInfo.FubenIdx > self.nCurIndex then
			self.pPanel:SetActive("Lock" ..index,true)
		end
	end
end

function tbUi:UpdateRight()

	local tbInfo = SeriesFuben:GetFubenInfo(self.nCurShowIndex)
	
	local szNotEng = "[FF0000]"
	local szAccord = "[9EFFE9]"
	local szLevel = tbInfo.ReqLevel > me.nLevel and szNotEng or szAccord
	local szLevel = szLevel .. tbInfo.ReqLevel .. "级"
	self.pPanel:Label_SetText("Level", szLevel);
	
	local nMyFightPower = me.GetNpc().GetFightPower()
	local szFight = tbInfo.FightPower > nMyFightPower and szNotEng or szAccord
	szFight = szFight .. tbInfo.FightPower
	self.pPanel:Label_SetText("Fighting", szFight);
	self.pPanel:Label_SetText("Time", tbInfo.Time .."秒");
	local tbAward = SeriesFuben:GetAward(self.nCurShowIndex)
	for i=1,self.MAX_SHOW_AWARD do
		 self.pPanel:SetActive("itemframe" ..i,false)
	end

	for nIndex,tbAwardInfo in ipairs(tbAward) do
		if nIndex <= self.MAX_SHOW_AWARD then
			local szItemFrameName = "itemframe" ..nIndex
			self.pPanel:SetActive(szItemFrameName,true)
			self[szItemFrameName].pPanel:SetActive("ItemLayer",true)
			self[szItemFrameName]:SetGenericItem(tbAwardInfo)
			self[szItemFrameName].fnClick = self[szItemFrameName].DefaultClick;
		end
	end
end

function tbUi:GetFubenInfo()

	local tbFubenInfo = {}
	local nPage = math.ceil(self.nCurIndex / 4) - 1
	local nStartIndex = nPage * 4 + 1
	local nEndIndex = nPage * 4 + 4
	for i = nStartIndex,nEndIndex do
		local tbInfo = SeriesFuben:GetFubenInfo(i)
		if tbInfo then
			table.insert(tbFubenInfo,tbInfo)
		end
	end
	return tbFubenInfo
end

function tbUi:OnClose()
	if self.bNpcOpen then
		self.bNpcOpen = false;
		self.pPanel:NpcView_Close("PartnerView");
	end
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow("TrialPanel");
	end,
	BtnDekaron = function (self)
		local bRet, szMsg = SeriesFuben:CheckCanEntry(self.nCurShowIndex)
		if not bRet then
			me.CenterMsg(szMsg or "请重试");
			return 
		end
		RemoteServer.TryEntrySeriesFuben()
		Ui:CloseWindow("TrialPanel");
	end,

}