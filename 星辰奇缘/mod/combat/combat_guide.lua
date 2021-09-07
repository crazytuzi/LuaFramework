CombatGuideAction = CombatGuideAction or BaseClass(CombatBaseAction)

function CombatGuideAction:__init(mainPanel, args)
    self.mainPanel = mainPanel
    self.guidepanel = self.mainPanel.transform:Find("GuidePanel")
    self.skillPanel = self.mainPanel.skillareaPanel
    self.combatCamera = self.mainPanel.controller.combatCamera
    self.type = args.type
    self.args = args
    self.effectOffset = Vector3(-4.5,2, -100)
end

function CombatGuideAction:Play()
    if self.type == "RoleSkill" then
        LuaTimer.Add(1, function()
        self:GuideSkill("Role")
            -- body
        end)
    elseif self.type == "SkillTarget" then
        self:GuideTarget(self.args.frometype, self.args.name, self.args.msg)
    elseif self.type == "PetSkill" then
        self:GuideSkill("Pet")
    elseif self.type == "Auto" then
        self:GuideAuto()
    elseif self.type == "Catch" then
        self:GuideFuncBtn("Catch")
    elseif self.type == "CancelAuto" then
        self:GuideCancelAuto()
    else
        print("未知的指引")
    end
end


function CombatGuideAction:GuideSkill(type)
    local skillid
    local target
    local btn = nil
    if type == "Role" then
        btn = self:CreatButton("20103")
        skillid = CombatUtil.GetFirstSkill(RoleManager.Instance.RoleData.classes)
        target = self.skillPanel.skillDict[skillid]
        btn.position = target.icon.transform.position
        btn:GetComponent(RectTransform).anchoredPosition = btn:GetComponent(RectTransform).anchoredPosition + Vector2(32, -32)
    else
        skillid = 1000
        target = self.skillPanel.skillDict[skillid]
        btn = self:CreatButton("20103")
        btn.position = target.icon.transform.position
        btn:GetComponent(RectTransform).anchoredPosition = btn:GetComponent(RectTransform).anchoredPosition + Vector2(32, -32)
        -- self:OpenGuide()
        -- self:OnActionEnd()
        -- self.skillPanel:OnSkillIconClick(skillid, target.lev)
    end
    -- local sp = CombatUtil.WorldToUIPoint(self.combatCamera, target.icon.transform.position)
    btn:GetComponent(Button).onClick:AddListener(function()
        self.skillPanel:OnSkillIconClick(skillid, target.lev)
        -- self:OpenGuide()
        self:OnActionEnd()
        end)
    TipsManager.Instance:ShowGuide({gameObject = btn.gameObject, data = TI18N("点这里<color='#ffff00'>选择技能</color>"), forward = TipsEumn.Forward.Left})
    self:OpenGuide()
end

function CombatGuideAction:GuideTarget(frometype, name, msg)
    local fctr = self.mainPanel.controller.brocastCtx:FindFighterByName(name)
    if fctr == nil then
        print("找不到指引目标")
        self:OnActionEnd()
        return
    end
    local sp = CombatUtil.WorldToUIPoint(self.combatCamera, fctr.transform.position)
    self.effectOffset = Vector3.zero
    local btn = nil
    if frometype == "Role" then
        btn = self:CreatButton("20103")
        btn.localPosition = Vector3(sp.x, sp.y + 20, 1)
        btn.localScale = Vector3(1, 1, 1)
        btn:GetComponent(Button).onClick:AddListener(function()
            self:OnActionEnd()
            self.mainPanel:OnHaloButtonClick(fctr.fighterData.id, self.mainPanel.selectSkillId, self.mainPanel.selectList)
            end)
    else
        btn = self:CreatButton("20103")
        btn.localPosition = Vector3(sp.x, sp.y + 20, 1)
        btn.localScale = Vector3(1, 1, 1)
        btn:GetComponent(Button).onClick:AddListener(function()
            self.mainPanel:OnPetHaloButtonClick(fctr.fighterData.id, self.mainPanel.selectSkillId, self.mainPanel.selectList)
            -- self:OpenGuide()
            self:OnActionEnd()
            end)
            -- LuaTimer.Add(100 ,function()
            -- self.mainPanel:OnPetHaloButtonClick(fctr.fighterData.id, self.mainPanel.selectSkillId, self.mainPanel.selectList)
            -- self:OpenGuide()
            -- self:OnActionEnd()
            -- end)
            -- return
    end
    TipsManager.Instance:ShowGuide({gameObject = btn.gameObject, data = msg, forward = TipsEumn.Forward.Right})
    self:OpenGuide()
