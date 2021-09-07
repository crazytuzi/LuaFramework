WingResetPanel = WingResetPanel or BaseClass(BasePanel)

function WingResetPanel:__init(model, gameObject)
    self.model = model
    self.parent = parent
    self.name = "WingResetPanel"
    self.gameObject = gameObject
    self.mgr = WingsManager.Instance

    self.resetDescString = {
        TI18N("1.翅膀属性与翅膀品质挂钩"),
        TI18N("2.品质越好属性越高"),
        TI18N("3.红色品质为最佳属性"),
        TI18N("4.重置可获取新的品质")
    }

    self.resetLookString = {
        TI18N("1.每个等阶分为几种翅膀"),
        TI18N("2.可选择自己喜欢的类型"),
        TI18N("3.重置可获取新的翅膀外观")
    }

    -- self.descString = TI18N("重置可获得新的<color=#ace92a>翅膀外观</color>和<color=#ace92a>翅膀属性</color>")
    self.descString = TI18N("最高属性品质排序:")
    self.previewDescString = TI18N("信息预览")

    self.resList = {

    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    -- self.onUpdateWingInfo = function()
    --     print('--------------------------更新翅膀信息')
    --     self:UpdateInfo()
    -- end

    self.propertyList = {}
    self.newPropertyList = {}
    self.itemList = {}

    self:InitPanel()
end

function WingResetPanel:__delete()
    -- EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.onUpdateWingInfo)
    self.OnHideEvent:Fire()
    if self.resetButton ~= nil then
        self.resetButton:DeleteMe()
        self.resetButton = nil
    end
    if self.qualityIcon ~= nil then
        self.qualityIcon.sprite = nil
    end
    if self.afterImage ~= nil then
        self.afterImage.sprite = nil
    end
    if self.beforeImage ~= nil then
        self.beforeImage.sprite = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self:AssetClearAll()
end

