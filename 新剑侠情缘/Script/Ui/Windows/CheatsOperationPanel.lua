
local tbUi = Ui:CreateClass("CheatsOperationPanel");
tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnCancel()
    Ui:CloseWindow("CheatsOperationPanel");
end

function tbUi.tbOnClick:BtnLevelUp()
    if not self.nItemID then
        return;
    end

    local pItem = me.GetItemInBag(self.nItemID);
    if not pItem then
        return;
    end

    if self.szOperation == "LevelUp" then
        RemoteServer.DoSkillBook("DoBookLevelUp", self.nItemID);
    elseif self.szOperation == "Upgrade" then
        RemoteServer.DoSkillBook("BookUpgrade", self.nItemID);
    elseif self.szOperation == "TuPo" then
        RemoteServer.DoSkillBook("BookTuPo", self.nItemID);
    elseif self.szOperation == "Evolve" then
        JueXue:TryActivateArea(pItem)
    elseif self.szOperation == "XiuLian" then
        JueXue:TryXiuLian(pItem)
    end
end

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("CheatsOperationPanel");
end

function tbUi:OnOpen(nItemID, szOperation)
    self.nItemID = nItemID;
    self.szOperation = szOperation or "";
    self:Update();
end

function tbUi:ClearAllUI()
    self.pPanel:SetActive("Cheatsitem1", false);
    self.pPanel:SetActive("CheatsAdvanced", false);
    self.pPanel:SetActive("ConditionGroup", false);
    self.pPanel:SetActive("TopCheatsDesc", false);
    self.pPanel:SetActive("BottomCheatsDesc", false);
end

function tbUi:Update()
    self:ClearAllUI();
    local funCallBack = self["OnOp"..self.szOperation];
    if not funCallBack then
        return;
    end

    funCallBack(self);
end

function tbUi:OnOpLevelUp()
    local pEquip = me.GetItemInBag(self.nItemID);
    if not pEquip then
        return;
    end

    self.pPanel:Label_SetText("Title", "秘籍升级");
    self.pPanel:SetActive("Cheatsitem1", true);
    self.pPanel:SetActive("TopCheatsDesc", true);
    self.pPanel:SetActive("BottomCheatsDesc", true);
    self.Cheatsitem1:SetItem(self.nItemID);
    self.Cheatsitem1.fnClick = self.Cheatsitem1.DefaultClick;

    local tbBook = Item:GetClass("SkillBook");
    local nBookLevel = pEquip.GetIntValue(tbBook.nSaveBookLevel);
    local nBookSkillLevel = pEquip.GetIntValue(tbBook.nSaveSkillLevel);
    local tbBookInfo = tbBook:GetBookInfo(pEquip.dwTemplateId);
    local nMaxExp = me.GetMoney(tbBook.szSkillBookExpName) + tbBook:UpdateGrowXiuLianExp(me);
    local tbBookLevelInfo = tbBook:GetBookLevelInfo(nBookLevel);
    local szMsg = string.format("秘籍等级：%s/%s", nBookLevel, tbBookInfo.MaxBookLevel);
    szMsg = szMsg .. string.format("\n\n秘籍技能等级：%s/%s", nBookSkillLevel, tbBookInfo.MaxSkillLevel);
    szMsg = szMsg .. string.format("\n\n升级所需修为：%s/%s", tbBookLevelInfo and tbBookLevelInfo.CostExp or 0, nMaxExp);
    szMsg = szMsg .. string.format("\n\n当前修为：%s", nMaxExp);
    self.pPanel:Label_SetText("TopCheatsDesc", szMsg);

    self.pPanel:ChangePosition("BottomCheatsDesc", -188, -117);
    local szBottom = "";
    if tbBookInfo.Type == tbBook.nBookTypeNormal then
        szBottom = "每升1级，有机会提升附带的属性\n每升满5级，有机会提升附带技能等级";
    else
        szBottom = "每升1级，有机会提升附带的属性\n每升满10级，100%提升附带技能等级";
    end

    if tbBookInfo.Type == tbBook.nBookTypeNormal or tbBookInfo.Type == tbBook.nBookTypeMiddle then
        local tbBookUpgrade = tbBook:GetBookUpgradeInfo(tbBookInfo.UpgradeID);
        local szLevelType = "中级";
        if tbBookInfo.Type == tbBook.nBookTypeMiddle then
            szLevelType = "高级";
        end   
        self.pPanel:ChangePosition("BottomCheatsDesc", -188, -80);
        szBottom = szBottom..string.format("\n当附带技能满级，且人物等级达到%s时，可进阶为%s秘籍", tbBookUpgrade.PlayerLevel, szLevelType);
    end    

    self.pPanel:Label_SetText("BottomCheatsDesc", szBottom);
    self.pPanel:Label_SetText("LbLevelUp", "升级");
