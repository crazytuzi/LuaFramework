
-- 红点检查
function Partner:UpdateRedPoint()
	self:CheckMainRedPoint();
	self:CheckCardPickRedPoint();
	Ui:CheckRedPoint("Partner");
end

function Partner:CheckCardPickRedPoint()
	if me.nLevel < CardPicker.Def.OpenLevel then
		Ui:ClearRedPointNotify("PartnerCardPickPanel");
		return;
	end

	local nNow = GetTime();
	local nNextFreePickTime = CardPicker:GetNextFreePickTime();
	local nNextCoinFreePick = CardPicker:GetNextCoinFreePickTime();

	if nNow > nNextCoinFreePick or nNow > nNextFreePickTime then
		Ui:SetRedPointNotify("PartnerCardPickPanel");
	else
		Ui:ClearRedPointNotify("PartnerCardPickPanel");
	end
end

function Partner:CheckMainRedPoint()
	if JingMai:CheckJingMaiMainPanelRP(me) then
		Ui:SetRedPointNotify("PartnerMainPanel");
		return true;
	end

	local tbPosInfo = me.GetPartnerPosInfo();
	for _, nPartnerId in pairs(tbPosInfo) do
		if self:CheckPartnerRedPoint(nPartnerId) then
			Ui:SetRedPointNotify("PartnerMainPanel");
			return true;
		end
	end

	Ui:ClearRedPointNotify("PartnerMainPanel");
	return false;
end

function Partner:CheckPartnerRedPoint(nPartnerId)
	local tbPartner = me.GetPartnerInfo(nPartnerId or 0);
	if not tbPartner then
		return false;
	end

	return false;
end

function Partner:ClearGralleryRedPoint()
	local tbInfo = Client:GetUserInfo("PartnerRedPoint");
	tbInfo.Grallery = tbInfo.Grallery or {};
	tbInfo.Grallery = {};

	Ui:CheckRedPoint("Partner");
	Client:SaveUserInfo();
end

function Partner:SetGralleryRedPoint(nPartnerId)
	local tbInfo = Client:GetUserInfo("PartnerRedPoint");
	tbInfo.Grallery = tbInfo.Grallery or {};
	local szName = GetOnePartnerBaseInfo(nPartnerId);
	if not szName then
		return;
	end

	tbInfo.Grallery[nPartnerId] = 1;
	Client:SaveUserInfo();
end

function Partner:GetGralleryRedPoint()
	local tbInfo = Client:GetUserInfo("PartnerRedPoint");
	tbInfo.Grallery = tbInfo.Grallery or {};
	return tbInfo.Grallery;
end

function Partner:GetSkillShowInfo(nSkillId, nSkillLevel, nMaxLevel, bNoPos, tbExtSkillId, szExtDes)
	nSkillLevel = math.max(nSkillLevel, 1);
	nMaxLevel = nMaxLevel or 1;

	local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId);
	local bMax = nSkillLevel >= nMaxLevel;
	local szCurMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel) or "";
	local szNextMagicDesc = nSkillLevel + 1 <= nMaxLevel and FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel + 1) or "";
	local szExtCurMagicDesc = ""
	local szExtNextMagicDesc = ""
	if tbExtSkillId then
		for _, nExtSkillId in ipairs(tbExtSkillId) do
			szExtCurMagicDesc = szExtCurMagicDesc ..(FightSkill:GetSkillMagicDesc(nExtSkillId, nSkillLevel) or "");
			szExtNextMagicDesc = szExtNextMagicDesc ..(nSkillLevel + 1 <= nMaxLevel and FightSkill:GetSkillMagicDesc(nExtSkillId, nSkillLevel + 1) or "");
		end
	end
	local tbSkillShowInfo = {
			nId				= nSkillId,
			nLevel 			= nSkillLevel,
			nMaxLevel		= nMaxLevel,
			bMax			= bMax,

			szIcon			= tbSkillInfo.Icon or "",
			szName			= tbSkillInfo.SkillName or "",
			szDesc			= tbSkillInfo.Desc or "",
			szProperty		= tbSkillInfo.Property or "",
			nCD				= tbSkillInfo.TimePerCast or 0,
			bPassive		= tbSkillInfo.SkillType == 3,
			nRadius			= tbSkillInfo.AttackRadius or 0,

			szCurMagicDesc = szCurMagicDesc or "",
			szNextMagicDesc = szNextMagicDesc or "",

			szExtCurMagicDesc = szExtCurMagicDesc or "",
			szExtNextMagicDesc = szExtNextMagicDesc or "",
			szExtDes = szExtDes,
		}
	if not bMax then
		tbSkillShowInfo.szNextLvFighTips = self:FormatNeedFightPowerTips(nSkillId, nSkillLevel + 1, bNoPos)
	end
	return tbSkillShowInfo;