function WingResetPanel:InitPanel()
    local panel = self.gameObject.transform
    self.transform = panel

    local needTransfrom = panel:Find("MaterialPanel/Needs")
    self.needTransfrom = needTransfrom
    self.itemTemplate = needTransfrom:Find("Item")
    self.needRect = needTransfrom:GetComponent(RectTransform)
    local w = 100

    self.DescIconCon = panel:Find("Tips/DescIconCon").gameObject
    self.DescIconCon:SetActive(true)
    self.DescIconConDesc = panel:Find("Tips/DescIconCon/Desc"):GetComponent(Text)
    self.descText = panel:Find("Tips/Desc"):GetComponent(Text)
    self.showPropertyBtn = panel:Find("Tips/ShowProperty"):GetComponent(Button)
    self.showLookBtn = panel:Find("Tips/ShowLook"):GetComponent(Button)
    self.qualityIcon = panel:Find("PreviewInfo/Title/QualifyImage"):GetComponent(Image)
    self.titleRect = panel:Find("PreviewInfo/Title"):GetComponent(RectTransform)
    self.saveBtn = panel:Find("Save"):GetComponent(Button)
    self.titleObj = panel:Find("PreviewInfo/Title").gameObject
    self.propertyPanel = panel:Find("PreviewInfo/PropertyPanel").gameObject
    self.beforeImage = panel:Find("PreviewInfo/PropertyPanel/Before/Image"):GetComponent(Image)
    self.afterImage = panel:Find("PreviewInfo/PropertyPanel/After/Image"):GetComponent(Image)
    self.previewDescText = panel:Find("PreviewInfo/Title/Text"):GetComponent(Text)

    for i=1,4 do
        local obj = panel:Find("PreviewInfo/PropertyPanel/Panel/Original/Property"..i)
        self.propertyList[i] = {}
        self.propertyList[i].obj = obj.gameObject
        self.propertyList[i].text = obj:Find("Text"):GetComponent(Text)
        self.propertyList[i].value = obj:Find("Value"):GetComponent(Text)
    end
    for i=1,4 do
        local obj = panel:Find("PreviewInfo/PropertyPanel/Panel/Now/NewProperty"..i)
        self.newPropertyList[i] = {}
        self.newPropertyList[i].obj = obj.gameObject
        self.newPropertyList[i].text = obj:Find("Text"):GetComponent(Text)
        self.newPropertyList[i].value = obj:Find("Value"):GetComponent(Text)
    end

    self.nowRect = panel:Find("PreviewInfo/PropertyPanel/Panel/Now"):GetComponent(RectTransform)
    self.origalRect = panel:Find("PreviewInfo/PropertyPanel/Panel/Original"):GetComponent(RectTransform)
    self.resetArea = panel:Find("ResetPanel/Button")
    self.resetText = panel:Find("ResetPanel/insuranceText"):GetComponent(Text)

        --幸运值
    self.luckValTxt = panel:Find("ResetPanel/LuckCon/TxtLuckVal"):GetComponent(Text)
    self.luckTanHaoBtn = panel:Find("ResetPanel/LuckCon"):GetComponent(Button)
    self.luckTanHaoBtn.onClick:AddListener(function()
        -- local str1 = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("1、每次重置翅膀将获得一定"), TI18N("极品率"), TI18N("加成"))
        -- local str2 = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("2、极品率越高，重置出"), TI18N("高品质翅膀"), TI18N("（橙色或红色）的几率越大"))
        -- local str3 = string.format("%s<color='#00ff00'>%s</color>", TI18N("3、当重置出红色品质翅膀时，极品率将"), TI18N("重置"))
        -- local str = string.format("%s\n%s\n%s", str1, str2, str3)
        -- NoticeManager.Instance:On9910({base_id = 20001, msg = str})


        local tips = {}
        table.insert(tips, TI18N("重置次数越多，出现<color='#ffff00'>橙色、红色翅膀</color>的几率越高"))
        TipsManager.Instance:ShowText({gameObject = self.luckTanHaoBtn.gameObject, itemData = tips})
    end)

    self.saveBtn.onClick:RemoveAllListeners()
    self.saveBtn.onClick:AddListener(function() self:SaveResetWings() end)

    self.resetButton = BuyButton.New(self.resetArea.gameObject, TI18N("重 置"))
    self.resetButton.protoId = 11604
    self.resetButton:Show()

    self.showPropertyBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.showPropertyBtn.gameObject, itemData = self.resetDescString}) end)
    self.showLookBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.showLookBtn.gameObject, itemData = self.resetLookString}) end)

    self.descText.text =  "" -- self.descString
    self.DescIconConDesc.text = self.descString
    self.descText.horizontalOverflow = 1
    self.previewDescText.text = self.previewDescString

    -- EventMgr.Instance:AddListener(event_name.role_wings_change, self.onUpdateWingInfo)
end

function WingResetPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingResetPanel:OnOpen()
    self:RemoveListeners()

    self:InitUI()
end

function WingResetPanel:OnHide()
    self:RemoveListeners()
end

function WingResetPanel:RemoveListeners()
end

