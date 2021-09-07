----------------------------------------------------
-- @doc 战斗扩展UI
-- @author yqhuang(19123767@qq.com)
-- -------------------------------------------------
CombatExtendPanel = CombatExtendPanel or BaseClass()

function CombatExtendPanel:__init(file, mainPanel)
    self.file = file
    self.mainPanel = mainPanel
    self.scriptSetfunc = function()
        self:UpdateSkillSet()
    end
    local callback = function()
        self:InitPanel()
    end
    self.resList = {

    }
    self.extraX = 0
    self.isInit = false
    self.isShow = false

    self.adaptListener = function() self:AdaptIPhoneX() end

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(self.resList, callback)
end

function CombatExtendPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(self.file))
    self.transform = self.gameObject.transform
    self.combatMgr = CombatManager.Instance
    UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.gameObject)

    self.TrialRoundInfo = self.gameObject.transform:FindChild("TrialRoundInfo").gameObject
    self.TrialRoundInfo:SetActive(false)

    self.ExtendMainUIButton = self.gameObject.transform:Find("ExtendMainUIButton").gameObject
    self.ExtendMainUIButton.transform.anchoredPosition = Vector2(-280, -84)
    self.ExtendMainUIButton:SetActive(true)
    self:InitExtendMainUIButton()

    self.guidence = self.transform:Find("Guidence").gameObject
    self.guidence.transform.pivot = Vector2(0.5, 1)
    self.guidence.transform.anchorMax = Vector2(0.5, 1)
    self.guidence.transform.anchorMin = Vector2(0.5, 1)
    self.guidence.transform.anchoredPosition = Vector2.zero
    self.guidenceText = self.guidence.transform:Find("Text"):GetComponent(Text)

    self.RoleItem = self.transform:Find("SkillSetCon/RoleItem")
    self.RoleItembtn = self.RoleItem:Find("Button"):GetComponent(Button)
    self.RoleItemLoader = SingleIconLoader.New(self.RoleItem:Find("Icon").gameObject)

    self.PetItem = self.transform:Find("SkillSetCon/PetItem")
    self.PetItembtn = self.PetItem:Find("Button"):GetComponent(Button)
    self.PetItemLoader = SingleIconLoader.New(self.PetItem:Find("Icon").gameObject)
    self:UpdateSkillSet()

    self.SkillSetButton = self.transform:Find("SkillSetButton")
    self.SkillSetCon = self.transform:Find("SkillSetCon")
    self.transform:Find("SkillSetButton"):GetComponent(Button).onClick:AddListener(function() self.SkillSetCon.gameObject:SetActive(not self.SkillSetCon.gameObject.activeSelf) end)
    self.SkillSetCon:GetComponent(Button).onClick:AddListener(function() self.SkillSetCon.gameObject:SetActive(false) end)

    self.switchcon_open = self.transform:Find("SwitchButton/OpenButton").gameObject
    self.switchcon_close = self.transform:Find("SwitchButton/CloseButton").gameObject
    self.switchcon_close.transform.anchoredPosition = Vector2(237, 0)

    PetManager.Instance.OnUpdatePetList:Add(self.scriptSetfunc)
    SkillScriptManager.Instance.OnRoleScriptChange:Add(self.scriptSetfunc)
    SkillScriptManager.Instance.OnPetScriptChange:Add(self.scriptSetfunc)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)

    self:AdaptIPhoneX()
end

function CombatExtendPanel:__delete()
    PetManager.Instance.OnUpdatePetList:Remove(self.scriptSetfunc)
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener) self.assetWrapper:DeleteMe()
    SkillScriptManager.Instance.OnRoleScriptChange:Remove(self.scriptSetfunc)
    SkillScriptManager.Instance.OnPetScriptChange:Remove(self.scriptSetfunc)
    if self.RoleItemLoader ~= nil then
        self.RoleItemLoader:DeleteMe()
        self.RoleItemLoader = nil
    end
    if self.PetItemLoader ~= nil then
        self.PetItemLoader:DeleteMe()
        self.PetItemLoader = nil
    end
    BaseUtils.CancelIPhoneXTween(self.transform)
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
end

