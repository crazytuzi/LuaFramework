local tbPartnerUi = Ui:CreateClass("Partner");
local tbUi = Ui:CreateClass("PartnerMainPanel");
local tbSeveranceDiscountItem = Item:GetClass("SeveranceDiscount");
tbUi.Skill_LIST = "SkillListPanel";
tbUi.ATTRIB_INFO = "AttribInfoPanel";

local nNumLen = 10;

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

function tbUi:PraseSubType(szSubType)
	if not szSubType then
		return;
	end

	local nPartnerId, szMainInfoParam = string.match(szSubType, "^PId=(%d+);(.*)$");
	nPartnerId = tonumber(nPartnerId or "nil");
	if not nPartnerId then
		return;
	end

	return nPartnerId, szMainInfoParam;
end

function tbUi:Update(szSubType)

	self.tbPartnerList, self.tbAllPartner = Partner:GetSortedPartnerList(me);
	self:UpdatePartnerPosInfo();
	self:UpdatePartnerList();
	local nPartnerId, szMainInfoParam = self:PraseSubType(szSubType);
	if not nPartnerId or not self.tbAllPartner[nPartnerId] then
		nPartnerId = self.tbPartnerList[1];
	end

	self.pPanel:SetActive("GradeLevelupEffect", false);
	self:SetSelectPartner(nPartnerId);

	local bJingMaiOpen = JingMai:CheckOpen(me);
	self.pPanel:SetActive("BtnMeridian", bJingMaiOpen);
	self.pPanel:SetActive("Meridian", bJingMaiOpen);
	self.pPanel:SetActive("Dantian", bJingMaiOpen);
	if bJingMaiOpen then
		local nDanTianValue = me.GetUserValue(JingMai.SAVE_GROUP_ID, JingMai.SAVE_INDEX_ID);
		self.pPanel:SetActive("ZhenYuan_PiLaoTeXiao", nDanTianValue > 0);
		self.pPanel:SetActive("ZhenYuan_ChongYingTeXiao", nDanTianValue <= 0);
	end

	self:SetBtnMeridianRedPoint()
end

function tbUi:SetBtnMeridianRedPoint()
	local bShowJingMaiRedPoint = JingMai:CheckJingMaiMainPanelRP(me);
	self.pPanel:SetActive("BtnMeridianRedPoint", bShowJingMaiRedPoint);
end

function tbUi:Clear()
	self.nCurPartnerId = nil;
	self.pPanel:Sprite_SetSprite("QualityIcon", "_______");
	self.pPanel:Label_SetText("Name", "");
	self.pPanel:Label_SetText("Features", "");
	self.pPanel:SetActive("QualityMark", false);
	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, 0);

	self:SetProtential();
	self:SetSkill();

	self.pPanel:SetActive("LevelUp", true);
	self.pPanel:Label_SetText("Level", "");
	self.pPanel:Label_SetText("ExpPercent", "-/-");
	self.pPanel:Sprite_SetFillPercent("ExpBar", 1);
	self.pPanel:Button_SetSprite("BtnLevelup", "BtnOption_01");
	self.pPanel:Label_SetText("BtnTxt", "升级");
	self.pPanel:SetActive("GradeLevelupRedPoint", false);

	self.pPanel:Button_SetCheck("BtnAttribInfo", false);
	self.pPanel:Button_SetEnabled("BtnAttribInfo", false);
	self.pPanel:SetActive("Quality", true);
	self.pPanel:SetActive("AttribInfoPanel", false);
	self.pPanel:Label_SetText("TxtSeverance", "洗髓");
	self.SeveranceItem:Clear();
	self.pPanel:Label_SetText("CompanionPersonality", "");
	self.pPanel:Label_SetText("PersonalityDescribe", "");
	self.pPanel:SetActive("GradeLevelupEffect", false);
	self.pPanel:SetActive("Meridian", false);

	for i = 1, 5 do
		self.pPanel:SetActive(tbSeries[i], false);
	end

	self.pPanel:SetActive("Weapon", false);
	self.pPanel:SetActive("BtnAwareness", false);
	self.pPanel:SetActive("AwarenessMark", false);
end

function tbUi:SetSelectPartner(nPartnerId)
	for i = 0, 1000, 1 do
		local itemObj = self.PartnerListScrollView.Grid["Item" .. i];
		if not itemObj then
			break;
		end

		itemObj.pPanel:Sprite_SetSprite("Main", nPartnerId == itemObj.nPartnerId and "BtnListThirdPress" or "BtnListThirdNormal");
		local tbPartnerInfo = me.GetPartnerInfo(itemObj.nPartnerId or 0);
		if tbPartnerInfo then
			itemObj.pPanel:SetActive("Mark", tbPartnerInfo.nIsNormal == 0);
		end
	end

	self:SetCurPartner(nPartnerId);
	self.nCurPartnerId = nPartnerId;
end

