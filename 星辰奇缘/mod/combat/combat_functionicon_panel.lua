-- 战斗UI
-- 2016-5-24 怒气技能扩充 huangzefeng
CombatFunctionIconPanel = CombatFunctionIconPanel or BaseClass()

function CombatFunctionIconPanel:__init(file, mainPanel)
    self.file = file
    self.mainPanel = mainPanel
    self.RoleSp = false
    self.PetSp = false

    self.originOffsetMax = Vector2.zero
    self.originOffsetMin = Vector2.zero

    self.adaptListener = function() self:AdaptIPhoneX() end

    self:InitPanel()
end

function CombatFunctionIconPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(self.file))
    self.transform = self.gameObject.transform

    self.combatMgr = CombatManager.Instance
    self.controller = CombatManager.Instance.controller
    self.accountInfo = RoleManager.Instance.RoleData
    UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.gameObject)

    self.normalButtons = self.gameObject.transform:Find ("NormalButton").gameObject;
    self.petNormalButtons = self.gameObject.transform:Find ("PetNormalButton").gameObject;


    self.escapeButton = self.normalButtons.transform:Find("EscapeButton").gameObject
    self.catchPetButton = self.normalButtons.transform:Find("CatchPetButton").gameObject
    self.skillButton = self.normalButtons.transform:Find("SkillButton").gameObject
    self.defenceButton = self.normalButtons.transform:Find("DefenceButton").gameObject
    self.protectButton = self.normalButtons.transform:Find("ProtectButton").gameObject
    self.propButton = self.normalButtons.transform:Find("PropButton").gameObject
    self.summonButton = self.normalButtons.transform:Find("SummonButton").gameObject
    self.atkButton = self.normalButtons.transform:Find("AtkButton").gameObject
    self.atkskillButton = self.normalButtons.transform:Find("AtkSkillButton").gameObject
    self.atkspskillButton = self.normalButtons.transform:Find("AtkSpSkillButton").gameObject


    self.escapeButton:GetComponent(Button).onClick:AddListener(function() self:OnEscapeButClick() end )
    self.skillButton:GetComponent(Button).onClick:AddListener(function() self:OnSkillButClick() end )
    self.defenceButton:GetComponent(Button).onClick:AddListener(function() self:OnDefenceButClick() end )
    self.protectButton:GetComponent(Button).onClick:AddListener(function() self:OnProtectButClick() end )
    self.catchPetButton:GetComponent(Button).onClick:AddListener(function() self:OnCatchpetButClick() end )
    self.summonButton:GetComponent(Button).onClick:AddListener(function() self:OnSummonButClick() end )
    self.propButton:GetComponent(Button).onClick:AddListener(function() self:OnPropButClick() end )
    self.atkButton:GetComponent(Button).onClick:AddListener(function() self:OnAtkAttackClick() end )
    self.atkspskillButton:GetComponent(Button).onClick:AddListener(function() self:OnAtkSpClick() end )
    self.atkskillButton:GetComponent(Button).onClick:AddListener(function() self:OnAtkSkillClick() end )

    self.petSkillButton= self.petNormalButtons.transform:Find("SkillButton").gameObject
    self.petPropButton= self.petNormalButtons.transform:Find("PropButton").gameObject
    self.petProtectButton= self.petNormalButtons.transform:Find("ProtectButton").gameObject
    self.petDefenceButton= self.petNormalButtons.transform:Find("DefenceButton").gameObject
    self.petEscapeButton= self.petNormalButtons.transform:Find("EscapeButton").gameObject
    self.patkButton = self.petNormalButtons.transform:Find("AtkButton").gameObject
    self.patkskillButton = self.petNormalButtons.transform:Find("AtkSkillButton").gameObject
    self.patkspskillButton = self.petNormalButtons.transform:Find("AtkSpSkillButton").gameObject

    self.petEscapeButton:GetComponent(Button).onClick:AddListener(function() self:OnPetEscapeButClick() end )
    self.petDefenceButton:GetComponent(Button).onClick:AddListener(function() self:OnPetDefenceButClick() end )
    self.petPropButton:GetComponent(Button).onClick:AddListener(function() self:OnPropButClick() end )
    self.petProtectButton:GetComponent(Button).onClick:AddListener(function() self:OnPetProtectButClick() end )
    self.patkButton:GetComponent(Button).onClick:AddListener(function() self:OnpAtkAttackClick() end )
    self.patkskillButton:GetComponent(Button).onClick:AddListener(function() self:OnpAtkSkillClick() end )
    self.patkspskillButton:GetComponent(Button).onClick:AddListener(function() self:OnpAtkSpClick() end )


    self.buttonList = {}
    self.atkbuttonList = {}
    table.insert(self.buttonList, self.propButton)
    table.insert(self.buttonList, self.summonButton)
    table.insert(self.buttonList, self.protectButton)
    table.insert(self.buttonList, self.defenceButton)
    table.insert(self.buttonList, self.catchPetButton)
    table.insert(self.buttonList, self.escapeButton)
    table.insert(self.atkbuttonList, {btn = self.atkButton, name = self.atkButton.name})
    table.insert(self.atkbuttonList, {btn = self.atkskillButton, name = self.atkskillButton.name})
    table.insert(self.atkbuttonList, {btn = self.atkspskillButton, name = self.atkspskillButton.name})

    self.petButtonList = {}
    self.petatkButtonList = {}
    table.insert(self.petButtonList, self.petPropButton)
    table.insert(self.petButtonList, self.petProtectButton)
    table.insert(self.petButtonList, self.petDefenceButton)
    table.insert(self.petButtonList, self.petEscapeButton)
    table.insert(self.petatkButtonList, {btn = self.patkButton, name = self.patkButton.name})
    table.insert(self.petatkButtonList, {btn = self.patkskillButton, name = self.patkskillButton.name})
    table.insert(self.petatkButtonList, {btn = self.patkspskillButton, name = self.patkspskillButton.name})

    self.autoButton = self.gameObject.transform:Find("AutoButton").gameObject
    self.cancelButton = self.gameObject.transform:Find("CancelButton").gameObject
    self.ReSelectButton = self.gameObject.transform:Find("ReSelectButton").gameObject
    self.ReSelectButtonImg = self.ReSelectButton.transform:GetComponent(Image)
    self.buttonPosition = self.autoButton:GetComponent(RectTransform).anchoredPosition
    -- utils.add_down_up_scale(self.autoButton)
    -- utils.add_down_up_scale(self.cancelButton)

    self.autoButton:GetComponent(Button).onClick:AddListener(function() self:OnAutoButtonClick() end)
    self.cancelButton:GetComponent(Button).onClick:AddListener(function() self:OnCancelButtonClick() end)
    self.ReSelectButton:GetComponent(Button).onClick:AddListener(function() self:OnReSelectButtonClick() end)

    self.hiddenPos = self.autoButton:GetComponent(RectTransform).anchoredPosition
    self.cancelButton.transform.anchoredPosition = self.buttonPosition
    self.hiddenPos = Vector2(self.hiddenPos.x, self.hiddenPos.y)
    MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(4, true)
    self.baseFuncIconList = {}
    self.baseButtonPanel1 = MainUIManager.Instance.MainUIIconView.transform:Find("ButtonPanel1/").gameObject
    local baseButList1 = MainUIManager.Instance.MainUIIconView.icon_type1_list
    -- local baseButList1 = {}
    local roleLev = self.accountInfo.lev
    self.baseswitchicon = MainUIManager.Instance.MainUIIconView.transform:Find("ButtonPanel1/IconSwitcherIconButton")
    self.origin_baseswitchicon_pos = Vector3(-40, 10, 0)
    self.baseswitchicon.transform.localPosition = Vector3(self.origin_baseswitchicon_pos.x-70, self.origin_baseswitchicon_pos.y, self.origin_baseswitchicon_pos.z)
    -- table.insert(self.baseFuncIconList, switchicon)
    -- for _, data in ipairs(baseButList1) do
    --     -- data.icon.transform.anchoredPosition = self.hiddenPos
    --     if data.lev <= roleLev
    --         -- and data.icon.name ~= "GuardianButton"
    --         and data.icon.name ~= "MainLineButton"
    --         and data.icon.name ~= "PetIconButton"
    --     then
    --         table.insert(self.baseFuncIconList, data)
    --     end
    -- end
    self.hideFuncIconList = {}

    -- self.baseButtonPanel1 = ui_basefunctioiconarea.Find("ButtonPanel1").gameObject

    -- self.ShowAuto = true
    -- self.gameObject:SetActive(true)
    self.normalButtons:SetActive(false)
    for i = 1, #self.buttonList do
        local but = self.buttonList[i]
        local pos = but.transform.anchoredPosition
        -- but.transform.anchoredPosition = Vector2(self.hiddenPos.x - 98 * i, pos.y)
        but.transform.anchoredPosition = Vector2(self.hiddenPos.x, pos.y)
    end

    self:HideButtonImmi("Pet")
    self:ActiveAll(false)

    self:HideAutoBut()
    self:HideBaseFuncIcon()

    self.IsShowRole = false
    self.IsShowPet = false
    self.IsShowBtn1 = false

    -- 召唤宠物
    self.SummonPanel = CombatSummonPanel.New(self.mainPanel)
    self.ItemPanel = CombatItemPanel.New(self.mainPanel)

    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)
    self:AdaptIPhoneX()