end

function tbUi:OnOpUpgrade()
    local pEquip = me.GetItemInBag(self.nItemID);
    if not pEquip then
        return;
    end

    for nI = 1, 2 do
        self["ConditionItem"..nI]:Clear();
    end


    for nI = 2, 3 do
        self["Cheatsitem"..nI]:Clear();
    end

    self.pPanel:Label_SetText("Title", "秘籍进阶");
    self.pPanel:SetActive("CheatsAdvanced", true);
    self.pPanel:SetActive("TopCheatsDesc", true);
    self.pPanel:SetActive("ConditionGroup", true);
    self.pPanel:Label_SetText("LbLevelUp", "进阶");
    local tbBook = Item:GetClass("SkillBook");
    local tbBookInfo = tbBook:GetBookInfo(pEquip.dwTemplateId);
    if tbBookInfo.UpgradeItem <= 0 then
        return;
    end

    local tbBookUpgrade = tbBook:GetBookUpgradeInfo(tbBookInfo.UpgradeID);
    self.Cheatsitem2:SetItem(self.nItemID);
    self.Cheatsitem2.fnClick = self.Cheatsitem2.DefaultClick;
    self.Cheatsitem3:SetItemByTemplate(tbBookInfo.UpgradeItem , 0, me.nFaction);
    self.Cheatsitem3.fnClick = self.Cheatsitem3.DefaultClick;

    local tbUpgrade = tbBook:GetBookInfo(tbBookInfo.UpgradeItem);

    local szPlayerColor = "";
    if me.nLevel < tbBookUpgrade.PlayerLevel then
        szPlayerColor = "[ff0000]";
    else
        szPlayerColor = "[64db00]";
    end

    local szLevelName = "中级";
    if tbUpgrade.Type == tbBook.nBookTypeHigh then
        szLevelName = "高级";
    end    

    local szMsg = string.format("本秘籍进阶条件：角色达到%s%s[-]级", szPlayerColor, tbBookUpgrade.PlayerLevel);
    szMsg = szMsg .. string.format("\n\n进阶后：\n    秘籍升为[FFFE0D]%s[-]\n    等级上限升至[FFFE0D]%s级[-]\n    秘籍技能升为[FFFE0D]%s[-]\n    秘籍技能等级上限升至[FFFE0D]%s级[-]",
        szLevelName, tbUpgrade.MaxBookLevel, szLevelName, tbUpgrade.MaxSkillLevel);
    self.pPanel:Label_SetText("TopCheatsDesc", szMsg);

    self.pPanel:Label_SetText("BreachTitle", "进阶所需");

    local tbItemHideID = {};
    tbItemHideID[self.nItemID] = 1;
    for nIndex, tbCost in pairs(tbBookUpgrade.tbAllCostIteam) do
        local nCount = me.GetItemCountInAllPos(tbCost.nItemTID, tbItemHideID);
        local szShow = "";
        if nCount < tbCost.nItemCount then
            szShow = "[ff0000]";
        else
            szShow = "[64db00]";
        end

        self.pPanel:Label_SetText("ItemNumber"..nIndex, string.format("%s%s[-]/%s", szShow, nCount, tbCost.nItemCount));
        self["ConditionItem" ..nIndex]:SetItemByTemplate(tbCost.nItemTID, nCount, me.nFaction);
        self["ConditionItem" ..nIndex].fnClick = self["ConditionItem" ..nIndex].DefaultClick;

    end
end

