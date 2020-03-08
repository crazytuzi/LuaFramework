local tbUi = Ui:CreateClass("FactionMonkeyPanel");

function tbUi:OnOpen()
	if FactionBattle.FactionMonkey:IsMonkeyStarting() then
		FactionBattle.FactionMonkey:SynData()
	end
end

function tbUi:OnOpenEnd()
	self:RefreshUi()
end

function tbUi:RefreshUi()

	if not FactionBattle.FactionMonkey:IsMonkeyStarting() or not FactionBattle.FactionMonkey.tbMonkeyData.tbMonkey then
		return
	end

	local nMonkeySession = FactionBattle.FactionMonkey.tbMonkeyData.nMonkeySession + 1
	local szMonkeySession = Lib:Transfer4LenDigit2CnNum(nMonkeySession)
	local szFaction = Faction:GetName(me.nFaction) or ""

	local szTitle = string.format("第%s届%s大师兄/大师姐评选", szMonkeySession or "N",szFaction or "")

	self.pPanel:Label_SetText("Title", szTitle);

	local nRemainVote = FactionBattle:RemainVote(me)

	self.pPanel:SetActive("Tip", nRemainVote < 1);

	self.pPanel:SetActive("Tip2",false)
	
	self.pPanel:SetActive("PlayerTitle",false)
	local nHonorLevel = me.nHonorLevel or 0
	local nVoteScore = FactionBattle.tbHonorVoteScore[nHonorLevel] or 0
	local szTip = nHonorLevel > 0 and string.format("你当前的头衔是         ，可投[60f45f]%d[-]票",nVoteScore) or string.format("你当前的头衔是无，可投[60f45f]%d[-]票",nVoteScore)
	
	self.pPanel:SetActive("Tip2",nRemainVote > 0)
	self.pPanel:SetActive("PlayerTitle",nRemainVote > 0 and nHonorLevel > 0)

	self.pPanel:Label_SetText("Tip2", szTip);
	if nHonorLevel > 0 and nRemainVote > 0 then
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
	end

	local function fnClickVote(itemObj)

		local bRet,szMsg = FactionBattle.FactionMonkey:CheckVote()

		if not bRet then
			me.CenterMsg(szMsg);
			return
		end

		RemoteServer.VoteMonkey(itemObj.nPlayerId);
	end
	local function fnClickInfo(itemObj)
		ViewRole:OpenWindow("ViewRolePanel", itemObj.nPlayerId)
	end

	local fnSetItem = function(itemObj,nIdx)

		local tbMonkeyInfo = FactionBattle.FactionMonkey.tbMonkeyData.tbMonkey[nIdx]
		local szName = tbMonkeyInfo.szName
		local nPlayerId = tbMonkeyInfo.nPlayerId
		local nScore = tbMonkeyInfo.nScore
		local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbMonkeyInfo.nBigFace, tbMonkeyInfo.nPortrait, 
			tbMonkeyInfo.nFaction, tbMonkeyInfo.nSex);

		local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace)
  		itemObj.pPanel:Sprite_SetSprite("head1", szBigIcon, szBigIconAtlas)

		itemObj.pPanel:Label_SetText("Name", szName);
		itemObj.pPanel:Label_SetText("Vote", "当前票数：" ..nScore .."票");

		itemObj.pPanel:SetActive("BtnVote",nRemainVote > 0)

		itemObj["BtnVote"].nPlayerId = nPlayerId
		itemObj.BtnCheck.nPlayerId = nPlayerId

		itemObj["BtnVote"].pPanel.OnTouchEvent = fnClickVote
		itemObj.BtnCheck.pPanel.OnTouchEvent = fnClickInfo
	end

	self.ScrollViewVoteItem:Update(#FactionBattle.FactionMonkey.tbMonkeyData.tbMonkey,fnSetItem);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_ONSYNC_MONKEY,   self.RefreshUi, self },
    };

    return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}


------------------------------------最新消息------------------------------------------

local nNumPerRow = 2;