end

function CombatFunctionIconPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)

    BaseUtils.ReleaseImage(self.ReSelectButtonImg)
    self.baseswitchicon.transform.localPosition = self.origin_baseswitchicon_pos
    MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(4, false)
    self.baseButtonPanel1:SetActive(true)
    self:ShowBaseFuncIcon()
    BaseUtils.CancelIPhoneXTween(self.transform)
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    if self.ItemPanel ~= nil then
        self.ItemPanel:DeleteMe()
    end
end

function CombatFunctionIconPanel:Hide()
    self.baseswitchicon.transform.localPosition = self.origin_baseswitchicon_pos
    MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(4, false)
    self.baseButtonPanel1:SetActive(true)
    self:ShowBaseFuncIcon()
end

function CombatFunctionIconPanel:Show( )
    self.normalButtons:SetActive(false)
    for i = 1, #self.buttonList do
        local but = self.buttonList[i]
        local pos = but.transform.anchoredPosition
        -- but.transform.anchoredPosition = Vector2(self.hiddenPos.x - 98 * i, pos.y)
        but.transform.anchoredPosition = Vector2(self.hiddenPos.x, pos.y)
    end
    self.baseswitchicon.transform.localPosition = Vector3(self.origin_baseswitchicon_pos.x-70, self.origin_baseswitchicon_pos.y, self.origin_baseswitchicon_pos.z)
    self:HideButtonImmi("Pet")
    self:ActiveAll(false)

    self:HideAutoBut()
    self:HideBaseFuncIcon()

    self.IsShowRole = false
    self.IsShowPet = false
    self.IsShowBtn1 = false
