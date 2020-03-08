local tbUi = Ui:CreateClass("EquipmentEvolutionPanel");


tbUi.tbOnClick =
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end;

}

tbUi.tbUiTextSettingAll = {
    Type_Evolution = {
        Title = "打造";
        ShowTip = "*可打造6阶黄金装备，黄金装备的可镶嵌等级和可强化等级会随主角等级提升而提升";
        BtnName = "打造";
        szCostName = "打造消耗";
        bShowHelp = true;
    };
    Type_EvolutionPlatinum = {
        Title = "进化";
        ShowTip = "*可进化10阶白金装备，白金装备的可镶嵌等级和可强化等级会随主角等级提升而提升；若用于升阶的黄金装备高于10阶，后续升阶到相同阶白金装备时将不再需要和氏璧";
        BtnName = "进化";
        szCostName = "进化消耗";
        bShowHelp = false;
    };
    Type_Upgrade = {
        Title = "升阶";
        ShowTip = "低阶%s装备，可升阶为更高一阶的%s装备。若升阶的%s装备不为当前最高阶，消耗所需的和氏璧数量将会减少，阶数差越多消耗得越少";
        BtnName = "升阶";
        szCostName = "升阶消耗";
        bShowHelp = true;

    };
    Type_EvolutionHorse = {
        Title = "升阶";
        ShowTip = "坐骑与坐骑装备可升阶为更高阶的坐骑与坐骑装备";
        BtnName = "升阶";
        szCostName = "升阶消耗";
        bShowHelp = false;
    };

}

function tbUi:OnOpen(szType, nItemId)
    szType = szType or "Type_Evolution" --Type_Upgrade
    self.szType = szType
    self.tbUiTextSetting = self.tbUiTextSettingAll[szType]
    if not self.tbUiTextSetting then
        return 0;
    end

    self:InitEquipList(nItemId);
    if nItemId then
        self.nSelectEquipId = nItemId
    else
        self.nSelectEquipId = self:GetAutoSelelctItem()
    end
    if not self.nSelectEquipId then
        me.CenterMsg("您身上没有符合条件的装备")
        return 0;
    end
    if not self:GetEquipInfo(self.nSelectEquipId) then
        me.CenterMsg("您不可以打造该装备")
        return 0
    end
    self.pPanel:Label_SetText("Title", self.tbUiTextSetting.Title)
    self.Evolution.pPanel:Label_SetText("EvolutionTip", self.tbUiTextSetting.ShowTip)
    self.Evolution.pPanel:Button_SetText("BtnEvolution", self.tbUiTextSetting.BtnName)
    self.Evolution.pPanel:Label_SetText("titleCostName", self.tbUiTextSetting.szCostName)
    self.pPanel:SetActive("BtnInfo", self.tbUiTextSetting.bShowHelp)

    self:UpdateEquips();
    self:UpdateMain(self.nSelectEquipId);

    self.pPanel:SetActive("jinhuachenggong", false)
    self.pPanel:SetActive("shengjiechenggong", false)
    self.Evolution.pPanel:SetActive("ModelTexture", true);
    self.Evolution.pPanel:NpcView_Open("ShowRole");
    self.Evolution.pPanel:NpcView_ShowNpc("ShowRole", 1124)
    self.Evolution.pPanel:NpcView_SetScale("ShowRole", 0.9)
    self.Evolution.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
end

