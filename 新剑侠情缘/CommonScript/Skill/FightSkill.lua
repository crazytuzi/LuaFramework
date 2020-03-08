Require("CommonScript/Skill/Define.lua");

if (not FightSkill.tbClassBase) then
    FightSkill.tbClassBase  = {};
    FightSkill.tbClass  = {
        [""]    = FightSkill.tbClassBase,
        default = FightSkill.tbClassBase,
    };
end

function FightSkill:ResetSkillPointFightPower()
    local nTotalFightPower = 0;
    local nSkillPoint = 0;
    while true do
        nSkillPoint = nSkillPoint + 1;
        local tbInfo = self.tbSkillPointFightPower[nSkillPoint];
        if not tbInfo then
            return;
        end

        self.nMaxSkillPoint = nSkillPoint;
        nTotalFightPower = nTotalFightPower + tbInfo.FightPower;
        tbInfo.nTotalFightPower = nTotalFightPower;
    end
end


function FightSkill:LoadSetting()
    local tbSkillIniSet = Lib:LoadIniFile("Setting/Skill/SkillSetting.ini");
    self.tbSkillIniSet = {};
    self.tbSkillIniSet.nFullAnger = tonumber(tbSkillIniSet.Mix.FullAnger);
    self.tbSkillIniSet.tbActStandID = {};
    self.tbSkillIniSet.nActStandMinFrame = tonumber(tbSkillIniSet.Mix.ActStandMinFrame);
    self.tbSkillIniSet.nActStandMaxFrame = tonumber(tbSkillIniSet.Mix.ActStandMaxFrame);
    for nI = 1, 5 do
        if not Lib:IsEmptyStr(tbSkillIniSet.Mix["ActStandID"..nI]) then
            local nStandID = tonumber(tbSkillIniSet.Mix["ActStandID"..nI]);
            table.insert(self.tbSkillIniSet.tbActStandID, nStandID);
        end    
    end    
    self.tbNpcShapeShift = {};

    local tbSkillUpgradeSetting = LoadTabFile(
        "Setting/Skill/SkillLevelUp.tab",
        "ddddddd",nil,
        {"GroupId", "SkillLevel", "ReqLevel", "Coin", "Exp", "FightPower", "SkillPoint"});

    FightSkill.tbSkillLevelUpGroup = {};
    for _,v in pairs(tbSkillUpgradeSetting) do
        FightSkill.tbSkillLevelUpGroup[v.GroupId] = FightSkill.tbSkillLevelUpGroup[v.GroupId] or {};
        FightSkill.tbSkillLevelUpGroup[v.GroupId][v.SkillLevel] = {v.ReqLevel, v.Coin, v.Exp, v.FightPower, v.SkillPoint};
    end


    local tbFactionSkill = Lib:LoadTabFile("Setting/Skill/FactionSkill.tab", {Faction = 1, SkillId = 1, SortInUI = 1, IsBaseSkill = 1, IsAnger = 1, LevelUpGroup = 1, GainLevel = 1, ShowParam = 1, WeaponType = 1, SwitchSkill = 1})
    FightSkill.tbFactionSkillSetting = {};
    for _, tbSkillInfo in ipairs(tbFactionSkill) do
        FightSkill.tbFactionSkillSetting[tbSkillInfo.Faction] = FightSkill.tbFactionSkillSetting[tbSkillInfo.Faction] or {};
        table.insert(FightSkill.tbFactionSkillSetting[tbSkillInfo.Faction], tbSkillInfo);
    end

    local tbFactionSkillSetting = LoadTabFile("Setting/Skill/FactionSkill.tab",
        "ddsssdddddd", "SkillId",
        {"Faction", "SkillId", "BtnName", "BtnIcon", "IconAltlas", "SortInUI", "IsAnger", "LevelUpGroup", "GainLevel", "ShowParam", "WeaponType"});
    FightSkill.tbSkillLevelUp = {};
    for _,v in pairs(tbFactionSkillSetting) do
        if v.LevelUpGroup and v.LevelUpGroup ~= 0 then
            FightSkill.tbSkillLevelUp[v.SkillId] = FightSkill.tbSkillLevelUpGroup[v.LevelUpGroup];
        end
    end

    FightSkill.tbAllFactionSkill = tbFactionSkillSetting;

    FightSkill.tbSkillMaxLevel = {};
    for nSkillId, tbSkillData in pairs(FightSkill.tbSkillLevelUp) do
        local nMaxLevel = 0;
        for k,v in pairs(tbSkillData) do
            if k > nMaxLevel then
                nMaxLevel = k;
            end
        end
        FightSkill.tbSkillMaxLevel[nSkillId] = nMaxLevel;
    end

    local tbFileData = Lib:LoadTabFile("Setting/Skill/NpcShapeShift.tab", {NpcTemplateID = 1});
    for _, tbInfo in pairs(tbFileData) do
        local tbShapeShiftInfo = {};
        tbShapeShiftInfo.nNpcTemplateID = tbInfo.NpcTemplateID;
        tbShapeShiftInfo.szIconAltlas   = tbInfo.IconAltlas;
        tbShapeShiftInfo.szJumpIconAltlas = tbInfo.JumpIconAltlas
        tbShapeShiftInfo.tbAllSkill     = {};

        for nI = 0, 10 do
            local szSkillID    = "SkillID"..nI;
            local szSkillLevel = "SkillLevel"..nI;
            local szWeapon     = "WeaponType"..nI;

            if not Lib:IsEmptyStr(tbInfo[szSkillID]) and not Lib:IsEmptyStr(tbInfo[szSkillLevel]) then
                local nSkillID    = tonumber(tbInfo[szSkillID]);
                local nSkillLevel = tonumber(tbInfo[szSkillLevel]);
                tbShapeShiftInfo.tbAllSkill[nI] =
                {
                    nSkillID    = nSkillID;
                    nSkillLevel = nSkillLevel;
                    nWeaponType = tonumber(tbInfo[szWeapon]) or 0;
                    szBtnIcon   = tbInfo["BtnIcon"..nI];
                };
            end
        end

        local szSkillID    = "SkillIDJump";
        local szSkillLevel = "SkillLevelJump";

        if not Lib:IsEmptyStr(tbInfo[szSkillID]) and not Lib:IsEmptyStr(tbInfo[szSkillLevel]) then
                local nSkillID    = tonumber(tbInfo[szSkillID]);
                local nSkillLevel = tonumber(tbInfo[szSkillLevel]);

                tbShapeShiftInfo.tbJumpSkill =
                {
                    nSkillID    = nSkillID;
                    nSkillLevel = nSkillLevel;
                    szBtnIcon   = tbInfo["BtnIconJump"];
                };
        end

        self.tbNpcShapeShift[tbInfo.NpcTemplateID] = tbShapeShiftInfo;
    end

    self.tbSkillPointFightPower = LoadTabFile("Setting/Skill/SkillPointFightPower.tab", "dd", "SkillPoint", {"SkillPoint", "FightPower"});
    self.nMaxSkillPoint         = 0;
    self:ResetSkillPointFightPower();
