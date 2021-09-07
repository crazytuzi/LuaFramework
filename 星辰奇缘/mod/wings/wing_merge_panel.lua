WingMergePanel = WingMergePanel or BaseClass(BasePanel)

function WingMergePanel:__init(model, gameObject, parent)
    self.ID = Time.time
    self.model = model
    self.parent = parent
    self.name = "WingMergePanel"
    self.gameObject = gameObject
    self.mgr = WingsManager.Instance

    self.currencyWingIndex = 1
    self.mergeMaterialString = TI18N("合成材料")
    self.expendString = TI18N("消耗")
    self.mergeLine = {90, 114, 87, 60}
    self.mergeDescString = {
        TI18N("1.翅膀分为5个等阶"),
        TI18N("2.提升翅膀等阶可获得更高属性、开启技能、更炫的翅膀")
    }
    self.EffectList = {}
    self.itemList = {}
    self.lineLength = {
        90,
        114,
        87,
        -60
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.imgLoader = nil
    self.imgLoader1 = nil

    self:InitPanel()
end

function WingMergePanel:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.imgLoader1 ~= nil then
        self.imgLoader1:DeleteMe()
        self.imgLoader1 = nil
    end

    self.OnHideEvent:Fire()
    self.MergePanel:Find("bg"):GetComponent(Image).sprite = nil
    -- self.unlocksprite = nil
    -- self.locksprite = nil
    if self.EffectList ~= nil then
        for k,v in pairs(self.EffectList) do
            v:DeleteMe()
        end
        self.EffectList = nil
    end
    if self.mergeButton ~= nil then
        self.mergeButton:DeleteMe()
        self.mergeButton = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
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

function WingMergePanel:InitPanel()
    local t = self.gameObject.transform
    self.transform = t
    -- self.unlocksprite = self.parent.assetWrapper:GetSprite(AssetConfig.wing_textures, "wingunlock")
    -- self.locksprite = self.parent.assetWrapper:GetSprite(AssetConfig.wing_textures, "winglock")
    self.previewList = {
        pre = {
            btn = t:Find("PreButton"):GetComponent(Button),
            enable = t:Find("PreButton/Enable").gameObject,
            disable = t:Find("PreButton/Disable").gameObject,
        },
        next = {
            btn = t:Find("NextButton"):GetComponent(Button),
            enable = t:Find("NextButton/Enable").gameObject,
            disable = t:Find("NextButton/Disable").gameObject,
        }
    }

    self.helpBtn = t:Find("Help"):GetComponent(Button)
    self.targetContent = t:Find("TargetInfo/WingIcon")
    self.targetNameText = t:Find("TargetInfo/Name"):GetComponent(Text)
    self.handbookBtn = t:Find("Book"):GetComponent(Button)

    self.needContainer = t:Find("MaterialInfo/Needs")
    self.needRect = self.needContainer:GetComponent(RectTransform)
    self.needCloner = self.needContainer:Find("Item").gameObject

    t:Find("MaterialInfo/Cost").gameObject:SetActive(false)

    self.mergeArea = t:Find("MaterialInfo/Synthesize")

    self.qualifyImage = t:Find("PreviewInfo/Title/QualifyImage"):GetComponent(Image)

    t:Find("MaterialInfo/Cost/Text"):GetComponent(Text).text = self.expendString
    t:Find("MaterialInfo/Title/Text"):GetComponent(Text).text = self.mergeMaterialString

    self.previewList.pre.btn.gameObject:SetActive(true)
    self.previewList.next.btn.gameObject:SetActive(true)

    self.previewList.pre.btn.onClick:AddListener(function() self:PreWing() end)
    self.previewList.next.btn.onClick:AddListener(function() self:NextWing() end)
    self.handbookBtn.onClick:AddListener((function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wing_book) end))

    -- 无翅膀合成界面
    self.MergePanel = self.parent.transform:Find("Merge")
    self.MergePanel:Find("bg"):GetComponent(Image).sprite = self.parent.assetWrapper:GetSprite(AssetConfig.shouhu_wakeup_big_bg, "ShouhuWakeUpbg")
    self.formationbg = self.MergePanel:Find("formationbg")
    self.MergeHelp = self.MergePanel:Find("Help")
    self.LineGroup = {}
    self.LineGroup[4] = self.MergePanel:Find("LineGroup/4")
    self.LineGroup[3] = self.MergePanel:Find("LineGroup/3")
    self.LineGroup[2] = self.MergePanel:Find("LineGroup/2")
    self.LineGroup[1] = self.MergePanel:Find("LineGroup/1")
    self.MergeWingIcon = self.MergePanel:Find("WingIcon")
    self.MergePanel:Find("WingIcon/Icon").gameObject:SetActive(false)
    self.MergePoint = {}
    for i=1,4 do
        self.MergePoint[i] = {}
        self.MergePoint[i].transform = self.MergePanel:Find(string.format("Point%s", i))
        self.MergePoint[i].ArrtText = self.MergePanel:Find(string.format("Point%s/ArrtText", i)):GetComponent(Text)
        self.MergePoint[i].Textbg = self.MergePanel:Find(string.format("Point%s/Textbg", i))
        self.MergePoint[i].icon = self.MergePanel:Find(string.format("Point%s/icon", i)):GetComponent(Image)
    end
    self.MergeSlot = self.MergePanel:Find("Need")
    self.Mergename = self.MergePanel:Find("Need/name")
    self.Mergecost = self.MergePanel:Find("Need/cost")
    self.MergeButton = self.MergePanel:Find("Button"):GetComponent(Button)
    -- self.MergeButtonText = self.MergePanel:Find("Button/Text"):GetComponent(Text)
    self.MergeDescText = self.MergePanel:Find("DescText"):GetComponent(Text)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(self.MergeWingIcon)
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -200)
        effectObject.transform.localRotation = Quaternion.identity
        self.wingeffect = effectView
        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        -- effectView:SetActive(i <= self.model.star)
    end
    local effect = BaseEffectView.New({effectId = 20253, time = nil, callback = fun})
    table.insert(self.EffectList, effect)
    self:InitMergePanel()

    self.mergeButton = BuyButton.New(self.MergeButton.gameObject, TI18N("点亮"))
    self.mergeButton.protoId = 11603
    self.targetNameText.text = TI18N("一阶翅膀")

    self.helpBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.helpBtn.gameObject, itemData = self.mergeDescString}) end)