function CombatExtendPanel:Show()
    --临时性代码
    -- if CombatManager.Instance.assetWrapper == nil then
    --     CombatManager.Instance.assetWrapper = self.mainPanel.combatMgr.assetWrapper
    -- end
    self:OnLoadFinish()
    self:InitExtendMainUIButton()
    self:HideExtendButton()
    self:UpdateSkillSet()
    self.isInit = true
end

function CombatExtendPanel:OnLoadFinish()
    local enterData = self.mainPanel.controller.enterData
    local combatType = enterData.combat_type
    self.SkillSetCon.gameObject:SetActive(false)
    self.TrialRoundInfo:SetActive(false)
    if not self.combatMgr.isWatching and not self.combatMgr.isWatchRecorder then
        -- if not BaseUtils.is_null(self.mainPanel.counterInfoPanel.VSImg) and self.mainPanel.counterInfoPanel.VSImg.gameObject.activeSelf then
        --     self.SkillSetButton.anchoredPosition = Vector2(170, -75)
        -- else
        --     self.SkillSetButton.anchoredPosition = Vector2(60, -75)
        -- end
        self.SkillSetButton.gameObject:SetActive(true)
    else
        self.SkillSetButton.gameObject:SetActive(false)
    end
    if combatType == 4 then
        local order = TrialManager.Instance.model.order
        local data = DataTrial.data_trial_data[order]
        local clear_normal = TrialManager.Instance.model.clear_normal
        if data ~= nil and data.ext_desc ~= nil and data.ext_desc ~= ""
            and not ((TrialManager.Instance.model.mode == 1 and TrialManager.Instance.model.max_order_easy < #DataTrial.data_trial_data)
                        or (TrialManager.Instance.model.mode == 2 and TrialManager.Instance.model.max_order_hard < #DataTrial.data_trial_data)) then
            self.TrialRoundInfo.transform.anchoredPosition = Vector2(308, -31)
            self.TrialRoundInfo:SetActive(true)
            self.SkillSetButton.gameObject:SetActive(false)
            self.TrialRoundInfo.transform:FindChild("Text").gameObject:GetComponent(Text).text = data.ext_desc
        else
            self.TrialRoundInfo:SetActive(false)  -- 暂时隐藏
            self.SkillSetButton.gameObject:SetActive(true)
        end
    elseif combatType == 43 then
        self.TrialRoundInfo.transform.anchoredPosition = Vector2(288, -67)
        local wave = UnlimitedChallengeManager.Instance.currWave
        if DataEndlessChallenge.data_list[wave].is_jump == 1 and DataEndlessChallenge.data_list[wave].round_limit >= 1 then
            self.TrialRoundInfo.transform:FindChild("Text").gameObject:GetComponent(Text).text = string.format(TI18N("%s回合内胜利可跳至第%s波"), DataEndlessChallenge.data_list[wave].round_limit, DataEndlessChallenge.data_list[wave].jump_to)
            self.TrialRoundInfo:SetActive(true)
            self.SkillSetButton.gameObject:SetActive(false)
        else
            self.TrialRoundInfo:SetActive(false)  -- 暂时隐藏
            self.SkillSetButton.gameObject:SetActive(true)
        end
    end
    local buttoncon = self.ExtendMainUIButton.transform:Find("ScrollMask/ButtonCon")
    for k,v in pairs(DataSystem.data_icon) do
        local button = buttoncon:Find(v.icon_name)
        if not BaseUtils.is_null(button) and v.lev <= RoleManager.Instance.RoleData.lev then
            button:GetComponent(Button).onClick:RemoveAllListeners()
            button:GetComponent(Button).onClick:AddListener(function ()
                MainUIManager.Instance:btnOnclick(v.id)
            end)
            -- utils.add_down_up_scale(button.gameObject)
            button.gameObject:SetActive(true)
            if v.icon_name == "UpgradeButton" then
                if #ImproveManager.Instance.lastList == 0 then
                    button.gameObject:SetActive(false)
                end
            end
        elseif not BaseUtils.is_null(button) then
            button.gameObject:SetActive(false)
        end
    end
    buttoncon:Find("HelpButton").gameObject:SetActive(false)
end

function CombatExtendPanel:OnPlayEnd(round)
    local enterData = self.mainPanel.controller.enterData
    local combatType = enterData.combat_type
    if combatType == 4 then
        local order = TrialManager.Instance.model.order
        local data = DataTrial.data_trial_data[order]
        if data == nil or data.round_desc <= round then
            self.TrialRoundInfo:SetActive(false)
        end
    elseif combatType == 43 then
        local wave = UnlimitedChallengeManager.Instance.currWave
        if DataEndlessChallenge.data_list[wave].is_jump == 1 and DataEndlessChallenge.data_list[wave].round_limit >= round then

            self.TrialRoundInfo.transform:FindChild("Text").gameObject:GetComponent(Text).text = string.format(TI18N("%s回合内胜利可跳至第%s波"), DataEndlessChallenge.data_list[wave].round_limit, DataEndlessChallenge.data_list[wave].jump_to)
            self.TrialRoundInfo:SetActive(true)
            self.SkillSetButton.gameObject:SetActive(false)
        else
            self.TrialRoundInfo:SetActive(false)  -- 暂时隐藏
            self.SkillSetButton.gameObject:SetActive(true)
        end
    end
end

-- 初始化战斗左侧按钮面板
function CombatExtendPanel:InitExtendMainUIButton()
    local buttoncon = self.ExtendMainUIButton.transform:Find("ScrollMask/ButtonCon")
    local switchcon = self.transform:Find("SwitchButton")
    local ranckbtn = buttoncon:Find("RanksIconButton")
    if ranckbtn ~= nil then
        ranckbtn.gameObject.name = "HelpButton"
    end
    for k,v in pairs(DataSystem.data_icon) do
        local button = buttoncon:Find(v.icon_name)
        if not BaseUtils.is_null(button) and v.lev <= RoleManager.Instance.RoleData.lev then
            button:GetComponent(Button).onClick:RemoveAllListeners()
            button:GetComponent(Button).onClick:AddListener(function ()
                MainUIManager.Instance:btnOnclick(v.id)
            end)
            -- utils.add_down_up_scale(button.gameObject)
            button.gameObject:SetActive(true)
            if v.icon_name == "UpgradeButton" then
                if #ImproveManager.Instance.lastList == 0 then
                    button.gameObject:SetActive(false)
                end
            end
        elseif not BaseUtils.is_null(button) then
            button.gameObject:SetActive(false)
        end
    end
    switchcon:Find("OpenButton"):GetComponent(Button).onClick:RemoveAllListeners()
    switchcon:Find("OpenButton"):GetComponent(Button).onClick:AddListener(function ()    self:ShowExtendButton()    end)
    switchcon:Find("CloseButton"):GetComponent(Button).onClick:RemoveAllListeners()
    switchcon:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function ()   self:HideExtendButton()    end)
    if not self.isInit then
        buttoncon:Find("MarketIconButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NMarketButtonIcon")
        buttoncon:Find("HelpButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NHelp")
        buttoncon:Find("ShopIconButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NShopButtonIcon")
        buttoncon:Find("DailyButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NAgenda")
        buttoncon:Find("UpgradeButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NUpgradeButtonIcon")
        buttoncon:Find("SettingsIconButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NSettingsButtonIcon2")
        buttoncon:Find("ArenaButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NArenaButtonIcon")
        buttoncon:Find("HandupButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NHandupButtonIcon")
        buttoncon:Find("FirstChargeButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "107")
        buttoncon:Find("RewardBackButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NRewardBackButton")
    end
    buttoncon:Find("RewardBackButton").gameObject:SetActive(RewardBackManager.Instance:IsShowMainUI())
    local ischargestatus = FirstRechargeManager.Instance:isHadDoFirstRecharge()
    buttoncon:Find("FirstChargeButton").gameObject:SetActive(not ischargestatus)
    buttoncon:Find("FirstChargeButton"):GetComponent(Button).onClick:RemoveAllListeners()
    buttoncon:Find("FirstChargeButton"):GetComponent(Button).onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
    end)
    buttoncon:Find("HelpButton").gameObject:SetActive(false)
end

function CombatExtendPanel:HideExtendButton()
    self.ExtendMainUIButton:SetActive(false)
    self.ExtendMainUIButton.transform.anchoredPosition = Vector2(-246, -84)
    self.switchcon_open:SetActive(true)
    self.switchcon_close:SetActive(false)
    -- self.ExtendMainUIButton.transform:Find("ScrollMask").gameObject:SetActive(false)
    self.isShow = false
end

function CombatExtendPanel:ShowExtendButton()
    self.ExtendMainUIButton:SetActive(true)
    self.ExtendMainUIButton.transform.anchoredPosition = Vector2(0 + self.extraX, -84)
    self.switchcon_open:SetActive(false)
    self.switchcon_close:SetActive(true)
    self.isShow = true
    -- self.ExtendMainUIButton.transform:Find("ScrollMask").gameObject:SetActive(true)
end

function CombatExtendPanel:ShowGuidence()
    self.guidence:SetActive(false)
    if self.mainPanel.controller.guidenceStr ~= nil and not self.combatMgr.isWatching and not self.combatMgr.isWatchRecorder then
        self.guidence:SetActive(true)
        self.guidenceText.text = self.mainPanel.controller.guidenceStr
        self.guidence.transform.sizeDelta = Vector2(self.guidenceText.preferredWidth+6, self.guidenceText.preferredHeight+4)
    end
end

function CombatExtendPanel:UpdateSkillSet()
    -- CombatManager.Instance.assetWrapper = self.mainPanel.combatMgr.assetWrapper
    if CombatManager.Instance.assetWrapper == nil or not CombatManager.Instance.assetWrapper.ResLoaded or not self.combatMgr.isFighting then
        return
    end
    local role = RoleManager.Instance.RoleData
    local skillList = SkillManager.Instance.model.role_skill
    local cur_petdata = PetManager.Instance.model.battle_petdata
    local currRole = SkillScriptManager.Instance.roleCurrIndex
    local currPet = SkillScriptManager.Instance.PetSet
    local currRoleGroup = SkillScriptManager.Instance.RoleSet[currRole]
    local NormalAtk = CombatUtil.GetNormalSKill(RoleManager.Instance.RoleData.classes)
    if currRoleGroup ~= nil and #currRoleGroup ~= 0 then
        if currRoleGroup[#currRoleGroup].skill_id == 1000 or currRoleGroup[#currRoleGroup].skill_id == 1001 or NormalAtk == currRoleGroup[#currRoleGroup].skill_id then
            if NormalAtk == currRoleGroup[#currRoleGroup].skill_id then

                -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(1000)
                self.RoleItemLoader:SetSprite(SingleIconType.SkillIcon, 1000)
            else
                -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(currRoleGroup[#currRoleGroup].skill_id)
                self.RoleItemLoader:SetSprite(SingleIconType.SkillIcon, currRoleGroup[#currRoleGroup].skill_id)
            end
        else
            print(currRoleGroup[#currRoleGroup].skill_id)
            local skillData = DataSkill.data_skill_role[currRoleGroup[#currRoleGroup].skill_id.."_1"]
            if skillData ~= nil then
                -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = CombatManager.Instance.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(skillData.icon))
                self.RoleItemLoader:SetSprite(SingleIconType.SkillIcon, skillData.icon)
            end
        end
    else
        local roleFirst = 10000* RoleManager.Instance.RoleData.classes +1
        if RoleManager.Instance.RoleData.classes == 6 then
            roleFirst = 69001
        elseif RoleManager.Instance.RoleData.classes == 7 then
            roleFirst = 69501
        end
        -- self.RoleItem:Find("Icon"):GetComponent(Image).sprite = CombatManager.Instance.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(roleFirst))
        self.RoleItemLoader:SetSprite(SingleIconType.SkillIcon, roleFirst)
    end
    self.RoleItembtn.gameObject.transform:Find("Text"):GetComponent(Text).text = SkillScriptManager.Instance:GetGroupName(currRole)
    self.RoleItem.gameObject:SetActive(true)
    if cur_petdata ~= nil then
        if currPet ~= 0 then
            local key = string.format("%s_1", currPet)
            local icondata = DataSkill.data_petSkill[key]
            if currPet == 1000 or currPet == 1001 then
                icondata = {icon = currPet}
            end
            xpcall(function()
                -- local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(currPet, 1)
                -- if Gassest ~= "" then
                --     self.PetItem:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(Gassest, icondata.icon)
                -- else
                --     self.PetItem:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetPetSkillSprite(icondata.icon)
                -- end
                self.PetItemLoader:SetSprite(SingleIconType.SkillIcon, icondata.icon)
            end,
            function()  Log.Error(debug.traceback()) end )

        else
            local petdata = DataPet.data_pet[cur_petdata.base_id]
            xpcall(function()
                self.PetItemLoader:SetSprite(SingleIconType.Pet, petdata.head_id)
                -- self.PetItem:Find("Icon"):GetComponent(Image).sprite = CombatManager.Instance.assetWrapper:GetSprite(BaseUtils.PetHeadPath(petdata.head_id), tostring(petdata.head_id))
                if (SkillScriptManager.Instance.model.markFor60507 == 1) then
                    local key = string.format("%s_1", 60507)
                    local icondata = DataSkill.data_petSkill[key]
                    local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(60507, 1)
                    -- self.PetItem:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(Gassest, icondata.icon)
                    self.PetItemLoader:SetSprite(SingleIconType.SkillIcon, icondata.icon)
                end
            end,
            function()  Log.Error(debug.traceback()) end )
        end
        self.PetItem.gameObject:SetActive(true)
        local key = string.format("%s_1", currPet)
        local basedata = DataSkill.data_petSkill[key]
        local petsetName = ""
        if basedata ~= nil then
            petsetName = basedata.name
        elseif currPet == 1000 then
            petsetName = TI18N("普通攻击")
        elseif currPet == 1001 then
            petsetName = TI18N("防御")
        end

        if petsetName == "" then
            petsetName = TI18N("智能模式")
        end
        self.PetItembtn.gameObject.transform:Find("Text"):GetComponent(Text).text = petsetName
    else
        self.PetItem.gameObject:SetActive(false)
    end

    self.RoleItembtn.onClick:RemoveAllListeners()
    self.RoleItembtn.onClick:AddListener(function() SkillScriptManager.Instance.model:OpenRoleSelectPanel(true) end)
    self.PetItembtn.onClick:RemoveAllListeners()
    self.PetItembtn.onClick:AddListener(function() SkillScriptManager.Instance.model:OpenPetSelectPanel(true) end)
end

function CombatExtendPanel:AdaptIPhoneX()
    -- if MainUIManager.Instance.adaptIPhoneX then
    --     if Screen.orientation == ScreenOrientation.LandscapeRight then
    --         self.extraX = 0
    --         self.switchcon_close.transform.anchoredPosition = Vector2(237, 0)
    --     else
    --         self.switchcon_close.transform.anchoredPosition = Vector2(280, 0)
    --         self.extraX = 40
    --     end
    -- else
    --     self.switchcon_close.transform.anchoredPosition = Vector2(237, 0)
    --     self.extraX = 0
    -- end

    if self.isShow then
        self:ShowExtendButton()
    else
        self:HideExtendButton()
    end
    BaseUtils.AdaptIPhoneX(self.transform)
end

