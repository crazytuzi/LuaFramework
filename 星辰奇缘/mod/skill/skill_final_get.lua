-- 职业绝招领悟面板
-- xhs  20180110

SkillFinalGetWindow = SkillFinalGetWindow or BaseClass(BaseWindow)

function SkillFinalGetWindow:__init(model)
    self.Mgr = SkillManager.Instance
    self.model = model
    self.name = "SkillFinalGetWindow"
    -- self.windowId = WindowConfig.WinID.exercise_window
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.skill_final_get, type = AssetType.Main},
        -- {file = AssetConfig.exercise_textures, type = AssetType.Dep},
        {file = AssetConfig.skill_light, type = AssetType.Main},
        {file = AssetConfig.getfinalskill_title, type = AssetType.Main},
        {file = AssetConfig.light_circle, type = AssetType.Main},
        {file = AssetConfig.final_skill_bg, type = AssetType.Main},

        {file = AssetConfig.wingsbookbg, type = AssetType.Main},
        {file = AssetConfig.guildleaguebig , type = AssetType.Dep},
        {file = AssetConfig.name_bg, type = AssetType.Main},

    }


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SkillFinalGetWindow:__delete()
    self.OnHideEvent:Fire()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.effect2 ~= nil then
        self.effect2:DeleteMe()
        self.effect2 = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SkillFinalGetWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_final_get))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    local main = self.gameObject.transform:Find("Main")

    main:GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig, "GuildLeague2")
    main:Find("Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.skill_light, "SkillLight")
    main:Find("Title"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getfinalskill_title, "GetI18NFinalSkillTitle")
    main:Find("LightCircle"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.light_circle, "LightCircle")
    main:Find("SkillBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.final_skill_bg, "FinalSkillBg")
    main:Find("Skillbottom"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    main:Find("SkillName"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.name_bg, "NameBg")

    self.skill = main:Find("Skill")

    if self.effect == nil then
        self.effect = BaseUtils.ShowEffect(20437, main:Find("LightCircle"), Vector3(1,1,1), Vector3(0,0,-1000))
    end

    if self.effect2 == nil then
        self.effect2 = BaseUtils.ShowEffect(20138, self.skill, Vector3(1,1,1), Vector3(0,0,-1000))
    end


    self.skillSlot = SkillSlot.New()
    self.skillSlot.gameObject:AddComponent(TransitionButton).scaleRate = 1.1
    UIUtils.AddUIChild(self.skill.gameObject, self.skillSlot.gameObject)

    local skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"]
    local data = DataSkill.data_skill_role[string.format("%s_1", skill.id)]
    self.skillSlot:SetAll(Skilltype.roleskill, data, { classes = RoleManager.Instance.RoleData.classes })
    main:Find("SkillName/Text"):GetComponent(Text).text = skill.name
    main:Find("SkillName").gameObject:SetActive(true)
    main:Find("Desc/Text"):GetComponent(Text).text = skill.desc
    main:GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
    main:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
end

function SkillFinalGetWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SkillFinalGetWindow:OnOpen()
    self:AddListeners()
    local temp = 0
    self.timerId = LuaTimer.Add(0, 22, function() self:Float(temp) temp = temp + 1  end)
    self.timerId2 = LuaTimer.Add(3000,function() self:OnClickClose() end)
end

function SkillFinalGetWindow:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end
end

function SkillFinalGetWindow:AddListeners()
    self:RemoveListeners()
end

function SkillFinalGetWindow:RemoveListeners()

end


function SkillFinalGetWindow:OnClickClose()
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        WindowManager.Instance:CloseWindow(self)
    else
        WindowManager.Instance:ShowUI(true)
        self.skill:SetParent(self.gameObject.transform)
        self.gameObject.transform:Find("Main").gameObject:SetActive(false)
        self.gameObject.transform:Find("Panel").gameObject:SetActive(false)
        if self.effect2 ~= nil then
            self.effect2:SetActive(false)
        end
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        if self.timerId2 ~= nil then
            LuaTimer.Delete(self.timerId2)
            self.timerId2 = nil
        end
        local icon = MainUIManager.Instance.MainUIIconView:getbuttonbyid(3)
        if icon ~= nil then
            Tween.Instance:Move(self.skill.gameObject, icon.transform.position, 1, function()
                WindowManager.Instance:CloseWindow(self)
                SoundManager.Instance:Play(555)
                TipsManager.Instance:ShowGuide({gameObject = icon.gameObject, data = TI18N("成功领悟<color='#ffff00'>职业绝招</color>啦~"), forward = TipsEumn.Forward.Up})
                local w = icon:GetComponent(RectTransform).rect.width
                local effect = BaseUtils.ShowEffect(20103, icon.transform, Vector3(1,1,1), Vector3(0,w/2,-1000))
                local fun = function ()
                    if effect ~= nil then
                        effect:DeleteMe()
                        effect = nil
                    end
                end
                icon:GetComponent(Button).onClick:AddListener(function()
                    fun()
                    icon:GetComponent(Button).onClick:RemoveListener(fun)
                end)
            end)
            Tween.Instance:Scale(self.skill.gameObject, Vector3.one * 0.2, 1)
        end
    end
end

function SkillFinalGetWindow:Float(stemp)
    stemp = stemp or 0
    self.skill.anchoredPosition = Vector2(475, -187+ 8 * math.sin(stemp * math.pi / 70, 0))
end

