-- 已废弃

BackpackWingPanel = BackpackWingPanel or BaseClass(BasePanel)

function BackpackWingPanel:__init(model)
    self.model = model
    self.parent = nil

    self.resList = {
        {file = AssetConfig.backpack_wings, type = AssetType.Main},
        {file = AssetConfig.wing_tips, type = AssetType.Main},
        -- {file = AssetConfig.base_textures, type = AssetType.Dep},
        {file = AssetConfig.wing_quality_icon, type = AssetType.Dep},
    }

    self.panelList = {nil, nil, nil, nil}
    self.buttonList = {nil, nil, nil, nil}
    self.numberToChinese = {
        TI18N("一"),
        TI18N("二"),
        TI18N("三"),
        TI18N("四"),
        TI18N("五")
    }

    self.wingTips = nil
    self.idToObj = {}
    self.wingEffects = {}

    self.wingIconLoader = nil
    self.iconLoader = nil

    self.loaders = {}

    self.levelChangeListener = function() self:OnLevelChangeListener() end
    self.roleAssetsChangeListener = function() self:OnRoleAssetsChangeListener() end
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.reloadListener = function() self:ReloadPanel() end

    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.roleAssetsChangeListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeListener)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.roleAssetsChangeListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeListener)

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:Add(self.hideListener)
end

