
Item.GoldGrade = {
    [1] = 30,
    [2] = 100,
    [3] = 300,
    [4] = 1000,
    [5] = 3000,
    [6] = 10000,
    [7] = 10000,  --15000以上
};

Item.CoinGrade = {
    [1] = 3000,
    [2] = 10000,
    [3] = 30000,
    [4] = 100000,
    [5] = 300000,
    [6] = 1000000,
    [7] = 1000000,  --15000以上
};
Item.coinGrade = Item.CoinGrade;

Item.ExpGrade = {
    [1] = 300,
    [2] = 1000,
    [3] = 3000,
    [4] = 10000,
    [5] = 30000,
    [6] = 100000,
    [7] = 100000,  --15000以上
};

Item.JadeGrade = {
    [1] = 300,
    [2] = 1000,
    [3] = 3000,
    [4] = 10000,
    [5] = 30000,
    [6] = 100000,
    [7] = 100000,  --15000以上
};

Item.TongBaoGrade = {
    [1] = 300,
    [2] = 1000,
    [3] = 3000,
    [4] = 10000,
    [5] = 30000,
    [6] = 100000,
    [7] = 100000,  --15000以上
};

Item.PartnerGrade = {
    [1] = 10000,
    [2] = 50000,
    [3] = 300000,
    [4] = 900000,
    [5] = 2000000,
    [6] = 6000000,
    [7] = 16000000,  --15000以上
};

Item.PStone0Grade = {
    [1] = 6,
    [2] = 20,
    [3] = 60,
    [4] = 200,
    [5] = 600,
    [6] = 2000,
    [7] = 2000,  --15000以上
};

Item.PStone1Grade = {
    [1] = 6,
    [2] = 20,
    [3] = 60,
    [4] = 200,
    [5] = 600,
    [6] = 2000,
    [7] = 2000,  --15000以上
};

Item.PStone2Grade = {
    [1] = 6,
    [2] = 20,
    [3] = 60,
    [4] = 200,
    [5] = 600,
    [6] = 2000,
    [7] = 2000,  --15000以上
};

Item.PStone3Grade = {
    [1] = 6,
    [2] = 20,
    [3] = 60,
    [4] = 200,
    [5] = 600,
    [6] = 2000,
    [7] = 2000,  --15000以上
};

Item.HonorGrade = {
    [1] = 300,
    [2] = 1000,
    [3] = 3000,
    [4] = 10000,
    [5] = 30000,
    [6] = 100000,
    [7] = 100000,  --15000以上
};

Item.BiographyGrade = {
    [1] = 300,
    [2] = 1000,
    [3] = 3000,
    [4] = 10000,
    [5] = 30000,
    [6] = 100000,
    [7] = 100000,  --15000以上
};

function Item:GetDigitalItemQuality(szType, nValue)
	local nQuality = 1;
    local tbGrade = Item[szType.."Grade"];
    if not tbGrade then
        return nQuality;
    end

    for i, v in ipairs(tbGrade) do
        if nValue < v then
            nQuality = i;
            break;
        end

        if i == 7 and not grade then
            nQuality = 7;
        end
    end

    return nQuality;
end

function Item:LoadSkillItemSetting()
	self.tbSkillItem = {};

	local tbSkillItem =  LoadTabFile("Setting/Item/Other/SkillItem.tab",
	    "dddssss", nil,
	    {"SkillId", "SkillLevel", "Quality", "Icon", "IconAtlas", "Desc", "Name"});

	for k,v in pairs(tbSkillItem) do
		self.tbSkillItem[v.SkillId] = self.tbSkillItem[v.SkillId] or {};
		self.tbSkillItem[v.SkillId][v.SkillLevel] = {v.Name, v.Icon, v.IconAtlas, v.Desc, v.Quality};
	end
end
Item:LoadSkillItemSetting();

function Item:GetSkillItemSetting(nSkillId, nSkillLevel)
	if self.tbSkillItem[nSkillId] and self.tbSkillItem[nSkillId][nSkillLevel] then
		return self.tbSkillItem[nSkillId][nSkillLevel];
	end
