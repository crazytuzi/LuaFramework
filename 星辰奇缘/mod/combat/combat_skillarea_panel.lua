-- 技能面板
-- 2016-5-24 怒气技能扩充 huangzefeng
-- 2016年09月09日15:56 宠物图集改为界面内加载
-- 2017年09月07日 增加前置技能，前置技能不占用出手次数
-- 2018年05月08日 增加宠物的前置技能，前置技能不占用出手次数
CombatSkilareaPanel = CombatSkilareaPanel or BaseClass()

function CombatSkilareaPanel:__init(file, mainPanel)
    self.file = file
    self.mainPanel = mainPanel

    self.first = true
    self.currPanelType = CombatUtil.SkillPanelType.None
    self.HoldTag = false
    self.ischild = false
    self.HoldTime = 0
    local callback = function()
        self:InitPanel()
    end
    self.resList = {

    }

    self.isShow = true
    self.adaptListener = function() self:AdaptIPhoneX() end

    self.roleSkillIconLoaderList = {}
    self.petSkillIconLoaderList = {}

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(self.resList, callback)
end

function CombatSkilareaPanel:InitPanel()
    if CombatManager.Instance.assetWrapper == nil then
        Log.Error("Combat Resources Unloaded, assetWrapper is nill,Init CombatSkilareaPanel Failed")
        return
    end
    self.gameObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(self.file))
    self.transform = self.gameObject.transform
    self.transform:SetSiblingIndex(2)
    self.combatMgr = CombatManager.Instance
    self.isHide = false
    self.IsMoving = false
    self.hideWidth = 277
    self.pethideWidth = 219

    self.downtime = 0
    self.isdown = false

    self.skillDict = {}
    self.petskillDict = {}

    UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.gameObject)

    self.rolePanel = self.gameObject.transform:FindChild ("BgImage").gameObject
    self.petPanel = self.gameObject.transform:FindChild ("PetBgImage").gameObject

    self.mash = self.transform:Find("BgImage/Mash")
    self.Spmash = self.transform:Find("BgImage/SpMash")
    self.grid = self.gameObject.transform:FindChild ("BgImage/Mash/Grid").gameObject
    self.Spgrid = self.gameObject.transform:FindChild ("BgImage/SpMash/Grid").gameObject

    self.baseIcon = self.grid.transform:FindChild ("BaseIcon").gameObject
    self.SpbaseIcon = self.Spgrid.transform:FindChild ("BaseIcon").gameObject
    self.moreicon = self.gameObject.transform:Find("BgImage/More").gameObject
    self.rolescrollrect = self.gameObject.transform:FindChild ("BgImage/Mash"):GetComponent(ScrollRect)
    self.skillLeft = self.transform:Find("RR").gameObject
    self.skillRight = self.transform:Find("BgImage/RL").gameObject
    self.skillLeft:GetComponent(Button).onClick:AddListener(function() self:ShowHidePanel(true) end)
    self.skillRight:GetComponent(Button).onClick:AddListener(function() self:ShowHidePanel(false) end)
    self.skillRight:SetActive(true)
    self.skillLeft:SetActive(false)

    self.petmash = self.transform:Find("PetBgImage/Mash")
    self.petSpmash = self.transform:Find("PetBgImage/SpMash")
    self.petGrid = self.gameObject.transform:FindChild ("PetBgImage/Mash/Grid").gameObject
    self.petSpGrid = self.gameObject.transform:FindChild ("PetBgImage/SpMash/Grid").gameObject
    self.basePetIcon = self.petGrid.transform:FindChild ("BaseIcon").gameObject
    self.SpbasePetIcon = self.petSpGrid.transform:FindChild ("BaseIcon").gameObject
    self.PetSkillLeft = self.transform:Find("PR").gameObject
    self.PetSkillRight = self.transform:Find("PetBgImage/PL").gameObject
    self.PetSkillLeft:GetComponent(Button).onClick:AddListener(function() self:ShowHidePanel(true) end)
    self.PetSkillRight:GetComponent(Button).onClick:AddListener(function() self:ShowHidePanel(false) end)
    self.PetSkillRight:SetActive(true)
    self.PetSkillLeft:SetActive(false)

    self.holdeffect = self.gameObject.transform:FindChild("HoldEffect").gameObject
    Utils.ChangeLayersRecursively(self.holdeffect.transform, "UI")
    self.holdeffect.layer = 5
    self.holdeffect:GetComponent(SpriteRenderer).sortingOrder = 5

    self.baseIcon:SetActive(false)
    self.SpbaseIcon:SetActive(false)
    self.basePetIcon:SetActive(false)
    self.SpbasePetIcon:SetActive(false)
    -- self.gameObject:SetActive(false)

    self.ShowState = CombatSeletedState.Idel -- hide
    self.originPos = self.rolePanel.transform.anchoredPosition
    self.PetoriginPos = self.petPanel.transform.anchoredPosition
    self.originRHidePos = Vector2(self.originPos.x + self.hideWidth, self.originPos.y)
    self.originPHidePos = Vector2(self.originPos.x + self.pethideWidth, self.originPos.y)
    self.rolePanel:SetActive(false)
    self.petPanel:SetActive(false)

    self.tabBtn = self.transform:Find("BgImage/TabButtonGroup").gameObject
    self.tabgroup = TabGroup.New(self.tabBtn, function (tab) self:OnTabChange(tab) end)
    local setting = {
        column = 3
        ,cspacing = 23
        ,rspacing = 14
        ,cellSizeX = 64
        ,cellSizeY = 64
        ,scrollRect = self.grid.transform.parent
    }
    local setting1 = {
        column = 2
        ,cspacing = 0
        ,rspacing = 5
        ,cellSizeX = 64
        ,cellSizeY = 64
        ,scrollRect = self.petGrid.transform.parent
    }
    self.RoleLayout = LuaGridLayout.New(self.grid.transform, setting)
    self.RoleSpLayout = LuaGridLayout.New(self.Spgrid.transform, setting)
    self.PetLayout = LuaGridLayout.New(self.petGrid.transform, setting)
    self.PetSpLayout = LuaGridLayout.New(self.petSpGrid.transform, setting)
    self.freeCdIconList = {}
    self.preSkillId = nil -- 前置技能
    self.petPreSkillId = nil  -- 宠物的前置技能

    self:CreateIconEffect()
    self:AfterInitPanel()
    -- xpcall(function() self:AfterInitPanel() end,
    --         function()  Log.Error(debug.traceback()) end )

    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)
    self:AdaptIPhoneX()
