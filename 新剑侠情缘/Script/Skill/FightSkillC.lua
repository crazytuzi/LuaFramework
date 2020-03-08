
Require("CommonScript/Skill/FightSkill.lua");
Require("CommonScript/Item/XiuLian.lua");
Require("CommonScript/Shop/Shop.lua");

FightSkill.tbFightSkillSlot = FightSkill.tbFightSkillSlot or {};
FightSkill.tbSelectorType =
{
    ["hurt_maxhp"] = 1;
    ["flag_npc"] = 2;
}

function FightSkill:GetSelectorSkill(nSkillId)
    if not self.tbSelectorSkill then
        self.tbSelectorSkill = LoadTabFile("Setting/Skill/SkillSelector.tab", "dsds", "SkillId", {"SkillId", "SelectorType", "SelectorRange", "Relation"});
    end
    return self.tbSelectorSkill[nSkillId]
end

function FightSkill:GetSkillSlotByID(nSkillId)
    if not self.tbSkillSlotSetting then
        self.tbSkillSlotSetting = {};
        local tbFileData = LoadTabFile("Setting/Skill/SkillSlot.tab", "dsss", nil, {"SkillID", "IconAltlas", "Icon", "BtnName1"})
        for _, tbInfo in pairs(tbFileData) do
            local tbSlotInfo = {};
            tbSlotInfo.nSkillId = tbInfo.SkillID;
            tbSlotInfo.szIconAltlas = tbInfo.IconAltlas;
            tbSlotInfo.szIcon = tbInfo.Icon;
            tbSlotInfo.tbBtnName = {};
            for nI = 1, 5 do
                if tbInfo["BtnName"..nI] and not Lib:IsEmptyStr(tbInfo["BtnName"..nI]) then
                    table.insert(tbSlotInfo.tbBtnName, tbInfo["BtnName"..nI]);
                end
            end

            self.tbSkillSlotSetting[tbSlotInfo.nSkillId] = tbSlotInfo;
        end
    end
    return self.tbSkillSlotSetting[nSkillId];
end

function FightSkill:OnAddFightSkill(nSkillId, nLevel)
    local tbSlotInfo = self:GetSkillSlotByID(nSkillId);
    if tbSlotInfo then
        Timer:Register(1, self.AddFightSkillSlot, self, nSkillId);
    end
end

function FightSkill:OnRemoveSkillState(nSkillId)
    local nCount = Lib:CountTB(self.tbFightSkillSlot);
    if nCount > 0 then
        Timer:Register(3, self.UpdateHaveSkillSlot, self);
    end
end

function FightSkill:UpdateHaveSkillSlot()
    local nCount = Lib:CountTB(self.tbFightSkillSlot);
    if nCount <= 0 then
        return;
    end

    local pNpc = me.GetNpc();
    if not pNpc then
        return;
    end

    local tbRemove = {};
    for nSkillId, _ in pairs(self.tbFightSkillSlot) do
        local nLevel = me.GetSkillLevel(nSkillId);
        if nLevel <= 0 then
            tbRemove[nSkillId] = 1;
        end
    end

    for nSkillId, _ in pairs(tbRemove) do
        self:RemoveFightSkillSlot(nSkillId);
    end
end

function FightSkill:AddFightSkillSlot(nSkillId)
    self:UpdateHaveSkillSlot();
    local tbSlot = self:GetSkillSlotByID(nSkillId);
    if not tbSlot then
        return;
    end

    local pNpc = me.GetNpc();
    if not pNpc then
        return;
    end

    local nLevel = me.GetSkillLevel(nSkillId);
    if nLevel <= 0 then
        return;
    end

    self.tbFightSkillSlot[nSkillId] = 1;
    UiNotify.OnNotify(UiNotify.emNOTIFY_ADD_SKILL_SLOT, nSkillId);
end

function FightSkill:RemoveFightSkillSlot(nSkillId)
    if not self.tbFightSkillSlot[nSkillId] then
        return;
    end

    self.tbFightSkillSlot[nSkillId] = nil;
    UiNotify.OnNotify(UiNotify.emNOTIFY_REMOVE_SKILL_SLOT, nSkillId);
end

