-- 公会副本追踪面板
-- ljh 2017.3.23
MainuiTraceGuildDungeon = MainuiTraceGuildDungeon or BaseClass(BaseTracePanel)

function MainuiTraceGuildDungeon:__init(main)
    self.main = main
    self.isInit = false
    self.loadList = BaseUtils.create_queue()
    self.assetLoaded = false

    self.resList = {
        {file = AssetConfig.guilddungeon_content, type = AssetType.Main},
        {file = AssetConfig.guilddungeon_textures, type = AssetType.Dep},
        {file = AssetConfig.totembg, type = AssetType.Dep},
        {file = AssetConfig.world_boss_head_icon, type = AssetType.Dep},
    }

    self._Update = function() self:Update() end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceGuildDungeon:__delete()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
end

function MainuiTraceGuildDungeon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddungeon_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    local transform = self.transform

    self.normalTransform = transform:FindChild("Normal")
    self.fightTransform = transform:FindChild("Fight")

    ------------------------------------------------------
    self.normalTransform:GetComponent(Button).onClick:AddListener(function() self:OnGotoButtonClick() end)
    -- self.normalTransform:FindChild("GoToButton"):GetComponent(Button).onClick:AddListener(function() self:OnGotoButtonClick() end)
    self.normalTransform:FindChild("ExitButton"):GetComponent(Button).onClick:AddListener(function() self:OnExitButtonClick() end)

    self.head = self.normalTransform:FindChild("Head/Image")
    self.nameText = self.normalTransform:FindChild("NameText"):GetComponent(Text)
    self.slider = self.normalTransform:FindChild("Slider"):GetComponent(Slider)
    self.sliderText = self.normalTransform:FindChild("Slider/ProgressTxt"):GetComponent(Text)
    self.task = self.normalTransform:FindChild("Task").gameObject
    -- self.goToButton = self.normalTransform:FindChild("GoToButton").gameObject

    self.normalTransform:Find("HeadBg").gameObject:SetActive(false)
    self.head.gameObject:SetActive(false)
    self.task:SetActive(false)

    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.normalTransform:FindChild("Head"))
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    BaseEffectView.New({effectId = 20338, time = nil, callback = fun})

    ------------------------------------------------------
    -- self.fightTransform:GetComponent(Button).onClick:AddListener(function() self:OnGotoButtonClick() end)
    -- self.fightTransform:FindChild("GoToButton"):GetComponent(Button).onClick:AddListener(function() self:OnGotoButtonClick() end)
    self.fightTransform:FindChild("ExitButton"):GetComponent(Button).onClick:AddListener(function() self:OnExitButtonClick() end)

    self.fight_head = self.fightTransform:FindChild("Head/Image")
    self.fight_nameText = self.fightTransform:FindChild("NameText"):GetComponent(Text)
    self.fight_slider = self.fightTransform:FindChild("Slider"):GetComponent(Slider)
    self.fight_sliderText = self.fightTransform:FindChild("Slider/ProgressTxt"):GetComponent(Text)
    self.fight_task = self.fightTransform:FindChild("Task").gameObject
    -- self.fight_goToButton = self.fightTransform:FindChild("GoToButton").gameObject

    self.fightTransform:Find("HeadBg").gameObject:SetActive(false)
    self.fight_head.gameObject:SetActive(false)
    self.fight_task:SetActive(false)

    self.fight_item1_text = self.fightTransform:FindChild("Item1/Text"):GetComponent(Text)
    self.fight_item2_text = self.fightTransform:FindChild("Item2/Text"):GetComponent(Text)
    self.fight_item3_text = self.fightTransform:FindChild("Item3/Text"):GetComponent(Text)
    self.fight_item4_text = self.fightTransform:FindChild("Item4/Text"):GetComponent(Text)

    self.fightTransform:FindChild("DescButton"):GetComponent(Button).onClick:AddListener(function()
            self:ShowFightTips()
        end)

    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.fightTransform:FindChild("Head"))
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    BaseEffectView.New({effectId = 20338, time = nil, callback = fun})

    self:OnLoadHeadBgTexture()