end

function WingMergePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingMergePanel:OnOpen()
    self:InitUI()
    self.mergeButton:Show()
    self.MergePanel.gameObject:SetActive(true)
    self.currencyWingIndex = 1
    self.mgr.onUpdateWing:Fire(self.model.wingsIdByGrade[1][self.currencyWingIndex])
    self.mgr.onUpdateProperty:Fire(1, 5, 0, Vector2(21.6, -154.04))
    self:CheckPreNext()

    self:RemoveListeners()
end

function WingMergePanel:OnHide()
    self.MergePanel.gameObject:SetActive(false)
    self:RemoveListeners()
end

function WingMergePanel:RemoveListeners()
end

function WingMergePanel:InitUI()
    self.qualifyImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon5")
    if self.itemData == nil then
        self.itemData = ItemData.New()
    end
    self.itemData:SetBase(DataItem.data_get[21105])
    if self.itemSlot == nil then
        self.itemSlot = ItemSlot.New()
    end
    self.itemSlot:SetAll(self.itemData, {nobutton = true, inbag = false})
    NumberpadPanel.AddUIChild(self.targetContent.gameObject, self.itemSlot.gameObject)

    self.baseToNum = {}

    self.needCloner:SetActive(false)
    local v = DataWing.data_upgrade["0_1"].need_item[1]
    if self.itemList[1] == nil then
        local obj = GameObject.Instantiate(self.needCloner)
        obj.transform:Find("Name"):GetComponent(Text).color = Color(199/255, 249/255, 255/255)
        obj.name = tostring(i)
        obj.transform:SetParent(self.MergeSlot)
        obj.transform.localPosition = Vector3(0, -20, 0)
        obj.transform.localScale = Vector3.one
        self.itemList[1] = WingMergeNeedItem.New(self.model, obj)
    end
    self.itemList[1]:SetData(v)
    if v[1] >= 90000 then
    else
        self.baseToNum[v[1]] = {need = v[2]}
    end

    -- for i=#DataWing.data_upgrade["0_1"].need_item + 1, #self.itemList do
    --     self.itemList[i]:SetActive(false)
    -- end
    self.mergeButton:Layout(self.baseToNum, function () WingsManager.Instance:Send11603({}) SoundManager.Instance:Play(246) end, function(baseidToBuyInfo) self:callbackAfter12406(baseidToBuyInfo) end, {customButton = self.MergeButton, freezetime = 1.5})

    local h = self.needRect.sizeDelta.y
    local w = 1
    if #DataWing.data_upgrade["0_1"].need_item > 4 then
        w = 90
    else
        w = 110
    end

    self.needRect.sizeDelta = Vector2(w * #DataWing.data_upgrade["0_1"].need_item, h)
    self:UpdateMergePanel()
end

function WingMergePanel:PreWing()
    local model = self.model
    local wingList = model.wingsIdByGrade[1]

    if self.currencyWingIndex > 1 then
        self.currencyWingIndex = self.currencyWingIndex - 1
        self.mgr.onUpdateWing:Fire(wingList[self.currencyWingIndex])
    end
    self:CheckPreNext()
end

function WingMergePanel:NextWing()
    local model = self.model
    local wingList = model.wingsIdByGrade[1]

    if self.currencyWingIndex < #wingList then
        self.currencyWingIndex = self.currencyWingIndex + 1
        self.mgr.onUpdateWing:Fire(wingList[self.currencyWingIndex])
    end
    self:CheckPreNext()
end

function WingMergePanel:CheckPreNext()
    local model = self.model
    local wingList = model.wingsIdByGrade[1]
    local pre = self.previewList.pre
    local next = self.previewList.next

    local isFirst = (self.currencyWingIndex == 1)
    local isEnd = (self.currencyWingIndex == #wingList)

    pre.disable:SetActive(isFirst)
    pre.enable:SetActive(not isFirst)
    next.disable:SetActive(isEnd)
    next.enable:SetActive(not isEnd)
end

function WingMergePanel:callbackAfter12406(baseidToBuyInfo)
    for i,v in ipairs(DataWing.data_upgrade["0_1"].need_item) do
        if self.itemList[i] ~= nil then
            self.itemList[i]:SetData(v, baseidToBuyInfo[v[1]])
        end
    end
end

function WingMergePanel:InitMergePanel()
    if WingsManager.Instance.grade > 0 then
        return
    end
    self.currstar = WingsManager.Instance.star

    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(self.MergeWingIcon)
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -200)
        effectObject.transform.localRotation = Quaternion.identity
        self.LastEffect = effectView
        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectView:SetActive(WingsManager.Instance.star ~= nil and WingsManager.Instance.star == 4)
        if self.wingeffect ~= nil then
            self.wingeffect:SetActive(WingsManager.Instance.star ~= nil and WingsManager.Instance.star ~= 4)
        end
    end
    local effect = BaseEffectView.New({effectId = 20250, time = nil, callback = fun})
    table.insert(self.EffectList, effect)
    for i=1, 4 do
        local attrdata = BaseUtils.copytab(DataWing.data_attribute[string.format("%s_0_1_%s", RoleManager.Instance.RoleData.classes, tostring(i))])
        local lastattrdata = BaseUtils.copytab(DataWing.data_attribute[string.format("%s_0_1_%s", RoleManager.Instance.RoleData.classes, tostring(i-1))])
        if attrdata ~= nil then
            if lastattrdata ~= nil then
                local newattrdata = BaseUtils.copytab(attrdata)
                for k,v in pairs(lastattrdata.attr) do
                    for kk,vv in pairs(attrdata.attr) do
                        if vv.attr_name == v.attr_name and vv.val == v.val then
                            newattrdata.attr[kk] = nil
                        elseif vv.attr_name == v.attr_name and vv.val ~= v.val then
                            newattrdata.attr[kk].val = vv.val - v.val
                        end
                    end
                end
                attrdata.attr = {}
                for k,v in pairs(newattrdata.attr) do
                    table.insert(attrdata.attr, v)
                end
            end
            self.MergePoint[i].ArrtText.text = KvData.GetAttrString(attrdata.attr[1].attr_name, attrdata.attr[1].val)
        end
        if self.MergePoint[i].lockeffect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.MergePoint[i].transform)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(0, 0, -200)
                effectObject.transform.localRotation = Quaternion.identity
                self.MergePoint[i].lockeffect = effectView
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectView:SetActive(WingsManager.Instance.star ~= nil and i == WingsManager.Instance.star+1)
            end
            local effect = BaseEffectView.New({effectId = 20200, time = nil, callback = fun})
            table.insert(self.EffectList, effect)
        end
        if self.MergePoint[i].unlockeffect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.MergePoint[i].transform)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(0, 0, -200)
                effectObject.transform.localRotation = Quaternion.identity
                self.MergePoint[i].unlockeffect = effectView
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectView:SetActive(WingsManager.Instance.star ~= nil and i <= WingsManager.Instance.star)
            end
            local effect = BaseEffectView.New({effectId = 20252, time = nil, callback = fun})
            table.insert(self.EffectList, effect)
        end
        if self.MergePoint[i].lineeffect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.LineGroup[i])
                effectObject.transform.localScale = Vector3.one
                if i == 4 then
                    effectObject.transform.localScale = Vector3.one*0.7
                end
                local x = self.lineLength[i]/2

                effectObject.transform.localPosition = Vector3(x, 0, -200)
                effectObject.transform.localRotation = Quaternion.identity
                self.MergePoint[i].lineeffect = effectView
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectView:SetActive(WingsManager.Instance.star ~= nil and i <= WingsManager.Instance.star)
            end
            local effect = BaseEffectView.New({effectId = 20251, time = nil, callback = fun})
            table.insert(self.EffectList, effect)
        end
        if self.MergePoint[i].openeffect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.MergePoint[i].transform)
                effectObject.transform.localScale = Vector3.one
                effectObject.transform.localPosition = Vector3(0, 0, -200)
                effectObject.transform.localRotation = Quaternion.identity
                self.MergePoint[i].openeffect = effectView
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                -- effectView:SetActive(WingsManager.Instance.star ~= nil and i <= WingsManager.Instance.star)
                effectView:SetActive(false)
            end
            local effect = BaseEffectView.New({effectId = 20254, time = nil, callback = fun})
            table.insert(self.EffectList, effect)
        end
    end
    if self.rotateID == nil then
        self.rotateID = Tween.Instance:RotateZ(self.formationbg.gameObject, -720, 30, function() end):setLoopClamp()
    end
    if WingsManager.Instance.wing_id == nil or WingsManager.Instance.wing_id == 0 then
        for i=1, 4 do
            if i >= WingsManager.Instance.star + 1 then
                self.LineGroup[i].sizeDelta = Vector2(0, 8)
            else
                self.LineGroup[i].sizeDelta = Vector2(self.mergeLine[i], 8)
            end
            if i <= WingsManager.Instance.star then
                BaseUtils.SetGrey(self.MergePoint[i].icon, false, true)
                -- self.MergePoint[i].icon.sprite = self.unlocksprite
                if self.MergePoint[i].lockeffect ~= nil then
                    self.MergePoint[i].lockeffect:SetActive(false)
                end
                if self.MergePoint[i].unlockeffect ~= nil then
                    self.MergePoint[i].unlockeffect:SetActive(false)
                end
            elseif i == WingsManager.Instance.star+1 then
                if self.MergePoint[i].lockeffect ~= nil then
                    self.MergePoint[i].lockeffect:SetActive(true)
                end
                if self.MergePoint[i].unlockeffect ~= nil then
                    self.MergePoint[i].unlockeffect:SetActive(false)
                end
                self.LineGroup[i].sizeDelta = Vector2(0, 8)
                BaseUtils.SetGrey(self.MergePoint[i].icon, true, true)
                -- self.MergePoint[i].icon.sprite = self.locksprite
            else
                self.LineGroup[i].sizeDelta = Vector2(0, 8)
                BaseUtils.SetGrey(self.MergePoint[i].icon, true, true)
                -- self.MergePoint[i].icon.sprite = self.locksprite
            end
        end
    end
