
local tbUi = Ui:CreateClass("PartnerReInitPanel");
tbUi.tbProtentialList =
{
	"Vitality",
	"Dexterity",
	"Strength",
	"Energy",
};

tbUi.tbSeries = {
	"Gold",
	"Wood",
	"Water",
	"Fire",
	"Earth",
}

function tbUi:OnOpen(tbReInitData)
	self.nPartnerId = tbReInitData.nPartnerId;
	self.tbData = tbReInitData.tbData;
	local pPartner = me.GetPartnerObj(self.nPartnerId);
	if not pPartner then
		return 0;
	end


	me.CallClientScript("Partner:SyncHasReinitData", true);
	self.pPanel:NpcView_Open("PartnerView");
	self.tbPartnerInfo = me.GetPartnerInfo(self.nPartnerId);
	self.tbPartnerInfo.nAwareness = Partner:GetPartnerAwareness(me, self.tbPartnerInfo.nTemplateId);
	self.tbData.nAwareness = self.tbPartnerInfo.nAwareness;

	self.tbPAttribInfo = pPartner.GetAttribInfo();

	self.tbOtherInfo, self.tbOtherAttribInfo = me.GetPartnerOriginalInfo(pPartner.nTemplateId, self.tbData.bIsBY and 1 or 0, self.tbData);
	self.tbOtherInfo.nAwareness = Partner:GetPartnerAwareness(me, pPartner.nTemplateId);
	self:Update(pPartner);
end

function tbUi:OnClose()
	self.pPanel:NpcView_Close("PartnerView");
	if PlayerEvent.bLogin and not Ui.bForRetrunLogin then
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE, self.nPartnerId);
	end
end

function tbUi:Update(pPartner)
	local szName, nQualityLevel, nNpcTemplateId, nGrowthType, nSeries = GetOnePartnerBaseInfo(pPartner.nTemplateId, self.tbData.bIsBY and 1 or 0);


	self.tbSrcSkillInfo = {};
	for i = 1, 5 do
	 	local nSkillId, nSkillLevel = pPartner.GetSkillInfo(i);
	 	if nSkillId > 0 then
	 		table.insert(self.tbSrcSkillInfo, {nSkillId, nSkillLevel});
	 	else
	 		break;
	 	end
	end
	self:SetSkillInfo("", self.tbSrcSkillInfo);

	local tbDstSkill = {};
	self.tbDstSkillInfo = {};
	for i = 1, 5 do
		local nSkillId = self.tbData.tbSkillInfo[i];
		if nSkillId then
			tbDstSkill[nSkillId] = 1;
			table.insert(self.tbDstSkillInfo, {nSkillId, 1});
		else
			break;
		end
	end
	self:SetSkillInfo("1", self.tbDstSkillInfo);

	local tbDstProtentialInfo = self:GetProtentialInfo(self.tbOtherInfo, self.tbOtherAttribInfo);
	local tbSrcProtentialInfo = self:GetProtentialInfo(self.tbPartnerInfo, self.tbPAttribInfo);
	self:SetProtential("", tbSrcProtentialInfo);
	self:SetProtential("1", tbDstProtentialInfo, tbSrcProtentialInfo);

	for i = 1, 5 do
		self.pPanel:SetActive(self.tbSeries[i], i == nSeries);
	end

	self.pPanel:Label_SetText("FightValue1", string.format("战力 %s", self.tbPartnerInfo.nFightPower));
	self.pPanel:Label_SetText("FightValue2", string.format("战力 %s", self.tbOtherInfo.nFightPower));
	self.pPanel:SetActive("QualityMark1", self.tbPartnerInfo.nIsNormal == 0);
	self.pPanel:SetActive("QualityMark2", self.tbOtherInfo.nIsNormal == 0);
	self.pPanel:Sprite_SetSprite("QualityIcon", Partner.tbQualityLevelToSpr[nQualityLevel]);

	self:SetPartner(self.tbOtherInfo, self.tbOtherAttribInfo);
	self.pPanel:SetActive("Select1", false);
	self.pPanel:SetActive("Select2", true);
end