end

FightSkill:LoadSetting();

function FightSkill:GetNpShapeShift(nNpcTemplateID)
    return self.tbNpcShapeShift[nNpcTemplateID];
end

function FightSkill:IsSelfSkill(nSkillId)
    local tbSkillInfo = self:GetSkillSetting(nSkillId);
    return tbSkillInfo.TargetSelf;
end

function FightSkill:GetSkillPointFightPower(nSkillPoint)
    if nSkillPoint <= 0 then
        return 0;
    end

    local tbInfo = self:GetSkillPointPowerInfo(nSkillPoint);
    return tbInfo.nTotalFightPower or 0;
end

function FightSkill:GetSkillPointPowerInfo(nSkillPoint)
    local tbInfo = self.tbSkillPointFightPower[nSkillPoint];
    if tbInfo then
        return tbInfo;
    end

    local tbCurInfo = self.tbSkillPointFightPower[self.nMaxSkillPoint];
    local nTotalFightPower = tbCurInfo.nTotalFightPower;

    for nI = self.nMaxSkillPoint + 1, nSkillPoint do
        local tbFightPowerInfo = {};
        tbFightPowerInfo.SkillPoint = nI;
        tbFightPowerInfo.FightPower = tbCurInfo.FightPower;

        nTotalFightPower = nTotalFightPower + tbFightPowerInfo.FightPower
        tbFightPowerInfo.nTotalFightPower = nTotalFightPower;

        self.tbSkillPointFightPower[nI] = tbFightPowerInfo;
    end

    self.nMaxSkillPoint = nSkillPoint;
    return self.tbSkillPointFightPower[nSkillPoint];
