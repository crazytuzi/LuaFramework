-- ----------------------------------------------------------
-- UI - 兑换属性窗口
-- xjlong 20160907
-- ----------------------------------------------------------
ExchangePointWindow = ExchangePointWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ExchangePointWindow:__init(model)
    self.model = model
    self.name = "ExchangePointWindow"
    self.windowId = WindowConfig.WinID.levelbreakwindow
    self.winLinkType = WinLinkType.Single
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.exchangepointwindow, type = AssetType.Main}
        ,{file = AssetConfig.rolebg, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil
    ------------------------------------------------

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ExchangePointWindow:__delete()
    self:OnHide()

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.guideBreak ~= nil then
        self.guideBreak:DeleteMe()
        self.guideBreak = nil
    end

    if self.gameObject ~= nil then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function ExchangePointWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exchangepointwindow))
    self.gameObject.name = "ExchangePointWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform:Find("RoleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")

    self.preview = self.mainTransform:Find("Preview").gameObject
    self.preview:SetActive(false)

    self.exchangeButton = self.mainTransform:FindChild("ExchangeButton").gameObject
    self.exchangeButton:GetComponent(Button).onClick:AddListener(function() self:OnExchangeButtonClick() end)

    self.exchangedText = self.mainTransform:FindChild("Exchanged/Text"):GetComponent(Text)
    self.costResText = self.mainTransform:FindChild("CostRes/Text"):GetComponent(Text)
    self.costIcon = self.mainTransform:FindChild("CostRes/Icon"):GetComponent(Image)
    self.curResText = self.mainTransform:FindChild("CurRes/Text"):GetComponent(Text)
    self.curIcon = self.mainTransform:FindChild("CurRes/Icon"):GetComponent(Image)
    self.costResObj = self.mainTransform:FindChild("CostRes").gameObject

    --[[local pointSlider = self.mainTransform:FindChild("PointSlider")
    pointSlider:Find("MinusButton"):GetComponent(Button).onClick:AddListener(function() self:Minus() end)
    pointSlider:Find("PlusButton"):GetComponent(Button).onClick:AddListener(function() self:Plus() end)
    self.valueText = pointSlider:Find("Value"):GetComponent(Text)
    self.slider = pointSlider:Find("Slider"):GetComponent(Slider)
    self.slider.onValueChanged:AddListener(function (val) self:Slide(val) end)]]
    ----------------------------

    self.curSelectNum = 0
    self.canExchangeNum = 0

    self.curExchanged = 0
    self.maxExchanged = 0
    self.assetType = 0
    self.canExchange = false

    self:OnShow()
    self:ClearMainAsset()
end

function ExchangePointWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
    BackpackManager.Instance.mainModel:OpenAddPoint()
end

function ExchangePointWindow:OnShow()
    self:Update()
    self:UpdatePreview()
    self:CheckGuideBreak()
end

function ExchangePointWindow:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function ExchangePointWindow:Update()
    self.curExchanged = RoleManager.Instance.RoleData.levbreakExchangePoint
    self.maxExchanged = DataLevBreak.data_lev_break_times[RoleManager.Instance.RoleData.lev_break_times].max_exchange
    self.exchangedText.text = self.curExchanged.."/"..self.maxExchanged

    local curPointData = DataLevBreak.data_lev_break_exchange[self.curExchanged + 1]
    if curPointData == nil then
        curPointData = DataLevBreak.data_lev_break_exchange[self.curExchanged]
    end
    self.assetType = curPointData.loss[1][1]

    local resTmp = RoleManager.Instance.RoleData:GetMyAssetById(self.assetType)

    self.costIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[self.assetType])
    self.curIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[self.assetType])

    self.canExchange = resTmp >= curPointData.loss[1][2]
    self.costResText.text = tostring(curPointData.loss[1][2])
    if self.canExchange then
        self.curResText.text = tostring(resTmp)
    else
        self.curResText.text = string.format("<color='#ff0000'>%s</color>", resTmp)
    end

    --[[self.curSelectNum = 0
    self.canExchangeNum = 0

    for i,v in ipairs(DataLevBreak.data_lev_break_exchange) do
        if i > self.curExchanged and v.loss[1][1] == assetType then
            if resTmp > v.loss[1][2] then
                resTmp = resTmp - v.loss[1][2]
                self.canExchangeNum = self.canExchangeNum + 1
            else
                break
            end
        end
    end

    self:UpdateVal()]]
end

function ExchangePointWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "ExchangePointWindow"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.38
    }
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function ExchangePointWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

--减1更新
function ExchangePointWindow:Minus()
    if self.curSelectNum > 0 then
        self.curSelectNum = self.curSelectNum - 1
    end

    self:UpdateVal()
end

--加1更新
function ExchangePointWindow:Plus()
    if self.curSelectNum < self.canExchangeNum then
        self.curSelectNum = self.curSelectNum + 1
    end

    self:UpdateVal()
end

--滑动更新
function ExchangePointWindow:Slide(value)
    self.curSelectNum = value
    self:UpdateVal(true)
end

function ExchangePointWindow:UpdateVal(bySlider)
    self.valueText.text = self.curSelectNum.."/"..self.canExchangeNum
    self.slider.value = self.curSelectNum
    self.slider.maxValue = self.canExchangeNum

    local cost = 0
    for i,v in ipairs(DataLevBreak.data_lev_break_exchange) do
        if i > self.curExchanged and i <= self.curExchanged + self.curSelectNum then
            cost = cost + v.loss[1][2]
        end
    end

    self.costResText.text = tostring(cost)
end

function ExchangePointWindow:OnExchangeButtonClick()
    if self.canExchange then
        LevelBreakManager.Instance:send17405(1)
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s不足"), GlobalEumn.AssetName[self.assetType]))
    end
end

-- 检查突破属性点兑换引导
function ExchangePointWindow:CheckGuideBreak()
    if RoleManager.Instance.isGuideBreakThird then
        -- 本次登陆是否引导过
        return
    end

    if not RoleManager.Instance:CheckBreakGuide() then
        return
    end

    local func = nil
    if RoleManager.Instance.RoleData.exp >= 3000000 then
        func = function()
            if self.guideBreak == nil then
                self.guideBreak = GuideBreakPointThird.New(self)
            end
            self.guideBreak:Show()
        end
    else
        func = function()
            TipsManager.Instance:ShowGuide({gameObject = self.costResObj, data = TI18N("最少需要<color='#00ff00'>300万</color>经验才能兑换哦"), forward = TipsEumn.Forward.Up})
        end
    end
    LuaTimer.Add(100, func)
end