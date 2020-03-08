local tbUi = Ui:CreateClass("QixiSendGiftPanel")

function tbUi:OnOpen(nItemTemplateId)
    if not nItemTemplateId then
        return 0
    end
    if not TeamMgr:HasTeam() then
        me.CenterMsg("没有队伍")
        return 0
    end

    local tbMember = TeamMgr:GetTeamMember()
    if #tbMember <= 0 then
        me.CenterMsg("没有可赠送队友")
        return 0
    end
end

function tbUi:OnOpenEnd(nItemTemplateId)
    self.tbMemberId = {}
    self.nItemTemplateId = nItemTemplateId
    local tbMember = TeamMgr:GetTeamMember()
    local nMemNum = #tbMember
    for i = 1, 3 do
        self.pPanel:SetActive("TargeItem" .. i, nMemNum >= i)
        self.pPanel:SetActive("BtnGive" .. i, nMemNum >= i)
        local tbMemberData = tbMember[i]
        if tbMemberData then
            self["TargeItem" .. i].pPanel:Label_SetText("Name", tbMemberData.szName)
            self["TargeItem" .. i].pPanel:Label_SetText("lbLevel", tbMemberData.nLevel)
            local szFactionIcon = Faction:GetIcon(tbMemberData.nFaction)
            local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbMemberData.nPortrait)
            self["TargeItem" .. i].pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
            self["TargeItem" .. i].pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
            table.insert(self.tbMemberId, tbMemberData.nPlayerID)
        end
    end
    self.pPanel:Widget_SetSize("Bg", 254, 290*(nMemNum/3))
    self.pPanel:ChangeBoxColliderSize("Main", 254, 290*(nMemNum/3))
    if nMemNum == 1 then
        self.pPanel:ChangePosition("TargeItem1", 0, 0)
        self.pPanel:ChangePosition("Bg", 0, 47)
    else
        self.pPanel:ChangePosition("TargeItem1", 0, 94)
        self.pPanel:ChangePosition("TargeItem2", 0, 0)
        self.pPanel:ChangePosition("Bg", 0, 145)
    end
end

function tbUi:OnScreenClick()
    Ui:CloseWindow("QixiSendGiftPanel")
end

function tbUi:TrySend(nMemberIdx)
    if self.tbMemberId[nMemberIdx] then
        RemoteServer.TrySendQixiGift(self.tbMemberId[nMemberIdx], self.nItemTemplateId)
    end
end

tbUi.tbOnClick = {}
for i = 1, 3 do
    tbUi.tbOnClick["BtnGive" .. i] = function (self)
        self:TrySend(i)
    end
end