end

function CombatSkilareaPanel:AfterInitPanel(type)
            -- self.grid.transform:GetComponent(GridLayoutGroup).enabled = false
    local skillList = CombatManager.Instance.enterData.skill_infos
    local RoleSkillList = {}
    local RoleSpSkillList = {}
    local ClassSkill = {}
    for _, skill in ipairs(skillList) do
        if skill.skill_type_1 == 0 or skill.skill_type_1 == 3 or skill.skill_type_1 == 4 then
            local skillDatas = skill.skill_data_1
            local length = #skillDatas
            for i = length, 1, -1 do
                local sData = skillDatas[i]
                local skillId = sData.skill_id_1
                local skillLev = sData.skill_lev_1
                local key = CombatUtil.Key(sData.skill_id_1, sData.skill_lev_1)
                if not table.containValue(CombatUtil.specialList, sData.skill_id_1) then
                    local iscp = false
                    local roleSkill = BaseUtils.copytab(DataSkill.data_skill_role[key])
                    local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(sData.skill_id_1, skillLev)
                    if Gskilltype == Skilltype.roleskill then
                        table.insert(ClassSkill, sData.skill_id_1)
                        roleSkill = Gskilldata
                    elseif Gskilltype == Skilltype.wingskill then
                        roleSkill = Gskilldata
                        iscp = false
                    elseif Gskilltype == Skilltype.marryskill then
                        roleSkill = Gskilldata
                        iscp = true
                    elseif Gskilltype == Skilltype.endlessskill then
                        roleSkill = Gskilldata
                        iscp = false
                    else
                        roleSkill = BaseUtils.copytab(DataCombatSkill.data_combat_skill[key])
                        iscp = false
                    end
                    if (roleSkill ~= nil) then
                        roleSkill.iscp = iscp
                        if skill.skill_type_1 == 3 then
                            table.insert(RoleSpSkillList, roleSkill)
                        else
                            table.insert(RoleSkillList, roleSkill)
                        end
                    end
                end
            end
        end
    end
    if #RoleSkillList > 9 then
        self.moreicon:SetActive(true)
        self.rolescrollrect.onValueChanged:AddListener(function (val) self.moreicon:SetActive(val.y>=0.7) end)
    end
    local myclass = RoleManager.Instance.RoleData.classes
    if RoleManager.Instance.RoleData.lev < 55 and self.mainPanel.combatMgr.controller.enterData.combat_type ~= 52 then
        local num = 0
        for i,v in ipairs(SkillManager.Instance.model.role_skill) do
            if num < 2 and v.lev == 0 then
                local roleSkill = DataSkill.data_skill_role[CombatUtil.Key(v.id, 1)]
                if roleSkill.type == 0 then
                    local temp = BaseUtils.copytab(roleSkill)
                    temp.nolearn = true
                    table.insert(RoleSkillList, temp)
                    num = num + 1
                end
            end
        end
    end
    for i,roleSkill in ipairs(RoleSkillList) do
        if (roleSkill ~= nil) then
            if roleSkill.id == 82151 then
                -- 丢雪球技能改为魔法消耗1
                roleSkill.cost_mp = 1
            end
            local skillIcon = GameObject.Instantiate(self.baseIcon)
            local image = skillIcon:GetComponent(Image)
            local iconLoader = SingleIconLoader.New(skillIcon)
            table.insert(self.roleSkillIconLoaderList, iconLoader)

            local CDText = skillIcon.transform:Find("CDText"):GetComponent(Text)
            local Kuang = skillIcon.transform:Find("Kuang")
            Kuang.gameObject:SetActive(false)
            local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(roleSkill.id, roleSkill.lev)
            -- image.sprite = CombatManager.Instance.assetWrapper:GetSprite(Gassest, tostring(Gskilldata.icon))

            skillIcon.name = "skillIcon" .. tostring(roleSkill.id)
            self.RoleLayout:AddCell(skillIcon)
            skillIcon.transform:Find("Lock").gameObject:SetActive(roleSkill.nolearn == true)
            skillIcon.transform:Find("Mash").gameObject:SetActive(roleSkill.nolearn == true)
            image.gameObject:SetActive(roleSkill.nolearn ~= true)
            if roleSkill.nolearn then
                skillIcon.transform:Find("Lock/Text"):GetComponent(Text).text = string.format(TI18N("<color='#ffff00'>%s级</color>"), roleSkill.study_lev)
            end
            skillIcon.transform:FindChild("SkillNameTxt"):GetComponent(Text).text = roleSkill.name
            if roleSkill.cost_mp ~= nil and self.mainPanel.combatMgr.controller.selfData.mp < roleSkill.cost_mp then
                BaseUtils.SetGrey(image, true, true)
            else
                BaseUtils.SetGrey(image, false, true)
            end

            iconLoader:SetSprite(SingleIconType.SkillIcon, Gskilldata.icon)

            if DataCombatUtil.data_power_skill[roleSkill.id] ~= nil then
                skillIcon.transform:FindChild("SkillNameTxt"):GetComponent(Text).color = Color.yellow
            end
            local cButton = skillIcon:GetComponent(CustomButton) or skillIcon:AddComponent(CustomButton)
            cButton.onClick:RemoveAllListeners()
            cButton.onClick:AddListener(function()
                if roleSkill.nolearn then
                    if RoleManager.Instance.RoleData.lev >= roleSkill.study_lev then
                        NoticeManager.Instance:FloatTipsByString(TI18N("该技能尚未习得，赶快打开<color='#ffff00'>技能界面</color>学习吧！"))
                    else
                        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("角色到达<color='#ffff00'>%s</color>级可习得该技能，赶快升级吧！"), roleSkill.study_lev))
                    end
                    return
                end
                if CDText.text ~= "" then
                    NoticeManager.Instance:FloatTipsByString(TI18N("技能冷却中，请选择其他技能"))
                    return
                end
                self:OnSkillIconClick(roleSkill.id, roleSkill.lev)
                end)
            cButton.onDown:AddListener(function () self:OnSkillIconDown(skillIcon) end)
            cButton.onUp:AddListener(function() self:OnSkillIconUp(skillIcon) end);
            cButton.onHold:AddListener(function() self:OnSkillIconHold(skillIcon, Gskilldata, Gskilltype) end);
            skillIcon:SetActive(true)
            self.skillDict[roleSkill.id] = {icon = skillIcon, lev = roleSkill.lev, type = Skilltype.roleskill}


        end
    end

    BaseUtils.dump(RoleSpSkillList,"战斗技能特效==============================================")
    for i,SpSkill in ipairs(RoleSpSkillList) do
        if (SpSkill ~= nil) then
            local skillIcon = GameObject.Instantiate(self.baseIcon)
            local image = skillIcon:GetComponent(Image)
            local iconLoader = SingleIconLoader.New(skillIcon)
            table.insert(self.roleSkillIconLoaderList, iconLoader)

            local CDText = skillIcon.transform:Find("CDText"):GetComponent(Text)
            local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(SpSkill.id, SpSkill.lev)
            -- image.sprite = CombatManager.Instance.assetWrapper:GetSprite(Gassest, tostring(Gskilldata.icon))

            local Kuang = skillIcon.transform:Find("Kuang")
            Kuang.gameObject:SetActive(true)
            skillIcon.name = "skillIcon" .. tostring(SpSkill.id)
            self.RoleSpLayout:AddCell(skillIcon)
            skillIcon.transform:Find("Lock").gameObject:SetActive(false)
            skillIcon.transform:Find("Mash").gameObject:SetActive(false)
            skillIcon.transform:FindChild("SkillNameTxt"):GetComponent(Text).text = SpSkill.name
            local rate = 1
            if self.mainPanel.combatMgr.controller.enterData.use_anger_ratio ~= nil then
                rate = self.mainPanel.combatMgr.controller.enterData.use_anger_ratio/1000
            end
            if self.mainPanel.combatMgr.controller.enterData.anger < Gskilldata.cost_anger * rate then
                BaseUtils.SetGrey(image, true, true)
            else
                BaseUtils.SetGrey(image, false, true)
            end

            iconLoader:SetSprite(SingleIconType.SkillIcon, Gskilldata.icon)

            if DataCombatUtil.data_power_skill[SpSkill.id] ~= nil then
                skillIcon.transform:FindChild("SkillNameTxt"):GetComponent(Text).color = Color.yellow
            end
            local cButton = skillIcon:GetComponent(CustomButton) or skillIcon:AddComponent(CustomButton)
            cButton.onClick:RemoveAllListeners()
            cButton.onClick:AddListener(function()
                if CDText.text ~= "" then
                    NoticeManager.Instance:FloatTipsByString(TI18N("技能冷却中，请选择其他技能"))
                    return
                end
                local rate = 1
                if self.mainPanel.combatMgr.controller.enterData.use_anger_ratio ~= nil then
                    rate = self.mainPanel.combatMgr.controller.enterData.use_anger_ratio/1000
                end
                -- if self.mainPanel.combatMgr.controller.enterData.anger < SpSkill.cost_anger * rate then
                --     NoticeManager.Instance:FloatTipsByString(TI18N("怒气不足，请选择其他技能"))
                --     return
                -- end
                self:OnSkillIconClick(SpSkill.id, SpSkill.lev)
                end)
            cButton.onDown:AddListener(function () self:OnSkillIconDown(skillIcon) end)
            cButton.onUp:AddListener(function() self:OnSkillIconUp(skillIcon) end);
            cButton.onHold:AddListener(function() self:OnSkillIconHold(skillIcon, Gskilldata, Gskilltype) end);
            skillIcon:SetActive(true)
            self.skillDict[SpSkill.id] = {icon = skillIcon, lev = SpSkill.lev, type = Skilltype.wingskill}

                BaseUtils.dump(SpSkill,"id")
            if DataWing.data_skill_energy[SpSkill.id] ~= nil then
                Kuang.gameObject:SetActive(true)
            else
                Kuang.gameObject:SetActive(false)
            end
        end
    end

    if #RoleSpSkillList > 0 then
        self.mainPanel:UpdaFunctionAtkButton(true, false)
        self.tabBtn:SetActive(true)
    else
        self.mainPanel:UpdaFunctionAtkButton(false, false)
        self.tabBtn:SetActive(false)
        self.rolePanel.transform.anchoredPosition = Vector2(-150, 245)
        self.petPanel.transform.anchoredPosition = Vector2(-150, 245)
        self.originPos = self.rolePanel.transform.anchoredPosition
        self.PetoriginPos = self.petPanel.transform.anchoredPosition
    end
