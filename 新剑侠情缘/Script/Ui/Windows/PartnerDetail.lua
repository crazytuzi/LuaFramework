local tbMainPartnerInfoUi = Ui:CreateClass("PartnerMainPanel");
local tbUi = Ui:CreateClass("PartnerDetail");

local tbSeries = {
	"Gold",
	"Wood",
	"Water",
	"Fire",
	"Earth",
}

local tbPartnerStory = {};
local function LoadPartnerStory()
	local tbFile = LoadTabFile("Setting/Partner/PartnerStory.tab", "ds", nil, {"nPartnerId", "szStory"});
	for _, tbInfo in pairs(tbFile or {}) do
		tbPartnerStory[tbInfo.nPartnerId] = tbInfo.szStory;
	end
end
LoadPartnerStory();

function tbUi:OnOpen(tbPartnerInfo, tbAttribInfo, tbSkillInfo, nPartnerId, tbPartnerList, tbAddAttribInfo, tbExtActiveSkillId)
	self.nPartnerId = nil;

	self.tbAddAttribInfo = tbAddAttribInfo;
	self.tbAttribInfo = tbAttribInfo and Lib:CopyTB(tbAttribInfo) or nil;
	self.tbSkillInfo = tbSkillInfo and Lib:CopyTB(tbSkillInfo) or nil;
	self.tbPartnerInfo = tbPartnerInfo and Lib:CopyTB(tbPartnerInfo) or nil;
	self.tbExtActiveSkillId = tbExtActiveSkillId or {}
	if nPartnerId then
		self.nPartnerId = nPartnerId;
	end

	if self.tbPartnerInfo then
		local szName, nQualityLevel, nNpcTemplateId, nGrowthType, nSeries = GetOnePartnerBaseInfo(self.tbPartnerInfo.nTemplateId, self.tbPartnerInfo.nIsNormal == 1 and 0 or 1);
		self.tbPartnerInfo.szName = szName;
		self.tbPartnerInfo.nQualityLevel = nQualityLevel;
		self.tbPartnerInfo.nNpcTemplateId = nNpcTemplateId;
		self.tbPartnerInfo.nGrowthType = nGrowthType;
		self.tbPartnerInfo.nSeries = nSeries;

		local tbProtentialInfo = {};
		for _, szType in pairs(Partner.tbAllProtentialType) do
			tbProtentialInfo[szType] = self.tbPartnerInfo["nProtential" .. szType];
		end

		local tbSkillInfo = {};
		for _, tbSkill in pairs(self.tbSkillInfo.tbNormalSkill) do
			if tbSkill.nSkillId > 0 then
				tbSkillInfo[tbSkill.nSkillId] = math.max(tbSkill.nSkillLevel, 1);
			end
		end

		local _, nStarLevel = Partner:GetStarValue(self.tbPartnerInfo.nFightPower);
		self.tbSkillInfo.tbDefaultSkill[2].nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;
	end

	self.nIndex = nil;
	if tbPartnerList and #tbPartnerList > 0 then
		self.tbPartnerList = tbPartnerList;

		for nIndex, nPId in pairs(tbPartnerList or {}) do
			if nPartnerId and nPId == nPartnerId then
				self.nIndex = nIndex;
				break;
			end
		end

		self.nIndex = self.nIndex or 1;
		self.nPartnerId = tbPartnerList[self.nIndex];
	end

	self:Update();
	self.pPanel:Button_SetCheck("BtnAttribInfo", false);
	self:UpdatePanel();
	self.pPanel:SetActive("BtnLeft", self.nIndex and true or false);
	self.pPanel:SetActive("BtnRight", self.nIndex and true or false);
	self.pPanel:SetActive("Meridian", tbAddAttribInfo and true or false);
end

