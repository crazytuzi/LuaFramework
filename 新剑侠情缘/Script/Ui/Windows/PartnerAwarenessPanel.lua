
local tbUi = Ui:CreateClass("PartnerAwarenessPanel");
local tbSeries = {
	"Gold",
	"Wood",
	"Water",
	"Fire",
	"Earth",
}
function tbUi:OnOpen(nPartnerId)
	self.tbPartner = me.GetPartnerInfo(nPartnerId or 0);
	if not self.tbPartner then
		me.CenterMsg("不存在的同伴");
		return 0;
	end

	if not Partner:GetAwareness(self.tbPartner.nTemplateId) then
		me.CenterMsg("此同伴无法觉醒");
		return 0;
	end

	self.tbSelectInfo = {};

	self.pPanel:NpcView_Open("PartnerView");

	self.tbPartner.nAwareness = Partner:GetPartnerAwareness(me, self.tbPartner.nTemplateId);
	self.pPanel:Button_SetEnabled("BtnAwaken", self.tbPartner.nAwareness ~= 1);
	self.pPanel:Label_SetText("TxtAwaken", self.tbPartner.nAwareness ~= 1 and "觉醒" or "已觉醒");
	self.pPanel:SetActive("AwakenTip", self.tbPartner.nAwareness == 1);
	self.pPanel:SetActive("PosGroup", self.tbPartner.nAwareness ~= 1);

	self.nPartnerId = nPartnerId;

	self.pPanel:SetActive("Select1", false);
	self.pPanel:SetActive("Select2", true);

	self:UpdatePartnerInfo(true);
	self:UpdateAttribInfo();
	self:UpdateNeedInfo();
end

function tbUi:UpdatePartnerInfo(bAwareness)
	self.pPanel:Sprite_SetSprite("QualityIcon", Partner.tbQualityLevelToSpr[self.tbPartner.nQualityLevel]);
	for i = 1, 5 do
		self.pPanel:SetActive(tbSeries[i], i == self.tbPartner.nSeries);
	end

	self.pPanel:SetActive("PMark1", self.tbPartner.nIsNormal ~= 1 and true or false);
	self.pPanel:SetActive("PMark2", bAwareness and true or false);
	if self.tbPartner.nIsNormal ~= 1 then
		self.pPanel:ChangePosition("PMark1", -168,171);
		self.pPanel:ChangePosition("PMark2", -168,68);
	else
		self.pPanel:ChangePosition("PMark2", -168,171);
	end

	local _, nResId = KNpc.GetNpcShowInfo(self.tbPartner.nNpcTemplateId);

	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	if bAwareness then
		self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, Partner:GetAwareness(self.tbPartner.nTemplateId).nUiEffectId);
	else
		self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, 0);
	end

	self.pPanel:NpcView_SetWeaponState("PartnerView", self.tbPartner.nWeaponState);
end

function tbUi:UpdateAttribInfo()
	local pPartner = me.GetPartnerObj(self.nPartnerId);
	local tbData = Partner:GetPartnerData(pPartner);
	tbData.nAwareness = 0;
	self.tbPartner.nAwareness = 0;
	local tbPInfo, tbPAttribInfo, tbPSInfo = me.GetPartnerOriginalInfo(pPartner.nTemplateId, tbData.bIsBY and 1 or 0, tbData);
	local tbValue = Partner:GetAttribShowInfo(tbPAttribInfo, self.tbPartner);
	for i = 1, 4 do
		local tbInfo = tbValue[i] or {tbValue = {0, 0}, nMaxValue = 0, nValue = 0, nLimitLevel = 0};
		self.pPanel:Label_SetText("QualityPercent1" .. i, string.format("%s / %s", tbInfo.tbValue[1], tbInfo.tbValue[2]));
		self.pPanel:Sprite_SetFillPercent("QualityBar1" .. i, tbInfo.nValue);
		self.pPanel:Label_SetText("Character1" .. i, Partner.tbPartnerLimitLevelDesc[tbInfo.nLimitLevel] or "--");
	end

	local nSkillId= tbPSInfo.tbDefaultSkill[2].nSkillId;
	local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
	if tbValue then
		local tbInfo = Partner:GetSkillInfoBySkillId(nSkillId) or {};
		local szFrameColor = Partner.tbSkillColor[tbInfo.nQuality or 1] or "";
		self.pPanel:Sprite_SetSprite("Skill1", tbValue.szIconSprite, tbValue.szIconAtlas);
		self.pPanel:Sprite_SetSprite("Color1", szFrameColor);
	end
	self.pPanel:Label_SetText("FightValue1", string.format("战力  %s", tbPInfo.nFightPower))

	tbData.nAwareness = 1;
	self.tbPartner.nAwareness = 1;
	tbPInfo, tbPAttribInfo, tbPSInfo = me.GetPartnerOriginalInfo(pPartner.nTemplateId, tbData.bIsBY and 1 or 0, tbData);
	tbValue = Partner:GetAttribShowInfo(tbPAttribInfo, self.tbPartner);

	for i = 1, 4 do
		local tbInfo = tbValue[i] or {tbValue = {0, 0}, nMaxValue = 0, nValue = 0, nLimitLevel = 0};
		self.pPanel:Label_SetText("QualityPercent2" .. i, string.format("[62f550]%s[-] / [62f550]%s[-]", tbInfo.tbValue[1], tbInfo.tbValue[2]));
		self.pPanel:Sprite_SetFillPercent("QualityBar2" .. i, tbInfo.nValue);
		self.pPanel:Label_SetText("Character2" .. i, "[62f550]" .. (Partner.tbPartnerLimitLevelDesc[tbInfo.nLimitLevel] or "--") .. "[-]");
	end

	nSkillId = tbPSInfo.tbDefaultSkill[2].nSkillId;
	local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
	if tbValue then
		local tbInfo = Partner:GetSkillInfoBySkillId(nSkillId) or {};
		local szFrameColor = Partner.tbSkillColor[tbInfo.nQuality or 1] or "";
		self.pPanel:Sprite_SetSprite("Skill2", tbValue.szIconSprite, tbValue.szIconAtlas);
		self.pPanel:Sprite_SetSprite("Color2", szFrameColor);
	end
	self.pPanel:Label_SetText("FightValue2", string.format("战力  %s", tbPInfo.nFightPower))