end

function CombatSkilareaPanel:InitPetPanel(type)
    self.PetLayout:ReSet()
    for k,v in pairs(self.petSkillIconLoaderList) do
        v:DeleteMe()
        v = nil
    end
    self.petSkillIconLoaderList = {}

    local skillList = self:GetPetSkillList()
    if skillList ~= nil then
        for _, skill in ipairs(skillList) do
            if skill.skill_type_2 == 0 then
                local skillDatas = skill.skill_data_2
                local length = #skillDatas
                for i = length, 1, -1 do
                    local sData = skillDatas[i]
                    local skillId = sData.skill_id_2
                    local skillLev = sData.skill_lev_2
                    local key = CombatUtil.Key(sData.skill_id_2, sData.skill_lev_2)
                    if not table.containValue(CombatUtil.specialList, sData.skill_id_2) then
                        local petSkill = nil
                        -- if self.ischild then
                        --     petSkill = CombatManager.Instance:GetChildSkillData(skillId, skillLev)
                        -- else
                        --     petSkill = CombatManager.Instance:GetPetSkillData(skillId, skillLev)
                        -- end
                        local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(sData.skill_id_2, sData.skill_lev_2)
                        if DataCombatSkill.data_combat_skill[key] ~= nil then
                            for k,v in pairs(DataCombatSkill.data_combat_skill[key]) do
                                Gskilldata[k] = v
                            end
                        end
                        petSkill = Gskilldata
                        if (Gskilldata ~= nil) then
                            local skillIcon = GameObject.Instantiate(self.basePetIcon)
                            local image = skillIcon:GetComponent(Image)
                            local iconLoader = SingleIconLoader.New(skillIcon)
                            table.insert(self.petSkillIconLoaderList, iconLoader)

                            -- xpcall(function()
                            --     if Gassest == "" then Gassest = AssetConfig.skillIcon_pet end
                            --     if AssetConfig.skillIcon_pet == Gassest or AssetConfig.skillIcon_pet2 == Gassest then
                            --         image.sprite = PreloadManager.Instance:GetPetSkillSprite(Gskilldata.icon)
                            --     else
                            --         image.sprite = CombatManager.Instance.assetWrapper:GetSprite(Gassest, tostring(Gskilldata.icon))
                            --     end
                            -- end,
                            -- function()  Log.Error(debug.traceback()) end )
                            if self.mainPanel.combatMgr.controller.selfPetData.mp < petSkill.cost_mp then
                                BaseUtils.SetGrey(image, true, true)
                            else
                                BaseUtils.SetGrey(image, false, true)
                            end

                            iconLoader:SetSprite(SingleIconType.SkillIcon, Gskilldata.icon)

                            skillIcon.name = "skillIcon" .. skillId
                            self.PetLayout:AddCell(skillIcon)
                            skillIcon.transform:FindChild("SkillNameTxt"):GetComponent(Text).text = petSkill.name
                            if DataCombatUtil.data_power_skill[skillId] ~= nil then
                                skillIcon.transform:FindChild("SkillNameTxt"):GetComponent(Text).color = Color.yellow
                            end
                            local cButton = skillIcon:GetComponent(CustomButton) or skillIcon:AddComponent(CustomButton)
                            cButton.onClick:AddListener(function()
                                -- if self.mainPanel.combatMgr.controller.selfPetData.mp < petSkill.cost_mp then
                                --     NoticeManager.Instance:FloatTipsByString(TI18N("魔法值不足，请选择其他技能"))
                                -- else
                                    self:OnPetSkillIconClick(skillId, skillLev)
                                -- end
                            end)
                            cButton.onDown:AddListener(function () self:OnSkillIconDown(skillIcon) end)
                            cButton.onUp:AddListener(function() self:OnSkillIconUp(skillIcon) end);
                            cButton.onHold:AddListener(function() self:OnSkillIconHold(skillIcon.transform, Gskilldata, Gskilltype) end)
                            -- event_manager:GetUIEvent(skillIcon).OnHold:AddListener(function() self:OnSkillIconHold() end);
                            skillIcon:SetActive(true)
                            self.skillDict[skillId] = {icon = skillIcon, lev = skillLev}
                            self.petskillDict[skillId] = {icon = skillIcon, lev = skillLev}
                            if petSkill.cooldown ~= nil and petSkill.cooldown > 0 then
                            end
                        end
                    end
                end
            end
        end
    end
