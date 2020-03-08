Require("CommonScript/Item/Define.lua")

Shop.TREASURE_REFRESH       = 4 * 3600; --珍宝阁限购商品次数刷新时间4点
Shop.SHOW_LEVEL             = 14;
Shop.MONEY_DEBT_GROUP = 3; --货币欠款存储组
Shop.MONEY_DEBT_BUFF = 2310; --货币欠款提示buffid
Shop.MONEY_DEBT_ATTR_DEBUFF = 2314; --货币欠款能力debuffid
Shop.MONEY_DEBT_FIGHT_DEBUFF = 2318; --货币欠款战斗力衰减debuffid

Shop.MONEY_DEBT_START_TIME = 51; --本次货币欠款开始时间

Shop.ShopWares = {
    ["Treasure"]        = {};
    ["Dress"] = {};

    ["DrugShop"]        = {};
    ["WeaponShop"]      = {};
    ["WarShop"]      = {};
    ["WeddingShop"] = {};
}

Shop.tbShopMoneyType = {
    ["DrugShop"]    = "Contrib",
    ["WarShop"]     = "Found",
    ["WeddingShop"] = "Gold",
}

Shop.tbCustomShopName = {
    ["DrugShop"]         = "珍宝坊";
    ["WarShop"]          = "战争坊";
    ["WeddingShop"]     = "婚礼商店";
};

Shop.ACT_LIMIT_TYPE = 66; --活动商店的限购类型。周限购是7
Shop.WEEK_LIMIT_TYPE = 7; --周限购是7
Shop.Special_LIMIT_TYPE = 99;

Shop.tbAllDayLimit = {} --ser scriptData， clinet 打开界面时 sync
Shop.tbAllWeekLimit = {};
Shop.tbActivityLimitSell = {};
Shop.tbPlayerExpWares = {};

-- 配置表 [道具ID] = {折扣程度 , {外装ID_1，外装ID_2} },
-- 使用道具默认打开 外装ID_1所在的界面。外装ID_1未找到，打开2的，以此类推，均未找到，提示对应打折商品已经下架。
Shop.tbDiscountConfigure = {
    [10253] = { 5 , {10251} },
    [10472] = { 5 , {10602} },
}
-- Shop.tbDiscountItem = {
--     [7679] = {579, 580},
--     [6207] = {579},
--     [2667] = {580},
--     [6998] = {580},
-- }
Shop.tbDiscountItem = {};
function Shop:LoadDiscountMsg()
    for nDiscountPaperId , v in pairs(Shop.tbDiscountConfigure) do
        local Items = v[2];
        if Items then
            for _, nTemplateId in ipairs(Items) do
                Shop.tbDiscountItem[nTemplateId] = Shop.tbDiscountItem[nTemplateId] or {};
                table.insert(Shop.tbDiscountItem[nTemplateId],nDiscountPaperId);
            end
        end
    end
end
Shop:LoadDiscountMsg();
function Shop:LoadWares()
    Shop.tbPlayerExpWares = {};

    local tbWares = LoadTabFile(
        "Setting/Shop/Wares.tab", "dddsssddssddddddssdddddddd",nil,
        {"GoodsId", "TemplateId", "Price", "MoneyType", "ShopType","SubType", "Sort", "Discount", "TimeFrame", "CloseTimeFrame", "LimitType", "LimitNum", "HotTip", "MinLevel", "ShowLevel", "ShowVipLevel", "OpenTime", "CloseTime", "ForbidStall", "version_tx",  "version_vn",   "version_hk",   "version_xm",   "version_en",   "version_kor",  "version_th"});

    for i, v in ipairs(tbWares) do
        if Lib:CheckVersion(v) then
            local tbWares = self.ShopWares[v.ShopType];
            tbWares[v.GoodsId] =
            {
                nGoodsId    = v.GoodsId,
                nTemplateId = v.TemplateId,
                nPrice      = v.Price,
                szMoneyType = v.MoneyType,
                szShopType  = v.ShopType,
                nSort       = v.Sort,
                nDiscount   = v.Discount,
                nLimitType  = v.LimitType ~= 0 and v.LimitType,
                nLimitNum   = v.LimitNum,
                bHotTip     = v.HotTip == 1,
                szTimeFrame = v.TimeFrame,
                szCloseTimeFrame = v.CloseTimeFrame,
                nMinLevel   = v.MinLevel,
                nShowLevel  = v.ShowLevel,
                nShowVipLevel=v.ShowVipLevel,
                szOpenTime = v.OpenTime, --启动时没有获得服务端时区，就不要直接转成时间戳了
                szCloseTime = v.CloseTime,
                SubType = v.SubType,
                bForbidStall = v.ForbidStall == 1;
            }
        end
    end

    local tbFileData = Lib:LoadTabFile("Setting/Shop/PlayerExpWares.tab", {PlayerAddExpP = 1, ItemID = 1, LimitAddNum = 1});
    for _, tbInfo in pairs(tbFileData) do
        Shop.tbPlayerExpWares[tbInfo.TimeFrame] = Shop.tbPlayerExpWares[tbInfo.TimeFrame] or {};
        Shop.tbPlayerExpWares[tbInfo.TimeFrame][tbInfo.PlayerAddExpP] = Shop.tbPlayerExpWares[tbInfo.TimeFrame][tbInfo.PlayerAddExpP] or {};
        Shop.tbPlayerExpWares[tbInfo.TimeFrame][tbInfo.PlayerAddExpP][tbInfo.ItemID] = tbInfo;
    end
end
Shop:LoadWares();