end

function WingMergePanel:UpdateMergePanel()
    if WingsManager.Instance.wing_id == nil or WingsManager.Instance.wing_id == 0 then
        if self.currstar ~= WingsManager.Instance.star and self.currstar < WingsManager.Instance.star then
            if self.LineGroup[WingsManager.Instance.star] ~= nil then
                local fun = function(val)
                    self.LineGroup[WingsManager.Instance.star].sizeDelta = Vector2(self.mergeLine[WingsManager.Instance.star]*val, 8)
                end
                local endfunc = function()
                    if self.LastEffect ~= nil then
                        self.LastEffect:SetActive(WingsManager.Instance.star == 4)
                        self.wingeffect:SetActive(WingsManager.Instance.star ~= 4)
                    end
                    if self.MergePoint[WingsManager.Instance.star+1] ~= nil  and self.MergePoint[WingsManager.Instance.star+1].lockeffect ~= nil then
                        self.MergePoint[WingsManager.Instance.star+1].lockeffect:SetActive(true)
                    end
                    self.tweening = false
                end
                Tween.Instance:ValueChange(0, 1, 0.6, endfunc, LeanTweenType.linear, fun)
            end
            if self.MergePoint[WingsManager.Instance.star] ~= nil  and self.MergePoint[WingsManager.Instance.star].openeffect ~= nil then
                self.MergePoint[WingsManager.Instance.star].openeffect:SetActive(true)
                LuaTimer.Add(1500, function()
                    if self.MergePoint ~= nil and self.MergePoint[WingsManager.Instance.star] ~= nil then
                        self.MergePoint[WingsManager.Instance.star].openeffect:SetActive(false)
                    end
                end)
            end
            if self.MergePoint[WingsManager.Instance.star] ~= nil then
                BaseUtils.SetGrey(self.MergePoint[WingsManager.Instance.star].icon, false, true)
                -- self.MergePoint[WingsManager.Instance.star].icon.sprite = self.unlocksprite
            end
            if self.MergePoint[WingsManager.Instance.star].lockeffect ~= nil then
                self.MergePoint[WingsManager.Instance.star].lockeffect:SetActive(false)
            end
            if self.MergePoint[WingsManager.Instance.star].unlockeffect ~= nil then
                self.MergePoint[WingsManager.Instance.star].unlockeffect:SetActive(true)
            end
            if self.MergePoint[WingsManager.Instance.star].lineeffect ~= nil then
                self.MergePoint[WingsManager.Instance.star].lineeffect:SetActive(true)
            end
            self.MergePoint[WingsManager.Instance.star].ArrtText.gameObject:SetActive(true)
            self.MergePoint[WingsManager.Instance.star].Textbg.gameObject:SetActive(true)
        elseif self.currstar > WingsManager.Instance.star then
            for i=1, 4 do
                if i >= WingsManager.Instance.star + 1 then
                    self.LineGroup[i].sizeDelta = Vector2(0, 8)
                else
                    self.LineGroup[i].sizeDelta = Vector2(self.mergeLine[i], 8)
                end
                if i <= WingsManager.Instance.star then
                    BaseUtils.SetGrey(self.MergePoint[i].icon, false, true)
                    -- self.MergePoint[i].icon.sprite = self.unlocksprite
                    if self.MergePoint[i].lockeffect ~= nil then
                        self.MergePoint[i].lockeffect:SetActive(false)
                    end
                    if self.MergePoint[i].unlockeffect ~= nil then
                        self.MergePoint[i].unlockeffect:SetActive(true)
                    end
                    if self.MergePoint[i].lineeffect ~= nil then
                        self.MergePoint[i].lineeffect:SetActive(true)
                    end
                    if self.MergePoint[i] ~= nil  and self.MergePoint[i].openeffect ~= nil then
                        self.MergePoint[i].openeffect:SetActive(false)
                    end
                elseif i == WingsManager.Instance.star+1 then
                    BaseUtils.SetGrey(self.MergePoint[i].icon, true, true)
                    -- self.MergePoint[i].icon.sprite = self.locksprite
                    if self.MergePoint[i].lockeffect ~= nil then
                        self.MergePoint[i].lockeffect:SetActive(true)
                    end
                    if self.MergePoint[i].unlockeffect ~= nil then
                        self.MergePoint[i].unlockeffect:SetActive(false)
                    end
                    if self.MergePoint[i].lineeffect ~= nil then
                        self.MergePoint[i].lineeffect:SetActive(false)
                    end
                    self.LineGroup[i].sizeDelta = Vector2(0, 8)
                else
                    self.LineGroup[i].sizeDelta = Vector2(0, 8)
                    BaseUtils.SetGrey(self.MergePoint[i].icon, true, true)
                    -- self.MergePoint[i].icon.sprite = self.locksprite
                    if self.MergePoint[i].unlockeffect ~= nil then
                        self.MergePoint[i].unlockeffect:SetActive(false)
                    end
                end
            end
        end
    end
    self.currstar = WingsManager.Instance.star