end

function tbUi:OnClickSkill(bAwareness)
	local pPartner = me.GetPartnerObj(self.nPartnerId);
	local tbData = Partner:GetPartnerData(pPartner);
	tbData.nAwareness = bAwareness and 1 or 0;

	local tbPInfo, _, tbPSInfo = me.GetPartnerOriginalInfo(pPartner.nTemplateId, tbData.bIsBY and 1 or 0, tbData);

	local _, nStarLevel = Partner:GetStarValue(tbPInfo.nFightPower);
	local nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;

	tbPInfo.nAwareness = bAwareness and 1 or 0;
	local nMaxFightPower = Partner:GetMaxFightPower(tbPInfo);
	local _, nMaxStar = Partner:GetStarValue(nMaxFightPower);
	local nMaxLevel = math.max(Partner.tbFightPowerToSkillLevel[nMaxStar] or 1, nSkillLevel);
	Partner:ShowSkillTips(tbPSInfo.tbDefaultSkill[2].nSkillId, nSkillLevel, nMaxLevel);
end

function tbUi:UpdateNeedInfo()
	local tbNeedInfo = Partner:GetAwareness(self.tbPartner.nTemplateId);

	self.tbSelectInfo = self.tbSelectInfo or {};
	local tbUsed = {};
	tbUsed[self.nPartnerId] = true;
	local tbPos = me.GetPartnerPosInfo();
	for _, nPId in pairs(self.tbSelectInfo) do
		tbUsed[nPId] = true;
	end

	for _, nPartnerId in pairs(tbPos) do
		if nPartnerId > 0 then
			tbUsed[nPartnerId] = true;
		end
	end

	local tbWeaponState = {};
	local tbAllPartner = me.GetAllPartner();
	for i = 1, 5 do
		local nNeedPartnerId = tbNeedInfo["nCost" .. i];
		local tbCanUse, tbOther, bHasWeapon = self:GetAwarenessCanUsePartner(nNeedPartnerId, false);
		local nCurPId = ((tbCanUse or tbOther or {})[1] or {})[1];
		if not self.tbSelectInfo[i] and nCurPId then
			self.tbSelectInfo[i] = nCurPId;
			tbUsed[nCurPId] = true;
		end
		tbWeaponState[nNeedPartnerId] = bHasWeapon;
	end

	local nWeaponCount = 0;
	for i = 1, 5 do
		local nNeedPartnerId = tbNeedInfo["nCost" .. i];
		local szName, nQualityLevel, nNpcTemplateId = GetOnePartnerBaseInfo(nNeedPartnerId);

		local nPId = self.tbSelectInfo[i];
		local tbObj = self["Pos" .. i];

		tbObj:Clear();

		if nPId then
			tbObj:SetPlayerPartner(nPId);
			tbObj.pPanel.OnTouchEvent = function (itemObj)
				self:OnClickPartner(i, nNeedPartnerId, tbNeedInfo.bNeedWeapon, true);
			end
		else
			tbObj:SetPartnerById(nNeedPartnerId);
			tbObj.pPanel.OnTouchEvent = function (itemObj)
				me.MsgBox(string.format("当前未上阵的同伴中没有[FFFE0D]%s[-]", szName), {{"前往招募", function ()
					local nHas = me.GetUserValue(Partner.PARTNER_HAS_GROUP, nNeedPartnerId);
					if nHas == 1 then
						Ui:OpenWindow("PartnerDetail", nil, nil, nil, nNeedPartnerId);
					else
						Ui:OpenWindow("Partner", "CardPickingPanel");
					end
				end}, {"暂不招募"}});
			end;

			local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
			local szAtlas, szSprite = Npc:GetFace(nFaceId);
			tbObj.pPanel:Sprite_SetSpriteGray("Face", szSprite, szAtlas);
		end


		tbObj.pPanel:SetActive("Weapon", tbNeedInfo.bNeedWeapon and true or false);
		if tbNeedInfo.bNeedWeapon then
			local bHasWeapon = tbWeaponState[nNeedPartnerId];
			if not bHasWeapon then
				local tbInfo  = tbAllPartner[nPId or -1];
				if tbInfo and tbInfo.nWeaponState == 1 then
					bHasWeapon = true;
				end
			end
			tbObj.pPanel:Sprite_SetGray("Weapon", not bHasWeapon);
			nWeaponCount = nWeaponCount + (bHasWeapon and 1 or 0);
		end

		tbObj.pPanel:Label_SetText("Name", szName);
	end

	self.pPanel:Label_SetText("AwakenNeedTxt",
		string.format("下列[%s]（%s/5名）[-]%s级同伴%s",
						Lib:CountTB(self.tbSelectInfo) == 5 and "00FF00" or "FFFFFF",
						Lib:CountTB(self.tbSelectInfo),
						Partner.tbQualityLevelDes[self.tbPartner.nQualityLevel + 1],
						tbNeedInfo.bNeedWeapon and string.format("及其对应的[%s]（%s/5个）[-]本命武器", nWeaponCount == 5 and "00FF00" or "FFFFFF", nWeaponCount) or ""
						));

	self.AwakenNeedItem:SetGenericItemTemplate(Partner.nPartnerAwarenessCostItem, 0);
	self.AwakenNeedItem.pPanel:SetActive("LabelSuffix", true);

	local nCount = me.GetItemCountInBags(Partner.nPartnerAwarenessCostItem);
	local szInfo = string.format("%s/%s", nCount, tbNeedInfo.nNeedSeveranceItem);
	if nCount < tbNeedInfo.nNeedSeveranceItem then
		szInfo = "[FF0000FF]".. szInfo .. "[-]";
	end
	self.AwakenNeedItem.pPanel:Label_SetText("LabelSuffix", szInfo);

	local szItemName = Item:GetItemTemplateShowInfo(Partner.nPartnerAwarenessCostItem);
	self.pPanel:Label_SetText("ItemName", szItemName);
	self.AwakenNeedItem.fnClick = self.AwakenNeedItem.DefaultClick;