function Shop:LoadEquipMakerSettings()
    self.tbEquipMakerSettings = LoadTabFile("Setting/Shop/EquipMaker.tab", "dddsddddddsd", nil,
            {"nId", "nHouse", "nQuality", "szQualityName", "nItem1Id",
            "nItem2Id", "nItem3Id", "nRate1", "nRate2", "nRate3", "szMoneyType", "nPrice"})

    local tbTmp = {}
    local nQualityMin, nQualityMax = math.huge, -1
    for nId, tb in pairs(self.tbEquipMakerSettings) do
        tbTmp[tb.nHouse] = tbTmp[tb.nHouse] or {}
        local nQuality = tb.nQuality
        tbTmp[tb.nHouse][nQuality] = tbTmp[tb.nHouse][nQuality] or {}
        table.insert(tbTmp[tb.nHouse][nQuality], nId)
        if nQuality>nQualityMax then
            nQualityMax = nQuality
        end
        if nQuality<nQualityMin then
            nQualityMin = nQuality
        end
    end
    self.nEquipMakerQualityMin = nQualityMin
    self.nEquipMakerQualityMax = nQualityMax

    for nHouse, tb in pairs(tbTmp) do
        for nQuality in pairs(tb) do
            table.sort(tbTmp[nHouse][nQuality], function(nA, nB)
                return nA<nB
            end)
        end
    end
    self.tbEquipMakerIdMap = tbTmp

    local tbRateSettings = LoadTabFile("Setting/Shop/EquipMakerRate.tab", "ddd", nil,
        {"nTimes", "nCCRate", "nXYRate"})
    self.tbEquipMakerRateSettings = {}
    for _,tb in ipairs(tbRateSettings) do
        self.tbEquipMakerRateSettings[tb.nTimes] = tb
    end
end
Shop:LoadEquipMakerSettings()

Shop.tbRenownShop = LoadTabFile("Setting/Shop/RenownShop.tab", "dddddds", "nId",
        {"nId", "nIndex", "nItemId", "nPrice", "nMaxCount", "nRate", "szTimeFrame"})

Shop.tbMoney =  LoadTabFile("Setting/MoneySetting.tab",
    "sdddddssssssss", "MoneyType",
    {"MoneyType", "SaveKey","DebtSaveKey", "Value", "ObjId", "Emotion", "Icon", "NumberColor", "StringColor", "Name", "BigIcon", "TipDesc", "IconAtlas", "BigIconAtlas"});


--除了在交易中心配的商品，在这里配的也可交易，不过只是卖
Shop.tbMarketable =  LoadTabFile("Setting/Shop/MarketableThing.tab",
    "ddsdsd", "TemplateId",
    {"TemplateId", "Price", "MoneyType", "PlayerLevel", "TimeFrameLimit", "NeedForbitStall"});


function Shop:GetPlayerExpItemInfo(nPlayerExpP, nItemId)
    local szCurTimeFrame = Lib:GetMaxTimeFrame(self.tbPlayerExpWares);
    if not szCurTimeFrame then
        return;
    end

    local tbTimeFramesWares = self.tbPlayerExpWares[szCurTimeFrame];
    if not tbTimeFramesWares then
        return;
    end

    local nPlayerAddExpP = nPlayerExpP - 100;
    local tbAllWares = tbTimeFramesWares[nPlayerAddExpP];
    if not tbAllWares then
        return;
    end

    return tbAllWares[nItemId];
end

function Shop:GetMoneyIcon(szMoneyType)
    local tbMoneySetting = self.tbMoney[szMoneyType];
    if not tbMoneySetting then
        if szMoneyType == "Found" then
            return "jianshezijinsmall", "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab"
        end
        Log("GetMoneyIcon Failure!", szMoneyType);
        return;
    end
    return tbMoneySetting.Icon, tbMoneySetting.IconAtlas;
end

function Shop:GetMoneyBigIcon(szMoneyType)
    local tbMoneySetting = self.tbMoney[szMoneyType];
    if not tbMoneySetting then
        Log("GetMoneyIcon Failure!".. szMoneyType);
        return;
    end
    return tbMoneySetting.BigIcon, tbMoneySetting.BigIconAtlas;
end

function Shop:GetMoneyName(szMoneyType)
    local tbMoneySetting = self.tbMoney[szMoneyType];
    if not tbMoneySetting then
        Log("GetMoneyName Failure!".. szMoneyType);
        return;
    end
    return tbMoneySetting.Name, "#" .. tbMoneySetting.Emotion;
end

function Shop:GetMoneyDesc(szMoneyType)
    local tbMoneySetting = self.tbMoney[szMoneyType];
    if not tbMoneySetting then
        Log("GetMoneyName Failure!".. szMoneyType);
        return;
    end
    return tbMoneySetting.TipDesc;
end

function Shop:GetMoneyValue(szMoneyType)
    local tbMoneySetting = self.tbMoney[szMoneyType];
    if not tbMoneySetting then
        Log("GetMoneyName Failure!".. szMoneyType);
        return;
    end
    return tbMoneySetting.Value;
end

function Shop:GetMoneyObjId(szMoneyType)
    local tbMoneySetting = self.tbMoney[szMoneyType];
    if not tbMoneySetting then
        Log("GetMoneyName Failure!".. szMoneyType);
        return;
    end
    return tbMoneySetting.ObjId;
end

function Shop:IsMoneyType(szMoneyType)
    local tbMoneySetting = self.tbMoney[szMoneyType];
    return tbMoneySetting ~= nil;
end

function Shop:CanBuyWarWare(pPlayer, nTemplateId, nBuyCount, nPrice)
    local tbItemInfo = DomainBattle.define.tbBattleApplyIds[nTemplateId]
    if not tbItemInfo then
        return false, "无商品信息"
    end

    if GetTimeFrameState(DomainBattle.define.szOpenTimeFrame) ~= 1 then
        return false, "时间轴未开放"
    end

   if MODULE_GAMESERVER then
        local tbKin = Kin:GetKinById(pPlayer.dwKinId)
        if not tbKin then
            return false, "无家族"
        end

        local tbMember = Kin:GetMemberData(pPlayer.dwID)
        if not tbMember then
            return false, "无家族"
        end

        local nCareer = tbMember:GetCareer()
        if not DomainBattle.define.tbCanUseItemCareer[nCareer] then
            return false, "您的权限不足"
        end

        local nCurFound = tbKin:GetFound()
        if nCurFound < nPrice * nBuyCount then
            return false, "家族建设资金不足"
        end
   else
        if not DomainBattle:CanUseBattleSupplys() then
            return false, "您的权限不足"
        end

        local tbBaseInfo = Kin:GetBaseInfo() or {};
        if not  tbBaseInfo.nFound or tbBaseInfo.nFound < nPrice * nBuyCount then
            return false, "家族建设资金不足"
        end
   end
   return true
