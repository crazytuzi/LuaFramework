-- 战斗UI 杂七杂八
CombatMixPanel = CombatMixPanel or BaseClass()

function CombatMixPanel:__init(file, mainPanel)
    self.file = file
    self.mainPanel = mainPanel
    self:InitPanel()
end

function CombatMixPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(self.file))
    self.transform = self.gameObject.transform
    self.combatMgr = CombatManager.Instance
    UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.gameObject)

    self.targetHaloButton = nil
    self.backToControlImage = nil
    self.fighterInfoTop = nil
    self.skillShoutPanel = nil
    self.skillShoutImage = nil
    self.buffPanel = nil
    self.BuffDetailPanel = nil
    self.TalkBubblePanel = nil
    self.UnitTalkBubblePanel = nil
    self.CommandItem = nil

    self.HoldEffect = nil
    self.isdown = false
    self.downtime = 0

    self.FinalWinPanel = nil
    self.FinalLosePanel = nil

    -- self.maskImage = self.gameObject.transform:Find ("MaskImage").gameObject
    self.targetHaloButton = self.gameObject.transform:Find ("TargetHeloButton").gameObject;
    self.backToControlImage = self.gameObject.transform:Find ("BackToControlImage").gameObject
    self.preSkillImage = self.gameObject.transform:Find ("PreSkillImage").gameObject
    self.fighterInfoTop = self.gameObject.transform:Find("FighterInfoTop").gameObject
    self.skillShoutPanel = self.gameObject.transform:FindChild("SkillShoutPanel").gameObject
    self.skillShoutImage = self.skillShoutPanel.transform:FindChild("SkillShoutImage").gameObject
    self.skillShoutText = self.skillShoutPanel.transform:FindChild("SkillShoutText").gameObject
    self.shoutTextPanel = self.skillShoutPanel.transform:FindChild("ShoutTextPanel").gameObject
    self.HoldEffect = self.gameObject.transform:Find("HoldEffect").gameObject
    self.CommandItem = self.gameObject.transform:Find("Command").gameObject

    self.buffPanel = self.gameObject.transform:FindChild ("BuffPanel").gameObject

    self.backToControlImage.transform:Find("BackToControlButton").gameObject:GetComponent(Button).onClick:AddListener(function() self:DoBackToControlButtonClick() end)
    self.smallSkillIcon = self.backToControlImage.transform:FindChild("SmallSkillIcon").gameObject
    self.smallSkillIconImg = SingleIconLoader.New(self.smallSkillIcon)
    -- self.defaultIcon = self.smallSkillIcon:GetComponent(Image).sprite
    self.defaultIcon = "s1001"
    self.skillName = self.backToControlImage.transform:Find("SkillName"):GetComponent(Text)
    self.textImagePanel = self.transform:FindChild("TextImagePanel").gameObject
    self.BuffEffectImage = self.textImagePanel.transform:Find("BuffEffectImage").gameObject
    self.DeBuffEffectImage = self.textImagePanel.transform:Find("DeBuffEffectImage").gameObject
    self.MissBuffImage = self.textImagePanel.transform:Find("MissBuffImage").gameObject
    self.UnUseImage = self.textImagePanel.transform:Find("UnUseImage").gameObject
    self.PreparingImage = self.textImagePanel.transform:Find("PreparingImage").gameObject
    self.AttrChange = self.textImagePanel.transform:Find("AttrChange").gameObject
    self.Absorb = self.textImagePanel.transform:FindChild("Absorb").gameObject
    self.Block = self.textImagePanel.transform:FindChild("Block").gameObject

    self.preSkillImage_smallSkillIcon = self.preSkillImage.transform:FindChild("SmallSkillIcon").gameObject
    self.preSkillImage_smallSkillIconImg = SingleIconLoader.New(self.preSkillImage_smallSkillIcon)
    self.preSkillImage_skillName = self.preSkillImage.transform:Find("SkillName"):GetComponent(Text)

    self.BuffDetailPanel = self.gameObject.transform:FindChild("BuffDetailPanel").gameObject
    self.BuffDetailPanel.transform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnCloseBuffDetailPanel() end)
    self.BuffDetailPanel.transform:FindChild("ClosePanel"):GetComponent(Button).onClick:AddListener(function() self:OnCloseBuffDetailPanel() end)
    -- event_manager:GetUIEvent(self.BuffDetailPanel.transform:FindChild("ClosePanel").gameObject).OnClick:AddListener(function()  self:OnCloseBuffDetailPanel() end)

    self.TalkBubblePanel = self.transform:FindChild("TalkBubble").gameObject
    self.UnitTalkBubblePanel = self.transform:FindChild("UnitTalkBubble").gameObject

    -- self.FinalWinPanel = self.transform:FindChild ("FinalWinPanel").gameObject
    -- self.FinalLosePanel = self.transform:FindChild ("FinalLosePanel").gameObject
    self.PassiveSkillPanel = self.transform:FindChild ("PassiveSkillPanel").gameObject
    -- self.AutoFightingImage = self.transform:FindChild("AutoFightingImage").gameObject
    self.TotalHurtImage = self.textImagePanel.transform:FindChild("TotalHurtImage").gameObject
    self.SkipWatching = self.transform:Find("WatchingSkip").gameObject
    self.ExitWatching = self.transform:Find("WatchingExit").gameObject
    self.DanmakuSendButton = self.transform:Find("DanmakuSendButton").gameObject
    self.cdText = self.transform:Find("DanmakuSendButton/cd"):GetComponent(Text)
    self.DanmakuSendButton.transform:GetComponent(Button).onClick:AddListener(function() self:OnDanmakuSend() end)
    self.DanmakuOptionButton = self.transform:Find("DanmakuOptionButton").gameObject
    self.DanmakuOptionButton.transform:GetComponent(Button).onClick:AddListener(function() self:OnDanmakuOption() end)
    self.DanmakuSwitchButton = self.transform:Find("DanmakuSwitchButton").gameObject
    self.DanmakuSwitchIcon = self.transform:Find("DanmakuSwitchButton/Icon").gameObject
    self.DanmakuSwitchopenIcon = self.transform:Find("DanmakuSwitchButton/open").gameObject
    self.DanmakuSwitchButton.transform:GetComponent(Button).onClick:AddListener(function() self:OnDanmakuSwitch() end)


    self.SkipWatching.transform:GetComponent(Button).onClick:AddListener(function() self.combatMgr:SkipRound() end)
    self.ExitWatching.transform:GetComponent(Button).onClick:AddListener(function() self:OnClickWatchingExit() end)

    self.watchRewardButton = self.gameObject.transform:Find("WatchRewardButton").gameObject
    self.watchSkillItem =  WatchSkillItem.New(self.gameObject.transform:Find("WatchingSkill").gameObject)
    self.watchRewardItemPanel = WatchRewardItemPanel.New(self.gameObject.transform:Find("WatchRewardItemPanel").gameObject, self.watchRewardButton)
    self.combatVotePanel = CombatVotePanel.New(self.gameObject.transform:Find("VotePanel").gameObject)

    self.SkipWatching:SetActive(self.combatMgr.isWatchRecorder)
    self.ExitWatching:SetActive(self.combatMgr.isWatching or self.combatMgr.isWatchRecorder)

    self:UpdateWatchingButton()

    -- self.AutoFightingImage:SetActive(false)
    self.AttrChgDict = {}

    self.PlayerInfoCanvas = self.transform:Find("PlayerInfoCanvas")
    self.NumStrCanvas = self.transform:Find("NumStrCanvas")
    self.StaticItemCanvas = self.transform:Find("StaticItemCanvas")
    EventMgr.Instance:AddListener(event_name.combat_danmaku_cd, function() if self.combatMgr.isFighting then self:OnCoolDown() end end)
    DanmakuManager.Instance.OnDanmakuSwitch:Add(function()
        self.DanmakuSwitchIcon:SetActive(DanmakuManager.Instance.model.isshow)
        self.DanmakuSwitchopenIcon:SetActive(not DanmakuManager.Instance.model.isshow)
    end)

    self:CreatePreSkillImageEffect()