end

function CombatFunctionIconPanel:OnEscapeButClick()
    self.mainPanel:OnEscapeButClick()
end

function CombatFunctionIconPanel:OnPetEscapeButClick()
    self.mainPanel:OnPetEscapeButClick()
end

function CombatFunctionIconPanel:OnPetDefenceButClick()
    self.mainPanel:OnPetDefenceButClick()
end

function CombatFunctionIconPanel:OnSkillButClick()
end

function CombatFunctionIconPanel:OnDefenceButClick()
    self.mainPanel:OnDefenceButClick()
end

function CombatFunctionIconPanel:OnProtectButClick()
    self.mainPanel:OnProtectButClick()
end

function CombatFunctionIconPanel:OnPetProtectButClick()
    self.mainPanel:OnPetProtectButClick()
end

function CombatFunctionIconPanel:OnCatchpetButClick()
    self.mainPanel:OnCatchpetButClick()
end

function CombatFunctionIconPanel:OnSummonButClick()
    self.SummonPanel:Show()
end

function CombatFunctionIconPanel:OnPropButClick()
    -- if CombatManager.Instance.isFighting == true and CombatManager.Instance.enterData.combat_type == 60 then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("爵位闯关无法使用道具"))
    --     return
    -- end
    self.ItemPanel:Show()
