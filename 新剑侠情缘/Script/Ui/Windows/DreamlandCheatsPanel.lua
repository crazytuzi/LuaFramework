
local tbUi = Ui:CreateClass("DreamlandCheatsPanel");

tbUi.tbOnClick =
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

tbUi.tbOnDrag =
{
    ShowRole = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
    end,
}


function tbUi:OnOpen()
    self.nFaction = me.nFaction;
    local SpFaction = Faction:GetIcon(self.nFaction)
    self.pPanel:Sprite_SetSprite("Faction", SpFaction)
    local nHonorLevel = me.nHonorLevel;
    local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
    if ImgPrefix then
        self.pPanel:SetActive("PlayerTitle", true)
        self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);            
    else
        self.pPanel:SetActive("PlayerTitle", false)
    end
    local szKinName = ""
    local tbBaseInfo = Kin:GetBaseInfo()
    if tbBaseInfo then
        szKinName = tbBaseInfo.szName
    end
    self.pPanel:Label_SetText("kinName", szKinName);

    self.pPanel:Label_SetText("szName", me.szName)
    self.pPanel:Label_SetText("lbLevel", me.nLevel)
    self.pPanel:Label_SetText("lbHP", me.GetNpc().nMaxLife)
    local nMinDamage,_ = me.GetBaseDamage()
    self.pPanel:Label_SetText("lbAttack", nMinDamage)
    self.pPanel:Label_SetText("lbFight", me.GetNpc().GetFightPower())

    self:UpdateEquip();

    self.pPanel:NpcView_Open("ShowRole", self.nFaction or me.nFaction, me.nSex);
    self:ChangeFeature();

    self:UpdatePublicMiJi();

end

function tbUi:OnClose()
    self.pPanel:NpcView_Close("ShowRole")
end

function tbUi:UpdateEquip()
    local tbEquip = me.GetEquips(1)
    local fnOnClickEquip = function (itemObj)
        Ui:OpenWindow("EquipTips", itemObj.nItemId)
    end

    for i = 0, Item.EQUIPPOS_MAIN_NUM  - 1 do
        local tbEqiptGrid = self["Equip"..i]

        tbEqiptGrid.nEquipPos = i;
        tbEqiptGrid.szItemOpt = "PlayerEquip"
        tbEqiptGrid.fnClick = fnOnClickEquip;
        tbEqiptGrid:SetItem(tbEquip[i], nil, self.nFaction)
        local nStrength = Strengthen:GetStrengthenLevel(me, i);
        if tbEquip[i] and nStrength > 0 then
            self.pPanel:SetActive("StrengthenLevel" .. i, true)
            self.pPanel:Label_SetText("StrengthenLevel" .. i, "+" .. nStrength)
        else
            self.pPanel:SetActive("StrengthenLevel" .. i, false) 
        end
    end

    local tbEqiptHorse = self["Equip"..Item.EQUIPPOS_HORSE]
    local nItemId = tbEquip[Item.EQUIPPOS_HORSE]
    if nItemId then
        tbEqiptHorse.nEquipPos = Item.EQUIPPOS_HORSE;
        tbEqiptHorse.szItemOpt = "PlayerEquip"
        tbEqiptHorse:SetItem(nItemId, nil, self.nFaction)
        tbEqiptHorse.fnClick = function (itemObj)
            Ui:OpenWindow("EquipTips", itemObj.nItemId, nil,  self.nFaction)
        end
        tbEqiptHorse.pPanel:SetActive("Main", true)
    else
        tbEqiptHorse.pPanel:SetActive("Main", false)
    end
    
    local tbEqiptWaiyi = self["Equip"..Item.EQUIPPOS_WAIYI]
    if tbEquip[Item.EQUIPPOS_WAIYI] then
        tbEqiptWaiyi.nEquipPos = Item.EQUIPPOS_WAIYI;
        tbEqiptWaiyi.szItemOpt = "PlayerEquip"
        tbEqiptWaiyi:SetItem(tbEquip[Item.EQUIPPOS_WAIYI], nil, self.nFaction)
        tbEqiptWaiyi.fnClick = function (itemObj)
            local pItem = KItem.GetItemObj(itemObj.nItemId);
            if pItem then
                Ui:OpenWindow("ItemTips", "Item", nil, pItem.dwTemplateId, self.nFaction);
            end
        end;
        
        tbEqiptWaiyi.pPanel:SetActive("Main", true)
    else
        tbEqiptWaiyi.pPanel:SetActive("Main", false)
    end
end

function tbUi:ChangeFeature()
    local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
    local tbFactionScale = {0.92, 1, 1.15, 1}   -- 贴图缩放比例
    local fScale = tbFactionScale[me.nFaction] or 1
    for nPartId, nResId in pairs(tbNpcRes) do
        local nCurResId = nResId
        if nPartId == Npc.NpcResPartsDef.npc_part_horse then
            nCurResId = 0;
        end

        self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId);
    end

    for nPartId, nResId in pairs(tbEffectRes) do
        self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId);
    end

    self.pPanel:NpcView_SetScale("ShowRole", fScale);
end

function tbUi:UpdatePublicMiJi()
    local tbSkillBook = Item:GetClass("SkillBook");
    for nIndex, nNeedLevel in ipairs(tbSkillBook.tbSkillBookHoleLevel) do
        local pEquip = me.GetEquipByPos(nIndex + Item.EQUIPPOS_SKILL_BOOK - 1);
        local tbItem = self["item" .. nIndex]
        tbItem.fnClick = nil;
        tbItem:Clear();
        if pEquip then
            tbItem:SetItem(pEquip.dwId);
            tbItem.fnClick = tbItem.DefaultClick;
        end 
    end

end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_ITEM,                  self.UpdatePublicMiJi},
    };

    return tbRegEvent;
end
