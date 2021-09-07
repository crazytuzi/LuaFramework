-- ----------------------------------------------------------
-- 子女进阶
-- hosr
-- ----------------------------------------------------------
PetChildUpgradeView = PetChildUpgradeView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetChildUpgradeView:__init(model)
    self.model = model
    self.name = "PetChildUpgradeView"
    self.windowId = WindowConfig.WinID.pet_child_upgrade
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy
    self.effectPath = "prefabs/effect/20056.unity3d"

    self.resList = {
        {file = AssetConfig.pet_child_upgrade_window, type = AssetType.Main}
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

    self.upgradeTips = {TI18N("1、孩子可<color='#ffff00'>进阶3次</color>，每次进阶后各<color='#ffff00'>项资质增加20</color>，并可学习一个<color='#ffff00'>新天赋</color>")
                        , TI18N("2、每次进阶需消耗<color='#ffff00'>苏醒精华</color>，进阶后孩子装备、项链技能将融入孩子本身")
                    }
	------------------------------------------------
    ------------------------------------------------

    self.itemListener = function() self:update_item() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetChildUpgradeView:__delete()
    self:OnHide()
    if self.item_solt ~= nil then
        self.item_solt:DeleteMe()
        self.item_solt = nil
    end
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

function PetChildUpgradeView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_child_upgrade_window))
    self.gameObject.name = "PetChildUpgradeView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Main/Title/Text"):GetComponent(Text).text = TI18N("子女进阶")

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
         = TI18N("1、装备加成属性将<color='#ffff00'>永久融合</color>到孩子身上，同时装备消失\n2、项链附带的技能<color='#ffff00'>随机抽取</color>一个融合到孩子身上，同时项链消失\n3、融合后的技能有概率在学习技能时被顶替\n4、孩子外观发生变化，<color='#5fffaa'>各项资质+20</color>")

    -- transform:FindChild("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.buttonscript = BuyButton.New(transform:FindChild("Main/OkButton"), TI18N("进 阶"))
    self.buttonscript.key = "ChildUpgrade"
    self.buttonscript.protoId = 18617
    self.buttonscript:Set_btn_img("DefaultButton3")
    self.buttonscript:Show()

    self.moneyNum = transform:FindChild("Main/MoneyNum").gameObject

    transform:FindChild("Main/CanNotUpgradeTipsText"):GetComponent(Text).text = TI18N("装备齐全才能进阶")
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

function PetChildUpgradeView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetChildUpgradeView:OnShow()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)

	self:update()

    if PetManager.Instance.model:CheckChildCanFollow() then
        local child = PetManager.Instance.model.currChild
        ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Follow)
    end
end

function PetChildUpgradeView:OnHide()
    self:RemoveListeners()
end

function PetChildUpgradeView:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
end

function PetChildUpgradeView:update()
    if self.model.currChild == nil then return end
    self:update_pet()
    self:update_item()
    self:update_canupgradetips()
    self:update_upgradequality()
end