function tbUi:Update()
	if self.nPartnerId then
		local _, nQualityLevel, _, nGrowthType = GetOnePartnerBaseInfo(self.nPartnerId);
		local nAwareness = Partner:GetPartnerAwareness(me, self.nPartnerId);
		local tbData = {
			bIsBY = false;
			nSkillCount = 0;
			tbSkillInfo = {};
			nVitality = 0;
			nDexterity = 0;
			nStrength = 0;
			nEnergy = 0;
			nLimitVitality = 5;
			nLimitDexterity = 5;
			nLimitStrength = 5;
			nLimitEnergy = 5;
			nAwareness = nAwareness;
		};
		for nType, szType in pairs(Partner.tbAllProtentialType) do
			local nLimitValue = Partner:GetLimitProtentialValue(nQualityLevel, nGrowthType, nType, 5, 1, nAwareness);
			tbData["n" .. szType] = nLimitValue * Partner.tbProtentialToValue[nQualityLevel];
		end

		self.tbPartnerInfo, self.tbAttribInfo, self.tbSkillInfo = me.GetPartnerOriginalInfo(self.nPartnerId, 0, tbData);
		self.tbPartnerInfo.nAwareness = Partner:GetPartnerAwareness(me, self.tbPartnerInfo.nTemplateId);
		self.tbSkillInfo.tbNormalSkill = {};
	end

	self:DoUpdateCallPartnerInfo();

	local tbSkillInfo = FightSkill:GetSkillSetting(self.tbSkillInfo.tbDefaultSkill[1].nSkillId);
	self.pPanel:Label_SetText("CompanionPersonality", string.format("同伴个性：%s", tbSkillInfo.SkillName or ""));
	self.pPanel:Label_SetText("PersonalityDescribe", string.format("%s", tbSkillInfo.Desc or ""));

	self.pPanel:Label_SetText("Name", self.tbPartnerInfo.szName);
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%d级", self.tbPartnerInfo.nLevel));
	else
		self.pPanel:Label_SetText("Level", string.format("Lv.%d", self.tbPartnerInfo.nLevel));
	end

	self.pPanel:Sprite_SetSprite("QualityMark", self.tbPartnerInfo.nIsNormal == 1 and "_____" or "Quality_Special");
	self.pPanel:SetActive("QualityMark2", (self.tbPartnerInfo.nAwareness and self.tbPartnerInfo.nAwareness == 1) and true or false);
	if self.tbPartnerInfo.nIsNormal ~= 1 then
		self.pPanel:ChangePosition("QualityMark", -53, 229);
		self.pPanel:ChangePosition("QualityMark2", -53, 126);
	else
		self.pPanel:ChangePosition("QualityMark2", -53, 229);
	end

	self.pPanel:Sprite_SetSprite("Quality", Partner.tbQualityLevelToSpr[self.tbPartnerInfo.nQualityLevel]);
	self.pPanel:Label_SetText("Characteristic", Partner:GetGrowthTypeByTemplateId(self.tbPartnerInfo.nTemplateId or 0));
	self.pPanel:Label_SetText("FightValue", "战力  " .. self.tbPartnerInfo.nFightPower);
	self.pPanel:SetActive("BtnStory", tbPartnerStory[self.tbPartnerInfo.nTemplateId or 0] and true or false);
	for i = 1, 5 do
		self.pPanel:SetActive(tbSeries[i], i == self.tbPartnerInfo.nSeries);
	end

	local _, nResId = KNpc.GetNpcShowInfo(self.tbPartnerInfo.nNpcTemplateId);
	Ui.CameraMgr.LeaveCameraAnimationState();
	self.pPanel:NpcView_Open("PartnerView");
	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	self.pPanel:NpcView_SetWeaponState("PartnerView", self.tbPartnerInfo.nWeaponState);
	self.pPanel:NpcView_SetAnimationSpeed("PartnerView", 0.5);

	if not self.bChangeDir then
		self.pPanel:NpcView_ChangeDir("PartnerView", -20, true)
	end

	if self.tbPartnerInfo.nAwareness and self.tbPartnerInfo.nAwareness == 1 then
		self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, Partner:GetAwareness(self.tbPartnerInfo.nTemplateId).nUiEffectId);
	else
		self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, 0);
	end

	self:UpdateAttribInfo();
	self:UpdateSkillInfo();

	if Ui.bShowDebugInfo then
		Ui:SetDebugInfo("dwTemplateId: " .. self.tbPartnerInfo.nTemplateId);
	end