end


function CombatSkilareaPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)
    for k,v in pairs(self.roleSkillIconLoaderList) do
        v:DeleteMe()
        v = nil
    end
    self.roleSkillIconLoaderList = {}

    for k,v in pairs(self.petSkillIconLoaderList) do
        v:DeleteMe()
        v = nil
    end
    self.petSkillIconLoaderList = {}

    BaseUtils.CancelIPhoneXTween(self.transform)

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
end

function CombatSkilareaPanel:OnSkillIconClick(skillId, skillLev)
    if self.HoldTag == true and self.HoldTime+1> Time.time then
        self.HoldTag = false
        return
    end
    self.HoldTag = false
    local selectState = self.mainPanel.selectState
    if selectState ~= CombatSeletedState.Idel then
        local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, skillLev)
        if combatSkill ~= nil and combatSkill.type == 4 and skillId == self.preSkillId then
            -- 取消前置技能
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("是否取消<color='#ffff00'>%s</color>的释放"), combatSkill.name)
            data.sureLabel = TI18N("我再想想")
            data.cancelLabel = TI18N("取消释放")
            data.blueSure = true
            data.greenCancel = true
            data.cancelCallback = function() CombatManager.Instance:Send10772() end
            NoticeManager.Instance:ConfirmTips(data)
        else
            -- 选择角色技能
            self.mainPanel:OnSkillIconClick(skillId, skillLev, "Role")
        end
    end
end
function CombatSkilareaPanel:OnPetSkillIconClick(skillId, skillLev)
    if self.HoldTag == true and self.HoldTime+1> Time.time then
        self.HoldTag = false
        return
    end
    self.HoldTag = false
    local selectState = self.mainPanel.selectState
    if selectState ~= CombatSeletedState.Idel then
        local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, skillLev)
        if combatSkill ~= nil and combatSkill.type == 4 and skillId == self.petPreSkillId then
            -- 取消宠物前置技能
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("是否取消<color='#ffff00'>%s</color>的释放"), combatSkill.name)
            data.sureLabel = TI18N("我再想想")
            data.cancelLabel = TI18N("取消释放")
            data.blueSure = true
            data.greenCancel = true
            data.cancelCallback = function() CombatManager.Instance:Send10774() end
            NoticeManager.Instance:ConfirmTips(data)
        else
            self.mainPanel:OnSkillIconClick(skillId, skillLev, "Pet")
        end
    end
end