end

function Shop:CanBuyGoodsWare(pPlayer, szShopType, nGoodsId, nBuyCount)
    local tbWare = self:GetGoodsWare(szShopType, nGoodsId);
    if not tbWare then
        return false, "不存在该商品";
    end

    return self:_CanBuyWare(pPlayer, tbWare, nBuyCount)
end

function Shop:_CanBuyWare(pPlayer, tbWare, nBuyCount)
    nBuyCount = math.floor(nBuyCount);
    if not nBuyCount or nBuyCount <= 0 then
        return false, "请选择购买数量";
    end

    local nPrice,nDiscount,nUseDiscountPaperId = self:GetPrice(pPlayer, tbWare);
    local nTemplateId = tbWare.nTemplateId

    local szShopType = tbWare.szShopType
    if szShopType == "WarShop" then
        return self:CanBuyWarWare(pPlayer, nTemplateId, nBuyCount, nPrice);
    end

    if not self:HasEnoughMoney(pPlayer, tbWare.szMoneyType, nPrice, nBuyCount) then
        local szMoneyName = self:GetMoneyName(tbWare.szMoneyType);
        local szTip = string.format("%s不足", szMoneyName);
        return false, szTip;
    end

    local bRet, szMsg = self:HasEnoughFreeBag(pPlayer, nTemplateId, nBuyCount)
    if not bRet then
        return false, szMsg;
    end

    if not self:CheckWareAvaliable(tbWare, pPlayer) then
        return false, "商品尚未上架"
    end

    if tbWare.nMinLevel and tbWare.nMinLevel > pPlayer.nLevel then
        return false, string.format("角色%s级后可购买", tbWare.nMinLevel)
    end

    if tbWare.nLimitType then
        local nRemainCount = self:GetWareRemainCount(pPlayer, tbWare);
        if nBuyCount > nRemainCount then
            return false, "剩余库存不足";
        end
    end

    local bFamiShop, bRand = self:IsFamilyShop(szShopType)
    if bFamiShop then
        if pPlayer.dwKinId == 0 then
            return false, "你没有家族，不能购买";
        end

        if bRand then
            local nDegree = self:GetFamilyWareDegree(pPlayer, szShopType, nTemplateId);
            if nBuyCount > nDegree then
                return false, "剩余库存不足";
            end
        else
            --家族等级等级要够
            local nBuildingId = Shop.tbFamilyShopCharToId[szShopType];
            local nBuildingLevel = self:GetBuildingLevel(pPlayer, nBuildingId);
            if nBuildingLevel < tbWare.nLevel then
                return false, "建筑等级不足"
            end
        end
    end

    if nDiscount and nUseDiscountPaperId then
        local szName = Item:GetItemTemplateShowInfo(nUseDiscountPaperId);
        local nHasNum = me.GetItemCountInAllPos(nUseDiscountPaperId);
        if nHasNum == nil or nHasNum < 1 then
            local szTip = string.format("背包%s不足",szName);
            return false , szTip;
        end;
    end

    return true;

end

--现在只是家族商店用
function Shop:CanBuyWare(pPlayer, szShopType, nTemplateId, nBuyCount)
    local tbWare = self:GetAWare(szShopType, nTemplateId);
    if not tbWare then
        return false, "不存在该商品";
    end

    return self:_CanBuyWare(pPlayer, tbWare, nBuyCount)
end

function Shop:GetFamilyWareDegree(pPlayer, szShopType, nTemplateId)
    --区分服务端和客户端
    local nDegree = 0;
    if self.GetFaimlyWareRemainClient then
        nDegree = self:GetFaimlyWareRemainClient(szShopType, nTemplateId);
    end

    if self.GetFamilyWareRemainServer then
        nDegree = self:GetFamilyWareRemainServer(pPlayer, szShopType, nTemplateId);
    end

    return nDegree;
end

function Shop:CheckWareTimeFrame(tbWare, szTimeFrame)
    if tbWare.nLimitType == self.WEEK_LIMIT_TYPE then
        local nOpenTime = CalcTimeFrameOpenTime(szTimeFrame)
        local nLastWeekStartTime = Lib:GetLocalWeekEndTime(GetTime() - Shop.TREASURE_REFRESH) - 3600*24*7 + Shop.TREASURE_REFRESH
        if nOpenTime > nLastWeekStartTime then
            return false;
        end
    else
        if GetTimeFrameState(szTimeFrame) ~= 1 then
            return false;
        end
     end
     return true
end

function Shop:CheckWareAvaliable(tbWare, pPlayer)
    if tbWare.nShowLevel and tbWare.nShowLevel > pPlayer.nLevel then
        return false;
    end

    if tbWare.nShowVipLevel and tbWare.nShowVipLevel ~= 0 then
        if pPlayer.GetVipLevel() < tbWare.nShowVipLevel then
            return false
        end
    end

    local szTimeFrame = tbWare.szTimeFrame
    if not Lib:IsEmptyStr(szTimeFrame) then
        if not self:CheckWareTimeFrame(tbWare, szTimeFrame) then
            return false;
        end
    end

    local szCloseTimeFrame = tbWare.szCloseTimeFrame
    if not Lib:IsEmptyStr(szCloseTimeFrame) then
       if self:CheckWareTimeFrame(tbWare, szCloseTimeFrame) then
            return false;
        end
    end

    local nNow = GetTime()
    if not Lib:IsEmptyStr(tbWare.szOpenTime) then
        if nNow < Lib:ParseDateTime(tbWare.szOpenTime) then
            return false
        end
    end
    if not Lib:IsEmptyStr(tbWare.szCloseTime) then
        if nNow > Lib:ParseDateTime(tbWare.szCloseTime) then
            return false
        end
    end
    return true
