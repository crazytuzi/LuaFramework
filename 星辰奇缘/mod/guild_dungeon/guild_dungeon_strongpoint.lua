-- 公会副本
-- ljh 20170301
GuildDungeonStrongPoint = GuildDungeonStrongPoint or BaseClass()

function GuildDungeonStrongPoint:__init(transform, assetWrapper)
    self.assetWrapper = assetWrapper
    self.transform = transform
    self.gameObject = transform.gameObject

    self.parent = transform.parent
    self.parentRect = self.parent:GetComponent(RectTransform)
    transform:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)

    self.slider = transform:FindChild("Slider"):GetComponent(Slider)
    self.sliderText = transform:FindChild("Slider/ProgressTxt"):GetComponent(Text)

    self.icon = transform:FindChild("Icon").gameObject
    self.bottom = transform:FindChild("Bottom").gameObject
    self.lock = transform:FindChild("Lock").gameObject
    self.task = transform:FindChild("Task").gameObject
    self.task2 = transform:FindChild("Task2").gameObject
    self.task3 = transform:FindChild("Task3").gameObject
    self.previewClickArea = transform:FindChild("PreviewClickArea").gameObject
    self.previewDead = transform:FindChild("PreviewDead").gameObject
    self.nameBg = transform:FindChild("NameBg")
    self.nameText = transform:FindChild("NameBg/NameText"):GetComponent(Text)

    local setting = {
        name = "GuildDungeonStrongPoint"..self.gameObject.name
        ,orthographicSize = 0.8
        ,width = 300
        ,height = 300
        ,offsetY = -0.15
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.transform)
    self.rawImage.gameObject:SetActive(false)
    self.modelPreview = self.transform:FindChild("Preview")


    self.battleEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 10096)))
    self.battleEffect.transform:SetParent(self.transform)
    self.battleEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.battleEffect.transform, "UI")
    self.battleEffect.transform.localScale = Vector3(150, 150, 1)
    self.battleEffect.transform.localPosition = Vector3(0, 0, -400)
end

function GuildDungeonStrongPoint:__delete()
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end
end

function GuildDungeonStrongPoint:Show()
    self.gameObject:SetActive(true)
    if self.previewComposite ~= nil then
       self.previewComposite:Show()
    end
end

function GuildDungeonStrongPoint:Hide()
    self.gameObject:SetActive(false)
    if self.previewComposite ~= nil then
       self.previewComposite:Hide()
    end
end