end

function MainuiTraceGuildDungeon:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceGuildDungeon:OnShow()
    GuildDungeonManager.Instance.OnUpdateBoss:Remove(self._Update)
    GuildDungeonManager.Instance.OnUpdateBoss:Add(self._Update)

    self:Update()
end

function MainuiTraceGuildDungeon:OnHide()
    GuildDungeonManager.Instance.OnUpdateBoss:Remove(self._Update)
end

function MainuiTraceGuildDungeon:Update()
    if not self.assetLoaded then
        return
    end

    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Normal then
    	self:UpdateNormal()
    elseif RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        self:UpdateFight()
    end
end

function MainuiTraceGuildDungeon:UpdateNormal()
    self.normalTransform.gameObject:SetActive(true)
    self.fightTransform.gameObject:SetActive(false)

    local bossMapData = GuildDungeonManager.Instance.model.bossMapData
    local bossData = GuildDungeonManager.Instance.model.bossData
    if bossMapData == nil or bossData == nil or bossMapData.head_id == nil or bossData.percent == nil then
        self.head.gameObject:SetActive(false)
        self.nameText.text = ""
        self.slider.value = 1
        self.sliderText.text = ""
        self.task:SetActive(false)
        -- self.goToButton:SetActive(false)
    else
        if bossMapData.head_type == 1 then
            self.head.gameObject:SetActive(true)
            if self.headLoader == nil then
                self.headLoader = SingleIconLoader.New(self.head.gameObject)
            end
            self.headLoader:SetSprite(SingleIconType.Pet,bossMapData.head_id)
            -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(bossMapData.head_id), bossMapData.head_id)
        elseif bossMapData.head_type == 2 then
            -- self.head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, bossMapData.head_id)
            self.head.gameObject:SetActive(false)
            self:OnLoadHeadTexture()
        end
        self.nameText.text = bossMapData.name
        self.slider.value = bossData.percent / 1000
        self.sliderText.text = string.format("%s%%", bossData.percent / 10)

        if bossData.percent > 0 then
            self.task:SetActive(false)
            -- self.goToButton:SetActive(true)
        else
            self.task:SetActive(true)
            -- self.goToButton:SetActive(false)
        end
    end
end

function MainuiTraceGuildDungeon:UpdateFight()
    self.normalTransform.gameObject:SetActive(false)
    self.fightTransform.gameObject:SetActive(true)

    local bossMapData = GuildDungeonManager.Instance.model.bossMapData
    local bossData = GuildDungeonManager.Instance.model.bossData
    if GuildDungeonManager.Instance.model.fightMapData ~= nil then
        bossMapData = GuildDungeonManager.Instance.model.fightMapData
        bossData = GuildDungeonManager.Instance.model.fightData
    end
    if bossMapData == nil or bossData == nil or bossMapData.head_id == nil or bossData.percent == nil then
        self.fight_head.gameObject:SetActive(false)
        self.fight_nameText.text = ""
        self.fight_slider.value = 1
        self.fight_sliderText.text = ""
        self.fight_task:SetActive(false)
        -- self.fight_goToButton:SetActive(false)

        self.fight_item1_text.text = string.format(TI18N("当前评分：<color='#c7f9ff'>%s</color>"), 0)
        self.fight_item2_text.text = string.format(TI18N("历史最高：<color='#c7f9ff'>%s</color>"), 0)
        self.fight_item3_text.text = string.format(TI18N("评分排名：<color='#c7f9ff'>%s</color>"), 0)
        self.fight_item4_text.text = string.format(TI18N("获得经验：<color='#c7f9ff'>%s</color>"), 0)
    else
        if bossMapData.head_type == 1 then
            self.fight_head.gameObject:SetActive(true)
                if self.headLoader == nil then
                    self.headLoader = SingleIconLoader.New(self.fight_head.gameObject)
                end
                self.headLoader:SetSprite(SingleIconType.Pet,bossMapData.head_id)
            -- self.fight_head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(bossMapData.head_id), bossMapData.head_id)
        elseif bossMapData.head_type == 2 then
            -- self.fight_head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, bossMapData.head_id)
            self.fight_head.gameObject:SetActive(false)
            self:OnLoadHeadTexture()
        end
        self.fight_nameText.text = bossMapData.name
        self.fight_slider.value = bossData.percent / 1000
        self.fight_sliderText.text = string.format("%s%%", bossData.percent / 10)

        if bossData.percent > 0 then
            self.fight_task:SetActive(false)
            -- self.fight_goToButton:SetActive(true)
        else
            self.fight_task:SetActive(true)
            -- self.fight_goToButton:SetActive(false)
        end

        self.fight_item1_text.text = string.format(TI18N("当前评分：<color='#c7f9ff'>%s</color>"), bossData.score)
        self.fight_item2_text.text = string.format(TI18N("历史最高：<color='#c7f9ff'>%s</color>"), bossData.max_score)
        self.fight_item3_text.text = string.format(TI18N("评分排名：<color='#c7f9ff'>%s</color>"), bossData.rank)
        self.fight_item4_text.text = string.format(TI18N("获得经验：<color='#c7f9ff'>%s</color>"), GuildDungeonManager.Instance.model:GetExp(bossMapData.exp_id, bossMapData.exp_ratio, bossData.war_percent))
    end