end

function Shop:CanSellWare(pPlayer, nItemId, nCount)
    local nCount = math.floor(nCount);
    if not nItemId or not nCount or nCount <= 0 then
        return false, "出售数量错误";
    end

    local pItem = pPlayer.GetItemInBag(nItemId);
    if not pItem then
        return false, "不存在该物品";
    end

    if pItem.nCount < nCount then
        return false, "物品数量不足";
    end

    if not MODULE_GAMESERVER then
        local nSumPrice, szMoneyType = self:GetSellSumPrice(pPlayer, pItem.dwTemplateId, nCount, pItem);
        if not nSumPrice or not szMoneyType then
            return false, "无价格配置"
        end
    end

    return true;
end

function Shop:GetHonorSellWare(dwTemplateId)
    local tbWare = Shop:GetAWare("Honor", dwTemplateId)
    if tbWare then
        return tbWare
    end
    tbWare = Shop:GetAWare("Biography", dwTemplateId)
    if tbWare then
        return tbWare
    end

    local nUnIdentiItem = Item.tbUnidentifyItemList[dwTemplateId]
    if nUnIdentiItem then
        tbWare = Shop:GetAWare("Honor", nUnIdentiItem)
        if tbWare then
            return tbWare
        end

        tbWare = Shop:GetAWare("Biography", nUnIdentiItem)
        if tbWare then
            return tbWare
        end
    end
end

function Shop:HasEnoughFreeBag(pPlayer, nTemplateId, nAddCount)
    local nFreeBagCount, szMsg = pPlayer.GetFreeBagCount();
    local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);

    if not tbBaseInfo then
        return false, "不存在该道具";
    end

    local nStackMax =  tbBaseInfo.nStackMax;

    if nStackMax == 0 then
        return nFreeBagCount - nAddCount > 0, szMsg;
    else
        local nCount, tbItems = pPlayer.GetItemCountInAllPos(nTemplateId);
        local nCurFree = 0;
        for _, pItem in ipairs(tbItems) do
            nCurFree = nCurFree + nStackMax - pItem.nCount;
        end
        --减去当前堆可继续增加的数量
        nAddCount = nAddCount - nCurFree;
        local nNeedBag = math.ceil(nAddCount / nStackMax);

        return nFreeBagCount -  nNeedBag >= 0, szMsg;
    end
end


function Shop:HasEnoughMoney(pPlayer, szMoneyType, nPrice, nCount)
    local nMoneyHave = pPlayer.GetMoney(szMoneyType);
    return nPrice * nCount <= nMoneyHave;
end

function Shop:FindMarketableThing(nCheckTemplateId, pItem)
    local tbWare = self.tbMarketable[nCheckTemplateId];
    if tbWare then
        if pItem and tbWare.NeedForbitStall == 1 and not Item:IsForbidStall(pItem) then
            return
        end
        if not Lib:IsEmptyStr(tbWare.TimeFrameLimit) and GetTimeFrameState(tbWare.TimeFrameLimit) ~= 1 then
            return
        end
        local tbData =
        {
            nTemplateId = tbWare.TemplateId,
            nPrice = tbWare.Price,
            szMoneyType = tbWare.MoneyType,
            nPlayerLevel = tbWare.PlayerLevel or 0;
        }
        return tbData;
    end
end

function Shop:GetGoodsWare(szShopType, nGoodsId)
    local tbWares = self.ShopWares[szShopType];
    if tbWares then
        return tbWares[nGoodsId]
    end
end

function Shop:GetAWare(szShopType, nTemplateId)
    local tbWares = self.ShopWares[szShopType];
    if tbWares then
        local bFamiShop, bRand = self:IsFamilyShop(szShopType)
        if bFamiShop then
            if bRand then
                for nLevel, tbPool in pairs(tbWares) do
                    for _,tbWares in pairs(tbPool) do
                        if tbWares[nTemplateId] then
                            return tbWares[nTemplateId];
                        end
                    end
                end
            else
                for nLevel, v in pairs(tbWares) do
                    if v[nTemplateId] then
                        return v[nTemplateId];
                    end
                end
            end
        else
            return tbWares[nTemplateId];
        end
    end
end

function Shop:GetPlayerExpExtCount(pPlayer, nItemId)
    local tbLevelInfo = Npc:GetPlayerLevelAddExpP(); --服务端不要用这个接口 频繁调用有性能问题 服务端有特殊的接口用
    if not tbLevelInfo then
        return 0;
    end

    local nExtP = tbLevelInfo[pPlayer.nLevel];
    if not nExtP then
        return 0;
    end

    local tbExpItemInfo = self:GetPlayerExpItemInfo(nExtP, nItemId);
    if not tbExpItemInfo then
        return 0;
    end

    return tbExpItemInfo.LimitAddNum;
end

function Shop:GetWareRemainCount(pPlayer, tbWares)
    local tbRoleLimitInfo = Shop:GetLimitInfo(pPlayer, tbWares.nLimitType)
    if not tbRoleLimitInfo then
        return 0;
    end

    local nExtLimtCount = 0;
    if tbWares.nLimitType == Shop.WEEK_LIMIT_TYPE then
        nExtLimtCount = self:GetPlayerExpExtCount(pPlayer, tbWares.nTemplateId);
    end

    local nKey = self:GetLimitSaveKey(tbWares)
    return math.max(0, tbWares.nLimitNum + nExtLimtCount - (tbRoleLimitInfo[nKey] or 0) )
end

function Shop:GetLimitSaveKey(tbWares)
    return tbWares.nLimitType == Shop.ACT_LIMIT_TYPE and tbWares.nGoodsId or tbWares.nTemplateId;
end