end

function FightSkill:GetAttackRadius(nSkillId)
    local tbSkillInfo = self:GetSkillSetting(nSkillId);
    return tbSkillInfo.AttackRadius;
end

function FightSkill:GetSkillLevelUpNeed(nSkillId, nLevel)
    nLevel = nLevel + 1;
    if self.tbSkillLevelUp[nSkillId] and self.tbSkillLevelUp[nSkillId][nLevel] then
        local tbSkill = self.tbSkillLevelUp[nSkillId][nLevel];
        return tbSkill[1], tbSkill[2], tbSkill[3], tbSkill[5];
    else
        return 0, 0, 0, 0;
    end
end

function FightSkill:GetSkillUpInfo(nSkillId, nLevel)
    local tbSkillInfo = self.tbSkillLevelUp[nSkillId];
    if not tbSkillInfo then
        return;
    end

    return tbSkillInfo[nLevel];
end

function FightSkill:GetSkillFightPower(nSkillId, nLevel)
    if self.tbSkillLevelUp[nSkillId] and self.tbSkillLevelUp[nSkillId][nLevel] then
        local tbSkill = self.tbSkillLevelUp[nSkillId][nLevel];
        return tbSkill[4];
    else
        return 0;
    end
end

function FightSkill:GetSkillMaxLevel(nSkillId)
    return self.tbSkillMaxLevel[nSkillId] or 99;
end

function FightSkill:CheckSkillLeveUp(pPlayer, nSkillId)
    local _, nBaseLevel = pPlayer.GetSkillLevel(nSkillId);
    if nBaseLevel <= 0 then
        return false, "没有获得该技能";
    end

    local pNpc = pPlayer.GetNpc();
    if pNpc.nShapeShiftNpcTID > 0 then
        return false, "变身状态时不能操作";
    end

    local nFactionLimit = KFightSkill.GetFactionLimit(nSkillId);
    if pPlayer.nFaction ~= nFactionLimit then
        return false, "门派不符合";
    end

    local nAddLimitLevel = FightSkill:GetSkillLimitAddLevel(pPlayer, nSkillId);
    local nLimitLevel = FightSkill:GetSkillMaxLevel(nSkillId);
    if nBaseLevel >= (nLimitLevel + nAddLimitLevel) then
        return false, "已达最大等级";
    end

    local nSkillCheckLevel = nBaseLevel;
    if nSkillCheckLevel >= nLimitLevel then
        nSkillCheckLevel = nLimitLevel - 1;
    end    

    local tbSkillUpInfo = FightSkill:GetSkillUpInfo(nSkillId, nSkillCheckLevel + 1);
    if not tbSkillUpInfo then
        return false, "已达最大等级!";
    end

    local nReqLevel, _, _, nNeedPoint = FightSkill:GetSkillLevelUpNeed(nSkillId, nSkillCheckLevel);
    if pPlayer.nLevel < nReqLevel then
        return false, string.format("主角达到%s级，才可继续升级此技能", nReqLevel);
    end

    local nSkillPoint = FightSkill:GetCurSkillPoint(pPlayer);
    if nSkillPoint < nNeedPoint then
        return false, "技能点不足";
    end

    return true, "", nBaseLevel, nNeedPoint;
end

function FightSkill:GetTotalSkillPoint(pPlayer)
    local tbSkillItem = Item:GetClass("SkillPointBook");
    local nCurPoint = FightSkill.nInitSkillPoint;
    if pPlayer.nLevel > 1 then
        nCurPoint = nCurPoint + (pPlayer.nLevel - 1) * FightSkill.nAddLeveUpSkillPoint;
    end

    for _, tbInfo in pairs(tbSkillItem.tbBookInfo) do
        local nCount = pPlayer.GetUserValue(tbSkillItem.nSavePointGroup, tbInfo.nSaveID);
        if nCount > 0 then
            local nPoint = nCount * tbInfo.nAddPoint;
            nCurPoint = nCurPoint + nPoint;
        end    
    end

    return nCurPoint;    