function tbUi:UpdatePartnerList()
	local function fnOnSelectBattle(itemObj)
		if self.bForbidenOperation then
			return;
		end

		if itemObj.bIsFirst then
			Guide.tbNotifyGuide:ClearNotifyGuide("Partner");
		end

		local nPartnerId = itemObj.nPartnerId;
		local nPos = self.tbPartner2Pos[nPartnerId];
		if nPos and nPos > 0 then
			nPartnerId = 0;
		end

		self:SetPartnerToPos(nPartnerId, nPos);
		self:DoSyncPartnerPos();
	end

	local function fnOnSelect(itemObj)
		if Ui.bShowDebugInfo then
			local tbPartnerInfo = self.tbAllPartner[itemObj.nPartnerId]
			if tbPartnerInfo then
				Ui:SetDebugInfo("TemplateId: " .. tbPartnerInfo.nTemplateId .. "\nPartnerId: " .. itemObj.nPartnerId);
			end
		end
		self:SetSelectPartner(itemObj.nPartnerId);
	end

	local fnSetItem = function(itemObj, index)
		local nPartnerId = self.tbPartnerList[index];
		local tbPartner = self.tbAllPartner[nPartnerId];

		itemObj.nPartnerId = nPartnerId;
		itemObj.PartnerHead:SetPartnerInfo(tbPartner);
		itemObj.pPanel:Label_SetText("Name", tbPartner.szName);
		itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", tbPartner.nFightPower));
		itemObj.pPanel:SetActive("Mark", tbPartner.nIsNormal == 0);
		itemObj.pPanel:Sprite_SetSprite("Main", self.nCurPartnerId == nPartnerId and "BtnListThirdPress" or "BtnListThirdNormal");

		itemObj.BtnCheck.bIsFirst = index == 1;

		if index == 1 then
			itemObj.BtnCheck.pPanel:UnRegisterRedPoint("GuideTips");
			--itemObj.BtnCheck.pPanel:RegisterRedPoint("GuideTips", "NG_Partner");
		else
			itemObj.BtnCheck.pPanel:UnRegisterRedPoint("GuideTips");
			itemObj.BtnCheck.pPanel:SetActive("GuideTips", false);
		end

		local bCanGradeLevelup = Partner:CheckCanGradeLevelup(me, nPartnerId);
		itemObj.pPanel:SetActive("RedPoint", bCanGradeLevelup and true or false);

		itemObj.BtnCheck.nPartnerId = nPartnerId;
		itemObj.BtnCheck:SetCheck(self.tbPartner2Pos[nPartnerId] and true or false);
		itemObj.BtnCheck.pPanel.OnTouchEvent = fnOnSelectBattle;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end

	self.tbPartnerList, self.tbAllPartner = Partner:GetSortedPartnerList(me);
	self.PartnerListScrollView:Update(self.tbPartnerList, fnSetItem);
	self.pPanel:DragScrollViewGoTop("PartnerListScrollView");

	self.pPanel:SetActive("BtnRecruit", #self.tbPartnerList <= 0);
	self.pPanel:Button_SetEnabled("BtnCompanionArray", true);
	self:UpdateLevelupRedPoint();
end

function tbUi:UpdateGradeLevelupRedPoint()
	for i = 0, 9999 do
		local pItemObj = self.PartnerListScrollView.Grid["Item" .. i];
		if not pItemObj then
			break;
		end

		if pItemObj.nPartnerId and type(pItemObj.nPartnerId) == "number" then
			local bCanGradeLevelup = Partner:CheckCanGradeLevelup(me, pItemObj.nPartnerId);
			pItemObj.pPanel:SetActive("RedPoint", bCanGradeLevelup and true or false);
		end
	end
end

function tbUi:UpdateLevelupRedPoint()
	local bShowLevelupRedPoint = false;
	local nExpItemCount = me.GetItemCountInAllPos("PartnerExpItem");
	if self.tbPartner2Pos[self.nCurPartnerId] and self.tbPartner.nLevel < me.nLevel and nExpItemCount > 0 then
		bShowLevelupRedPoint = true;
	end
	--self.pPanel:SetActive("LevelupRed", bShowLevelupRedPoint);
end

function tbUi:SetCurPartner(nPartnerId)
	if not self.nCurPartnerId or self.nCurPartnerId ~= nPartnerId then
		Partner:CloseOtherUi();
	end

	self.nCurPartnerId = nPartnerId or self.nCurPartnerId;
	self.tbPartner = me.GetPartnerInfo(self.nCurPartnerId or 0);
	if not self.tbPartner then
		self:Clear();
		return;
	end

	self.tbPartner.nAwareness = 0;
	if GetTimeFrameState(Partner.szOpenAwarenessTimeFrame) == 1 and Partner:GetAwareness(self.tbPartner.nTemplateId) then
		self.tbPartner.nAwareness = Partner:GetPartnerAwareness(me, self.tbPartner.nTemplateId);
		self.pPanel:SetActive("BtnAwareness", self.tbPartner.nAwareness ~= 1 and true or false);
	else
		self.pPanel:SetActive("BtnAwareness", false);
	end

	self.pPanel:SetActive("AwarenessMark", self.tbPartner.nAwareness == 1 and true or false);

	if Partner.tbWeaponValue[self.tbPartner.nTemplateId] then
		self.pPanel:SetActive("Weapon", self.tbPartner.nWeaponState ~= 1 and true or false);
	else
		self.pPanel:SetActive("Weapon", false);
	end

	local bCanGradeLevelup = Partner:CheckCanGradeLevelup(me, self.nCurPartnerId);
	self.pPanel:Button_SetSprite("BtnLevelup", bCanGradeLevelup and "BtnOption_02" or "BtnOption_01");
	self.pPanel:Label_SetText("BtnTxt", bCanGradeLevelup and "突破" or "升级");
	self.pPanel:SetActive("GradeLevelupRedPoint", bCanGradeLevelup and true or false);


	self.pPanel:Label_SetText("TxtSeverance", self.bHasReinitData and "洗髓结果" or "洗髓");

	self.pPanel:SetActive("QualityMark", true);
	self.pPanel:Sprite_SetSprite("QualityMark", self.tbPartner.nIsNormal == 1 and "____" or "Quality_Special");
	if self.tbPartner.nIsNormal ~= 1 then
		self.pPanel:ChangePosition("QualityMark", 74, 153);
		self.pPanel:ChangePosition("AwarenessMark", 74, 63);
	else
		self.pPanel:ChangePosition("AwarenessMark", 74, 153);
	end

	self.pPanel:Sprite_SetSprite("QualityIcon", Partner.tbQualityLevelToSpr[self.tbPartner.nQualityLevel]);

	self.pPanel:Label_SetText("Name", self.tbPartner.szName);
	self.pPanel:Label_SetText("Features", string.format("（%s）", Partner:GetGrowthTypeByTemplateId(self.tbPartner.nTemplateId)));
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%s级", self.tbPartner.nLevel));
	else
		self.pPanel:Label_SetText("Level", string.format("Lv.%s", self.tbPartner.nLevel));
	end
	local nStar = Partner:GetStarValue(self.tbPartner.nFightPower);

	for i = 1, 5 do
		self.pPanel:SetActive(tbSeries[i], i == self.tbPartner.nSeries);
	end

	local _, nResId = KNpc.GetNpcShowInfo(self.tbPartner.nNpcTemplateId);


	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	if self.tbPartner.nAwareness and self.tbPartner.nAwareness == 1 then
		self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, Partner:GetAwareness(self.tbPartner.nTemplateId).nUiEffectId);
	else
		self.pPanel:NpcView_ChangePartEffect("PartnerView", 2, 0);
	end

	self.pPanel:NpcView_SetWeaponState("PartnerView", self.tbPartner.nWeaponState);

	self:ExtUpdateSeverance();
	self:ExtUpdateLevelUp();

	local tbAllSkillInfo, pPartner = Partner:GetPartnerAllSkillInfo(me, self.nCurPartnerId);
	local tbPartnerAttrib = pPartner.GetAttribInfo();
	self:SubUpdateQualitySkill(self.tbPartner, tbAllSkillInfo, tbPartnerAttrib);

	local nPos = self.tbPartner2Pos[self.nCurPartnerId];
	if nPos and nPos > 0 then
		local tbLearnInfo = JingMai:GetLearnedXueWeiInfo(me);
		local tbAllAddAttribInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo);
		tbAllAddAttribInfo = JingMai:CombineAddInfo(tbAllAddAttribInfo, JingMai:GetJingMaiLevelAttribInfo(me, JingMai.tbJingMaiSetting))
		tbPartnerAttrib = JingMai:MgrPartnerAttrib(tbPartnerAttrib, JingMai:GetAttribInfo(tbAllAddAttribInfo.tbExtPartnerAttrib));
	end

	self.pPanel:SetActive("Meridian", (nPos and nPos > 0) and true or false);

	self:SubUpdateAttribInfoPanel(self.tbPartner, tbAllSkillInfo, tbPartnerAttrib);

	local tbSkillInfo = FightSkill:GetSkillSetting(tbAllSkillInfo.tbDefaultSkill[1].nSkillId);
	self.pPanel:Label_SetText("CompanionPersonality", string.format("同伴个性：%s", tbSkillInfo.SkillName or ""));
	self.pPanel:Label_SetText("PersonalityDescribe", string.format("%s", tbSkillInfo.Desc or ""));

	self.pPanel:Button_SetEnabled("BtnAttribInfo", true);
	self.pPanel:Button_SetCheck("BtnAttribInfo", self.pPanel:IsActive("AttribInfoPanel") and true or false);
	self:UpdateLevelupRedPoint();

	local bJingMaiOpen = JingMai:CheckOpen(me);
	self.pPanel:SetActive("BtnMeridian", bJingMaiOpen);
	self.pPanel:SetActive("Meridian", bJingMaiOpen);
	if bJingMaiOpen then
		local nDanTianValue = me.GetUserValue(JingMai.SAVE_GROUP_ID, JingMai.SAVE_INDEX_ID);
		self.pPanel:SetActive("ZhenYuan_PiLaoTeXiao", nDanTianValue > 0);
		self.pPanel:SetActive("ZhenYuan_ChongYingTeXiao", nDanTianValue <= 0);
	end