function Shop:GetUnidentifySellInfo(nTemplateId, nCount, nNormalPriceParam)
    local tbItemInfo = KItem.GetItemBaseProp(nTemplateId)
    local szSellMoneyTypeForHigh;
    if tbItemInfo.szClass == "Unidentify" then
        szSellMoneyTypeForHigh = "Contrib";
    elseif tbItemInfo.szClass == "UnidentifyZhenYuan" then
        szSellMoneyTypeForHigh = "Energy";
    end
    if not szSellMoneyTypeForHigh then
        return
    end

    local nPrice = MarketStall:GetPriceInfo("item", nTemplateId)
    if not nPrice then
        local nResutlItemId = KItem.GetItemExtParam(nTemplateId, 1)
        local tbItemInfoTar = KItem.GetItemBaseProp(nResutlItemId)
	    if not tbItemInfoTar then
	        Log(nResutlItemId, debug.traceback())
	        return
	    end
        nPrice = tbItemInfoTar.nPrice / 1000
    end

    if tbItemInfo.nDetailType == Item.DetailType_Normal then --普通真元出售价格是0.35
        return math.max(math.floor(nPrice * 100 * nNormalPriceParam * nCount + 0.1) , 1), "Coin"
    elseif tbItemInfo.nDetailType == Item.DetailType_Rare or tbItemInfo.nDetailType == Item.DetailType_Inherit then
        return math.max(math.floor(nPrice * 10 * 0.5* nCount + 0.1) , 1), szSellMoneyTypeForHigh
    end
end

Shop.tbItemClassSellFunc = {
    ["Unidentify"] = function (self, nTemplateId, nCount, tbItemInfo)
        return Shop:GetUnidentifySellInfo(nTemplateId, nCount, 0.5)
    end;
    ["UnidentifyZhenYuan"] =  function (self, nTemplateId, nCount, tbItemInfo)
        return Shop:GetUnidentifySellInfo(nTemplateId, nCount, 0.35)
    end;
    ["UnidentifyRefineStone"] = function (self, nTemplateId, nCount, tbItemInfo)
        return math.max(math.floor(tbItemInfo.nPrice / 10 * 0.2) * nCount, 1), "Coin"
    end;
    ["PartnerSkillBook"] = function (self, nTemplateId, nCount)
        local nPrice = MarketStall:GetPriceInfo("item", nTemplateId)
        if nPrice then
            return math.max(math.floor(nPrice * 10 / 4) * nCount, 1), "Contrib"
        end
    end;
    ["ComposeMeterial"] = function (self, nTemplateId, nCount)
        local nTargerItemId, nComposeNum = Compose.EntityCompose:GetEquipComposeInfo(nTemplateId)
        if nTargerItemId then
           local nPrice, szMoneyType = self:GetUnidentifySellInfo(nTargerItemId, 1)
           if nPrice then
                return math.max(math.floor(nPrice / nComposeNum) * nCount, 1), szMoneyType
           end
        end
    end;
    ["equip"] = function (self, nTemplateId, nCount, tbItemInfo)
        local nPrice = tbItemInfo.nPrice / 1000
        local nUnIdentiItem = Item.tbUnidentifyItemList[nTemplateId]
        if  nUnIdentiItem then
           local nMarketPrice = MarketStall:GetPriceInfo("item", nUnIdentiItem)
           if nMarketPrice then
                nPrice = nMarketPrice
           end
        end
        local szMoneyType = Item.tbSellMoneyType[tbItemInfo.nDetailType]
        if szMoneyType then
            if szMoneyType == "Coin" then
                return math.max(math.floor(nPrice * 100 * 0.3) * nCount, 1), szMoneyType
            elseif szMoneyType == "Contrib"  then
                return math.max(math.floor(nPrice * 10 * 0.3) * nCount, 1), szMoneyType
            end
        end
    end;
    ["RefineStone"] = function (self, nTemplateId, nCount, tbItemInfo)
        return math.max(math.floor(tbItemInfo.nPrice / 10 * 0.2) * nCount, 1), "Coin"
    end;
    ["ZhenYuan"] = function (self, nTemplateId, nCount, tbItemInfo)
        if tbItemInfo.nDetailType == Item.DetailType_Rare or tbItemInfo.nDetailType == Item.DetailType_Inherit then
            return math.max(math.floor(tbItemInfo.nPrice / 100 * 0.3) * nCount, 1), "Energy"
        elseif tbItemInfo.nDetailType == Item.DetailType_Normal then
            return math.max(math.floor(tbItemInfo.nPrice / 10 * 0.2) * nCount, 1), "Coin"
        end
    end;
    ["Stone"] = function (self, nTemplateId, nCount, tbItemInfo)
        local tbQue = StoneMgr:GetStoneLevelQueue(nTemplateId)
        local v1 = tbQue[1]
        if not v1 then
            return
        end
        local tbItemBase1 = KItem.GetItemBaseProp(v1)
        local tbAllowQuality = {1,2,3,4};
        --if GetTimeFrameState("OpenLevel79") == 1 then
        --    table.insert(tbAllowQuality, 2)
        --end
        --if GetTimeFrameState("OpenLevel109") == 1 then
        --    table.insert(tbAllowQuality, 3)
        --end
        for _, nSellQuality in ipairs(tbAllowQuality) do
            if tbItemBase1.nQuality == nSellQuality then
                local nPrice = MarketStall:GetPriceInfo("item", nTemplateId)
                if nPrice then
                    return math.max(math.floor(nPrice * 10 *0.2) * nCount, 1), "Contrib"
                end
                break;
            end
        end
      end;

    ["SkillMaxLevel"] = function (self, nTemplateId, nCount, tbItemInfo, pPlayer)
        local tbMaxItem = Item:GetClass("SkillMaxLevel");
        local bRet, tbSellInfo = tbMaxItem:CheckSellItem(pPlayer, nTemplateId);
        if not bRet then
            return;
        end

        local nValue = tbSellInfo[2] * nCount;
        return nValue, tbSellInfo[1];
    end;
    ["QuickBuyFromMS"] = function (self, nTemplateId, nCount, tbItemInfo)
        local nMaxSellLevel;
        local tbTimeFrames = {"OpenDay99", "OpenDay224", "OpenDay399" };
        for i,v in ipairs(tbTimeFrames) do
            if GetTimeFrameState(v) == 1 then
                nMaxSellLevel = i;
            else
                break;
            end
        end
        if not nMaxSellLevel then
            return
        end

        local nMarketPrice = MarketStall:GetPriceInfo("item", nTemplateId)
        if not nMarketPrice then
            return
        end
        if tbItemInfo.nLevel > nMaxSellLevel then
            return
        end
        return  math.max(nMarketPrice *0.5 * 100 *nCount, 1),  "Coin"
    end;

    ["CollectAndRobClueBox"] = function (self, nTemplateId, nCount, tbItemInfo, pPlayer)
        if Activity:__IsActInProcessByType("CollectAndRobClue") then
            return
        end
        local tbItems,nItemCount = pPlayer.FindItemInBag(nTemplateId)
        local nPrice = 0
        local tbItemClass = Item:GetClass("CollectAndRobClue");
        for i=1,nCount do
            local pItem = tbItems[i]
            if pItem then
                nPrice = tbItemClass.SELL_BASE + tbItemClass.SELL_PRICE * pItem.GetIntValue(tbItemClass.IntKeyDebrisCount)
            end
        end
        return  nPrice,  "Coin"
    end;
    ["CollectAndRobClue"] = function (self, nTemplateId, nCount, tbItemInfo, pPlayer)
        if Activity:__IsActInProcessByType("CollectAndRobClue") then
            return
        end

        return  Item:GetClass("CollectAndRobClue").CLUE_SELL_PRICE * nCount,  "Coin"
    end;
    ["MibenBook"] = function (self, nTemplateId, nCount, tbItemInfo)
        return tbItemInfo.nPrice * nCount, "SkillExp"
    end;
    ["DuanpianBook"] = function (self, nTemplateId, nCount, tbItemInfo)
        return tbItemInfo.nPrice * nCount, "SkillExp"
    end;
    ["RechargeSumOpenBox"] = function (self, nTemplateId, nCount, tbItemInfo)
        if Activity:__IsActInProcessByType("RechargeSumOpenBox") then
            return nil,nil,true
        end
    end;
};