end

function Item:GetItemTargetType(nTemplateId)
    local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
    if tbBaseInfo.szClass == "Unidentify" then
        nTemplateId = KItem.GetItemExtParam(nTemplateId, 1)
        tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
    end
    return tbBaseInfo.nItemType
end

function Item:GetItemPosShowInfo(nTemplateId)
    local nType = self:GetItemTargetType(nTemplateId)
    local nPos = Item.EQUIPTYPE_POS[nType]
    return Item.EQUIPPOS_NAME[nPos], nPos
end

Item.tbItemFunc = {
    ["NeedChooseItem"] = function (tbPos, nItemTemplateId, nItemId, tbInfo)
        -- Ui:OpenWindowAtPos("ItemSelectPanel", tbPos.x, tbPos.y, nItemTemplateId, nItemId)
        local bForceTips = tbInfo and tbInfo.bForceTips
        Item:GetClass("NeedChooseItem"):TryOpenUi(tbPos.x, tbPos.y, nItemTemplateId, nItemId, nil, bForceTips)
    end,

    ["SkillBook"] = function(tbPos, nItemTemplateId, nItemId, tbInfo)
        local pCurEquip;
        if nItemId then
            local pItem = KItem.GetItemObj(nItemId)
            if  pItem and tbInfo.pAsyncRole and  not me.GetItemInBag(nItemId)  then
                --如果目标是同门派的要取同样类型的秘籍
                if tbInfo.pAsyncRole.GetFaction() == me.nFaction then
                    local tbBook = Item:GetClass("SkillBook");
                    local nLowestTypeId = tbBook:GetLowestBookId(pItem.dwTemplateId)
                    for nIndex, nNeedLevel in ipairs(tbBook.tbSkillBookHoleLevel) do
                        local pEquip = me.GetEquipByPos(nIndex + Item.EQUIPPOS_SKILL_BOOK - 1);
                        if pEquip then
                            local nMyLowestTypeId = tbBook:GetLowestBookId(pEquip.dwTemplateId)
                            if nMyLowestTypeId == nLowestTypeId then
                                pCurEquip = pEquip;
                                break;
                            end
                        end
                    end
                else
                    if tbInfo.nPosIndex then
                        pCurEquip = me.GetEquipByPos(tbInfo.nPosIndex);
                    end
                end
            end
        end
        if not pCurEquip then
            local szItemOpt;
            if nItemId and not  me.GetItemInBag(nItemId) then
                szItemOpt = "ViewEquip"
            end
            Ui:OpenWindowAtPos("SkillCheatsPanel", tbPos.x, tbPos.y, nItemId, nItemTemplateId, tbInfo.tbRandomAtrrib or {}, szItemOpt)
        else
            Ui:OpenWindowAtPos("SkillCheatsPanel", 133, 15, nItemId, nItemTemplateId, tbInfo.tbRandomAtrrib or {}, "ViewEquip")
            Ui:OpenWindowAtPos("SkillCheatsComparePanel", -269, 15, pCurEquip.dwId, pCurEquip.dwTemplateId, tbInfo.tbRandomAtrrib or {},"ViewEquip")
        end
    end;
    ["Stone"] = function(tbPos, nItemTemplateId, nItemId)
        if StoneMgr:IsStone(nItemTemplateId) then
            Ui:OpenWindowAtPos("StoneTipsPanel", 0, 0, nItemId, nItemTemplateId);
        else
            Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "Item", nItemId, nItemTemplateId);
        end
    end;
    ["waiyi"] = function(tbPos, nItemTemplateId, nItemId, tbInfo)
        Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "Item", nItemId, nItemTemplateId, tbInfo.nFaction, tbInfo.nSex);
    end;
    ["CollectionItem"] = function (tbPos, nItemTemplateId, nItemId, tbInfo)
        Ui:OpenWindowAtPos("CardCollection", tbPos.x, tbPos.y, nItemTemplateId, nItemId, tbInfo.tbRandomAtrrib or {})
    end;
    ["JuanZhou"] = function (tbPos, nItemTemplateId, nItemId, tbInfo)
        Ui:OpenWindowAtPos("JuanZhouPanel", tbPos.x, tbPos.y, nItemTemplateId, nItemId)
    end;
    ["PlayerPortraitItem_NoSex"] = function (tbPos, nItemTemplateId, nItemId)
        Ui:OpenWindowAtPos("PortraitItemPreviewPanel", 0, 0, nItemTemplateId, nItemId)
    end;
    ["CollectClueDebris"] = function (tbPos, nItemTemplateId)
        Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "CollectClue", nItemTemplateId);
    end;
    ["CollectClueCombie"] = function (tbPos, nItemTemplateId)
        Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "CollectClue", nItemTemplateId);
    end;
    ["JueYao"] = function(tbPos, nItemTemplateId, nItemId, tbInfo)
        ZhenFa:OpenJueYaoTips(tbPos, nItemTemplateId, nItemId, tbInfo)
    end;
    ["ZhenFaBox"] = function (tbPos, nItemTemplateId, nItemId, tbInfo)
        if nItemId then
            Ui:OpenWindowAtPos("ZhenFaBoxTips", tbPos.x, tbPos.y, nItemId, nItemTemplateId);
        else
            Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "Item", nItemId, nItemTemplateId);
        end
    end;
    ["InscriptionItem"] = function (tbPos, nItemTemplateId, nItemId, tbInfo)
        local nFaction = tbInfo.nFaction or me.nFaction
        local nSex = Player:Faction2Sex(nFaction, tbInfo.nSex or me.nSex)
        Ui:OpenWindowAtPos("InscriptionTips", tbPos.x, tbPos.y, nItemId, nItemTemplateId, nFaction, tbInfo.szItemOpt, tbInfo.tbRandomAtrrib, nSex)
    end;
    ["JuexueBook"] = function (tbPos, nItemTID, nItemID, tbInfo)
        Item:GetClass("JuexueBook"):OpenTips(tbPos, nItemTID, nItemID, tbInfo)
    end;
    ["MibenBook"] = function (tbPos, nItemTID, nItemID, tbInfo)
        Ui:OpenWindow("MibenBookTips", nItemTID or false, nItemID or false, tbInfo.tbRandomAtrrib or false, tbInfo.szItemOpt or false, tbInfo.nEquipPos)
    end;
    ["DuanpianBook"] = function (tbPos, nItemTID, nItemID, tbInfo)
        Ui:OpenWindowAtPos("DuanpianBookTips", tbPos.x, tbPos.y, nItemTID or false, nItemID or false, tbInfo.tbRandomAtrrib or false, tbInfo.szItemOpt or false, tbInfo.nEquipPos)
    end;
    ["RefineStone"] = function (tbPos, nItemTID, nItemID, tbInfo)
        local nEquipType = KItem.GetItemExtParam(nItemTID, Item.tbRefinementStone.REFINE_STONE_PARAM_TYPE)
        local nEquipPos = Item.EQUIPTYPE_POS[nEquipType]
        local nFaction = tbInfo.nFaction or me.nFaction
        local szItemOpt = "RefineStone"
        if nItemID then
            local pItem = KItem.GetItemObj(nItemID)
            local tbSavedRandomAttrib = Item.tbRefinement:GetSaveRandomAttrib(pItem)

            local pCurEquip = me.GetEquipByPos(nEquipPos);
            if pCurEquip then
                Ui:OpenWindowAtPos("EquipTips", 133, 234, tbInfo.nItemId, tbInfo.nTemplate, nFaction, szItemOpt, tbSavedRandomAttrib, tbInfo.pAsyncRole or 1, nSex)
                Ui:OpenWindowAtPos("CompareTips", -315, 234, pCurEquip.dwId, nil, nil)
            else
                -- 独立显示位置
                Ui:OpenWindowAtPos("EquipTips", -84, 234, tbInfo.nItemId, nil, nFaction, szItemOpt, tbSavedRandomAttrib, tbInfo.pAsyncRole or 1, nSex)
            end
        else
            -- 独立显示位置
            Ui:OpenWindowAtPos("EquipTips", -84, 234, false, tbInfo.nTemplate, nFaction, szItemOpt, tbInfo.tbRandomAtrrib, nil, nSex)
        end
    end;
    ["PartnerCardCompose"] = function (tbPos, nItemTemplateId, nItemId, tbInfo)
        local nCardId =  KItem.GetItemExtParam(nItemTemplateId, 1);
        Ui:OpenWindow("PartnerCardComposePanel", nCardId, nItemTemplateId)
    end;
    ["DrinkHouseDinnerInvitation"] = function (tbPos, nItemTemplateId, nItemId, tbInfo)
        Ui:OpenWindow("CeremonyInvitationPanel")
    end;
}


