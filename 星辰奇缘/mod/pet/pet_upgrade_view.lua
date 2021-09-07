-- ----------------------------------------------------------
-- UI - 宠物窗口 主窗口
-- ----------------------------------------------------------
PetUpgradeView = PetUpgradeView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetUpgradeView:__init(model)
    self.model = model
    self.name = "PetUpgradeView"
    self.windowId = WindowConfig.WinID.pet_upgrade
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy
    self.effectPath = "prefabs/effect/20056.unity3d"

    self.resList = {
        {file = AssetConfig.pet_upgrade_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.eqmwashbg, type = AssetType.Dep}
        , {file = self.effectPath, type = AssetType.Dep}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
    self.preview_image1 = nil
    self.preview_image2 = nil
    self.item_solt = nil
    self.bgeffect = nil

    self.buttonscript = nil
    self.moneyNum = nil

    self.upgradeTips = {TI18N("1、携带等级≥65级的宠物，可以<color='#ffff00'>进阶2次</color>")
                        , TI18N("2、携带等级≥75级宠物进阶需要消耗<color='#ffff00'>二品灵犀</color>")
                        , TI18N("3、携带等级为65级的宠物，进阶1阶需要消耗<color='#ffff00'>灵犀</color>，进阶2阶需要消耗<color='#ffff00'>二品灵犀</color>")
                        , TI18N("4、携带等级<65级宠物，可以进阶1次，进阶需要消耗<color='#ffff00'>灵犀</color>")
                        , TI18N("5、神兽、珍兽进阶需要消耗对应的神兽之魂、珍兽之魂")}
	------------------------------------------------
    ------------------------------------------------

    self.updateListener = function() self:update_item() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetUpgradeView:__delete()
    if self.item_solt ~= nil then
        self.item_solt:DeleteMe()
        self.item_solt = nil
    end

    self:OnHide()

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.previewComposite2 ~= nil then
        self.previewComposite2:DeleteMe()
        self.previewComposite2 = nil
    end

    if self.buttonscript ~= nil then
        self.buttonscript:DeleteMe()
        self.buttonscript = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function PetUpgradeView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_upgrade_window))
    self.gameObject.name = "PetUpgradeView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    ----------------------------
    local transform = self.transform
    transform:Find("Main/ItemBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.eqmwashbg, "EqmWashBg")
    transform:Find("Main/Image1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    transform:Find("Main/Image2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.preview1 = transform:FindChild("Main/Preview1")
    self.preview2 = transform:FindChild("Main/Preview2")
    self.item_solt = ItemSlot.New()
    UIUtils.AddUIChild(transform:FindChild("Main/Item").gameObject, self.item_solt.gameObject)

    transform:FindChild("Main/DescText"):GetComponent(Text).text
         = TI18N("1、符石加成属性将<color='#ffff00'>永久融合</color>到宠物身上，同时符石消失\n2、附带的技能<color='#ffff00'>随机抽取</color>一个融合到宠物身上，同时符石消失\n3、融合后的技能有概率在学习技能时被顶替\n4、宠物外观发生变化，<color='#5fffaa'>各项资质+20</color>")

    self.buttonscript = BuyButton.New(transform:FindChild("Main/OkButton"), TI18N("进 阶"))
    self.buttonscript.key = "PetUpgrade"
    self.buttonscript.protoId = 10509
    self.buttonscript:Show()

    self.moneyNum = transform:FindChild("Main/MoneyNum").gameObject

    self.canNotUpgradeTips = transform:FindChild("Main/CanNotUpgradeTipsText").gameObject

    transform:FindChild("Main/DescButton"):GetComponent(Button).onClick:AddListener(
        function() TipsManager.Instance:ShowText({gameObject = transform:FindChild("Main/DescButton").gameObject, itemData = self.upgradeTips}) end)

    local bgeffect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    bgeffect.transform:SetParent(transform:FindChild("Main/ItemBg"))
    bgeffect.transform.localPosition = Vector3(-1, 7, -10)
    bgeffect.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(bgeffect.transform, "UI")
    bgeffect:SetActive(false)
    bgeffect:SetActive(true)

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetUpgradeView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetUpgradeView:OnShow()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)

	self:update()
end

function PetUpgradeView:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
end

function PetUpgradeView:OnHide()
    self:RemoveListeners()
end

function PetUpgradeView:update()
    if self.model.cur_petdata == nil then return end
    self:update_pet()
    self:update_item()
    self:update_canupgradetips()
    self:update_upgradequality()
end

function PetUpgradeView:update_pet()
    local petData = self.model.cur_petdata
    local modelId = petData.base.model_id
    local modelId2 = petData.base.model_id1
    local skin = petData.base.skin_id_0
    local effects = petData.base.effects_0
    local skin2 = petData.base.skin_id_1
    local effects2 = petData.base.effects_1
    if petData.genre ~= 1 then
        if petData.grade == 0 then
            modelId = petData.base.model_id
            skin = petData.base.skin_id_0
            effects = petData.base.effects_0

            modelId2 = petData.base.model_id1
            skin2 = petData.base.skin_id_1
            effects2 = petData.base.effects_1
        elseif petData.grade == 1 then
            modelId = petData.base.model_id1
            skin = petData.base.skin_id_1
            effects = petData.base.effects_1

            modelId2 = petData.base.model_id2
            skin2 = petData.base.skin_id_2
            effects2 = petData.base.effects_2
        elseif petData.grade == 2 then
            modelId = petData.base.model_id2
            skin = petData.base.skin_id_2
            effects = petData.base.effects_2

            modelId2 = petData.base.model_id3
            skin2 = petData.base.skin_id_3
            effects2 = petData.base.effects_3
        elseif petData.grade == 3 then
            modelId = petData.base.model_id3
            skin = petData.base.skin_id_3
            effects = petData.base.effects_3

            modelId2 = petData.base.model_id3
            skin2 = petData.base.skin_id_3
            effects2 = petData.base.effects_3
        end
    else
        if petData.grade == 0 then
            modelId = petData.base.model_id
            skin = petData.base.skin_id_s0
            effects = petData.base.effects_s0

            modelId2 = petData.base.model_id1
            skin2 = petData.base.skin_id_s1
            effects2 = petData.base.effects_s1
        elseif petData.grade == 1 then
            modelId = petData.base.model_id1
            skin = petData.base.skin_id_s1
            effects = petData.base.effects_s1

            modelId2 = petData.base.model_id2
            skin2 = petData.base.skin_id_s2
            effects2 = petData.base.effects_s2
        elseif petData.grade == 2 then
            modelId = petData.base.model_id2
            skin = petData.base.skin_id_s2
            effects = petData.base.effects_s2

            modelId2 = petData.base.model_id3
            skin2 = petData.base.skin_id_s3
            effects2 = petData.base.effects_s3
        elseif petData.grade == 3 then
            modelId = petData.base.model_id3
            skin = petData.base.skin_id_s3
            effects = petData.base.effects_s3

            modelId2 = petData.base.model_id3
            skin2 = petData.base.skin_id_s3
            effects2 = petData.base.effects_s3
        end
    end

    local data = {type = PreViewType.Pet, skinId = skin, modelId = modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = effects}
    local data2 = {type = PreViewType.Pet, skinId = skin2, modelId = modelId2, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = effects2}

    local setting = {
        name = "PetView"
        ,orthographicSize = 1
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local fun = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview1)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    local fun2 = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview2)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.previewComposite2 ~= nil then
        self.previewComposite2:DeleteMe()
        self.previewComposite2 = nil
    end

    self.previewComposite = PreviewComposite.New(fun, setting, data)
    -- self.previewComposite:BuildCamera()
    self.previewComposite2 = PreviewComposite.New(fun2, setting, data2)
    -- self.previewComposite2:BuildCamera()
