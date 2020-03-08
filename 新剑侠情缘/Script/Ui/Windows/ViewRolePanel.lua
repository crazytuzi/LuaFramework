
local tbUi = Ui:CreateClass("ViewRolePanel");

tbUi.nTabPartner    = 1;
tbUi.nTabMiji       = 2;
tbUi.tbTabName = {
    [tbUi.nTabPartner] = "同伴";
    [tbUi.nTabMiji] = "秘籍";
}

tbUi.tbOnClick =
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    Companion1 = function (self)
        self:OnClickCompanion(1)
    end,
    Companion2 = function (self)
        self:OnClickCompanion(2)
    end,
    Companion3 = function (self)
        self:OnClickCompanion(3)
    end,
    Companion4 = function (self)
        self:OnClickCompanion(4)
    end,
    BtnCompanion = function (self)
        self.nCurShowTab = self.nTabPartner
        self:UpdateTabShow()
    end;
    BtnSecretBooks = function (self)
        self.nCurShowTab = self.nTabMiji
        self:UpdateTabShow()
    end;
    BtnMounts = function (self)
        Ui:OpenWindow("HorsePanel", self.tbEquip)
    end;
    BtnMeridian = function (self)
        local tbLearnInfo, bHasNoPartner, tbJingMaiLevelInfo = JingMai:GetLearnedXueWeiInfo(nil, self.pAsyncRole);
        local tbAddInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo);
        tbAddInfo = JingMai:CombineAddInfo(tbAddInfo, JingMai:GetJingMaiLevelAttribInfo(nil, JingMai.tbJingMaiSetting, tbJingMaiLevelInfo))
        Ui:OpenWindow("JingMaiTipsPanel", tbAddInfo.tbExtAttrib, tbAddInfo.tbSkill, bHasNoPartner, nil, tbJingMaiLevelInfo);
    end;
    BtnGuest = function (self)
        local tbAttrib = PartnerCard:GetAllActiveAttrib(nil, self.pAsyncRole, self.tbPartnerInfo)
        Ui:OpenWindow("PartnerCardAttribPanel", tbAttrib, self.pAsyncRole)
    end;
    BtnLostKnowledge = function (self)
        Ui:OpenWindow("ViewRoleJueXueTip", self.tbEquip)
    end;
}

tbUi.tbOnDrag =
{
    ShowRole = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
    end,
}