end

function tbUi:ExtUpdateSeverance()
	if not self.tbPartner then
		return;
	end

	local nItemCount = me.GetItemCountInAllPos(Partner.nSeveranceItemId);
	self.SeveranceItem:SetGenericItem({"item", Partner.nSeveranceItemId, 0});
	self.SeveranceItem.fnClick = self.SeveranceItem.DefaultClick;

	local nCostCount = Partner.ServeranceCost[self.tbPartner.nQualityLevel];
	self.SeveranceItem.pPanel:SetActive("LabelSuffix", true);

	local szCountInfo = string.format("%s/%s", nItemCount, nCostCount);
	local nDiscountCount = tbSeveranceDiscountItem:Discount(me, nCostCount, self.tbPartner.nQualityLevel)
	if nItemCount < nDiscountCount then
		szCountInfo = string.format("[FF0000FF]%s[-]", szCountInfo);
	end
	self.SeveranceItem.pPanel:Label_SetText("LabelSuffix", szCountInfo);
	self.pPanel:SetActive("Discount", false)
	if nDiscountCount ~= nCostCount then
		self.pPanel:SetActive("Discount", true)
		local nWidth = 33
		if nCostCount < 10 then
			nWidth = 22
		elseif nCostCount >= 100 then
			nWidth = 44
		end
		self.pPanel:Widget_SetSize("DiscountLine", nWidth, 4);
		local szDiscountCount = string.format("[08FF00FF]%s[-]", nDiscountCount)
		if nItemCount < nDiscountCount then
			szDiscountCount = string.format("[FF0000FF]%s[-]", nDiscountCount)
		end
			
		self.pPanel:Label_SetText("Discount", szDiscountCount)
		self.pPanel:SetActive("Discount", true)
	end