function BackpackWingPanel:InitPanel()
    local model = self.model

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_wings))
    self.gameObject.name = "BackpackWingPanel"
    self.transform = self.gameObject.transform

    local show = self.transform:Find("Show")
    self.preview = self.transform:Find("Preview").gameObject

    local wing_id = nil
    if model.wing_id == nil then
        wing_id = 20000
    else
        wing_id = model.wing_id
    end

    UIUtils.AddUIChild(self.parent.transform:Find("Main").gameObject, self.gameObject)

    local info = show:Find("Info")
    self.titleObj = info:Find("Title").gameObject
    self.titleObj:SetActive(false)
    self.colorImage = info:Find("Title/Icon"):GetComponent(Image)
    self.colorImage.gameObject:SetActive(false)
    self.nameText = info:Find("Title/Name"):GetComponent(Text)
    self.levText = info:Find("Title/Lev"):GetComponent(Text)
    self.nextBtn = self.transform:Find("NextButton"):GetComponent(Button)
    self.nextBtn.onClick:AddListener(function () self:NextWing() end)
    self.nextEnable = self.nextBtn.transform:Find("Enable").gameObject
    self.nextDisable = self.nextBtn.transform:Find("Disable").gameObject
    self.preBtn = self.transform:Find("PreButton"):GetComponent(Button)
    self.preBtn.onClick:AddListener(function () self:PreWing() end)
    self.preEnable = self.preBtn.transform:Find("Enable").gameObject
    self.preDisable = self.preBtn.transform:Find("Disable").gameObject
    local property = show:Find("Property")
    self.propertyList = {nil, nil, nil, nil}
    self.propertyTextList = {nil, nil, nil, nil}
    self.propertyValueList = {nil, nil, nil, nil}
    for i=1,4 do
        self.propertyList[i] = property:Find("Property"..i).gameObject
        self.propertyTextList[i] = self.propertyList[i].transform:Find("Text"):GetComponent(Text)
        self.propertyValueList[i] = self.propertyList[i].transform:Find("Value"):GetComponent(Text)
    end
    self.propertyObj = property.gameObject
    self.propertyRect = property:GetComponent(RectTransform)

    if self.wingEffects[5] ~= nil then
        self.wingEffects[5]:DeleteMe()
    end
    self.wingEffects[5] = self:ShowEffect(20059, self.colorImage.transform, Vector3(0.95, 0.8, 1), Vector3(0, 2,-100))

    local operatePanel = self.transform:Find("OperatePanel")
    operatePanel:SetAsLastSibling()
    local tabButtonGroup = operatePanel:Find("TabButtonGroup")
    for i=1,4 do
        self.panelList[i] = operatePanel:Find("Panel"..i)
        self.panelList[i].gameObject:SetActive(false)
    end

    if self.wingEffects[6] ~= nil then
        self.wingEffects[6]:DeleteMe()
    end
    self.wingEffects[6] = self:ShowEffect(20058, self.panelList[1]:Find("Quality/Icon"), Vector3(0.71, 0.75, 1), Vector3(-1.61,1.86,-100))
    local btn = self.panelList[1]:Find("Quality/Icon"):GetComponent(Button)
    btn.onClick:AddListener(function ()
        self:ShowWingTips(btn.gameObject)
    end)

    -- 信息页帮助按钮
    local helpBtn1 = self.panelList[1]:Find("Quality/Help"):GetComponent(Button)
    helpBtn1.onClick:AddListener(function ()
        self:ShowWingTips(helpBtn1.gameObject)
    end)

    -- 进阶页帮助按钮
    local helpBtn2 = self.panelList[2]:Find("LevelUp/Help"):GetComponent(Button)
    helpBtn2.onClick:AddListener(function ()
        self:ShowHelpTips(helpBtn2.gameObject, 2)
    end)

    if self.wingEffects[7] ~= nil then
        self.wingEffects[7]:DeleteMe()
    end
    self.wingEffects[7] = self:ShowEffect(20059, self.panelList[2]:Find("LevelUp/PreviewInfo/Title/QualifyImage"), Vector3(0.95, 0.8, 1), Vector3(0, 2,-100))

    -- 合成页帮助按钮
    local helpBtn3 = self.panelList[4]:Find("Help"):GetComponent(Button)
    helpBtn3.onClick:AddListener(function ()
        self:ShowHelpTips(helpBtn3.gameObject, 2)
    end)

    if self.wingEffects[8] ~= nil then
        self.wingEffects[8]:DeleteMe()
    end
    self.wingEffects[8] = self:ShowEffect(20059, self.panelList[4]:Find("PreviewInfo/Title/QualifyImage"), Vector3(0.95, 0.8, 1), Vector3(0, 2,-100))

    -- 重置页属性按钮
    local showPropertyBtn = self.panelList[3]:Find("Tips/ShowProperty"):GetComponent(Button)
    showPropertyBtn.onClick:AddListener(function ()
        self:ShowHelpTips(showPropertyBtn.gameObject, 3)
    end)

    -- 重置页外观按钮
    local showLookBtn = self.panelList[3]:Find("Tips/ShowLook"):GetComponent(Button)
    showLookBtn.onClick:AddListener(function ()
        self:ShowHelpTips(showLookBtn.gameObject, 4)
    end)

    if self.wingEffects[9] ~= nil then
        self.wingEffects[9]:DeleteMe()
    end
    self.wingEffects[9] = self:ShowEffect(20059, self.panelList[3]:Find("PreviewInfo/Title/QualifyImage"), Vector3(0.95, 0.8, 1), Vector3(0, 2,-100))

    local book1 = self.panelList[1]:Find("Book"):GetComponent(Button)
    book1.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(52, 60)
    book1.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wing_book) end)
    local book4 = self.panelList[4]:Find("Book"):GetComponent(Button)
    book4.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(52, 60)
    book4.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wing_book) end)

    self.synthesizeButton = BuyButton.New(self.panelList[4]:Find("MaterialInfo/Synthesize").gameObject, TI18N("合 成"), WindowConfig.WinID.backpack)     -- 合成按钮
    self.synthesizeButton:Show()
    self.synthesizeButton.protoId = 11601
    self.upgradeButton = BuyButton.New(self.panelList[2]:Find("LevelUp/MaterialInfo/Upgrade").gameObject, TI18N("进 阶"), WindowConfig.WinID.backpack)        -- 进阶按钮
    self.upgradeButton:Show()
    self.upgradeButton.protoId = 11603
    self.resetButton = BuyButton.New(self.panelList[3]:Find("ResetPanel/Button").gameObject, TI18N("重 置"), WindowConfig.WinID.backpack)          -- 重置按钮
    self.resetButton:Show()
    self.resetButton.protoId = 11604

    for i=1,4 do
        self.buttonList[i] = tabButtonGroup:Find("Button"..i)
        self.buttonList[i].gameObject:SetActive(false)
        self.buttonList[i]:GetComponent(Button).onClick:AddListener(function() self:UpdateButtonList(i) self:UpdatePanel(i) end)
    end

    if model.gotWingData ~= true then
        model:GetData()
        -- return
    end
end

function BackpackWingPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackpackWingPanel:__delete()
    self.OnHideEvent:Fire()

    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end

    if self.wingIconLoader ~= nil then
        self.wingIconLoader:DeleteMe()
        self.wingIconLoader = nil
    end

    for k,v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = nil

    if self.synthesizeButton ~= nil then
        self.synthesizeButton:DeleteMe()
        self.synthesizeButton = nil
    end
    if self.upgradeButton ~= nil then
        self.upgradeButton:DeleteMe()
        self.upgradeButton = nil
    end
    if self.resetButton ~= nil then
        self.resetButton:DeleteMe()
        self.resetButton = nil
    end
    if self.wingEffects ~= nil then
        for k,v in pairs(self.wingEffects) do
            if v ~= nil then
                v:DeleteMe()
                self.wingEffects[k] = nil
                v = nil
            end
        end
        self.wingEffects = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.wingTips ~= nil then
        GameObject.DestroyImmediate(self.wingTips)
        self.wingTips = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackpackWingPanel:SwitchTab(index)
    self.model.lastIndex = index