Shop.tbItemClassSellFunc["EquipMeterial"] = Shop.tbItemClassSellFunc["ComposeMeterial"];
Shop.tbItemClassSellFunc["NormalMeterial"] = Shop.tbItemClassSellFunc["ComposeMeterial"];

function Shop:GetSellSumPrice(pPlayer, nTemplateId, nCount, pItem)
    --如果是想class的处理之后不继续判断FindMarketableThing里是否可卖，class fuc回传的第三个参数传true
    local tbItemInfo = KItem.GetItemBaseProp(nTemplateId)
   local fFunc = self.tbItemClassSellFunc[tbItemInfo.szClass]
   if fFunc then
        local szMoney, szMoneyType, bNotConti = fFunc(self, nTemplateId, nCount, tbItemInfo, pPlayer, pItem)
        if bNotConti then
            return szMoney, szMoneyType
        end
        if szMoney and szMoneyType then
            return szMoney, szMoneyType
        end
   end
    local tbWare = self:FindMarketableThing(nTemplateId, pItem);
    if tbWare then
        if tbWare.nPlayerLevel and pPlayer.nLevel < tbWare.nPlayerLevel then
            return;
        end

        local nSumPrice = tbWare.nPrice * nCount;
        nSumPrice = nSumPrice < 1 and 1 or nSumPrice;
        return nSumPrice, tbWare.szMoneyType;
    end
end

--------------------家族商店--------------------------

--[[--ShopWares 商店表
    tb = {
        [szShopType] = {
            [nLevel] = {
                [nPool] = {
                    [TemplateId] = {...}
                    [TemplateId] = {...}
                    ...
                }
            }
        }
    }
]]


--[[--scriptdata 玩家数据
    tbFamilyShop = {
        [nRecodeTime] = 120448 --

        [szShopType] = { -- buildingId
            [tbWares] = {
                [1] = {
                    TemplateId = 123,
                    -- nTotalCount = 10,
                    nCount = 9,
                },
                [2] = ...
                ...
            };
            [nLevel] = 10,
        }
    }
]]

--[[--随机池子
Shop.FamilyPool = {
    [ShopType] = {
        [1] = {
            [1] = {Prob1, Prob2, Count1, Count2}
            [2] = {},
            [3] = {},
        }
    }
}

]]

Shop.FAMILY_SHOP_REFRESH = 4 * 3600;    --家族商店凌晨4点刷新
Shop.FAMILY_SHOP_MAX_ITEM = 50          --每个家族商店最多物品数


Shop.tbFamilyShopIdToChar = {
    [Kin.Def.Building_DrugStore]    = "DrugShop",
    [Kin.Def.Building_WeaponStore]  = "WeaponShop",
    [Kin.Def.Building_FangJuHouse]  = "FangJuHouse",
    [Kin.Def.Building_ShouShiHouse]  = "ShouShiHouse",
    [Kin.Def.Building_War]           = "WarShop",
}

Shop.tbFamilyShopCharToId = {
    ["DrugShop"] = Kin.Def.Building_DrugStore,
    ["WeaponShop"] = Kin.Def.Building_WeaponStore,
    ["FangJuHouse"] = Kin.Def.Building_FangJuHouse,
    ["ShouShiHouse"] = Kin.Def.Building_ShouShiHouse,
    ["WarShop"] = Kin.Def.Building_War,
}

Shop.FamilyPool = {
    ["DrugShop"]       = {},
}

Shop.FamilyPoolPlayerLevelLimit = {
    ["DrugShop"]       = {},
}