end

function tbUi:GetAwarenessCanUsePartner(nPartnerTemplateId, bNeedWeapon)
	local tbAllPartner = me.GetAllPartner();
	local tbCanUsePartner;
	local tbOtherPartner;

	local nWeaponItemId = Partner.tbPartner2WeaponItem[nPartnerTemplateId];
	local bHasWeapon = false;
	if nWeaponItemId then
		local nCCount = me.GetItemCountInBags(nWeaponItemId);
		bHasWeapon = nCCount > 0;
	else
		bHasWeapon = true;
	end

	local tbUsed = {};
	local tbPos = me.GetPartnerPosInfo();
	for _, nPartnerId in pairs(tbPos) do
		if nPartnerId > 0 then
			tbUsed[nPartnerId] = true;
		end
	end

	for nPId, tbInfo in pairs(tbAllPartner) do
		if not tbUsed[nPId] and tbInfo.nTemplateId == nPartnerTemplateId then
			if bNeedWeapon and not bHasWeapon and tbInfo.nWeaponState ~= 1 then
				tbOtherPartner = tbOtherPartner or {}
				table.insert(tbOtherPartner, {nPId, tbInfo.nFightPower});
			else
				tbCanUsePartner = tbCanUsePartner or {};
				table.insert(tbCanUsePartner, {nPId, tbInfo.nFightPower});
			end
		end
	end

	local function fnSort(a, b)
		return a[2] < b[2];
	end

	if tbCanUsePartner and #tbCanUsePartner > 1 then
		table.sort(tbCanUsePartner, fnSort);
	end

	if tbOtherPartner and #tbOtherPartner > 1 then
		table.sort(tbOtherPartner, fnSort);
	end

	return tbCanUsePartner, tbOtherPartner, bHasWeapon;
