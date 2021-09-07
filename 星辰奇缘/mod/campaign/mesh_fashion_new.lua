-- @author 黄耀聪
-- @date 2017年8月8日, 星期二

MeshFashionNew = MeshFashionNew or BaseClass(BasePanel)

function MeshFashionNew:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MeshFashionNew"

    self.resList = {
        {file = AssetConfig.mesh_fashion, type = AssetType.Main}
        , {file = AssetConfig.specialitem_texture, type = AssetType.Dep}
        , {file = AssetConfig.fashionres, type = AssetType.Dep}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
        , {file = AssetConfig.mesh_fashion_show_bg, type = AssetConfig.Main}

        -- , {file = "prefabs/effect/15100.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/15101.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/15102.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/13100.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/13101.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/12100.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/12101.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/11100.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/11101.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/11102.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/11103.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/14101.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/17100.unity3d", type = AssetType.Main}
        -- , {file = "prefabs/effect/17101.unity3d", type = AssetType.Main}
    }

    self.campId = nil
    self.itemList = {}

    self.updateListener = function() self:ReloadRole() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MeshFashionNew:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v.iconLoader ~= nil then
                v.iconLoader:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    self:AssetClearAll()
end

function MeshFashionNew:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mesh_fashion))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.layout = LuaBoxLayout.New(t:Find("ItemBg/Scroll/Container"), {cspacing = 0, border = 2, axis = BoxLayoutAxis.X})
    self.cloner = t:Find("ItemBg/Scroll/Cloner").gameObject

    self.button = t:Find("ItemBg/Button"):GetComponent(Button)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.roleContainer = t:Find("Role")

    self.attrTrans = t:Find("Attr")
    self.attrText = t:Find("Attr/Text"):GetComponent(Text)

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.mesh_fashion_show_bg)))
    self.button.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1, 4}) end)
end

function MeshFashionNew:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MeshFashionNew:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.self_loaded, self.updateListener)

    self:Reload()
end

function MeshFashionNew:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function MeshFashionNew:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.self_loaded, self.updateListener)
end

function MeshFashionNew:Reload()
    local cfgData = DataCampaign.data_list[self.campId]
    local rewardList = CampaignManager.ItemFilter(cfgData.rewardgift)

    self.nameText.text = cfgData.name
    self.cloner:SetActive(false)
    self.layout:ReSet()
    self.fashionList = {}

    local count = 0
    local str = nil
    for i,v in ipairs(rewardList) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.select = tab.transform:Find("Select").gameObject
            tab.iconLoader = SingleIconLoader.New(tab.transform:Find("Icon").gameObject)
            tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickItem(tab) end)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)
        tab.select:SetActive(false)
        tab.base_id = v[1]

        tab.iconLoader.gameObject:SetActive(true)
        local itemdata = DataItem.data_get[v[1]]
        for _,effect in pairs(itemdata.effect) do
            if effect.effect_type == 25 then
                for _,val in ipairs(effect.val) do
                    table.insert(self.fashionList, val[1])
                end
            -- elseif v.effect_type == 28 then
                -- count = count + 1
                -- if str == nil then
                --     str = string.format(TI18N("属性点<color='%s'>+%s</color>"), ColorHelper.color[5], tostring(v.val[1]))
                -- else
                --     str = str .. string.format(TI18N("\n属性点<color='%s'>+%s</color>"), ColorHelper.color[5], tostring(v.val[1]))
                -- end
            end
        end

        tab.iconLoader:SetSprite(SingleIconType.Item, itemdata.icon)
    end
    for i=#rewardList+1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end

    -- if count == 0 then count = 1 end
    count = 2
    str = string.format(TI18N("颜值<color='%s'>+180</color>\n属性点<color='%s'>+2</color>"), ColorHelper.color[5], ColorHelper.color[5])
    self.attrText.text = string.format(TI18N("%s"), str or TI18N("无加成"))
    self.attrTrans.sizeDelta = Vector2(130, 61 + 19 * count)

    self:ReloadRole()
end

function MeshFashionNew:OnClickItem(tab)
    if self.lastTab ~= nil then
        self.lastTab.select:SetActive(false)
    end
    tab.select:SetActive(true)
    self.lastTab = tab
    TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = DataItem.data_get[tab.base_id], extra = {}})
end