function tbUi:InitEquipList(nItemId)
    self.tbEquips           = {};

    if self.szType == "Type_Evolution" then
        --直接传的图谱的道具id
        --直接就取对应的10件6阶黄金， 列表是包里没有的黄金装备
        local tbAllTarItems = Item.GoldEquip:GetAllInitEvolutionTarItems()
        local tbAllEquipInRoles = me.FindItemInPlayer("equip")
        local tbAllEquipInRolesId = {}
        for i,pItem in ipairs(tbAllEquipInRoles) do
            tbAllEquipInRolesId[pItem.dwTemplateId] = 1;
        end

        for nTarItem, nSrcItem in pairs(tbAllTarItems) do
            if not tbAllEquipInRolesId[nTarItem] then
                local tbItemBase = KItem.GetItemBaseProp(nTarItem)
                local szItemName = Item:GetItemTemplateShowInfo(nTarItem, me.nFaction, me.nSex)
                local tbData = {
                    nPos = Item.EQUIPTYPE_POS[tbItemBase.nItemType];
                    nItemType = tbItemBase.nItemType;
                    szName = szItemName;
                    nSrcItem = nSrcItem;--配置key道具模板
                    nTarItem = nTarItem;--配置目标道具模板
                    nItemId = nTarItem; --左边列表对应nItemId 打造的itemid 是 目标的 templateid
                    bTemplate = true; --针对上面的nItemId
                    };

                local tbFindItems = me.FindItemInPlayer(nSrcItem)
                if next(tbFindItems) then
                    local nFindSrcItemId = tbFindItems[1].dwId
                    tbData.nSrcItemId = nFindSrcItemId --变更操作的道具id
                    local bUpgrade, szMsg = Item.GoldEquip:CanEvolution(me, nFindSrcItemId)
                    tbData.bUpgrade = bUpgrade
                end

                table.insert(self.tbEquips, tbData);
            end
        end
    elseif self.szType == "Type_EvolutionPlatinum" then
        --而且当前是10阶以上的黄金装备就显示
        local tbEquips = me.GetEquips()
        for i,nItemId in pairs(tbEquips) do
            local tbData = self:GetEquipListItemData(nItemId)
            if tbData then
                table.insert(self.tbEquips, tbData);
            end
        end
    else
        local nKind = self.szType == "Type_EvolutionHorse" and 1 or 0
        local tbAllEquips       = me.GetEquips(nKind);

        local bFindItemId = false;
        for nPos, nEquipId in pairs(tbAllEquips) do
            if nEquipId == nItemId then
                bFindItemId = true;
            end
            local tbData = self:GetEquipListItemData(nEquipId)
            if tbData then
                table.insert(self.tbEquips, tbData);
            end
        end
        if self.szType == "Type_EvolutionHorse" and nItemId and not bFindItemId then
            local tbData = self:GetEquipListItemData(nItemId)
            if tbData then
                table.insert(self.tbEquips, tbData);
            end
        end
    end

end

function tbUi:GetAutoSelelctItem()
    if self.tbEquips then
        local tbFirst = self.tbEquips[1]
        if tbFirst then
            return tbFirst.nItemId
        end
    end
end

function tbUi:GetEquipListItemData(nEquipId)
    local pItem = me.GetItemInBag(nEquipId);
    if not pItem then
        return
    end
    local nTarItem;
    local nSrcItem = pItem.dwTemplateId
    local bIsEvolution = true;
    if self.szType == "Type_Evolution" then
	--没有走这里
    elseif self.szType == "Type_EvolutionHorse" then
        if not pItem.nEquipPos or not Item.tbHorseItemPos[pItem.nEquipPos] then
            return
        end
        nTarItem = Item.GoldEquip:CanEvolutionTarItem(pItem.dwTemplateId)
    elseif self.szType == "Type_EvolutionPlatinum" then
        if pItem.nDetailType == Item.DetailType_Gold and pItem.nLevel >= Item.GoldEquip.UP_TO_PLATINUM_MIN_LEVEL then
            nSrcItem = Item.GoldEquip:GetInitPlattinumSrcItemByPos(pItem.nEquipPos)
            if not nSrcItem then
                return
            end
            nTarItem = Item.GoldEquip:GetCosumeItemToTarItem( nSrcItem )
        end
    else
        bIsEvolution = false
        nTarItem = Item.GoldEquip:CanUpgradeTarItem(pItem.dwTemplateId)
    end

    if not nTarItem then
        return
    end

    local nPos = pItem.nEquipPos
    local bUpgrade, szMsg = Item.GoldEquip:CanEvolution(me, pItem.dwId)
    if not bIsEvolution then
        bUpgrade, szMsg = Item.GoldEquip:CanUpgrade(me, pItem)
    end

    local szName = Item:GetDBItemShowInfo(pItem, me.nFaction);
    return {
            nPos        = nPos,
            nItemType   = pItem.nItemType,
            szName      = szName,
            nSrcItem    = nSrcItem, --消耗的配置key道具模板，图谱之类
            nEquipLevel = pItem.nLevel,
            nItemId     = pItem.dwId, --列表对应的道具id，如果 bTemplate则是模板
            nSrcItemId = pItem.dwId, --进化变更操作的道具id，如黄金武器进化到白金时用到的武器
            nTarItem    = nTarItem,
            bUpgrade    = bUpgrade,
           }
end