function CombatSkilareaPanel:OnSkillIconHold(parent, roleskill, skilltype)
    if roleskill.lev == nil then
        roleskill.key = 1
    end
    local extra = {}
    local key = CombatUtil.Key(roleskill.id, roleskill.lev)
    -- local skillCfg = nil
    -- if DataSkill.data_skill_role[key] ~= nil then
    --     skilltype = Skilltype.roleskill
    --     skillCfg = DataSkill.data_skill_role[key]
    -- elseif DataSkill.data_petSkill[key] ~= nil then
    --     skilltype = Skilltype.petskill
    --     skillCfg = DataSkill.data_petSkill[key]
    -- elseif DataSkill.data_skill_guard[key] ~= nil then
    --     skilltype = Skilltype.shouhuskill
    --     skillCfg = DataSkill.data_skill_guard[key]
    -- elseif DataSkill.data_skill_effect[roleskill.id] ~= nil then
    --     skilltype = Skilltype.roleskill
    --     skillCfg = DataSkill.data_skill_effect[roleskill.id]
    -- elseif DataSkill.data_skill_other[roleskill.id] ~= nil then
    --     skilltype = Skilltype.endlessskill
    --     skillCfg = DataSkill.data_skill_other[roleskill.id]
    -- elseif DataSkill.data_marry_skill[key] ~= nil then
    --     skilltype = Skilltype.marryskill
    --     skillCfg = DataSkill.data_marry_skill[key]
    -- elseif DataSkill.data_wing_skill[key] ~= nil then
    --     skilltype = Skilltype.wingskill
    --     skillCfg = DataSkill.data_wing_skill[key]
    -- elseif DataSkill.data_get_pet_stone[roleskill.id] ~= nil then
    --     skillCfg = DataSkill.data_get_pet_stone[roleskill.id]
    -- elseif DataSkill.data_mount_skill[key] ~= nil then
    --     skilltype = Skilltype.rideskill
    --     skillCfg = DataSkill.data_mount_skill[key]
    -- elseif DataSkill.data_endless_challenge[roleskill.id] ~= nil then
    --     skilltype = Skilltype.endlessskill
    --     skillCfg = DataSkill.data_endless_challenge[roleskill.id]
    -- elseif DataSkill.data_child_skill[roleskill.id] ~= nil then
    --     skilltype = Skilltype.childskill
    --     skillCfg = DataSkill.data_child_skill[roleskill.id]
    --     extra = {classes = math.floor(skillCfg.icon/10000)}
    -- end
    if DataSkill.data_child_skill[roleskill.id] ~= nil then
        -- skilltype = Skilltype.childskill
        -- skillCfg = DataSkill.data_child_skill[roleskill.id]
        extra = {classes = math.floor(DataSkill.data_child_skill[roleskill.id].icon/10000)}
    end

    -- local tipsinfo = {gameObject = parent.gameObject, skillData = skillCfg, type = skilltype, extra = extra}
    local tipsinfo = {gameObject = parent.gameObject, skillData = roleskill, type = skilltype, extra = extra}
    -- if roleskill.iscp then
    --     TipsManager.Instance:ShowSkill({gameObject = parent.gameObject, type = Skilltype.marryskill, skillData = roleskill})
    -- else
        TipsManager.Instance:ShowSkill(tipsinfo)
    -- end
    self.HoldTag = true
    self.HoldTime = Time.time
    -- mod_tips.skill_tips(tipsinfo)
end

function CombatSkilareaPanel:OnSkillIconDown(skillIcon, roleskill)
    self.downtime = Time.time
    self.isdown = true
    LuaTimer.Add(130, function () if self.isdown and Time.time - self.downtime >= 0.1 then
            if not BaseUtils.isnull(self.holdeffect) then
                self.holdeffect.transform.position = Vector3(skillIcon.transform.position.x, skillIcon.transform.position.y+0.3, -0.15)
                self.holdeffect:SetActive(true)
            end
        end end)

end

function CombatSkilareaPanel:OnSkillIconUp(skillIcon)
    self.isdown = false
    self.holdeffect:SetActive(false)
end

function CombatSkilareaPanel:OnAutoSetting(flag, result, msg)
    local selectState = self.mainPanel.selectState
    if flag == 0 and selectState ~= CombatSeletedState.Idel then
        if selectState == CombatSeletedState.Role then
            self:ShowPanel("Role", function() end)
        else
            self:ShowPanel("Pet", function() end)
        end

    else
        self:HidePanel(function() end)
    end
end


function CombatSkilareaPanel:ShowHidePanel(show)
    if self.mainPanel.combatMgr.isWatching or self.mainPanel.combatMgr.isWatchRecorder then
        self:HidePanel(function() end)
        return
    end
    local selectState = self.mainPanel.selectState
    if selectState == CombatSeletedState.Idel then
        if show then
            self:ShowPanel("Role", function() end)
            return
        end
            self:HidePanel(function() end)
        return
    end
    if show then
        if selectState == CombatSeletedState.Role then
            self:ShowPanel("Role", function() end)
        else
            self:ShowPanel("Pet", function() end)
        end
        -- self:ShowAuto(true)
    else
        self:HidePanel(function() end)
    end
end

function CombatSkilareaPanel:UpdateSkillCD(coolDownList)
    self.freeCdIconList = {}
    if coolDownList ~= nil then
        for _, cd in ipairs(coolDownList) do
            local iconLev = self.skillDict[cd.skill_id]
            if iconLev ~= nil then
                local c = cd.cd_left
                local icon = iconLev.icon
                local lev = iconLev.lev
                local skillData = CombatManager.Instance:GetCombatSkillObject(cd.skill_id, lev)
                local mash = icon.transform:FindChild("Mash").gameObject
                -- local halo1 = icon.transform:FindChild("Halo1").gameObject
                -- local halo2 = icon.transform:FindChild("Halo2").gameObject
                -- halo1:SetActive(false)
                -- halo2:SetActive(false)
                local text = icon.transform:FindChild("CDText").gameObject
                -- local cdEffect = icon.transform:FindChild("cd_effect")
                text:GetComponent(Text).text = (c == 0 and "" or tostring(c))
                local mashImage = mash:GetComponent(Image)
                if c == 0 then
                    -- if mashImage.fillAmount ~= 0 then
                    --     if cdEffect ~= nil then
                    --         table.insert(self.freeCdIconList, cdEffect.gameObject)
                    --     end
                    -- end
                    mashImage.fillAmount = 0
                    mash:SetActive(false)
                else
                    mash:SetActive(true)
                    local amount = c / skillData.cooldown
                    mashImage.fillAmount = c / skillData.cooldown
                end
            end
        end
    end
end

