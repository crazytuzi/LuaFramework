WingUpgradePanel = WingUpgradePanel or BaseClass(BasePanel)

function WingUpgradePanel:__init(model, gameObject, parent)
    self.model = model
    self.parent = parent
    self.name = "WingUpgradePanel"
    self.gameObject = gameObject
    self.mgr = WingsManager.Instance
    self.currencyWingIndex = 1

    self.gradeNameString = TI18N("%s阶翅膀")
    self.levUpgradableString = TI18N("%s级可进阶")
    self.upgradeString = TI18N("进 阶")
    self.upgradeStarString = TI18N("升 星")
    self.levUpgradableStarString = TI18N("%s级可升星")
    self.upgradeMaterialString = TI18N("进阶材料")
    self.starExpainString = {
        TI18N("1.提升翅膀等阶可获得<color='#ffff00'>更高属性</color>、<color='#ffff00'>翅膀技能</color>、<color='#ffff00'>全新外观</color>"),
        TI18N("2.二阶及以上翅膀可<color='#ffff00'>提升星级</color>，全部点满时可进阶至下一阶"),
        TI18N("3.四阶及以上翅膀可<color='#ffff00'>学习技能</color>，技能个数与翅膀等阶有关"),
        TI18N("4.进阶翅膀后，已经获得的翅膀特技将<color='#ffff00'>继续保留</color>，不会被重置"),
    }

    self.upgradeDescString = {
        TI18N("1.翅膀分为5个等阶"),
        TI18N("2.提升翅膀等阶可获得<color='#ffff00'>更高属性</color>、<color='#ffff00'>开启技能</color>、<color='#ffff00'>更炫的翅膀</color>")
    }

    self.starDescString = {
        TI18N("1.翅膀分为5个等阶"),
        TI18N("2.提升翅膀等阶可获得更高属性、开启技能、更炫的翅膀"),
        TI18N("3.二阶及以上翅膀可提升星级，全部点满时自动进阶至下一阶"),
        TI18N("4.四阶及以上翅膀可学习技能，技能个数与翅膀等阶有关"),
    }

    self.explainString = TI18N("升星可获<color=#13fc60>更高属性</color>，点满后进阶激活<color=#13fc60>全新外观</color>")

    self.descString = {
        TI18N("<color=#00FF00>下阶</color>极品属性预览"),
        TI18N("<color=#00FF00>下一星</color>属性预览"),
        TI18N("本阶段极品属性预览")
    }

    self.resList = {

    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.levListener = function() self:OnLevelChangeListener() end
    self.starListener = function(index) self:ShowStarEffect(index) end

    self.propertyList = {}
    self.itemList = {}
    self.itemStarList = {}
    self.itemAwakenList = {}
    self.starList = {}
    self.wingsEffect = {}
    self.levelStarList = {}
    self.awakenStarList = {}

    self:InitPanel()
end

function WingUpgradePanel:__delete()
    self.OnHideEvent:Fire()
    if self.upgradeButton ~= nil then
        self.upgradeButton:DeleteMe()
        self.upgradeButton = nil
    end
    if self.upgradeStarButton ~= nil then
        self.upgradeStarButton:DeleteMe()
        self.upgradeStarButton = nil
    end
    if self.upgradeAwakenButton ~= nil then
        self.upgradeAwakenButton:DeleteMe()
        self.upgradeAwakenButton = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.itemStarList ~= nil then
        for _,v in pairs(self.itemStarList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemStarList = nil
    end
    if self.itemAwakenList ~= nil then
        for _,v in pairs(self.itemAwakenList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemAwakenList = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.itemData1 ~= nil then
        self.itemData1:DeleteMe()
        self.itemData1 = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.itemSlot1 ~= nil then
        self.itemSlot1:DeleteMe()
        self.itemSlot1 = nil
    end
    self.baseToItem = nil
    self:AssetClearAll()
end

function WingUpgradePanel:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    self.helpBtn = t:Find("Help"):GetComponent(Button)

    self.needContainer = t:Find("MaterialInfo/Needs")
    self.nothingObj = t:Find("MaterialInfo/Panel").gameObject
    self.needRect = self.needContainer:GetComponent(RectTransform)

    for i=1,4 do
        self.itemList[i] = WingMergeNeedItem.New(self.model, self.needContainer:GetChild(i - 1).gameObject)
    end

    self.upgradeArea = t:Find("MaterialInfo/Upgrade")

    t:Find("MaterialInfo/Title/Text"):GetComponent(Text).text = self.upgradeMaterialString

    self.propertyTrans = t:Find("Property/Container")
    for i=1,4 do
        local tab = {}
        local trans = self.propertyTrans:GetChild(i - 1)
        tab.text = trans:Find("AttrName"):GetComponent(Text)
        tab.nowValue = trans:Find("Now"):GetComponent(Text)
        tab.newValue = trans:Find("New"):GetComponent(Text)
        tab.obj = trans.gameObject
        self.propertyList[i] = tab
    end

    self.helpBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.helpBtn.gameObject, itemData = self.upgradeDescString}) end)