end

function tbUi:DoUpdateCallPartnerInfo()
	local bHas = me.GetUserValue(Partner.PARTNER_HAS_GROUP, self.tbPartnerInfo.nTemplateId);
	self.pPanel:SetActive("SeveranceItem", self.nPartnerId and bHas == 1);
	self.pPanel:SetActive("Btnrecruit", self.nPartnerId and bHas == 1);

	if bHas == 1 and self.nPartnerId then
		local nItemCount = me.GetItemCountInAllPos(Partner.nSeveranceItemId);
		self.SeveranceItem:SetGenericItem({"item", Partner.nSeveranceItemId, 0});
		self.SeveranceItem.fnClick = self.SeveranceItem.DefaultClick;

		local nCostCount = Partner.tbCallPartnerCost[self.tbPartnerInfo.nQualityLevel];
		self.SeveranceItem.pPanel:SetActive("LabelSuffix", true);

		local szCountInfo = string.format("%s/%s", nItemCount, nCostCount);
		if nItemCount < nCostCount then
			szCountInfo = string.format("[FF0000FF]%s[-]", szCountInfo);
		end
		self.bCanCallPartner = nItemCount >= nCostCount;
		self.SeveranceItem.pPanel:Label_SetText("LabelSuffix", szCountInfo);
	end

	local nCardId = PartnerCard:GetCardIdByPartnerTempleteId(self.tbPartnerInfo.nTemplateId) or 0 
	local bHaveCard = PartnerCard:IsHaveCard(me, nCardId)
	local nItemId, nConsumeCount = PartnerCard:GetAddCardCostItem(nCardId)
	local bCan = PartnerCard:CheckCanRepeatAdd(me, nCardId)
	local bOp = self.nPartnerId and PartnerCard:CheckCardOpen(nCardId) and nCardId > 0 and not bHaveCard and nItemId and bCan and PartnerCard:IsOpen()
	self.pPanel:SetActive("BtnGuest", bOp);
	self.pPanel:SetActive("GuestItem", bOp);
	self.pPanel:SetActive("BtnPreview", (nCardId and PartnerCard:IsOpen()) and true or false);
	if bOp then
		local nItemCount = me.GetItemCountInAllPos(nItemId);
		self.GuestItem:SetGenericItem({"item", nItemId, 0});
		self.GuestItem.fnClick = self.GuestItem.DefaultClick;

		self.GuestItem.pPanel:SetActive("LabelSuffix", true);

		local szCountInfo = string.format("%s/%s", nItemCount, nConsumeCount);
		if nItemCount < nConsumeCount then
			szCountInfo = string.format("[FF0000FF]%s[-]", szCountInfo);
		end
		self.GuestItem.pPanel:Label_SetText("LabelSuffix", szCountInfo);
	end
end

function tbUi:OnClose()
	if not self.bChangeDir then
		self.pPanel:NpcView_ChangeDir("PartnerView", 20, true);
	end

	self.pPanel:NpcView_Close("PartnerView");
	Ui:SetDebugInfo("");
end

function tbUi:OnSyncItem()
	self:DoUpdateCallPartnerInfo();
end

function tbUi:UpdateAttribInfo()
	tbMainPartnerInfoUi.SubUpdateAttribInfoPanel(self, self.tbPartnerInfo, self.tbSkillInfo, self.tbAttribInfo);
end

function tbUi:UpdateSkillInfo()
	tbMainPartnerInfoUi.SubUpdateQualitySkill(self, self.tbPartnerInfo, self.tbSkillInfo, self.tbAttribInfo);
end

function tbUi:OnClickSkill(nIdx)
	tbMainPartnerInfoUi.OnClickSkill(self, nIdx, self.tbExtActiveSkillId);
end

