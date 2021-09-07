-- 公会副本 
-- ljh 20170301
GuildDungeonSettlementWindow = GuildDungeonSettlementWindow or BaseClass(BasePanel)

function GuildDungeonSettlementWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.guilddungeonsettlementwindow

    self.resList = {
        {file = AssetConfig.guilddungeonsettlementwindow, type = AssetType.Main}
        ,{file = AssetConfig.guilddungeon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect1, type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect2, type = AssetType.Dep}
    }


    -----------------------------------------------------------

    -----------------------------------------------------------
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function GuildDungeonSettlementWindow:__delete()
    self.OnHideEvent:Fire()

    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildDungeonSettlementWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddungeonsettlementwindow))
    self.gameObject.name = "GuildDungeonSettlementWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    	
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform = self.transform:FindChild("Main")

    self.RoleBg1 = self.mainTransform:Find("RoleBg1")
    self.RoleBg2 = self.mainTransform:Find("RoleBg2")
    for i=1,2 do
        self.RoleBg1:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect1, "LevelBreakEffect1")
    end

    for i=1,4 do
        self.RoleBg2:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect2, "LevelBreakEffect2")
    end

    local setting = {
        name = "PetView"
        ,orthographicSize = 0.7
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.mainTransform)
    self.rawImage.gameObject:SetActive(false)
    self.modelPreview = self.mainTransform:FindChild("Preview")

    self.itemText1 = self.mainTransform:Find("Item1/Text"):GetComponent(Text)
    self.itemText2 = self.mainTransform:Find("Item2/Text"):GetComponent(Text)
    self.itemText3 = self.mainTransform:Find("Item3/Text"):GetComponent(Text)
    self.itemText4 = self.mainTransform:Find("Item4/Text"):GetComponent(Text)
    self.itemText4 = self.mainTransform:Find("Item4/Text"):GetComponent(Text)
    self.itemText5 = self.mainTransform:Find("Item5/Text"):GetComponent(Text)

    self.mainTransform:FindChild("OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
end

function GuildDungeonSettlementWindow:OnClickClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.model:CloseGuildDungeonSettlementWindow()
    self.model:OpenWindow()
end

function GuildDungeonSettlementWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDungeonSettlementWindow:OnOpen()
    self:Update()
end

function GuildDungeonSettlementWindow:OnHide()
    
end

function GuildDungeonSettlementWindow:Update()
	self:UpdateModel()
    self:UpdateItem()

    self:showBgAni()
end

function GuildDungeonSettlementWindow:UpdateModel()
	local roledata = RoleManager.Instance.RoleData
    local data = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = SceneManager.Instance:MyData().looks}
    if self.modelData ~= nil and BaseUtils.sametab(data, self.modelData) then
        return
    end

    self.previewComposite:Reload(data, function(composite) self:PreviewLoaded(composite) end)
    self.modelData = data
end

function GuildDungeonSettlementWindow:PreviewLoaded(composite) 
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.modelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    -- composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
end

function GuildDungeonSettlementWindow:UpdateItem()
    local data = self.model.settlementData
    if data == nil then
    	return
    end
	self.itemText1.text = string.format(TI18N("回合数： <color='#c7f9ff'>%s</color>"), data.round)
	self.itemText2.text = string.format(TI18N("造成伤害： <color='#13fc60'>%s</color>"), data.dmg)
	self.itemText3.text = string.format(TI18N("挑战评分： <color='#f5f598'>%s</color>"), data.score)
	self.itemText4.text = string.format(TI18N("妖魔剩余血量： <color='#c7f9ff'>%s%%</color>"), data.percent/10)
	self.itemText5.text = string.format(TI18N("讨伐血量： <color='#c7f9ff'>%s%%</color>"), data.harm/10)
end

function GuildDungeonSettlementWindow:showBgAni()
	if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
    end
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function GuildDungeonSettlementWindow:Rotate()
    self.RoleBg1.transform:Rotate(Vector3(0, 0, 0.3))
    self.RoleBg2.transform:Rotate(Vector3(0, 0, -0.5))
end
