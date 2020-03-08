local tbUi = Ui:CreateClass("LoverRecommondPanel");
function tbUi:OnOpen()
	LoverTask:SynRecommondLover()
end

function tbUi:Update(tbRecommondPlayer)
	self.tbRecommondPlayer = tbRecommondPlayer or {}
	self.nChoose = self.nChoose or 1
	if not self.tbRecommondPlayer[self.nChoose] then
		self.nChoose = nil
	end
	for i = 1, LoverTask.nRecommondLoverCount do
		local tbPlayerInfo = self.tbRecommondPlayer[i]
		local szName = tbPlayerInfo and tbPlayerInfo.szName or ""
		local nLevel = tbPlayerInfo and tbPlayerInfo.nLevel or 0
		local nSex = tbPlayerInfo and tbPlayerInfo.nSex or 0
		local nFaction = tbPlayerInfo and tbPlayerInfo.nFaction or 0
		local nPortrait = tbPlayerInfo and tbPlayerInfo.nPortrait or 0
		local nBigFace = tbPlayerInfo and tbPlayerInfo.nBigFace or 0
		self.pPanel:Label_SetText("Name" ..i, szName)
		self.pPanel:Label_SetText("Level" ..i, nLevel)
		local nTmpBigFace = PlayerPortrait:CheckBigFaceId(nBigFace, nPortrait, nFaction, nSex);
		if nTmpBigFace > 0 then
			local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace)
			self.pPanel:Sprite_SetSprite("head" ..i, szBigIcon, szBigIconAtlas);
		end
		if nFaction > 0 then
			local szFactionIcon = Faction:GetIcon(nFaction);
			self.pPanel:Sprite_SetSprite("Faction" ..i, szFactionIcon);
		end
		self.pPanel:SetActive("Player" ..i, tbPlayerInfo and true or false)
	end
	self:OnBtnPlayer(self.nChoose)
end

tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnChange()
	LoverTask:ChangeRecommondLover()
end

function tbUi.tbOnClick:BtnSend()
	local nPlayerId = self.tbRecommondPlayer[self.nChoose] and self.tbRecommondPlayer[self.nChoose].dwID
	local szName = self.tbRecommondPlayer[self.nChoose] and self.tbRecommondPlayer[self.nChoose].szName
	if not nPlayerId or not szName then
		me.CenterMsg("请选择一个玩家", true)
		return
	end
	local tbData = 
	{
		szName = szName;
	}
	ChatMgr:OpenPrivateWindow(nPlayerId, tbData)
end

function tbUi.tbOnClick:BtnAddFriend()
	local nPlayerId = self.tbRecommondPlayer[self.nChoose] and self.tbRecommondPlayer[self.nChoose].dwID
	local szName = self.tbRecommondPlayer[self.nChoose] and self.tbRecommondPlayer[self.nChoose].szName
	if not nPlayerId or not szName then
		me.CenterMsg("请选择一个玩家", true)
		return
	end
	RemoteServer.RequestAddFriend(nPlayerId)
end

function tbUi:OnBtnPlayer(nIdx)
	for i=1, LoverTask.nRecommondLoverCount do
		self.pPanel:SetActive("ChooseMark" ..i, nIdx == i)
	end
	self.nChoose = nIdx

	local nPlayerId = self.nChoose and self.tbRecommondPlayer[self.nChoose] and self.tbRecommondPlayer[self.nChoose].dwID
	local bIsFriend 
	if nPlayerId then
		bIsFriend = FriendShip:IsFriend(me.dwID, nPlayerId)
	end
	self.pPanel:SetActive("BtnAddFriend", not bIsFriend)
end

for i = 1, LoverTask.nRecommondLoverCount do
	tbUi.tbOnClick["Player" .. i] = function (self)
		self:OnBtnPlayer(i)
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_RECOMMOND_LOVER, self.Update, self},
	};

	return tbRegEvent;
end