end

--人物战斗技能面板点击
function CombatFunctionIconPanel:OnAtkSkillClick()
    self.mainPanel:SwitchSkillPanel("Role", 2)
end

--人物怒气技能点击
function CombatFunctionIconPanel:OnAtkSpClick()
    self.mainPanel:SwitchSkillPanel("Role", 3)
end

--人物攻击按钮点击
function CombatFunctionIconPanel:OnAtkAttackClick()
    self.mainPanel:SwitchSkillPanel("Role", 1)
end

--宠物技能按钮点击
function CombatFunctionIconPanel:OnpAtkSkillClick()
    self.mainPanel:SwitchSkillPanel("Pet", 2)
end

--宠物sp技能点击
function CombatFunctionIconPanel:OnpAtkSpClick()
    self.mainPanel:SwitchSkillPanel("Pet", 3)
    -- body
end

--宠物普工点击
function CombatFunctionIconPanel:OnpAtkAttackClick()
    self.mainPanel:SwitchSkillPanel("Pet", 1)
end

function CombatFunctionIconPanel:OnAutoButtonClick()
    self.ReSelectButton:SetActive(false)
    self.combatMgr:Send10740(1, CombatUtil.GetNormalSKill(self.accountInfo.classes), 1000)
    if not self.combatMgr.isBrocasting then
        -- print("播报结束立刻决定")
        -- self.combatMgr:Send10731(self.mainPanel.round)
    end
end

function CombatFunctionIconPanel:OnCancelButtonClick()
    self.combatMgr:Send10740(0, CombatUtil.GetNormalSKill(self.accountInfo.classes), 1000)
end

function CombatFunctionIconPanel:OnReSelectButtonClick()
    self.combatMgr:Send10735()
end

function CombatFunctionIconPanel:OnAutoSetting(flag, result, msg)
    local selectState = self.mainPanel.selectState
    if flag == 0 then
        -- self.autoButton:SetActive(true)
        -- self.cancelButton:SetActive(false)
        self:SetAutoButActive(true)
    else
        -- self.cancelButton:SetActive(true)
        -- self.autoButton:SetActive(false)
        self:SetAutoButActive(false)
    end

    if flag == 0 and selectState ~= CombatSeletedState.Idel then -- 开启
        if self.IsShowBtn1 then
            self:HideButton("ButtonPanel1", function() end)
        end
        if selectState == CombatSeletedState.Role then
            self:HideButton("Pet", function() end)
            self:ShowButton("Role", function() end)
        else
            self:HideButton("Role", function() end)
            self:ShowButton("Pet", function() end)
        end
        -- self.ReSelectButton:SetActive(true)
        -- self.ReSelectButton.transform.anchoredPosition = Vector2(self.hiddenPos.x - 70, self.hiddenPos.y-38)
    else
        local callback = function()
            self:ShowButton("ButtonPanel1", function() end)
        end
        if selectState ~= CombatSeletedState.Idel then
            self:HideButton("Pet", function() end)
            self:HideButton("Role", callback)
        else
            self:HideButton("Role", function() end)
            self:HideButton("Pet", callback)
        end
    end
    if selectState == CombatSeletedState.Idel and flag == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("下回合开始时显示操作菜单"))
    elseif selectState == CombatSeletedState.Idel and flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N(msg))
    end
end

-- 点击技能时用到
function CombatFunctionIconPanel:ActiveAll(isShow)
    local selectState = self.mainPanel.selectState
    if isShow then
        if selectState == CombatSeletedState.Role then
            self:ShowButton("Role", function() end)
        else
            self:ShowButton("Pet", function() end)
        end
    else
        if selectState == CombatSeletedState.Role then
            self:HideButtonImmi("Role")
        else
            self:HideButtonImmi("Pet")
        end
    end
    self:ActiveProcBut()