function GuildDungeonStrongPoint:Update(data, chapter_id)
	self.data = data
    self.chapter_id = chapter_id

    self.data_strongpoint = DataGuildDungeon.data_strongpoint[string.format("%s_%s", chapter_id, data.strongpoint_id)]

    local notActive = (GuildDungeonManager.Instance.model.guild_dungeon_chapter.active == 2)

    if self.data_strongpoint.type == 0 then
        self.modelPreview.gameObject:SetActive(true)
        self:UpdateModel()
        self.icon:SetActive(false)
        self.bottom:SetActive(true)

        -- status 1、可挑战 2、不可挑战 、3已完成
        if self.data.status == 1 then
            self.lock:SetActive(false)
            self.task:SetActive(false)
            self.task2:SetActive(false)
            self.task3:SetActive(notActive)
            self.previewClickArea:SetActive(true)
            self.previewDead:SetActive(false)
            self.slider.gameObject:SetActive(true)
            self.nameBg.localPosition = Vector3(0, -75, 0)
        elseif self.data.status == 2 then
            self.lock:SetActive(true)
            self.task:SetActive(false)
            self.task2:SetActive(false)
            self.task3:SetActive(notActive)
            self.previewClickArea:SetActive(true)
            self.previewDead:SetActive(false)
            self.slider.gameObject:SetActive(false)
            self.nameBg.localPosition = Vector3(0, -45, 0)
        elseif self.data.status == 3 then
            self.lock:SetActive(false)
            self.previewClickArea:SetActive(false)
            self.previewDead:SetActive(false)
            if DataGuildDungeon.data_strongpoint[string.format("%s_%s", chapter_id, data.strongpoint_id+1)] == nil then
                self.task:SetActive(true)
                self.task2:SetActive(false)
            else
                self.task:SetActive(false)
                self.task2:SetActive(true)
            end
            self.task3:SetActive(false)
            self.slider.gameObject:SetActive(false)
            self.nameBg.localPosition = Vector3(0, -45, 0)
        end

        if self.data.battle then
            self.battleEffect:SetActive(true)
            self.battleEffect.transform.localPosition = Vector3(0, 150, -400)
        else
            self.battleEffect:SetActive(false)
        end
    else
        self.modelPreview.gameObject:SetActive(false)
        self.previewClickArea:SetActive(false)
        self.icon:SetActive(true)
        self.bottom:SetActive(false)
        self.previewDead:SetActive(false)

        self.icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guilddungeon_textures, tostring(self.data_strongpoint.type))

        -- status 1、可挑战 2、不可挑战 、3已完成
        if self.data.status == 1 then
            self.lock:SetActive(false)
            self.task:SetActive(false)
            self.task2:SetActive(false)
            self.task3:SetActive(notActive)
            BaseUtils.SetGrey(self.icon:GetComponent(Image), false)
            self.slider.gameObject:SetActive(true)
            self.nameBg.localPosition = Vector3(0, -75, 0)
        elseif self.data.status == 2 then
            self.lock:SetActive(true)
            self.task:SetActive(false)
            self.task2:SetActive(false)
            self.task3:SetActive(notActive)
            BaseUtils.SetGrey(self.icon:GetComponent(Image), true)
            self.slider.gameObject:SetActive(false)
            self.nameBg.localPosition = Vector3(0, -45, 0)
        elseif self.data.status == 3 then
            self.lock:SetActive(false)
            if DataGuildDungeon.data_strongpoint[string.format("%s_%s", chapter_id, data.strongpoint_id+1)] == nil then
                self.task:SetActive(true)
                self.task2:SetActive(false)
            else
                self.task:SetActive(false)
                self.task2:SetActive(true)
            end
            self.task3:SetActive(false)
            BaseUtils.SetGrey(self.icon:GetComponent(Image), true)
            self.slider.gameObject:SetActive(false)
            self.nameBg.localPosition = Vector3(0, -45, 0)
        end

        if self.data.battle then
            self.battleEffect:SetActive(true)
            self.battleEffect.transform.localPosition = Vector3(0, 50, -400)
        else
            self.battleEffect:SetActive(false)
        end
    end

    self.transform.localPosition = Vector2(self.data_strongpoint.x - self.parentRect.sizeDelta.x / 2, self.data_strongpoint.y * -1 + self.parentRect.sizeDelta.y / 2)
    self.slider.value = self.data.percent / 1000
    self.sliderText.text = string.format("%s%%", self.data.percent/10)
    self.nameText.text = self.data_strongpoint.strongpoint_name
end

function GuildDungeonStrongPoint:UpdateModel()
    local duild_dungeon_unit = DataGuildDungeon.data_unit[string.format("%s_%s_%s", self.chapter_id, self.data.strongpoint_id, self.data_strongpoint.monsters[1])]
    local data_unit = DataUnit.data_unit[duild_dungeon_unit.id]
    local scale = duild_dungeon_unit.scale
    local data = {type = PreViewType.Npc, skinId = data_unit.skin, modelId = data_unit.res, animationId = data_unit.animation_id, scale = scale / 100, effects = data_unit.effects}
    if self.modelData ~= nil and BaseUtils.sametab(data, self.modelData) then
        return
    end

    self.previewComposite:Reload(data, function(composite) self:PreviewLoaded(composite) end)
    self.modelData = data
end

function GuildDungeonStrongPoint:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.modelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    -- composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

end

function GuildDungeonStrongPoint:OnClick()
    BaseUtils.dump(self.data)
    if self.data_strongpoint.type == 0 then
        if self.data.status == 1 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddungeonbosswindow, { self.chapter_id, self.data.strongpoint_id, self.data, 1 })
        elseif self.data.status == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("尚未开启，请先挑战前面据点"))
        elseif self.data.status == 3 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddungeonbosswindow, { self.chapter_id, self.data.strongpoint_id, self.data, 2 })
        end
    else
        if self.data.status == 1 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddungeonsoldierwindow, { self.chapter_id, self.data.strongpoint_id, self.data, 1 })
        elseif self.data.status == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("尚未开启，请先挑战前面据点"))
        elseif self.data.status == 3 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddungeonsoldierwindow, { self.chapter_id, self.data.strongpoint_id, self.data, 2 })
        end
    end
end