-- 角色技能耗魔判断显示
function CombatSkilareaPanel:UpdateSkillMp()

    local skillList = SkillManager.Instance.model.role_skill
    local currmp = self.mainPanel.combatMgr.controller.selfData.mp
    local curranger = self.mainPanel.combatMgr.controller.enterData.anger
    for k,v in pairs(self.skillDict) do
        if v.type ~= Skilltype.petskill then
            local cost_mp = DataSkill.data_skill_role[string.format("%s_%s", tostring(k), tostring(v.lev))]
            if cost_mp == nil then
                cost_mp = DataCombatSkill.data_combat_skill[string.format("%s_%s", tostring(k), tostring(v.lev))]
            end
            local cost_anger = DataSkill.data_wing_skill[string.format("%s_%s", tostring(k), tostring(v.lev))]
            if cost_anger ~= nil then
                cost_anger = cost_anger.cost_anger
            end
            if cost_mp ~= nil then
                cost_mp = cost_mp.cost_mp
                local icon = self.skillDict[k]
                if icon ~= nil and not BaseUtils.isnull(icon.icon) then
                    icon = icon.icon
                    if icon ~= nil then
                        if cost_mp ~= nil and currmp < cost_mp then
                            BaseUtils.SetGrey(icon:GetComponent(Image), true, true)
                        else
                            BaseUtils.SetGrey(icon:GetComponent(Image), false, true)
                        end
                    end
                end
            end
            local rate = 1
            if self.mainPanel.combatMgr.controller.enterData.use_anger_ratio ~= nil then
                rate = self.mainPanel.combatMgr.controller.enterData.use_anger_ratio/1000
            end
            if cost_anger ~= nil then
                local icon = self.skillDict[k]
                if icon ~= nil and not BaseUtils.isnull(icon.icon) then
                    icon = icon.icon
                    if icon ~= nil then
                        if curranger < cost_anger * rate then
                            BaseUtils.SetGrey(icon:GetComponent(Image), true, true)
                        else
                            BaseUtils.SetGrey(icon:GetComponent(Image), false, true)
                        end
                    end
                end
            else
                -- print(string.format("技能%s未开启或者读不到数据，不处理Lev:%s", tostring(v.id), tostring(v.lev)))
            end
        end
    end

    local skillList = self:GetPetSkillList()
    if skillList ~= nil then
        for _, skill in ipairs(skillList) do
            if skill.skill_type_2 == 0 then
                local skillDatas = skill.skill_data_2
                local length = #skillDatas
                for i = length, 1, -1 do
                    local sData = skillDatas[i]
                    local skillId = sData.skill_id_2
                    local skillLev = sData.skill_lev_2
                    local key = CombatUtil.Key(sData.skill_id_2, sData.skill_lev_2)
                    if not table.containValue(CombatUtil.specialList, sData.skill_id_2) then
                        local petSkill = nil
                        if self.ischild then
                            petSkill = CombatManager.Instance:GetChildSkillData(skillId, skillLev)
                        else
                            petSkill = CombatManager.Instance:GetPetSkillData(skillId, skillLev)
                        end
                        local Gskilltype, Gskilldata, Gassest = SkillManager.Instance:GetSkillType(skillId, skillLev)
                        petSkill = Gskilldata
                        if (petSkill ~= nil) then
                            local skillIcon = self.skillDict[skillId]
                            if skillIcon ~= nil then
                                skillIcon = skillIcon.icon
                                local image = skillIcon:GetComponent(Image)
                                if self.mainPanel.combatMgr.controller.selfPetData.mp < petSkill.cost_mp then
                                    BaseUtils.SetGrey(image, true, true)
                                else
                                    BaseUtils.SetGrey(image, false, true)
                                end
                            else
                                Log.Error(string.format("Pet Skill Not Found, id: %s",skillId))
                                self.mainPanel.combatMgr:OnDisConnect()
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 显示选中的前置技能
function CombatSkilareaPanel:UpdatePreSkill()
    if self.preSkillId == nil then -- 如果是取消前置技能，先把图标按照耗蓝重置一遍
        self:UpdateSkillMp()
    end
    for skillId, iconLev in pairs(self.skillDict) do
        if iconLev.type == Skilltype.roleskill or iconLev.type == Skilltype.wingskill then
            local icon = iconLev.icon
            local selectObj = icon.transform:FindChild("Select").gameObject
            local halo2 = icon.transform:FindChild("Halo2").gameObject
            if skillId == self.preSkillId then
                selectObj:SetActive(true)
                halo2:SetActive(false)

                BaseUtils.SetGrey(icon:GetComponent(Image), true, true) -- 把图标置灰，如果取消前置技能需要恢复
            else
                -- 判断是否前置技能
                local lev = iconLev.lev
                local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, lev)
                if combatSkill ~= nil then
                    local halo1 = icon.transform:FindChild("Halo1").gameObject
                    local halo2 = icon.transform:FindChild("Halo2").gameObject
                    local mash = icon.transform:FindChild("Mash").gameObject
                    if mash.activeSelf then
                        halo1:SetActive(false)
                        halo2:SetActive(false)
                        selectObj:SetActive(false)
                    else
                        if nil ~= self.preSkillId and combatSkill.type ~= 4 then
                            halo1:SetActive(true)
                            halo2:SetActive(false)
                        elseif nil == self.preSkillId and combatSkill.type == 4 then
                            halo1:SetActive(false)
                            halo2:SetActive(true)
                        else
                            halo1:SetActive(false)
                            halo2:SetActive(false)
                        end
                        selectObj:SetActive(false)
                        -- BaseUtils.SetGrey(icon:GetComponent(Image), false, true)
                    end
                end
            end
        end
    end
end

function CombatSkilareaPanel:SetPreSkill(preSkillId)
    self.preSkillId = preSkillId
    self:UpdatePreSkill()
end

-- 显示选中的宠物前置技能
function CombatSkilareaPanel:UpdatePetPreSkill()
    for skillId, iconLev in pairs(self.petskillDict) do
        local icon = iconLev.icon
        if not BaseUtils.isnull(icon) then
            local selectObj = icon.transform:FindChild("Select").gameObject
            local halo2 = icon.transform:FindChild("Halo2").gameObject
            if skillId == self.petPreSkillId then
                selectObj:SetActive(true)
                halo2:SetActive(false)

                BaseUtils.SetGrey(icon:GetComponent(Image), true, true)
            else
                -- 判断是否前置技能
                local lev = iconLev.lev
                local combatSkill = self.combatMgr:GetCombatSkillObject(skillId, lev)
                if combatSkill ~= nil then
                    local halo1 = icon.transform:FindChild("Halo1").gameObject
                    local halo2 = icon.transform:FindChild("Halo2").gameObject
                    local mash = icon.transform:FindChild("Mash").gameObject
                    if mash.activeSelf then
                        halo1:SetActive(false)
                        halo2:SetActive(false)
                        selectObj:SetActive(false)
                    else
                        if nil ~= self.petPreSkillId and combatSkill.type ~= 4 then
                            halo1:SetActive(true)
                            halo2:SetActive(false)
                        elseif nil == self.petPreSkillId and combatSkill.type == 4 then
                            halo1:SetActive(false)
                            halo2:SetActive(true)
                        else
                            halo1:SetActive(false)
                            halo2:SetActive(false)
                        end
                        selectObj:SetActive(false)
                        BaseUtils.SetGrey(icon:GetComponent(Image), false, true)
                    end
                end
            end
        end
    end