end

function tbUi:ExtUpdateLevelUp()
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%s级", self.tbPartner.nLevel));
	else
		self.pPanel:Label_SetText("Level", string.format("Lv.%s", self.tbPartner.nLevel));
	end

	self.pPanel:Label_SetText("ExpPercent", string.format("%s / %s", self.tbPartner.nExp, self.tbPartner.nLevelupExp));
	self.pPanel:Sprite_SetFillPercent("ExpBar", self.tbPartner.nExp / (math.max(self.tbPartner.nLevelupExp or 1, 1)));
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
		local nValue = tbPAttribInfo["n" .. szType];
		local nLimitLevel = tbPartnerInfo["nLimitProtential" .. szType];
		local nLimitProtential, bIsMaxGrade = Partner:GetLimitProtentialValue(tbPartnerInfo.nQualityLevel,
														tbPartnerInfo.nGrowthType,
														Partner.tbAllProtentialTypeStr2Id[szType],
														nLimitLevel,
														tbPartnerInfo.nGradeLevel + 1,
														tbPartnerInfo.nAwareness);

		local nMaxValue = tbPAttribInfo["n" .. szType] + math.max(nLimitProtential - math.floor(tbPartnerInfo["nProtential" .. szType] / Partner.tbProtentialToValue[tbPartnerInfo.nQualityLevel]), 0);
		nValue = bIsMaxGrade and math.min(nValue, nMaxValue) or nValue;
		tbValue.szInfo = string.format("%d / %d", nValue, nMaxValue);
		tbValue.nLimitLevel = nLimitLevel;
		tbValue.nValue =  nValue / nMaxValue;
		table.insert(tbInfo, tbValue);
	end
	tbUi.SetProtential(self, tbInfo);

	self.tbPSkillInfo = tbPSkillInfo;
	self.tbPPartnerInfo = tbPartnerInfo;
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