end

function FightSkill:GetCurSkillPoint(pPlayer)
    local nTotalPoint = self:GetTotalSkillPoint(pPlayer);
    local nToalCostPoint = pPlayer.GetUserValue(self.nSaveSkillPointGroup, self.nSaveCostSkillPoint);
    local nCurPoint = nTotalPoint - nToalCostPoint;
    if nCurPoint < 0 then
        nCurPoint = 0;
    end

    return nCurPoint;    
end

function FightSkill:GetSkillShowInfo(nSkillId)
    local tbSkillInfo = self:GetSkillSetting(nSkillId);
    if not tbSkillInfo then
        return;
    end

    local szAtlas = tbSkillInfo.IconAtlas;
    if Lib:IsEmptyStr(szAtlas) then
        szAtlas = "UI/Atlas/SkillIcon/SkillIcon.prefab";
    end

    local tbIcon = { szIconAtlas = szAtlas, szIconSprite = tbSkillInfo.Icon or "Skill3" };

    return tbIcon, tbSkillInfo.SkillName;
end

function FightSkill:GetFactionSkill(nFaction)
    return self.tbFactionSkillSetting[nFaction];
end

function FightSkill:GetSkillFactionInfo(nSkillId)
    return self.tbAllFactionSkill[nSkillId];
end

function FightSkill:GetSkillIdByBtnName(nFaction, szBtnName)
    local tbSkill = {}
    local tbFactionSkill = self:GetFactionSkill(nFaction);
    for _, tbSkillInfo in pairs(tbFactionSkill) do
        if tbSkillInfo.BtnName == szBtnName then
            table.insert(tbSkill, tbSkillInfo.SkillId)
        end
    end
    return tbSkill
end

function FightSkill:GetSkillIdByLevelUpGroup(nFaction, nLevelUpGroup)
    local tbFactionSkill = self:GetFactionSkill(nFaction);
    for _, tbSkillInfo in pairs(tbFactionSkill) do
        if tbSkillInfo.LevelUpGroup == nLevelUpGroup then
            return tbSkillInfo.SkillId;
        end
    end
end

function FightSkill:GetFakePlayerSkillList(nFaction, nPlayerLevel)
    local tbResult = {};
    local tbSkillList = self.tbFactionSkillSetting[nFaction]
    for _, tbInfo in ipairs(tbSkillList) do
        local nSkillId = tbInfo.SkillId;
        if nSkillId > 0 and self.tbSkillLevelUp[nSkillId] then
            local nMaxLevel = 0;
            for nLevel, tbUpdateGradeInfo in ipairs(self.tbSkillLevelUp[nSkillId]) do
                if tbUpdateGradeInfo[1] > nPlayerLevel then
                    break;
                end
                nMaxLevel = nLevel;
            end

            if nMaxLevel > 0 then
                table.insert(tbResult, {nSkillId,  nMaxLevel});
            end
        end
    end

    return tbResult;
end

function FightSkill:GetSkillSetting(nSkillId, nLevel)
    local tbSkillInfo = KFightSkill.GetSkillInfo(nSkillId, nLevel or 1);
    return tbSkillInfo;
end

-- 取得特定类名的Skill类
function FightSkill:GetClass(szClassName, bNotCreate)
    local tbSkill   = self.tbClass[szClassName];
    if (not tbSkill and bNotCreate ~= 1) then
        tbSkill = Lib:NewClass(self.tbClassBase);
        self.tbClass[szClassName] = tbSkill;
    end
    return tbSkill;
end

