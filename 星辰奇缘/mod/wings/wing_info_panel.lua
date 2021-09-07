WingInfoPanel = WingInfoPanel or BaseClass(BasePanel)

function WingInfoPanel:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.assetWrapper = assetWrapper

    self.propertyList = {}
    self.itemList = {}
    self.isInited = false
    self.isAutoBuy = false

    self.unfreeListener = function() self:Unfreeze() end
    self.updateListener = function() self:ReloadPanel() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingInfoPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.upgradeBtn ~= nil then
        self.upgradeBtn:DeleteMe()
        self.upgradeBtn = nil
    end
    if self.upgradeSkillImage ~= nil then
        self.upgradeSkillImage.sprite = nil
    end
    self.gameObject = nil
    self.assetWrapper = nil
    self.model = nil
    self.transform = nil
end

function WingInfoPanel:InitPanel()
    local t = self.transform

    local property = t:Find("Property/Container")
    t:Find("Property/Title/Text"):GetComponent(Text).text = TI18N("升级属性预览")
    for i=1,4 do
        local tab = {}
        tab.transform = property:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.nameText = tab.transform:Find("AttrName"):GetComponent(Text)
        tab.nowText = tab.transform:Find("Now"):GetComponent(Text)
        tab.newText = tab.transform:Find("New"):GetComponent(Text)
        tab.arrowObj = tab.transform:Find("Arrow").gameObject
        self.propertyList[i] = tab
    end
    self.propertyContainer = property

    local needs = t:Find("Material/Needs")
    t:Find("Material/Title/Text"):GetComponent(Text).text = TI18N("升级消耗材料")

    local nothing = GameObject.Instantiate(t:Find("Material/Title/Text").gameObject)
    nothing.transform:SetParent(t:Find("Material"))
    nothing.transform.localScale = Vector3(1, 1, 1)
    nothing.transform.anchorMax = Vector2(0.5, 0.5)
    nothing.transform.anchorMin = Vector2(0.5, 0.5)
    nothing.transform.pivot = Vector2(0.5, 0.5)
    nothing.transform.anchoredPosition = Vector2(0, -22)
    self.nothingText = nothing:GetComponent(Text)
    self.nothingText.text = TI18N("已达到最高级")

    for i=1,4 do
        self.itemList[i] = WingMergeNeedItem.New(self.model, needs:GetChild(i - 1).gameObject)
    end
    self.needContainer = needs

    self.upgradeRed = t:Find("Upgrade/Red").gameObject

    self.upgradeButton = t:Find("Upgrade"):GetComponent(Button)
    self.upgradeButtonText = t:Find("Upgrade/Text"):GetComponent(Text)
    self.upgradeBtn = BuyButton.New(t:Find("AutoBuy"))
    self.upgradeBtn.key = "WingUpgrade"
    self.upgradeBtn.protoId = 11603
    self.upgradeBtn:Set_btn_img("DefaultButton3")
    self.upgradeBtn:Show()
    self.upgradeBtn.OnOpenEvent:AddListener(function()
        self.upgradeRed.transform:SetParent(self.upgradeBtn.transform)
        self.upgradeRed.transform.localScale = Vector3(1, 1, 1)
    end)
    if self:CheckWingGuide() then
        self.upgradeBtn.guideClickListener = self.onUpgradeHandler
    end

    self.toggle = t:Find("Property/SpeedToggle"):GetComponent(Button)
    self.toggleTick = t:Find("Property/SpeedToggle/Tick").gameObject

    -- self.autoBuyTick = t:Find("AutoBuy/Tick").gameObject

    self.isInited = true

    self.toggle.onClick:AddListener(function() self:OnSpeed() end)
    -- self.autoBuyButton.onClick:AddListener(function() self:OnAutoBuy() end)

    -- self.autoBuyButton.gameObject:SetActive(false)
    self.upgradeButton.onClick:AddListener(function() self.upgradeBtn:OnClick() end)
    self.upgradeBtn.clickListener = function() self:OnUpgrade() end


    WingsManager.Instance:AutoLottory()
end

function WingInfoPanel:onUpgradeHandler()
     BackpackManager.Instance.mainModel:ShowWingGuide()
end

function WingInfoPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingInfoPanel:OnOpen()
    if self.isInited ~= true then
        self:InitPanel()
    end
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.unfreeListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.updateListener)

    self:ReloadPanel()
