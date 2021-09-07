BackpackRolePanel = BackpackRolePanel or BaseClass(BasePanel)

function BackpackRolePanel:__init(model)
    self.model = model
    self.parent = nil
    self.transform = nil
    self.resList = {
        {file = AssetConfig.backpack_role, type = AssetType.Main},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
        {file = AssetConfig.rolebgstand, type = AssetType.Dep},
        {file = AssetConfig.portrait_textures, type = AssetType.Dep},
    }

    self.isInit = false
    self.equipList = {}
    self.upList = {}
    self.extra = {
        white_list = {
            {id = TipsEumn.ButtonType.Smith, show = true},
            {id = TipsEumn.ButtonType.Trans, show = true},
            {id = TipsEumn.ButtonType.Xilian, show = true},
            {id = TipsEumn.ButtonType.Dianhua, show = true}
        },
        nobutton = true
    }
    self.worldLevChange = function() self:UpdateWorldLev() end
    self.listener = function() self:UpdateSwitcherRed() end
    self.nameChangeListener = function() self:UpdateName() end
    self.updateListener = function(list) self:Update(list) end
    self.infoUpdateListener = function() self:UpdateInfo() end
    self.previewListener = function() self:UpdatePreview() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.wingSlot = nil

    self.tips = {
        TI18N("<color='#ffff00'>人物评分构成：</color>"),
        TI18N("<color='#00B0F0'>1、装备评分</color>"),
        TI18N("<color='#00B0F0'>2、已分配属性点*<color='#ffff00'>1.6</color></color>"),
        TI18N("<color='#00B0F0'>3、职业技能总等级*<color='#ffff00'>0.7</color></color>"),
        TI18N("<color='#00B0F0'>4、强壮精通等级*<color='#ffff00'>3</color></color>"),
        TI18N("<color='#00B0F0'>5、冒险技能总等级*<color='#ffff00'>10</color></color>"),
        TI18N("<color='#00B0F0'>6、宝石总等级*<color='#ffff00'>6</color></color>"),
        TI18N("<color='#00B0F0'>7、翅膀评分</color>")
    }
end

function BackpackRolePanel:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.renamePanel ~= nil then
        self.renamePanel:DeleteMe()
        self.renamePanel = nil
    end

    if self.classes ~= nil then
        self.classes.sprite = nil
    end

    for k,v in pairs(self.equipList) do
        v:DeleteMe()
    end
    self.equipList = nil
    self.model = nil


    GameObject.DestroyImmediate(self.gameObject)
    self.equipList = {}
    self.isInit = false
    self.gameObject = nil
    self.transform = nil
    self:AssetClearAll()

    self:RemoveListeners()
end

function BackpackRolePanel:AddListeners()
    EventMgr.Instance:AddListener(event_name.world_lev_change, self.worldLevChange)
    EventMgr.Instance:AddListener(event_name.role_attr_change, self.listener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.infoUpdateListener)
    EventMgr.Instance:AddListener(event_name.equip_item_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_name_change, self.nameChangeListener)
    EventMgr.Instance:AddListener(event_name.role_looks_change, self.previewListener)
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.previewListener)
end

function BackpackRolePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.world_lev_change, self.worldLevChange)
    EventMgr.Instance:RemoveListener(event_name.role_attr_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_name_change, self.nameChangeListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.infoUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_looks_change, self.previewListener)
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.previewListener)
end

function BackpackRolePanel:OnInitCompleted()
    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
    self:OnShow()
end

function BackpackRolePanel:OnShow()
    self:UpdateName()
    self:UpdateInfo()
    self:UpdateWorldLev()
    self:UpdateEquip()
    self:UpdateWingIcon()
    self:UpdatePreview()
    self:UpdateSwitcher(self.model.currentIndex)
    self:UpdateSwitcherRed()
    self:UpdateFightRed()
end

