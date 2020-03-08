local ChatEquipBQ = ChatMgr.ChatEquipBQ
local tbUi = Ui:CreateClass("ActionBQPanel");
tbUi.tbOnClick = {};
tbUi.nTotalSub = 5;

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen()
    self:UpdateInfo();
end

function tbUi:UpdateInfo()
    local pNpc = me.GetNpc();
    self.tbAllItem = {};
    if pNpc.nShapeShiftNpcTID <= 0 then
        local szShape = ActionInteract:GetFactionShape(me.nFaction, me.nSex);
        local tbInteractInfo = ActionInteract:GetInteractShowInfo(szShape) or {};
        for nInterID, tbInfo in pairs(tbInteractInfo) do
            if nInterID > 0 then
                local tbShowInfo = {};
                tbShowInfo.szName = tbInfo.szName or "-";
                tbShowInfo.nID = tbInfo.nInteractID;
                tbShowInfo.szType = "Interact";
                tbShowInfo.szIcon = tbInfo.szIcon;
                tbShowInfo.szIconAtlas = tbInfo.szIconAtlas;
                table.insert(self.tbAllItem, tbShowInfo);
            end
        end
    end

    local tbBQActionType = ChatMgr:GetActionBQType(pNpc.nShapeShiftNpcTID) or {};
    for _, tbInfo in pairs(tbBQActionType) do
        if tbInfo.ChatID > 0 then
            local tbShowInfo = {};
            tbShowInfo.szName = tbInfo.Name or "-";
            tbShowInfo.nID = tbInfo.ChatID;
            tbShowInfo.szType = "Normal";
            tbShowInfo.szIcon = tbInfo.Icon;
            tbShowInfo.szIconAtlas = tbInfo.IconAtlas;
            tbShowInfo.NpcType = pNpc.nShapeShiftNpcTID;
            table.insert(self.tbAllItem, tbShowInfo);
        end
    end

    local tbEquipBQ = ChatEquipBQ:GetAllEquipBQ(me)
    for _, nBQId in ipairs(tbEquipBQ) do
        local tbInfo = ChatMgr:GetActionBQInfo(ChatEquipBQ.nNpcType, nBQId)
        if tbInfo then
             local tbShowInfo = {};
            tbShowInfo.szName = tbInfo.Name or "-";
            tbShowInfo.nID = tbInfo.ChatID;
            tbShowInfo.szType = "Equip";
            tbShowInfo.szIcon = tbInfo.Icon;
            tbShowInfo.szIconAtlas = tbInfo.IconAtlas;
            tbShowInfo.NpcType = ChatEquipBQ.nNpcType;
            table.insert(self.tbAllItem, tbShowInfo);
        end
    end
    table.sort(self.tbAllItem, function (a, b)
        local nA = a.nID < b.nID and 1 or 0
        local nB = b.nID < a.nID and 1 or 0
        local nEquip = 10
        local nInteract = 5
        if a.szType == "Equip" then
            nA = nA + nEquip
        end
        if b.szType == "Equip" then 
            nB = nB + nEquip
        end
        if a.szType == "Interact" then
            nA = nA + nInteract
        end
        if b.szType == "Interact" then 
            nB = nB + nInteract
        end
        return nA > nB;
    end);

    local fnSetItem = function (tbItem, nIndex)
        local nStartIndex  = (nIndex - 1) * tbUi.nTotalSub + 1;
        local tbSubAllItem = {};
        for nI = 1, tbUi.nTotalSub, 1 do
            local nSubIndex = nStartIndex + nI - 1;
            local tbInfo = self.tbAllItem[nSubIndex];
            if tbInfo then
                table.insert(tbSubAllItem, tbInfo);
            end
        end

        tbItem.tbSubAllItem = tbSubAllItem;
        tbItem:UpdateSubItem();
    end

    local nTotalCount = #self.tbAllItem;
    self.ScrollView:Update(math.ceil(nTotalCount / tbUi.nTotalSub), fnSetItem);
end

local tbSubUi = Ui:CreateClass("ActionBQSub");
tbSubUi.tbOnClick = {};
for nI = 1, tbUi.nTotalSub, 1 do
    tbSubUi.tbOnClick["Btn"..nI] = function (self)
        local tbSubItem = self.tbSubAllItem[nI];
        if not tbSubItem then
            return;
        end

        if tbSubItem.szType == "Normal" or tbSubItem.szType == "Equip" then
            RemoteServer.SendChatBQ(tbSubItem.nID, tbSubItem.NpcType);
        else
            me.CenterMsg("请选择玩家一起"..tbSubItem.szName, true);
            local tbInfo = {};
            tbInfo.nID = tbSubItem.nID;
            tbInfo.szName = tbSubItem.szName;
            ActionInteract.tbSelfActInteract = tbInfo;
        end

        Ui:CloseWindow("ActionBQPanel");
    end
end

function tbSubUi:UpdateSubItem()
    for nI = 1, tbUi.nTotalSub, 1 do
        local tbSubItem = self.tbSubAllItem[nI];
        if tbSubItem then
            self.pPanel:SetActive("Btn"..nI, true);
            self.pPanel:Label_SetText("Label"..nI, tbSubItem.szName);
            if not Lib:IsEmptyStr(tbSubItem.szIcon) then
                self.pPanel:Sprite_SetSprite("Btn"..nI, tbSubItem.szIcon, tbSubItem.szIconAtlas);
                self.pPanel:Button_SetSprite("Btn"..nI, tbSubItem.szIcon);
            end
        else
           self.pPanel:SetActive("Btn"..nI, false);
        end
    end
end