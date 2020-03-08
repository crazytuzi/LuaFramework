Require("CommonScript/Player/PlayerEventRegister.lua");
local tbBook = Item:GetClass("SkillBook");

----------策划填写--------------------------
tbBook.nMaxAttribCount = 4; --最大属性
tbBook.nAttribScaleValue = 1000; --表填值 / nAttribScaleValue = 属性值
tbBook.szSkillBookExpName = "SkillExp";
tbBook.tbSkillBookHoleLevel = {40, 50, 60 , 70}; --开孔的等级
tbBook.nTotalSkillLevelRate = 1000; --技能升级总共概率
tbBook.nMinStartExpLevel = 40; --多少等级开始有修炼经验
tbBook.nMaxXiuLianExp = 10000; --最多修炼经验
tbBook.nPerGroupXiuLianExp = 240; --多少秒增加一次修炼经验
tbBook.nBookCostExptRecycleP = 50; --技能书消耗回收率
tbBook.nBookBaseValueRecycleP = 50; --基础价值量回收率
tbBook.nValueRecycleParam = 100; --回收的价值参数
tbBook.nPerMiJiUpgradeParam = -4000; --进阶每本秘籍的参数

tbBook.nBookTypeNormal = 0; --普通秘籍
tbBook.nBookTypeMiddle = 1; --中级秘籍
tbBook.nBookTypeHigh = 2; --高级秘籍

tbBook.tbAllXiuWeiBook = {764, 2395, 2396}; --修为书

----------策划填写End--------------------------


tbBook.nSaveBookLevel = 1;
tbBook.nSaveSkillLevel = 2;
tbBook.nSaveFlag       = 16;

tbBook.nPlayerSaveGroup = 95;
tbBook.nPlayerSaveXiuLianExp = 1;