function Shop:LoadFamilyPool()
    local tbPoolSetting = LoadTabFile(
        "Setting/Shop/FamilyPool.tab", "ddsddddddd", nil,
        {"Level", "PlayerLevel","ShopType", "Pool", "Count1", "Prob1", "Count2", "Prob2", "ReplaceLevel", "ReplacePool"});

    self.tbReplacePool = {};
    for _,v in pairs(tbPoolSetting) do
        local tbPool = self.FamilyPool[v.ShopType]
        assert(tbPool, v.ShopType)
        tbPool[v.Level] = tbPool[v.Level] or {};
        tbPool[v.Level][v.Pool] = {v.Count1, v.Prob1, v.Count2, v.Prob2, v.PlayerLevel};
        self.FamilyPoolPlayerLevelLimit[v.ShopType][v.Level] = v.PlayerLevel;
        if v.ReplaceLevel ~= 0 and v.ReplacePool ~= 0 then
            self.tbReplacePool[v.Level] = self.tbReplacePool[v.Level] or {}
            self.tbReplacePool[v.Level][v.Pool] = {v.ReplaceLevel, v.ReplacePool};
        end
    end
end
Shop:LoadFamilyPool();



function Shop:LoadFamilyWares()
    local tbWares = LoadTabFile(
        "Setting/Shop/FamilyWares.tab", "ddssdddddsdddddddd",nil,
        {"TemplateId", "Price", "MoneyType", "ShopType", "Sort", "Level", "Pool", "Count", "Discount", "TimeFrame", "HotTip", "MinLevel","NotVersion_tx", "NotVersion_vn","NotVersion_hk","NotVersion_xm","NotVersion_kor","NotVersion_th"});

    for _, v in pairs(tbWares) do
        if not Lib:CheckNotVersion(v) then
            if self.ShopWares[v.ShopType] then
                local tbWares = self.ShopWares[v.ShopType];
                tbWares[v.Level] = tbWares[v.Level] or {};
                local tbPoolWares;
                if v.Pool ~= 0 then
                    tbWares[v.Level][v.Pool] = tbWares[v.Level][v.Pool] or {};
                    tbPoolWares = tbWares[v.Level][v.Pool];
                else
                    tbPoolWares = tbWares[v.Level]
                end

                tbPoolWares[v.TemplateId] =
                {
                    nTemplateId = v.TemplateId,
                    nPrice      = v.Price,
                    szMoneyType = v.MoneyType,
                    szShopType  = v.ShopType,
                    nSort       = v.Sort,
                    nLevel      = v.Level,
                    nPool       = v.Pool,
                    nCount      = v.Count,

                    nDiscount   = v.Discount,
                    bHotTip     = v.HotTip == 1,
                    szTimeFrame = v.TimeFrame,
                    nMinLevel   = v.MinLevel,
                }
            end
        end
    end
end
Shop:LoadFamilyWares();

Shop.tbFamilyDiscount = {};
function Shop:LoadFamilyDiscount()
    -- tab 中的level 是差的等级＋１
    local szTypes = "s"
    local tbKeys = {"ShopType"}
    for i=1, Kin.Def.nMaxBuildingLevel do
        szTypes = szTypes.."d"
        table.insert(tbKeys, "Level"..i)
    end
    local tbDiscountSetting = LoadTabFile("Setting/Shop/FamilyDiscount.tab", szTypes, "ShopType", tbKeys);
    for szShopType, v in pairs(tbDiscountSetting) do
        self.tbFamilyDiscount[szShopType] = {}
        for i = 1, Kin.Def.nMaxBuildingLevel do
            assert(v["Level" .. i] > 0, i)
            self.tbFamilyDiscount[szShopType][i] = v["Level" .. i]
        end
    end
end
Shop:LoadFamilyDiscount();

function Shop:CheckDressDiscount(pPlayer, tbData)
    local szShopType = tbData.szShopType;
    if szShopType ~= "Dress" then return end;
    local nDiscount = tbData.nDiscount or 0;
    local nTemplateId = tbData.nTemplateId or 0;
    local tbDiscountItem = Shop.tbDiscountItem[nTemplateId];
    local tbDiscountConfigure = Shop.tbDiscountConfigure;
    if not tbDiscountItem or not tbDiscountConfigure then return end;

    local nUseDiscountPaperId = -1;
    for _, nDiscountPaperId in pairs(tbDiscountItem) do
        -- Check 玩家身上是否有 这个打折券Id;
        local nHasNum = pPlayer.GetItemCountInAllPos(nDiscountPaperId);
        if tbDiscountConfigure[nDiscountPaperId] and nHasNum > 0 then
            local nParperDiscount = tbDiscountConfigure[nDiscountPaperId][1];
            if nParperDiscount ~= nil then
                if nDiscount == 0 then
                    nDiscount = nParperDiscount;
                    nUseDiscountPaperId = nDiscountPaperId;
                else
                    if nParperDiscount ~= 0 and nParperDiscount < nDiscount then
                        nDiscount = nParperDiscount;
                        nUseDiscountPaperId = nDiscountPaperId;
                    end
                end
            end
        end
    end
    local nPrice = tbData.nPrice;
    if nDiscount == 0 or nUseDiscountPaperId == -1 then return nil end;
    nPrice = math.floor(tbData.nPrice * nDiscount / 10);
    local tbRes = {};
    tbRes.nPrice = nPrice;
    tbRes.nUseDiscountPaperId = nUseDiscountPaperId;
    tbRes.nDiscount = nDiscount;
    return tbRes;
end

function Shop:GetPrice(pPlayer, tbWares)
    local nPrice = tbWares.nPrice
    local szShopType = tbWares.szShopType
    if self:IsFamilyShop(szShopType) then
        local nAppealLevel = tbWares.nLevel --道具的出现等级
        local nBuildingId = self.tbFamilyShopCharToId[szShopType];
        local nLevel = self:GetBuildingLevel(pPlayer, nBuildingId);
        -- 商品打折等级按当前商店等级 与 商品出现等级 的差值来走
        local nDiscount = self:GetFamilyDiscount(szShopType, nLevel);

        nPrice = nPrice * nDiscount;
        nPrice = math.floor(nPrice + 0.5);--四舍五入
        nPrice = nPrice < 1 and 1 or nPrice;

        if szShopType == "WarShop" then --攻城战活动要显示折扣，是折上折
            nDiscount = 8
            if Activity:__IsActInProcessByType("DomainBattleAct") then
                nPrice =  math.ceil(nPrice * nDiscount / 10)
                return nPrice, nDiscount
            end
        end
        return nPrice;
    elseif szShopType == "Dress" then
        local tbDiscount = Shop:CheckDressDiscount(pPlayer, tbWares);
        if not tbDiscount then return nPrice end;
        nPrice = tbDiscount.nPrice or nPrice;
        return nPrice,tbDiscount.nDiscount,tbDiscount.nUseDiscountPaperId;
    else
        return nPrice;
    end