function BackpackRolePanel:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function BackpackRolePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_role))
    self.gameObject.name = "BackpackRolePanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(-185, 0, 0)
    self.transform:SetSiblingIndex(2)

    self.transform:Find("RoleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.transform:Find("RoleStand"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")

    self.preview = self.transform:Find("Preview").gameObject
    self.preview:SetActive(false)
    self.worldIcon = self.transform:Find("WorldIcon"):GetComponent(Image)
    self.worldIcon.gameObject:GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.worldIcon.gameObject, itemData = RoleManager.Instance:WorldlevTips()})
    end)
    self.transform:Find("Info"):GetComponent(Button).onClick:AddListener(function() self:Rename() end)
    self.infoRect = self.transform:Find("Info"):GetComponent(RectTransform)
    self.nameTxt = self.transform:Find("Info/RoleNameText"):GetComponent(Text)
    self.nameTxt.supportRichText = true
    self.classes = self.transform:Find("Info/Classes"):GetComponent(Image) self.renameBtn = self.transform:Find("Info/Rename"):GetComponent(Button)
    self.switchObj1 = self.transform:Find("Switcher1").gameObject
    self.switchBtn1 = self.switchObj1:GetComponent(Button)
    self.switchImg1 = self.switchObj1:GetComponent(Image)
    self.switchRed1 = self.switchObj1.transform:Find("Red").gameObject
    self.switchBtn2 = self.transform:Find("Switcher2"):GetComponent(Button)
    self.switchRed2 = self.switchBtn2.transform:Find("Red").gameObject

    self.fightObj = self.transform:Find("Fight").gameObject
    local fightBtn = self.fightObj:AddComponent(Button)
    fightBtn.onClick:AddListener(function() self:ShowTips() end)

    self.fightRect = self.transform:Find("Fight/Container"):GetComponent(RectTransform)
    self.fightTxt = self.transform:Find("Fight/Container/Value"):GetComponent(Text)
    self.transform:Find("Fight").gameObject:SetActive(true)
    self.fightRed = self.transform:Find("Fight/Up/Red").gameObject
    self.showFightRed = true

    self.switchBtn1.onClick:AddListener(function() self:OnClickSwitcher1() end)
    self.switchBtn2.onClick:AddListener(function() FashionManager.Instance.model:OpenFashionUI() end)
    self.renameBtn.gameObject:SetActive(true)
    self.renameBtn.onClick:AddListener(function() self:Rename() end)
    local equips = self.transform:Find("EquipGirds").gameObject.transform
    for i=1,9 do
        local equip = equips:GetChild(i-1):Find("ItemSlot").gameObject
        table.insert(self.equipList, ItemSlot.New(equip))
        local upObj = equips:GetChild(i - 1):Find("Up").gameObject
        upObj:SetActive(false)
        table.insert(self.upList, upObj)
    end

    self.wingSlot = self.equipList[9]
    self.wingSlot.noTips = true
    self.portraitBtn = self.transform:Find("PortraitEnter"):GetComponent(Button)
    self.portraitBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.portraitwindow) end)

    local otherSlot = self.transform:Find("EquipGirds"):GetChild(9):Find("ItemSlot")

    if self.imgLoader == nil then
        self.imgLoader = SingleIconLoader.New(otherSlot:Find("ItemImg").gameObject)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 20699)

    BaseUtils.SetGrey(otherSlot:Find("ItemImg"):GetComponent(Image), not ShouhuManager.Instance.model:CheckWakeUpIsOpen())
    otherSlot:GetComponent(Button).onClick:AddListener(function()
        if ShouhuManager.Instance.model:CheckWakeUpIsOpen() then
            ShouhuManager.Instance.model:OpenShouhuWakeUpAttrTipsUI()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("守护觉醒魂石尚未开启"))
        end
    end)

    self:AddListeners()

    self.isInit = true
end

function BackpackRolePanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

function BackpackRolePanel:UpdateInfo()
    local role = RoleManager.Instance.RoleData
    self:UpdateName()
    self.classes.sprite = PreloadManager.Instance:GetClassesSprite(role.classes)
    self.fightTxt.text = tostring(role.fc)
    local len = self.fightTxt.preferredWidth + 40
    self.fightRect.sizeDelta = Vector2(len, 30)