end

function PetUpgradeView:update_item()
    local data = DataPet.data_pet_grade[string.format("%s_%s", self.model.cur_petdata.base.id, self.model.cur_petdata.grade+1)]
    if data == nil then return end
    local cost = data.loss[1].val[1]
    local base_data = BackpackManager.Instance:GetItemBase(cost[1])
    local cost_num = cost[2]
    local backlpack_num = BackpackManager.Instance:GetItemCount(cost[1])
    local itemData = ItemData.New()
    itemData:SetBase(base_data)
    self.item_solt:SetAll(itemData)

    self.transform:FindChild("Main/ItemNameText"):GetComponent(Text).text = ColorHelper.color_item_name(base_data.quality, base_data.name)
    local color = "#00ff00"
    if cost_num > backlpack_num then
        color = "#ff0000"
        self.moneyNum.gameObject:SetActive(true)
    else
        self.moneyNum.gameObject:SetActive(false)
    end
    self.transform:FindChild("Main/ItemNumText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>/%s", color, backlpack_num, cost_num)

    self.buttonscript:Layout({[cost[1]] = {need = cost_num}}, function() self:button_click() end, function (baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end, { antofreeze = false })
    if self.model.cur_petdata.lev < 30 then
        self.buttonscript:Set_btn_txt("30级进阶")
    end
end

function PetUpgradeView:update_canupgradetips()
    local petData = self.model.cur_petdata
    local stone_hole = petData.grade + 2
    if #petData.stones < stone_hole then
        self.canNotUpgradeTips:SetActive(true)
    else
        self.canNotUpgradeTips:SetActive(false)
    end
end

function PetUpgradeView:update_upgradequality()
    local petData = self.model.cur_petdata
    if petData.genre == 2 or petData.genre == 4 then
        self.transform:FindChild("Main/UpgradeQualityImage"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_Pet_Upgrade_Add2")
    else
        self.transform:FindChild("Main/UpgradeQualityImage"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_Pet_Upgrade_Add")
    end
end

function PetUpgradeView:button_click()
    local gen_skill_num = {}
    for _,value in ipairs(self.model.cur_petdata.skills) do
        if value.source == 2 then
            table.insert(gen_skill_num, string.format("<color='#25BFCF'>[%s]</color>", DataSkill.data_petSkill[string.format("%s_1", value.id)].name))
        end
    end

    if #gen_skill_num > 1 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        local skillName = ""
        for index,value in ipairs(gen_skill_num) do
            skillName = string.format("%s%s", skillName, value)
            if index ~= #gen_skill_num then skillName = string.format("%s、", skillName) end
        end
        data.content = string.format(TI18N("你的宠物佩戴了拥有%s两个技能的护符，进阶<color='#00ff00'>随机</color>保留<color='#00ff00'>1个</color>，确定要进阶吗？"), skillName)
        data.sureLabel = TI18N("进阶")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self:OnClickClose()
            PetManager.Instance:Send10509(self.model.cur_petdata.id)
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        PetManager.Instance:Send10509(self.model.cur_petdata.id)

        if self.model.cur_petdata.lev < 30 then
            self.buttonscript:ReleaseFrozon()
        else
            self:OnClickClose()
        end
    end
end

function PetUpgradeView:callbackAfter12406(baseidToBuyInfo)
    local coins = RoleManager.Instance.RoleData.coins
    local gold_bind = RoleManager.Instance.RoleData.gold_bind

    for k,v in pairs(baseidToBuyInfo) do
        local numText = self.moneyNum:GetComponent(Text)

        if self.imgLoader == nil then
            local go = self.moneyNum.transform:Find("Currency").gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, v.assets)

        if v.allprice < 0 then
            numText.text = "<color=#FF0000>"..tostring(0 - v.allprice).."</color>"
        else
            numText.text = tostring(v.allprice)
        end
    end
end