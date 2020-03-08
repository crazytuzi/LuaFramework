local tbUi    = Ui:CreateClass("PartnerItemComposePanel");
local COMPOSE = 1;
local GAIN    = 2;

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_ONCOMPOSE_CALLBACK, self.OnComposeSuccess,  self },
        { UiNotify.emNOTIFY_SYNC_ITEM,          self.OnItemNumChange,   self },
    };

    return tbRegEvent;
end

function tbUi:OnOpen(nTemplateID, tbExtPar)
    if not nTemplateID then
        return;
    end

    self.vecDetail   = self.vecDetail or self.pPanel:GetPosition("Details");
    self.vecBgSize   = self.vecBgSize or self.pPanel:Sprite_GetSize("Bg");
    self.nTemplateID = nTemplateID;
    self.tbExtPar    = tbExtPar or {};

    self:Update();
end

function tbUi:OnClose()
    if not self.nTemplateID then
        return;
    end

    self:CloseSubUi();
    Compose:ClearCurItem()
end

function tbUi:Update()
    local tbBaseInfo = KItem.GetItemBaseProp(self.nTemplateID);
    self.pPanel:Label_SetText("Name", tbBaseInfo.szName);
    self.pPanel:SetActive("BtnSure", false);

    self.Details_Item:SetGenericItem({ "Item", self.nTemplateID });

    if tbBaseInfo.szClass == "PartnerEquip" then
        self:UpdatePartnerEquip();
    else
        Log("暂未支持的同伴类型：", tbBaseInfo.szClass);
    end

    self.pPanel.OnTouchEvent = function ()
        Ui:CloseWindow(self.UI_NAME);
    end
end

local function GetTips(nTemplateID)
    local tbEquipInfo = KItem.GetPartnerItemInfo(nTemplateID);
    local szTips = "[ECE82B]";
    local function fnCmp(tb1, tb2)
        return tb1.szAttribName > tb2.szAttribName;
    end
    table.sort(tbEquipInfo.tbAttrib, fnCmp);

    for _, tbAttrib in ipairs(tbEquipInfo.tbAttrib) do
        szTips = szTips .. FightSkill:GetMagicDesc(tbAttrib.szAttribName, tbAttrib.tbValue) .. "\n";
    end
    szTips = szTips .. "[-]";
    return szTips;
end