function tbUi:UpdateEquips()
    local fnClick = function (ButtonObj)
        self.nSelectEquipId = ButtonObj.nItemId;
        ButtonObj.pPanel:Toggle_SetChecked("Main", true);

        self:UpdateMain(ButtonObj.nItemId);

    end
    local fnClickItem = function (itemframe)
        fnClick(itemframe.parent)
    end

    local fnSetItem = function (itemObj, nIndex)
        local tbData = self.tbEquips[nIndex];
        itemObj.pPanel:Toggle_SetChecked("Main", self.nSelectEquipId == tbData.nItemId);

        itemObj.pPanel:SetActive("StoneIconGroup", false);
        itemObj.pPanel:SetActive("TxtStren", false);

        itemObj.pPanel:Label_SetText("TxtName", tbData.szName);
        -- itemObj.pPanel:Label_SetText("TxtLevel", tbData.nEquipLevel);
        if tbData.bTemplate then
            itemObj.itemframe:SetItemByTemplate(tbData.nItemId)
        else
            itemObj.itemframe:SetItem(tbData.nItemId);
        end

        itemObj.itemframe.parent = itemObj
        itemObj.itemframe.fnClick = fnClickItem;
        itemObj.nItemId             = tbData.nItemId;
        itemObj.pPanel.OnTouchEvent = fnClick;
        itemObj.pPanel:SetActive("UpgradeFlag", tbData.bUpgrade);
    end


    self.Evolution.ScrollViewStrengthenEquip:Update(#self.tbEquips, fnSetItem);
end

function tbUi:GetEquipInfo(nItemId)
    for i,v in ipairs(self.tbEquips) do
        if v.nItemId == nItemId then
            return v;
        end
    end
end

function tbUi:GetShowAttrib(tbAttribSrc)
    local tbRet = {}
    for _,tbDesc in ipairs(tbAttribSrc) do
        if not string.find(tbDesc[1], "上马激活") then
            local _,_, szMagicName,szVal = string.find(tbDesc[1], "(.*)[ ]+(\+%d+%%?)")
            if szMagicName then
                table.insert(tbRet, {szMagicName, szVal})
            end
        end
    end
    return tbRet
end

function tbUi:CheckAddOtherDesc(nSrcItem, nTarItem, tbSrc, tbDest)
    local nFullCountSrc = Item.tbRefinement:GetAttribFullCount(nSrcItem)
    local nFullCountTar = Item.tbRefinement:GetAttribFullCount(nTarItem)

    if nFullCountSrc >= nFullCountTar then
        return
    end
    table.insert(tbSrc,  {"可洗练条数", tostring(nFullCountSrc) })
    table.insert(tbDest,  {"可洗练条数", tostring(nFullCountTar) })
end

function tbUi:UpdateMain(nItemId)
    local curPanel = self.Evolution;
    if not nItemId then
        curPanel.EquipItem2:Clear();
        curPanel.pPanel:SetActive("ConsumptionStren", false)
        return;
    end

    local tbData = self:GetEquipInfo(nItemId);
    if not tbData.bTemplate then
        curPanel.EquipItem1.pPanel:SetActive("Main", false)
        curPanel.EquipItem2.pPanel:SetActive("Main", true)
        curPanel.EquipItem3.pPanel:SetActive("Main", true)
        curPanel.pPanel:SetActive("Sprite1", false)
        curPanel.pPanel:SetActive("Sprite2", true)
        curPanel.pPanel:SetActive("Sprite3", true)
        curPanel.pPanel:SetActive("SpriteRight1", true)

        curPanel.EquipItem2:SetItem(nItemId);
        curPanel.EquipItem2.fnClick = curPanel.EquipItem2.DefaultClick
        curPanel.EquipItem3:SetItemByTemplate(tbData.nTarItem);
        curPanel.EquipItem3.szItemOpt = "ViewUpgrade"
        curPanel.EquipItem3.fnClick = curPanel.EquipItem3.DefaultClick
    else
        curPanel.EquipItem1.pPanel:SetActive("Main", true)
        curPanel.EquipItem2.pPanel:SetActive("Main", false)
        curPanel.EquipItem3.pPanel:SetActive("Main", false)
        curPanel.pPanel:SetActive("Sprite1", true)
        curPanel.pPanel:SetActive("Sprite2", false)
        curPanel.pPanel:SetActive("Sprite3", false)
        curPanel.pPanel:SetActive("SpriteRight1", false)
        curPanel.EquipItem1:SetItemByTemplate(tbData.nTarItem);
        curPanel.EquipItem1.fnClick = curPanel.EquipItem1.DefaultClick
    end

    -- local tbAttribSrc = KItem.GetEquipBaseProp(tbData.nItemId).tbBaseAttrib;
    -- local tbAttribTar = KItem.GetEquipBaseProp(tbData.nTarItem).tbBaseAttrib;
    local tbEquip = Item:GetClass("equip");
    local tbAttribTar = tbEquip:GetBaseAttrib(tbData.nTarItem, nil, me)
    local tbDest = self:GetShowAttrib(tbAttribTar)
    local tbAttribSrc, tbSrc = {}, {};
    if not tbData.bTemplate then
        local pItem = me.GetItemInBag(tbData.nSrcItemId)
        if not pItem then
            return
        end
        tbAttribSrc = tbEquip:GetBaseAttrib(pItem.dwTemplateId, nil, me)
        tbSrc = self:GetShowAttrib(tbAttribSrc)
    end

    self:CheckAddOtherDesc(tbData.nSrcItem, tbData.nTarItem, tbSrc, tbDest)

    if not next(tbSrc) then
        curPanel.pPanel:SetActive("SpriteRight2", false)
    else
        curPanel.pPanel:SetActive("SpriteRight2", true)
    end

    local nMaxLine = 5;
    local i = 0
    for ii, tbInfo in ipairs(tbDest) do
        local szMagicName1, szVal1 = unpack(tbSrc[ii] or {})
        local szMagicName2, szVal2 = unpack(tbInfo)
        szVal1 = szVal1 or ""
        i = i + 1;
        curPanel.pPanel:Label_SetText("TxtEvolutionName" .. i, szMagicName2)

        curPanel.pPanel:Label_SetText("TxtEvolutionNext" .. i, szVal2)
        local _,_,Val1,szPercent1 = string.find(szVal1, "[^%d]*(%d+)(%%?)")
        local _,_,Val2,szPercent2 = string.find(szVal2, "[^%d]*(%d+)(%%?)")
        local nVal1 = tonumber(Val1)
        local nVal2 = tonumber(Val2)
        if Lib:IsEmptyStr(Val1) and not tbData.bTemplate then
             -- 如果没有前阶属性没有百分比属性而后阶属性新增百分比属性显示+0%
            if not Lib:IsEmptyStr(szPercent2) then
                szVal1 = "+0%"
            else
                -- 如果没有前阶属性没有数值属性而后阶属性新增数值属性显示+0
                if not Lib:IsEmptyStr(Val2) then
                    szVal1 = "+0"
                end
            end
        end
        curPanel.pPanel:Label_SetText("TxtEvolutionCur" .. i, szVal1)
        curPanel.pPanel:SetActive("SpriteUp" .. i, true)
        if nVal1 and nVal2 and nVal2 > nVal1 then
            curPanel.pPanel:Label_SetText("TxtEvolutionExtent" .. i, string.format("+%d%s", nVal2 - nVal1, szPercent1))
        elseif nVal2 and not nVal1  and not tbData.bTemplate then
            curPanel.pPanel:Label_SetText("TxtEvolutionExtent" .. i, szVal2 )
        else
            curPanel.pPanel:Label_SetText("TxtEvolutionExtent" .. i, "" )
            curPanel.pPanel:SetActive("SpriteUp" .. i, false)
        end

        curPanel.pPanel:SetActive("EvolutionWidget" .. i, true)
        if i >= nMaxLine then
            break;
        end
    end
    for i2 = i + 1, nMaxLine do
        curPanel.pPanel:SetActive("EvolutionWidget" .. i2, false)
    end

    --center
    --套装描述
    local tbSuitAttirs, tbActiveNeedNum = Item.GoldEquip:GetSuitAttrib(tbData.nTarItem, me)
    if tbSuitAttirs then
        curPanel.pPanel:SetActive("Suit", true)
        local szTxtAttris = ""
        for i,v in ipairs(tbSuitAttirs) do
            szTxtAttris = szTxtAttris .. v[1] .. "\n";
        end
        curPanel.pPanel:Label_SetText("SuitNum", szTxtAttris)
    else
        curPanel.pPanel:SetActive("Suit", false)
    end


    --bottom
    curPanel.pPanel:SetActive("ConsumptionStren", true)

    local tbConsumeSetting;
    local pSelItem
    if self.szType == "Type_EvolutionHorse" then
        pSelItem = me.GetItemInBag(nItemId)
        tbConsumeSetting = Item.GoldEquip:GetEvolutionConsumeSetting(me, pSelItem)
    elseif self.szType == "Type_Evolution" then
        tbConsumeSetting = Item.GoldEquip:GetEvolutionConsumeSetting(me, nil, tbData.nSrcItem)
    elseif self.szType == "Type_EvolutionPlatinum" then
        pSelItem = me.GetItemInBag(nItemId)
        tbConsumeSetting = Item.GoldEquip:GetEvolutionConsumeSetting(me, nil, tbData.nSrcItem)
    else
        pSelItem = me.GetItemInBag(nItemId)
        tbConsumeSetting = Item.GoldEquip:GetUpgradeConsumeSetting(pSelItem)
        local szShowTip = self.tbUiTextSetting.ShowTip
        if pSelItem.nDetailType == Item.DetailType_Gold then
            szShowTip = string.format(szShowTip, "黄金", "黄金", "黄金")
        elseif pSelItem.nDetailType == Item.DetailType_Platinum then
            szShowTip = string.format(szShowTip, "白金", "白金", "白金")
        end
        self.Evolution.pPanel:Label_SetText("EvolutionTip", szShowTip)

    end

    local tbHideID = {  }
    if tbData.bTemplate or (pSelItem and pSelItem.dwTemplateId ~= tbData.nSrcItem) then
        table.insert(tbConsumeSetting, 1, {tbData.nSrcItem, 1}) ; --nSrc 只是材料之一
    else
        tbHideID[nItemId] = 1
    end
    curPanel.pPanel:SetActive("Discount", false)
    curPanel.pPanel:SetActive("Charge", false)

    for i=1,3 do
        local tbInfo = tbConsumeSetting[i]
        local tbGrid = curPanel["CostItem" .. i];
        if tbInfo then
            local nCosumeItem, nConsumeCount,nCousumeCountOrg = unpack(tbInfo)
            if nConsumeCount == 0 then
                tbGrid.pPanel:SetActive("Main", false)
                curPanel.pPanel:SetActive("sussessPerBG" .. i, false)
                curPanel.pPanel:SetActive("TxtConsume" .. i, false)
                curPanel.pPanel:SetActive("Charge", true)
                curPanel.Charge.pPanel.OnTouchEvent = function ( ... )
                    local pSelItem = me.GetItemInBag(nItemId)
                    if pSelItem then
                        Ui:OpenWindow("AttributeDescription", string.format("岁星之精，化而为玉\n其中充能大量和氏璧可作为本白金装备升阶所需的材料，升阶至[ffff00]%d[-]阶过程中不再消耗背包中的和氏璧。\n充能亦可为本装备提供属性加成。", pSelItem.GetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL)))
                    end
                end
            else
                tbGrid.pPanel:SetActive("Main", true)
                -- curPanel.pPanel:SetActive("ItemName" .. i, false)
                curPanel.pPanel:SetActive("TxtConsume" .. i, true)
                curPanel.pPanel:SetActive("sussessPerBG" .. i, true)

                tbGrid:SetItemByTemplate(nCosumeItem);
                tbGrid.fnClick = tbGrid.DefaultClick
                local tbItemBase = KItem.GetItemBaseProp(nCosumeItem)
                -- curPanel.pPanel:Label_SetText("ItemName" .. i, tbItemBase.szName)
                local nExistCount = me.GetItemCountInBags(nCosumeItem, tbHideID)
                if not nCousumeCountOrg then
                    curPanel.pPanel:Label_SetText("TxtConsume" .. i, string.format("%d/%d", nExistCount, nConsumeCount));
                else
                    curPanel.pPanel:SetActive("Discount", true)
                    curPanel.pPanel:Label_SetText("Discount", nConsumeCount)
                    curPanel.pPanel:Label_SetText("TxtConsume" .. i, string.format("%d/%d", nExistCount, nCousumeCountOrg));
                end
                curPanel.pPanel:Label_SetColorByName("TxtConsume" .. i,  nConsumeCount > nExistCount and "Red" or "White");
            end
        else
            tbGrid.pPanel:SetActive("Main", false)
            curPanel.pPanel:SetActive("sussessPerBG" .. i, false)
            -- curPanel.pPanel:SetActive("ItemName" .. i, false)
            curPanel.pPanel:SetActive("TxtConsume" .. i, false)
        end

    end

    if self.szType == "Type_Upgrade" then
        local tbSetting = Item.GoldEquip:GetUpgradeSetting(tbData.nSrcItem)
        local tbSrcItems = me.FindItemInPlayer(tbSetting.CosumeItem1) --消耗掉的T7 稀有
        local pOriSrcItem = tbSrcItems and tbSrcItems[1]
        if pOriSrcItem then
            curPanel["CostItem1"]:SetItem(pOriSrcItem.dwId)
        end
    end


    curPanel.BtnEvolution.pPanel.OnTouchEvent = function ( ... )
        if self.szType == "Type_EvolutionHorse" or self.szType == "Type_Evolution" or self.szType == "Type_EvolutionPlatinum" then
            self:DoEvolution()
        else
            self:DoUpgrade();
        end
    end