end

function CombatSkilareaPanel:SetPetPreSkill(petPreSkillId)
    self.petPreSkillId = petPreSkillId
    self:UpdatePetPreSkill()
end

function CombatSkilareaPanel:GetPetSkillList()
    local selfPetData = self.mainPanel.combatMgr.controller.selfPetData
    if selfPetData == nil then
        return nil
    else
        local rid = selfPetData.rid
        if selfPetData.type == FighterType.Child then
            self.ischild = true
            local childList = CombatManager.Instance.enterData.child_skill_infos
            for _, child in ipairs(childList) do
                if rid == child.child_id then
                    local temp = BaseUtils.copytab(child.child_skill_infos)
                    local transferTemp = {}
                    temp.skill_type_2 = temp.skill_type_3
                    temp.skill_data_2 = temp.skill_data_3
                    for k,data in pairs(temp) do
                        transferTemp[k] = {}
                        transferTemp[k].skill_type_2 = data.skill_type_3
                        transferTemp[k].skill_data_2 = {}
                        for kk,vv in pairs(data.skill_data_3) do
                            transferTemp[k].skill_data_2[kk] = {}
                            transferTemp[k].skill_data_2[kk].skill_lev_2 = vv.skill_lev_3
                            transferTemp[k].skill_data_2[kk].skill_id_2 = vv.skill_id_3
                        end
                    end
                    return transferTemp
                end
            end
        else
            self.ischild = false
            local petList = CombatManager.Instance.enterData.pet_skill_infos
            for _, pet in ipairs(petList) do
                if rid == pet.pet_id then
                    return pet.pet_skill_infos
                end
            end
        end

    end
    return nil
end

function CombatSkilareaPanel:ShowPanel(PanelType, callback)
    if not BaseUtils.is_null(self.mainPanel.controller.teamquestPanel) then
        self.mainPanel.controller.teamquestPanel:SetActive(false)
    end
    if self.mainPanel.combatMgr.isWatching or self.mainPanel.combatMgr.isWatchRecorder then
        self:HidePanel(function() end)
        return
    end
    if PanelType == "Role" then
        self.mainPanel.functionIconPanel.ReSelectButton.gameObject:SetActive(false)
        if self.tabgroup ~= nil and self.tabgroup.currentIndex ~= 1 then
            self.tabgroup:ChangeTab(1)
            return
        end
        self.rolePanel:SetActive(true)
        self.petPanel:SetActive(false)
        self.mash.gameObject:SetActive(true)
        self.Spmash.gameObject:SetActive(false)
        self.ShowState = CombatSeletedState.Role
        self.currPanelType = CombatUtil.SkillPanelType.RoleSkill
        self.skillRight:SetActive(true)
        self.skillLeft:SetActive(false)

        self.PetSkillRight:SetActive(false)
        self.PetSkillLeft:SetActive(false)
    elseif PanelType == "SpRole" then
        if self.tabgroup ~= nil and  self.tabgroup.currentIndex ~= 2 then
            self.tabgroup:ChangeTab(2)
            return
        end
        self.rolePanel:SetActive(true)
        self.petPanel:SetActive(false)
        self.mash.gameObject:SetActive(false)
        self.Spmash.gameObject:SetActive(true)
        self.ShowState = CombatSeletedState.Role
        self.currPanelType = CombatUtil.SkillPanelType.RoleSp
        self.skillRight:SetActive(true)
        self.skillLeft:SetActive(false)

        self.PetSkillRight:SetActive(false)
        self.PetSkillLeft:SetActive(false)
    else
        self.mainPanel.functionIconPanel.ReSelectButton.gameObject:SetActive(true)
        self.mainPanel:OnBackToControlButtonClick("Pet")
        self.freeCdIconList = {}

        self.rolePanel:SetActive(false)
        self.petPanel:SetActive(true)
        self.ShowState = CombatSeletedState.Pet
        self.currPanelType = CombatUtil.SkillPanelType.PetSkill
        self.PetSkillRight:SetActive(true)
        self.PetSkillLeft:SetActive(false)

        self.skillRight:SetActive(false)
        self.skillLeft:SetActive(false)
    end
    self.gameObject:SetActive(true)
    self:DoShow(callback)

    self.isShow = true
end

function CombatSkilareaPanel:DoShow(callback)
    if not self.IsMoving then
        self.IsMoving = true
        local call = function()
            self.IsMoving = false
            callback()
            if self.freeCdIconList ~= nil and #self.freeCdIconList > 0 then
                for _, effect in ipairs(self.freeCdIconList) do
                    effect:SetActive(true)
                end
                LuaTimer.Add(3000, function() self:HideCdEffect() end)
            end
        end
        -- CombatUtil.DOLocalMoveX(self.gameObject, self.originPos.x, 0.3, call)
        local pos = self.gameObject.transform:GetComponent(RectTransform).anchoredPosition
        self.rolePanel.transform.anchoredPosition = self.originPos
        self.petPanel.transform.anchoredPosition = self.PetoriginPos
        -- self.gameObject.transform:GetComponent(RectTransform).anchoredPosition = Vector2(self.originPos.x, pos.y)
        call()
    end
end

function CombatSkilareaPanel:HideCdEffect()
    for _, effect in ipairs(self.freeCdIconList) do
        if effect ~= nil then
            if not BaseUtils.isnull(effect) then
                effect:SetActive(false)
            end
        end
    end
end