function WingResetPanel:InitUI()
    self.baseToNum = {}
    local panel = self.transform
    local model = self.model
    local data = DataWing.data_reset[model.grade].need_item
    self.itemTemplate.gameObject:SetActive(false)
    for i,v in ipairs(data) do
        if self.itemList[i] == nil then
            local obj = GameObject.Instantiate(self.itemTemplate.gameObject)
            obj.name = tostring(i)
            obj.transform:SetParent(self.needTransfrom)
            obj.transform.localScale = Vector3.one
            self.itemList[i] = WingMergeNeedItem.New(self.model, obj)
        end
        self.itemList[i]:SetData(v)
        if v[1] >= 90000 then
        else
            self.baseToNum[v[1]] = {need = v[2]}
        end
    end

    for i=#data + 1, #self.itemList do
        self.itemList[i]:SetActive(false)
    end

    local h = self.needRect.sizeDelta.y
    local w = nil
    if #data > 4 then
        w = 90
    else
        w = 110
    end

    self.needRect.sizeDelta = Vector2(w * #data, h)
    self.mgr.onUpdateWing:Fire(self.model.wingsIdByGrade[model.grade][1])

    -- self.mgr.onUpdateProperty:Fire(grade, 5, Vector2(21.6, -154.04))

    self.resetButton:Layout(self.baseToNum, function () WingsManager.Instance:Send11604({}) SoundManager.Instance:Play(246) end, function(baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end)

    local classes = RoleManager.Instance.RoleData.classes
    local grade = nil
    local growth = nil
    if DataWing.data_base[model.temp_reset_id] == nil then
        self.qualityIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..model.growth)
        grade = model.grade
        growth = model.growth
        self.titleObj:SetActive(true)
        self.propertyPanel:SetActive(false)

        self.mgr.onUpdateWing:Fire(model.wing_id)
        self.mgr.onUpdateProperty:Fire(grade, growth, model.star, Vector2(21.6, -154.04))
    else
        self.qualityIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..model.tmp_growth)
        grade = model.tmp_grade
        growth = model.tmp_growth
        self.titleObj:SetActive(false)
        self.propertyPanel:SetActive(true)
        self.beforeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..tostring(model.growth))
        self.afterImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..tostring(growth))

        self.mgr.onUpdateWing:Fire(model.wing_id, model.temp_reset_id)
        self.mgr.onUpdateProperty:Fire(grade, growth)

        local newAttrlist = DataWing.data_attribute[classes.."_"..grade.."_"..growth.."_"..model.star].attr
        local attrlist = DataWing.data_attribute[classes.."_"..model.grade.."_"..model.growth.."_"..model.star].attr
        for i=1,4 do
            self.propertyList[i].obj:SetActive(false)
            self.newPropertyList[i].obj:SetActive(false)
            if attrlist[i] ~= nil then
                self.propertyList[i].text.text = KvData.GetAttrName(attrlist[i].attr_name)..":"
                self.propertyList[i].value.text = tostring(attrlist[i].val)
                self.propertyList[i].obj:SetActive(true)
            else
                self.propertyList[i].obj:SetActive(false)
            end
            if newAttrlist[i] ~= nil then
                self.newPropertyList[i].text.text = KvData.GetAttrName(newAttrlist[i].attr_name)..":"
                self.newPropertyList[i].value.text = tostring(newAttrlist[i].val)
                self.newPropertyList[i].obj:SetActive(true)
            else
                self.newPropertyList[i].obj:SetActive(false)
            end
        end

        self.nowRect.sizeDelta = Vector2(129.5, #newAttrlist * 25)
        self.origalRect.sizeDelta = Vector2(129.5, #attrlist * 25)
    end

    self.saveBtn.gameObject:SetActive(DataWing.data_base[model.temp_reset_id] ~= nil)
    self.luckValTxt.text = string.format(TI18N("幸运值:%s"), WingsManager.Instance.reset_times*2)

    if DataWing.data_reset[model.grade] ~= nil and DataWing.data_reset[model.grade].insurance - WingsManager.Instance.reset_times <= 5 then
        -- 显示保底文本
        self.resetText.text = string.format(TI18N("<color='#ffa500'>再重置<color='#00ff00'>%s</color>次必然出现<color='#ff0000'>红色品阶</color></color>"), tostring(DataWing.data_reset[model.grade].insurance - WingsManager.Instance.reset_times))
        self.resetText.gameObject:SetActive(true)
    else
        self.resetText.gameObject:SetActive(false)
    end
end

-- function WingResetPanel:UpdateInfo()
--     -- print("=========================================dddddddddd")
--     BaseUtils.dump(WingsManager.Instance.WingInfo)

--     self.luckValTxt.text = string.format("%s:%s", TI18N("幸运值"), WingsManager.Instance.reset_times*2)
-- end

function WingResetPanel:callbackAfter12406(baseidToBuyInfo)
    local model = self.model
    local data = DataWing.data_reset[model.grade].need_item
    for i,v in ipairs(data) do
        self.itemList[i]:SetData(v, baseidToBuyInfo[v[1]])
    end
end

function WingResetPanel:SaveResetWings()
    WingsManager.Instance:Send11605({})
end