end

function BackpackWingPanel:UpdateButtonList(index)
    local model = self.model
    if index == 4 then
        for i=1,3 do
            self.buttonList[i].gameObject:SetActive(false)
        end
        self.buttonList[4].gameObject:SetActive(true)
    else
        for i=1,3 do
            self.buttonList[i].gameObject:SetActive(true)
            self.buttonList[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
            self.buttonList[i]:Find("Text"):GetComponent(Text).color = Color(0.48, 0.54, 0.6)
            self.panelList[i].gameObject:SetActive(false)
        end
        self.buttonList[4].gameObject:SetActive(false)

        model.lastIndex = index
        self.buttonList[model.lastIndex]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")
        self.buttonList[model.lastIndex]:Find("Text"):GetComponent(Text).color = Color(1, 1, 1)
        self.panelList[model.lastIndex].gameObject:SetActive(true)
    end
end

-- 刷新标签页
function BackpackWingPanel:UpdatePanel(index)
    local model = self.model
    for i=1,4 do
        self.panelList[i].gameObject:SetActive(false)
    end
    self.panelList[index].gameObject:SetActive(true)
    if index == 4 then
        self.nextBtn.gameObject:SetActive(true)
        self.preBtn.gameObject:SetActive(true)
        self.nextEnable:SetActive(true)
        self.nextDisable:SetActive(false)
        self.preEnable:SetActive(false)
        self.preDisable:SetActive(true)

        self.propertyObj:SetActive(true)
        self:UpdateProperty(1, 5)
        self:UpdateSynthesizePanel()
        self:ShowWingsList(model.wingsIdByGrade[1])
    else
        if index == 1 then
            self.nextBtn.gameObject:SetActive(false)
            self.preBtn.gameObject:SetActive(false)
            self.propertyObj:SetActive(false)
            self:UpdateProperty(model.grade, model.growth)
            self:UpdateInfoPanel()
            self:UpdateWingShow(model.wing_id)
        elseif index == 2 then
            self.nextBtn.gameObject:SetActive(true)
            self.preBtn.gameObject:SetActive(true)
            self.propertyObj:SetActive(true)
            self:UpdateUpgradePanel()
            self:UpdateWingShow(model.wing_id)
            if model.grade < 5 then
                self:UpdateProperty(model.grade + 1, 5)
                self:ShowWingsList(model.wingsIdByGrade[model.grade + 1])
            else
                self:UpdateProperty(5, 5)
                self:ShowWingsList(model.wingsIdByGrade[5])
            end
        elseif index == 3 then
            self.nextBtn.gameObject:SetActive(false)
            self.preBtn.gameObject:SetActive(false)
            self.propertyObj:SetActive(true)
            self.propertyObj:SetActive(true)
            if DataWing.data_base[model.temp_reset_id] == nil then
                self:UpdateWingShow(model.wing_id)
            else
                self:UpdateWingShow(model.temp_reset_id)
            end
            self:UpdateResetPanel()
        end
    end
end

function BackpackWingPanel:ReloadPanel()
    local model = self.model
    if model.wing_id == nil or model.wing_id == 0 then
        self:UpdateButtonList(4)
        self:UpdatePanel(4)
    else
        if model.lastIndex == nil then
            model.lastIndex = 1
        end
        self:UpdateButtonList(model.lastIndex)
        self:UpdatePanel(model.lastIndex)
    end
end

function BackpackWingPanel:ShowHelpTips(gameObject, type)
    local textlist = nil
    if type == 1 then
        textlist = {TI18N("1.翅膀分为5个品质"), TI18N("2.品质越好属性越高"), TI18N("3.重置可重新获取新的品质")}
    elseif type == 2 then
        textlist = {TI18N("1.翅膀分为5个等阶"), TI18N("2.提升翅膀等阶可获得更高属性、开启技能、更炫的翅膀")}
    elseif type == 3 then
        textlist = {TI18N("1.翅膀属性与翅膀品质挂钩"), TI18N("2.品质越好属性越高"), TI18N("3.红色品质为最佳属性"), TI18N("4.重置可获取新的品质")}
    elseif type == 4 then
        textlist = {TI18N("1.每个等阶分为几种翅膀"), TI18N("2.可选择自己喜欢的类型"), TI18N("3.重置可获取新的翅膀外观")}
    end
    TipsManager.Instance:ShowText({gameObject = gameObject, itemData = textlist})
end

function BackpackWingPanel:NextWing()
    local model = self.model
    local wingIdList = model.currentWingList
    local length = #wingIdList

    if model.currentWingIndex < length then
        model.currentWingIndex = model.currentWingIndex + 1
        self:UpdateWingShow(wingIdList[model.currentWingIndex])

        self:UpdateNextPreButtonState()
    end
end

function BackpackWingPanel:PreWing()
    local model = self.model
    local wingIdList = model.currentWingList
    local length = #wingIdList
    if model.currentWingIndex > 1 then
        model.currentWingIndex = model.currentWingIndex - 1
        self:UpdateWingShow(wingIdList[model.currentWingIndex])

        self:UpdateNextPreButtonState()
    end
end

function BackpackWingPanel:UpdateProperty(grade, grouth)
    local model = self.model
    local classes = RoleManager.Instance.RoleData.classes
    local msg = classes.."_"..grade.."_"..grouth
    local data = DataWing.data_attribute[msg]
    local attrlist = data.attr
    for i=1,4 do
        if attrlist[i] ~= nil then
            self.propertyList[i].gameObject:SetActive(true)
            self.propertyTextList[i].text = KvData.GetAttrName(attrlist[i].attr_name)..":"
            self.propertyValueList[i].text = tostring(attrlist[i].val)
        else
            self.propertyList[i].gameObject:SetActive(false)
        end
    end
end

-- 翅膀信息面板
function BackpackWingPanel:UpdateInfoPanel()
    local model = self.model
    local classes = RoleManager.Instance.RoleData.classes
    local msg = classes.."_"..model.grade.."_"..model.growth
    local data = DataWing.data_attribute[msg]
    local panel = self.panelList[1].transform
    local quality = panel:Find("Quality")
    local qualityIcon = quality:Find("Icon"):GetComponent(Image)
    local qualityText = quality:Find("Text"):GetComponent(Text)
    local descText = panel:Find("Desc"):GetComponent(Text)

    local propertyObj = panel:Find("Property")
    local attrlist = data.attr
    for i=1,4 do
        local pro = propertyObj:Find("Property"..i)
        if attrlist[i] ~= nil then
            pro.gameObject:SetActive(true)
            pro:Find("Text"):GetComponent(Text).text = KvData.GetAttrName(attrlist[i].attr_name)..":"
            pro:Find("Value"):GetComponent(Text).text = tostring(attrlist[i].val)
        else
            pro.gameObject:SetActive(false)
        end
    end
    qualityText.text = string.format(TI18N("品质:%s色"), ColorHelper.color_item_name(model.growth, KvData.quality_name[model.growth + 1]))
    qualityIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..model.growth)
