local tbUi = Ui:CreateClass("PlayerLevelUp")
local tbTip = {
--    [10] = {{"IconSprite", "10级可以使用公聊和大家说话啦！"}},
--    [20] = {{"IconSprite", "Content1"}},
 --   [40] = {{"IconSprite", "10级可以使用公聊和大家说话啦！"}},
}

local function GetNewSkill(nLevel)
    local tbSkillSetting = FightSkill:GetFactionSkill(me.nFaction)
    for _, tbInfo in pairs(tbSkillSetting) do
        if tbInfo.GainLevel == nLevel then
            return tbInfo.SkillId
        end
    end
end

function tbUi:OnOpenEnd()
    self.tbBgSize = self.tbBgSize or self.pPanel:Widget_GetSize("Bg")
    self.nSkillH  = self.nSkillH or self.pPanel:Widget_GetSize("Skill").y
    self.nTipH    = self.nTipH or self.pPanel:Widget_GetSize("Tip1").y
    
    self.pPanel:SetActive("Main", false)
    if Map:GetMapType(me.nMapTemplateId) == Map.emMap_Fuben then
        return
    end

    self:PlayAni()
end

function tbUi:ShowMe()
    if self.pPanel:IsActive("Main") then
        return
    end

    self:PlayAni()
end

function tbUi:PlayAni()
    Ui:OpenWindow("LevelUpPopup", "shengji")

    local nMapId, nX, nY = me.GetWorldPos()
    Ui:PlayEffect(9120, nX, nY, 0)

    Timer:Register(Env.GAME_FPS * 1.5, self.BeginShowMe, self);
end

function tbUi:BeginShowMe()
    self.pPanel:SetActive("Main", true)
    self.pPanel:PlayUiAnimation("NormalOpen", false, false, {})
    self:Update()
end

function tbUi:Update()
    local tbOldAtt  = KPlayer.GetLevelFactionPotency(me.nFaction, me.nLevel - 1)
    local tbNewAtt  = KPlayer.GetLevelFactionPotency(me.nFaction, me.nLevel)
    local tbAttName = { "Vitality", "Strength", "Dexterity", "Energy" }
    for _, szName in pairs(tbAttName) do
        local szAttKey = "n" .. szName
        local nAddition = tbNewAtt[szAttKey] - tbOldAtt[szAttKey]
        self.pPanel:Label_SetText("From" .. szName, me[szAttKey] - nAddition)
        self.pPanel:Label_SetText("To" .. szName, me[szAttKey])
        self.pPanel:Label_SetText("Addition" .. szName, string.format("(+%d)", nAddition))
    end

    local nNewSkill = GetNewSkill(me.nLevel)
    local nSkillH = 0
    self.pPanel:SetActive("Skill", nNewSkill and true or false)
    if nNewSkill then
        local tbSkill = FightSkill:GetSkillSetting(nNewSkill)
        self.pPanel:Label_SetText("SkillName", "[新技能]" .. tbSkill.SkillName)
        self.pPanel:Label_SetText("SkillContent", tbSkill.Desc)
        self.pPanel:Sprite_SetSprite("SkillIcon", tbSkill.Icon, tbSkill.IconAtlas)
        nSkillH = self.nSkillH
    end

    local tbLevelTip = tbTip[me.nLevel] or {}
    local nTipH      = self.nTipH * (#tbLevelTip)
    local nHeight    = self.tbBgSize.y + nSkillH + nTipH
    self.pPanel:Widget_SetSize("Bg", self.tbBgSize.x, nHeight)
    self.pPanel:ChangeBoxColliderSize("Main", self.tbBgSize.x, nHeight)

    Timer:Register(1, function ()
        local nTipOriY = self.pPanel:GetPosition("Information").y - self.pPanel:Widget_GetSize("Information").y/2
        self.pPanel:ChangePosition("Tip1", 0, nTipOriY - nSkillH - self.nTipH/2 - 8)
        
        for i, tbInfo in ipairs(tbLevelTip) do
            local szTip    = "Tip" .. i
            self.pPanel:SetActive(szTip, true)
            self.pPanel:Label_SetText(szTip .. "Label", tbInfo[2])
            self.pPanel:Sprite_SetSprite(szTip .. "Icon", tbInfo[1])
        end
        for i = #tbLevelTip + 1, 2 do
            self.pPanel:SetActive("Tip" .. i, false)
        end
    end)
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_MAP_LOADED, self.ShowMe, self },
    };

    return tbRegEvent;
end