end

function Shop:GetFamilyDiscount(szShopType, nLevel)

    local tbDsicountInfo = self.tbFamilyDiscount[szShopType]
    if not tbDsicountInfo then
        return 1
    end
    local nDiscount = tbDsicountInfo[nLevel] or 10000;
    nDiscount = nDiscount / 10000;
    return nDiscount;
end

function Shop:GetEquipMakerPrice(pPlayer, nId)
    local tbSetting = self.tbEquipMakerSettings[nId]
    local nBuildingLevel = self:GetBuildingLevel(pPlayer, tbSetting.nHouse)
    local nOpenLevel = tbSetting.nOpenLevel
    local szShopType = self.tbFamilyShopIdToChar[tbSetting.nHouse]
    local nDiscount = self:GetFamilyDiscount(szShopType, nBuildingLevel)
    local nPrice = tbSetting.nPrice * nDiscount
    nPrice = math.floor(nPrice + 0.5)
    return nPrice < 1 and 1 or nPrice
end

function Shop:GetBuildingLevel(pPlayer, nBuildingId)
    if self.GetBuildingLevelClient then
        return self:GetBuildingLevelClient(nBuildingId);
    end

    if self.GetBuildingLevelServer then
        return self:GetBuildingLevelServer(pPlayer, nBuildingId);
    end
end

function Shop:GetShopMoneyType(szShopType)
    return self.tbShopMoneyType[szShopType];
end

-- 第二个参数是否随机商店 药品坊，天工坊 是 随机商店，武器店不是
function Shop:IsFamilyShop(szShopType)
    if not self.tbFamilyShopCharToId[szShopType] then
        return
    end
    if self.FamilyPool[szShopType] then
        return true, true
    end
    return true
end

function Shop:IsEquipMakerQualityOpen(nQuality)
    local szTimeFrame = Kin.Def.tbEquipMakerQualityTimeFrames[nQuality]
    if not szTimeFrame or szTimeFrame=="" then
        return true
    end
    return GetTimeFrameState(szTimeFrame)==1
end

function Shop:EquipMakerGetCurMaxQuality()
    local tbQualities = {}
    for nQuality in pairs(Kin.Def.tbEquipMakerQualityTimeFrames) do
        table.insert(tbQualities, nQuality)
    end
    table.sort(tbQualities, function(nA, nB)
        return nA<nB
    end)

    local nCurQuality = 0
    for _, nQuality in ipairs(tbQualities) do
        if self:IsEquipMakerQualityOpen(nQuality) then
            nCurQuality = nQuality
        else
            break
        end
    end
    return nCurQuality
end

function Shop:EquipMakerGetNextQualityInfo()
    local tbQualities = {}
    for nQuality in pairs(Kin.Def.tbEquipMakerQualityTimeFrames) do
        table.insert(tbQualities, nQuality)
    end
    table.sort(tbQualities, function(nA, nB)
        return nA<nB
    end)

    local nNextQuality = 0
    for _, nQuality in ipairs(tbQualities) do
        if not self:IsEquipMakerQualityOpen(nQuality) then
            nNextQuality = nQuality
            break
        end
    end

    if nNextQuality<=0 then
        return
    end
    local szNextTimeFrame = Kin.Def.tbEquipMakerQualityTimeFrames[nNextQuality]
    local nOpenTime = CalcTimeFrameOpenTime(szNextTimeFrame)
    local nNextDay = Lib:GetLocalDay(nOpenTime) - Lib:GetLocalDay()
    return nNextDay, nNextQuality
end

function Shop:CanMakeEquip(pPlayer, nId)
    if not pPlayer.dwKinId or pPlayer.dwKinId<=0 then
        return false, "你没有家族，不能打造"
    end

    local tbSetting = self.tbEquipMakerSettings[nId]
    if not self:IsEquipMakerQualityOpen(tbSetting.nQuality) then
        return false, "尚未开放"
    end

    local nPrice = self:GetEquipMakerPrice(pPlayer, nId)
    if pPlayer.GetMoney(tbSetting.szMoneyType)<nPrice then
        return false, string.format("%s不足", Shop:GetMoneyName(tbSetting.szMoneyType))
    end

    return true
end

Shop.nRenownShopSaveGrp = 109
Shop.nRenownShopUpdateKey = 255 --保存上次刷新时间
Shop.nRenownRefreshOffset = 4*3600

function Shop:ShouldRenownShopRefresh(pPlayer)
    local nLastRefresh = pPlayer.GetUserValue(self.nRenownShopSaveGrp, self.nRenownShopUpdateKey) or 0
    local nNow = GetTime()
    return Lib:IsDiffWeek(nLastRefresh, nNow, self.nRenownRefreshOffset)
end

function Shop:RenownShopCheckBeforeBuy(pPlayer, nId, nCount)
    local tbSetting = self.tbRenownShop[nId]
    if not tbSetting then
        Log("[x] Shop:RenownShopCheckBeforeBuy, invalid id", nId)
        return false, "非法参数"
    end

    nCount = math.floor(nCount or 0)
    if not nCount or nCount<=0 then
        return false, "请选择购买数量"
    end

    local nCost = tbSetting.nPrice*nCount
    if pPlayer.GetMoney("Renown")<nCost then
        return false, "名望不足"
    end

    local nAvaliableCount = pPlayer.GetUserValue(self.nRenownShopSaveGrp, nId)
    if nCount>nAvaliableCount then
        return false, "剩余库存不足"
    end
    return true
end