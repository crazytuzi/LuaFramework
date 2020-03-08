
local tbUi = Ui:CreateClass("SkillCheatsPanel");

tbUi.tbOnClick =
{
    BtnLevelUp = function (self)
        if not self.nItemID then
            return;
        end

      if InDifferBattle.bRegistNotofy then
            Shop:ConfirmSell(self.nItemID);
            Ui:CloseWindow(self.UI_NAME)
            return
        end

        local pItem = me.GetItemInBag(self.nItemID);
        if not pItem then
            return;
        end

        local tbBook = Item:GetClass("SkillBook");
        local szOpration = tbBook:GetEquipOperation(pItem);
        if not szOpration then
            return;
        end

        if szOpration == "Evolve" then
            JueXue:TryActivateArea(pItem)
        else
            Ui:OpenWindow("CheatsOperationPanel", self.nItemID, szOpration);
        end

        Ui:CloseWindow("SkillCheatsPanel");
    end,

    BtnUnload = function (self)
        if not self.nItemID then
            return;
        end

        local tbBook = Item:GetClass("SkillBook");
        local bRet, szMsg, pEquip = tbBook:CheckRecycleSkillBook(me, self.nItemID);
        if not bRet then
            me.CenterMsg(szMsg);
            return;
        end

        local nBookLevel = pEquip.GetIntValue(tbBook.nSaveBookLevel);
        local nCosExp = tbBook:GetSkillBookExp(pEquip);
        me.MsgBox(string.format("该秘籍被拆解后，可获得%s点修为\n你确定要拆解吗？", nCosExp), {{"确定", function ()
            RemoteServer.DoSkillBook("RecycleSkillBook", self.nItemID);
            Ui:CloseWindow("SkillCheatsPanel");
        end}, {"取消"}})
        Ui:CloseWindow("SkillCheatsPanel");
    end,

    BtnEquip = function (self)
        if not self.nItemID then
            return;
        end

        local pItem = me.GetItemInBag(self.nItemID);
        if not pItem then
            return;
        end

        if pItem.nPos ~= Item.EITEMPOS_BAG then
            RemoteServer.UnuseEquip(pItem.nPos);
            --Player:ClientUnUseEquip( pItem.nPos )
            Ui:CloseWindow("SkillCheatsPanel");
            return;
        end

        local tbBook = Item:GetClass("SkillBook");
        local nEquipPos = tbBook:FinEmptyHole(me);
        if not nEquipPos then
            me.CenterMsg("已经满了！");
            return;
        end

        local bRet, szMsg = tbBook:CheckUseEquip(me, pItem, nEquipPos);
        if not bRet then
            me.CenterMsg(szMsg);
            return;
        end

        RemoteServer.UseEquip(self.nItemID, nEquipPos)

        if InDifferBattle.bRegistNotofy then

        else
            Ui:OpenWindow("SkillPanel", "PublicPanel");
        end

        Ui:CloseWindow("SkillCheatsPanel");
    end,
}

function tbUi:OnOpen(nItemID, nItemTID, tbIntValueInfo, szOpt)
    if not nItemID and not nItemTID then
        return 0;
    end

    self.nItemID = nItemID;
    self.szOpt = szOpt

    self:UpdateInfo(nItemID, nItemTID, tbIntValueInfo);
    Ui:OpenWindow("BgBlackAll", 0.7, Ui.LAYER_NORMAL)
end

function tbUi:UpdateBtnState()
    local bShowBtnEquip = self.nItemID ~= nil
    local bShowBtnLevelUp = false;
    local bShowBtnUnload = false;
    if self.szOpt == "ViewEquip" then
       bShowBtnEquip = false;
       bShowBtnLevelUp = false;
       bShowBtnUnload = false;
    else
        if self.nItemID ~= nil then
            local tbBook = Item:GetClass("SkillBook");
            local pItem = me.GetItemInBag(self.nItemID);
            if pItem then
                if tbBook:GetEquipOperation(pItem) then
                    bShowBtnLevelUp = true
                end
                local nBookLevel = pItem.GetIntValue(tbBook.nSaveBookLevel);
                local tbBookInfo = tbBook:GetBookInfo(pItem.dwTemplateId);
                bShowBtnUnload = nBookLevel > 1 and tbBookInfo.LimitRecycle ~= 1;

                if InDifferBattle.bRegistNotofy then
                    local nPrice, szMoneyType = InDifferBattle:GetSellSumPrice(pItem.dwTemplateId, 1)
                    if not nPrice then
                        bShowBtnLevelUp = false;
                    end
                    if pItem.nPos ~= Item.EITEMPOS_BAG then
                        bShowBtnEquip = false
                    end
                end
            end
        end
    end

    if InDifferBattle.bRegistNotofy then
        self.pPanel:Label_SetText("LbLevelUp", "出售")
        bShowBtnUnload = false;
    else
        self.pPanel:Label_SetText("LbLevelUp", "升级")
    end
    self.pPanel:SetActive("BtnEquip", bShowBtnEquip);
    self.pPanel:SetActive("BtnLevelUp", bShowBtnLevelUp);
    self.pPanel:SetActive("BtnUnload", bShowBtnUnload);