function tbBook:LoadSetting()
    self.tbBookSetting = {};
    self.tbFightPowerSetting = {};
    self.tbBookLevelInfo = {};
    self.tbBookUpgradeInfo = {};
    self.tbSkillLevelInfo = {};
    self.tbBookTuPoSetting = {};
    self.tbFactionBookSetting = {};
    self.tbFactionBookType = {};
    self.tbBookUpgradeToLowIndex = {};

    local tbFileData = Lib:LoadTabFile("Setting/Item/SkillBook/Book.tab", {BookID = 1, LimitFaction = 1, LevelFightPowerID = 1, SkillFightPowerID = 1, SkillID = 1,
                        UpgradeID = 1, UpgradeItem = 1, MaxBookLevel = 1, MaxSkillLevel = 1, LimitRecycle = 1, TuPoID = 1, Type = 1, MutualType = 1});
    for _, tbInfo in pairs(tbFileData) do
        local tbAllAttrib = {};
        for nI = 1, self.nMaxAttribCount do
            local szType = "Attrib"..nI.."Type";
            if not Lib:IsEmptyStr(tbInfo[szType]) then
                local tbAttrib = {};
                tbAttrib.szType = tbInfo[szType];
                tbAttrib.tbInit = {0, 0, 0};
                tbAttrib.tbInit[1] = tonumber(tbInfo["Init"..nI.."Value"]);

                tbAttrib.tbGrow = {0, 0, 0};
                tbAttrib.tbGrow[1] = tonumber(tbInfo["Grow"..nI.."Value"]);

                table.insert(tbAllAttrib, tbAttrib);
            end
        end

        tbInfo.tbAllAttrib = tbAllAttrib;
        self.tbBookSetting[tbInfo.BookID] = tbInfo;
        if tbInfo.UpgradeItem ~= 0 then
            self.tbBookUpgradeToLowIndex[tbInfo.UpgradeItem] = tbInfo.BookID;        
        end
    end

    tbFileData = Lib:LoadTabFile("Setting/Item/SkillBook/FightPower.tab", {FightPowerID = 1, Level = 1, FightPowerValue = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbFightPowerSetting[tbInfo.FightPowerID] = self.tbFightPowerSetting[tbInfo.FightPowerID] or {};
        self.tbFightPowerSetting[tbInfo.FightPowerID][tbInfo.Level] = tbInfo;
    end

    tbFileData = Lib:LoadTabFile("Setting/Item/SkillBook/BookLevel.tab", {Level = 1, CostExp = 1, SkillMinLevel = 1, SkillLevelUpRate = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbBookLevelInfo[tbInfo.Level] = tbInfo;
    end

    tbFileData = Lib:LoadTabFile("Setting/Item/SkillBook/SkillLevel.tab", {SkillLevel = 1, Value = 1, RecycleP = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbSkillLevelInfo[tbInfo.SkillLevel] = tbInfo;
    end

    tbFileData = Lib:LoadTabFile("Setting/Item/SkillBook/BookUpgrade.tab", {UpgradeID = 1, PlayerLevel = 1,  BookLevel = 1, BookSkillLevel = 1});
    for _, tbInfo in pairs(tbFileData) do
        tbInfo.tbAllCostIteam = {};
        for nI = 1, 3 do
            if not Lib:IsEmptyStr(tbInfo["CostItem"..nI]) and not Lib:IsEmptyStr(tbInfo["CostItemCount"..nI]) then
                local tbCost = {};
                tbCost.nItemTID = tonumber(tbInfo["CostItem"..nI]);
                tbCost.nItemCount = tonumber(tbInfo["CostItemCount"..nI]);
                table.insert(tbInfo.tbAllCostIteam, tbCost);
            end
        end
        self.tbBookUpgradeInfo[tbInfo.UpgradeID] = tbInfo;
    end

    tbFileData = Lib:LoadTabFile("Setting/Item/SkillBook/TuPo.tab", {TuPoID = 1, BookLevel = 1, BookSkillLevel = 1, TuPoSkillLevel = 1, CostExp = 1});
    for _, tbInfo in pairs(tbFileData) do
        tbInfo.tbAllCostIteam = {};
        for nI = 1, 3 do
            if not Lib:IsEmptyStr(tbInfo["CostItem"..nI]) and not Lib:IsEmptyStr(tbInfo["CostItemCount"..nI]) then
                local tbCost = {};
                tbCost.nItemTID = tonumber(tbInfo["CostItem"..nI]);
                tbCost.nItemCount = tonumber(tbInfo["CostItemCount"..nI]);
                table.insert(tbInfo.tbAllCostIteam, tbCost);
            end
        end

        self.tbBookTuPoSetting[tbInfo.TuPoID] = self.tbBookTuPoSetting[tbInfo.TuPoID] or {};
        self.tbBookTuPoSetting[tbInfo.TuPoID][tbInfo.BookLevel] = self.tbBookTuPoSetting[tbInfo.TuPoID][tbInfo.BookLevel] or {};
        self.tbBookTuPoSetting[tbInfo.TuPoID][tbInfo.BookLevel][tbInfo.BookSkillLevel] = tbInfo;
    end

    tbFileData = Lib:LoadTabFile("Setting/Item/SkillBook/FactionBook.tab", {Type = 1, Faction = 1, SkillBookID = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbFactionBookSetting[tbInfo.Type] = self.tbFactionBookSetting[tbInfo.Type] or {};
        self.tbFactionBookSetting[tbInfo.Type][tbInfo.Faction] = tbInfo;
        self.tbFactionBookType[tbInfo.SkillBookID] = tbInfo.Type;
    end
end

tbBook:LoadSetting();

local tbEquip = Item:GetClass("equip");
function tbBook:GetTip(pEquip, pPlayer, bIsCompare)            -- 获取普通道具Tip
    local tbBaseAttrib = tbEquip:GetBaseAttrib(pEquip.dwTemplateId, pEquip, pPlayer, bIsCompare)
    return tbBaseAttrib;
end

function tbBook:GetBookLevelInfo(nBookLevel)
    return self.tbBookLevelInfo[nBookLevel];
end

function tbBook:GetBookInfo(nItemID)
    return self.tbBookSetting[nItemID];
end

function tbBook:GetFactionTypeBook(nBookType, nFaction)
    local tbInfo = self.tbFactionBookSetting[nBookType][nFaction]
    if tbInfo then
        return tbInfo.SkillBookID
    end
end

function tbBook:GetBookType(nItemID)
    return self.tbFactionBookType[nItemID]
end

function tbBook:GetLowestBookId(nUpItemID)
    for i=1,10 do
        local dwLowId = self.tbBookUpgradeToLowIndex[nUpItemID];
        if dwLowId then
            if nUpItemID == dwLowId then
                return nUpItemID
            end
            nUpItemID = dwLowId
        else
            return nUpItemID
        end
    end
end

function tbBook:GetSkillLevelInfo(nSkillLevel)
    return self.tbSkillLevelInfo[nSkillLevel];
end

function tbBook:GetBookUpgradeInfo(nUpgradeID)
    return self.tbBookUpgradeInfo[nUpgradeID];
end

function tbBook:GetBookTuPoInfo(nTuPoID)
    return self.tbBookTuPoSetting[nTuPoID];
end

function tbBook:GetBookTuPoByEquip(pEquip)
    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        return;
    end

    if tbBookInfo.TuPoID <= 0 then
        return;
    end

    local tbTuPoInfo = self:GetBookTuPoInfo(tbBookInfo.TuPoID);
    if not tbTuPoInfo then
        return;
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    local tbBookLevelInfo = tbTuPoInfo[nBookLevel];
    if not tbBookLevelInfo then
        return;
    end

    local nSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    return tbBookLevelInfo[nSkillLevel];
end

function tbBook:UpdateGrowXiuLianExp(pPlayer)
    if self.nMinStartExpLevel > pPlayer.nLevel then
        return 0;
    end

    local nCurTime = GetTime();
    local nLastTime = pPlayer.GetUserValue(self.nPlayerSaveGroup, self.nPlayerSaveXiuLianExp);
    if nLastTime <= 0 then
        nLastTime = nCurTime;
        if MODULE_GAMESERVER then
            pPlayer.SetUserValue(self.nPlayerSaveGroup, self.nPlayerSaveXiuLianExp, nCurTime);
        end
    end

    local nAddExp = math.floor((nCurTime - nLastTime) / tbBook.nPerGroupXiuLianExp);
    local nGetAddExp = nAddExp;
    if nAddExp > 0 then
        local nCurExp = pPlayer.GetMoney(tbBook.szSkillBookExpName);
        if (nAddExp + nCurExp) > self.nMaxXiuLianExp then
            nGetAddExp = self.nMaxXiuLianExp - nCurExp;
        end

        if nGetAddExp <= 0 then
            nGetAddExp = 0;
        end

        if MODULE_GAMESERVER then
            pPlayer.SetUserValue(self.nPlayerSaveGroup, self.nPlayerSaveXiuLianExp, nLastTime + nAddExp * tbBook.nPerGroupXiuLianExp);

            if nGetAddExp > 0 then
                pPlayer.AddMoney(tbBook.szSkillBookExpName, nGetAddExp, Env.LogWay_MiJi);
            end
        end
    end

    return nGetAddExp;
end

function tbBook:GetFightPowerValue(nID, nLevel)
    local tbFightPower = self.tbFightPowerSetting[nID];
    if not tbFightPower then
        return 0;
    end

    local tbInfo = tbFightPower[nLevel];
    if not tbInfo then
        return 0;
    end

    return tbInfo.FightPowerValue;
end


function tbBook:InitInfo(pEquip)
    pEquip.SetIntValue(self.nSaveBookLevel, 1);
    pEquip.SetIntValue(self.nSaveSkillLevel, 1);
    pEquip.SetIntValue(self.nSaveFlag, 1);
end

function tbBook:OnCreate(pEquip)
    self:InitInfo(pEquip);
end

function tbBook:UpdateSkillBook(pEquip)
    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        Log("Error SkillBook UpdateSkillBook Info", pEquip.dwTemplateId);
        return;
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    if nBookLevel > tbBookInfo.MaxBookLevel then
        pEquip.SetIntValue(self.nSaveBookLevel, tbBookInfo.MaxBookLevel);
        Log("SkillBook UpdateSkillBook BookLevel", pEquip.dwTemplateId, nBookLevel);
    end

    local nSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    if nSkillLevel > tbBookInfo.MaxSkillLevel then
        pEquip.SetIntValue(self.nSaveSkillLevel, tbBookInfo.MaxSkillLevel);
        Log("SkillBook UpdateSkillBook SkillLevel", pEquip.dwTemplateId, nSkillLevel);
    end

    local nFlag = pEquip.GetIntValue(self.nSaveFlag);
    if nFlag == 1 then
        return;
    end

    for nI = 3, 15 do
        if nI ~= self.nSaveBookLevel and nI ~= self.nSaveSkillLevel then
            local nV = pEquip.GetIntValue(nI);
            if nV ~= 0 then
                pEquip.SetIntValue(nI, 0);
                Log("SkillBook UpdateSkillBook Value", pEquip.dwTemplateId, nI, nV);
            end
        end
    end
    pEquip.SetIntValue(self.nSaveFlag, 1);
end

function tbBook:OnInit(pEquip)
    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    if nBookLevel <= 0 then
        self:InitInfo(pEquip);
        Log("Error SkillBook InitInfo", pEquip.dwTemplateId);
    end

    if MODULE_GAMESERVER then
        self:UpdateSkillBook(pEquip); --注意之前的卡牌收集导致部分数据错误
    end

    nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    local tbAllAttrib = self:GetBookAttrib(tbBookInfo, nBookLevel);
    for nIndex, tbAttrib in ipairs(tbAllAttrib) do
        pEquip.SetRandAttrib(nIndex, tbAttrib.szType, tbAttrib.tbValue[1], tbAttrib.tbValue[2], tbAttrib.tbValue[3]);
    end

    local nSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    local nTotalIndex = #tbAllAttrib;
    pEquip.SetRandAttrib(nTotalIndex + 1, "add_skill_level", tbBookInfo.SkillID, nSkillLevel, 1);

    local nBaseFightPower     = pEquip.nBaseFightPower;
    local nBookFightPower     = self:GetFightPowerValue(tbBookInfo.LevelFightPowerID, nBookLevel);
    local nSkillFightPower    = self:GetFightPowerValue(tbBookInfo.SkillFightPowerID, nSkillLevel);
    pEquip.nFightPower        = nBaseFightPower + nBookFightPower + nSkillFightPower;
end

function tbBook:CalcAttribAddValue(tbValue1, tbValue2, nAdd)
    local tbValue = {};
    tbValue[1] = tbValue1[1] + nAdd * tbValue2[1];
    tbValue[2] = tbValue1[2] + nAdd * tbValue2[2];
    tbValue[3] = tbValue1[3] + nAdd * tbValue2[3];
    return tbValue;
end

function tbBook:CheckUseEquip(pPlayer, pEquip, nEquipPos)
    if pEquip.szClass ~= "SkillBook" then
        return false, "当前尚未开启!";
    end

    local nIndex = nEquipPos - Item.EQUIPPOS_SKILL_BOOK + 1;
    local nOpenLevel = self.tbSkillBookHoleLevel[nIndex];
    if not nOpenLevel then
        return false, "已经满了！";
    end

    if nOpenLevel > pPlayer.nLevel then
        return false, string.format("升级到%s级，才可装备更多秘籍", nOpenLevel);
    end

    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        return false, "当前尚未开启!!!";
    end

    if tbBookInfo.LimitFaction > 0 and tbBookInfo.LimitFaction ~= pPlayer.nFaction then
        return false, string.format("门派不符合！");
    end

    local bRet = self:HaveSkillBook(pPlayer, pEquip.dwTemplateId);
    if bRet then
        return false, "相同秘籍最多只能装备一本";
    end

    return true, "";
end

function tbBook:HaveSkillBook(pPlayer, nItemTID)
    local tbSkillBook1 = self:GetBookInfo(nItemTID);
    if not tbSkillBook1 then
        return true;
    end

    local nEndPos = Item.EQUIPPOS_SKILL_BOOK + #self.tbSkillBookHoleLevel - 1;
    for nEquipPos = Item.EQUIPPOS_SKILL_BOOK, nEndPos, 1 do
        local pItem = pPlayer.GetEquipByPos(nEquipPos);
        if pItem then
            local tbSkillBook = self:GetBookInfo(pItem.dwTemplateId);
            if not tbSkillBook then
                return true;
            end

            if tbSkillBook.MutualType == tbSkillBook1.MutualType then
                return true;
            end
        end
    end

    return false;
end

function tbBook:CheckBookLevelUp(pPlayer, nItemID)
    local pEquip = pPlayer.GetItemInBag(nItemID)
    if not pEquip then
        return false, "装备不存在！";
    end

    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        return false, "当前尚未开启!";
    end

    if tbBookInfo.LimitFaction > 0 and tbBookInfo.LimitFaction ~= pPlayer.nFaction then
        return false, string.format("门派不符合！");
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    if nBookLevel >= tbBookInfo.MaxBookLevel then
        return false, "已经达到最大等级"
    end

    local tbBookNextLevel = self:GetBookLevelInfo(nBookLevel + 1);
    if not tbBookNextLevel then
        return false, "已经达到最大等级!";
    end

    self:UpdateGrowXiuLianExp(pPlayer);
    local tbBookLevelInfo = self:GetBookLevelInfo(nBookLevel);
    local nBookExp = pPlayer.GetMoney(tbBook.szSkillBookExpName);
    if tbBookLevelInfo.CostExp <= 0 then
        return false, "当前尚未开启!!";
    end

    if tbBookLevelInfo.CostExp > nBookExp then
        local bAutoRet, szMsg = self:AutCostXiuWeiBook(pPlayer);
        return false, "修为点数不足，无法升级" .. szMsg;
    end

    return true, "", pEquip;
end

function tbBook:AutCostXiuWeiBook(pPlayer)
    if not MODULE_GAMESERVER then
        return false, "";
    end
    
    for _, nXiuWeiID in ipairs(self.tbAllXiuWeiBook) do
        local tbItems = pPlayer.FindItemInBag(nXiuWeiID) or {}
        local pItem = tbItems[1];
        if pItem then
            local szName = pItem.szName;
            Item:UseItem(pItem.dwId);
           return true, ", 自动消耗了一本"..szName;
        end
    end

    return false, "";
end


function tbBook:DoBookLevelUp(pPlayer, nItemID)
    local bRet, szMsg, pEquip = self:CheckBookLevelUp(pPlayer, nItemID);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    local tbBookLevelInfo = self:GetBookLevelInfo(nBookLevel);
    if not pPlayer.CostMoney(tbBook.szSkillBookExpName, tbBookLevelInfo.CostExp, Env.LogWay_MiJi) then
        Log("ERROR SkillBook DoBookLevelUp", pPlayer.dwID, tbBookLevelInfo.CostExp);
        return
    end

    local tbBookNextLevel = self:GetBookLevelInfo(nBookLevel + 1);
    self:BookSkillLevelUp(pPlayer, pEquip, tbBookNextLevel);
    pEquip.SetIntValue(self.nSaveBookLevel, nBookLevel + 1);
    pEquip.ReInit();
    FightPower:ChangeFightPower("SkillBook", pPlayer);
    pPlayer.CenterMsg("秘籍等级提升1级！");
    pPlayer.CallClientScript("Player:ServerSyncData", "SkillBookLevelUp", nItemID);
    Log("SkillBook DoBookLevelUp", pPlayer.dwID, pEquip.dwTemplateId, nBookLevel + 1);
end

function tbBook:BookSkillLevelUp(pPlayer, pEquip, tbBookLevelInfo)
    if not tbBookLevelInfo.SkillLevelUpRate or tbBookLevelInfo.SkillLevelUpRate <= 0 then
        return;
    end

    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        Log("Error SkillBook UpdateSkillBook Info", pEquip.dwTemplateId);
        return;
    end

    local nSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    if nSkillLevel >= tbBookInfo.MaxSkillLevel then
        return;
    end

    if nSkillLevel >= tbBookLevelInfo.SkillMinLevel then
        local nCurRate = MathRandom(self.nTotalSkillLevelRate);
        if nCurRate > tbBookLevelInfo.SkillLevelUpRate then
            return;
        end
    end

    pEquip.SetIntValue(self.nSaveSkillLevel, nSkillLevel + 1);
    pPlayer.CenterMsg("领悟成功，秘籍技能提升1级！");
    Log("SkillBook DoBookLevelUp BookSkillLevelUp", pPlayer.dwID, nSkillLevel + 1, pEquip.dwTemplateId);
end

function tbBook:CheckRecycleSkillBook(pPlayer, nItemID)
    local pEquip = pPlayer.GetItemInBag(nItemID)
    if not pEquip then
        return false, "装备不存在！";
    end

    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        return false, "当前尚未开启!";
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    if nBookLevel <= 1 then
        return false, string.format("不能拆解%s级秘籍", nBookLevel);
    end

    if tbBookInfo.LimitRecycle == 1 then
        return false, "不能拆解秘籍";
    end

    return true, "", pEquip;
end

function tbBook:GetBookCostExp(nBookLevel)
    local nCostExp = 0;
    for _, tbInfo in ipairs(self.tbBookLevelInfo) do
        if tbInfo.Level < nBookLevel then
            nCostExp = nCostExp + tbInfo.CostExp;
        else
            return nCostExp;
        end
    end

    return nCostExp;
end

function tbBook:GetSkillBookExp(pEquip)
    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    local nSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    local nCostExp = self:GetBookCostExp(nBookLevel);
    local tbSkillLevel = self:GetSkillLevelInfo(nSkillLevel);

    local nTotalExp = nCostExp * self.nBookCostExptRecycleP / 100;
    nTotalExp = nTotalExp + pEquip.nOrgValue / self.nValueRecycleParam * self.nBookBaseValueRecycleP / 100;
    nTotalExp = nTotalExp + tbSkillLevel.Value / self.nValueRecycleParam * tbSkillLevel.RecycleP / 100;
    nTotalExp = math.floor(nTotalExp);
    return nTotalExp;
end

function tbBook:RecycleSkillBook(pPlayer, nItemID)
    local bRet, szMsg, pEquip = self:CheckRecycleSkillBook(pPlayer, nItemID);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end
    self:UpdateGrowXiuLianExp(pPlayer);
    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    local nSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    local nCostExp = self:GetSkillBookExp(pEquip);
    local nItemTID = pEquip.dwTemplateId;

    local nConsumeCount = pPlayer.ConsumeItem(pEquip, 1, Env.LogWay_MiJi)
    if nConsumeCount <= 0 then
        pPlayer.CenterMsg("扣除道具失败！");
        return;
    end

    FightPower:ChangeFightPower("SkillBook", pPlayer);
    pPlayer.AddMoney(tbBook.szSkillBookExpName, nCostExp, Env.LogWay_MiJi);
    pPlayer.CenterMsg(string.format("秘籍拆解后，获得了%s点修为", nCostExp));
    pPlayer.CallClientScript("Player:ServerSyncData", "RecycleSkillBook");
    Log("SkillBook RecycleSkillBook",  pPlayer.dwID, nBookLevel, nSkillLevel, nItemTID);
end

function tbBook:CheckBookUpgrade(pPlayer, nItemID)
    local pEquip = pPlayer.GetItemInBag(nItemID)
    if not pEquip then
        return false, "装备不存在！";
    end

    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        return false, "当前尚未开启!";
    end

    if tbBookInfo.UpgradeItem <= 0 then
        return false, "秘籍不能升阶!";
    end

    if tbBookInfo.UpgradeID <= 0 then
        return false, "未开启升阶！！";
    end

    local tbBookUpgrade = self:GetBookUpgradeInfo(tbBookInfo.UpgradeID);
    if not tbBookUpgrade then
        return false, "秘籍不能升阶";
    end

    if GetTimeFrameState(tbBookUpgrade.TimeFrame) ~= 1 then
        return false, string.format("距离升阶还有%s", Lib:TimeDesc2(CalcTimeFrameOpenTime(tbBookUpgrade.TimeFrame) - GetTime()));
    end

    if pPlayer.nLevel < tbBookUpgrade.PlayerLevel then
        return false, string.format("您等级不足%s", tbBookUpgrade.PlayerLevel);
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    if nBookLevel < tbBookUpgrade.BookLevel then
        return false, string.format("秘籍等级不足%s", tbBookUpgrade.BookLevel);
    end

    local nBookSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    if nBookSkillLevel < tbBookUpgrade.BookSkillLevel then
        return false, string.format("秘籍的技能等级不足%s", tbBookUpgrade.BookSkillLevel);
    end

    local tbItemHideID = {};
    tbItemHideID[pEquip.dwId] = 1;
    for _, tbCost in pairs(tbBookUpgrade.tbAllCostIteam) do
        local nCount = pPlayer.GetItemCountInAllPos(tbCost.nItemTID, tbItemHideID);
        if nCount < tbCost.nItemCount then
            local szName = Item:GetItemTemplateShowInfo(tbCost.nItemTID, pPlayer.nFaction, pPlayer.nSex);
            return false, string.format("%s不足%s个", szName, tbCost.nItemCount);
        end
    end

    return true, "", pEquip;
end

function tbBook:ConsumeItemInBag(pPlayer, nItemTemplateId, nNeedCount, nLogReazon, tbHideID, nParam)
    local nConsumeCount = 0;
    local nXiuExp = 0;
    local nCountInBag, tbItem = pPlayer.GetItemCountInAllPos(nItemTemplateId, tbHideID);
    if nCountInBag < nNeedCount then
        return nConsumeCount, nXiuExp;
    end

    for _, pItem in ipairs(tbItem) do
        if not tbHideID or not tbHideID[pItem.dwId] then
            local nConsume = math.min(pItem.nCount, nNeedCount - nConsumeCount);
            if pItem.szClass == "SkillBook" then
                local nCurExp = self:GetSkillBookExp(pItem);
                local nGetExp = (nCurExp + nParam) * nConsume;
                nXiuExp = nXiuExp + math.max(0, nGetExp);
            end

            nConsume = pPlayer.ConsumeItem(pItem, nConsume, nLogReazon);
            nConsumeCount = nConsumeCount + nConsume;
            if nConsumeCount >= nNeedCount then
                break;
            end
        end
    end

    if nConsumeCount < nNeedCount then
        Log("SkillBook ConsumeItemInBag ERR nConsumeCount < nNeedCount", pPlayer.szName, pPlayer.dwID, nItemTemplateId, nNeedCount, nConsumeCount);
    end

    return nConsumeCount, nXiuExp;
end

function tbBook:DoBookUpgrade(pPlayer, nItemID)
    local bRet, szMsg, pEquip = self:CheckBookUpgrade(pPlayer, nItemID);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    self:UpdateGrowXiuLianExp(pPlayer);
    local nTotalXiuExp = 0;
    local tbItemHideID = {};
    tbItemHideID[pEquip.dwId] = 1;
    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    local tbBookUpgrade = self:GetBookUpgradeInfo(tbBookInfo.UpgradeID);
    for _, tbCost in pairs(tbBookUpgrade.tbAllCostIteam) do
        local nConsumeCount, nCostExp = self:ConsumeItemInBag(pPlayer, tbCost.nItemTID, tbCost.nItemCount, Env.LogWay_MiJiUpgrade, tbItemHideID, tbBook.nPerMiJiUpgradeParam);
        if nConsumeCount ~= tbCost.nItemCount then
            pPlayer.CenterMsg("扣除道具失败！", true);
            return;
        end

        nTotalXiuExp = nTotalXiuExp + nCostExp;
    end

    local nBookTID = pEquip.dwTemplateId;
    pEquip.ReInit(tbBookInfo.UpgradeItem);
    if nTotalXiuExp > 0 then
        pPlayer.AddMoney(tbBook.szSkillBookExpName, nTotalXiuExp, Env.LogWay_MiJiUpgrade);
        pPlayer.CenterMsg(string.format("秘籍升阶后，获得了%s点修为", nTotalXiuExp), true);
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    local nSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    pPlayer.CenterMsg("秘籍升阶成功！", true);
    pPlayer.CallClientScript("Player:ServerSyncData", "BookUpgrade", pEquip.dwId);
    FightPower:ChangeFightPower("SkillBook", pPlayer);
    Log("SkillBook DoBookUpgrade", pPlayer.dwID, nBookTID, nBookLevel, nSkillLevel, pEquip.dwTemplateId);
end

function tbBook:CheckBookTuPo(pPlayer, nItemID)
    local pEquip = pPlayer.GetItemInBag(nItemID)
    if not pEquip then
        return false, "装备不存在！";
    end

    local tbTuPoInfo = self:GetBookTuPoByEquip(pEquip);
    if not tbTuPoInfo then
        return false, "秘籍不可以突破";
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    if nBookLevel < tbTuPoInfo.BookLevel then
        return false, string.format("秘籍等级不足%s", tbTuPoInfo.BookLevel);
    end

    local nBookSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    if nBookSkillLevel < tbTuPoInfo.BookSkillLevel then
        return false, string.format("秘籍的技能等级不足%s", tbTuPoInfo.BookSkillLevel);
    end

    if nBookSkillLevel >= tbTuPoInfo.TuPoSkillLevel then
        return false, "秘籍不能够突破";
    end

    self:UpdateGrowXiuLianExp(pPlayer);
    local nBookExp = pPlayer.GetMoney(tbBook.szSkillBookExpName);
    if nBookExp < tbTuPoInfo.CostExp then
        return false, string.format("秘籍的修为不足%s", tbTuPoInfo.CostExp);
    end

    local tbItemHideID = {};
    tbItemHideID[pEquip.dwId] = 1;
    for _, tbCost in pairs(tbTuPoInfo.tbAllCostIteam) do
        local nCount = pPlayer.GetItemCountInAllPos(tbCost.nItemTID, tbItemHideID);
        if nCount < tbCost.nItemCount then
            local szName = Item:GetItemTemplateShowInfo(tbCost.nItemTID, pPlayer.nFaction, pPlayer.nSex);
            return false, string.format("%s不足%s个", szName, tbCost.nItemCount);
        end
    end

    return true, "", pEquip, tbTuPoInfo;
end

function tbBook:DoBookTuPo(pPlayer, nItemID)
    local bRet, szMsg, pEquip, tbTuPoInfo = self:CheckBookTuPo(pPlayer, nItemID);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    if not pPlayer.CostMoney(tbBook.szSkillBookExpName, tbTuPoInfo.CostExp, Env.LogWay_MiJiTuPo) then
        Log("ERROR SkillBook DoBookTuPo", pPlayer.dwID, tbTuPoInfo.CostExp);
        return
    end

    local tbItemHideID = {};
    tbItemHideID[pEquip.dwId] = 1;
    for _, tbCost in pairs(tbTuPoInfo.tbAllCostIteam) do
        local nConsumeCount = pPlayer.ConsumeItemInAllPos(tbCost.nItemTID, tbCost.nItemCount, Env.LogWay_MiJiTuPo, tbItemHideID);
        if nConsumeCount ~= tbCost.nItemCount then
            pPlayer.CenterMsg("扣除道具失败！", true);
            return;
        end
    end

    local nOrgSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    pEquip.SetIntValue(self.nSaveSkillLevel, tbTuPoInfo.TuPoSkillLevel);
    pEquip.ReInit();
    pPlayer.CenterMsg("秘籍突破成功！", true);
    pPlayer.CallClientScript("Player:ServerSyncData", "BookTuPo", pEquip.dwId);
    FightPower:ChangeFightPower("SkillBook", pPlayer);
    Log("SkillBook DoBookTuPo", pPlayer.dwID, nOrgSkillLevel, tbTuPoInfo.TuPoSkillLevel, pEquip.dwTemplateId);
end

function tbBook:CheckCanSell(pItem)
    if pItem.szClass ~= "SkillBook" then
        return false;
    end

    local nBookLevel = pItem.GetIntValue(self.nSaveBookLevel);
    if nBookLevel > 1 then
        return false;
    end

    local nPos = pItem.nPos;
    local nIndex = nPos - Item.EQUIPPOS_SKILL_BOOK + 1;
    if self.tbSkillBookHoleLevel[nIndex] then
        return false;
    end

    return true;
end

function tbBook:GetBookAttrib(tbBookInfo, nBookLevel)
    local tbAllAttrib = {};
    for nIndex, tbBookAttrib in ipairs(tbBookInfo.tbAllAttrib) do
        local tbAttribInfo   = {};
        tbAttribInfo.szType  = tbBookAttrib.szType;
        tbAttribInfo.tbValue = {};
        local tbValue = self:CalcAttribAddValue(tbBookAttrib.tbInit, tbBookAttrib.tbGrow, nBookLevel - 1);
        tbAttribInfo.tbValue[1] = math.floor(tbValue[1] / self.nAttribScaleValue);
        tbAttribInfo.tbValue[2] = math.floor(tbValue[2] / self.nAttribScaleValue);
        tbAttribInfo.tbValue[3] = math.floor(tbValue[3] / self.nAttribScaleValue);
        table.insert(tbAllAttrib, tbAttribInfo);
    end

    return tbAllAttrib;
end

function tbBook:GetShowTipInfo(nItemTID, nBookLevel, nBookSkillLevel)
    local tbBookInfo = self:GetBookInfo(nItemTID);
    if not tbBookInfo then
        return;
    end

    local tbAllAttrib = self:GetBookAttrib(tbBookInfo, nBookLevel);
    local tbSkillInfo = {nSkillID = tbBookInfo.SkillID, nSkillLevel = nBookSkillLevel};
    local tbItemInfo = KItem.GetEquipBaseProp(nItemTID);
    local nBaseFightPower     = tbItemInfo.nFightPower;
    local nBookFightPower     = self:GetFightPowerValue(tbBookInfo.LevelFightPowerID, nBookLevel);
    local nSkillFightPower    = self:GetFightPowerValue(tbBookInfo.SkillFightPowerID, nBookSkillLevel);
    local nFightPower         = nBaseFightPower + nBookFightPower + nSkillFightPower;
    return tbAllAttrib, tbSkillInfo, nFightPower;
end

function tbBook:FinEmptyHole(pPlayer)
    local nEndPos = Item.EQUIPPOS_SKILL_BOOK + #self.tbSkillBookHoleLevel - 1;
    for nEquipPos = Item.EQUIPPOS_SKILL_BOOK, nEndPos, 1 do
        local pItem = pPlayer.GetEquipByPos(nEquipPos);
        if not pItem then
            return nEquipPos;
        end
    end

end

function tbBook:UnuseAllSkillBook(pPlayer)
    local nEndPos = Item.EQUIPPOS_SKILL_BOOK + #self.tbSkillBookHoleLevel - 1;
    for nEquipPos = Item.EQUIPPOS_SKILL_BOOK, nEndPos, 1 do
        local pItem = pPlayer.GetEquipByPos(nEquipPos);
        if pItem then
            Item:UnuseEquip(nEquipPos);
        end
    end
end

function tbBook:CheckChangeFactionBook(pPlayer, pItem, nOrgFaction, nChangeFaction)
    local nBookType = self.tbFactionBookType[pItem.dwTemplateId];
    if not nBookType then
        return false;
    end

    local tbFactionBook = self.tbFactionBookSetting[nBookType];
    if not tbFactionBook then
        return false;
    end

    local tbChangeBook = tbFactionBook[nChangeFaction];
    if not tbChangeBook then
        return false;
    end

    if tbChangeBook.SkillBookID == pItem.dwTemplateId then
        return false;
    end

    if tbChangeBook.SkillBookID <= 0 then
        return false;
    end

    return true, tbChangeBook.SkillBookID;
end

function tbBook:ChangeFactionBook(pPlayer, nOrgFaction, nChangeFaction)
    local nEndPos = Item.EQUIPPOS_SKILL_BOOK + #self.tbSkillBookHoleLevel - 1;
    for nEquipPos = Item.EQUIPPOS_SKILL_BOOK, nEndPos, 1 do
        local pItem = pPlayer.GetEquipByPos(nEquipPos);
        if pItem then
            local bRet, nSkillBookID = self:CheckChangeFactionBook(pPlayer, pItem, nOrgFaction, nChangeFaction)
            if bRet then
                local nOrgTID = pItem.dwTemplateId;
                pItem.ReInit(nSkillBookID);
                --海外版的摆摊道具限制需要重新加入新的物品
                MarketStall:ResetItemSellLimit(nOrgTID, nSkillBookID, pPlayer)
                Log("SkillBook ChangeFactionBook pItem", pPlayer.dwID, nEquipPos, nOrgTID, nSkillBookID);
            else
                Log("Error SkillBook ChangeFactionBook pItem", pPlayer.dwID, pItem.dwTemplateId);
            end
        end
    end

    FightPower:ChangeFightPower("SkillBook", pPlayer);
    Log("SkillBook ChangeFactionBook", pPlayer.dwID, nOrgFaction, nChangeFaction);
end

function tbBook:UpdateRedPoint(pPlayer)
    local nEndPos = Item.EQUIPPOS_SKILL_BOOK + #self.tbSkillBookHoleLevel - 1;
    for nEquipPos = Item.EQUIPPOS_SKILL_BOOK, nEndPos, 1 do
        local nIndex = nEquipPos - Item.EQUIPPOS_SKILL_BOOK + 1;
        local pItem = pPlayer.GetEquipByPos(nEquipPos);
        local szRedPoint = "SkillPublicBook"..nIndex;
        if pItem then
            local bRet = self:CheckBookLevelUp(pPlayer, pItem.dwId);
            local bRet1 = self:CheckBookUpgrade(pPlayer, pItem.dwId);
            local bRet2 = self:CheckBookTuPo(pPlayer, pItem.dwId);
            local bRet3 = self:CheckBookEvolve(pPlayer, pItem.dwId);
            if bRet or bRet1 or bRet2 or bRet3 then
                if not Ui:GetRedPointState(szRedPoint) then
                    Ui:SetRedPointNotify(szRedPoint);
                end
            else
                if Ui:GetRedPointState(szRedPoint) then
                    Ui:ClearRedPointNotify(szRedPoint);
                end
            end
        else
            if Ui:GetRedPointState(szRedPoint) then
                Ui:ClearRedPointNotify(szRedPoint);
            end
        end
    end
end

function tbBook:GetEquipOperation(pEquip)
    local tbBookInfo = self:GetBookInfo(pEquip.dwTemplateId);
    if not tbBookInfo then
        return;
    end

    local nBookLevel = pEquip.GetIntValue(self.nSaveBookLevel);
    local nBookSkillLevel = pEquip.GetIntValue(self.nSaveSkillLevel);
    if nBookLevel < tbBookInfo.MaxBookLevel then
        return "LevelUp";
    end

    if nBookLevel == tbBookInfo.MaxBookLevel and nBookSkillLevel == tbBookInfo.MaxSkillLevel then
        if tbBookInfo.UpgradeItem <= 0 then
            if JueXue:CheckShowEvolve(pEquip.dwTemplateId) then
                return "Evolve";
            end
            return;
        end

        return "Upgrade";
    end

    local tbTuPoInfo = self:GetBookTuPoByEquip(pEquip);
    if tbTuPoInfo then
        return "TuPo";
    end
end

function tbBook:CheckBookEvolve(pPlayer, nItemID)
    local pEquip = pPlayer.GetItemInBag(nItemID)
    if not pEquip then
        return false
    end
    if not self:IsFactionBookMaxLevel(pEquip, pPlayer.nFaction) then
        return false
    end
    return JueXue:CheckShowEvolve(pEquip.dwTemplateId)
end

--目前只是心魔用 ，同类型的只要有一本就无用了,目前只是初级秘籍的判断
function tbBook:IsUsableItem(pPlayer, dwTemplateId)
    local tbItems = pPlayer.FindItemInPlayer("SkillBook")
    for i,v in ipairs(tbItems) do
        local nBookId = self:GetLowestBookId(v.dwTemplateId)
        if nBookId == dwTemplateId then
            return false
        end
    end
    return true
end

function tbBook:IsFactionBookMaxLevel(pBook, nFaction)
    local tbBookInfo = self:GetBookInfo(pBook.dwTemplateId)
    if not tbBookInfo then
        return
    end

    if tbBookInfo.LimitFaction > 0 and tbBookInfo.LimitFaction ~= nFaction then
        return
    end

    local nBookLevel = pBook.GetIntValue(self.nSaveBookLevel)
    if nBookLevel < tbBookInfo.MaxBookLevel then
        return
    end

    return true
end

tbBook.tbC2SCallFun =
{
    ["RecycleSkillBook"] = function (pPlayer, nItemID)
        if type(nItemID) ~= "number" then
            return;
        end

        tbBook:RecycleSkillBook(pPlayer, nItemID)
    end;

    ["DoBookLevelUp"] = function (pPlayer, nItemID)
        if type(nItemID) ~= "number" then
            return;
        end

        tbBook:DoBookLevelUp(pPlayer, nItemID)
    end;

    ["BookUpgrade"] = function (pPlayer, nItemID)
        if type(nItemID) ~= "number" then
            return;
        end

        tbBook:DoBookUpgrade(pPlayer, nItemID)
    end;

    ["BookTuPo"] = function (pPlayer, nItemID)
        if type(nItemID) ~= "number" then
            return;
        end

        tbBook:DoBookTuPo(pPlayer, nItemID)
    end;
}

function tbBook:OnLogin()
    self:UpdateGrowXiuLianExp(me);
end

function tbBook:OnLevelUp(nNewLevel)
    self:UpdateGrowXiuLianExp(me);
end

if MODULE_GAMESERVER then
PlayerEvent:RegisterGlobal("OnLogin",                       tbBook.OnLogin, tbBook);
PlayerEvent:RegisterGlobal("OnLevelUp",                     tbBook.OnLevelUp, tbBook);
end