end

function CombatMixPanel:__delete()
    if self.smallSkillIconImg ~= nil then
        self.self.smallSkillIconImg:DeleteMe()
        self.self.smallSkillIconImg = nil
    end
    if self.preSkillImage_smallSkillIconImg ~= nil then
        self.preSkillImage_smallSkillIconImg:DeleteMe()
        self.preSkillImage_smallSkillIconImg = nil
    end
    if self.watchSkillItem ~= nil then
        self.watchSkillItem:DeleteMe()
        self.watchSkillItem = nil
    end
    if self.watchRewardItemPanel ~= nil then
        self.watchRewardItemPanel:DeleteMe()
        self.watchRewardItemPanel = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
end

function CombatMixPanel:Show()
    CombatUtil.DestroyChildActive(self.PlayerInfoCanvas.gameObject, true)
    CombatUtil.DestroyChildActive(self.NumStrCanvas.gameObject, true)
    CombatUtil.DestroyChildActive(self.StaticItemCanvas.gameObject, true)
    self.SkipWatching:SetActive(self.combatMgr.isWatchRecorder)
    self.ExitWatching:SetActive(self.combatMgr.isWatching or self.combatMgr.isWatchRecorder)

    self:UpdateWatchingButton()

    self:OnCloseBuffDetailPanel()