function CombatSkilareaPanel:HidePanel(callback)
    local selectState = self.mainPanel.selectState
    if not BaseUtils.is_null(self.mainPanel.controller.teamquestPanel) then
        self.mainPanel.controller.teamquestPanel:SetActive(true)
    end
    if not self.IsMoving then
        self.IsMoving = true
        if selectState ~= CombatSeletedState.Idel then
            if selectState == CombatSeletedState.Role then
                self.skillRight:SetActive(false)
                self.skillLeft:SetActive(true)
            else
                self.PetSkillRight:SetActive(false)
                self.PetSkillLeft:SetActive(true)
            end
        else
            self.skillRight:SetActive(false)
            self.skillLeft:SetActive(true)
        end
        local call = function()
            self.IsMoving = false
            callback()
            self.ShowState = CombatSeletedState.Idel
        end
        if self.gameObject.activeSelf then
            -- CombatUtil.DOLocalMoveX(self.gameObject, self.originHidePos.x, 0.3, call)
            -- local pos = self.gameObject.transform:GetComponent(RectTransform).anchoredPosition
            -- self.gameObject.transform:GetComponent(RectTransform).anchoredPosition = Vector2(self.originHidePos.x, pos.y)
            self.rolePanel:SetActive(false)
            self.petPanel:SetActive(false)
            call()
        else
            self.IsMoving = false
            -- self.gameObject.transform.localPosition = self.originHidePos
            self.rolePanel:SetActive(false)
            self.petPanel:SetActive(false)
            self.gameObject:SetActive(true)
            callback()
        end
    end

    self.isShow = false
end

function CombatSkilareaPanel:RefreshPetSkill()
    CombatUtil.DestroyChildActive(self.petGrid)
    self:InitPetPanel()
end

----------------------------------角色
function CombatSkilareaPanel:SwitchRoleSkillPanel()
    self:HideAll()
    if self.currPanelType ~= CombatUtil.SkillPanelType.RoleSkill then
        -- self:ShowPanel("Role", function() end)
        self.tabgroup:ChangeTab(1)
        -- print("显示任务技能")
        self.currPanelType = CombatUtil.SkillPanelType.RoleSkill
    else
        self.currPanelType = CombatUtil.SkillPanelType.None
    end
end

function CombatSkilareaPanel:SwitchRoleSpSkillPanel()
    self:HideAll()
    if self.currPanelType ~= CombatUtil.SkillPanelType.RoleSp then
        -- self:ShowPanel("SpRole", function() end)
        self.tabgroup:ChangeTab(2)
        self.currPanelType = CombatUtil.SkillPanelType.RoleSp
    else
        self.currPanelType = CombatUtil.SkillPanelType.None
    end
end

function CombatSkilareaPanel:ClickRoleAttack()
    -- self:HideAll()
    -- if self.currPanelType ~= CombatUtil.SkillPanelType.RoleAttack then

    --     self.currPanelType = CombatUtil.SkillPanelType.RoleAttack
    -- else
    --     self.currPanelType = CombatUtil.SkillPanelType.None
    -- end
end


---------------------------------宠物
function CombatSkilareaPanel:SwitchPetSkillPanel()
    self:HideAll()
    if self.currPanelType ~= CombatUtil.SkillPanelType.PetSkill then
        self:ShowPanel("Pet", function() end)
        self.currPanelType = CombatUtil.SkillPanelType.PetSkill
    else
        self.currPanelType = CombatUtil.SkillPanelType.None
    end
end

function CombatSkilareaPanel:SwitchPetSpSkillPanel()
    self:HideAll()
    if self.currPanelType ~= CombatUtil.SkillPanelType.PetSp then

        self.currPanelType = CombatUtil.SkillPanelType.PetSp
    else
        self.currPanelType = CombatUtil.SkillPanelType.None
    end
end

function CombatSkilareaPanel:ClickPetAttack()
    -- self:HideAll()
    -- if self.currPanelType ~= CombatUtil.SkillPanelType.PetAttack then

    --     self.currPanelType = CombatUtil.SkillPanelType.PetAttack
    -- else
    --     self.currPanelType = CombatUtil.SkillPanelType.None
    -- end
end

function CombatSkilareaPanel:HideAll()
    self:HidePanel(function() end)
end

function CombatSkilareaPanel:OnTabChange(index)
    if self.first == true then
        -- 初始化跳过，只用于切换标签
        self.first = false
        return
    end
    self:HideAll()
    if index == 1 then
        self:ShowPanel("Role", function() end)
    elseif index == 2 then
        self:ShowPanel("SpRole", function() end)
    end
end

function CombatSkilareaPanel:CreateIconEffect()
    local effectObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20021)))
    effectObject.transform:SetParent(self.baseIcon.transform:Find("Halo2"))
    effectObject.name = "Effect"
    effectObject.transform.localScale = Vector3.one
    effectObject.transform.localPosition = Vector3(0, 0, -400)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "UI")

    effectObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20022)))
    effectObject.transform:SetParent(self.baseIcon.transform:Find("Halo1"))
    effectObject.name = "Effect"
    effectObject.transform.localScale = Vector3.one
    effectObject.transform.localPosition = Vector3(0, 0, -400)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "UI")

    effectObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20022)))
    effectObject.transform:SetParent(self.SpbaseIcon.transform:Find("Halo1"))
    effectObject.name = "Effect"
    effectObject.transform.localScale = Vector3.one
    effectObject.transform.localPosition = Vector3(0, 0, -400)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "UI")

    self.baseIcon.transform:Find("Halo1"):GetComponent(Image).enabled = false
    self.baseIcon.transform:Find("Halo2"):GetComponent(Image).enabled = false
    self.SpbaseIcon.transform:Find("Halo1"):GetComponent(Image).enabled = false

    effectObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20021)))
    effectObject.transform:SetParent(self.basePetIcon.transform:Find("Halo2"))
    effectObject.name = "Effect"
    effectObject.transform.localScale = Vector3.one
    effectObject.transform.localPosition = Vector3(0, 0, -400)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "UI")

    effectObject = GameObject.Instantiate(CombatManager.Instance.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20022)))
    effectObject.transform:SetParent(self.basePetIcon.transform:Find("Halo1"))
    effectObject.name = "Effect"
    effectObject.transform.localScale = Vector3.one
    effectObject.transform.localPosition = Vector3(0, 0, -400)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    
    self.basePetIcon.transform:Find("Halo1"):GetComponent(Image).enabled = false
    self.basePetIcon.transform:Find("Halo2"):GetComponent(Image).enabled = false
end

function CombatSkilareaPanel:AdaptIPhoneX()
    -- if MainUIManager.Instance.adaptIPhoneX then
    --     if Screen.orientation == ScreenOrientation.LandscapeRight then
    --         self.transform.offsetMax = Vector2(-40, 0)
    --     else
    --         self.transform.offsetMax = Vector2(-4, 0)
    --     end
    -- else
    --     self.transform.offsetMax = Vector2.zero
    -- end
    BaseUtils.AdaptIPhoneX(self.transform)
end