end

-- 修改UI
function BackpackWingPanel:callbackAfter12406(baseidToBuyInfo)
    local coins = RoleManager.Instance.RoleData.coins
    local gold_bind = RoleManager.Instance.RoleData.gold_bind

    for k,v in pairs(baseidToBuyInfo) do
        local t = self.idToObj[k].transform
        local numText = t:Find("Num"):GetComponent(Text)

        local go = t:Find("Num/Currency").gameObject
        local id = go:GetInstanceID()
        local loader = self.loaders[id]
        if loader == nil then
            loader = SingleIconLoader.New(go)
            self.loaders[id] = loader
        end
        loader:SetSprite(SingleIconType.Item, v.assets)

        if v.allprice < 0 then
            numText.text = "<color=#FF0000>"..tostring(0 - v.allprice).."</color>"
        else
            numText.text = tostring(v.allprice)
        end
    end
end

-- 翅膀进阶面板
function BackpackWingPanel:UpdateUpgradePanel()
    self.baseidToNum = {}
    local model = self.model
    local panel = self.panelList[2].transform:Find("LevelUp")
    local grade = 5
    if model.grade < 5 then
        grade = model.grade + 1
    end
    local data = DataWing.data_upgrade[grade].need_item
    local titleText = panel:Find("PreviewInfo/Title/Text"):GetComponent(Text)
    local costText = panel:Find("MaterialInfo/Cost/Value"):GetComponent(Text)
    local needTransfrom = panel:Find("MaterialInfo/Needs")
    local needRect = needTransfrom:GetComponent(RectTransform)
    local itemTemplate = needTransfrom:Find("Item").gameObject
    local w = 100

    local result = 0
    self.propertyRect.gameObject:SetActive(true)
    self.propertyRect.anchoredPosition = Vector2(21.6, -154.04)

    local wingIconImage = panel:Find("TargetInfo/WingIcon/Icon"):GetComponent(Image)

    panel:Find("PreviewInfo/Title/QualifyImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon5")
    panel:Find("TargetInfo/Name"):GetComponent(Text).text = self.numberToChinese[grade].. TI18N("阶翅膀")
    if self.wingIconLoader == nil then
        self.wingIconLoader = SingleIconLoader.New(wingIconImage.gameObject)
    end
    self.wingIconLoader:SetSprite(SingleIconType.Item, 21104 + grade)

    if model.grade == 5 then
        panel:Find("MaterialInfo/Upgrade").gameObject:SetActive(false)
        panel:Find("MaterialInfo/Cost").gameObject:SetActive(false)
        panel:Find("MaterialInfo/Needs").gameObject:SetActive(false)
        panel:Find("MaterialInfo/Panel").gameObject:SetActive(true)
        return
    else
        panel:Find("MaterialInfo/Upgrade").gameObject:SetActive(true)
        panel:Find("MaterialInfo/Cost").gameObject:SetActive(true)
        panel:Find("MaterialInfo/Needs").gameObject:SetActive(true)
        panel:Find("MaterialInfo/Panel").gameObject:SetActive(false)
    end

    itemTemplate:SetActive(false)
    costText.transform.parent.gameObject:SetActive(false)

    local c = 0
    for i=1,#data do
        local t = needTransfrom:Find(tostring(i))
        local item = nil
        if t == nil then
            item = GameObject.Instantiate(itemTemplate)
            item.name = tostring(i)
            UIUtils.AddUIChild(needTransfrom, item)
        else
            item = t.gameObject
        end
        c = c + 1
        self:SetData(item, data[i][1], data[i][2])
    end

    -- MarketManager.Instance:send12416({["base_ids"] = {{base_id = 21104}, {base_id = 21102}, {base_id = 21103}}}, function() print("+++++++++++++++++++++++++++++++++++++++") end)
    self:OnLevelChangeListener()
    self.upgradeButton:Layout(self.baseidToNum,
        function ()
            WingsManager.Instance:Send11603({})
            -- self.wingEffects[2] = self:ShowEffect(20060, self.preview.transform, Vector3(1, 1, 1), Vector3(0, 0, -100), 10000)
        end,
        function (baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end)

    local h = needRect.sizeDelta.y
    if c > 4 then
        w = 90
    else
        w = 110
    end
    needRect.sizeDelta = Vector2(w * c, h)
end

-- 翅膀重置面板
function BackpackWingPanel:UpdateResetPanel()
    self.baseidToNum = {}
    local panel = self.panelList[3].transform
    local model = self.model
    local data = DataWing.data_reset[model.grade].need_item
    local needTransfrom = panel:Find("MaterialPanel/Needs")
    local itemTemplate = needTransfrom:Find("Item")
    local needRect = needTransfrom:GetComponent(RectTransform)
    local w = 100
    local qualityIcon = panel:Find("PreviewInfo/Title/QualifyImage"):GetComponent(Image)
    local titleRect = panel:Find("PreviewInfo/Title"):GetComponent(RectTransform)
    local saveBtn = panel:Find("Save"):GetComponent(Button)
    local titleObj = panel:Find("PreviewInfo/Title").gameObject
    local propertyPanel = panel:Find("PreviewInfo/PropertyPanel").gameObject
    local beforeImage = panel:Find("PreviewInfo/PropertyPanel/Before/Image"):GetComponent(Image)
    local afterImage = panel:Find("PreviewInfo/PropertyPanel/After/Image"):GetComponent(Image)
    local propertyList = {}
    for i=1,4 do
        local obj = panel:Find("PreviewInfo/PropertyPanel/Panel/Original/Property"..i)
        propertyList[i] = {}
        propertyList[i].obj = obj.gameObject
        propertyList[i].text = obj:Find("Text"):GetComponent(Text)
        propertyList[i].value = obj:Find("Value"):GetComponent(Text)
    end
    local newPropertyList = {}
    for i=1,4 do
        local obj = panel:Find("PreviewInfo/PropertyPanel/Panel/Now/NewProperty"..i)
        newPropertyList[i] = {}
        newPropertyList[i].obj = obj.gameObject
        newPropertyList[i].text = obj:Find("Text"):GetComponent(Text)
        newPropertyList[i].value = obj:Find("Value"):GetComponent(Text)
    end
    saveBtn.onClick:RemoveAllListeners()
    saveBtn.onClick:AddListener(function() self:SaveResetWings() end)

    itemTemplate.gameObject:SetActive(false)
    for i=1,#data do
        local t = needTransfrom:Find(tostring(i))
        local item = nil
        if t ~= nil then
            item = t.gameObject
        else
            item = GameObject.Instantiate(itemTemplate.gameObject)
            item.name = tostring(i)
            UIUtils.AddUIChild(needTransfrom, item)
        end
        self:SetData(item, data[i][1], data[i][2])
    end

    self.resetButton:Layout(self.baseidToNum,
        function ()
            -- WingsManager.Instance:Send11602({})
            -- self.wingEffects[3] = self:ShowEffect(20057, self.preview.transform, Vector3(1, 1, 1), Vector3(0, 0, -100), 10000)

            WingsManager.Instance:Send11604({})
        end,
        function (baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end)

    local h = needRect.sizeDelta.y
    if #data > 4 then
        w = 90
    else
        w = 110
    end
    needRect.sizeDelta = Vector2(w * #data, h)

    local classes = RoleManager.Instance.RoleData.classes
    local grade = nil
    local growth = nil
    if DataWing.data_base[model.temp_reset_id] == nil then
        qualityIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..model.growth)
        self.propertyRect.anchoredPosition = Vector2(21.6, -154.04)
        grade = model.grade
        growth = model.growth
        titleObj:SetActive(true)
        propertyPanel:SetActive(false)
        self.propertyObj:SetActive(true)

        -- print("==========================111111111111")
        self.levText.text = string.format(TI18N("【%s阶】"), self.numberToChinese[model.grade])

        self:UpdateProperty(grade, growth)
    else
        qualityIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..model.tmp_growth)
        grade = model.tmp_grade
        growth = model.tmp_growth
        titleObj:SetActive(false)
        propertyPanel:SetActive(true)
        self.propertyObj:SetActive(false)
        beforeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..tostring(model.growth))
        afterImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..tostring(growth))
        print(model.temp_reset_id)
        print(model.wing_id)
        if model.temp_reset_id ~= model.wing_id then
            self.levText.text = TI18N("<color='#ffff00'>【新形象】</color>")
        else
            self.levText.text = string.format(TI18N("【%s阶】"), self.numberToChinese[model.grade])
        end

        local newAttrlist = DataWing.data_attribute[classes.."_"..grade.."_"..growth].attr
        local attrlist = DataWing.data_attribute[classes.."_"..model.grade.."_"..model.growth].attr
        for i=1,4 do
            propertyList[i].obj:SetActive(false)
            newPropertyList[i].obj:SetActive(false)
            if attrlist[i] ~= nil then
                propertyList[i].text.text = KvData.GetAttrName(attrlist[i].attr_name)..":"
                propertyList[i].value.text = tostring(attrlist[i].val)
                propertyList[i].obj:SetActive(true)
            else
                propertyList[i].obj:SetActive(false)
            end
            if newAttrlist[i] ~= nil then
                newPropertyList[i].text.text = KvData.GetAttrName(newAttrlist[i].attr_name)..":"
                newPropertyList[i].value.text = tostring(newAttrlist[i].val)
                newPropertyList[i].obj:SetActive(true)
            else
                newPropertyList[i].obj:SetActive(false)
            end
        end

        panel:Find("PreviewInfo/PropertyPanel/Panel/Now"):GetComponent(RectTransform).sizeDelta = Vector2(129.5, #newAttrlist * 25)
        panel:Find("PreviewInfo/PropertyPanel/Panel/Original"):GetComponent(RectTransform).sizeDelta = Vector2(129.5, #attrlist * 25)
    end

    saveBtn.gameObject:SetActive(DataWing.data_base[model.temp_reset_id] ~= nil)
end

-- 翅膀合成面板
function BackpackWingPanel:UpdateSynthesizePanel()
    self.baseidToNum = {}
    local panel = self.panelList[4].transform
    local data = DataWing.data_merge[1].need_item
    local costText = panel:Find("MaterialInfo/Cost/Value"):GetComponent(Text)
    local needTransfrom = panel:Find("MaterialInfo/Needs")
    local needRect = needTransfrom:GetComponent(RectTransform)
    local itemTemplate = needTransfrom:Find("Item").gameObject
    local w = 100

    panel:Find("PreviewInfo/Title/QualifyImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon5")

    local go = panel:Find("TargetInfo/WingIcon/Icon").gameObject
    local id = go:GetInstanceID()
    local imgLoader = self.loaders[id]
    if imgLoader == nil then
        imgLoader = SingleIconLoader.New(go)
        self.loaders[id] = imgLoader
    end
    imgLoader:SetSprite(SingleIconType.Item, 21105)

    itemTemplate:SetActive(false)

    costText.transform.parent.gameObject:SetActive(false)
    for i=1,#data do
        local t = needTransfrom:Find(tostring(i))
        local item = nil
        if t == nil then
            item = GameObject.Instantiate(itemTemplate)
            item.name = tostring(i)
            UIUtils.AddUIChild(needTransfrom, item)
        else
            item = t.gameObject
        end
        self:SetData(item, data[i][1], data[i][2])
    end


    self.synthesizeButton:Layout(self.baseidToNum,
        function ()
            WingsManager.Instance:Send11601({})
            -- self.wingEffects[1] = self:ShowEffect(20060, self.preview.transform, Vector3(1, 1, 1), Vector3(0, 0, -100), 10000)
        end,
        function (baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end)

    local h = needRect.sizeDelta.y
    if #data > 4 then
        w = 90
    else
        w = 110
    end

    needRect.sizeDelta = Vector2(w * #data, h)
    self.propertyRect.anchoredPosition = Vector2(21.6, -154.04)
end

function BackpackWingPanel:SetData(obj, base_id, num)
    local t = obj.transform
    local nameText = t:Find("Name"):GetComponent(Text)
    local iconObj = t:Find("Icon").gameObject
    local iconImage = t:Find("Icon/Image"):GetComponent(Image)
    local numText = iconObj.transform:Find("Num"):GetComponent(Text)
    local assetText = t:Find("Num"):GetComponent(Text)
    local currencyImage = t:Find("Num/Currency"):GetComponent(Text)
    local centerText = t:Find("CenterNum")
    if centerText ~= nil then
        centerText = centerText:GetComponent(Text)
        centerText.text = ""
    end

    assetText.text = "0"

    local basedata = DataItem.data_get[base_id]
    nameText.text = ColorHelper.color_item_name(basedata.quality, basedata.name)

    if base_id < 90000 then
        numText.gameObject:SetActive(true)
        assetText.gameObject:SetActive(true)
        local numInBackpack = BackpackManager.Instance:GetItemCount(base_id)
        if numInBackpack < num then
            numText.text = "<color=#FF0000>".. numInBackpack.."</color>/"..num
            self.baseidToNum[base_id] = {need = num}
        else
            numText.text = numInBackpack.."/"..num
            assetText.gameObject:SetActive(false)
        end
    else
        numText.gameObject:SetActive(true)
        assetText.gameObject:SetActive(false)
        local assetNum = 0
        local roledata = RoleManager.Instance.RoleData
        if base_id == KvData.assets.coin then
            assetNum = roledata.coin
        elseif base_id == KvData.assets.gold then
            assetNum = roledata.gold
        elseif base_id == KvData.assets.gold_bind then
            assetNum = roledata.gold_bind
        elseif base_id == KvData.assets.bind then
            assetNum = roledata.bind
        elseif base_id == KvData.assets.intelligs then
            assetNum = roledata.intelligs
        elseif base_id == KvData.assets.pet_exp then
            assetNum = roledata.pet_exp
        elseif base_id == KvData.assets.energy then
            assetNum = roledata.energy
        elseif base_id == KvData.assets.exp then
            assetNum = roledata.exp
        elseif base_id == KvData.assets.guild then
            assetNum = roledata.guild
        end

        if assetNum < num then
            numText.text = "<color=#FF0000>"..num.."</color>"
            -- self.baseidToNum[base_id] = num - assetNum
        else
            numText.text = tostring(num)
        end
    end

    if self.iconLoader == nil then
        self.iconLoader = SingleIconLoader.New(iconImage.gameObject)
    end
    self.iconLoader:SetSprite(SingleIconType.Item, basedata.icon)

    local info = ItemData.New()
    info:SetBase(basedata)
    local btn = obj:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function ()
        TipsManager.Instance:ShowItem({["gameObject"] = iconObj, ["itemData"] = info})
    end)

    obj.gameObject:SetActive(true)
    self.idToObj[base_id] = obj

end

function BackpackWingPanel:UpdateWingShow(wing_id)
    local model = self.model
    self.titleObj:SetActive(true)
    if model.lastIndex == 1 and model.growth > 0 then
        self.colorImage.gameObject:SetActive(true)
        self.colorImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..model.growth)
    else
        self.colorImage.gameObject:SetActive(false)
    end

    local data = DataWing.data_base[wing_id]
    self.levText.text = string.format(TI18N("【%s阶】"), self.numberToChinese[data.grade])
    self.nameText.text = data.name


    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "wing"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 300
        ,offsetY = -0.1
        , noDrag = true
    }
    local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = wing_id}}}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData, "ModelPreview")
    else
        self.previewComp:Reload(modelData, callback)
    end