end

function BackpackRolePanel:UpdateWorldLev()
    if RoleManager.Instance.exp_ratio_real > 1000 then
        self.worldIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "I18NWorldLev_Up")
    elseif RoleManager.Instance.exp_ratio_real == 1000 then
        self.worldIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "I18NWorldLev_Normal")
    elseif RoleManager.Instance.exp_ratio_real < 1000 then
        self.worldIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "I18NWorldLev_Down")
    end
    self.worldIcon.gameObject.transform.localScale = Vector3.one
    self.worldIcon:SetNativeSize()
    self.worldIcon.gameObject:SetActive(true)
end

function BackpackRolePanel:UpdateEquip()
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        local slot = self.equipList[v.pos]
        slot:SetAll(v, self.extra)
        slot:ShowEnchant(true)
        slot:ShowLevel(true)
        slot:SetQuality(0)
        self.upList[v.pos]:SetActive(BackpackManager.Instance:EquipCanUpgrade(v))
    end
    self:ChangeItemTextColor()


    local otherSlot = self.transform:Find("EquipGirds"):GetChild(9):Find("ItemSlot")
    BaseUtils.SetGrey(otherSlot:Find("ItemImg"):GetComponent(Image), not ShouhuManager.Instance.model:CheckWakeUpIsOpen())
end

-- 更新翅膀图标
function BackpackRolePanel:UpdateWingIcon()
    if RoleManager.Instance.RoleData.lev < 12 then
        self.wingSlot:SetAll(nil)
        self.wingSlot:ShowAddBtn(true)
        local tips = {TI18N("12级开启翅膀功能,赶快升级吧!")}
        self.wingSlot:SetAddCallback(function() TipsManager.Instance:ShowText({gameObject = self.wingSlot.gameObject, itemData = tips}) end)
        self.wingSlot:SetSelectSelfCallback(nil)
    else
        self.wingSlot:ShowAddBtn(false)
        local wingID = WingsManager.Instance.wing_id
        local grade = WingsManager.Instance.grade
        if wingID ~= nil and wingID ~= 0 then
            local base = nil
            if DataWing.data_base[wingID].grade < 2000 then
                base = DataItem.data_get[WingsManager.Instance:GetItemByGrade(grade)]
            else
                base = DataItem.data_get[DataWing.data_base[wingID].item_id]
            end
            local itemData = ItemData.New()
            itemData:SetBase(base)
            self.wingSlot:SetAll(itemData, {nobutton = true})
            self.wingSlot:SetSelectSelfCallback(function() self:ClickWing(itemData) end)
        else
            self.wingSlot:ShowAddBtn(true)
            self.wingSlot:SetAddCallback(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {3}) end)
            self.wingSlot:SetSelectSelfCallback(nil)
        end
        self.wingSlot:SetQuality(0)
    end
end

function BackpackRolePanel:Update(list)
    for _,dat in ipairs(list) do
        local slot = self.equipList[dat.pos]
        slot:SetAll(BackpackManager.Instance.equipDic[dat.id], self.extra)
        slot:ShowEnchant(true)
        slot:ShowLevel(true)
    end

    self:ChangeItemTextColor()
end

function BackpackRolePanel:UpdateSwitcher(index)
    if not self.isInit then
        return
    end
    if index == 1 then
        self.switchImg1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "I18NAttributeButton")
    else
        self.switchImg1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "I18NGoodsButton")
    end
end

function BackpackRolePanel:OnClickSwitcher1()
    if self.model.currentIndex == 1 then
        self.model:ChangeSub(2)
    else
        self.model:ChangeSub(1)
    end
end

