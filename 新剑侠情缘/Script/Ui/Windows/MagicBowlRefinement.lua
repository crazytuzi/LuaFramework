local tbUI = Ui:CreateClass("MagicBowlRefinementPanel")

function tbUI:DoRefine()
  if not self:HaveEnoughMoney() then
        me.CenterMsg("银两不足");
        return;
    end

    local nTarPos;
    if self.tbTarAttribs[self.nTarPos] then
        nTarPos = self.nTarPos;
    else
        nTarPos = nil;
    end

    if not self.nSrcPos then
        me.CenterMsg("请选择洗练属性");
        return;
    end

    if not self.nTarPos then
        me.CenterMsg("请选择被替换属性")
        return
    end

    if self.bRequest then --防止网络卡发送了多条请求
        me.CenterMsg("请等待洗练结果")
        return
    end

    local fnYes = function ()
        self.bRequest = true;
        House:MagicBowlRefinementReq(self.nSrcEquipId, self.nSrcPos, nTarPos or 0)
    end

    if nTarPos and self.tbTarAttribs[self.nTarPos].nAttribLevel > self.tbSrcAttribs[self.nSrcPos].nAttribLevel then
        Ui:OpenWindow("MessageBox",
          "确认将 [FFFE0D]高级属性[-] 替换为 [FFFE0D]低级属性[-] 吗？",
         { {fnYes},{} },
         {"替换", "取消替换"});

    else
        fnYes();
    end
end

tbUI.tbOnClick =
{
    BtnClose = function (self)
        self.bAllReturn = false;
            Ui:CloseWindow(self.UI_NAME);
    end,

    BtnOK = function (self)
        self:DoRefine()
    end,
}

function tbUI:OnOpen(nSrcEquipId)
    self.bRequest = false;

    self.nSrcEquipId = nSrcEquipId;
    self.pSrcEquip = me.GetItemInBag(nSrcEquipId);

    self:Update()
end

function tbUI:Update()
    self.nSrcPos = nil;
    self.nTarPos = nil;

    self.tbForbitTar = {};
    self.tbForbitSrc = {};

    local tbSrcAttribs = Item.tbRefinement:GetRandomAttribEx(self.pSrcEquip);
    local tbTarAttribs = House:MagicBowlGetAttrs()
    self.tbSrcAttribs = tbSrcAttribs;
    self.tbTarAttribs = tbTarAttribs;

    self.pPanel:Label_SetText("TxtCoin", 0);
    self:UpdateSourcePanel();
    self:UpdateTargetPanel();
end

function tbUI:UpdateAttribItemUi(pPanelSrcAttrib, tbAttrib,nItemType, nEquipLevel )
    local szColor
    if not tbAttrib then
        pPanelSrcAttrib:Label_SetText("TxtAttrib", "（空属性）");
        szColor = Item:GetQualityColor(1)
        pPanelSrcAttrib:Label_SetGradientColor("TxtAttrib", szColor);
        return;
    end

    local tbMA, szDesc, szAttrib = Item.tbRefinement:GetAttribMA(tbAttrib, nItemType);
    local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel, nItemType);
    if  Lib:IsEmptyStr(szDesc) then
        szDesc = FightSkill:GetMagicDesc(szAttrib, tbMA);
    end
    pPanelSrcAttrib:Label_SetText("TxtAttrib", szDesc);
    szColor = Item:GetQualityColor(nQuality)
    pPanelSrcAttrib:Label_SetGradientColor("TxtAttrib", szColor);
end