function FightSkill:OnAddAnger(pNpc, nAnger)
    local pPlayer = pNpc.GetPlayer();
    if pPlayer then
        Ui("HomeScreenBattle"):UpdateAnger();
    end

    if pNpc.nMasterNpcId == me.GetNpc().nId then
        Ui("HomeScreenBattle"):UpdatePartnerAnger(pNpc);
    end
end

function FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel)
    if not self.tbSkillDesc then
        self.tbSkillDesc = LoadTabFile("Setting/Skill/SkillDesc.tab", "ds", "SkillId", {"SkillId", "MagicDesc"});
    end
	local tbSetting = self.tbSkillDesc[nSkillId];
	if not tbSetting then
		return "";
	end

	local szMagicDesc = FightSkill:GetSkillMagicDescEx(tbSetting.MagicDesc, nSkillId, nSkillLevel);
    return szMagicDesc;
end

FightSkill.tbMagicKeyValue =
{
    ["t_magicshield1"] = function (nSkillId, nSkillLevel, szValue)
        local pNpc = me.GetNpc();
        if pNpc and FightSkill.bCalcValue then
            local tbState = pNpc.GetState(Npc.STATE.SHIELD);
            if tbState and tbState.nParam ~= 0 then
                return tostring(tbState.nParam);
            end
        end

        local nValue = me.GetSkillAddShield(nSkillId) + (tonumber(szValue) or 0);
        nValue = math.floor(nValue * me.nDexterity / 100);
        return tostring(nValue);
    end;
}

function FightSkill:GetSkillMagicDescEx(szMagicDesc, nSkillId, nSkillLevel, tbSkillMagic, bRealTime)
    --Log("[DEBUG][GetSkillMagicDescEx]", nSkillId, nSkillLevel, tbSkillMagic, bRealTime);

    local tbMagicValue = {};
    if not tbSkillMagic then
        tbSkillMagic = KFightSkill.GetSkillAllMagic(nSkillId, nSkillLevel);
        --Log("[DEBUG][GetSkillMagicDescEx2]tbSkillMagic=", tbSkillMagic);
    end

    self:FormatMagicAttrib(tbSkillMagic, tbMagicValue, nSkillLevel, bRealTime);

    for szKey, szValue in pairs(tbMagicValue) do
        if self.tbMagicKeyValue["t_"..szKey] and not Lib:IsEmptyStr(string.match(szMagicDesc, "t_"..szKey)) then
            szKey = "t_"..szKey;
            szValue = self.tbMagicKeyValue[szKey](nSkillId, nSkillLevel, szValue) or szValue;
        end

        local szFind = string.match(szMagicDesc, szKey .. "/(%d[.%d]+)");
        if szFind and szFind ~= "" then
            szValue = tostring(math.abs(tonumber(szValue)) / tonumber(szFind));
            szValue = math.floor(tonumber(szValue)*100)/100;
            --szValue = string.format("%.1f", szValue);
            --szValue = string.gsub(szValue, "%.0", "");
            szMagicDesc = string.gsub(szMagicDesc, szKey .. "/(%d[.%d]+)", szValue);
        else
            local szCurValue = szValue;
            local nValue = tonumber(szValue);
            if nValue ~= nil then
                szCurValue = tostring(math.abs(nValue));
            end

            szMagicDesc = string.gsub(szMagicDesc, szKey, szCurValue);
        end
    end
    return szMagicDesc;
end