function tbUi:UpdatePanel()
	local bCheck = self.pPanel:Button_GetCheck("BtnAttribInfo");
	self.pPanel:SetActive("QualitySkill", not bCheck);
	self.pPanel:SetActive("AttribInfoPanel", bCheck);
	if bCheck then
		self:UpdateAttribInfo();
	else
		self:UpdateSkillInfo();
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnAttribInfo()
	self:UpdatePanel();
end

tbUi.tbOnClick.BtnLeft = function (self)
	self.nIndex = self.nIndex or 1;
	self.nIndex = self.nIndex - 1;
	if self.nIndex <= 0 then
		self.nIndex = #self.tbPartnerList;
	end
	self.nIndex = math.min(self.nIndex, #self.tbPartnerList);
	self.nPartnerId = self.tbPartnerList[self.nIndex];
	self:Update();
end

tbUi.tbOnClick.BtnRight = function (self)
	self.nIndex = self.nIndex or 1;
	self.nIndex = self.nIndex + 1;
	if self.nIndex > #self.tbPartnerList then
		self.nIndex = 1;
	end
	self.nIndex = math.max(self.nIndex, 1);
	self.nPartnerId = self.tbPartnerList[self.nIndex];
	self:Update();
end

tbUi.tbOnClick.BtnStory = function (self)
	local szStory = tbPartnerStory[self.tbPartnerInfo.nTemplateId or 0];
	if not szStory then
		return;
	end

	Ui:OpenWindow("PartnerStoryPanel", szStory);
end

tbUi.tbOnClick.Btnrecruit = function (self)
	if not self.bCanCallPartner then
		MarketStall:TipBuyItemFromShop(me, Partner.nSeveranceItemId);
		return;
	end
	local nTemplateId = self.tbPartnerInfo.nTemplateId
	local fnAgree = function ()
		RemoteServer.CallPartnerFunc("CallPartner", nTemplateId);
	end
	if PartnerCard:IsOpen() then
		me.MsgBox(string.format("您当前招募的为[FFFE0D]同伴[-]%s，是否确定？\n（注意招募的[FFFE0D]不是门客[-]哦） ", self.tbPartnerInfo.szName or ""), {{"确定", fnAgree}, {"取消"}})
		return 
	end
	RemoteServer.CallPartnerFunc("CallPartner", nTemplateId);
end

tbUi.tbOnClick.Meridian = function (self)
	Ui:OpenWindow("JingMaiTipsPanel", self.tbAddAttribInfo.tbExtPartnerAttrib, self.tbAddAttribInfo.tbPartnerSkill);
end

tbUi.tbOnClick.BtnPreview = function (self)
	local nCardId = PartnerCard:GetCardIdByPartnerTempleteId(self.tbPartnerInfo.nTemplateId) or 0
	if nCardId > 0 then
		Ui:OpenWindow("PartnerCardDetailTip", nCardId);
	else
		me.CenterMsg("没有门客", true)
	end
end

tbUi.tbOnClick.BtnGuest = function (self)
	local nCardId = PartnerCard:GetCardIdByPartnerTempleteId(self.tbPartnerInfo.nTemplateId) or 0
	if nCardId > 0 then
		local bRet, szMsg, nItemId = PartnerCard:CanAddCard(me, nCardId)
		if not bRet then
			if nItemId then
				MarketStall:TipBuyItemFromShop(me, nItemId, szTipsInfo)
			else
				me.CenterMsg(szMsg, true)
			end
			return
		end
		RemoteServer.PartnerCardOnClientCall("AddCard", nCardId)
	else
		me.CenterMsg("没有门客", true)
	end
end

for i = 2, 8 do
	tbUi.tbOnClick["Skill" .. i] = function (self)
		self:OnClickSkill(i);
	end
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("PartnerDetail");
end

tbUi.tbOnDrag =
{
	PartnerView = function (self, szWnd, nX, nY)
		self.bChangeDir = true;
		self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
	end,
}

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_ITEM,				self.OnSyncItem},
		{ UiNotify.emNOTIFY_DEL_ITEM,				self.OnSyncItem},
		{ UiNotify.emNOTIFY_PARTNER_CARD_ADD,		self.DoUpdateCallPartnerInfo, self},
	};

	return tbRegEvent;
end