end

function CombatMixPanel:DoBackToControlButtonClick()
    if self.mainPanel.skillareaPanel.petPanel ~= nil and self.mainPanel.skillareaPanel.petPanel.activeSelf == true then
        self.mainPanel:OnBackToControlButtonClick("Pet")
    else
        self.mainPanel:OnBackToControlButtonClick("Role")
    end
end

function CombatMixPanel:GetAttrChgImage()
end

function CombatMixPanel:HideBackToControlImage()
    self.backToControlImage:SetActive(false)
end

function CombatMixPanel:ShowBackToControlImage(skillId, skillLev, fromType)
    -- local roleSkill = CombatManager.Instance:GetRoleSkillObject(skillId, skillLev)
    local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, skillLev)
    local roleSkill = CombatManager.Instance:GetCombatSkillObject(skillId, skillLev, 0)
    self.skillName.text = TI18N("普通攻击")

    if roleSkill ~= nil then
        if roleSkill.icon == nil then
            self.smallSkillIconImg:SetSprite(SingleIconType.SkillIcon, self.defaultIcon)
        else
            self.smallSkillIconImg:SetSprite(SingleIconType.SkillIcon, roleSkill.icon)
        end

        self.skillName.text = roleSkill.name
    else
        if fromType == "Pet" then
            local petskilldata = DataSkill.data_petSkill[tostring(skillId).."_1"]
            if petskilldata ~= nil then
                self.smallSkillIconImg:SetSprite(SingleIconType.SkillIcon, petskilldata.icon)
                self.skillName.text = petskilldata.name
            else
                self.smallSkillIconImg:SetSprite(SingleIconType.SkillIcon, self.defaultIcon)    
            end
        else
            self.smallSkillIconImg:SetSprite(SingleIconType.SkillIcon, self.defaultIcon)
        end
    end
    if combatSkill.target_type == SkillTargetType.All then
        self.backToControlImage.transform.anchoredPosition = Vector2.zero
    elseif combatSkill.target_type == SkillTargetType.Enemy then
        self.backToControlImage.transform.anchoredPosition = Vector2(110, -45)
    elseif combatSkill.target_type == SkillTargetType.SelfGroup then
        self.backToControlImage.transform.anchoredPosition = Vector2(-110, 45)
    elseif combatSkill.target_type == SkillTargetType.Self then
        self.backToControlImage.transform.anchoredPosition = Vector2(-110, 45)
    elseif combatSkill.target_type == SkillTargetType.SelfGroupNotSelf then
        self.backToControlImage.transform.anchoredPosition = Vector2(-110, 45)
    elseif combatSkill.target_type == SkillTargetType.Couple then
        self.backToControlImage.transform.anchoredPosition = Vector2(-110, 45)
    elseif combatSkill.target_type == SkillTargetType.None then
        self.backToControlImage.transform.anchoredPosition = Vector2.zero
    elseif combatSkill.target_type == SkillTargetType.EnemyGroupPet then
        self.backToControlImage.transform.anchoredPosition = Vector2(110, -45)
    elseif combatSkill.target_type == SkillTargetType.SelfGroupPet then
        self.backToControlImage.transform.anchoredPosition = Vector2(-110, 45)
    end
    self.backToControlImage:SetActive(true)
    self.backToControlImage.transform:SetAsLastSibling()