--直接查看到别的玩家数据的用ViewRole:OpenWindow 打开
function tbUi:OnOpen(tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole, tbEffectRest)
    self.pAsyncRole = pAsyncRole
    self.nFaction = pAsyncRole.GetFaction();
    self.nSex = Player:Faction2Sex(self.nFaction, pAsyncRole.GetSex());
    self.tbPartnerInfo = tbPartnerInfo
    self.tbEquip = tbEquip
    self.tbNpcRes = tbNpcRes
    local szFactionName = Faction:GetName(self.nFaction)
    local tbPlayerInfo = KPlayer.GetPlayerInitInfo(self.nFaction, self.nSex);
    self.pPanel:Label_SetText("FactionName", string.format("%s [%s]%s[-]", szFactionName, Npc.SeriesColor[tbPlayerInfo.nSeries], Npc.Series[tbPlayerInfo.nSeries]) )
    local SpFaction = Faction:GetIcon(self.nFaction)
    self.pPanel:Sprite_SetSprite("Faction", SpFaction)
    local nHonorLevel = pAsyncRole.GetHonorLevel();
    local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
    if ImgPrefix then
        self.pPanel:SetActive("PlayerHonor", true)
        self.pPanel:Sprite_Animation("PlayerHonor", ImgPrefix, Atlas);
    else
        self.pPanel:SetActive("PlayerHonor", false)
    end
    local tbRoleInfo = pAsyncRole.tbRoleInfo
    local nBgId = pAsyncRole.GetWaiyiBgId()
    nBgId = nBgId == 0 and 1 or nBgId
    local tbInfo = Item.tbChangeColor:GetWaiyiBgSetting()[nBgId];
    local nShowEffectId;
    if tbInfo then
        self.pPanel:Texture_SetTexture("rightbg", tbInfo.ViewBgTexture);
        if tbInfo.EffectIdView > 0 then
            nShowEffectId = tbInfo.EffectIdView
        end
    end
    if nShowEffectId then
        self.pPanel:ShowEffect("rightbg", nShowEffectId, 1)
    else
        self.pPanel:HideEffect("rightbg")
    end

    self.pPanel:Label_SetText("kinName", tbRoleInfo and tbRoleInfo.szKinName or "");
    local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbRoleInfo.nBigFace, tbRoleInfo.nPortrait, 
        tbRoleInfo.nFaction, tbRoleInfo.nSex);
    local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace)
    self.pPanel:Sprite_SetSprite("Rolehead", szBigIcon, szBigIconAtlas)

    local tbTitleInfo = tbRoleInfo and tbRoleInfo.tbTitleInfo
    if tbTitleInfo then
        local nTitleId, szTitleStr = unpack(tbTitleInfo)
        if nTitleId == 0 and Lib:IsEmptyStr(szTitleStr)  then
            tbTitleInfo = nil
        end
    end
    if tbTitleInfo then
        self.pPanel:SetActive("Title", true)
        local nTitleId, szTitleStr = unpack(tbTitleInfo)
        local tbCurTemp = PlayerTitle:GetTitleTemplate(nTitleId);
        if Lib:IsEmptyStr(szTitleStr) then
            szTitleStr = tbCurTemp.Name
        end
        self.pPanel:Label_SetText("Title", szTitleStr);
        local RepresentSetting = Ui.RepresentSetting
        local MainColor = RepresentSetting.GetColorSet(tbCurTemp.ColorID);
        self.pPanel:Label_SetColor("Title", MainColor.r * 255, MainColor.g * 255, MainColor.b * 255);
        if tbCurTemp.GTopColorID > 0 and tbCurTemp.GBottomColorID > 0 then
            local GTopColor = RepresentSetting.GetColorSet(tbCurTemp.GTopColorID);
            local GTBottomColor = RepresentSetting.GetColorSet(tbCurTemp.GBottomColorID);
            self.pPanel:Label_SetGradientByColor("Title", GTopColor, GTBottomColor);
        else
            self.pPanel:Label_SetGradientActive("Title", false);
        end
        local ColorOuline = RepresentSetting.CreateColor(0.0, 0.0, 0.0, 1.0);
        if tbCurTemp.OutlineColorID > 0 then
            ColorOuline = RepresentSetting.GetColorSet(tbCurTemp.OutlineColorID);
        end
        self.pPanel:Label_SetOutlineColor("Title", ColorOuline);

    else
        self.pPanel:SetActive("Title", false)
    end

    local szRoleName = pAsyncRole.szName
    if tbRoleInfo then
        local szRemmarkName = FriendShip:GetRemarkName(tbRoleInfo.dwID)
        if not Lib:IsEmptyStr(szRemmarkName) then
            szRoleName = string.format("%s（%s）", szRoleName, szRemmarkName)
        end
    end
    self.pPanel:Label_SetText("szName", szRoleName)
    self.pPanel:Label_SetText("lbLevel", pAsyncRole.GetLevel())
    self.pPanel:Label_SetText("lbHP", pAsyncRole.GetMaxHp())
    self.pPanel:Label_SetText("lbAttack", pAsyncRole.GetBaseDamage())
    self.pPanel:Label_SetText("lbFight", pAsyncRole.GetFightPower())

    local tbRoleAttribs = {
        {
            "Vitality", "TiZhi", "lbTiZHi"
        },
        {
            "Strength", "LiLiang", "lbLiLiang"
        },
        {
            "Energy", "LingQiao", "lbLingQiao"
        },
        {
            "Dexterity", "MinJie", "lbMinJie"
        }
    };
    for i,v in ipairs(tbRoleAttribs) do
        local szType, szWidget,szLabel = unpack(v);
        local nVal = pAsyncRole["Get" .. szType]()
        if nVal > 0 then
            self.pPanel:SetActive(szWidget, true)
            self.pPanel:Label_SetText(szLabel, nVal)
        else
            self.pPanel:SetActive(szWidget, false)
        end
    end

    self:UpdateEquip();

    local nFactionID = pAsyncRole.GetFaction();
    local nOldFaction = self.nFactionID;
    self.nFactionID = nFactionID
    local nSex = Player:Faction2Sex(nFactionID, pAsyncRole.GetSex())

    self.pPanel:NpcView_Open("ShowRole", nFactionID or me.nFaction, nSex);
    --TODO delete 
    if nOldFaction ~= nFactionID then
        local nFeatureId = self.pPanel:NpcView_GetFeatureNodeId("ShowRole")
        local tbFea = Ui.NpcViewMgr.GetFeatureNode(nFeatureId)
        if tbFea and tbFea.m_NpcFeature then
            tbFea.m_NpcFeature.m_byActionModeFlag = 0;
        end
    end

    self.pPanel:NpcView_UseDynamicBone("ShowRole", true);
    self.pPanel:NpcView_SetScale("ShowRole", 0.9);

    self:ChangeFeature(tbNpcRes, tbEffectRest);

    self.pPanel:SetActive("BtnGuest", PartnerCard:IsOpen())
    self.pPanel:SetActive("BtnLostKnowledge", JueXue:CheckShowTab())
    self.pPanel:SetActive("BtnMeridian", TimeFrame:GetTimeFrameState(JingMai.szOpenTimeFrame) == 1)
    self.pPanel:SetActive("BtnSecretBooks", TimeFrame:GetTimeFrameState("OpenLevel49") == 1)
    self.pPanel:SetActive("BtnCompanion", TimeFrame:GetTimeFrameState("OpenLevel49") == 1)

    if not self.nCurShowTab then
        self.nCurShowTab = self.nTabPartner
    end
    self:UpdateTabShow();