end

function WingUpgradePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingUpgradePanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levListener)
    self.mgr.onStarEffect:AddListener(self.starListener)

    if self.mgr.redPointDic[2] == true then self.mgr.redPointDic[2] = false end
    self.mgr.onUpdateRed:Fire()

    self.model:GetData()
    self:InitUI()
end

function WingUpgradePanel:OnHide()
    self:RemoveListeners()
    if self.wingsEffect ~= nil then
        for _,v in pairs(self.wingsEffect) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.wingsEffect = {}
    end
end

function WingUpgradePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levListener)
    self.mgr.onStarEffect:RemoveListener(self.starListener)
end

function WingUpgradePanel:InitUI()
    local model = self.model

    if model.grade == 6 and model.star == 4 then
        self:Awaken()
    elseif (model.grade == self.mgr.top_grade and DataWing.data_upgrade[model.grade.."_"..(model.star + 1)] == nil) or model.grade < 1 then
        self:Upgrade()
    else
    end
end

function WingUpgradePanel:callbackAfter12406(baseidToBuyInfo, type)
    local model = self.model
    local data = nil
    if type == 2 then
        for k,v in pairs(baseidToBuyInfo) do
            self.baseToStarItem[k]:SetData(self.baseToStarItem[k].data, v)
        end
    else
        for k,v in pairs(baseidToBuyInfo) do
            self.baseToItem[k]:SetData(self.baseToItem[k].data, v)
        end
    end
end