function MeshFashionNew:ReloadRole()
    local callback = function(composite)
        self:SetRamImage(composite)
    end

    local setting = {
        name = "MeshFashionNewRole"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 256
        ,offsetY = -0.3
    }


    local targetList = nil
    if RoleManager.Instance.RoleData.sex == 0 then --女
        targetList = CreateRoleManager.Instance.model.femaleEffectList
    else
        targetList = CreateRoleManager.Instance.model.maleEffectList
    end


    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)

    if unitData == nil then
        return
    end

    local kvLooks = {}
    local roledata = RoleManager.Instance.RoleData
    for _,v in pairs(unitData.looks) do
        kvLooks[v.looks_type] = v
    end
    self.has_belt = false
    for k,v in pairs(self.fashionList) do
        local fashionData = DataFashion.data_base[v]
        if (fashionData.classes == 0 or roledata.classes == fashionData.classes) and (fashionData.sex == 2 or roledata.sex == fashionData.sex) then
            kvLooks[fashionData.type] = {looks_str = "", looks_val = fashionData.model_id, looks_mode = fashionData.texture_id, looks_type = fashionData.type}
            if fashionData.type == SceneConstData.lookstype_belt then
                self.has_belt = true
            end
        end
    end
    self.temp_looks = {}
    for k,v in pairs(kvLooks) do
        table.insert(self.temp_looks, v)
    end

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = self.temp_looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        -- self.previewComp:Reload(modelData, callback)
        self.previewComp:Show()
        -- self.previewComp:PlayAnimation(tostring(BaseUtils.GetShowActionId(RoleManager.Instance.RoleData.classes,RoleManager.Instance.RoleData.sex)))
        self.previewComp:PlayMotion(FighterAction.Stand)
    end

end

function MeshFashionNew:SetRamImage(composite)
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.roleContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1.5, 1.5, 1)

    self.last_tpose = composite.tpose

    composite:PlayMotion(FighterAction.Stand)
    -- composite:PlayAnimation(tostring(BaseUtils.GetShowActionId(RoleManager.Instance.RoleData.classes,RoleManager.Instance.RoleData.sex)))

    -- local targetList = nil
    -- if RoleManager.Instance.RoleData.sex == 0 then --女
    --     targetList = CreateRoleManager.Instance.model.femaleEffectList
    -- else
    --     targetList = CreateRoleManager.Instance.model.maleEffectList
    -- end

    -- for i=1,#targetList do
    --    local ed = targetList[i]
    --     if ed.Classes == RoleManager.Instance.RoleData.classes then
    --         self:fight_effect(ed)
    --     end
    -- end
end

function MeshFashionNew:fight_effect(effectObjectData)
    local attackPos = self.last_tpose.transform.position

    local attackTransform = self.last_tpose.transform
    local tempStr = "prefabs/effect/%s.unity3d"
    tempStr = string.format(tempStr, tostring(effectObjectData.EffectId))

    local effect = self:GetPrefab(tempStr)

    if effect == nil then
        -- mod_notify.append_scroll_win(string.format("缺少特效资源:%s",tostring(effectObjectData.EffectId)))
        Log.Error(string.format("缺少特效资源:%s",tostring(effectObjectData.EffectId)))
        return
    end

    local effectObject = GameObject.Instantiate(effect)
    -- table.insert(self.effectList, effectObject)

    if effectObjectData.type == 0 then
        return
    end
    if effectObjectData.EffectTargetPoint == EffectTargetPoint.Weapon then
        self:bind_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.Origin  then
        effectObject.transform:SetParent(attackTransform)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.LHand  then
        self:bind_hand(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.RHand then
        self:bind_hand(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.LWeapon then
        self:bind_left_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.RWeapon then
        self:bind_right_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    else
        effectObject.transform:SetParent(attackTransform)
    end

    effectObject.transform.localScale = Vector3(1, 1, 1)
    effectObject.transform.localPosition = Vector3(0, 0, 0)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
    effectObject:SetActive(true)
end

function MeshFashionNew:bind_hand(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        -- table.insert(self.effectList, leffect)
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Hand")
        leffect.transform:SetParent(attackTransform:Find(weaponPoint))
        leffect.transform.localPosition = Vector3.zero
        leffect.transform.localRotation = Quaternion.identity
        leffect.transform.localScale = Vector3(1.0,1.0,1.0)
    elseif classes == 3 then

    elseif classes == 5 then
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    else
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    end
end

--绑武器
function MeshFashionNew:bind_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        -- table.insert(self.effectList, leffect)
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
        leffect.transform:SetParent(attackTransform:Find(weaponPoint))
        leffect.transform.localPosition = Vector3.zero
        leffect.transform.localRotation = Quaternion.identity
        leffect.transform.localScale = Vector3(1.0,1.0,1.0)
    elseif classes == 3 then

    elseif classes == 5 then
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    else
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    end
end

function MeshFashionNew:bind_right_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

--绑左武器
function MeshFashionNew:bind_left_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

function MeshFashionNew:bind_right_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end