local tbNewInfoUi = Ui:CreateClass("NewInfo_FactionMonkey")
function tbNewInfoUi:OnOpen(tbData)
	if not tbData then
		return
	end
	self:RefreshUi(tbData)
end

function tbNewInfoUi:RefreshUi(tbData)
	local nMonkeySession = tbData.nMonkeySession
	self.tbMonker = FactionBattle.FactionMonkey:ManageMonkey(tbData.tbMonkey)
	local szMonkeySession = Lib:Transfer4LenDigit2CnNum(nMonkeySession)
	self.pPanel:Label_SetText("ElectionNumber", (szMonkeySession or "N"));

	local fnSetItem = function(itemObj,nIdx)
		local nCur = (nIdx - 1) * nNumPerRow + 1;
		local nStep = nCur + nNumPerRow - 1;
		local tbRowList = self:UpdateRowInfo(nCur,nStep);
		self:SetItem(itemObj, nIdx, tbRowList);
	end

	local nRow = math.ceil(#self.tbMonker/nNumPerRow)

	self.ScrollViewElectionItem:Update(nRow,fnSetItem);
end

function tbNewInfoUi:UpdateRowInfo(nCur,nStep)
	local tbRowList = {};
	for index = nCur,nStep do
		if self.tbMonker[index] then
			table.insert(tbRowList,self.tbMonker[index]);
		end
	end
	return tbRowList;
end

function tbNewInfoUi:SetItem(itemObj, index, tbRowList)
	local function fnClickInfo(itemObj)
		ViewRole:OpenWindow("ViewRolePanel", itemObj.nPlayerId)
	end
	for i,tbInfo in ipairs(tbRowList) do
		if tbInfo then

			local nFaction = tbInfo.nFaction
			local szName = tbInfo.szName
			local nLevel = tbInfo.nLevel
			local nFightPower = tbInfo.nFightPower
			local nHonorLevel = tbInfo.nHonorLevel
			local nPortrait = tbInfo.nPortrait
			local nBigFace = tbInfo.nBigFace
			local szKinName = tbInfo.szKinName
			local nPlayerId = tbInfo.nPlayerId
			local nSex = tbInfo.nSex or 0

			local szFaction = Faction:GetName(nFaction) or ""
			local szMonkey = nSex == Player.SEX_MALE and "大师兄" or "大师姐"

			itemObj["FactionInfo" .. i].pPanel:Label_SetText("Faction", (szFaction  ..szMonkey));

			local SpFaction = Faction:GetIcon(nFaction)
			itemObj["FactionInfo" .. i].pPanel:Sprite_SetSprite("FactionIcon",  SpFaction);

			local nTmpBigFace = PlayerPortrait:CheckBigFaceId(nBigFace, nPortrait, nFaction, nSex);
			local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace);
  			itemObj["FactionInfo" .. i].pPanel:Sprite_SetSprite("Role", szBigIcon, szBigIconAtlas)

			itemObj["FactionInfo" .. i].pPanel:Label_SetText("PlayerName", szName);
			itemObj["FactionInfo" .. i].pPanel:Label_SetText("FamilyName", szKinName);
			itemObj["FactionInfo" .. i].pPanel:Label_SetText("Level", nLevel);
			itemObj["FactionInfo" .. i].pPanel:Label_SetText("Fight", nFightPower);

			itemObj["FactionInfo" .. i].pPanel:SetActive("PlayerTitle", nHonorLevel > 0);

			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
			itemObj["FactionInfo" .. i].pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
			itemObj["FactionInfo" .. i]["BtnCheck"].nPlayerId = nPlayerId
			itemObj["FactionInfo" .. i]["BtnCheck"].pPanel.OnTouchEvent = fnClickInfo

		end
	end
	self:CheckObj(itemObj,tbRowList);
end

function tbNewInfoUi:CheckObj(itemObj,tbRowList)
	local rowNum = #tbRowList;
	if rowNum < nNumPerRow then
		rowNum = rowNum + 1;
		for i = rowNum,nNumPerRow do
			itemObj.pPanel:SetActive("FactionInfo" .. i, false);
		end
	end
end