function PetChildUpgradeView:update_pet()
    local petData = PetManager.Instance.model.currChild
    local grade = petData.grade

    local base = DataChild.data_child[petData.base_id]

    local modelId = base.model_id
    local modelId2 = base.model_id1
    local skin = base.skin_id_0
    local effects = base.effects_0
    local skin2 = base.skin_id_1
    local effects2 = base.effects_1

    if grade == 0 then
        modelId = base.model_id
        skin = base.skin_id_0
        effects = base.effects_0

        modelId2 = base.model_id1
        skin2 = base.skin_id_1
        effects2 = base.effects_1
    elseif grade == 1 then
        modelId = base.model_id1
        skin = base.skin_id_1
        effects = base.effects_1

        modelId2 = base.model_id2
        skin2 = base.skin_id_2
        effects2 = base.effects_2
    elseif grade == 2 then
        modelId = base.model_id2
        skin = base.skin_id_2
        effects = base.effects_2

        modelId2 = base.model_id3
        skin2 = base.skin_id_3
        effects2 = base.effects_3
    elseif grade == 3 then
        modelId = base.model_id3
        skin = base.skin_id_3
        effects = base.effects_3

        modelId2 = base.model_id3
        skin2 = base.skin_id_3
        effects2 = base.effects_3
    end

    local data = {type = PreViewType.Pet, skinId = skin, modelId = modelId, animationId = base.animation_id, scale = 1, effects = effects}
    local data2 = {type = PreViewType.Pet, skinId = skin2, modelId = modelId2, animationId = base.animation_id, scale = 1, effects = effects2}

    local setting = {
        name = "ChildUpView"
        ,orthographicSize = 0.55
        ,width = 341
        ,height = 341
        ,offsetY = -0.21
    }

    local fun = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview1)
        rawImage.transform.localPosition = Vector3.zero
        rawImage.transform.localScale = Vector3.one
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    local fun2 = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview2)
        rawImage.transform.localPosition = Vector3.zero
        rawImage.transform.localScale = Vector3.one
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
    self.previewComposite2 = PreviewComposite.New(fun2, setting, data2)
end

function PetChildUpgradeView:update_item()
    local data = DataChild.data_upgrade[string.format("%s_%s", self.model.currChild.base_id, self.model.currChild.grade + 1)]
    if data == nil then
        return
    end

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

    if self.model.currChild.grade == 0 and self.model.currChild.lev < 85 then
        self.buttonscript.content = TI18N("85级进阶")
    elseif self.model.currChild.grade == 1 and self.model.currChild.lev < 95 then
        self.buttonscript.content = TI18N("95级进阶")
    else
        self.buttonscript.content = TI18N("进 阶")
    end

    self.buttonscript:Layout({[cost[1]] = {need = cost_num}}, function() self:button_click() end, function (baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end, { antofreeze = false })
end

function PetChildUpgradeView:update_canupgradetips()
    local petData = self.model.currChild
    local stone_hole = petData.grade + 2
    if #petData.stones < stone_hole then
        self.canNotUpgradeTips:SetActive(true)
    else
        self.canNotUpgradeTips:SetActive(false)
    end
end

function PetChildUpgradeView:update_upgradequality()
    local petData = self.model.currChild
    self.transform:FindChild("Main/ChildUpgradeQualityImage").gameObject:SetActive(true)
    -- if petData.genre == 2 or petData.genre == 4 then
    --     self.transform:FindChild("Main/UpgradeQualityImage"):GetComponent(Image).sprite
    --         = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_Pet_Upgrade_Add2")
    -- else
    --     self.transform:FindChild("Main/UpgradeQualityImage"):GetComponent(Image).sprite
    --         = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_Pet_Upgrade_Add")
    -- end
end

function PetChildUpgradeView:button_click()
    local gen_skill_num = {}
    for _,value in ipairs(self.model.currChild.skills) do
        if value.source == 3 then
            table.insert(gen_skill_num, string.format("<color='#25BFCF'>[%s]</color>", DataSkill.data_child_skill[value.id].name))
        end
    end

    local id = self.model.currChild.child_id
    local platform = self.model.currChild.platform
    local zone_id = self.model.currChild.zone_id

    if #gen_skill_num > 1 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        local skillName = ""
        for index,value in ipairs(gen_skill_num) do
            skillName = string.format("%s%s", skillName, value)
            if index ~= #gen_skill_num then skillName = string.format("%s、", skillName) end
        end
        data.content = string.format(TI18N("你的孩子佩戴了拥有%s两个技能的护符，进阶<color='#00ff00'>随机</color>保留<color='#00ff00'>1个</color>，确定要进阶吗？"), skillName)
        data.sureLabel = TI18N("进阶")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self:OnClickClose()
            ChildrenManager.Instance:Require18617(id, platform, zone_id)
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        self:OnClickClose()
        ChildrenManager.Instance:Require18617(id, platform, zone_id)
    end
end

function PetChildUpgradeView:callbackAfter12406(baseidToBuyInfo)
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