end


function tbUi:UpdateTabShow()
    local szTabName = self.tbTabName[self.nCurShowTab]
    if szTabName then
        self.pPanel:Label_SetText("TabTitle", szTabName)
    end
    if self.nCurShowTab == self.nTabMiji then
        self:UpdateMijiInfo();
    elseif self.nCurShowTab == self.nTabHorseEquip then
        self:UpdateHorseEquip();
    else
        self:UpdatePartnerInfo()
    end
end

function tbUi:OnClose()
    self.pPanel:NpcView_Close("ShowRole")
end

function tbUi:UpdateEquip()
    local tbEquip = self.tbEquip
    local tbStrengthen = self.pAsyncRole.GetStrengthen();

    for i = 0, Item.EQUIPPOS_MAIN_NUM  - 1 do
        local tbEquipGrid = self["Equip"..i]

        tbEquipGrid.nEquipPos = i;
        tbEquipGrid.nFaction = self.nFaction
        tbEquipGrid.szItemOpt = "PlayerEquip";
        tbEquipGrid.pAsyncRole = self.pAsyncRole
        tbEquipGrid.fnClick = tbEquipGrid.DefaultClick;
        if i == Item.EQUIPPOS_RING and tbEquip[i] then
        	local pItem = KItem.GetItemObj(tbEquip[i])
        	if pItem and pItem.GetStrValue(1) then
        		tbEquipGrid.szFragmentSprite = "MarriedMark";
        		tbEquipGrid.szFragmentAtlas = "UI/Atlas/NewAtlas/Panel/NewPanel.prefab";
        	else
        		tbEquipGrid.szFragmentSprite = nil;
        		tbEquipGrid.szFragmentAtlas = nil;
        	end
        end
        tbEquipGrid:SetItem(tbEquip[i], nil, self.nFaction, self.nSex)
        local nStrength = tbStrengthen[i + 1]
        if tbEquip[i] and nStrength > 0 then
            self.pPanel:SetActive("StrengthenLevel" .. i, true)
            self.pPanel:Label_SetText("StrengthenLevel" .. i, "+" .. nStrength)
        else
            self.pPanel:SetActive("StrengthenLevel" .. i, false)
        end
    end

    if GetTimeFrameState(Item.tbPiFeng.OPEN_TIME_FRAME) == 1 then
        self.pPanel:SetActive("PiFeng", true)
        self.pPanel:SetActive("CloakFashion", true)

        local tbPos = {Item.EQUIPPOS_BACK2, Item.EQUIPPOS_WAI_BACK2};
        for i,nPos in ipairs(tbPos) do
            local tbEqipGrid = self["Equip"..nPos]
            local nItemId = tbEquip[nPos]
            if nItemId then
                tbEqipGrid.nEquipPos = nPos;
                tbEqipGrid.pAsyncRole = self.pAsyncRole
                tbEqipGrid.szItemOpt = "PlayerEquip";
                tbEqipGrid:SetItem(nItemId, nil, self.nFaction, self.nSex)
                tbEqipGrid.fnClick = tbEqipGrid.DefaultClick
                self.pPanel:SetActive("FashionTitle" .. nPos, false)
            else
                tbEqipGrid:Clear()
                self.pPanel:SetActive("FashionTitle" .. nPos, true)
            end    
        end
     
    else
        self.pPanel:SetActive("PiFeng", false)
        self.pPanel:SetActive("CloakFashion", false)
    end
    

    local tbWayyiPos = {Item.EQUIPPOS_WAIYI, Item.EQUIPPOS_WAI_WEAPON, Item.EQUIPPOS_WAI_HEAD, Item.EQUIPPOS_WAI_BACK, Item.EQUIPPOS_WAI_HORSE};
    for _, nEquipPos in ipairs(tbWayyiPos) do
        local tbEqiptWaiyi = self["Equip"..nEquipPos]
        if tbEquip[nEquipPos] then
            self.pPanel:SetActive("FashionTitle" .. nEquipPos, false)
            tbEqiptWaiyi.nEquipPos = nEquipPos;
            tbEqiptWaiyi.szItemOpt = "PlayerEquip"
            tbEqiptWaiyi:SetItem(tbEquip[nEquipPos], nil, self.nFaction, self.nSex)
            tbEqiptWaiyi.fnClick = function (itemObj)
                local pItem = KItem.GetItemObj(itemObj.nItemId);
                if pItem then
                    if nEquipPos == Item.EQUIPPOS_WAI_HORSE then
                        Ui:OpenWindow("WaiyiPreview", pItem.dwTemplateId,self.nFaction, self.nSex)
                    else
                        Ui:OpenWindow("ItemTips", "Item", nil, pItem.dwTemplateId, self.nFaction, self.nSex);    
                    end
                end
            end;
        else
            self.pPanel:SetActive("FashionTitle" .. nEquipPos, true)
            tbEqiptWaiyi:Clear();
        end
    end


    if GetTimeFrameState(Item.tbZhenYuan.szOpenTimeFrame) == 1 then
        self.pPanel:SetActive("Vitality", true)
        local tbEquipZhenYuan = self["Equip"..Item.EQUIPPOS_ZHEN_YUAN]
        if tbEquip[Item.EQUIPPOS_ZHEN_YUAN] then
            tbEquipZhenYuan.szItemOpt = "PlayerEquip";
            tbEquipZhenYuan.nEquipPos = Item.EQUIPPOS_ZHEN_YUAN;
            tbEquipZhenYuan:SetItem(tbEquip[Item.EQUIPPOS_ZHEN_YUAN])
            tbEquipZhenYuan.fnClick = tbEquipZhenYuan.DefaultClick;
            self.pPanel:SetActive("FashionTitle" .. Item.EQUIPPOS_ZHEN_YUAN, false)
        else
            self.pPanel:SetActive("FashionTitle" .. Item.EQUIPPOS_ZHEN_YUAN, true)
            tbEquipZhenYuan:Clear()
        end
    else
        self.pPanel:SetActive("Vitality", false)
    end