function BackpackRolePanel:UpdateSwitcherRed()
    if RoleManager.Instance.RoleData.point == 0 then
        self.switchRed1:SetActive(false)
    else
        self.switchRed1:SetActive(true)
    end

    local fashionModel = FashionManager.Instance.model
    local cfgData = DataFashion.data_face[string.format("%s_%s", fashionModel.collect_lev+1, RoleManager.Instance.RoleData.classes)]
    local percent = fashionModel.collect_val/cfgData.loss_collect
    if percent >= 1 then
        self.switchRed2:SetActive(true)
    else
        self.switchRed2:SetActive(false)
    end
end

function BackpackRolePanel:UpdateFightRed()
    if self.showFightRed or ForceImproveManager.Instance.model:CheckCanUpgrade(false) then
        self.fightRed:SetActive(true)
    else
        self.fightRed:SetActive(false)
    end
end

function BackpackRolePanel:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "BackpackRole"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks}
    if BaseUtils.IsVerify then
        modelData.isTransform = true
    end
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()

    -- local callback = function(composite)
    -- end
    -- local setting = {
    --     name = "BackpackRole"
    --     ,layer = "UI"
    --     ,parent = self.preview.transform
    --     ,localRot = Vector3(0, 0, 0)
    --     ,localPos = Vector3(0, -108, -150)
    --     ,usemask = false
    --     ,sortingOrder = 21
    -- }
    -- local llooks = {}
    -- local mySceneData = SceneManager.Instance:MyData()
    -- if mySceneData ~= nil then
    --     llooks = mySceneData.looks
    -- end
    -- self.preview.gameObject:SetActive(true)
    -- local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks, scale = 2}
    -- if self.previewComp == nil then
    --     self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
    -- else
    --     self.previewComp:Reload(modelData, callback)
    -- end
    -- self.previewComp:Show()
end

function BackpackRolePanel:ClickWing(data)
    data = BaseUtils.copytab(data)
    data.wingData = {
        grade = WingsManager.Instance.grade,
        wing_id = WingsManager.Instance.wing_id,
        growth = WingsManager.Instance.growth,
        enhance = WingsManager.Instance.enhance,
    }

    local info = {gameObject = self.wingSlot.gameObject, itemData = data}
    TipsManager.Instance:ShowWing(info)
end

function BackpackRolePanel:UpdateName()
    if self.nameTxt ~= nil then
        local role = RoleManager.Instance.RoleData
        if role.lev_break_times == 0 then
            self.nameTxt.text = string.format("%s %s%s", role.name, role.lev, TI18N("级"))
        else
            self.nameTxt.text = string.format("%s <color='#11d1ff'>%s%s</color>", role.name, role.lev, TI18N("级"))
        end
    end

    self.infoRect.sizeDelta = Vector2(self.nameTxt.preferredWidth + 50, 30)

    -- self.renameBtn.gameObject.transform.anchoredPosition = Vector2(-23 + self.nameTxt.preferredWidth + 2, 0)
end

function BackpackRolePanel:ShowTips()
    -- TipsManager.Instance:ShowText({gameObject = self.fightObj, itemData = self.tips})
    self.showFightRed = false
    self:UpdateFightRed()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.force_improve, {1})
end

function BackpackRolePanel:Rename()
    if self.renamePanel == nil then
        self.renamePanel = BackpackRenamePanel.New(self.parent.gameObject, self.model)
    end
    self.renamePanel:Show()
end

function BackpackRolePanel:ChangeItemTextColor()
    local levelList = {}
    for i,v in ipairs(self.equipList) do
        if v.itemData ~= nil and i <= 8 then
            if v.itemData.lev ~= nil then
                levelList[#levelList + 1] = {}
                levelList[#levelList].slot = v
                levelList[#levelList].lev = v.itemData.lev
            end
        end
    end


    table.sort(levelList,function(a,b)
               if a.lev ~= b.lev then
                    return a.lev < b.lev
                else
                    return false
                end
            end)
    
    if levelList[1] ~= nil then
        local lowLevel = levelList[1].lev
        for i,v in ipairs(levelList) do
            if v.lev > lowLevel then
                v.slot.equipLevelTxt.text = string.format("<color='#ffff00'>%s</color>",v.slot.itemData.lev)
            end
        end
    end
end