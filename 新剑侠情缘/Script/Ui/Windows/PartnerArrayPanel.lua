
local tbUi = Ui:CreateClass("PartnerArrayPanel");

function tbUi:OnOpenEnd(szDesc, fnCallback, ...)
	self.fnCallback = fnCallback;
	self.tbArg = {...};
	self.tbPartnerList, self.tbAllPartner = Partner:GetSortedPartnerList(me);
	RemoteServer.BattleArrayRequest();


	self.pPanel:SetActive("BtnFight", szDesc and true or false);
	if szDesc then
		self.pPanel:Button_SetText("BtnFight", szDesc)
	end
end

function tbUi:UpdatePartnerArrayInfo()
	if not self.bHasSyncArrayInfo then
		return;
	end

	self.tbPosInfo = me.GetPartnerPosInfo();
	for i = 1, 6 do
		local tbObj = self["PFace" .. i];
		tbObj:Clear();
		tbObj.pPanel:SetActive("Main", false);

		self.pPanel:Label_SetText("Name" .. i, "");
	end

	self.tbArrayInfo = AsyncBattle:GetBattleArray();
	for i = 1, 6 do
		local nIdx = self.tbArrayInfo[i] or -1;
		local tbObj = self["PFace" .. nIdx];

		if i == 1 then
			tbObj.pPanel:SetActive("Main", true);
			tbObj.pPanel:SetActive("Face", true);
			tbObj.pPanel:SetActive("GrowthLevel", false);
			local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(me.nPortrait);
			tbObj.pPanel:Sprite_SetSprite("Face", szIcon, szIconAtlas);
			self.pPanel:Label_SetText("Name" .. nIdx, me.szName);
		else
			local nPartnerId = self.tbPosInfo[i - 1];
			local tbPartner = self.tbAllPartner[nPartnerId];
			if tbPartner then
				tbObj.pPanel:SetActive("Main", true);
				tbObj:SetPartnerInfo(tbPartner);
				self.pPanel:Label_SetText("Name" .. nIdx, tbPartner.szName);
			end
		end
	end
end

function tbUi:CheckCanSetPos(nPartnerId, nPos)
	if self.bForbidenOperation then
		return false;
	end

	if not nPos or me.nLevel < Partner.tbPosNeedLevel[nPos] then
		return false, "上阵位已满";
	end

	if nPartnerId <= 0 then
		return true;
	end

	local tbPartner = me.GetPartnerInfo(nPartnerId);
	if not tbPartner then
		return false, "无效同伴";
	end

	local nTemplateId = tbPartner.nTemplateId;
	for i = 1, 4 do
		local nPPId = self.tbPosInfo[i];
		local tbPP = me.GetPartnerInfo(nPPId);
		if tbPP and tbPP.nTemplateId == nTemplateId then
			return false, "同类型同伴只能上阵一个";
		end
	end

	return true;
end

function tbUi:StartDragPartnerPos(nPos)
	local nPartnerId = self.tbPosInfo[nPos];
	local tbPartner = self.tbAllPartner[nPartnerId];
	if not tbPartner then
		return;
	end

	local nFaceId = KNpc.GetNpcShowInfo(tbPartner.nNpcTemplateId);
	local szAtlas, szSprite = Npc:GetFace(nFaceId);
	self.pPanel:StartDrag(szAtlas, szSprite);
end

function tbUi:StartDragPartnerArray(nPos)
	self.tbArrayInfo = AsyncBattle:GetBattleArray();
	local nIdx = 0;
	for i, nPosIdx in pairs(self.tbArrayInfo) do
		if nPosIdx == nPos then
			nIdx = i;
			break;
		end
	end

	if nIdx <= 0 then
		return;
	end

	if nIdx == 1 then
		local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(me.nPortrait);
		self.pPanel:StartDrag(szIconAtlas, szIcon);
		return;
	end

	self:StartDragPartnerPos(nIdx - 1);
end

function tbUi:ExchangePartnerArray(nPos1, nPos2)
	self.tbArrayInfo = AsyncBattle:GetBattleArray();
	local nIdx = 0;
	for i, nPosIdx in pairs(self.tbArrayInfo) do
		if nPosIdx == nPos1 then
			nIdx = i;
			break;
		end
	end

	if nIdx <= 0 then
		return;
	end

	AsyncBattle:SetBattleArray(nIdx, nPos2);
	self:UpdatePartnerArrayInfo();
end

function tbUi:OnSyncBattleArray()
	self.bHasSyncArrayInfo = true;
	self:UpdatePartnerArrayInfo();
end

function tbUi:OnClose()
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_BATTLEARRAY,		self.OnSyncBattleArray },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {}

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnFight = function (self)
	if self.fnCallback then
		if self.fnCallback(unpack(self.tbArg)) == 0 then
			return;
		end
	end
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnDrag = {}
tbUi.tbOnDrop = {}
tbUi.tbOnDragEnd = {};

for i = 1, 6 do
	tbUi.tbOnDrag["BPFace"..i] = function (self, ...)
		self:StartDragPartnerArray(i)
	end
	tbUi.tbOnDrop["BPFace"..i] = function (self, szWnd, szDropWnd)
		local nPos1 = string.match(szDropWnd, "BPFace(%d)");
		local nPos2 = string.match(szWnd, "BPFace(%d)");
		if nPos1 and nPos2 then
			self:ExchangePartnerArray(tonumber(nPos1), tonumber(nPos2));
		end
	end
end