end

function tbUi:ChangeFeature(tbNpcRes, tbEffectRest)
    local tbCopyNpcRes = Lib:CopyTB(tbNpcRes);
    for nI = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
        if not tbCopyNpcRes[nI] then
            tbCopyNpcRes[nI] = 0;
        end
    end
    tbCopyNpcRes[Npc.NpcResPartsDef.npc_part_horse] = 0

    for nPartId, nResId in pairs(tbCopyNpcRes) do
        self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nResId);
    end

    tbEffectRest = tbEffectRest or {};
    for nPartId, nResId in pairs(tbEffectRest) do
        self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId);
    end
end

function tbUi:UpdatePartnerInfo()
    self.pPanel:SetActive("Companion", true)
    self.pPanel:SetActive("Item", false)
    local tbPartnerInfo = self.tbPartnerInfo
    for i = 1, 4 do
        local tbOneData = tbPartnerInfo[i]
        if tbOneData then
            self["Face" .. i]:SetPartnerInfo(tbOneData.tbPartnerInfo);
            self.pPanel:SetActive("Face" .. i, true);
            self.pPanel:SetActive("num" .. i, false)
        else
            self.pPanel:Sprite_SetSprite("Companion" .. i, "CompanionHeadBg_None");
            self.pPanel:SetActive("Face" .. i, false);
            self.pPanel:SetActive("num" .. i, true)
        end
    end