--供程序调用，获取指定等级技能的全部魔法属性数据
function FightSkill:GetLevelData(szSkillName, nLevel)
    assert(szSkillName and nLevel);
    if (not self.tbClass[szSkillName]) then
        print(string.format("[ERROR][技能错误]‘%s’ not found, 魔法属性未找到！！！！！！", szSkillName));
        return {};
    end
    local tbSkill = assert(self.tbClass[szSkillName], "[ERROR]Skill{"..tostring(szSkillName).."} not found!");
    local tbRet = {};
    if (#tbSkill.tbMagics ~= 0) then
        for _, tbMagic in ipairs(tbSkill.tbMagics) do
            if (type(tbMagic) ~= "table") then
                Log("[ERROR][技能错误]", szSkillName, nLevel);
            end
            local tbData = { szName = tbMagic.szMagicName};
            local tbProp = {};
            for nI = 1, self.MAGIC_VALUE_NUM do
                tbData["nV"..nI] = 0;
            end
            if (type(tbMagic.tbValue) == "function") then
                tbProp = tbMagic.tbValue(nLevel);
            else
                for i = 1, self.MAGIC_VALUE_NUM do
                    tbProp[i] = Lib.Calc:Link(nLevel, tbMagic.tbValue[i]);
                end
            end;

            for nI, nValue in pairs(tbProp) do
                tbData["nV"..nI] = nValue;
            end

            tbRet[#tbRet + 1] = tbData;
        end
    else
        for szMagicName, tbMagicProp in pairs(tbSkill.tbMagics) do
            local tbData = { szName = szMagicName};
            local tbProp = {};
            for nI = 1, self.MAGIC_VALUE_NUM do
                tbData["nV"..nI] = 0;
            end
            if (type(tbMagicProp) == "function") then
                tbProp = tbMagicProp(nLevel);
            else
                for i = 1, self.MAGIC_VALUE_NUM do
                    tbProp[i] = Lib.Calc:Link(nLevel, tbMagicProp[i]);
                end
            end;

            for nI, nValue in pairs(tbProp) do
                tbData["nV"..nI] = nValue;
            end
            tbRet[#tbRet + 1] = tbData;
        end
    end

    return tbRet;
end

-- 供程序调用，分析数值公式
function FightSkill:GetFormatValue(szFormat, nLevel)
    local fnData = loadstring("return "..szFormat);
    if (not fnData) then
        error(string.format("loadstring failed! FMT = %s, Level = %d", szFormat, nLevel));
    end
    local tbPoint = {fnData()};
    if (#tbPoint <= 1) then -- 只填一个数字的情况
        local varValue  = tbPoint[1];
        if (type(varValue) == "string") then    -- 策划文档不小心出了引号
            return self:GetFormatValue(varValue, nLevel);
        elseif (type(varValue) == "number") then
            return varValue;
        elseif (type(varValue) == "table") then
            return varValue[2];
        else
            error("format error!");
        end
    end
    return Lib.Calc:Link(nLevel, tbPoint);
end

-- 供程序调用，分析数值公式
function FightSkill:GetFormatPoint(szFormat)
    szFormat = string.gsub(szFormat, "\"", "");
    local fnData = loadstring("return "..szFormat);
    if (not fnData) then
        error(string.format("loadstring failed! GetFormatPoint = %s", szFormat));
    end

    local tbPoint = {fnData()};
    if (#tbPoint <= 1) then -- 只填一个数字的情况
        local varValue  = tbPoint[1];
        if (type(varValue) == "number") then
            return varValue;
        end
    end

    return tbPoint;
end

function FightSkill:GetPointValue(tbPoint, nLevel)
    if (#tbPoint <= 1) then -- 只填一个数字的情况
        local varValue  = tbPoint[1];
        if (type(varValue) == "string") then    -- 策划文档不小心出了引号
            return self:GetFormatValue(varValue, nLevel);
        elseif (type(varValue) == "number") then
            return varValue;
        else
            error("format error!");
        end
    end
    return Lib.Calc:Link(nLevel, tbPoint);
end

function FightSkill:AddMagicData(tbMagicDatas)

    for szSkillName, tbMagics in pairs(tbMagicDatas) do
        self:GetClass(szSkillName).tbMagics = tbMagics;
    end
end

function FightSkill:GetConflictingSkillList(nSkillId)
    return FightSkill.tbStateReplaceRegular:GetConflictingSkillList(nSkillId);
end

function FightSkill:GetStateGroupReplaceType(nSkillId)
    return FightSkill.tbStateReplaceRegular:GetStateGroupReplaceType(nSkillId);
end

function FightSkill:GetSkillLimitAddLevel(pPlayer, nFactionSkill)
    local tbSkillInfo = FightSkill:GetSkillFactionInfo(nFactionSkill);
    if not tbSkillInfo or not tbSkillInfo.LevelUpGroup then
        return 0;
    end
    return self:GetPlayerSkillLimit(pPlayer, tbSkillInfo.LevelUpGroup)
end


FightSkill.nSaveLevelGroup = 134
FightSkill.nSaveLevelMaxCount = 20

--直接使用道具突破上限
FightSkill.tbDirectBreakMaxLv =
{
--技能组ID  最大使用数量   增加上限  保存位置      等级需求         消耗的道具ID           消耗的道具数量        时间轴限制
    [2]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  1, nRequireLv = 110, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"},
           },
    [3]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  2, nRequireLv = 110, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"},
           },
    [4]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  3, nRequireLv = 110, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"},
           },
    [6]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  4, nRequireLv = 110, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"},
           },
    [5]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  5, nRequireLv = 120, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel129"},
                {nMaxCount = 5,  nAdd = 1, nSaveID = 11, nRequireLv = 150, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel159"},
           },
    [7]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  6, nRequireLv = 120, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel129"},
           },
    [8]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  7, nRequireLv = 120, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel129"},
           },
    [9]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  8, nRequireLv = 130, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel139"},
           },
    [11] = {
                {nMaxCount = 5,  nAdd = 1, nSaveID =  9, nRequireLv = 130, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel139"},
           },
    [12] = {
                {nMaxCount = 5,  nAdd = 1, nSaveID = 10, nRequireLv = 130, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel139"},
           },
    [1]  = {
                {nMaxCount = 5,  nAdd = 1, nSaveID = 12, nRequireLv = 150, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel159"},
           },
}

function FightSkill:GetPlayerSkillLimit(pPlayer, nLevelUpGroup)
    local tbList = self.tbDirectBreakMaxLv[nLevelUpGroup]
    if not tbList then
        return 0
    end

    local nCount = 0
    for _, tbInfo in ipairs(tbList) do
        local nThis = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID) * tbInfo.nAdd
        nCount = nCount + nThis
    end
    return nCount
end

function FightSkill:_CheckUseItemBreak(pPlayer, tbInfo)
    if not Lib:IsEmptyStr(tbInfo.szTimeFrame) and GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
        return false, "尚未开放"
    end

    if pPlayer.nLevel < tbInfo.nRequireLv then
        return false, string.format("%d级之后可使用道具提升该技能最大等级", tbInfo.nRequireLv)
    end

    if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveLevelMaxCount then
        return false, "不能使用当前的道具!"
    end

    local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID)
    if nCount >= tbInfo.nMaxCount then
        return false, string.format("该道具最多使用%s个。", tbInfo.nMaxCount)
    end
    return true