function tbUI:UpdateSourcePanel(bAutoSelect)
    local bExistSame = false;
    local nSameAttribGrp;
    if self.nTarPos then
        local tbTarAttrib = self.tbTarAttribs[self.nTarPos];
        if tbTarAttrib then
            bExistSame = Item.tbRefinement:IsExistSameTypeAttribEx(self.tbSrcAttribs, tbTarAttrib.nExternAttribGrp);
            nSameAttribGrp = tbTarAttrib.nExternAttribGrp;
        end
    end

    if bAutoSelect then
        for i,tbSrcAttrib in ipairs(self.tbSrcAttribs) do
            if bExistSame and tbSrcAttrib.nExternAttribGrp == nSameAttribGrp then
                self.nSrcPos = i;
                break;
            end
        end
    end

    local fnClickSrcAttrib = function (itemObj)
        local nIndex = itemObj.nIndex
        if self.tbForbitSrc[nIndex] then
            return;
        end

        if self.nSrcPos == nIndex then
            self.nSrcPos = nil;
            self.nTarPos = nil;
        else
            self.nSrcPos = nIndex;
        end

        self.tbForbitTar = {};
        self:UpdateSourcePanel(false);
        self:UpdateTargetPanel(true);
        self:CalcCost();
    end

    local tbMagicBowl = House:GetMagicBowlData(me.dwID)

    local fnSetItem = function (itemObj, i)
        itemObj.nIndex = i
        local pPanelSrcAttrib = itemObj.pPanel
        local tbAttrib = self.tbSrcAttribs[i];

        self:UpdateAttribItemUi(pPanelSrcAttrib, tbAttrib, self.pSrcEquip.nItemType, tbMagicBowl.nLevel)

        pPanelSrcAttrib.OnTouchEvent = fnClickSrcAttrib

        local bCanSelelct = true;
        for _,tbTarAttrib in ipairs(self.tbTarAttribs) do
            if tbTarAttrib and tbTarAttrib.nExternAttribGrp == tbAttrib.nExternAttribGrp then
                 if tbAttrib.nAttribLevel <= tbTarAttrib.nAttribLevel then
                    bCanSelelct = false;
                 end
                 break;
            end
        end
        pPanelSrcAttrib:SetActive("CheckBox", bCanSelelct);
        pPanelSrcAttrib:Button_SetEnabled("Main", bCanSelelct)
        local bSelect = i == self.nSrcPos;
        pPanelSrcAttrib:SetActive("CheckMark", bSelect);
        pPanelSrcAttrib:SetActive("Highlight", bSelect);
    end
    self.ScrollView2:Update(self.tbSrcAttribs, fnSetItem)

    local szName = Item:GetItemTemplateShowInfo(self.pSrcEquip.dwTemplateId, me.nFaction, me.nSex)
    self.pPanel:Label_SetText("TxtSrcEquipName", szName)
    self.ItemSrc:SetItem(self.pSrcEquip.dwId, {bShowTip = false});
end

function tbUI:UpdateTargetPanel(bAutoSelect)
    local bExistSame = false;
    local nSameAttribGrp
    if self.nSrcPos then
        local tbSrcAttrib = self.tbSrcAttribs[self.nSrcPos];
        bExistSame = Item.tbRefinement:IsExistSameTypeAttribEx(self.tbTarAttribs, tbSrcAttrib.nExternAttribGrp);
        nSameAttribGrp = tbSrcAttrib.nExternAttribGrp;
    end

    --自动选择
    local nFullCount = Furniture.MagicBowl:GetMaxAttrCount(me.dwID)
    if bAutoSelect then
        self.nTarPos = nil;
        for i = 1, nFullCount do
            local tbTarAttrib = self.tbTarAttribs[i];
            if tbTarAttrib then
                if bExistSame and tbTarAttrib.nExternAttribGrp == nSameAttribGrp then
                    self.nTarPos = i;
                    break;
                end
            else
                self.nTarPos = i;
                break;
            end
        end

    end

    local fnClickTarAttrib = function (itemObj)
        local nIndex = itemObj.nIndex
        if self.tbForbitTar[nIndex] then
            return;
        end

        if self.nTarPos == nIndex then
            self.nSrcPos = nil;
            self.nTarPos = nil;
            self.tbForbitTar = {};
        else
            self.nTarPos = nIndex;
        end

        self:UpdateTargetPanel(false);
        self:UpdateSourcePanel(false);

        self:CalcCost();
    end

    local tbMagicBowl = House:GetMagicBowlData(me.dwID)

    local fnSetItem = function (itemObj, i)
        itemObj.nIndex = i
        local pPanelSrcAttrib = itemObj.pPanel
        local tbAttrib = self.tbTarAttribs[i];

        self:UpdateAttribItemUi(pPanelSrcAttrib, tbAttrib, self.pSrcEquip.nItemType, tbMagicBowl.nLevel)
        pPanelSrcAttrib.OnTouchEvent = fnClickTarAttrib
        if tbAttrib then
            if bAutoSelect and bExistSame and tbAttrib.nExternAttribGrp ~= nSameAttribGrp then
                self.tbForbitTar[i] = true;
                pPanelSrcAttrib:SetActive("CheckBox", false);
            else
                pPanelSrcAttrib:SetActive("CheckBox", true);
            end
        else
            pPanelSrcAttrib:SetActive("CheckBox", not bExistSame);
            pPanelSrcAttrib:SetActive("CheckBox", not bExistSame);

            if bAutoSelect and bExistSame then
                self.tbForbitTar[i] = true;
            end
        end
        local bSelect = i == self.nTarPos;
        pPanelSrcAttrib:SetActive("CheckMark", bSelect);
        pPanelSrcAttrib:SetActive("Highlight", bSelect);

    end
    self.ScrollView1:Update(nFullCount, fnSetItem)

    self:CalcCost();

    self.pPanel:Label_SetText("TxtTarEquipName", string.format("%d级聚宝盆", tbMagicBowl.nLevel))
    local tbSetting = Furniture.MagicBowl:GetLevelSetting(tbMagicBowl.nLevel)
    self.ItemTar:SetItemByTemplate(tbSetting.nItemId, 1)