end

function CombatGuideAction:GuideAuto()
    self.effectOffset = Vector3(0,2,0)
    self.guidepanel:GetComponent(Image).enabled = false
    local btn = self:CreatButton("20119")
    btn:GetComponent(Button).onClick:AddListener(function()
        self:OnActionEnd()
        self.mainPanel.functionIconPanel:OnAutoButtonClick()
        self.guidepanel:GetComponent(Image).enabled = false
        end)
    btn.position = self.mainPanel.functionIconPanel.autoButton.transform.position
    TipsManager.Instance:ShowGuide({gameObject = btn.gameObject, data = TI18N("开启<color='#ffff00'>自动战斗</color>")})
    self:OpenGuide()
end

function CombatGuideAction:CreatButton(effectid)
    local btn = GameObject("GuideBtn")
    btn:AddComponent(Image).color = Color(1,1,1,0)
    btn.transform:SetParent(self.guidepanel)
    btn:GetComponent(RectTransform).sizeDelta = Vector2(64, 64)
    btn.transform.localScale = Vector3.one
    btn:AddComponent(Button)
    local effect = GameObject.Instantiate(self.guidepanel:Find(effectid).gameObject)
    -- self.guidepanel:Find("20103").gameObject 20119
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform:SetParent(btn.transform)
    effect.transform.localScale = Vector3.one
    effect.transform.localPosition = self.effectOffset
    effect.gameObject:SetActive(true)
    return btn.transform
end

function CombatGuideAction:CloseGuide()
    self.guidepanel.gameObject:SetActive(false)
end

function CombatGuideAction:OpenGuide()
    self.guidepanel.gameObject:SetActive(true)
end

function CombatGuideAction:ClearBtn()
    local btn = self.guidepanel:Find("GuideBtn")
    if btn ~= nil then
        GameObject.DestroyImmediate(btn.gameObject)
    end
end

function CombatGuideAction:OnActionEnd()
    TipsManager.Instance:HideGuide()
    self:ClearBtn()
    self:CloseGuide()
    self:InvokeAndClear(CombatEventType.End)
    self = nil
end

function CombatGuideAction:GuideFuncBtn(name)
    self.guidepanel:GetComponent(Image).enabled = false
    local btn = self:CreatButton("20103")
    if name == "Catch" then
        btn.transform.position = self.mainPanel.functionIconPanel.catchPetButton.transform.position
        btn:GetComponent(Button).onClick:AddListener(function()
            self.mainPanel.functionIconPanel:OnCatchpetButClick()
            self:OnActionEnd()
        end)
        btn:GetComponent(RectTransform).anchoredPosition = Vector2(btn:GetComponent(RectTransform).anchoredPosition.x+3.2, btn:GetComponent(RectTransform).anchoredPosition.y+27)
        TipsManager.Instance:ShowGuide({gameObject = btn.gameObject, data = TI18N("被偷取较多银币时使用捕捉")})
    end
    self:OpenGuide()
end

function CombatGuideAction:GuideCancelAuto()
    if self.mainPanel.functionIconPanel.cancelButton.transform:Find("effect") == nil then
        local effect = GameObject.Instantiate(self.guidepanel:Find("20119").gameObject)
        effect.name = "effect"
        effect.transform:SetParent(self.mainPanel.functionIconPanel.cancelButton.transform)
        effect.transform.localScale = Vector3.one
        effect.transform.localPosition = Vector3.zero
        effect:SetActive(true)
    end
end