function Item:ShowItemDetail(tbInfo, tbPos)
    local tbShowPos = tbPos or {x = -1, y = -1}
    local nFaction = tbInfo.nFaction or me.nFaction;
    local nSex = Player:Faction2Sex(nFaction, tbInfo.nSex or me.nSex);
    if tbInfo.nItemId and tbInfo.nItemId ~= 0 then        -- 优先道具ID
        local pItem = KItem.GetItemObj(tbInfo.nItemId)
        if Item.tbItemFunc[pItem.szClass] then
            Item.tbItemFunc[pItem.szClass](tbShowPos, pItem.dwTemplateId, tbInfo.nItemId, tbInfo)
        elseif pItem and pItem.IsEquip() == 1 then
            -- 装备对比
            local pCurEquip = me.GetEquipByPos(pItem.nEquipPos);
            if pCurEquip and pCurEquip.dwId ~= tbInfo.nItemId then
                -- 装备对比位置
                Ui:OpenWindowAtPos("EquipTips", 133, 234, tbInfo.nItemId, nil, nFaction, tbInfo.szItemOpt, nil, tbInfo.pAsyncRole or 1, nSex)
                local szItemOpt = nil;
                if not me.GetItemInBag(tbInfo.nItemId) then
                    szItemOpt = "ViewOtherEquip"
                end
                Ui:OpenWindowAtPos("CompareTips", -315, 234, pCurEquip.dwId, nil, nil, szItemOpt)
            else
                -- 独立显示位置
                if not tbPos then
                    tbShowPos = {x = -84, y = 234}
                end

                Ui:OpenWindowAtPos("EquipTips", tbShowPos.x, tbShowPos.y, tbInfo.nItemId, nil, nFaction, tbInfo.szItemOpt, nil, tbInfo.pAsyncRole or 1, nSex)
            end
        else
            Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Item", tbInfo.nItemId, tbInfo.nTemplate);
        end
    elseif tbInfo.nTemplate and tbInfo.nTemplate ~= 0 then
        local tbBaseInfo = KItem.GetItemBaseProp(tbInfo.nTemplate);
        local nEquipPos = KItem.GetEquipPos(tbInfo.nTemplate);
        if Item.tbItemFunc[tbBaseInfo.szClass] then
            Item.tbItemFunc[tbBaseInfo.szClass](tbShowPos, tbInfo.nTemplate, nil, tbInfo)
        elseif nEquipPos then
            local pCurEquip = me.GetEquipByPos(nEquipPos);
            if pCurEquip and not tbInfo.tbRandomAtrrib then
                -- 装备对比位置
                local tbMySavedRandomAttrib = nil; --黄金装备获得时随机属性是身上对应装备的随机属性
                local pOrgEquip;
                if Item.GoldEquip.DetailTypeGoldUp[tbBaseInfo.nDetailType] then
                    tbMySavedRandomAttrib = Item.tbRefinement:GetSaveRandomAttrib(pCurEquip)
                    pOrgEquip = pCurEquip
                end
                Ui:OpenWindowAtPos("EquipTips", 133, 234, false, tbInfo.nTemplate, nFaction, tbInfo.szItemOpt, tbMySavedRandomAttrib, nil, nSex, pOrgEquip)
                Ui:OpenWindowAtPos("CompareTips", -315, 234, pCurEquip.dwId)
            else
                -- 独立显示位置
                if not tbPos then
                    tbShowPos = {x = -84, y = 234}
                end
                Ui:OpenWindowAtPos("EquipTips", tbShowPos.x, tbShowPos.y, false, tbInfo.nTemplate, nFaction, tbInfo.szItemOpt, tbInfo.tbRandomAtrrib, nil, nSex)
            end
        else
            Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Item", nil, tbInfo.nTemplate, nFaction, nSex)
        end
    elseif tbInfo.szDigitalType then
        Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Digit", tbInfo.szDigitalType, tbInfo.nCount);
    elseif tbInfo.nSkillId then
        Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Skill", tbInfo.nSkillId, tbInfo.nSkillLevel);
    elseif tbInfo.nPartnerId then
        Ui:OpenWindowAtPos("PartnerDetail", tbShowPos.x, tbShowPos.y, nil, nil, nil, tbInfo.nPartnerId);
    elseif tbInfo.nSeqId then
        Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "ComposeValue", tbInfo.nSeqId);
    elseif tbInfo.nTitleId then
        Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "AddTimeTitle", tbInfo.nTitleId);
    end