end

function tbUi:UpdateMijiInfo()
    self.pPanel:SetActive("Companion", false)
    self.pPanel:SetActive("Item", true)

    local tbBook = Item:GetClass("SkillBook");
    for i = 1, 4 do
        local nItemId = self.tbEquip[Item.EQUIPPOS_SKILL_BOOK + i - 1]
        local tbGrid = self["Item0" .. i]
        if nItemId and nItemId > 0 then
            --使用模板，加 tbIntValueInfo
            local pItem = KItem.GetItemObj(nItemId)
            if pItem then
                tbGrid.pAsyncRole = self.pAsyncRole
                tbGrid.nPosIndex = Item.EQUIPPOS_SKILL_BOOK + i - 1;
                tbGrid:SetItem(nItemId, nil, self.nFaction, self.nSex)
                tbGrid.fnClick = tbGrid.DefaultClick;
            end
        else
            tbGrid:Clear();
        end
    end
end

function tbUi:UpdateHorseEquip()
    self.pPanel:SetActive("Companion", false)
    self.pPanel:SetActive("Item", true)

    local tbPoses = {Item.EQUIPPOS_REIN, Item.EQUIPPOS_SADDLE, Item.EQUIPPOS_PEDAL };
    for i=1,4 do
        local tbGrid = self["Item0" .. i]
        local nPos = tbPoses[i]
        if nPos and self.tbEquip[nPos] then
            tbGrid:SetItem(self.tbEquip[nPos]);
            tbGrid.fnClick = tbGrid.DefaultClick;
        else
           tbGrid:Clear();
        end
    end
end

function tbUi:OnClickCompanion(nIndex)
    local tbInfo = self.tbPartnerInfo[nIndex]
    if not tbInfo then
        return
    end
   
    local tbLearnInfo = JingMai:GetLearnedXueWeiInfo(nil, self.pAsyncRole);
    local tbAllAddAttribInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo);
    local tbPartnerAttribInfo = JingMai:MgrPartnerAttrib(tbInfo.tbPartnerAttribInfo, JingMai:GetAttribInfo(tbAllAddAttribInfo.tbExtPartnerAttrib));
    local tbExtSkillId = PartnerCard:GetActiveSkillIdByPTId(nil, self.pAsyncRole, tbInfo.tbPartnerInfo.nTemplateId)
    Ui:OpenWindow("PartnerDetail", tbInfo.tbPartnerInfo, tbPartnerAttribInfo, tbInfo.tbPartnnerSkillInfo, nil, nil, tbAllAddAttribInfo, tbExtSkillId);
end