function tbUi:GetProtentialInfo(tbPartnerInfo, tbAttribInfo)
	local tbProtentialInfo = {};
	for nType, szName in pairs(Partner.tbAllProtentialType) do
		tbProtentialInfo["n" .. szName] = tbAttribInfo["n" .. szName];

		local nLimitProtential = self:GetLimitePValue(nType, tbPartnerInfo["nLimitProtential" .. szName], tbPartnerInfo.nAwareness);
		local nMaxValue = tbAttribInfo["n" .. szName] + nLimitProtential - math.floor(tbPartnerInfo["nProtential" .. szName] / Partner.tbProtentialToValue[tbPartnerInfo.nQualityLevel])

		tbProtentialInfo["nLimit" .. szName] = nMaxValue;
		tbProtentialInfo["nLimitLevel" .. szName] = tbPartnerInfo["nLimitProtential" .. szName];
	end
	return tbProtentialInfo;
end

function tbUi:GetLimitePValue(nProtentialType, nLimitLevel, nAwareness)
	local nLimitProtential = Partner:GetLimitProtentialValue(self.tbPartnerInfo.nQualityLevel, self.tbPartnerInfo.nGrowthType,
															nProtentialType, nLimitLevel, self.tbPartnerInfo.nGradeLevel + 1, nAwareness);
	return nLimitProtential;
end

function tbUi:SetPartner(tbPartnerInfo, tbPartnerAttribInfo)
	local tbDefault = GetPartnerDefaultSkill(tbPartnerInfo.nTemplateId);
	self.tbDefaultSkill = {};
	for _, nSkillId in ipairs(tbDefault) do
		table.insert(self.tbDefaultSkill, {nSkillId, 1});
	end
	local _, nStarLevel = Partner:GetStarValue(tbPartnerInfo.nFightPower);
	local nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;
	local nMaxFightPower = Partner:GetMaxFightPower(tbPartnerInfo);
	local _, nMaxStar = Partner:GetStarValue(nMaxFightPower);
	local nMaxLevel = math.max(Partner.tbFightPowerToSkillLevel[nMaxStar] or 1, nSkillLevel);

	self.tbDefaultSkill[2][2] = nSkillLevel;
	self.tbDefaultSkill[2][3] = nMaxLevel;

	self:SetDefaultSkillInfo(self.tbDefaultSkill);

	local _, nResId = KNpc.GetNpcShowInfo(tbPartnerInfo.nNpcTemplateId);
	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	self.pPanel:NpcView_SetWeaponState("PartnerView", tbPartnerInfo.nWeaponState);
	if tbPartnerInfo.nAwareness and tbPartnerInfo.nAwareness == 1 then
		self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, Partner:GetAwareness(tbPartnerInfo.nTemplateId).nUiEffectId);
	end
end

function tbUi:SetDefaultSkillInfo(tbDefaultSkill)
	tbDefaultSkill = tbDefaultSkill or {};
	for i = 1, 2 do
		local nSkillId = (tbDefaultSkill[i + 1] or {})[1] or 0;
		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		if tbValue then
			local tbInfo = Partner:GetSkillInfoBySkillId(nSkillId) or {};
			local szFrameColor = Partner.tbSkillColor[tbInfo.nQuality or 1] or "";
			self.pPanel:SetActive("DefaultSkill" .. i, true);
			self.pPanel:Sprite_SetSprite("DefaultSkill" .. i, tbValue.szIconSprite, tbValue.szIconAtlas);
			self.pPanel:Sprite_SetSprite("DefaultColor" .. i, szFrameColor);
		else
			self.pPanel:SetActive("DefaultSkill" .. i, false);
		end
	end

	local tbSkillInfo = FightSkill:GetSkillSetting(tbDefaultSkill[1][1]);
	self.pPanel:Label_SetText("CompanionPersonality", string.format("同伴个性：%s", tbSkillInfo.SkillName or ""));
	self.pPanel:Label_SetText("PersonalityDescribe", string.format("%s", tbSkillInfo.Desc or ""));
end

function tbUi:SetSkillInfo(szTitle, tbSkillInfo)
	tbSkillInfo = tbSkillInfo or {};
	for i = 1, 5 do
		local nSkillId = (tbSkillInfo[i] or {})[1] or 0;
		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		if tbValue then
			local tbInfo = Partner:GetSkillInfoBySkillId(nSkillId) or {};
			local szFrameColor = Partner.tbSkillColor[tbInfo.nQuality or 1] or "";
			self.pPanel:SetActive("Skill" .. szTitle .. i, true);
			self.pPanel:Sprite_SetSprite("Skill" .. szTitle .. i, tbValue.szIconSprite, tbValue.szIconAtlas);
			self.pPanel:Sprite_SetSprite("Color" .. szTitle .. i, szFrameColor);
		else
			self.pPanel:SetActive("Skill" .. szTitle .. i, false);
		end
	end