end

function CombatFunctionIconPanel:ActiveProcBut()
    if self.mainPanel.isAutoFighting then
        -- self.autoButton:SetActive(false)
        -- self.cancelButton:SetActive(true)
        self:SetAutoButActive(false)

        self.baseButtonPanel1:SetActive(true)
        self:ShowButton("ButtonPanel1", function() end)
    else
        -- self.autoButton:SetActive(true)
        -- self.cancelButton:SetActive(false)
        self:SetAutoButActive(true)
        local callback = function()
            self.baseButtonPanel1:SetActive(false)
        end
        self:HideButton("ButtonPanel1", callback)
    end
end

function CombatFunctionIconPanel:HideAutoBut()
    -- self.autoButton:SetActive(false)
    -- self.cancelButton:SetActive(false)
    self:SetAutoButActive(false)
end

function CombatFunctionIconPanel:HideReslectButton()
    self.ReSelectButton:SetActive(false)
end

function CombatFunctionIconPanel:HideButtonImmi(PanelType)
    local list = {}
    local atklist = {}
    if PanelType == "Role" then
        list = self.buttonList
        -- atklist = self.atkbuttonList
        self.IsShowRole = false
    elseif PanelType == "Pet" then
        self.ReSelectButton:SetActive(false)
        list = self.petButtonList
        -- atklist = self.petatkButtonList
        self.IsShowPet = false
    elseif PanelType == "ButtonPanel1" then
        self.ReSelectButton:SetActive(false)
        self.IsShowBtn1 = false
        for _, data in ipairs(self.baseFuncIconList) do
            table.insert(list, data.icon)
        end
    end
    for _, but in ipairs(list) do
        but:SetActive(false)
        -- but:GetComponent(RectTransform).localPosition = self.buttonPosition
    end
    -- for _, but in ipairs(atklist) do
    --     but.btn:SetActive(false)
    --     -- but:GetComponent(RectTransform).localPosition = self.buttonPosition
    -- end
end

function CombatFunctionIconPanel:HideButton(PanelType, callback)
    if PanelType == "Role" then
        if self.IsShowRole then
            local count = #self.buttonList
            local idx = 1
            for _, button in ipairs(self.buttonList) do
                local call = function()
                    if not BaseUtils.is_null(self.escapeButton) then
                        button:SetActive(false)
                        if idx == count then
                            callback()
                            self.IsShowRole = false
                        end
                        idx = idx + 1
                    end
                end
                -- button:GetComponent(RectTransform).anchoredPosition = Vector2(self.hiddenPos.x, self.hiddenPos.y)
                call()
            end
            -- for i,v in ipairs(self.atkbuttonList) do
            --     v.btn:SetActive(false)
            -- end
        else
            callback()
        end
    elseif PanelType == "Pet" then
        if self.IsShowPet then
            local count = #self.petButtonList
            local idx = 1
            for _, button in ipairs(self.petButtonList) do
                local call = function()
                    if not BaseUtils.is_null(self.escapeButton) then
                        button:SetActive(false)
                        if idx == count then
                            callback()
                            self.IsShowPet = false
                        end
                        idx = idx + 1
                    end
                end
                -- button:GetComponent(RectTransform).anchoredPosition = Vector2(self.hiddenPos.x, self.hiddenPos.y)
                call()
            end
            -- for i,v in ipairs(self.petatkButtonList) do
            --     v.btn:SetActive(false)
            -- end
            --隐藏宠物按钮时,非播放状态并且不是选择角色技能时,才显示返回按钮
            if not self.combatMgr.isBrocasting and self.mainPanel.selectState ~= CombatSeletedState.Role then   
                self.ReSelectButtonImg.sprite = self.combatMgr.assetWrapper:GetSprite(AssetConfig.combat2_texture, "I18NReSelect1")
                self.ReSelectButton:SetActive(true)
                self.ReSelectButton.transform.anchoredPosition = Vector2(self.hiddenPos.x - 70, self.hiddenPos.y-38)
            else
                self.ReSelectButton:SetActive(false)
            end
        else
            callback()
        end

    elseif PanelType == "ButtonPanel1" then
        if self.IsShowBtn1 then
        --     local count = #self.baseFuncIconList
        --     local idx = 1
        --     for _, button in ipairs(self.baseFuncIconList) do
        --         local call = function()
        --             if not BaseUtils.is_null(self.escapeButton) then
        --                 button.icon:SetActive(false)
        --                 if idx == count then
        --                     callback()
        --                     self.IsShowBtn1 = false
        --                 end
        --                 idx = idx + 1
        --             end
        --         end
        --         button.icon:GetComponent(RectTransform).anchoredPosition = Vector2(self.hiddenPos.x, self.hiddenPos.y)
        --         call()
        --     end
            self.IsShowBtn1 = false
            self.baseButtonPanel1:SetActive(false)
        else
            callback()
        end
    end