function tbUi:OnOpTuPo()
    local pEquip = me.GetItemInBag(self.nItemID);
    if not pEquip then
        return;
    end

    self.pPanel:Label_SetText("Title", "秘籍突破");
    self.pPanel:SetActive("Cheatsitem1", true);
    self.pPanel:SetActive("TopCheatsDesc", true);
    self.pPanel:SetActive("ConditionGroup", true);
    self.Cheatsitem1:SetItem(self.nItemID);
    self.Cheatsitem1.fnClick = self.Cheatsitem1.DefaultClick;

    local tbBook = Item:GetClass("SkillBook");
    local nBookLevel = pEquip.GetIntValue(tbBook.nSaveBookLevel);
    local nBookSkillLevel = pEquip.GetIntValue(tbBook.nSaveSkillLevel);
    local tbBookInfo = tbBook:GetBookInfo(pEquip.dwTemplateId);
    local szMsg = string.format("秘籍等级：%s/%s [64db00]（已满级）[-]", nBookLevel, tbBookInfo.MaxBookLevel);
    szMsg = szMsg .. string.format("\n\n秘籍技能等级：%s/%s", nBookSkillLevel, tbBookInfo.MaxSkillLevel);
    szMsg = szMsg .. "\n\n[FFFE0D]满级秘籍，若附带技能未满级，且达到7级，则可通过突破，将技能直接升到10级[-]";
    self.pPanel:Label_SetText("TopCheatsDesc", szMsg);

    for nI = 1, 2 do
        self["ConditionItem"..nI]:Clear();
    end

    local nMaxExp = me.GetMoney(tbBook.szSkillBookExpName) + tbBook:UpdateGrowXiuLianExp(me);
    local tbTuPoInfo = tbBook:GetBookTuPoByEquip(pEquip);
    if tbTuPoInfo then
        local tbCost = tbTuPoInfo.tbAllCostIteam[1];
        local tbItemHideID = {};
        tbItemHideID[self.nItemID] = 1;
        local nCount = me.GetItemCountInAllPos(tbCost.nItemTID, tbItemHideID);
        local szShow = "";
        if nCount < tbCost.nItemCount then
            szShow = "[ff0000]";
        else
            szShow = "[64db00]";
        end
        self.pPanel:Label_SetText("ItemNumber1", string.format("%s%s[-]/%s", szShow, nCount, tbCost.nItemCount));
        self.ConditionItem1:SetItemByTemplate(tbCost.nItemTID, nCount, me.nFaction);
        self.ConditionItem1.fnClick = self.ConditionItem1.DefaultClick;

        self.ConditionItem2:SetDigitalItem(tbBook.szSkillBookExpName, 0);
        self.ConditionItem2.fnClick = self.ConditionItem2.DefaultClick;

        szShow = "";
        if nMaxExp < tbTuPoInfo.CostExp then
            szShow = "[ff0000]";
        else
            szShow = "[64db00]";
        end

        self.pPanel:Label_SetText("ItemNumber2", string.format("%s%s[-]/%s", szShow, nMaxExp, tbTuPoInfo.CostExp));
    end
    self.pPanel:Label_SetText("BreachTitle", "突破所需");
    self.pPanel:Label_SetText("LbLevelUp", "突破");
end

function tbUi:OnOpEvolve()
    local pEquip = me.GetItemInBag(self.nItemID);
    if not pEquip then
        return;
    end

    Ui:CloseWindow(self.UI_NAME)
    Item:ShowItemDetail({nItemId = self.nItemID})
end

--修炼时该self.nItemID是绝学秘籍，非高级秘籍
function tbUi:OnOpXiuLian()
    local pEquip = me.GetItemInBag(self.nItemID);
    if not pEquip then
        return;
    end

    self.pPanel:Label_SetText("Title", "绝学修炼");
    self.pPanel:SetActive("Cheatsitem1", true);
    self.pPanel:SetActive("TopCheatsDesc", true);
    self.pPanel:SetActive("BottomCheatsDesc", true);
    self.Cheatsitem1:SetItem(self.nItemID);

    local nAreaId = pEquip.nCurEquipAreaId
    if not nAreaId then
        return
    end

    local nCurLv  = JueXue:GetCurXiuLianLv(me, nAreaId)
    local tbBook  = Item:GetClass("SkillBook");
    local nMaxExp = me.GetMoney(JueXue.Def.szMoneyType) + tbBook:UpdateGrowXiuLianExp(me);
    local szMsg   = string.format("绝学修炼等级：%d/%d", nCurLv, JueXue.nXiuLianMaxLv)
    szMsg = szMsg .. string.format("\n\n技能等级上限：%s级", JueXue:GetXiuLianSkillLv(me, nAreaId));
    local nConsume = JueXue:GetXiulianConsume(nCurLv)
    if nConsume then
        szMsg = szMsg .. string.format("\n\n升级所需修为：%s/%s", nConsume, nMaxExp);
    else
        szMsg = szMsg .. "\n\n已满级";
    end
    self.pPanel:Label_SetText("TopCheatsDesc", szMsg);

    self.pPanel:Label_SetText("BottomCheatsDesc", "*更换绝学时，绝学修炼等级保留");
    self.pPanel:Label_SetText("LbLevelUp", "修炼");
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow("CheatsOperationPanel");
end

tbUi.tbType = {
    ["BookTuPo"]         = true,
    ["SkillBookLevelUp"] = true,
    ["BookUpgrade"]      = true,
    ["AddSkillBookExp"]  = true,
    ["Evolve"]           = true,
    ["XiuLian"]          = true,
}

function tbUi:OnSyncData(szType)
    if self.tbType[szType] then
        local pEquip = me.GetItemInBag(self.nItemID);
        if not pEquip then
            Ui:CloseWindow("CheatsOperationPanel");
            return;
        end

        if pEquip.szClass == "SkillBook" then
            local tbBook = Item:GetClass("SkillBook");
            local szOperation = tbBook:GetEquipOperation(pEquip);
            self.szOperation = szOperation or self.szOperation;
        end
        self:Update();
    end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end