end

function tbUi:DoEvolution( )
    if not self.nSelectEquipId then
        me.CenterMsg("请选择装备");
        return;
    end

    local pItem;
    if self.szType == "Type_EvolutionHorse" then
        pItem = KItem.GetItemObj(self.nSelectEquipId);
    else
        local tbData = self:GetEquipInfo(self.nSelectEquipId)
        if not tbData or not tbData.nSrcItemId then
            me.CenterMsg("材料不足")
            return
        end
        pItem = KItem.GetItemObj(tbData.nSrcItemId);
    end

    if not pItem then
        me.CenterMsg("材料不足")
        return;
    end
    local bRet, szMsg = Item.GoldEquip:CanEvolution(me, pItem.dwId)
    if not bRet then
        if szMsg then
            me.CenterMsg(szMsg)
        end
        return
    end

    RemoteServer.DoEquipEvolution(pItem.dwId);

    self.Evolution.pPanel:Button_SetEnabled("BtnEvolution", false)
    Timer:Register(math.floor(Env.GAME_FPS * 1.6) , function ()
        self.Evolution.pPanel:Button_SetEnabled("BtnEvolution", true)
    end)
end

function tbUi:DoUpgrade()
    if not self.nSelectEquipId then
        me.CenterMsg("请选择装备");
        return;
    end

    local pEquip = KItem.GetItemObj(self.nSelectEquipId);
    if not pEquip then
        return;
    end

    local bRet, szMsg = Item.GoldEquip:CanUpgrade(me, pEquip)
    if not bRet then
        if szMsg then
            me.CenterMsg(szMsg)
        end
        return
    end
    RemoteServer.RequestEquipUpgrade(pEquip.dwId)