function FightSkill:FormatMagicAttrib(tbSkillMagic, tbMagicValue, nSkillLevel, bRealTime)
	if type(tbSkillMagic) == "number" then
	    Log("cccccccc[FightSkill:FormatMagicAttrib]return1,tbSkillMagic=", tbSkillMagic, nSkillLevel, bRealTime);
		Log(debug.traceback())
        return;
    end

    if ((not tbSkillMagic) or tbSkillMagic == 0) then
	    Log("cccccccc[FightSkill:FormatMagicAttrib]return2");
        return;
    end

    for _, tbMA in pairs(tbSkillMagic) do
        local bUserDesc = string.find(tbMA.szName, "userdesc_000");
        if bUserDesc then
            for i = 1, 3 do
                local nDescSkillId = tbMA.tbValue[i];
                if nDescSkillId ~= 0 then
                    local tbDescSkillMagic = KFightSkill.GetSkillAllMagic(nDescSkillId, nSkillLevel);
                    self:FormatMagicAttrib(tbDescSkillMagic, tbMagicValue, nSkillLevel, bRealTime);
                end
            end
        elseif not Lib:IsEmptyStr(tbMA.szName) then
            local tbMult
            for i = 1, 3 do
                local szKey = tbMA.szName .. i;
                --如果tbSkillMagic有重复的属性，那么此处需叠加起来。叠加规则按照MultMagicType.tab(换包版本处理)
                local nValue = tbMA.tbValue[i]
                if bRealTime and tbMagicValue[szKey] and tbMagicValue[szKey] ~= 0 then
                    tbMult = tbMult or KFightSkill.GetMagicValueMult(tbMA.szName)
                    if tbMult[i] > 0 then
                        nValue = nValue + tbMagicValue[szKey]
                    end
                end
                tbMagicValue[szKey] = nValue;
            end
        end
    end
end


FightSkill.AttackType = {
    Normal    = 1;
    Direction = 2;
    Target    = 3;
}

function FightSkill:GetSkillAttackInfo(nSkillId)
    if not self.tbSkillAttackType then
        self.tbSkillAttackType = LoadTabFile(
            "Setting/Skill/AttackSkill.tab", "ddd", "SkillId", {"SkillId", "AttackType", "AutoFightTarget"});
    end
    return self.tbSkillAttackType[nSkillId]
end

function FightSkill:GetSkillAttackType(nSkillId)
    local tbInfo = self:GetSkillAttackInfo(nSkillId)
    if tbInfo then
        return tbInfo.AttackType;
    end

    return FightSkill.AttackType.Normal;
end

function FightSkill:IsTeamFollowAttackNeedTarget(nSkillId)
    local tbSkillInfo = FightSkill:GetSkillAttackInfo(nSkillId) or {};
    return tbSkillInfo.AutoFightTarget == 1;
end

FightSkill.tbStateFunDesc =
{
    [XiuLian.tbDef.nXiuLianBuffId] = function (nSkillId, nSkillLevel)
        local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel);
        if not tbStateEffect then
            return "";
        end

        local szMagicDesc = FightSkill:GetSkillMagicDescEx(tbStateEffect.MagicDesc, nSkillId, nSkillLevel);
        local nResidueExp = me.GetUserValue(XiuLian.tbDef.nSaveGroupID, XiuLian.tbDef.nSaveResidueExp);
        return string.format(szMagicDesc, math.floor(XiuLian.tbDef.nAddExpPercent / 100), nResidueExp);
    end;

    [FriendShip.nTeamHelpBuffId] = function (nSkillId, nSkillLevel)
        return FriendShip:GetTeamAddExpDesc()
    end;

    [Shop.MONEY_DEBT_BUFF] = function (nSkillId, nSkillLevel)
        return Player:GetMoneyDebtDesc()
    end;
}

function FightSkill:ExtraSkillMagicDesc(nSkillId, nSkillLevel, nValue, szType, szKey)
    local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel);
    if not tbStateEffect then
        return "";
    end

    local szMagicDesc = FightSkill:GetSkillMagicDescEx(tbStateEffect.MagicDesc, nSkillId, nSkillLevel);
    if szKey == "YJXB_DIE_NO_DROP" then
        return string.format(szMagicDesc, Fuben.KeyQuestFuben:GetForbitDeathDropCount(nValue))
    end
    return string.format(szMagicDesc, string.format("%d%%", nValue * 100));
end

function FightSkill:GetSkillStateMagicDesc(nSkillId, nSkillLevel, tbSkillMagic, bRealTime)
    local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel);
    if not tbStateEffect then
        return "";
    end

    local funDescFun = self.tbStateFunDesc[nSkillId]
    if funDescFun then
        return funDescFun(nSkillId, nSkillLevel);
    end

    local nValue, szType, szKey = Player:GetExtraSkillValue(nSkillId, nSkillLevel)
    if nValue then
        return self:ExtraSkillMagicDesc(nSkillId, nSkillLevel, nValue, szType, szKey)
    end

    local szMagicDesc = tbStateEffect.MagicDesc
    if bRealTime then
        local szAdd = self.AdditionAnalyse:GetSkillAdditionDesc(nSkillId)
        if not Lib:IsEmptyStr(szAdd) then
            if Lib:IsEmptyStr(szMagicDesc) then
                szMagicDesc = szAdd
            else
                szMagicDesc = string.format("%s\n%s", szMagicDesc, szAdd)
            end
        end
    end
    szMagicDesc = FightSkill:GetSkillMagicDescEx(szMagicDesc, nSkillId, nSkillLevel, tbSkillMagic, bRealTime);
    return szMagicDesc;
