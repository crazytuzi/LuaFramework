local tbUi = Ui:CreateClass("ZhenYuanChosePanel")

function tbUi:OnOpen( nTarItemId )
    local pTarEquip = me.GetItemInBag(nTarItemId)
    if not pTarEquip then
        return 0
    end
    local pCurEquip = me.GetEquipByPos(pTarEquip.nEquipPos)
    if not pCurEquip then
        return 0;
    end
    local nSkillInfo1 = pCurEquip.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo)
    local nSkillInfo2 = pTarEquip.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo)
    if nSkillInfo1 == 0 or nSkillInfo2 == 0 then
        me.CenterMsg("不需要选择方案")
        return 0
    end
    local nSkillId1, nSkillLevel1 = Item.tbRefinement:SaveDataToAttrib(nSkillInfo1)
    local nSkillId2, nSkillLevel2 = Item.tbRefinement:SaveDataToAttrib(nSkillInfo2)
    local nSkillMaxLevel1 = Item.tbZhenYuan:GetEquipMaxSkillLevel(pCurEquip.nLevel)
    local nSkillMaxLevel2 = Item.tbZhenYuan:GetEquipMaxSkillLevel(pTarEquip.nLevel)
    local tbMaxLevel = {nSkillMaxLevel1, nSkillMaxLevel2};
    
    local tbGroups = {};
    self.tbGroups = tbGroups
    self.tbTypeDesc = {};
    self.nTarItemId = nTarItemId
    if nSkillId1 ~= nSkillId2 then
        table.insert(tbGroups, {
                {nSkillId2, nSkillLevel1};
                {nSkillId1, nSkillLevel2};
            })
        self.tbTypeDesc[#tbGroups] = "OnlySkillId";

    end
    if nSkillLevel1 ~= nSkillLevel2 then
        table.insert(tbGroups, {
            {nSkillId1, nSkillLevel2};
            {nSkillId2, nSkillLevel1};
        })
        self.tbTypeDesc[#tbGroups] = "OnlySkillLevel";
    end
    if nSkillId1 ~= nSkillId2 and nSkillLevel1 ~= nSkillLevel2 then
        table.insert(tbGroups, {
            {nSkillId2, nSkillLevel2};
            {nSkillId1, nSkillLevel1};
        })
        self.tbTypeDesc[#tbGroups] = "BothSkillAndLevel";
    end

    local tbCurInfo = {
        {nSkillId1,nSkillLevel1};
        {nSkillId2,nSkillLevel2 };
    }
    for i,v in ipairs(tbCurInfo) do
        local nSkillId,nSkillLevel = unpack(v)
        local nSkillMaxLevel = tbMaxLevel[i]
        local tbIcon, szSkillName = FightSkill:GetSkillShowInfo(nSkillId);
        self.CurrentPlan.pPanel:Sprite_SetSprite("CurrentPlanSkill" .. i, tbIcon.szIconSprite, tbIcon.szIconAtlas)
        self.CurrentPlan.pPanel:Label_SetText("CurrentPlanName" ..i, szSkillName)
        self.CurrentPlan.pPanel:Label_SetText("CurrentPlanGrade"..i, string.format("等级：%d/%d", nSkillLevel, nSkillMaxLevel))
    end
    local tbHeightBg1 = {
        [1] = 334;
        [2] = 439;
        [3] = 549;
    }
    local tbHeightBg2 = {
        [1] = 256;
        [2] = 358;
        [3] = 466;
    }
    self.pPanel:Widget_SetSize("Bg1", 850, tbHeightBg1[#tbGroups])
    self.pPanel:Widget_SetSize("Bg2", 746, tbHeightBg2[#tbGroups])
    local tbColName = { "One", "Two", "Three" };
    for i=1,3 do
        local tbGroupInfo = tbGroups[i]
        if tbGroupInfo then
            self.pPanel:SetActive("Scheme" .. i, true)
            for i2,v2 in ipairs(tbGroupInfo) do
                local nSkillId, nSkillLevel = unpack(v2)
                local nSkillMaxLevel = tbMaxLevel[i2]
                local tbIcon, szSkillName = FightSkill:GetSkillShowInfo(nSkillId);
                local Scheme = self["Scheme" .. i]
                Scheme.pPanel:Sprite_SetSprite("SchemeSkill" .. i .. i2, tbIcon.szIconSprite, tbIcon.szIconAtlas)
                Scheme.pPanel:Label_SetText("SchemeName" .. i .. i2, szSkillName)
                Scheme.pPanel:Label_SetText("SchemeGrade".. i .. i2, string.format("等级：%d/%d", nSkillLevel, nSkillMaxLevel))         
            end
        else
            self.pPanel:SetActive("Scheme" .. i, false)
        end
    end
end

function tbUi:OnClickChoose( index )
    local szDesc = self.tbTypeDesc[index]
    assert(szDesc)

    local tbGroupInfo = self.tbGroups[index]
    local nSkillId1, nSkillLevel1 = unpack(tbGroupInfo[1])
    local nSkillId2, nSkillLevel2 = unpack(tbGroupInfo[2])
    local szMoneyType, nMoney = Item.tbZhenYuan:GetRefineSkillCost(nSkillLevel2)
    local szMoneyName = Shop:GetMoneyName(szMoneyType)
    local szMoneyUseDesc = string.format("%d%s", nMoney, szMoneyName)
    
    local szMsg;
    local _, szSkillName1 = FightSkill:GetSkillShowInfo(nSkillId1);
    local _, szSkillName2 = FightSkill:GetSkillShowInfo(nSkillId2);
    if szDesc == "OnlySkillId" then
        szMsg = string.format("您确定要花费[FFFE0D]%s[-]将已装备的真元上的技能[FFFE0D]%s[-]，替换为[FFFE0D]%s[-]吗？（替换后，技能等级将保持不变）",szMoneyUseDesc, szSkillName2,szSkillName1)
    elseif szDesc == "OnlySkillLevel" then
        szMsg = string.format("您确定要花费[FFFE0D]%s[-]将已装备的真元上的[FFFE0D]等级：%s[-]，替换为[FFFE0D]等级：%s[-]吗？（替换后，技能种类将保持不变）",szMoneyUseDesc, nSkillLevel2,nSkillLevel1)
    else
        szMsg = string.format("您确定要花费[FFFE0D]%s[-]将已装备的真元上的[FFFE0D]%s 等级：%s[-]，替换为[FFFE0D]%s 等级：%s[-]吗？",szMoneyUseDesc, szSkillName2, nSkillLevel2, szSkillName1, nSkillLevel1)
    end
    local fnAgree = function ()
        Ui:CloseWindow(self.UI_NAME)
        Ui:CloseWindow("EquipTips")
        RemoteServer.ZhenYuanRefineSkill(self.nTarItemId, szDesc)
    end
    me.MsgBox(szMsg, {{"同意", fnAgree}, {"取消"}}) 

end

tbUi.tbOnClick = {};
for i=1,3 do
    tbUi.tbOnClick["Scheme" .. i] = function (self)
        self:OnClickChoose(i)
    end
end

function tbUi.tbOnClick:BtnClose(  )
    Ui:CloseWindow(self.UI_NAME)
end