end

function CombatMixPanel:HidePreSkillImage()
    self.preSkillImage:SetActive(false)
    -- self.maskImage:SetActive(false)
end

function CombatMixPanel:ShowPreSkillImage(skillId, skillLev, fromType)
    local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, skillLev)
    local roleSkill = CombatManager.Instance:GetCombatSkillObject(skillId, skillLev, 0)
    self.preSkillImage_skillName.text = TI18N("普通攻击")
    if roleSkill ~= nil then
        -- local sprite = nil
        -- if fromType == "Pet" then
        --     sprite = PreloadManager.Instance:GetPetSkillSprite(roleSkill.icon)
        -- else
        --     sprite = CombatManager.Instance.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(roleSkill.icon))
        --     if sprite == nil then
        --         sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(roleSkill.icon))
        --     end
        --     if sprite == nil then
        --         sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(roleSkill.icon))
        --     end
        --     if sprite == nil then
        --         sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.talisman_skill, tostring(roleSkill.icon))
        --     end
        -- end
        -- if sprite ~= nil then
        --     self.preSkillImage_smallSkillIconImg.sprite = sprite
        -- else
        --     self.preSkillImage_smallSkillIconImg.sprite = self.defaultIcon
        -- end
        if roleSkill.icon == nil then
            self.preSkillImage_smallSkillIconImg:SetSprite(SingleIconType.SkillIcon, self.defaultIcon)
        else
            self.preSkillImage_smallSkillIconImg:SetSprite(SingleIconType.SkillIcon, roleSkill.icon)
        end
        local skillName = StringHelper.Split(roleSkill.name, "·")
        self.preSkillImage_skillName.text = skillName[1]
    end
    self.preSkillImage:SetActive(true)
    self.preSkillImage.transform:SetAsLastSibling()
    -- self.maskImage:SetActive(true)
end

function CombatMixPanel:OnCloseBuffDetailPanel()
    self.BuffDetailPanel:SetActive(false)
end

-- 显示长按特效
function CombatMixPanel:ShowHoldEffect(position)
    self.HoldEffect.transform.localPosition = Vector3(position.x, position.y, -20)
    self.HoldEffect:SetActive(true)
end
-- 隐藏长按特效
function CombatMixPanel:HidHoldEffect()
    self.HoldEffect:SetActive(false)
end