end

function BackpackWingPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

function BackpackWingPanel:ShowWingsList(wingIdList)
    local length = #wingIdList
    local model = self.model
    self.preEnable:SetActive(false)
    self.preDisable:SetActive(true)
    if length > 1 then
        self.nextEnable:SetActive(true)
        self.nextDisable:SetActive(false)
    else
        self.nextEnable:SetActive(false)
        self.nextDisable:SetActive(true)
    end
    model.currentWingList = wingIdList
    model.currentWingIndex = 1
    self:UpdateWingShow(wingIdList[1])
end

function BackpackWingPanel:UpdateNextPreButtonState()
    local model = self.model
    local length = #model.currentWingList
    local index = model.currentWingIndex

    if length > 1 then
        self.nextEnable:SetActive(true)
        self.nextDisable:SetActive(true)
        self.preEnable:SetActive(true)
        self.preDisable:SetActive(true)
        if index > 1 then
            self.preDisable:SetActive(false)
        else
            self.preEnable:SetActive(false)
        end
        if index < length then
            self.nextDisable:SetActive(false)
        else
            self.nextEnable:SetActive(false)
        end
    else
        self.nextEnable:SetActive(false)
        self.nextDisable:SetActive(true)
        self.preEnable:SetActive(false)
        self.preDisable:SetActive(true)
    end