end

function tbUi:SetProtential(szTitle, tbProtentialInfo, tbOther)
	for i, szType in ipairs(self.tbProtentialList) do
		local nValue = tbProtentialInfo["n" .. szType];
		local nMaxValue = tbProtentialInfo["nLimit" .. szType];

		local function fnGetValue(nOldV, nV)
			local szValue = tostring(nV);
			local szColor;
			if nV >= nOldV then
				szColor = "62f550";
			elseif nV < nOldV then
				szColor = "f84141";
			end
			if szColor then
				szValue = string.format("[%s]%s[-]", szColor, szValue);
			end
			return szValue;
		end

		local szValue = tostring(nValue);
		local szMaxValue = tostring(nMaxValue);
		if tbOther then
			szValue = fnGetValue(tbOther["n" .. szType], nValue);
			szMaxValue = fnGetValue(tbOther["nLimit" .. szType], nMaxValue);
		end

		self.pPanel:Label_SetText("Character" .. szTitle .. i, Partner.tbPartnerLimitLevelDesc[tbProtentialInfo["nLimitLevel" .. szType]]);
		self.pPanel:Label_SetText("QualityPercent" .. szTitle .. i, string.format("%s / %s", szValue, szMaxValue));
		self.pPanel:Sprite_SetFillPercent("QualityBar" .. szTitle .. i, nValue / nMaxValue);
	end
end

function tbUi:OnClickSkill(szType, nIdx)
	if not self[szType] or not self[szType][nIdx] then
		return;
	end

	local tbInfo = self[szType][nIdx];
	local nSkillId, nSkillLevel = unpack(tbInfo);
	Partner:ShowSkillTips(nSkillId, nSkillLevel);
end

function tbUi:OnClickDefaultSkill(nIdx)
	Partner:ShowSkillTips(unpack(self.tbDefaultSkill[nIdx + 1]));
end

tbUi.tbOnDrag =
{
	PartnerView = function (self, szWnd, nX, nY)
		self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
	end,
}

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnBefore = function (self)
	Ui:CloseWindow(self.UI_NAME);

	RemoteServer.CallPartnerFunc("ReInitPartnerConfirm", self.nPartnerId, true);
	me.CallClientScript("Partner:SyncHasReinitData", false);
	if Ui:WindowVisible("Partner") and Ui("Partner").pPanel:IsActive(Ui("Partner").MAIN_PANEL) then
		Ui("Partner").PartnerMainPanel:SetSelectPartner(self.nPartnerId);
	end
end

tbUi.tbOnClick.BtnAfter = function (self)
	Ui:CloseWindow(self.UI_NAME);

	RemoteServer.CallPartnerFunc("ReInitPartnerConfirm", self.nPartnerId, false);
	me.CallClientScript("Partner:SyncHasReinitData", false);
	if Ui:WindowVisible("Partner") and Ui("Partner").pPanel:IsActive(Ui("Partner").MAIN_PANEL) then
		Ui("Partner").PartnerMainPanel:SetSelectPartner(self.nPartnerId);
	end
end

tbUi.tbOnClick.Before = function (self)
	self:SetPartner(self.tbPartnerInfo, self.tbPAttribInfo);
	self.pPanel:SetActive("Select1", true);
	self.pPanel:SetActive("Select2", false);
end

tbUi.tbOnClick.After = function (self)
	self:SetPartner(self.tbOtherInfo, self.tbOtherAttribInfo);
	self.pPanel:SetActive("Select1", false);
	self.pPanel:SetActive("Select2", true);
end

for i = 1, 2 do
	tbUi.tbOnClick["DefaultSkill" .. i] = function (self)
		self:OnClickDefaultSkill(i);
	end
end

for i = 1, 5 do
	tbUi.tbOnClick["Skill" .. i] = function (self)
		self:OnClickSkill("tbSrcSkillInfo", i);
	end

	tbUi.tbOnClick["Skill1" .. i] = function (self)
		self:OnClickSkill("tbDstSkillInfo", i);
	end
end