function CombatMixPanel:InitCommandPanel()
    local enterdata = self.mainPanel.controller.enterData
    self.commandpanel = self.BuffDetailPanel.transform:Find("CommandPanel").gameObject
    self.BuffDetailPanel.transform:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    self.BuffDetailPanel.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function ()
        self.commandpanel:SetActive(self.commandpanel.activeSelf == false)
        -- if not mod_team.has_team() or mod_team.myteam_state == 0 or mod_team.myteam_state == 2 then
        -- else
        --     mod_notify.append_scroll_win(TI18N("队长功能呢"))
        -- end
    end)
    self.BuffDetailPanel.transform:Find("Button").gameObject:SetActive(not (self.combatMgr.isWatching or self.combatMgr.isWatchRecorder) )
    local t = self.commandpanel.transform
    for i=1,8 do
        -- utils.add_down_up_scale(self.commandpanel.transform:Find(tostring(i)).gameObject)
        local cButton = t:Find(tostring(i)).gameObject:GetComponent(Button)
        cButton.onClick:RemoveAllListeners()
        cButton.onClick:AddListener(function() self.mainPanel.controller:OnCommandClick(i) self:OnCloseBuffDetailPanel() end)
    end
    for k,v in pairs(enterdata.fighter_list) do
        -- if v.self_preside_status == 6 then
            self:CreatOrGetCommand(v.id, v.self_preside_text, {self_preside_status = v.self_preside_status, self_preside_text = v.self_preside_text, target_preside_status = v.target_preside_status, target_preside_text = v.target_preside_text})
        -- else
            -- self:CreatOrGetCommand(v.id, v.self_preside_status, {self_preside_status = v.self_preside_status, self_preside_text = v.self_preside_text, target_preside_status = v.target_preside_status, target_preside_text = v.target_preside_text})
        -- end
    end

end
-- 创建获取战斗指令
-- more_data用于初始化时候区分己方和敌方指挥
-- {uint8, self_preside_status, "己方指挥状态"}
-- ,{string, self_preside_text, "己方指挥文字"}
-- ,{uint8, target_preside_status, "敌方指挥状态"}
-- ,{string, target_preside_text, "敌方指挥文字"}
function CombatMixPanel:CreatOrGetCommand(fighterID,command, more_data)
    if self.combatMgr.isWatching or not self.combatMgr.isFighting then
        return
    end
    local fctr = self.mainPanel.controller.brocastCtx:FindFighter(fighterID)
    if fctr == nil or BaseUtils.isnull(fctr.transform) then
        return
    end
    local selfgroup = fctr.fighterData.group == self.mainPanel.controller.selfData.group
    if self.combatMgr.isWatchRecorder then
        selfgroup = false
    end
    if more_data ~= nil then
        if selfgroup then
            if more_data.self_preside_status == 6 then
                command = more_data.self_preside_text
            else
                command = more_data.self_preside_status
            end
        else
            if more_data.target_preside_status == 6 then
                command = more_data.target_preside_text
            else
                command = more_data.target_preside_status
            end
        end
    end
    local newcommand = nil
    local key = string.format("Command%s", tostring(fighterID))
    if self.mainPanel.commandList ~= nil and next(self.mainPanel.commandList) ~= nil then
        newcommand = self.mainPanel.commandList[key]
    end
    if newcommand == nil then
        -- newcommand = CombatManager.Instance.objPool:Pop("CommandItem")
        if newcommand == nil then
            newcommand = GameObject.Instantiate(self.CommandItem)
        end
        newcommand.transform:SetParent(self.StaticItemCanvas)
        newcommand.transform.localScale = Vector3.one
        newcommand.name = key
        self.mainPanel.commandList[key] = newcommand
        -- table.insert(self.mainPanel.controller.uiResCacheList, {id = "CommandItem", go = newcommand})
    end

    local fp = fctr.transform.position
    local sp = CombatUtil.WorldToUIPoint(self.mainPanel.controller.combatCamera, fp)
    newcommand.transform.localPosition = Vector3(sp.x, sp.y + 20, 1)
    if command == nil or command == 0 or command == "" then
        newcommand:SetActive(false)
    elseif command ~= 7 then
        if type(command) == "string" then
            newcommand.transform:Find("Text"):GetComponent(Text).text =  command
        elseif not selfgroup then
            newcommand.transform:Find("Text"):GetComponent(Text).text =  TargetCombatCommand[command]
        elseif selfgroup then
            newcommand.transform:Find("Text"):GetComponent(Text).text =  SelfCombatCommand[command]
        end
        newcommand:SetActive(true)
        local canvasgroup = newcommand.transform:GetComponent(CanvasGroup) or newcommand.transform.gameObject:AddComponent(CanvasGroup)
        canvasgroup.blocksRaycasts = false
    end
    return newcommand
