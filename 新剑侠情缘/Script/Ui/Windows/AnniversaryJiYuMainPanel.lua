local tbUi = Ui:CreateClass("AnniversaryJiYuMainPanel")
tbUi.tbOnClick = tbUi.tbOnClick or {}

function tbUi.tbOnClick:BtnPanelOpen()
	self:OpenRankBoard()
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
	Ui:CloseWindow("AnniversaryJiYuWritePanel")
end

function tbUi.tbOnClick:BtnWish1()
	self:ReadMyJiYu();
end

function tbUi.tbOnClick:BtnPanelClose()
	self:CloseRankBoard()
end

function tbUi.tbOnClick:BtnLeft()
	self.nRankBoardPage = math.max(self.nRankBoardPage - 1, 1)
	self:UpdateRankBoard()
end

function tbUi.tbOnClick:BtnRight()
	self.nRankBoardPage = math.min(self.nRankBoardPage + 1, self.nMaxPage or 1)
	self:UpdateRankBoard()
end

function tbUi.tbOnClick:BtnMy()
	local nMyRankPos = self.nMyRankPos
	if not nMyRankPos or nMyRankPos == 0 then
		me.CenterMsg("未上榜")
		return;
	end
	local nPage = math.ceil(nMyRankPos / RankBoard.PAGE_NUM)
	if self.nRankBoardPage == nPage then
		return;
	end
	self.nRankBoardPage = nPage;
	self:UpdateRankBoard();
end

for i = 1, 12 do
	tbUi.tbOnClick["WishBar"..i] = function (self)
		self:ReadFriendJiYu(i)
	end
end

for i = 1, 7 do
	tbUi.tbOnClick["RankingsList"..i] = function (self)
		self:ReadRankBoardJiYu(i)
	end
end

tbUi.bShowRankBoard = true

function tbUi:OnOpen()
	self.nRankBoardPage = 1;
	if self.bShowRankBoard then
		self:UpdateRankBoard();
	end
	self:UpdateFriendJiYuList()
end

function tbUi:OpenRankBoard()
	if self.bShowRankBoard then
		return 
	end
	self.pPanel:SetActive("BackGround", true)
	self.bShowRankBoard = true
	self:UpdateRankBoard()
end

function tbUi:CloseRankBoard()
	if not self.bShowRankBoard then
		return
	end
	self.pPanel:SetActive("BackGround", false)
	self.bShowRankBoard = false
end

function tbUi:OnSynRankData()
	if not self.bShowRankBoard then
		return;
	end
	self:UpdateRankBoard();
end

function tbUi:UpdateRankBoard()
	local tbData = RankBoard:CheckUpdateData("AnniversaryJiYuAct", self.nRankBoardPage) or {}
	local tbMyInfo = RankBoard.tbMyRankInfo["AnniversaryJiYuAct"] or {}
	self.nMyRankPos = tbMyInfo.nPosition
	self.tbRankBoardPlayer = {}
	for i = 1, RankBoard.PAGE_NUM do
		local tbRecord = tbData[i]
		self.pPanel:SetActive("RankingsList"..i, tbRecord and true or false)
		if tbRecord then
			self.tbRankBoardPlayer[i] = tbRecord.dwUnitID
			local pPanel = self["RankingsList"..i].pPanel
			local mgPrefix, Atlas = Player:GetHonorImgPrefix(tbRecord.nHonorLevel);
			if ImgPrefix then
				pPanel:SetActive("PlayerTitle", true);
				pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
			else
				pPanel:SetActive("PlayerTitle", false);
			end
			pPanel:SetActive("RankingsTxt", true)
			pPanel:Label_SetText("lbLevel", tbRecord.nLevel)
			pPanel:Label_SetText("lbRoleName", tbRecord.szName);
			pPanel:Label_SetText("PraiseTxt", tbRecord.szValue);
			local szPortrait, szAtlas = PlayerPortrait:GetSmallIcon(tbRecord.nPortrait);
			pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAtlas);
			pPanel:Label_SetText("RankingsTxt", tbRecord.nPosition);
			pPanel:SetActive("RankingsGroup", true);
			for j = 1, 3 do
				if tbRecord.nPosition == j then
					pPanel:SetActive("RankingsTxt", false);
				end
				pPanel:SetActive("Rankings" .. j, tbRecord.nPosition == j)
			end
			if tbRecord.nPosition == self.nMyRankPos then
				pPanel:SetActive("RankingsList" .. i.."Self", true);
			else
				pPanel:SetActive("RankingsList" .. i.."Self", false);
			end
			local szFaction = Faction:GetIcon(tbRecord.nFaction);
			pPanel:Sprite_SetSprite("SpFaction", szFaction);
		end
	end
	local nMaxNum = tbMyInfo.nLength or 0
	self.nMaxPage = math.max(math.ceil(nMaxNum / RankBoard.PAGE_NUM), 1)
	self.pPanel:Label_SetText("Pages", string.format("%d/%d", self.nRankBoardPage, self.nMaxPage))
end

local tbAct = Activity.AnniversaryJiYuAct
function tbUi:UpdateFriendJiYuList()
	self.tbFriendList = {}
	local tbData = tbAct:GetFriendJiYuList()
	local tbIdx = {}
	for i = 1, 12 do
		table.insert(tbIdx, i)
	end
	if #tbData < 10 then
		tbIdx = Lib:RandomArray(tbIdx)
	end
	for i, nIdx in ipairs(tbIdx) do
		local nPlayerId = tbData[i]
		local tbRecord = FriendShip:GetFriendDataInfo(nPlayerId) or Kin:GetMemberData(nPlayerId)
		self.pPanel:SetActive("WishBar"..nIdx, tbRecord and true or false)
		if tbRecord then
			self.pPanel:Label_SetText("RoleName"..nIdx, tbRecord.szName)
			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRecord.nHonorLevel);
			self.pPanel:SetActive("RoleTitle" .. nIdx, ImgPrefix and true or false);
			if ImgPrefix then
				self.pPanel:Sprite_Animation("RoleTitle" .. nIdx, ImgPrefix, Atlas);
			end
			local szPortrait, szAtlas = PlayerPortrait:GetSmallIcon(tbRecord.nPortrait);
			self.pPanel:Sprite_SetSprite("SpRoleHead" .. nIdx, szPortrait, szAtlas);
			local szFaction = Faction:GetIcon(tbRecord.nFaction);
			self.pPanel:Sprite_SetSprite("SpFaction" .. nIdx, szFaction);
			self.tbFriendList[nIdx] = nPlayerId;
		end
	end
end

function tbUi:ReadFriendJiYu(nIdx)
	local nPlayerId = self.tbFriendList[nIdx]
	if not nPlayerId then
		return
	end
	tbAct:ReadPlayerJiYu(nPlayerId)
end

function tbUi:ReadRankBoardJiYu(nIdx)
	local nPlayerId = self.tbRankBoardPlayer[nIdx]
	if not nPlayerId then
		return
	end
	tbAct:ReadPlayerJiYu(nPlayerId)
end

function tbUi:ReadMyJiYu()
	tbAct:ReadPlayerJiYu(me.dwID)
end

function tbUi:OnDataUpdate(bUpdateFriendJiYuList)
	if bUpdateFriendJiYuList then
		self:UpdateFriendJiYuList()
	end
end

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_SYNC_RANKBOARD_DATA, self.OnSynRankData, self },
		{UiNotify.emNOTIFY_SYNC_DRINKTODREAM_DATA, self.OnDataUpdate, self },
	}
end