end

function tbUi:UpdateInfo(nItemID, nItemTID, tbIntValueInfo)
    self:UpdateBtnState();
    self.pPanel:SetActive("SkillUpgradeCondition", nItemID ~= nil and self.szOpt ~= "ViewEquip");
    if self.szOpt == "ViewEquip" and nItemID and me.GetItemInBag(nItemID) then
        self.pPanel:SetActive("Equipped", true)
    else
        self.pPanel:SetActive("Equipped", false)
    end

    local nBookLevel = 1;
    local nBookSkillLevel = 1;
    local tbBookInfo = nil;
    local tbBook = Item:GetClass("SkillBook");
    if nItemID then
        local pItem = KItem.GetItemObj(nItemID)
        if not pItem then
            return;
        end

        nItemTID = pItem.dwTemplateId;
        nBookLevel = pItem.GetIntValue(tbBook.nSaveBookLevel);
        nBookSkillLevel = pItem.GetIntValue(tbBook.nSaveSkillLevel);
        if pItem.nPos ~= Item.EITEMPOS_BAG then
            self.pPanel:Label_SetText("EquipLabel", "卸下");
        else
            self.pPanel:Label_SetText("EquipLabel", "装备");
        end

        tbBookInfo = tbBook:GetBookInfo(nItemTID);

        local nGrowExp = tbBook:UpdateGrowXiuLianExp(me);
        local tbBookLevelInfo = tbBook:GetBookLevelInfo(nBookLevel);
        local szUpgradeMsg = "";
        if nBookSkillLevel >= tbBookInfo.MaxSkillLevel then
            szUpgradeMsg = "<已满级>";
        else
            szUpgradeMsg = string.format("升级所需修为：%s/%s", tbBookLevelInfo.CostExp, me.GetMoney(tbBook.szSkillBookExpName) + nGrowExp)
        end

        local szOpration = tbBook:GetEquipOperation(pItem);
        if szOpration then
            local szLevel = "升级";
            if szOpration == "LevelUp" then
                szLevel = "升级";
            elseif szOpration == "Upgrade" then
                szLevel = "进阶";
                szUpgradeMsg = "秘籍已满级，可进阶成中级秘籍";
                if tbBookInfo.Type == tbBook.nBookTypeMiddle then
                    szUpgradeMsg = "秘籍已满级，可进阶成高级级秘籍";
                end

            elseif szOpration == "TuPo" then
                szLevel = "突破";
                szUpgradeMsg = "秘籍已满级，可通过突破提升技能等级";
            elseif szOpration == "Evolve" then		--绝学图突破
                szLevel = "突破";
                local tbInfo = KItem.GetItemBaseProp(JueXue.Def.nActivateTemplateId)
                local _1, _2, nAreaId = JueXue:GetBookActivateArea(pItem.dwTemplateId)
                szUpgradeMsg = string.format("解锁绝学位置需要消耗%s%d个", tbInfo.szName, JueXue.Def.nActivateConsume);
            end

            if not InDifferBattle.bRegistNotofy then
                self.pPanel:Label_SetText("LbLevelUp", szLevel);
            end
        end

        local bRet = tbBook:CheckBookLevelUp(me, nItemID);
        local bRet1 = tbBook:CheckBookUpgrade(me, pItem.dwId);
        local bRet2 = tbBook:CheckBookTuPo(me, pItem.dwId);
        local bRet3 = tbBook:CheckBookEvolve(me, pItem.dwId);
        self.pPanel:SetActive("SkillRedmark", (bRet or bRet1 or bRet2 or bRet3) and pItem.nPos ~= Item.EITEMPOS_BAG);

        self.pPanel:Label_SetText("SkillUpgradeCondition", szUpgradeMsg);

    elseif tbIntValueInfo and Lib:HaveCountTB(tbIntValueInfo) then
        nBookLevel = tbIntValueInfo[tbBook.nSaveBookLevel] or nBookLevel;
        nBookSkillLevel = tbIntValueInfo[tbBook.nSaveSkillLevel] or nBookSkillLevel;
    else
        tbBookInfo = tbBook:GetBookInfo(nItemTID);
        if tbBookInfo.Type == tbBook.nBookTypeMiddle then
            nBookLevel = 100;
            nBookSkillLevel = 10;
        elseif tbBookInfo.Type == tbBook.nBookTypeHigh then
            nBookLevel = 150;
            nBookSkillLevel = 15;
        end
    end

    tbBookInfo = tbBook:GetBookInfo(nItemTID);
    if not tbBookInfo then
        Log("Error SkillBook Not Book Info", nItemTID);
        return;
    end

    local tbAllAttrib, tbSkillInfo, nFightPower = tbBook:GetShowTipInfo(nItemTID, nBookLevel, nBookSkillLevel);
    if not tbAllAttrib then
        return;
    end

    local tbEquip = Item:GetClass("equip");
    self.CheatsItem:SetItemByTemplate(nItemTID, 1, me.nFaction);
    self.CheatsItem.fnClick = nil;
    local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nItemTID, me.nFaction, me.nSex);
    local szNameColor = Item:GetQualityColor(nQuality) or "White";
    self.pPanel:Label_SetText("CheatsName", szName or "-");
    self.pPanel:Label_SetText("TxtFightPower", string.format("战力：%s", nFightPower));
    self.pPanel:Label_SetColorByName("CheatsName", szNameColor);
    self.pPanel:Label_SetText("CheatsLevel", string.format("等级：%s级", nBookLevel));
    if tbBookInfo.LimitFaction > 0 then
        self.pPanel:SetActive("Faction", true);
        self.pPanel:Label_SetText("Faction", string.format("门派：%s", Faction:GetName(tbBookInfo.LimitFaction)));
    else
        self.pPanel:SetActive("Faction", false);
    end

    local szAttrib = "";
    for _, tbInfo in ipairs(tbAllAttrib) do
        local szDesc = tbEquip:GetMagicAttribDesc(tbInfo.szType, tbInfo.tbValue);
        szAttrib = szAttrib..szDesc.."\n";
    end

    self.pPanel:Label_SetText("Attribute1", szAttrib);
    --self.pPanel:Label_SetColorByName("Attribute1", szNameColor or "White");

    local tbIcon, szSkillName = FightSkill:GetSkillShowInfo(tbSkillInfo.nSkillID);
    self.pPanel:Label_SetText("SkillName", szSkillName or "-");
    self.pPanel:Sprite_SetSprite("SkillItem", tbIcon.szIconSprite, tbIcon.szIconAtlas);
    local szMagicDesc = FightSkill:GetSkillMagicDesc(tbSkillInfo.nSkillID, tbSkillInfo.nSkillLevel);
    local tbSkillSetting = FightSkill:GetSkillSetting(tbSkillInfo.nSkillID, tbSkillInfo.nSkillLevel);

    local tbBookInfo = tbBook:GetBookInfo(nItemTID);
    self.pPanel:Label_SetText("SkillLevel", string.format("等级：%s/%s", tbSkillInfo.nSkillLevel, tbBookInfo.MaxSkillLevel));
    self.pPanel:Label_SetText("SkillDetails", string.format("%s\n\n%s", tbSkillSetting.Desc, szMagicDesc));

end



function tbUi:OnScreenClick()
    Ui:CloseWindow("SkillCheatsPanel");
end

function tbUi:OnSyncData(szType)
    if szType ~= "SkillBookLevelUp" then
        return;
    end

    local nItemID = Player:GetServerSyncData("SkillBookLevelUp");
    self:UpdateInfo(nItemID);
end

function tbUi:OnTipsClose(szWnd)
    if szWnd == "SkillCheatsPanel" or szWnd == "SkillCheatsComparePanel" then
        Ui:CloseWindow(self.UI_NAME);
    end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
        { UiNotify.emNOTIFY_WND_CLOSED,                 self.OnTipsClose},
    };

    return tbRegEvent;
end

function tbUi:OnClose()
    if Ui:WindowVisible("SkillCheatsPanel") == 1 and Ui:WindowVisible("SkillCheatsComparePanel") == 1 then
        return
    end
    Ui:CloseWindow("BgBlackAll")
end