end

function BackpackWingPanel:ShowWingTips(gameObject)
    local model = self.model
    local parent = gameObject.transform.parent
    gameObject.transform:SetParent(self.parent.transform)
    local rect = gameObject:GetComponent(RectTransform)
    local pos = rect.anchoredPosition
    local size = rect.sizeDelta
    gameObject.transform:SetParent(parent)

    if self.wingTips == nil then
        self.wingTips = GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_tips))
        local t = self.wingTips.transform
        UIUtils.AddUIChild(self.parent.transform.gameObject, t.gameObject)
        self.wingTipsValText = t:Find("Main/Val"):GetComponent(Text)
        t:Find("Panel"):GetComponent(Button).onClick:AddListener(function ()
            self.wingTips:SetActive(false)
        end)
        local iconContainer = t:Find("Main/Icons")
        for i=1,iconContainer.childCount do
            if self.wingEffects[10 + i] ~= nil then
                self.wingEffects[10 + i]:DeleteMe();
            end
            self.wingEffects[10 + i] = self:ShowEffect(20058, iconContainer:GetChild(i - 1), Vector3(0.71, 0.75, 1), Vector3(-1.61,1.86,-100))
        end
    else
        self.wingTips:SetActive(true)
    end

    local main = self.wingTips.transform:Find("Main").gameObject:GetComponent(RectTransform)
    main.anchorMax = rect.anchorMax
    main.anchorMin = rect.anchorMin
    local wingtipsSize = main.sizeDelta
    main.anchoredPosition = Vector2(pos.x - size.x / 2 - wingtipsSize.x / 2, pos.y + size.y / 2 - wingtipsSize.y / 2)
                                                                                            -- 前面还有个白色，所以要 +1
    self.wingTipsValText.text = string.format(TI18N("当前品质为：%s色"), ColorHelper.color_item_name(model.growth, KvData.quality_name[model.growth + 1]))