end

function FightSkill:GetStateEffect(nStateEffectID)
    if not self.tbSkillStateEffect then
        FightSkill.tbSkillStateEffect = LoadTabFile(
            "Setting/Skill/StateEffect.tab", "dssssdddd", "StateEffectId",
            {"StateEffectId", "MagicDesc", "Icon", "IconAtlas", "StateName", "NotShowTime", "ShowSort", "HightLightSkill", "RequireSuperpose"});
        for _, tbInfo in pairs(FightSkill.tbSkillStateEffect) do
            if not Lib:IsEmptyStr(tbInfo.MagicDesc) then
                tbInfo.MagicDesc = Lib:Str2LunStr(tbInfo.MagicDesc);
            end
        end
    end

    return self.tbSkillStateEffect[nStateEffectID];
end

function FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel)
    local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId, nSkillLevel);
    if not tbSkillInfo or tbSkillInfo.StateEffectId <= 0 then
        return;
    end

    local tbStateEffect = self:GetStateEffect(tbSkillInfo.StateEffectId);
    return tbStateEffect;
end

function FightSkill:InitResetMagicType()
    --使用临时属性时需要在这里作声明

    KFightSkill.ResetMagicNameId();

    Log("FightSkill InitResetMagicType");
end
FightSkill:InitResetMagicType()

function FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nSkillMaxLevel)
    local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId, nSkillLevel);

    if not tbSkillInfo then
	    --Log("[DEBUG]FightSkill:GetSkillShowTipInfo tbSkillInfo=nil", nSkillId, nSkillLevel);
        return;
    end

    local nMaxLevel = nSkillMaxLevel or nSkillLevel;
    local bMax = nSkillLevel >= nMaxLevel;
    local szCurMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel) or "";
    local szNextMagicDesc = nSkillLevel + 1 <= nMaxLevel and FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel + 1) or "";
    local tbSkillShowInfo = {
            nId             = nSkillId,
            nLevel          = nSkillLevel,
            nMaxLevel       = nMaxLevel,
            bMax            = bMax,

            szIcon          = tbSkillInfo.Icon or "",
            szIconAltlas    = tbSkillInfo.IconAtlas or "",
            szName          = tbSkillInfo.SkillName or "",
            szDesc          = tbSkillInfo.Desc or "",
            szProperty      = tbSkillInfo.Property or "",
            nCD             = tbSkillInfo.TimePerCast or 0,
            bPassive        = tbSkillInfo.SkillType == FightSkill.SkillTypeDef.skill_type_passivity,
            nRadius         = tbSkillInfo.AttackRadius or 0,

            szCurMagicDesc = szCurMagicDesc or "",
            szNextMagicDesc = szNextMagicDesc or "",
        }

    return tbSkillShowInfo;
end

function FightSkill:IsShowSkillState(nSkillId, nSkillLevel)
    local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId, nSkillLevel);
    if not tbSkillInfo or tbSkillInfo.StateEffectId <= 0 then
        return false;
    end

    local tbStateEffect = self:GetStateEffect(tbSkillInfo.StateEffectId);
    if not tbStateEffect then
        return false;
    end

    if Lib:IsEmptyStr(tbStateEffect.Icon) then
        return false;
    end

    return true;
end

FightSkill.tbMagicCallScriptFun =
{
}

function FightSkill:MagicCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3)
    local funCallScript = FightSkill.tbMagicCallScriptFun[nSkillId];
    if funCallScript then
        funCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3);
    end
end