end

WingMergeNeedItem = WingMergeNeedItem or BaseClass()

function WingMergeNeedItem:__init(model, gameObject)
    self.gameObject = gameObject
    self.model = model

    local t = gameObject.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.iconObj = t:Find("Icon").gameObject
    self.btn = gameObject:GetComponent(Button)
    self.numText = t:Find("Num"):GetComponent(Text)
    self.numText.color = ColorHelper.DefaultButton1
    self.costExt = MsgItemExt.New(t:Find("CenterNum"):GetComponent(Text), 100, 16, 18.52)
    self.costExt.contentTrans.gameObject:SetActive(false)

    -- t.anchoredPosition = t.anchoredPosition + Vector2(0, -15)

    self.clickFunc = function()
    print("===========================================1=============")
        if self.itemData ~= nil then
            TipsManager.Instance:ShowItem({["gameObject"] = self.iconObj, ["itemData"] = self.itemData})
        end
    end
    self.btn.onClick:AddListener(self.clickFunc)
end

function WingMergeNeedItem:__delete()
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.costExt ~= nil then
        self.costExt:DeleteMe()
        self.costExt = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
end

-- data 基本显示数据
-- protoData 协议数据，这里指的是价格数据
function WingMergeNeedItem:SetData(data, protoData)
    self.gameObject:SetActive(true)
    self.base_id = data[1]
    self.data = data
    if protoData ~= nil then
        self.costExt.contentTrans.gameObject:SetActive(true)
        if protoData.allprice < 0 then
            self.costExt:SetData(string.format("{string_2, #ff0000, %s}{assets_2,%s}", 0 - protoData.allprice, protoData.assets))
        else
            self.costExt:SetData(string.format("%s{assets_2,%s}", protoData.allprice, protoData.assets))
        end
        local size = self.costExt.contentTrans.sizeDelta
        self.costExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, -34)
    else
        self.costExt.contentTrans.gameObject:SetActive(false)
    end

    local basedata = DataItem.data_get[data[1]]
    if self.itemData == nil then self.itemData = ItemData.New() end
    self.itemData:SetBase(basedata)

    self.nameText.text = basedata.name
    if self.itemSlot == nil then
        self.itemSlot = ItemSlot.New()
        NumberpadPanel.AddUIChild(self.iconObj.transform, self.itemSlot.gameObject)
    end
    self.itemSlot:SetAll(self.itemData, {inbag = false, noTips = true})
    self.itemSlot.clickSelfFunc = self.clickFunc

    if data[1] < 90000 then
        local inBagNum = BackpackManager.Instance:GetItemCount(data[1])
        if inBagNum < data[2] then
            self.numText.text = string.format("<color=#FF0000>%s</color>/%s", inBagNum, data[2])
        else
            self.numText.text = string.format("<color='#00ff00'>%s</color>/%s", inBagNum, data[2])
        end
    else
        local assetNum = 0
        local roledata = RoleManager.Instance.RoleData

        for k,v in pairs(KvData.assets) do
            if data[1] == v then
                assetNum = roledata[k]
                break
            end
        end

        self.numText.text = ""

        if assetNum < data[2] then
            self.numText.text = "<color=#FF0000>"..data[2].."</color>"
        else
            self.numText.text = tostring(data[2])
        end
    end

    -- self.costExt.contentTrans.gameObject:SetActive(false)
    self:SetActive(true)
end

function WingMergeNeedItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