end

function MainuiTraceGuildDungeon:OnGotoButtonClick()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDungeonBattle then
        return
    end

    local bossData = GuildDungeonManager.Instance.model.bossData
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for key, value in ipairs(units) do
        if value.baseid == bossData.monster_id then
            SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(value.uniqueid)
            return
        end
    end
end

function MainuiTraceGuildDungeon:OnExitButtonClick()
    GuildDungeonManager.Instance:Send19506()
end

function MainuiTraceGuildDungeon:OnLoadHeadBgTexture()
    self.assetLoaded = true
    self.normalTransform:Find("HeadBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")
    self.normalTransform:Find("HeadBg").gameObject:SetActive(true)
    self.normalTransform:Find("Task"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guilddungeon_textures, "Task2")

    self.fightTransform:Find("HeadBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")
    self.fightTransform:Find("HeadBg").gameObject:SetActive(true)
    self.fightTransform:Find("Task"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guilddungeon_textures, "Task2")

    self:Update()
end

function MainuiTraceGuildDungeon:OnLoadHeadTexture()
    local bossMapData = GuildDungeonManager.Instance.model.bossMapData
    local bossData = GuildDungeonManager.Instance.model.bossData
    if bossMapData == nil or bossData == nil or bossMapData.head_id == nil or bossData.percent == nil then
    else
        if bossMapData.head_type == 2 then
            self.head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, bossMapData.head_id)
            self.head.gameObject:SetActive(true)

            self.fight_head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, bossMapData.head_id)
            self.fight_head.gameObject:SetActive(true)
        end
    end
end

function MainuiTraceGuildDungeon:ShowFightTips()
    local bossMapData = GuildDungeonManager.Instance.model.bossMapData
    local bossData = GuildDungeonManager.Instance.model.bossData
    if GuildDungeonManager.Instance.model.fightMapData ~= nil then
        bossMapData = GuildDungeonManager.Instance.model.fightMapData
        bossData = GuildDungeonManager.Instance.model.fightData
    end
        if bossMapData == nil or bossData == nil or bossMapData.head_id == nil or bossData.percent == nil then

        else
        local descTips = {string.format(TI18N("1.公会最高评分：<color='#ffff00'>%s</color>"), bossData.max_guild_score)
                    , TI18N("2.评分越高，获得的经验越多")
                }
        TipsManager.Instance:ShowText({gameObject = self.fightTransform:FindChild("DescButton").gameObject, itemData = descTips})
    end
end