end

function Item:ShowStoneCompareTips(nItemTemplateId, nItemId)
    if StoneMgr:IsStone(nItemTemplateId) then
        local tbPosType = StoneMgr:GetCanInsetPos(nItemTemplateId)
        local nPos = Item.EQUIPTYPE_POS[tbPosType[1]];
        local pCurEquip = me.GetEquipByPos(nPos);
        if pCurEquip then
        	Ui:OpenWindowAtPos("CompareTips", -315, 234, pCurEquip.dwId, nil, nil, szItemOpt);
        	Ui:OpenWindowAtPos("StoneTipsPanel", 170, 0, nItemId, nItemTemplateId);
        else
        	Ui:OpenWindowAtPos("StoneTipsPanel", 0, 0, nItemId, nItemTemplateId);
        end
    else
        Ui:OpenWindowAtPos("ItemTips", 0, 0, "Item", nItemId, nItemTemplateId);
    end
end

function Item:GetDisplayName(pItem, szName)
    if pItem and Item:IsForbidStall(pItem) then
        return string.format("%s（封）", szName)
    end
    return szName
end

function Item:ShowEquipMeterialCompareTips(nItemTemplateId, nItemId)
    local nTarItemTemplate = Compose.EntityCompose:GetEquipComposeInfo(nItemTemplateId)
    if nTarItemTemplate then
        local nEquipPos = KItem.GetEquipPos(nTarItemTemplate);
        if nEquipPos then
            Ui:OpenWindowAtPos("CompareTips", -315, 234, nil, nTarItemTemplate);
            Ui:OpenWindowAtPos("ItemTips", 170, -20, "Item", nItemId, nItemTemplateId);
        else
            Ui:OpenWindowAtPos("ItemCompareTips", -200, 0, "Item", nil, nTarItemTemplate);
            Ui:OpenWindowAtPos("ItemTips", 170, 0, "Item", nItemId, nItemTemplateId);
        end
    else
       Ui:OpenWindowAtPos("ItemTips", 0, 0, "Item", nItemId, nItemTemplateId);
    end
end

function Item:ShowItemCompareTips(tbGrid)
    local nTemplate, nItemId = tbGrid.nTemplate, tbGrid.nItemId
    local tbBaseInfo = KItem.GetItemBaseProp(nTemplate);
    if tbBaseInfo.szClass == "Stone" then
        Item:ShowStoneCompareTips(nTemplate, nItemId)
    elseif tbBaseInfo.szClass == "EquipMeterial" then
        Item:ShowEquipMeterialCompareTips(nTemplate, nItemId)
    else
        Item:ShowItemDetail(tbGrid);
    end
end
