-- ----------------------------------------------------------
-- UI - 宠物图鉴皮肤预览界面
-- ----------------------------------------------------------
PetSkinPreviewWindow = PetSkinPreviewWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetSkinPreviewWindow:__init(model)
    self.model = model
    self.name = "PetSkinPreviewWindow"
    self.windowId = WindowConfig.WinID.petquickshow

    self.resList = {
        {file = AssetConfig.petskinpreviewwindow, type = AssetType.Main}
        ,{file  = AssetConfig.wingsbookbg, type  =  AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
    self.petData = nil

    self.previewComposite = {}
    self.preview = {}
	------------------------------------------------

    ------------------------------------------------

    self.onClickStoneShowWashPanelFun = function (slotItemData)
        self:onClickStoneShowWashPanel(slotItemData)
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetSkinPreviewWindow:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function PetSkinPreviewWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petskinpreviewwindow))
    self.gameObject.name = "PetSkinPreviewWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform


    self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.transform:FindChild("Panel").gameObject:AddComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    ----------------------------
    self.transform:FindChild("Main/Info/bg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.transform:FindChild("Main/Info/bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.transform:FindChild("Main/Info/bg3"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview[1] = self.transform:FindChild("Main/Info/Preview1")
    self.preview[2] = self.transform:FindChild("Main/Info/Preview2")
    self.preview[3] = self.transform:FindChild("Main/Info/Preview3")

    self.nameText1 = self.transform:FindChild("Main/Info/NameText1"):GetComponent(Text)
    self.nameText2 = self.transform:FindChild("Main/Info/NameText2"):GetComponent(Text)
    self.nameText3 = self.transform:FindChild("Main/Info/NameText3"):GetComponent(Text)

    self.descText = self.transform:FindChild("Main/Info/Text"):GetComponent(Text)
    -- local btn = self.transform:FindChild("Main/Info/Preview1").gameObject:AddComponent(Button)
    -- btn.onClick:AddListener(function() self:PlayAction() end)

    ----------------------------
    LuaTimer.Add(10, function() self:OnShow() self:ClearMainAsset() end)
end

function PetSkinPreviewWindow:OnClickClose()
    self.model:ClosePetSkinPreviewWindow()
end

function PetSkinPreviewWindow:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.petData = BaseUtils.copytab(self.openArgs[1])
    end

	self:update()
end

function PetSkinPreviewWindow:OnHide()
    if self.previewComposite ~= nil then
        for key, value in pairs(self.previewComposite) do
        	value:DeleteMe()
        end
        self.previewComposite = {}
    end
end

function PetSkinPreviewWindow:update()
    if self.petData == nil then return end

    self:update_model()
end

function PetSkinPreviewWindow:update_model()
    local petData = self.petData

    local setting = {
        name = "PetView"
        ,orthographicSize = 0.6
        ,width = 200
        ,height = 200
        ,offsetY = -0.3
    }
    local data_pet_skin

    local data1 = {type = PreViewType.Pet, skinId = petData.skin_id_s0, modelId = petData.model_id, animationId = petData.animation_id, scale = petData.scale / 100, effects = petData.effects_s0}
    self:update_preview(1, setting, data1)
    self.nameText1.text = self.petData.name

   	local data2 = BaseUtils.copytab(data1)
    data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.petData.id, 1)]
    if data_pet_skin ~= nil then
        data2.modelId = data_pet_skin.model_id
		data2.skinId = data_pet_skin.skin_id
        data2.effects = data_pet_skin.effects
    end
    self:update_preview(2, setting, data2)
    self.nameText2.text = string.format(TI18N("<color='#00ffff'>[勇者]</color>%s"), data_pet_skin.skin_name)

    local data3 = BaseUtils.copytab(data2)
    data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.petData.id, 2)]
    if data_pet_skin ~= nil then
        data3.modelId = data_pet_skin.model_id
		data3.skinId = data_pet_skin.skin_id
        data3.effects = data_pet_skin.effects
    end
    self:update_preview(3, setting, data3)
    self.nameText3.text = string.format(TI18N("<color='#00ffff'>[史诗]</color>%s"), data_pet_skin.skin_name)

    if petData.genre == 2 or petData.genre == 4 then
	    self.descText.text = TI18N("神兽珍兽进阶2次后可更换皮肤")
	else
		self.descText.text = TI18N("变异宠物进阶到最高阶后可更换皮肤")
	end
end

function PetSkinPreviewWindow:update_preview(index, setting, data)
    local fun = function(composite)
        if BaseUtils.is_null(self.gameObject) or BaseUtils.is_null(self.preview[index]) then
            -- bugly #29765622 hosr 20160722
            return
        end
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview[index])
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

        -- if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
        -- self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)
    end

    if self.previewComposite[index] ~= nil then
        self.previewComposite[index]:DeleteMe()
        self.previewComposite[index] = nil
    end
    self.previewComposite[index] = PreviewComposite.New(fun, setting, data)
    self.previewComposite[index]:BuildCamera(true)
end

-- function PetSkinPreviewWindow:PlayAction()
--     if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.petData ~= nil then
--         local petData = self.petData

--         local animationData = DataAnimation.data_npc_data[petData.animation_id]
--         local action_list = { "1000", "2000", string.format("Idle%s", animationData.idle_id) }
--         self.actionIndex_PlayAction = self.actionIndex_PlayAction + math.random(1, 2)
--         if self.actionIndex_PlayAction > #action_list then self.actionIndex_PlayAction = self.actionIndex_PlayAction - #action_list end
--         local action_name = action_list[self.actionIndex_PlayAction]
--         self.previewComposite.tpose:GetComponent(Animator):Play(action_name)

--         local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", action_name, petData.model_id)]
--         if motion_event ~= nil then
--             if action_name == "1000" then
--                 self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil if not BaseUtils.isnull(self.previewComposite.tpose) then self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id)) end end)
--             elseif action_name == "2000" then
--                 self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil if not BaseUtils.isnull(self.previewComposite.tpose) then self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Stand%s", animationData.idle_id)) end end)
--             else
--                 self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil end)
--             end
--         end
--     end
-- end

-- function PetSkinPreviewWindow:PlayIdleAction()
--     if self.timeId_PlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.petData ~= nil then
--         local petData = self.petData

--         local animationData = DataAnimation.data_npc_data[petData.animation_id]
--         self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Idle%s", animationData.idle_id))
--     end
-- end