function tbUi:SubUpdateAttribInfoPanel(tbPartnerInfo, tbPSkillInfo, tbPAttribInfo)
	local tbGrowth = Partner.tbPartnerGrowthInfo[tbPartnerInfo.nGrowthType];
	local bFirstOpen = false;
	for nIdx, tbInfo in ipairs(Partner.tbAllAttribDef) do
		local szType = tbInfo[1];
		local value = 0;
		local szShowValue = nil;

		if type(tbInfo[2]) == "string" and tbInfo[2] == "Protential" then
			value = string.format("%.1f", tbGrowth[tbInfo[3]]);
		elseif type(tbInfo[2]) == "string" then
			value = Partner:GetJingMaiValueBase(tbPAttribInfo, unpack(tbInfo, 2)) or 0;
		elseif type(tbInfo[2]) == "function" then
			value, szShowValue = tbInfo[2](Partner, tbPAttribInfo, unpack(tbInfo, 3));
			value = value or 0;
		end
		value = szShowValue or value;

		if not self.pPanel:CheckHasChildren("AttribInfo" .. nIdx) then
			self.pPanel:CreateWnd("AttribInfo", "AttribInfo", tostring(nIdx));
			self.pPanel:ChangePosition("AttribInfo" .. nIdx, 0, 235 - 39.5 * nIdx - #Partner.tbAllAttribDef * 2);
			self.pPanel:SetActive("AttribInfo" .. nIdx, true);
			bFirstOpen = true;
		end

		self.pPanel:Label_SetText("AttribName" .. nIdx, szType);
		self.pPanel:Label_SetText("AttribValue" .. nIdx, type(value) == "number" and math.floor(value) or value);
	end

	self.pPanel:ResizeScrollViewBound("Attrilist", 225 - 40 * #Partner.tbAllAttribDef - #Partner.tbAllAttribDef * 2, 225 - #Partner.tbAllAttribDef * 2);
	if bFirstOpen then
		self.pPanel:DragScrollViewGoTop("Attrilist");
	end
end

function tbUi:SetProtential(tbValue)
	tbValue = tbValue or {};
	for i = 1, 4 do
		local tbInfo = tbValue[i] or {szInfo = "0 /", nMaxValue = 0, nValue = 0, nLimitLevel = 0};
		self.pPanel:Label_SetText("QualityPercent" .. i, tbInfo.szInfo);
		self.pPanel:Sprite_SetFillPercent("QualityBar" .. i, tbInfo.nValue);
		self.pPanel:Label_SetText("Character" .. i, Partner.tbPartnerLimitLevelDesc[tbInfo.nLimitLevel] or "--");
	end
end

function tbUi:SetSkill(tbSkillInfo)
	tbSkillInfo = tbSkillInfo or {};
	for i = 2, 8 do
		tbSkillInfo[i] = tbSkillInfo[i] or {};
		local nSkillId = (tbSkillInfo[i] or {})[1] or 0;
		local nSkillLevel = (tbSkillInfo[i] or {})[2];
		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		if tbValue then
			local tbInfo = Partner:GetSkillInfoBySkillId(nSkillId) or {};
			local szFrameColor = Partner.tbSkillColor[tbInfo.nQuality or 1] or "";
			self.pPanel:SetActive("Skill" .. i, true);
			self.pPanel:Sprite_SetSprite("Skill" .. i, tbValue.szIconSprite, tbValue.szIconAtlas);
			self.pPanel:Sprite_SetSprite("Color" .. i, szFrameColor);

			if i >= 4 then
				if not self.UI_NAME then
					self.pPanel:SetActive("SkillAdd" .. i, false);
				end
				self.pPanel:SetActive("SLevel" .. i, false);
			end
		else
			if not self.UI_NAME then
				if i >= 4 then
					self.pPanel:SetActive("SkillAdd" .. i, true);
				end
			end

			self.pPanel:SetActive("Skill" .. i, false);
		end
	end
end

function tbUi:OnUpdatePartner(nPartnerId)
	if self.nCurPartnerId and self.nCurPartnerId == nPartnerId then
		self:SetCurPartner(nPartnerId);
		self:UpdatePartnerPosInfo();
	end

	for i = 0, 1000 do
		local itemObj = self.PartnerListScrollView.Grid["Item"..i];
		if not itemObj then
			break;
		end

		if itemObj.nPartnerId == nPartnerId then
			local tbPartner = me.GetPartnerInfo(nPartnerId);
			itemObj.PartnerHead:SetPartnerInfo(tbPartner);
			itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", tbPartner.nFightPower));
			itemObj.pPanel:SetActive("Mark", tbPartner.nIsNormal == 0);
		end
	end

	self:UpdateGradeLevelupRedPoint();
end

function tbUi:OnAddPartner(nPartnerId)
end

function tbUi:OnPartnerGradeLevelup(nPartnerId, nOldGradeLevel, nNewGradeLevel)
	self:UpdateGradeLevelupRedPoint();
	if nPartnerId ~= self.nCurPartnerId then
		return;
	end

	local bCanGradeLevelup = Partner:CheckCanGradeLevelup(me, self.nCurPartnerId);
	self.pPanel:Button_SetSprite("BtnLevelup", bCanGradeLevelup and "BtnOption_02" or "BtnOption_01");
	self.pPanel:Label_SetText("BtnTxt", bCanGradeLevelup and "突破" or "升级");
	self.pPanel:SetActive("GradeLevelupRedPoint", bCanGradeLevelup and true or false);

	self.pPanel:SetActive("GradeLevelupEffect", false);
	self.pPanel:SetActive("GradeLevelupEffect", true);

	local bShowAni = not self.pPanel:IsActive("AttribInfoPanel");
	if not bShowAni then
		self:SetCurPartner(nPartnerId);
	end

	local tbPartnerInfo = me.GetPartnerInfo(nPartnerId);
	local pPartner = me.GetPartnerObj(nPartnerId);
	local tbPAttribInfo = pPartner.GetAttribInfo();
	local tbShowInfo = {};
	for i, szType in ipairs(self.tbProtentialList) do
		local tbValue = {};
		local nValue = tbPAttribInfo["n" .. szType];
		local nLimitProtential = Partner:GetLimitProtentialValue(tbPartnerInfo.nQualityLevel,
														tbPartnerInfo.nGrowthType,
														Partner.tbAllProtentialTypeStr2Id[szType],
														tbPartnerInfo["nLimitProtential" .. szType],
														tbPartnerInfo.nGradeLevel + 1,
														Partner:GetPartnerAwareness(me, tbPartnerInfo.nTemplateId));

		local nMaxValue = tbPAttribInfo["n" .. szType] + math.max(nLimitProtential - math.floor(tbPartnerInfo["nProtential" .. szType] / Partner.tbProtentialToValue[tbPartnerInfo.nQualityLevel]), 0);

		local szInfo  = self.pPanel:Label_GetText("QualityPercent" .. i);
		local nOldMaxValue = string.match(szInfo, "/ (%d+)$") or "0";
		nOldMaxValue = tonumber(nOldMaxValue) or 0;

		tbShowInfo[i] = {};
		tbShowInfo[i][1] = nOldMaxValue;
		tbShowInfo[i][2] = nMaxValue;
		if bShowAni then
			self.pPanel:Label_SetText("QualityPercent" .. i, string.format("%d / %d", nValue, nMaxValue));
			self.pPanel:Tween_FillAmountPlay("QualityBar" .. i, 0, nValue / nMaxValue, 0.7);
		end
	end

	Ui:OpenWindow("PartnerGradeLevelup", tbShowInfo);
end

function tbUi:OnSyncItem(nItemId, bUpdateAll)
	if bUpdateAll then
		self:ExtUpdateSeverance();
	else
		local pItem = KItem.GetItemObj(nItemId);
		if pItem and pItem.dwTemplateId == Partner.nSeveranceItemId then
			self:ExtUpdateSeverance();
		end
	end
end

function tbUi:OnClickSkill(nIdx, tbExtSkillId)
	local nSkillId = 0;
	local nSkillLevel = 1;
	local nMaxLevel = 1;
	local bNoPos = false;
	local tbExtProtectSkillId
	if nIdx <= 3 then
		nSkillId = self.tbPSkillInfo.tbDefaultSkill[nIdx].nSkillId;
		nSkillLevel = self.tbPSkillInfo.tbDefaultSkill[nIdx].nSkillLevel;

		if nIdx == 2 then
			if not self.UI_NAME then
				local _, nStarLevel = Partner:GetStarValue(self.tbPartner.nFightPower);
				nSkillLevel = Partner.tbFightPowerToSkillLevel[nStarLevel] or 1;
			end
			local nMaxFightPower = Partner:GetMaxFightPower(self.tbPPartnerInfo);
			local _, nMaxStar = Partner:GetStarValue(nMaxFightPower);
			nMaxLevel = math.max(Partner.tbFightPowerToSkillLevel[nMaxStar] or 1, nSkillLevel);

			if self.tbPartner2Pos and self.nCurPartnerId and self.tbPartner2Pos[self.nCurPartnerId] then
				local nExtLevel = me.GetSkillFlagLevel(nSkillId);
				nSkillLevel = nSkillLevel + nExtLevel;
				nMaxLevel = nMaxLevel + nExtLevel;
			else
				bNoPos = true;
			end
			tbExtProtectSkillId = tbExtSkillId
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
	if not nIdx or self.UI_NAME then
		local tbSkillId
		if self.nCurPartnerId then
			local tbPartnerInfo = me.GetPartnerInfo(self.nCurPartnerId) or {}
			tbSkillId = PartnerCard:GetActiveSkillId(me, tbPartnerInfo.nTemplateId, self:GetPartnerPos(self.nCurPartnerId))
		else
			tbSkillId = tbExtProtectSkillId
		end
		Partner:ShowSkillTips(nSkillId, nSkillLevel, nMaxLevel, bNoPos, tbSkillId);
	else
		Ui:OpenWindow("PartnerSkillTips", self.nCurPartnerId, nIdx);
	end
end

function tbUi:GetPartnerPos(nPartnerId)
	local nPartnerPos = 0
	for nPos, nId in pairs(self.tbPosInfo) do
		if nPartnerId == nId then
			nPartnerPos = nPos
			break
		end
	end
	return nPartnerPos
end

function tbUi:OnAddSkill(nIdx)
	local tbItemList = {};
	local tbTmp = {};
	local tbAllBook = me.FindItemInBag("PartnerSkillBook");
	for _, pItem in pairs(tbAllBook) do
		if not tbTmp[pItem.dwTemplateId] then
			local bRet = Partner:CheckCanUseSkillBook(me, self.nCurPartnerId, pItem.dwId);
			if bRet then
				table.insert(tbItemList, pItem.dwId);
				tbTmp[pItem.dwTemplateId] = true;
			end
		end
	end

	table.sort(tbItemList);
	if #tbItemList > 0 then
		Ui:OpenWindow("PartnerSelectSkillBook", self.nCurPartnerId, tbItemList);
		return;
	end

	me.MsgBox(string.format("无可用技能书，是否前往摆摊购买？"),
		{
			{"前往", function () Ui:OpenWindow("MarketStallPanel", 1, 7); end },
			{"取消"}
		});
end

function tbUi:UpdatePartnerPosInfo(tbPosInfo)
	if not tbPosInfo then
		self.bForbidenOperation = false;
		self.bHasChange = false;
	end

	self.tbPosInfo = tbPosInfo or me.GetPartnerPosInfo();
	self.tbPartner2Pos = {};
	for i = 1 , 4 do
		local nPartnerId = self.tbPosInfo[i];
		self.tbAllPartner[nPartnerId] = me.GetPartnerInfo(nPartnerId);
		local tbPartner = self.tbAllPartner[nPartnerId];
		if tbPartner then
			self.tbPartner2Pos[nPartnerId] = i;
			self["Pos" .. i]:SetPartnerInfo(tbPartner);
			self["Pos" .. i].pPanel:SetActive("Main", true);
		else
			self["Pos" .. i]:Clear();
			self["Pos" .. i].pPanel:SetActive("Main", false);
		end

		self.pPanel:SetActive("Lock" .. i, me.nLevel < Partner.tbPosNeedLevel[i]);
		self.pPanel:Label_SetText("Label" .. i, string.format("%s级开放", Partner.tbPosNeedLevel[i]));
	end

	for i = 0, 1000 do
		local itemObj = self.PartnerListScrollView.Grid["Item" .. i];
		if not itemObj then
			break;
		end

		itemObj.BtnCheck:SetCheck(self.tbPartner2Pos[itemObj.nPartnerId] and true or false);
	end
	self:UpdateLevelupRedPoint();
	self:SetCurPartner(self.nCurPartnerId);
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

function tbUi:ExchangePartnerPos(nPos1, nPos2)
	if self.bForbidenOperation then
		return;
	end

	if not nPos1 or not nPos2 or me.nLevel < Partner.tbPosNeedLevel[nPos1] or me.nLevel < Partner.tbPosNeedLevel[nPos2] then
		return;
	end

	if not self.tbPosInfo[nPos1] or self.tbPosInfo[nPos1] <= 0 then
		return;
	end

	local nPId1, nPId2 = self.tbPosInfo[nPos1], self.tbPosInfo[nPos2];
	self.tbPartner2Pos[nPId1], self.tbPartner2Pos[nPId2] = self.tbPartner2Pos[nPId2], self.tbPartner2Pos[nPId1];
	self.tbPosInfo[nPos1], self.tbPosInfo[nPos2] = self.tbPosInfo[nPos2], self.tbPosInfo[nPos1];
	self.bHasChange = true;
	self:UpdatePartnerPosInfo(self.tbPosInfo);
end

function tbUi:SetPartnerToPos(nPartnerId, nPos)
	self.tbPosInfo = self.tbPosInfo or {};
	if not nPos then
		for i = 1, 4 do
			if self.tbPosInfo[i] <= 0 then
				nPos = i;
				break;
			end
		end
	end

	local bRet, szMsg = self:CheckCanSetPos(nPartnerId, nPos);
	if not bRet then
		if szMsg then
			me.CenterMsg(szMsg);
		end
		return;
	end

	local pPartner = me.GetPartnerObj(nPartnerId);
	if pPartner then
		local tbDefaultSkill = GetPartnerDefaultSkill(pPartner.nTemplateId);
		local nProtectSkillId = tbDefaultSkill[2];

		for _, nPId in pairs(self.tbPosInfo) do
			local pPartner = me.GetPartnerObj(nPId);
			if pPartner then
				local tbDS = GetPartnerDefaultSkill(pPartner.nTemplateId);
				if nProtectSkillId == tbDS[2] then
					me.MsgBox("上阵同伴中存在多个相同的护主技能。\n[FFFE0D]（相同的护主技能高等级的生效）[-]", {{"确定"}});
				end
			end
		end
	end

	self.tbPartner2Pos[self.tbPosInfo[nPos]] = nil;
	self.tbPartner2Pos[nPartnerId] = nPos;
	self.tbPosInfo[nPos] = nPartnerId;
	self.bHasChange = true;

	self:UpdatePartnerPosInfo(self.tbPosInfo);
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

function tbUi:DoSyncPartnerPos()
	if not self.bHasChange then
		return;
	end

	self.bForbidenOperation = true;
	RemoteServer.CallPartnerFunc("SetPartnerPos", self.tbPosInfo);
end

tbUi.tbOnDrag = tbUi.tbOnDrag or {};
tbUi.tbOnDrag.PartnerView = function (self, szWnd, nX, nY)
	self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
end

tbUi.tbOnDrop = tbUi.tbOnDrop or {};
tbUi.tbOnClick = tbUi.tbOnClick or {};
for i = 1, 4 do
	tbUi.tbOnDrag["BPos"..i] = function (self, ...)
		if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
			return;
		end
		self:StartDragPartnerPos(i)
	end
	tbUi.tbOnDrop["BPos"..i] = function (self, szWnd, szDropWnd)
		if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
			return;
		end
		local nPos1 = string.match(szDropWnd, "BPos(%d)");
		local nPos2 = string.match(szWnd, "BPos(%d)");
		if nPos1 and nPos2 then
			self:ExchangePartnerPos(tonumber(nPos1), tonumber(nPos2));
		end
	end
end

tbUi.tbOnClick.BtnRecruit = function (self)
	Ui("Partner"):Update(tbPartnerUi.CARDPICKING_PANEL);
end

tbUi.tbOnClick.BtnCompanionArray = function (self)
	if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
		me.CenterMsg("当前没有同伴");
		return;
	end

	self:DoSyncPartnerPos();
	RemoteServer.ConfirmPartnerPos();
	Ui:OpenWindow("PartnerArrayPanel");
end

for i = 2, 8 do
	tbUi.tbOnClick["Skill" .. i] = function (self)
		if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
			me.CenterMsg("当前没有同伴");
			return;
		end

		self:OnClickSkill(i);
	end

	if i >= 4 then
		tbUi.tbOnClick["SkillAdd" .. i] = function (self)
			if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
				me.CenterMsg("当前没有同伴");
				return;
			end

			self:OnAddSkill(i);
		end
	end
end


for i = 1, 4 do
	tbUi.tbOnClick["Quality" .. i] = function (self)
		if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
			me.CenterMsg("当前没有同伴");
			return;
		end

		Ui:OpenWindow("PartnerProtential", self.nCurPartnerId, self.tbProtentialList[i]);
	end
end

tbUi.tbOnClick.BtnSeverance = function (self)
	if self.bHasReinitData then
		RemoteServer.CallPartnerFunc("CheckReinitResult");
		return;
	end

	if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
		me.CenterMsg("当前没有同伴");
		return;
	end

	local pPartner = me.GetPartnerObj(self.nCurPartnerId);
	if pPartner then
		local _, nQualityLevel = GetOnePartnerBaseInfo(pPartner.nTemplateId);
		local nCost = Partner.ServeranceCost[nQualityLevel];
		local nDiscountCount = tbSeveranceDiscountItem:Discount(me, nCost, nQualityLevel)
		local nCount = me.GetItemCountInAllPos(Partner.nSeveranceItemId);
		if not nCount or nCount < nDiscountCount then
			MarketStall:TipBuyItemFromShop(me, Partner.nSeveranceItemId);
			return;
		end
	end

	local bRet, szMsg = Partner:CheckReinitPartner(me, self.nCurPartnerId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local szMsg = "洗髓后同伴的 [FFFE0D]潜能、技能[-] 将会重新生成，是否继续？";
	if self.tbPartner.nIsNormal == 0 then
		szMsg = "洗髓后 [FFFE0D]奇才同伴[-] 可能会变成普通同伴，是否继续？";
	end

	if szMsg then
		me.MsgBox(szMsg, { {"确定", function ()
			RemoteServer.CallPartnerFunc("ReInitPartner", self.nCurPartnerId);
		end}, {"取消"}});
	else
		RemoteServer.CallPartnerFunc("ReInitPartner", self.nCurPartnerId);
	end
end

tbUi.tbOnClick.BtnAwareness = function (self)
	Ui:OpenWindow("PartnerAwarenessPanel", self.nCurPartnerId);
end

tbUi.tbOnClick.Weapon = function (self)
	RemoteServer.CallPartnerFunc("UseWeapon", self.nCurPartnerId);
end

tbUi.tbOnClick.BtnLevelup = function (self)
	if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
		me.CenterMsg("当前没有同伴");
		return;
	end

	local pPartner = me.GetPartnerObj(self.nCurPartnerId);
	if not pPartner then
		return;
	end

	local bRet = Partner:CheckCanGradeLevelup(me, self.nCurPartnerId);
	if bRet then
		RemoteServer.CallPartnerFunc("GradeLevelup", self.nCurPartnerId);
		return;
	end

	Ui:OpenWindow("PartnerExpUse", self.nCurPartnerId)
end

tbUi.tbOnClick.BtnAttribInfo = function (self)
	if not self.nCurPartnerId or self.nCurPartnerId <= 0 then
		me.CenterMsg("当前没有同伴");
		return;
	end

	local bCheck = self.pPanel:Button_GetCheck("BtnAttribInfo");
	self.pPanel:SetActive("Quality", not bCheck);
	self.pPanel:SetActive("AttribInfoPanel", bCheck);
	self:SetCurPartner();
end

tbUi.tbOnClick.BtnMeridian = function (self)
	--self.pPanel:SetActive("BtnMeridianRedPoint", false);
	Ui:OpenWindow("JingMaiPanel");
	Ui:CloseWindow("Partner")
end

tbUi.tbOnClick.Meridian = function (self)
	local tbLearnInfo, bHasNoPartner, tbJingMaiLevelInfo = JingMai:GetLearnedXueWeiInfo(me);
	local tbAddInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo);
	tbAddInfo = JingMai:CombineAddInfo(tbAddInfo, JingMai:GetJingMaiLevelAttribInfo(nil, JingMai.tbJingMaiSetting, tbJingMaiLevelInfo))
	Ui:OpenWindow("JingMaiTipsPanel", tbAddInfo.tbExtPartnerAttrib, tbAddInfo.tbPartnerSkill, bHasNoPartner, tbJingMaiLevelInfo);
end

tbUi.tbOnClick.Dantian = function (self)
	local nDanTianValue = me.GetUserValue(JingMai.SAVE_GROUP_ID, JingMai.SAVE_INDEX_ID);
	local szTips = "丹田状态：[FFFE0D]充盈[-]\n\n丹田处于充盈状态，给同伴使用\n[FFFE0D]资质丹[-]能获得[FFFE0D]真气值[-]！";
	if nDanTianValue > 0 then
		szTips = string.format("丹田状态：[FF0000]疲劳[-]\n疲劳度：[FF0000]%s[-]\n\n丹田处于疲劳状态，使用资质丹\n可以降低[FFFE0D]疲劳度[-]，以让丹田重新\n[FFFE0D]充盈[-]！", nDanTianValue);
	end
	Ui:OpenWindowAtPos("TxtTipPanel", 300, -95, szTips);
end

---------------------------------------- PartnerMainPanelItem

local tbItem = Ui:CreateClass("PartnerMainPanelItem");
function tbItem:SetCheck(bCheck)
	self.pPanel:SetActive("Check", bCheck);
end
