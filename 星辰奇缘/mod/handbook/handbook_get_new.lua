-- ---------------------------------------
-- 幻化手册获得新幻化
-- hosr
-- ---------------------------------------
HandbookGetNew = HandbookGetNew or BaseClass(BasePanel)

function HandbookGetNew:__init(callback)
    self.callback = callback
    self.texture = AssetConfig.getpet_textures
	self.resList = {
		{file = AssetConfig.handbookgetnew, type = AssetType.Main},
		{file = self.texture, type = AssetType.Dep},
		{file = AssetConfig.handbooknewtitle, type = AssetType.Dep},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.actionover = true
    self.meshId = 0
    self.previewLoaded = false
    self.previewShowed = false
    self.listener = function(texture, modleList) self:OnTposeLoad(texture, modleList) end
    self.click = function() self:Destroy() end
    self.playaction = function() self:PlayAction() end

    self.actions = {"Idle1"}
    self.step = 0

    self.petId = nil

    self.timeId = 0
    self.rotateId = 0

    self.setting = {
        name = "HandbookGetNewPreview"
        ,orthographicSize = 0.75
        ,width = 682
        ,height = 600
        ,offsetY = -0.4
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil
end

function HandbookGetNew:__delete()
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function HandbookGetNew:OnShow()
	self.data = self.openArgs
    self:SetData()
end

function HandbookGetNew:OnHide()
end

function HandbookGetNew:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbookgetnew))
    self.gameObject.name = "HandbookGetNew"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.title = self.transform:Find("Main/Title").gameObject
    self.title:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.handbooknewtitle, "HandbookNewTitle")
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.light = self.transform:Find("Main/Light").gameObject
    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.rawImg = self.transform:Find("Main/RawImage").gameObject
    self.button = self.transform:Find("Main/Button").gameObject
    self.newImg = self.transform:Find("Main/New").gameObject
    self.rawImg:SetActive(false)
    self.newImg:SetActive(false)
    self.button:SetActive(false)
    self.halo:SetActive(false)
    self.light:SetActive(false)
    self.title:SetActive(false)

     self.halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")

    self.button:GetComponent(Button).onClick:AddListener(self.click)
    self.name.text = ""

    self:OnShow()
end

function HandbookGetNew:SetData()
    self:Next()
end

function HandbookGetNew:Next()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.step = self.step + 1
    if self.step == 1 then
        self:ShowTitle()
    elseif self.step == 2 then
        self:ShowHaloLight()
        self:ShowPreview()
        self:PutNewImg()
    elseif self.step == 3 then
        self:ShowButton()
    end
end

function HandbookGetNew:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function HandbookGetNew:ShowHaloLight()
    self.halo:SetActive(true)
    self.light:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function HandbookGetNew:ShowPreview()
	local modelData = nil
	if self.data.effect_type == HandbookEumn.EffectType.Pet then
		local pet = DataPet.data_pet[self.data.preview_id]
		if pet ~= nil then
			self.name.text = pet.name
			self.meshId = pet.model_id
			modelData = {type = PreViewType.Pet, skinId = pet.skin_id_0, modelId = pet.model_id, animationId = pet.animation_id, effects = pet.effects_0, scale = pet.scale / 100}
        end
        if self.data.preview_id == 20018 then 
			modelData.scale = pet.scale / 150
		end
	elseif self.data.effect_type == HandbookEumn.EffectType.Guard then
		local guard = DataShouhu.data_guard_base_cfg[self.data.preview_id]
		if guard ~= nil then
			self.name.text = guard.name
			self.meshId = guard.res_id
			modelData = {type = PreViewType.Shouhu, skinId = guard.paste_id, modelId = guard.res_id, animationId = guard.animation_id, scale = guard.scale / 100}
		end
    elseif self.data.effect_type == HandbookEumn.EffectType.NPC then
        local npc = DataUnit.data_unit[self.data.preview_id]
        if npc ~= nil then
            self.name.text = npc.name
            self.meshId = npc.res
            modelData = {type = PreViewType.Npc, skinId = npc.skin, modelId = npc.res, animationId = npc.animation_id, scale = npc.scale / 100}
            if self.data.preview_id == 32004 or self.data.preview_id == 32031 then
                modelData.scale = npc.scale / 150
            end
        end
	end

    self:LoadPreview(modelData)
end

function HandbookGetNew:PutNewImg()
    self.newImg:SetActive(true)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function HandbookGetNew:ShowButton()
    -- self.timeId = LuaTimer.Add(500, function() self:PlayAction() end)
    self.button.transform.localScale = Vector3.one * 3
    self.button:SetActive(true)
    Tween.Instance:Scale(self.button, Vector3.one, 1, function() self:BeginCountDown() end, LeanTweenType.easeOutElastic)
end

function HandbookGetNew:Rotate()
    self.light.transform:Rotate(Vector3(0, 0, 0.5))
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function HandbookGetNew:Destroy()
    if self.countDownId ~= nil then
        LuaTimer.Delete(self.countDownId)
        self.countDownId = nil
    end
    if self.callback ~= nil then
        self.callback()
    end
end

function HandbookGetNew:PlayAction()
    -- if not self.actionover then
    --     return
    -- end
    -- self.actionover = false
    -- self.animator:Play(self.actions[1])
    -- self.timeId = LuaTimer.Add(20, function () self:ActionDelay() end)
end

function HandbookGetNew:ActionDelay()
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    if delay ~= 0 then
        self.timeId = LuaTimer.Add(delay * 1000, function() self:ActionEnd() end)
    else
        self.actionover = true
    end
end

function HandbookGetNew:ActionEnd()
    if self.animator ~= nil then
        self.animator:Play("Move1")
    end
    self.actionover = true
end

function HandbookGetNew:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function HandbookGetNew:SetRawImage(composite)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self:SetPosition()
    self.previewComp.tpose.transform:Rotate(Vector3(0, 20, 0))
    self.rawImg:SetActive(true)
    self.animator = composite.tpose:GetComponent(Animator)
    self.rawImg:GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
end

--根据模型包围盒计算中心点
function HandbookGetNew:SetPosition()
    if self.petId == 20001 then
        self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, -0.4, 0)
    else
        local mesh = self.previewComp.tpose.transform:Find(string.format("Mesh_%s", self.meshId)):GetComponent(SkinnedMeshRenderer)
        local miny = mesh.bounds.min.y
        local maxy = mesh.bounds.max.y
        local y = (miny - maxy) / 2 + 0.05
        self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, y, 0)
    end
end

function HandbookGetNew:BeginCountDown()
    -- self.countDownId = LuaTimer.Add(3000, function() self:Destroy() end)
end