function FightSkill:GetPreciseCastSkill(nSkillId)
    if not self.tbPreciseCastSkill then
        self.tbPreciseCastSkill = LoadTabFile(
            "Setting/Skill/PreciseCastSkill.tab", "dsdd", "SkillId", {"SkillId", "CastType", "CastRadius", "DamageRadius"});
    end
    return self.tbPreciseCastSkill[nSkillId]
end

function FightSkill:CheckConsumeItemBreakMaxLv(nSkillId)
    local tbSkillInfo = FightSkill:GetSkillFactionInfo(nSkillId);
    if not tbSkillInfo or not tbSkillInfo.LevelUpGroup then
        return
    end

    return self:CheckUseItemBreak(me, tbSkillInfo.LevelUpGroup);
end

function FightSkill:OnSkillMaxLvBreak(szSkillName, nAdd)
    me.CenterMsg(string.format("您的%s技能等级上限成功增加%s级", szSkillName, nAdd), true);
    UiNotify.OnNotify(UiNotify.emNOTIFY_SKILL_LEVELUP, true, nil, nil, true)
end

function FightSkill:GetBuffHightLightSkill(nBuffId)
    local tbInfo = FightSkill:GetStateEffect(nBuffId) or {}
    return tbInfo.HightLightSkill or 0
end

function FightSkill:GetSkillHightLight(nSkillId)
    if not self.tbHightLightSkill then
        self:GetStateEffect(0)
        self.tbHightLightSkill = {}
        for _, tbInfo in pairs(self.tbSkillStateEffect) do
             if tbInfo.HightLightSkill > 0 then
                 self.tbHightLightSkill[tbInfo.HightLightSkill] = self.tbHightLightSkill[tbInfo.HightLightSkill] or {}
                 self.tbHightLightSkill[tbInfo.HightLightSkill][tbInfo.StateEffectId] = tbInfo.RequireSuperpose
             end
        end
    end
    return self.tbHightLightSkill[nSkillId]
end

function FightSkill:CheckSkillHightLight(nSkillId)
    local tbInfo = self:GetSkillHightLight(nSkillId) or {}
    for nBuffId, nSuperpose in pairs(tbInfo) do
        local tbState = me.GetNpc().GetSkillState(nBuffId)
        if tbState and tbState.nEndFrame ~= 0 then
            if nSuperpose > 1 then
                for _, tbInfo in pairs(tbState.tbAttrib) do
                    if tbInfo.szName == "superposemagic" then
                        return tbInfo.tbValue[3] >= nSuperpose
                    end
                end
                return false
            end
            return true
        end
    end
end

function FightSkill:GetSkillStyleDesc(nSkillId)
    if not self.tbSkillStyle then
        local tbSkillFile = LoadTabFile("Setting/Skill/Skill.tab", "ds", "SkillId", {"SkillId", "SkillStyle"});
        self.tbSkillStyle = {}
        for _, tbInfo in pairs(tbSkillFile) do
            self.tbSkillStyle[tbInfo.SkillId] = tbInfo.SkillStyle
        end
    end

    local szStyle = self.tbSkillStyle[nSkillId]
    if Lib:IsEmptyStr(szStyle) then
        return
    end
    local tbStyle = Lib:SplitStr(self.tbSkillStyle[nSkillId], ",")
    local tbDesc = {}

    if not self.tbSkillStyleDesc then
        local tbStyleName = LoadTabFile("Setting/Skill/SkillStyleDesc.tab", "ss", nil, {"StyleName", "StyleDesc"});
        self.tbSkillStyleDesc = {}
        for _, tbInfo in pairs(tbStyleName) do
            self.tbSkillStyleDesc[tbInfo.StyleName] = tbInfo.StyleDesc
        end
    end

    for _, szStyle in pairs(tbStyle) do
        local szName = self.tbSkillStyleDesc[szStyle]
        if szName then
            table.insert(tbDesc, szName)
        end
    end
    return " [FFFFFF]" .. table.concat(tbDesc, ",")
end