function WingUpgradePanel:Upgrade()
    local model = self.model
    local grade = self.mgr.top_grade
    local star = 0
    local w = 100
    local key = ""

    if model.grade < self.mgr.top_grade then
        grade = model.grade
    end

    self.targetNameText.text = string.format(self.gradeNameString, BaseUtils.NumToChn(grade))
    if self.itemData == nil then
        self.itemData = ItemData.New()
    end
    self.itemData:SetBase(DataItem.data_get[self.mgr.stageid[grade]])
    if self.itemSlot == nil then
        self.itemSlot = ItemSlot.New()
    end
    self.itemSlot:SetAll(self.itemData, {nobutton = true, inbag = false})
    NumberpadPanel.AddUIChild(self.targetContent.gameObject, self.itemSlot.gameObject)

    self.baseToNum = {}

    self.needCloner:SetActive(false)

    self.levelStarCloner:SetActive(false)
    local width = self.levelStarContainer:GetComponent(RectTransform).sizeDelta.x
    local perWidth = self.levelStarCloner:GetComponent(RectTransform).sizeDelta.y
    for i=1,model.star do
        local tab = nil
        if self.levelStarList[i] == nil then
            tab = {obj = nil, transform = nil, normal = nil, select = nil, rect = nil}
            tab.obj = GameObject.Instantiate(self.levelStarCloner)
            tab.obj.name = tostring(i)
            tab.transform = tab.obj.transform
            tab.normal = tab.transform:Find("Normal").gameObject
            tab.select = tab.transform:Find("Select").gameObject
            tab.transform:SetParent(self.levelStarContainer)
            tab.rect = tab.obj:GetComponent(RectTransform)
            tab.transform.localScale = Vector3.one
            self.levelStarList[i] = tab
        else
            tab = self.levelStarList[i]
        end
        tab.obj:SetActive(true)
        tab.rect.anchoredPosition = Vector2((width - perWidth * model.star) / 2 + (i - 0.5) * perWidth, 0)

        tab.normal:SetActive(false)
        tab.select:SetActive(true)
    end

    for i=model.star + 1, #self.levelStarList do
        self.levelStarList[i].obj:SetActive(false)
    end


    if grade < self.mgr.top_grade then
        self.needContainer.gameObject:SetActive(true)
        self.upgradeArea.gameObject:SetActive(true)
        self.nothingObj:SetActive(false)
        local data = nil
        if DataWing.data_upgrade[grade.."_"..star].is_upgrage == 1 then
            data = DataWing.data_upgrade[(grade + 1).."_0"].need_item
        else
            data = DataWing.data_upgrade[grade.."_"..(star + 1)].need_item
        end
        for i,v in ipairs(data) do
            if self.itemList[i] == nil then
                local obj = GameObject.Instantiate(self.needCloner)
                obj.name = tostring(i)
                obj.transform:SetParent(self.needContainer)
                obj.transform.localScale = Vector3.one
                self.itemList[i] = WingMergeNeedItem.New(self.model, obj)
            end
            self.itemList[i]:SetData(v)
            if v[1] >= 90000 then
            else
                self.baseToNum[v[1]] = {need = v[2]}
            end
        end

        self.baseToItem = {}
        for k,v in pairs(self.itemList) do
            self.baseToItem[v.base_id] = v
        end

        for i=#data + 1, #self.itemList do
            self.itemList[i]:SetActive(false)
        end

        self.upgradeButton:Layout(self.baseToNum, function ()
            WingsManager.Instance:Send11603({})
            SoundManager.Instance:Play(246)
        end, function(baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end)

        local h = self.needRect.sizeDelta.y
        if #data > 4 then
            w = 90
        else
            w = 110
        end

        self.needRect.sizeDelta = Vector2(w * #data, h)
    else
        self.needContainer.gameObject:SetActive(false)
        self.upgradeArea.gameObject:SetActive(false)
        self.nothingObj:SetActive(true)
    end

    if grade == self.mgr.top_grade then
        self.mgr.onUpdateWing:Fire(self.model.wingsIdByGrade[grade][self.currencyWingIndex])
        self.mgr.onUpdateProperty:Fire(grade, 5, model.star, Vector2(21.6, -154.04))
    else
        self.mgr.onUpdateWing:Fire(self.model.wingsIdByGrade[(grade + 1)][self.currencyWingIndex])
        self.mgr.onUpdateProperty:Fire((grade+1), 5, 0, Vector2(21.6, -154.04))
    end
    self:OnLevelChangeListener()
end

function WingUpgradePanel:OnLevelChangeListener()
    local lev = RoleManager.Instance.RoleData.lev
    local lev_break_times = RoleManager.Instance.RoleData.lev_break_times
    local model = self.model
    if model.wing_id == nil or DataWing.data_base[model.wing_id] == nil then
        return
    end
    local grade = DataWing.data_base[model.wing_id].grade
    local act_lev = nil
    local lev_break = 0

    local fillStar = false
    if grade < self.mgr.top_grade then
        if DataWing.data_upgrade[grade.."_"..(model.star + 1)] ~= nil then
            local d = DataWing.data_upgrade[grade.."_"..(model.star + 1)]
            act_lev = d.lev
            lev_break = d.lev_break
        else
            local d = DataWing.data_upgrade[(grade + 1).."_0"]
            act_lev = d.lev
            lev_break = d.lev_break
            fillStar = true
        end
    elseif DataWing.data_upgrade[grade.."_"..(model.star + 1)] ~= nil then
        local d = DataWing.data_upgrade[grade.."_"..(model.star + 1)]
        act_lev = d.lev
        lev_break = d.lev_break
    else
        local d = DataWing.data_upgrade[grade.."_"..model.star]
        act_lev = d.lev
        lev_break = d.lev_break
        fillStar = true
    end
    if self.upgradeButton ~= nil then
        if lev_break_times < lev_break then
            self.upgradeButton.content = string.format(self.levUpgradableString, tostring(act_lev))
        elseif lev_break_times == lev_break then
            if lev < act_lev then
                self.upgradeButton.content = string.format(self.levUpgradableString, tostring(act_lev))
            else
                self.upgradeButton.content = self.upgradeString
            end
        else
            self.upgradeButton.content = self.upgradeString
        end

        -- if lev < act_lev then
        --     self.upgradeButton.content = string.format(self.levUpgradableString, tostring(act_lev))
        -- else
        --     self.upgradeButton.content = self.upgradeString
        -- end

        if self.upgradeButton.loading == false then
            self.upgradeButton:Update()
        end
    end
    if self.upgradeStarButton ~= nil then
        if fillStar then
            -- if lev < act_lev then
            --     self.upgradeStarButton.content = string.format(self.levUpgradableString, tostring(act_lev))
            -- else
            --     self.upgradeStarButton.content = self.upgradeString
            -- end

            if lev_break_times < lev_break then
                self.upgradeStarButton.content = string.format(self.levUpgradableString, tostring(act_lev))
            elseif lev_break_times == lev_break then
                if lev < act_lev then
                    self.upgradeStarButton.content = string.format(self.levUpgradableString, tostring(act_lev))
                else
                    self.upgradeStarButton.content = self.upgradeString
                end
            else
                self.upgradeStarButton.content = self.upgradeString
            end

        else
            if lev_break_times < lev_break then
                self.upgradeStarButton.content = string.format(self.levUpgradableStarString, tostring(act_lev))
            elseif lev_break_times == lev_break then
                if lev < act_lev then
                    self.upgradeStarButton.content = string.format(self.levUpgradableStarString, tostring(act_lev))
                else
                    self.upgradeStarButton.content = self.upgradeStarString
                end
            else
                self.upgradeStarButton.content = self.upgradeStarString
            end

            -- if lev_break_times == 0 and lev < act_lev then
            --     self.upgradeStarButton.content = string.format(self.levUpgradableStarString, tostring(act_lev))
            -- else
            --     self.upgradeStarButton.content = self.upgradeStarString
            -- end
        end
        if self.upgradeStarButton.loading == false then
            self.upgradeStarButton:Update()
        end
    end
end

function WingUpgradePanel:ShowStarEffect(index)
    if self.wingsEffect[1] ~= nil then self.wingsEffect[1]:DeleteMe() self.wingsEffect[1] = nil end

    if self.starList[index] ~= nil then
        self.wingsEffect[1] = BibleRewardPanel.ShowEffect(20049, self.starList[index].transform, Vector3(0.5, 0.5, 0.5), Vector3(-0.5, -18.5, 1))
    end
end