end


function tbUI:HaveEnoughMoney()
    local nCoin = me.GetMoney("Coin");
    return nCoin >= self.nCost;
end

function tbUI:CalcCost()
    local nCost = 0
    local tbSrcAttrib = self.tbSrcAttribs[self.nSrcPos];
    if tbSrcAttrib then
        nCost = Furniture.MagicBowl:GetRefineCost(tbSrcAttrib.nSaveData)
    end
    self.nCost = nCost
    self.pPanel:Label_SetText("TxtCoin", nCost);
end

function tbUI:OnRespond(bRet, szMsg)
    self.bRequest = false;
    if szMsg then
        me.CenterMsg(szMsg)
    end
    if not bRet then
        self:Update();
        return
    end
    local tbSrcAttrib = self.tbSrcAttribs[self.nSrcPos];
    local tbTarAttrib = self.tbTarAttribs[self.nTarPos];
    local szOrgDesc;
    local nOrgAttribLevel;
    if tbTarAttrib then
        nOrgAttribLevel = tbTarAttrib.nAttribLevel;
        local tbMA, _, szAttrib = Item.tbRefinement:GetAttribMA(tbTarAttrib, self.pSrcEquip.nItemType);
        szOrgDesc = FightSkill:GetMagicDesc(szAttrib, tbMA);
    end

    local tbMA, _, szAttrib = Item.tbRefinement:GetAttribMA(tbSrcAttrib, self.pSrcEquip.nItemType);
    local szCurDesc = FightSkill:GetMagicDesc(szAttrib, tbMA);
    local nCurAttribLevel = tbSrcAttrib.nAttribLevel;

    local tbMagicBowl = House:GetMagicBowlData(me.dwID)
    Ui:OpenWindow("RefineNotice", szOrgDesc, szCurDesc, nOrgAttribLevel, nCurAttribLevel, tbMagicBowl.nLevel, self.pSrcEquip.nItemType);
    local tbSrcAttribs = Item.tbRefinement:GetRandomAttribEx(self.pSrcEquip);
    if not next(tbSrcAttribs) then
        --[[
        if self.pSrcEquip.szClass ~= "ZhenYuan" or  self.pSrcEquip.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo) == 0 then
            Shop:QuickSellItem(self.pSrcEquip.dwId, "当前铭文已无随机属性，建议出售。\n出售可以获得%d%s")
        end
        ]]
        Ui:CloseWindow(self.UI_NAME);
    else
        self:Update()
    end
end