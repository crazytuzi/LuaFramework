local tbPartnerUi = Ui:CreateClass("Partner");
local tbUi = Ui:CreateClass("PartnerMainInfo");

tbUi.PARTNER_LIST = "PartnerListPanel";
tbUi.Skill_LIST = "SkillListPanel";
tbUi.ATTRIB_INFO = "AttribInfoPanel";

tbUi.EXT_PANEL = "ExtPanel";
tbUi.SUB_PANEL = "SubPanel";
tbUi.tbPanelInfo = {};

tbPartnerUi.EXT_LEVELUP = "LevelUp";
tbPartnerUi.EXT_SEVERANCE = "Severance";
tbPartnerUi.EXT_LEARNSKILL = "LearnSkill";

tbPartnerUi.SUB_QUALITYSKILL = "QualitySkill";
tbPartnerUi.SUB_ATTRIBINFO = "AttribInfoPanel";

local tbSeries = {
	"Gold",
	"Wood",
	"Water",
	"Fire",
	"Earth",
}

-- 体质   Vitality
-- 敏捷   Dexterity
-- 力量   Strength
-- 灵巧   Energy

function tbUi:SetType(szSubPanel, szExtPanel)
	self:UpdatePanel(self.EXT_PANEL, szExtPanel);
	self:UpdatePanel(self.SUB_PANEL, szSubPanel);
end

function tbUi:LoadParam(szMainInfoParam)
	if not szMainInfoParam or szMainInfoParam == "" then
		return;
	end

	local szSubPanel = string.match(szMainInfoParam, "SP=([^;]+);");
	local szExtPanel = string.match(szMainInfoParam, "EP=([^;]+);");
	local nExtParam = string.match(szMainInfoParam, "EPP=([^;]+);");
	if szSubPanel then
		self:UpdatePanel(self.SUB_PANEL, szSubPanel);
	end

	if szExtPanel then
		self:UpdatePanel(self.EXT_PANEL, szExtPanel);
	end

	if szExtPanel == tbPartnerUi.EXT_LEARNSKILL and nExtParam then
		local nItemId = tonumber(nExtParam);
		local pItem = KItem.GetItemObj(nItemId or 0);
		if pItem then
			self:SetSkillBook(nItemId, pItem.szName);
		end
	end
end

function tbUi:UpdatePanel(szPanelType, szPanel)
	if not self.tbUiSetting then
		self.tbUiSetting = {
			[self.EXT_PANEL] = {
				[tbPartnerUi.EXT_LEVELUP] = self.ExtUpdateLevelUp,
				[tbPartnerUi.EXT_SEVERANCE] = self.ExtUpdateSeverance,
				[tbPartnerUi.EXT_LEARNSKILL] = self.ExtUpdateLearnSkill,
			};
			[self.SUB_PANEL] = {
				[tbPartnerUi.SUB_QUALITYSKILL] = self.SubUpdateQualitySkill,
				[tbPartnerUi.SUB_ATTRIBINFO] = self.SubUpdateAttribInfoPanel,
			};
		}
	end

	if not self.tbPartner then
		self:Clear();
		return;
	end

	self.tbPanelInfo[self.SUB_PANEL] = self.tbPanelInfo[self.SUB_PANEL] or tbPartnerUi.SUB_QUALITYSKILL;
	self.tbPanelInfo[self.EXT_PANEL] = self.tbPanelInfo[self.EXT_PANEL] or tbPartnerUi.EXT_LEVELUP;

	self.tbPanelInfo[szPanelType] = szPanel or self.tbPanelInfo[szPanelType];
	szPanel = self.tbPanelInfo[szPanelType];
	for szType, fnUpdate in pairs(self.tbUiSetting[szPanelType]) do
		self.pPanel:SetActive(szType, szType == szPanel);
	end

	local tbAllSkillInfo, pPartner = Partner:GetPartnerAllSkillInfo(me, self.nPartnerId);
	self.tbUiSetting[szPanelType][szPanel](self, self.tbPartner, tbAllSkillInfo, pPartner.GetAttribInfo());
end

