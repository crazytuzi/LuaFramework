-- ----------------------------------------------------------
-- UI - 宠物窗口 宠物突破
-- ----------------------------------------------------------
PetBreakWindow = PetBreakWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetBreakWindow:__init(model)
    self.model = model
    self.name = "PetBreakWindow"
    self.windowId = WindowConfig.WinID.petbreakwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy
    self.effectPath = "prefabs/effect/20056.unity3d"

    self.resList = {
        {file = AssetConfig.petbreakwindow, type = AssetType.Main}
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

    self.breakTips = {TI18N("1、突破宠物需要玩家<color='#ffff00'>突破等级上限</color>后才能携带")
                        , TI18N("2、突破宠物的专有技能需要<color='#ffff00'>宠物突破后</color>才会生效")
                        , TI18N("3、宠物突破后，<color='#ffff00'>不会吞噬</color>护符/符石，<color='#ffff00'>不会</color>增加资质上限")
                        , TI18N("4、专有技能<color='#ffff00'>不会</color>被学习技能/洗髓<color='#00ff00'>替换掉</color>，会一直存在")}

	------------------------------------------------
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetBreakWindow:__delete()
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

function PetBreakWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petbreakwindow))
    self.gameObject.name = "PetBreakWindow"
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
         = TI18N("1、突破成功后，宠物将激活<color='#ffff00'>专有技能</color>\n2、突破时宠物符石和护符都将<color='#ffff00'>不会被吞噬</color>")


    -- transform:FindChild("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.buttonscript = BuyButton.New(transform:FindChild("Main/OkButton"), TI18N("突 破"))
    self.buttonscript.protoId = 10550
    self.buttonscript:Show()

    self.moneyNum = transform:FindChild("Main/MoneyNum").gameObject

    self.canNotUpgradeTips = transform:FindChild("Main/CanNotUpgradeTipsText").gameObject

    transform:FindChild("Main/DescButton"):GetComponent(Button).onClick:AddListener(
        function() TipsManager.Instance:ShowText({gameObject = transform:FindChild("Main/DescButton").gameObject, itemData = self.breakTips}) end)

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

function PetBreakWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetBreakWindow:OnShow()
	self:update()
end

function PetBreakWindow:OnHide()

end

function PetBreakWindow:update()
    if self.model.cur_petdata == nil then return end
    self:update_pet()
    self:update_item()
    self:update_canupgradetips()
    self:update_upgradequality()
end

function PetBreakWindow:update_pet()
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

function PetBreakWindow:update_item()
    local data = DataPet.data_pet[self.model.cur_petdata.base.id]
    if data == nil then return end
    local cost = data.lev_break_cost[1]
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

    self.moneyNum.gameObject:SetActive(false)
    self.buttonscript:Layout({[cost[1]] = {need = cost_num}}, function() self:button_click() end, function (baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end, { antofreeze = false })
end

function PetBreakWindow:update_canupgradetips()
    -- local petData = self.model.cur_petdata
    -- local stone_hole = petData.grade + 2
    -- if #petData.stones < stone_hole then
    --     self.canNotUpgradeTips:SetActive(true)
    --     self.canNotUpgradeTips:GetComponent(Text).text = TI18N("宠物装备满符石后才能突破")
    -- else
    --     self.canNotUpgradeTips:SetActive(false)
    -- end
    self.canNotUpgradeTips:SetActive(false)
end

function PetBreakWindow:update_upgradequality()
    local petData = self.model.cur_petdata
    if petData.genre == 2 or petData.genre == 4 then
        self.transform:FindChild("Main/UpgradeQualityImage"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_Pet_Upgrade_Add3")
    else
        self.transform:FindChild("Main/UpgradeQualityImage"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_Pet_Upgrade_Add3")
    end
end

function PetBreakWindow:button_click()
    local gen_skill_num = {}
    for _,value in ipairs(self.model.cur_petdata.skills) do
        if value.source == 2 then
            table.insert(gen_skill_num, string.format("<color='#25BFCF'>[%s]</color>", DataSkill.data_petSkill[string.format("%s_1", value.id)].name))
        end
    end

	local skillName = ""
	for key, value in ipairs(self.model.cur_petdata.base.lev_break_skills) do
	    local skill_data = DataSkill.data_petSkill[string.format("%s_1", value)]
	    if key == 1 then
	        skillName = string.format("[%s]", skill_data.name)
	    else
	        skillName = string.format("%s、[%s]", skillName, skill_data.name)
	    end
	end

	-- 突破宠物特殊处理
	local data = NoticeConfirmData.New()
	data.type = ConfirmData.Style.Normal
	data.content = string.format(TI18N("宠物突破成功后，可以激活<color='#00ff00'>%s</color>，突破不会吞噬护符和符石，也不会增加资质。是否进行突破？"), skillName)
	data.sureLabel = TI18N("突破")
	data.cancelLabel = TI18N("取消")
	data.sureCallback = function()
	    self:OnClickClose()
	    PetManager.Instance:Send10550(self.model.cur_petdata.id)
	end
	NoticeManager.Instance:ConfirmTips(data)
end

function PetBreakWindow:callbackAfter12406(baseidToBuyInfo)
    local coins = RoleManager.Instance.RoleData.coins
    local gold_bind = RoleManager.Instance.RoleData.gold_bind

    for k,v in pairs(baseidToBuyInfo) do
        local numText = self.moneyNum:GetComponent(Text)
        numText.gameObject:SetActive(true)

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