end

--bNoPos：没上阵
function Partner:ShowSkillTips(nSkillId, nSkillLevel, nMaxLevel, bNoPos, tbExtSkillId, szExtDes)
	local tbSkillShowInfo = self:GetSkillShowInfo(nSkillId, nSkillLevel, nMaxLevel, bNoPos, tbExtSkillId, szExtDes);
	Ui:OpenWindow("SkillShow", tbSkillShowInfo);
end

function Partner:OnComposeSuccess(nItemTemplateId, dwId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_ONCOMPOSE_CALLBACK, nItemTemplateId, dwId);
end

--UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ITEM, Partner.UpdateRedPoint, Partner);
--UiNotify:RegistNotify(UiNotify.emNOTIFY_DEL_ITEM, Partner.UpdateRedPoint, Partner);
--UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_MONEY, Partner.UpdateRedPoint, Partner);
--PlayerEvent:RegisterGlobal("OnLevelUp",			Partner.UpdateRedPoint, Partner);

function Partner:PGInit()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PG_INIT);
end

function Partner:PGClose()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PG_CLOSE);
end

function Partner:PGForbiddenPartner()
	UiNotify.OnNotify(UiNotify.emNOTIFY_FORBIDDEN_PARTNER);
end

function Partner:PGPartnerDeath(nPos)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_DEATH, nPos);
end

function Partner:PGPartnerNpcChange(bIsAdd, nNpcId, nPos)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_NPC_CHANGE, bIsAdd, nNpcId, nPos);
end

function Partner:PGSwitchToGroup(nGroupId, bFixGroupID, nFirstPartnerNpcId, nSecondPartnerNpcId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_SWITCH_GROUP, nGroupId, bFixGroupID, nFirstPartnerNpcId, nSecondPartnerNpcId);
end

function Partner:PGAwarenessFinish(nPartnerId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_AWARENESS, nPartnerId);
end

function Partner:SyncHasReinitData(bHasData)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_REINITDATA, bHasData);
end

function Partner:OnGradeLevelup(nPartnerId, nGradeLevel)
	me.CenterMsg("突破成功，各项潜能上限得到提升");
	local pPartner = me.GetPartnerObj(nPartnerId);
	if not pPartner then
		return;
	end

	local nOldGradeLevel = pPartner.GetGradeLevel();
	pPartner.SetGradeLevel(nGradeLevel);
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_GRADE_LEVELUP, nPartnerId, nOldGradeLevel + 1, nGradeLevel + 1);
end


function Partner:ChangePartnerFightID(nPartnerId)
    local tbPartner = me.GetPartnerInfo(nPartnerId);
    if not tbPartner then
    	return;
    end

    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_FIGHTPARTNER_ID, nPartnerId);
end

function Partner:FormatNeedFightPowerTips(nSkillId, nSkillLevel, bNoPos)
	local nExtLevel = 0
	if not bNoPos then
		nExtLevel = me.GetSkillFlagLevel(nSkillId)
	end
	local nFightPower = self.tbStarDef[nSkillLevel - nExtLevel]
	if nFightPower then
		return string.format("[FFFE0D]  （需要同伴战力达到%d）[-]", nFightPower)
	end
end

function Partner:GetPartnerIdByPos(nPartnerPos)
	local tbPosInfo = me.GetPartnerPosInfo()
	for nPos, nPartnerId in pairs(tbPosInfo) do
		if nPartnerPos == nPos then
			return nPartnerId
		end
	end
end