function tbUi:UpdatePartnerEquip()
    self.pPanel:SetActive("BtnStoneGroup", false);
    self.pPanel:SetActive("BtnEquipGroup", true);

    self.pPanel:SetActive("Tip", true);
    self.pPanel:SetActive("Label3", true);
    self.pPanel:SetActive("Label2", false);

    local nHaveNum = me.GetItemCountInAllPos(self.nTemplateID) or 0;
    local szHaveNum = string.format("[92d2ff]拥有[-] %d [92d2ff]件", nHaveNum);
    self.pPanel:Label_SetText("Have", szHaveNum);

    local tbPartner    = me.GetPartnerInfo(self.tbExtPar.nPartnerID);
    local nNeedLevel   = GetPartnerEquipNeedLevel(tbPartner.nGradeLevel, self.tbExtPar.nPos);
    local bLevelEnough = tbPartner.nLevel >= nNeedLevel;
    self.pPanel:SetActive("Tip", true);
    if bLevelEnough then
        self.pPanel:Label_SetText("Tip", "[92d2ff]装备后会与该同伴绑定");
    else
        local szTip = string.format("[FF0000]需要同伴等级：%d级", nNeedLevel);
        self.pPanel:Label_SetText("Tip", szTip);
    end

    local tbChild    = self:GetChildItem(self.nTemplateID);
    local tbGainInfo = OutputTable:GetRuneOutputList(self.nTemplateID);
    self.pPanel:SetActive("BtnGoCompose", #tbChild > 0 and #tbGainInfo > 0);
    self.pPanel:SetActive("BtnGoGain", #tbGainInfo > 0 and #tbChild > 0);
    self.pPanel:SetActive("BtnEquip", #tbGainInfo == 0 or #tbChild == 0 or nHaveNum > 0);
    self.pPanel:Button_SetEnabled("BtnEquip", true);
    if nHaveNum > 0 then
        self.pPanel:Button_SetText("BtnEquip", "装备");
        self.pPanel:Button_SetEnabled("BtnEquip", bLevelEnough);
        self.tbOnClick.BtnEquip = function ()
            self:Equip();
        end
    elseif #tbGainInfo > 0 and #tbChild == 0 then
        self.pPanel:Button_SetText("BtnEquip", "获取");
        self.tbOnClick.BtnEquip = function ()
            self:OpenSubUi(GAIN);
        end
    elseif #tbGainInfo == 0 and #tbChild > 0 then
        self.pPanel:Button_SetText("BtnEquip", "合成");
        self.tbOnClick.BtnEquip = function ()
            self:OpenSubUi(COMPOSE);
        end
    end

    local szDesc = GetTips(self.nTemplateID);
    self.pPanel:Label_SetText("Label1", szDesc);
    local tbBaseInfo = KItem.GetItemBaseProp(self.nTemplateID) or {};
    self.pPanel:Label_SetText("Label3", tbBaseInfo.szIntro or "");
end

function tbUi:OpenSubUi(nSubState)
    self.pPanel:ChangePosition("Details", self.vecDetail.x - self.vecBgSize.x/2, self.vecDetail.y);
    self.pPanel:SetActive("CombineAndGain", true);

    self.nSubState = nSubState or self.nSubState;
    self:OnComposeOpen();
end

function tbUi:CloseSubUi()
    self.pPanel:ChangePosition("Details", self.vecDetail.x, self.vecDetail.y);
    self.pPanel:SetActive("CombineAndGain", false);
    self.nSubState = nil;
end

function tbUi:OnComposeOpen()
    self.tbTopItem = {};
    self:UpdateSubUi(self.nTemplateID);
end

function tbUi:UpdateSubUi(nItemID)
    self.nCurItemID = nItemID or self.nCurItemID;
    self:UpdateTop();
    self:UpdateContent();
end

function tbUi:OnClickItem(nItemID)
    self:UpdateSubUi(nItemID);
end

function tbUi:UpdateContent()
    local tbChild = self:GetChildItem(self.nCurItemID);
    local szName  = Item:GetItemTemplateShowInfo(self.nCurItemID);

    self.pPanel:SetActive("MiniGain", #tbChild <= 0 or self.nSubState == GAIN);
    self.pPanel:SetActive("Combine", #tbChild > 0 and self.nSubState == COMPOSE);
    self.pPanel:Label_SetText("ItemNameLabel", szName);

    if self.nSubState == COMPOSE and #tbChild > 0 then
        self:UpdateChildTree();
    else
        self:UpdateGainList();
    end
end

local CHILD_NUM = 3;
function tbUi:UpdateChildTree()
    local tbChild = self:GetChildItem(self.nCurItemID);
    local nChild  = math.min(#tbChild, CHILD_NUM);
    self.MainItem:SetGenericItem({ "Item", self.nCurItemID });

    self.pPanel:Sprite_SetSprite("CombineArrow", "CombineSource0" .. nChild);
    for i = 1, CHILD_NUM do
        self.pPanel:SetActive("itemframe" .. i, false);
        self.pPanel:SetActive("Number" .. i, false);
    end

    local tbIndex = {1, 2, 3};
    if nChild == 1 then
        table.remove(tbIndex, 3);
        table.remove(tbIndex, 1);
    elseif nChild == 2 then
        table.remove(tbIndex, 2);
    end

    for nIdx = 1, nChild do
        local nUiID      = tbIndex[nIdx];
        local tbCurChild = tbChild[nIdx] or {};
        local function fnClick()
            self:OnClickItem(tbCurChild.nChildTemplateID);
        end
        self["itemframe" .. nUiID]:SetGenericItem({ "Item", tbCurChild.nChildTemplateID });
        self["itemframe" .. nUiID].fnClick = fnClick;
        self.pPanel:SetActive("itemframe" .. nUiID, true)

        local nNeedNum = tbCurChild.nNeedNum;
        local nHadNum  = me.GetItemCountInAllPos(tbCurChild.nChildTemplateID);
        local szColor  = nHadNum >= nNeedNum and "[-]" or "[FF0000]";
        self.pPanel:SetActive("Number".. nUiID, true);
        self.pPanel:Label_SetText("Number" .. nUiID, string.format("%s%d [-]/ %d", szColor, nHadNum, nNeedNum));
    end
end

function tbUi:UpdateGainList()
    self.GainItem:SetGenericItem({ "Item", self.nCurItemID });

    local tbGainInfo = OutputTable:GetRuneOutputList(self.nCurItemID);
    local fnOnClick = function (itemObj)
        local tbInfo = tbGainInfo[itemObj.nIndex];
        OutputTable:GotoGainUi(tbInfo);

        local nTargetID = self.tbTopItem[#self.tbTopItem - 1]
        Compose:SetCurItem(nTargetID, self.nCurItemID)
    end
    local fnSetItem = function(itemObj, nIdx)
        local bEnable, szDesc, szBgSprite, szIcon = OutputTable:GetGainInfo(tbGainInfo[nIdx]);
        itemObj.pPanel:Label_SetText("Label", szDesc);
        itemObj.pPanel:Sprite_SetSprite("Main", szBgSprite);
        itemObj.pPanel:Sprite_SetSprite("Icon", szIcon);

        itemObj.nIndex = nIdx;
        itemObj.pPanel.OnTouchEvent = bEnable and fnOnClick;
    end
    self.ScrollView:Update(#tbGainInfo, fnSetItem);
end

local TOP_NUM = 4;
function tbUi:UpdateTop()
    self:UpdateTopList();
    local nBeginIndex = #self.tbTopItem > TOP_NUM and (#self.tbTopItem - TOP_NUM + 1) or 1;
    for nIdx = 1, TOP_NUM do
        local nItemID = self.tbTopItem[nBeginIndex];
        self.pPanel:SetActive("Select" .. nIdx, nItemID == self.nCurItemID);
        if nItemID then
            local function fnClick()
                self:OnClickItem(nItemID);
            end
            self["Top_Item" .. nIdx]:SetGenericItem({ "Item", nItemID });
            self["Top_Item" .. nIdx].fnClick = fnClick;
            self.pPanel:SetActive("Top_Item" .. nIdx, true);
        else
            self.pPanel:SetActive("Top_Item" .. nIdx, false);
        end

        if nIdx > 1 then
            self.pPanel:SetActive("Arrow" .. (nIdx - 1), nItemID);
        end

        nBeginIndex = nBeginIndex + 1;
    end
end

function tbUi:UpdateTopList()
    self.tbTopItem = self.tbTopItem or {};
    local nIdx = #self.tbTopItem + 1;
    for i, nID in pairs(self.tbTopItem) do
        if nID == self.nCurItemID then
            nIdx = i;
        end
    end
    for i = #self.tbTopItem, 1, -1 do
        if i < nIdx then
            break;
        end
        table.remove(self.tbTopItem, i);
    end
    table.insert(self.tbTopItem, self.nCurItemID);
end

function tbUi:GetChildItem(nTemplateID)
    return Compose:GetConsumeInfo(nTemplateID) or {};
end

function tbUi:OnComposeSuccess(nItemTemplateID, dwItemId)
    if not nItemTemplateID or nItemTemplateID ~= self.nCurItemID then
        return;
    end

    local nTopNum = #self.tbTopItem;
    if nTopNum <= 0 then
        self:CloseSubUi();
        return;
    end

    if nTopNum > 1 then
        local nClickTemplateID = self.tbTopItem[nTopNum - 1];
        self:OnClickItem(nClickTemplateID);
    else
        self.tbExtPar.nItemId = dwItemId or self.tbExtPar.nItemId;
        self:CloseSubUi();
        self:Update();
    end
end

function tbUi:Equip()
    if self.tbExtPar then
        Log("[PartnerItemComposePanel Equip] UseEquipInfo:", self.tbExtPar.nPartnerID, self.tbExtPar.nPos, self.tbExtPar.nItemId);
        if not self.tbExtPar.nItemId then
            local tbItem = me.FindItemInBag(self.nTemplateID)
            self.tbExtPar.nItemId = tbItem[1].dwId
        end
        RemoteServer.CallPartnerFunc("UseEquip", self.tbExtPar.nPartnerID, self.tbExtPar.nPos, self.tbExtPar.nItemId);
    else
        me.CenterMsg("装备失败，请重试");
    end
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnItemNumChange()
    self:UpdatePartnerEquip();
end

tbUi.tbOnClick = {};
tbUi.tbOnClick["BtnGoGain"] = function (self)
    self:OpenSubUi(GAIN);
end

tbUi.tbOnClick["BtnGoCompose"] = function (self)
    self:OpenSubUi(COMPOSE);
end

tbUi.tbOnClick["BtnCompose"] = function (self)
--合成X
    RemoteServer.TryComposeItem(self.nCurItemID);
end

tbUi.tbOnClick["BtnGainBack"] = function (self)
    local nTopNum = #self.tbTopItem;
    if nTopNum > 1 then
        self:UpdateSubUi(self.tbTopItem[nTopNum - 1]);
    else
        self:CloseSubUi();
    end
end

tbUi.tbOnClick["BtnEquip"] = function (self)
    self:Equip();
end