end

function BackpackWingPanel:ShowEffect(id, transform, scale, position, time)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

function BackpackWingPanel:PlayMergeSucc()
    if self.wingEffects[3] ~= nil then
        self.wingEffects[3]:DeleteMe()
    end
    self.wingEffects[3] = self:ShowEffect(20057, self.preview.transform, Vector3(1, 1, 1), Vector3(0, 0, -100), 10000)
end

function BackpackWingPanel:PlayResetSucc()
    if self.wingEffects[2] ~= nil then
        self.wingEffects[2]:DeleteMe()
    end
    self.wingEffects[2] = self:ShowEffect(20060, self.preview.transform, Vector3(1, 1, 1), Vector3(0, 0, -100), 10000)
end

function BackpackWingPanel:PlayUpgradeSucc()
    if self.wingEffects[1] ~= nil then
        self.wingEffects[1]:DeleteMe()
    end
    self.wingEffects[1] = self:ShowEffect(20060, self.preview.transform, Vector3(1, 1, 1), Vector3(0, 0, -100), 10000)
end

function BackpackWingPanel:OnLevelChangeListener()
    local lev = RoleManager.Instance.RoleData.lev
    local model = self.model
    if model.wing_id == nil or DataWing.data_base[model.wing_id] == nil then
        return
    end
    local grade = DataWing.data_base[model.wing_id].grade
    local act_lev = DataWing.data_upgrade[grade + 1].lev
    if self.upgradeButton ~= nil then
        if lev < act_lev then
            self.upgradeButton.content = act_lev..TI18N("级可进阶")
        else
            self.upgradeButton.content = TI18N("进 阶")
        end
        if self.upgradeButton.isInited == true then
            self.upgradeButton:Update()
        end
    end
end

function BackpackWingPanel:OnOpen()
    self:ReloadPanel()

    self:RemoveListeners()
    WingsManager.Instance.onUpdateReset:AddListener(self.reloadListener)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.roleAssetsChangeListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeListener)
end

function BackpackWingPanel:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function BackpackWingPanel:OnRoleAssetsChangeListener()
    self:ReloadPanel()
end

function BackpackWingPanel:RemoveListeners()
    WingsManager.Instance.onUpdateReset:RemoveListener(self.reloadListener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.roleAssetsChangeListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeListener)
end

function BackpackWingPanel:SaveResetWings()
    WingsManager.Instance:Send11605({})
end