end

function WingInfoPanel:ReloadPanel()
    self:ReloadAttr(WingsManager.Instance.grade, WingsManager.Instance.star)
    self.upgradeRed:SetActive(WingsManager.Instance:Upgradable())

    self.toggleTick:SetActive(WingsManager.Instance.is_no_speed == true)
    self:ShowLottryEffect(WingsManager.Instance:CanLottory())
end

function WingInfoPanel:ReloadAttr(grade, star)
    local next_grade = nil
    local next_star = nil

    next_grade,next_star = WingsManager.Instance:GetNext(grade or 0, star)

    -- print(string.format("%s_%s_%s", RoleManager.Instance.RoleData.classes, next_grade, next_star))
    -- print(string.format("%s_%s_%s", RoleManager.Instance.RoleData.classes, grade, star))
    local attr = DataWing.data_attribute[string.format("%s_%s_%s", RoleManager.Instance.RoleData.classes, grade, star)]

    if next_grade ~= nil then
        local next_attr = DataWing.data_attribute[string.format("%s_%s_%s", RoleManager.Instance.RoleData.classes, next_grade, next_star)]

        local propertyTab = {}
        for _,v in ipairs(next_attr.attr) do
            propertyTab[v.attr_name] = {next = v.val}
        end
        for _,v in ipairs((attr or {}).attr or {}) do
            propertyTab[v.attr_name] = propertyTab[v.attr_name] or {next = 0}
            propertyTab[v.attr_name].curr = v.val
        end

        for i,property in ipairs(self.propertyList) do
            if next_attr.attr[i] ~= nil then
                property.nameText.text = KvData.GetAttrName(next_attr.attr[i].attr_name)
                if next_attr.attr[i].attr_name == 3 and WingsManager.Instance.is_no_speed == true then
                    property.nowText.text = 0
                    property.newText.text = 0
                else
                    property.nowText.text = KvData.GetAttrVal(next_attr.attr[i].attr_name, propertyTab[next_attr.attr[i].attr_name].curr or 0)
                    property.newText.text = KvData.GetAttrVal(next_attr.attr[i].attr_name, propertyTab[next_attr.attr[i].attr_name].next)
                end
                property.arrowObj:SetActive(true)
                property.gameObject:SetActive(true)
            else
                property.gameObject:SetActive(false)
            end
            property.transform.anchoredPosition = Vector2(0, property.transform.anchoredPosition.y)
        end

        local needs = {}
        if DataWing.data_upgrade[string.format("%s_%s", grade, star)] ~= nil then
            for _,v in ipairs(DataWing.data_upgrade[string.format("%s_%s", grade, star)].need_item) do
                needs[v[1]] = {need = v[2]}
            end

            local currentUpgrade = DataWing.data_upgrade[string.format("%s_%s", grade, star)]

            if WingsManager.Instance:CanLottory() then
                self.upgradeBtn:Set_btn_txt(TI18N("外观奖励"))
                self.upgradeButtonText.text = TI18N("外观奖励")
            elseif currentUpgrade.lev_break > 0 then
                if RoleManager.Instance.RoleData.lev_break_times < currentUpgrade.lev_break or RoleManager.Instance.RoleData.lev < currentUpgrade.lev then
                    self.upgradeBtn:Set_btn_txt(string.format(TI18N("突破%s级"), currentUpgrade.lev))
                    self.upgradeButtonText.text = string.format(TI18N("突破%s级"), currentUpgrade.lev)
                else
                    self.upgradeBtn:Set_btn_txt(TI18N("升级翅膀"))
                    self.upgradeButtonText.text = TI18N("升级翅膀")
                end
            elseif RoleManager.Instance.RoleData.lev < currentUpgrade.lev then
                self.upgradeBtn:Set_btn_txt(string.format(TI18N("%s级可升级"), currentUpgrade.lev))
                self.upgradeButtonText.text = string.format(TI18N("%s级可升级"), currentUpgrade.lev)
            else
                self.upgradeBtn:Set_btn_txt(TI18N("升级翅膀"))
                self.upgradeButtonText.text = TI18N("升级翅膀")
            end

            self:ReloadMaterials(needs)

            self.upgradeBtn:Layout(needs,
                function()
                    if RoleManager.Instance.RoleData.lev_break_times > currentUpgrade.lev_break
                        or RoleManager.Instance.RoleData.lev_break_times == currentUpgrade.lev_break and RoleManager.Instance.RoleData.lev >= currentUpgrade.lev
                        then
                        WingsManager.Instance:Send11603()
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("等级不足"))
                    end

                    -- self.model:ShowIllusion()
                end
            , function(baseidToAllprice) self:ReloadMaterials(needs, baseidToAllprice) end)

        else
            Log.Error(string.format("拿不到翅膀升级所需物品，grade = %s, star = %s", grade, star))
        end

        self.nothingText.gameObject:SetActive(false)
    else
        local propertyTab = {}
        for _,v in ipairs(attr.attr) do
            propertyTab[v.attr_name] = {curr = v.val}
        end
        for i,property in ipairs(self.propertyList) do
            if attr.attr[i] ~= nil then
                property.nameText.text = KvData.GetAttrName(attr.attr[i].attr_name)
                property.nowText.text = KvData.GetAttrVal(attr.attr[i].attr_name, propertyTab[attr.attr[i].attr_name].curr or 0)
                property.arrowObj:SetActive(false)
                property.newText.text = ""
                property.gameObject:SetActive(true)
            else
                property.gameObject:SetActive(false)
            end
            property.transform.anchoredPosition = Vector2(48, property.transform.anchoredPosition.y)
        end
        self.nothingText.gameObject:SetActive(true)
        self:ReloadMaterials({})
        self.upgradeBtn:Layout({}, function() NoticeManager.Instance:FloatTipsByString(TI18N("已达到最高级")) end, function(baseidToAllprice)  end)
    end
    self.upgradeRed.transform:SetAsLastSibling()