end

function FightSkill:CheckUseItemBreak(pPlayer, nLevelUpGroup)
    local tbList = self.tbDirectBreakMaxLv[nLevelUpGroup]
    if not tbList then
        return false, "该技能不能使用道具提升"
    end
    local szMsg
    for _, tbInfo in ipairs(tbList) do
        local bRet, szErrMsg = self:_CheckUseItemBreak(pPlayer, tbInfo)
        if bRet then
            local nItemCount = pPlayer.GetItemCountInAllPos(tbInfo.nConsumeItemID)
            if nItemCount < tbInfo.nConsumeItemNum then
                return false, "您的[FFFE0D]门派信物[-]数量不足[FFFE0D]" .. tbInfo.nConsumeItemNum .."[-]个"
            end
            return true, "", tbInfo
        else
            szMsg = szErrMsg
        end
    end
    return false, szMsg
end

function FightSkill:CheckShowSKillUpper(pPlayer, nLevelUpGroup)
    local tbList = self.tbDirectBreakMaxLv[nLevelUpGroup]
    if not tbList then
        return
    end

    for _, tbInfo in ipairs(tbList) do
        if (pPlayer.nLevel >= tbInfo.nRequireLv) and
           (Lib:IsEmptyStr(tbInfo.szTimeFrame) or GetTimeFrameState(tbInfo.szTimeFrame) == 1) and
           (pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID) < tbInfo.nMaxCount) then
            return true
        end
    end
end