function tbUi:SubUpdateAttribInfoPanel(tbPartnerInfo, tbPSkillInfo, tbPAttribInfo)
	for nIdx, tbInfo in ipairs(Partner.tbAllAttribDef) do
		local szType = tbInfo[1];
		local value = 0;
		local szShowValue = nil;
		if type(tbInfo[2]) == "string" and tbInfo[2] == "Protential" then
			value = string.format("%.1f", math.floor((tbPartnerInfo["nProtential" .. tbInfo[3]] or 0) * 10) / 10);
		elseif type(tbInfo[2]) == "string" then
			value = Partner:GetValueBase(tbPAttribInfo, unpack(tbInfo, 2)) or 0;
		elseif type(tbInfo[2]) == "function" then
			value, szShowValue = tbInfo[2](Partner, tbPAttribInfo, unpack(tbInfo, 3));
			value = value or 0;
		end
		value = szShowValue or value;

		if not self.pPanel:CheckHasChildren("AttribInfo" .. nIdx) then
			self.pPanel:CreateWnd("AttribInfo", "AttribInfo", tostring(nIdx));
			self.pPanel:ChangePosition("AttribInfo" .. nIdx, 10, 245 - 40 * nIdx);
			self.pPanel:SetActive("AttribInfo" .. nIdx, true);
		end

		self.pPanel:Label_SetText("AttribName" .. nIdx, szType);
		self.pPanel:Label_SetText("AttribValue" .. nIdx, type(value) == "number" and math.floor(value) or value);
	end

	self.pPanel:ResizeScrollViewBound("Attrilist", 205 - 40 * #Partner.tbAllAttribDef, 225);
end

function tbUi:ExtUpdateSeverance()
	self.pPanel:Toggle_SetChecked("BtnCompanionSeverance", true);
	self.pPanel:Button_SetEnabled("BtnSeverance", true);
	local nItemCount = me.GetItemCountInAllPos(Partner.nSeveranceItemId);
	self.SeveranceItem:SetGenericItem({"item", Partner.nSeveranceItemId, 0});
	self.SeveranceItem.fnClick = self.SeveranceItem.DefaultClick;

	local nCostCount = Partner.ServeranceCost[self.tbPartner.nQualityLevel];
	self.SeveranceItem.pPanel:SetActive("LabelSuffix", true);

	local szCountInfo = string.format("%s/%s", nItemCount, nCostCount);
	if nItemCount < nCostCount then
		szCountInfo = string.format("[FF0000FF]%s[-]", szCountInfo);
	end
	self.SeveranceItem.pPanel:Label_SetText("LabelSuffix", szCountInfo);
end

function tbUi:ExtUpdateLevelUp()
	self.pPanel:Toggle_SetChecked("BtnCompanionLevelUp", true);
	self.pPanel:Button_SetEnabled("BtnLevelup", true);
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%s级", self.tbPartner.nLevel));
	else
		self.pPanel:Label_SetText("Level", string.format("Lv.%s", self.tbPartner.nLevel));
	end
	self.pPanel:Label_SetText("ExpPercent", string.format("%s / %s", self.tbPartner.nExp, self.tbPartner.nLevelupExp));
	self.pPanel:Sprite_SetFillPercent("ExpBar", self.tbPartner.nExp / (math.max(self.tbPartner.nLevelupExp or 1, 1)));
end

function tbUi:ExtUpdateLearnSkill()
	self.pPanel:Toggle_SetChecked("BtnCompanionLearnSkill", true);
	self.pPanel:Button_SetEnabled("BtnLearn", true);
	self.nLearnSkillBookId = nil;
	self.LearnSkillItem:Clear();
	self.pPanel:Sprite_SetSprite("BtnAddSkillBook", "companionBut_+green");
	self.pPanel:Label_SetText("SkillBookName", "点击放入技能书");
end

function tbUi:Clear()
	self.nPartnerId = nil;
	self.pPanel:SetActive("StarInfo", false);
	self.pPanel:SetActive("QualityMark", false);
	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.pPanel:Label_SetText("FightValue", "战力  --");
	self.pPanel:SetActive("Severance", false);
	self.pPanel:SetActive("LearnSkill", false);
	self.pPanel:SetActive("AttribInfoPanel", false);

	self.pPanel:SetActive("QualitySkill", true);
	self:SetProtential();
	self:SetSkill();

	self.pPanel:SetActive("LevelUp", true);

	if version_tx then
		self.pPanel:Label_SetText("Level", "0级");
	else
		self.pPanel:Label_SetText("Level", "Lv.0");
	end

	self.pPanel:Button_SetEnabled("BtnLevelup", false);
	self.pPanel:Label_SetText("ExpPercent", "-/-");
	self.pPanel:Sprite_SetFillPercent("ExpBar", 1);
	self.pPanel:Button_SetEnabled("BtnCompanionLevelUp", self.nPartnerId and true or false);
	self.pPanel:Button_SetEnabled("BtnCompanionLearnSkill", self.nPartnerId and true or false);
	self.pPanel:Button_SetEnabled("BtnCompanionSeverance", self.nPartnerId and true or false);
end

function tbUi:SubUpdateQualitySkill(tbPartnerInfo, tbPSkillInfo, tbPAttribInfo)
	self.tbProtentialList = {
		"Vitality",
		"Dexterity",
		"Strength",
		"Energy",
	};

	local tbInfo = {};
	for _, szType in ipairs(self.tbProtentialList) do
		local tbValue = {};
		local nValue = math.floor(tbPartnerInfo["nProtential" .. szType] * 100 + 0.1);
		local nMaxValue = math.floor(tbPartnerInfo["nLimitProtential" .. szType] * 100 + 0.1);

		tbValue.szInfo = string.format("%d / %d", nValue, nMaxValue);
		tbValue.nValue =  nValue / nMaxValue;
		table.insert(tbInfo, tbValue);
	end
	tbUi.SetProtential(self, tbInfo);

	self.tbPSkillInfo = tbPSkillInfo;
	local tbSkillInfo = {};
	for i = 1, 3 do
		if tbPSkillInfo.tbDefaultSkill[i] then
			table.insert(tbSkillInfo, {tbPSkillInfo.tbDefaultSkill[i].nSkillId, tbPSkillInfo.tbDefaultSkill[i].nSkillLevel});
		end
	end

	for i = 1, 5 do
		if tbPSkillInfo.tbNormalSkill[i] then
			table.insert(tbSkillInfo, {tbPSkillInfo.tbNormalSkill[i].nSkillId, tbPSkillInfo.tbNormalSkill[i].nSkillLevel});
		end
	end

	tbUi.SetSkill(self, tbSkillInfo);
end

function tbUi:SetProtential(tbValue)
	tbValue = tbValue or {};
	for i = 1, 4 do
		local tbInfo = tbValue[i] or {szInfo = "-/-", nValue = 0};
		self.pPanel:Label_SetText("QualityPercent" .. i, tbInfo.szInfo);
		self.pPanel:Sprite_SetFillPercent("QualityBar" .. i, tbInfo.nValue);
	end
end

function tbUi:SetSkill(tbSkillInfo)
	tbSkillInfo = tbSkillInfo or {};
	for i = 1, 8 do
		tbSkillInfo[i] = tbSkillInfo[i] or {};
		local nSkillId = (tbSkillInfo[i] or {})[1] or 0;
		local nSkillLevel = (tbSkillInfo[i] or {})[2];
		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		if tbValue then
			local tbInfo = Partner:GetSkillInfoBySkillId(nSkillId) or {};
			local szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(tbInfo.nQuality or 1);
			self.pPanel:SetActive("Skill" .. i, true);
			self.pPanel:Sprite_SetSprite("Skill" .. i, tbValue.szIconSprite, tbValue.szIconAtlas);
			self.pPanel:Sprite_SetSprite("Color" .. i, szFrameColor);

			if i >= 4 then
				self.pPanel:SetActive("SLevel" .. i, false);
			end
		else
			self.pPanel:SetActive("Skill" .. i, false);
		end
	end
end

function tbUi:SetCurPartner(nPartnerId)
	self.nPartnerId = nPartnerId or self.nPartnerId;
	self.tbPartner = me.GetPartnerInfo(self.nPartnerId or 0);
	if not self.tbPartner then
		self:Clear();
		return;
	end

	self.tbPartner.nAwareness = Partner:GetPartnerAwareness(me, self.tbPartner.nTemplateId);
	self.pPanel:Button_SetEnabled("BtnCompanionLevelUp", self.nPartnerId and true or false);
	self.pPanel:Button_SetEnabled("BtnCompanionLearnSkill", self.nPartnerId and true or false);
	self.pPanel:Button_SetEnabled("BtnCompanionSeverance", self.nPartnerId and true or false);

	self.pPanel:SetActive("QualityMark", true);
	self.pPanel:Sprite_SetSprite("QualityMark", self.tbPartner.nIsNormal == 1 and "____" or "Quality_Special");

	self.pPanel:Label_SetText("FightValue", string.format("战力  %s", self.tbPartner.nFightPower));
	local nStar = Partner:GetStarValue(self.tbPartner.nFightPower);
	self.pPanel:SetActive("StarInfo", true);
	for i = 1, 10 do
		if i <= math.ceil(nStar) then
			self.pPanel:SetActive("star" .. i, true);
			if i <= nStar then
				self.pPanel:Sprite_SetSprite("star" .. i, "Star_01");
			else
				self.pPanel:Sprite_SetSprite("star" .. i, "Star_half");
			end
		else
			self.pPanel:SetActive("star" .. i, false);
		end
	end

	for i = 1, 5 do
		self.pPanel:SetActive(tbSeries[i], i == self.tbPartner.nSeries);
	end

	local _, nResId = KNpc.GetNpcShowInfo(self.tbPartner.nNpcTemplateId);
	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	self.pPanel:NpcView_SetWeaponState("PartnerView", self.tbPartner.nWeaponState);

	self:UpdatePanel(self.EXT_PANEL);
	self:UpdatePanel(self.SUB_PANEL);
end

function tbUi:BtnAddProtential(szType)
	Ui:OpenWindow("PartnerProtential", self.nPartnerId, szType);
end

function tbUi:OnClickSkill(nIdx, tbExtSkillId)
	local nSkillId = 0;
	local nSkillLevel = 1;
	local nMaxLevel = 1;
	if nIdx <= 3 then
		nSkillId = self.tbPSkillInfo.tbDefaultSkill[nIdx].nSkillId;
		nSkillLevel = self.tbPSkillInfo.tbDefaultSkill[nIdx].nSkillLevel;

		if nIdx == 2 then
			if not self.UI_NAME then
				local _, nStarLevel = Partner:GetStarValue(self.tbPartner.nFightPower);
				nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;
			end
			nMaxLevel = Partner.tbFightPowerToSkillLevel[#Partner.tbFightPowerToSkillLevel];
		end

		nIdx = nil;
	else
		nIdx = nIdx - 3;
		nSkillId = self.tbPSkillInfo.tbNormalSkill[nIdx].nSkillId;
		nSkillLevel = self.tbPSkillInfo.tbNormalSkill[nIdx].nSkillLevel;
	end

	if not nSkillId or nSkillId <= 0 then
		return;
	end

	Partner:ShowSkillTips(nSkillId, nSkillLevel, nMaxLevel, nil, tbExtSkillId);
end

function tbUi:SetSkillBook(nItemId, szName)
	self.nLearnSkillBookId = nItemId;
	self.LearnSkillItem:SetItem(nItemId);
	self.LearnSkillItem.pPanel:SetActive("LabelSuffix", false);

	self.pPanel:Sprite_SetSprite("BtnAddSkillBook", "__nil");
	self.pPanel:Label_SetText("SkillBookName", szName);
end

function tbUi:OnSelectCoverSkill(nPartnerId, nItemId, nPos)
	if nPartnerId ~= self.nPartnerId or nItemId ~= self.nLearnSkillBookId then
		return;
	end

	local bRet, _, _, _, tbAllowInfo = Partner:CheckCanUseSkillBook(me, self.nPartnerId, self.nLearnSkillBookId);
	if not bRet or not tbAllowInfo or not tbAllowInfo[nPos] then
		return;
	end

	RemoteServer.CallPartnerFunc("UseSkillBook", self.nPartnerId, self.nLearnSkillBookId, nPos);
	self:UpdatePanel(self.EXT_PANEL);
end

function tbUi:OnUpdatePartner(nPartnerId)
	if self.nPartnerId and self.nPartnerId == nPartnerId then
		self:SetCurPartner();
	end
end

function tbUi:OnSyncItem()
	self:UpdatePanel(self.EXT_PANEL);
end

tbUi.tbOnDrag =
{
	PartnerView = function (self, szWnd, nX, nY)
		self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
	end,
}

tbUi.tbOnClick = tbUi.tbOnClick or {};

for i = 1, 4 do
	tbUi.tbOnClick["BtnAdd" .. i] = function (self)
		self:BtnAddProtential(self.tbProtentialList[i]);
	end
end

for i = 1, 8 do
	tbUi.tbOnClick["Skill" .. i] = function (self)
		self:OnClickSkill(i);
	end
end

tbUi.tbOnClick.BtnCompanionLevelUp = function (self)
	self:SetType(nil, tbPartnerUi.EXT_LEVELUP);
end

tbUi.tbOnClick.BtnCompanionLearnSkill = function (self)
	self:SetType(nil, tbPartnerUi.EXT_LEARNSKILL);
end

tbUi.tbOnClick.BtnCompanionSeverance = function (self)
	self:SetType(nil, tbPartnerUi.EXT_SEVERANCE);
end

tbUi.tbOnClick.BtnLevelup = function (self)
	if self.nPartnerId and self.nPartnerId > 0 then
		Ui:OpenWindow("PartnerExpUse", self.nPartnerId)
	end
end

tbUi.tbOnClick.BtnSeverance = function (self)
	local bRet, szMsg = Partner:CheckReinitPartner(me, self.nPartnerId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local szMsg;
	if self.tbPartner.nLevel > 1 then
		szMsg = "洗髓后同伴的 [FFFE0D]潜能、技能[-] 将会重新生成，是否继续？";
	end

	if self.tbPartner.nIsNormal == 0 then
		szMsg = "洗髓后 [FFFE0D]奇才同伴[-] 可能会变成普通同伴，是否继续？";
	end

	if szMsg then
		me.MsgBox(szMsg, { {"确定", function ()
			RemoteServer.CallPartnerFunc("ReInitPartner", self.nPartnerId);
		end}, {"取消"}});
	else
		RemoteServer.CallPartnerFunc("ReInitPartner", self.nPartnerId);
	end
end

tbUi.tbOnClick.BtnLearn = function (self)
	if not self.nLearnSkillBookId then
		self.tbOnClick.BtnAddSkillBook(self);
		return;
	end

	local bRet, _, _, nMustPos = Partner:CheckCanUseSkillBook(me, self.nPartnerId, self.nLearnSkillBookId)
	if bRet and nMustPos and nMustPos > 0 then
		RemoteServer.CallPartnerFunc("UseSkillBook", self.nPartnerId, self.nLearnSkillBookId, nMustPos);
		self:UpdatePanel(self.EXT_PANEL);
		return;
	end

	if bRet then
		Ui:OpenWindow("PartnerSelectCoverSkill", self.nPartnerId, self.nLearnSkillBookId);
	end
end

tbUi.tbOnClick.BtnAddSkillBook = function (self)
	local tbItemList = {};
	local tbTmp = {};
	local tbAllBook = me.FindItemInBag("PartnerSkillBook");
	for _, pItem in pairs(tbAllBook) do
		if not tbTmp[pItem.dwTemplateId] then
			local bRet = Partner:CheckCanUseSkillBook(me, self.nPartnerId, pItem.dwId);
			if bRet then
				table.insert(tbItemList, pItem.dwId);
				tbTmp[pItem.dwTemplateId] = true;
			end
		end
	end

	table.sort(tbItemList);
	if #tbItemList > 0 then
		Ui:OpenWindow("PartnerSelectSkillBook", self.nPartnerId, tbItemList);
		return;
	end

	me.MsgBox(string.format("无可用技能书，是否前往摆摊购买？"),
		{
			{"前往", function () Ui:OpenWindow("MarketStallPanel", 1); end },
			{"取消"}
		});
end