end

function tbUi:OnResponse(bRet)
    self.pPanel:SetActive("jinhuachenggong", false)
    self.pPanel:SetActive("shengjiechenggong", false)
    self.Evolution.EquipItem2.fnClick = nil;
    local fnQHTime =  self.Evolution.pPanel:NpcView_PlayAnimation("ShowRole", "qh", 0.1, 1)
    if fnQHTime > 0 then
        if self.nTimerQH then
            Timer:Close(self.nTimerQH)
        end
        local nDelayTime = math.floor(Env.GAME_FPS * fnQHTime * 2 - 5)
        self.nTimerQH = Timer:Register(nDelayTime  , function ()
            self.Evolution.pPanel:NpcView_PlayAnimation("ShowRole", "st", 0.2, 1)
            self.nTimerQH = nil;

            if bRet then
                if self.szType == "Type_Evolution" then
                    self.pPanel:SetActive("jinhuachenggong", true)
                else
                    self.pPanel:SetActive("shengjiechenggong", true)
                end

            end
        end)

        if bRet then
            self.nTimerRefreshUi = Timer:Register(nDelayTime + 5, function ( )
                self.nTimerRefreshUi = nil;
                self:InitEquipList();
                self:UpdateEquips()
                self:UpdateMain();
            end)
        end
    end
end

function tbUi:OnClose()
    self.nSelectEquipId = nil;
    self.tbEquips = nil;
    self.Evolution.pPanel:SetActive("ModelTexture", false);
    self.Evolution.pPanel:NpcView_Close("ShowRole");
    if self.nTimerRefreshUi then
        Timer:Close(self.nTimerRefreshUi)
        self.nTimerRefreshUi = nil;
    end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_EQUIP_EVOLUTION,           self.OnResponse},

    };

    return tbRegEvent;
end