FightSkill.tbMutexSkill = FightSkill.tbMutexSkill or {}
FightSkill.tbPrioritySkill = FightSkill.tbPrioritySkill or {}
FightSkill.tbWeaponSkill   = FightSkill.tbWeaponSkill or {}
function FightSkill:GetMutexSkill(nSkillId)
    local nFaction = me.nFaction
    if not self.tbMutexSkill[nFaction] then
        self.tbMutexSkill[nFaction] = {}
        self.tbPrioritySkill[nFaction] = {}
        local tbBtn = {}
        for _, tbInfo in pairs(self.tbFactionSkillSetting[nFaction]) do
            if not Lib:IsEmptyStr(tbInfo.BtnName) then
                if tbBtn[tbInfo.BtnName] then
                    local nBtnSkillId = tbBtn[tbInfo.BtnName][1]
                    if tbBtn[tbInfo.BtnName][2] == 0 and tbInfo.WeaponType == 0 then
                        self.tbMutexSkill[nFaction][tbInfo.SkillId] = nBtnSkillId
                        self.tbMutexSkill[nFaction][nBtnSkillId] = tbInfo.SkillId
                    else
                        self.tbWeaponSkill[nBtnSkillId] = true
                        self.tbWeaponSkill[tbInfo.SkillId] = true
                    end
                end
                if tbInfo.ShowParam > 0 then
                    self.tbPrioritySkill[nFaction][tbInfo.SkillId] = true
                end
                tbBtn[tbInfo.BtnName] = {tbInfo.SkillId, tbInfo.WeaponType}
            end
        end
    end
    return self.tbMutexSkill[nFaction][nSkillId], self.tbPrioritySkill[nFaction][nSkillId]
end

function FightSkill:GetCheckMutexBuff(nBuffId)
    if not self.tbCheckMutexBuff then
        self.tbCheckMutexBuff = {}
        for nSkillId, tbInfo in pairs(self.tbAllFactionSkill) do
            if tbInfo.ShowParam > 0 then
                self.tbCheckMutexBuff[tbInfo.ShowParam] = nSkillId
            end
        end
    end
    return self.tbCheckMutexBuff[nBuffId]
end

function FightSkill:GetSwitchWeaponSkill(nFaction)
    self.tbSwitchWeaponSkill = self.tbSwitchWeaponSkill or {}
    if not self.tbSwitchWeaponSkill[nFaction] then
        self.tbSwitchWeaponSkill[nFaction] = {}
        for _, tbInfo in pairs(self.tbFactionSkillSetting[nFaction]) do
            if tbInfo.SwitchSkill > 0 then
                self.tbSwitchWeaponSkill[nFaction][tbInfo.WeaponType] = tbInfo.SkillId
            end
        end
    end
    return self.tbSwitchWeaponSkill[nFaction]
end

function FightSkill:GetSkillWeapon(nFaction, nSkill)
    self.tbFactionSkillWeapon = self.tbFactionSkillWeapon or {}
    if not self.tbFactionSkillWeapon[nFaction] then
        self.tbFactionSkillWeapon[nFaction] = {}
        for _, tbInfo in pairs(self.tbFactionSkillSetting[nFaction]) do
            self.tbFactionSkillWeapon[nFaction][tbInfo.SkillId] = tbInfo.WeaponType
        end
    end
    return self.tbFactionSkillWeapon[nFaction][nSkill]
end

function FightSkill:IsBaseSkill(nFaction, nSkillId)
    self.tbFactionBaseSkill = self.tbFactionBaseSkill or {}
    if not self.tbFactionBaseSkill[nFaction] then
        self.tbFactionBaseSkill[nFaction] = {}
        for _, tbInfo in pairs(self.tbFactionSkillSetting[nFaction]) do
            if tbInfo.IsBaseSkill > 0 then
                self.tbFactionBaseSkill[nFaction][tbInfo.SkillId] = true
            end
        end
    end
    return self.tbFactionBaseSkill[nFaction][nSkillId]
end

function FightSkill:GetWeaponType()
	--By SuMiao 3596242830
    return me.GetUserValue(266, 65);
end

function FightSkill:GetCurBaseSkill()
    local nCurWeapon  = self:GetWeaponType()
    local tbBaseSkill = self:GetSkillIdByBtnName(me.nFaction, "Attack")
    for _, nSkillId in pairs(tbBaseSkill) do
        local nWeapon = self:GetSkillWeapon(me.nFaction, nSkillId)
        if nWeapon == nCurWeapon then
            return nSkillId
        end
    end
end