end

function WingInfoPanel:ReloadMaterials(needs, baseidToAllprice)
    local i = 0
    baseidToAllprice = baseidToAllprice or {}
    for base_id,v in pairs(needs) do
        if v ~= nil then
            i = i + 1
            self.itemList[i]:SetData({base_id, v.need}, baseidToAllprice[base_id])
        end
    end
    for j=i + 1,#self.itemList do
        self.itemList[j].gameObject:SetActive(false)
    end

    self.needContainer.sizeDelta = Vector2(60 * i + 10 * (i + 1), 120)
end

function WingInfoPanel:OnHide()
    self:RemoveListeners()
end

function WingInfoPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.unfreeListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
end

function WingInfoPanel:InitUI()
    local model = self.model
    local classes = RoleManager.Instance.RoleData.classes
    local msg = classes.."_"..model.grade.."_"..model.growth.."_"..model.star
    local data = DataWing.data_attribute[msg]
    local attrlist = data.attr

    for i,v in ipairs(self.propertyList) do
        local attr = attrlist[i]
        if attr == nil then
            v.obj:SetActive(false)
        else
            v.obj:SetActive(true)
            v.value.text = tostring(attr.val)
            v.text.text = KvData.GetAttrName(attr.attr_name)..":"
        end
    end

    self.mgr.onUpdateWing:Fire(model.wing_id)
    self.mgr.onUpdateProperty:Fire()

    self.optionSkillBtn.gameObject:SetActive(false)
    self.upgradeSkillBtn.gameObject:SetActive(false)
    if model.grade >= 5 then
        self:update_cur_option(WingsManager.Instance.valid_plan)

        self.transform:Find("Skill/UpgradeSkill"):GetComponent(RectTransform).anchoredPosition = Vector2(-90, -142)
        self.transform:Find("Skill/OptionSkill"):GetComponent(RectTransform).anchoredPosition = Vector2(90, -142)
        self.optionSkillBtn.gameObject:SetActive(true)
        self.upgradeSkillBtn.gameObject:SetActive(true)
    else
        self.transform:Find("Skill/UpgradeSkill"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -142)
        self.upgradeSkillBtn.gameObject:SetActive(true)
        for i=1,4 do
            local tab = model.skill_data[i]
            if tab == nil then
                tab = {}
            end
            self.skillItemList[i].assetWrapper = self.assetWrapper
            self.skillItemList[i]:update_my_self(tab, i)
        end

        if #model.skill_data < DataWing.data_base[model.wing_id].skill_count then
            self.upgradeSkillText.text = self.upgradeText[1]
            self.upgradeSkillImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        else
            if model.grade < 4 then
                self.upgradeSkillText.text = self.upgradeText[3]
            else
                self.upgradeSkillText.text = self.upgradeText[2]
            end
            self.upgradeSkillImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        end
    end