end

function CombatMixPanel:HidCommand(fighterID)
    local key = string.format("Command%s", tostring(fighterID))
    if self.mainPanel.commandList ~= nil and next(self.mainPanel.commandList) ~= nil then
        if self.mainPanel.commandList[key] ~= nil then
            self.mainPanel.commandList[key]:SetActive(false)
        end
    end
end

function CombatMixPanel:OnClickWatchingExit()
    self.mainPanel.controller:ExitWatching()
end

function CombatMixPanel:UpdateCmdPanel(group)
    if group ~= self.mainPanel.controller.selfData.group then
        for i=1,5 do
            local str = self:GetTargetCmd(i)
            local cButton = self.commandpanel.transform:Find(tostring(i).."/Text").gameObject:GetComponent(Text)
            cButton.text = str
        end
    else
        for i=1,5 do
            local str = self:GetSelfCmd(i)
            local cButton = self.commandpanel.transform:Find(tostring(i).."/Text").gameObject:GetComponent(Text)
            cButton.text = str
        end
    end
end

function CombatMixPanel:GetSelfCmd(id)
    local str = nil
    for i,v in ipairs(self.combatMgr.self_preside) do
        if v.flag1 == id then
            str = v.text2
        end
    end
    if str == nil then
        str = SelfCombatCommand[id]
    end
    return str
end

function CombatMixPanel:GetTargetCmd(id)
    local str = nil
    for i,v in ipairs(self.combatMgr.target_preside) do
        if v.flag2 == id then
            str = v.text2
        end
    end
    if str == nil then
        str = TargetCombatCommand[id]
    end
    return str
end

function CombatMixPanel:OnDanmakuSend()
    if self.iscd then
        NoticeManager.Instance:FloatTipsByString(TI18N("弹幕发言冷却中，请稍后再试"))
        return
    end
    local args = {
        defaultstr = "",
        sendCall = function(msg)
            if self.combatMgr.isWatchRecorder then
                self.combatMgr:Send10769(msg, self.mainPanel.round)
            else
                ChatManager.Instance:Send10426(msg)
            end
        end
    }
    DanmakuManager.Instance.model:OpenPanel(args)
end

function CombatMixPanel:OnDanmakuOption()
    DanmakuManager.Instance.model:OpenHisPanel()
end

function CombatMixPanel:OnDanmakuSwitch()
    if DanmakuManager.Instance.model.isshow then
        DanmakuManager.Instance.model:Hide()
        NoticeManager.Instance:FloatTipsByString(TI18N("成功屏蔽弹幕"))
        self.DanmakuSwitchIcon:SetActive(false)
        self.DanmakuSwitchopenIcon:SetActive(true)
    else
        DanmakuManager.Instance.model:Show()
        NoticeManager.Instance:FloatTipsByString(TI18N("成功开启弹幕"))
        self.DanmakuSwitchIcon:SetActive(true)
        self.DanmakuSwitchopenIcon:SetActive(false)
    end
end

-- 弹幕冷却
function CombatMixPanel:OnCoolDown()
    local icon = self.DanmakuSendButton.transform:GetComponent(Image)
    BaseUtils.SetGrey(icon, true)
    local count = 10
    self.iscd = true
    LuaTimer.Add(0, 1000, function()
        if count == 0 then
            self.cdText.text = ""
            BaseUtils.SetGrey(icon, false)
            self.iscd = false
            return false
        else
            self.cdText.text = string.format(TI18N("%s秒"), tostring(count))
            count = count - 1
        end
    end)
end

function CombatMixPanel:CreatePreSkillImageEffect()
    local effectObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20023)))
    effectObject.transform:SetParent(self.preSkillImage.transform)
    effectObject.name = "Effect"
    effectObject.transform.localScale = Vector3.one
    effectObject.transform.localPosition = Vector3(0, 0, -400)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