end

function tbUi:OnClickPartner(nPos, nPartnerTemplateId, bNeedWeapon, bHasWeapon)
	if not bHasWeapon then
		local nWeaponItemId = Partner.tbPartner2WeaponItem[nPartnerTemplateId];
		local szName = Item:GetItemTemplateShowInfo(nWeaponItemId or 0);
		me.CenterMsg(string.format("缺少本命武器[FFFE0D]%s[-]", szName));
		return;
	end

	local tbSelectList = {};
	local tbCanUsePartner = self:GetAwarenessCanUsePartner(nPartnerTemplateId, false);
	for _, tbInfo in ipairs(tbCanUsePartner or {}) do
		table.insert(tbSelectList, tbInfo[1]);
	end

	Ui:OpenWindow("PartnerSelectPanel", tbSelectList, function (nPId)
		self.tbSelectInfo[nPos] = nPId;
		self:UpdateNeedInfo();
	end, bNeedWeapon);
end

function tbUi:Clear()
	self.nPartnerId = nil;
	self.tbSelectInfo = {};
	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.pPanel:Button_SetEnabled("BtnAwaken", false);
	self.pPanel:SetActive("GradeLevelupEffect", false);
	self.pPanel:SetActive("AwakenTip", true);
	self.pPanel:SetActive("PosGroup", true);
end

function tbUi:OnClose()
	self:Clear();
	self.pPanel:NpcView_Close("PartnerView");
end

function tbUi:OnAwarenessFunc()
	self.pPanel:SetActive("GradeLevelupEffect", false);
	self.pPanel:SetActive("GradeLevelupEffect", true);
	self.tbOnClick.After(self);
	self.pPanel:Button_SetEnabled("BtnAwaken", false);
	self.pPanel:Label_SetText("TxtAwaken", "已觉醒");
	self.pPanel:SetActive("AwakenTip", true);
	self.pPanel:SetActive("PosGroup", false);
end

function tbUi:OnAwareness(nPartnerId)
	if nPartnerId ~= self.nPartnerId then
		return;
	end
	self:OnAwarenessFunc();
end

function tbUi:OnSyncItem()
	local tbNeedInfo = Partner:GetAwareness(self.tbPartner.nTemplateId);
	local nCount = me.GetItemCountInBags(Partner.nPartnerAwarenessCostItem);
	local szInfo = string.format("%s/%s", nCount, tbNeedInfo.nNeedSeveranceItem);
	if nCount < tbNeedInfo.nNeedSeveranceItem then
		szInfo = "[FF0000FF]".. szInfo .. "[-]";
	end
	self.AwakenNeedItem.pPanel:Label_SetText("LabelSuffix", szInfo);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_PG_PARTNER_AWARENESS,			self.OnAwareness},
		{ UiNotify.emNOTIFY_SYNC_ITEM,						self.OnSyncItem},
		{ UiNotify.emNOTIFY_DEL_ITEM,						self.OnSyncItem},
		{ UiNotify.emNOTIFY_SYNC_PARTNER_ADD,				function () self:UpdateNeedInfo(); end}
	};

	return tbRegEvent;
end

tbUi.tbOnDrag = tbUi.tbOnDrag or {};
tbUi.tbOnDrag.PartnerView = function (self, szWnd, nX, nY)
	self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
end

tbUi.tbOnClick = tbUi.tbOnClick or {}

tbUi.tbOnClick.Skill1 = function (self)
	self:OnClickSkill(false);
end

tbUi.tbOnClick.Skill2 = function (self)
	self:OnClickSkill(true);
end

tbUi.tbOnClick.Before = function (self)
	self:UpdatePartnerInfo(false);
	self.pPanel:SetActive("Select1", true);
	self.pPanel:SetActive("Select2", false);
end

tbUi.tbOnClick.After = function (self)
	self:UpdatePartnerInfo(true);
	self.pPanel:SetActive("Select1", false);
	self.pPanel:SetActive("Select2", true);
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnAwaken = function (self)
	if Lib:CountTB(self.tbSelectInfo) ~= 5 then
		me.CenterMsg("觉醒所需材料不足");
		return;
	end
	RemoteServer.CallPartnerFunc("DoAwareness", self.nPartnerId, self.tbSelectInfo);
end