end

function WingInfoPanel:ShowWingTips(gameObject)
    local model = self.model
    local parent = gameObject.transform.parent
    local mainParent = self.model.mainModel.mainWindow.gameObject
    gameObject.transform:SetParent(mainParent.transform)
    local rect = gameObject:GetComponent(RectTransform)
    local pos = rect.anchoredPosition
    local size = rect.sizeDelta
    gameObject.transform:SetParent(parent)

    if self.wingTips == nil then
        self.wingTips = GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_tips))
        local t = self.wingTips.transform
        UIUtils.AddUIChild(mainParent.transform.gameObject, t.gameObject)
        self.wingTipsValText = t:Find("Main/Val"):GetComponent(Text)
        t:Find("Panel"):GetComponent(Button).onClick:AddListener(function ()
            self.wingTips:SetActive(false)
        end)
        local iconContainer = t:Find("Main/Icons")
        for i=1,iconContainer.childCount do
            if self.wingEffects[10 + i] ~= nil then
                self.wingEffects[10 + i]:DeleteMe();
            end
            self.wingEffects[10 + i] = BibleRewardPanel.ShowEffect(20058, iconContainer:GetChild(i - 1), Vector3(0.71, 0.75, 1), Vector3(-1.61,1.86,-100))
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

function WingInfoPanel:OnCheckRed()
    local skill_data = nil
    for i=1,#WingsManager.Instance.plan_data do
        if WingsManager.Instance.plan_data[i].index == self.model.cur_selected_option then
            skill_data = WingsManager.Instance.plan_data[i].skills
            break
        end
    end

    if WingsManager.Instance.grade > 3 and WingsManager.Instance.valid_plan == self.model.cur_selected_option and (skill_data == nil or #skill_data == 0) then
        self.upgradeSkillRedObj:SetActive(true)
    else
        self.upgradeSkillRedObj:SetActive(false)
    end

    -- self.upgradeSkillRedObj:SetActive(self.mgr.redPointDic[1] == true)
end

function WingInfoPanel:ShowSkillPreviewWindow()
    WingsManager.Instance:OpenSkillPreview()
end

function WingInfoPanel:Freeze()
    if self.upgradeBtn ~= nil then
        self.upgradeBtn:Freeze()
    end
end

function WingInfoPanel:Unfreeze()
    if self.upgradeBtn ~= nil then
        self.upgradeBtn:ReleaseFrozon()
    end
end

function WingInfoPanel:CheckWingGuide()
    local quest = QuestManager.Instance:GetQuest(22222)
    if quest ~= nil and quest.finish ~= QuestEumn.TaskStatus.Finish then
        return true
    end
    return false
end

-- 攻速选择
function WingInfoPanel:OnSpeed()
    if WingsManager.Instance.is_no_speed then
        WingsManager.Instance:Send11614(1)
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("该操作将会屏蔽翅膀加成的攻速，该操作适用于<color='#ffff00'>龟速流派</color>，是否继续（再次勾选可恢复）？")
        confirmData.sureCallback = function() WingsManager.Instance:Send11614(0) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function WingInfoPanel:OnAutoBuy()
    self.isAutoBuy = not self.isAutoBuy
    self:SetAutoBuy()
end

function WingInfoPanel:SetAutoBuy()
    self.autoBuyTick:SetActive(self.isAutoBuy)
end

function WingInfoPanel:OnUpgrade()
    for _,group in pairs(WingsManager.Instance.wing_groups) do
        if group.wing_times > 0 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wings_turnplant, {group_id = group.group_id, rotate = true})
            WingsManager.Instance:Send11615(group.group_id, 1)
            return
        end
    end

    self.upgradeBtn:OnClickTrue()
end

function WingInfoPanel:ShowLottryEffect(bool)
    if bool then
        if self.lottoryEffect ~= nil then
            self.lottoryEffect:SetActive(true)
        else
            self.lottoryEffect = BaseUtils.ShowEffect(20053, self.upgradeButton.transform, Vector3(1.9, 0.7, 1), Vector3(-60, -15, -200))
        end
    else
        if self.lottoryEffect ~= nil then
            self.lottoryEffect:SetActive(false)
        end
    end
end