end

function CombatMixPanel:ShowWatchSkillItem(watchSkillData)
    xpcall(function() 
            if self.watchSkillItem ~= nil then
                if watchSkillData ~= nil then
                    self.watchSkillItem:Show(watchSkillData)
                else
                    self.watchSkillItem:Hide()
                end
            end
        end, function()  Log.Error(debug.traceback()) end )
end

function CombatMixPanel:ShowWatchRewardItem(data)
    xpcall(function() 
            if self.watchRewardItemPanel ~= nil then
                if data ~= nil then
                    self.watchRewardItemPanel:SetInfo(data)
                end
                self.watchRewardItemPanel:Show()
            end
        end, function()  Log.Error(debug.traceback()) end )
end

function CombatMixPanel:ShowCombatVotePanel(combatType)
    xpcall(function() 
            if combatType == CombatUtil.CombatType.combat_type_gods_challenge then
                self.combatVotePanel:SetActive(true)
            else
                self.combatVotePanel:SetActive(false)
            end
        end, function()  Log.Error(debug.traceback()) end )
end

function CombatMixPanel:UpdateWatchingButton()
    if self.combatMgr.isWatching or self.combatMgr.isWatchRecorder then
        self.DanmakuSendButton:SetActive(true)
        self.DanmakuSwitchButton:SetActive(true)
        self.DanmakuSwitchIcon:SetActive(true)
        self.DanmakuSwitchopenIcon:SetActive(false)
        self.watchRewardButton:SetActive(false)
        if self.combatMgr.isWatching then
            if CombatUtil.ShowDamakuWatchType[self.combatMgr.combatType] then
                if DataCombatSkill.data_watch_skill[self.combatMgr.combatType] then -- 有观战技能的时候
                    self.DanmakuSendButton.transform.anchoredPosition3D = Vector3(-216, 134, 0)
                    self.DanmakuSwitchButton.transform.anchoredPosition3D = Vector3(-158, 134, 0)

                    self.DanmakuOptionButton:SetActive(false)
                    self.watchRewardButton:SetActive(true)
                    self.watchRewardItemPanel:Show()
                    
                    self:ShowWatchSkillItem(DataCombatSkill.data_watch_skill[self.combatMgr.combatType])
                else
                    self.DanmakuSendButton.transform.anchoredPosition3D = Vector3(-100, 134, 0)
                    self.DanmakuSwitchButton.transform.anchoredPosition3D = Vector3(-42, 134, 0)
                    self.DanmakuOptionButton:SetActive(false)    

                    self:ShowWatchSkillItem(nil)
                end
            else
                self.DanmakuSendButton:SetActive(false)
                self.DanmakuSwitchButton:SetActive(false)
                self.DanmakuOptionButton:SetActive(false)

                self:ShowWatchSkillItem(nil)
            end

            self:ShowCombatVotePanel(self.combatMgr.combatType)
        else
            if CombatManager.Instance.currRecData ~= nil then
                self.DanmakuOptionButton:SetActive(true)
                self.DanmakuSendButton.transform.anchoredPosition3D = Vector3(-216, 134, 0)
                self.DanmakuSwitchButton.transform.anchoredPosition3D = Vector3(-158, 134, 0)
                self.DanmakuOptionButton.transform.anchoredPosition3D = Vector3(-100, 134, 0)
            else
                self.DanmakuSendButton:SetActive(false)
                self.DanmakuSwitchButton:SetActive(false)
                self.DanmakuOptionButton:SetActive(false)
            end

            self:ShowWatchSkillItem(nil)
            self:ShowCombatVotePanel(nil)
        end
    else
        self.DanmakuSendButton:SetActive(false)
        self.DanmakuOptionButton:SetActive(false)
        self.DanmakuSwitchButton:SetActive(false)
        self.watchRewardButton:SetActive(false)

        self:ShowWatchSkillItem(nil)
        self:ShowCombatVotePanel(self.combatMgr.combatType)
    end
end