end

function CombatFunctionIconPanel:ShowButton(PanelType, callback)
    if (self.combatMgr.isWatching or self.combatMgr.isWatchRecorder)and PanelType ~= "ButtonPanel1" then
        return
    end
    if PanelType == "Role" then
        if not self.IsShowRole then
            self.normalButtons:SetActive(true)
            local count = #self.buttonList
            local idx = 1
            for i = 1, count do
                local button = self.buttonList[i]
                button:SetActive(true)
                local call = function()
                    if idx == count then
                        callback()
                        self.IsShowRole = true
                    end
                    idx = idx + 1
                end
                button:GetComponent(RectTransform).anchoredPosition = Vector2(self.hiddenPos.x - 70 * i, self.hiddenPos.y-38)
                call()
            end
            -- for i,v in ipairs(self.atkbuttonList) do
            --     if v.name ~= "AtkSpSkillButton" then
            --         v.btn:SetActive(true)
            --     else
            --         v.btn:SetActive(self.RoleSp)
            --     end
            -- end
        else
            callback()
        end
    elseif PanelType == "Pet" then
        if not self.IsShowPet then
            self.petNormalButtons:SetActive(true)
            local count = #self.petButtonList
            local idx = 1
            for i = 1, count do
                local button = self.petButtonList[i]
                button:SetActive(true)
                local call = function()
                    if idx == count then
                        callback()
                        self.IsShowPet = true
                    end
                    idx = idx + 1
                end
                button:GetComponent(RectTransform).anchoredPosition = Vector2(self.hiddenPos.x - 70 * i, self.hiddenPos.y-38)
                call()
            end
            self.ReSelectButtonImg.sprite = self.combatMgr.assetWrapper:GetSprite(AssetConfig.combat2_texture, "I18NReSelect")
            self.ReSelectButton:SetActive(true)
            self.ReSelectButton.transform.anchoredPosition = Vector2(self.hiddenPos.x - 70 * idx, self.hiddenPos.y-38)
            -- for i,v in ipairs(self.petatkButtonList) do
            --     if v.name ~= "AtkSpSkillButton" then
            --         v.btn:SetActive(true)
            --     else
            --         v.btn:SetActive(self.PetSp)
            --     end
            -- end
        else
            callback()
        end
    elseif PanelType == "ButtonPanel1" then
        if not self.IsShowBtn1 then
            -- local count = #self.baseFuncIconList
            -- local idx = 1
            -- -- 此处可能有tween没跑完，等下一帧处理
            -- -- ctx:InvokeDelayFrame(function ()
            --     for i = 1, count do
            --         local button = self.baseFuncIconList[i]
            --         local call = function()
            --             if idx == count then
            --                 callback()
            --                 self.IsShowBtn1 = true
            --             end
            --             idx = idx + 1
            --         end
            --         local pos = button.icon:GetComponent(RectTransform).anchoredPosition
            --         button.icon:GetComponent(RectTransform).anchoredPosition = Vector2(self.hiddenPos.x - 74 * i, self.hiddenPos.y - 24.5)
            --         button.icon:SetActive(true)
            --         call()
            --     end
            --     self.baseButtonPanel1:SetActive(true)
            self.ReSelectButton:SetActive(false)
            self.baseButtonPanel1:SetActive(true)
            MainUIManager.Instance.MainUIIconView:showbaseicon()
            callback()
            self.IsShowBtn1 = true
        else
            callback()
        end
    end
end

function CombatFunctionIconPanel:HideBaseFuncIcon()
    self.baseButtonPanel1:SetActive(false)
    -- local count = self.baseButtonPanel1.transform.childCount
    -- for i = 0, count - 1 do
    --     local child = self.baseButtonPanel1.transform:GetChild(i)
    --     local find = false
    --     for i = 1, #self.baseFuncIconList do
    --         local button = self.baseFuncIconList[i]
    --         if button.icon.name == child.name then
    --             find = true
    --             break
    --         end
    --     end
    --     if not find then
    --         if child.gameObject.activeSelf then
    --             child.gameObject:SetActive(false)
    --             table.insert(self.hideFuncIconList, child)
    --         end
    --     else
    --         local pos = child.gameObject.transform.anchoredPosition
    --         child.gameObject.transform.anchoredPosition = Vector2(pos.x, self.hiddenPos.y - 40)
    --     end
    -- end
end
function CombatFunctionIconPanel:ShowBaseFuncIcon()
    -- for _, data in ipairs(self.hideFuncIconList) do
    --     data.gameObject:SetActive(true)
    -- end
    self.baseButtonPanel1:SetActive(true)
    self.ReSelectButton:SetActive(false)
    MainUIManager.Instance.MainUIIconView:showbaseicon()
end

function CombatFunctionIconPanel:SetAutoButActive(IsAutoActive)
    if IsAutoActive and self.combatMgr.isWatching == false and not self.combatMgr.isWatchRecorder then
        self.autoButton:SetActive(true)
        self.cancelButton:SetActive(false)
        -- self.mainPanel.mixPanel.AutoFightingImage:SetActive(false)
        self.mainPanel.counterInfoPanel.digitRoundPanel:SetActive(true)
    elseif self.combatMgr.isWatching == false and not self.combatMgr.isWatchRecorder then
        self.autoButton:SetActive(false)
        self.cancelButton:SetActive(true)
        self.mainPanel.counterInfoPanel.digitRoundPanel:SetActive(true)
        if self.mainPanel.isAutoFighting then
            -- self.mainPanel.mixPanel.AutoFightingImage:SetActive(false)
        end
    else
        self.autoButton:SetActive(false)
        self.cancelButton:SetActive(false)
    end
end

function CombatFunctionIconPanel:UpdateAtkList(RoleSp, PetSp)
    self.RoleSp = RoleSp
    self.PetSp = PetSp
    if RoleSp == false then
        self.atkspskillButton:SetActive(false)
        self.atkskillButton.transform.anchoredPosition = Vector2(-43, 177)
    else
        self.atkspskillButton:SetActive(true)
        self.atkskillButton.transform.anchoredPosition = Vector2(-43, 257)
    end
    if PetSp == false then
        self.patkspskillButton:SetActive(false)
        self.patkskillButton.transform.anchoredPosition = Vector2(-43, 177)
    else
        self.patkspskillButton:SetActive(false)
        self.patkskillButton.transform.anchoredPosition = Vector2(-43, 257)
    end
end

function CombatFunctionIconPanel:AdaptIPhoneX()
    if self.mainPanel.InitFinish then
        -- if MainUIManager.Instance.adaptIPhoneX then
        --     self.originOffsetMax = Vector2(-3, 0)
        --     self.originOffsetMin = Vector2(24, 0)
        -- else
        --     self.originOffsetMax = Vector2.zero
        --     self.originOffsetMin = Vector2.zero
        -- end

        -- self.transform.offsetMax = self.originOffsetMax
        -- self.transform.offsetMin = self.originOffsetMin
        BaseUtils.AdaptIPhoneX(self.transform)
    end
end

