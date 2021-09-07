-- @author 黄耀聪
-- @date 2016年9月8日

MidAutumnSettleWindow = MidAutumnSettleWindow or BaseClass(BaseWindow)

function MidAutumnSettleWindow:__init(model)
    self.model = model
    self.name = "MidAutumnSettleWindow"
    self.windowId = WindowConfig.WinID.mid_autumn_settle

    self.resList = {
        {file = AssetConfig.midAutumn_lantern_settle, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
    }

    self.descString = TI18N("你在本轮<color='#ffff00'>孔明灯会</color>里表现优异，\n总共获得了以下奖励：")
    self.slotList = {}
    self.dataList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MidAutumnSettleWindow:__delete()
    self.OnHideEvent:Fire()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotList = nil
    end
    if self.dataList ~= nil then
        for _,v in pairs(self.dataList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.dataList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnSettleWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_lantern_settle))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.descText = t:Find("Main/Desc"):GetComponent(Text)
    self.reward = t:Find("Reward")
    self.rewardContainer = t:Find("Main/Reward/Scroll/Container")
    self.layout = LuaBoxLayout.New(self.rewardContainer, {axis = BoxLayoutAxis.X, cspacing = 5, border = 5})

    self.modelContainer = t:Find("Main/Preview")

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self:update_sh_model()
end

function MidAutumnSettleWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnSettleWindow:OnOpen()
    self:RemoveListeners()

    self.openArgs = self.openArgs or {}
    self:ReloadList(self.openArgs.rewards)
end

function MidAutumnSettleWindow:OnHide()
    self:RemoveListeners()
end

function MidAutumnSettleWindow:RemoveListeners()
end

function MidAutumnSettleWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function MidAutumnSettleWindow:ReloadList(datalist)
    datalist = datalist or {}
    self.layout:ReSet()
    for i,v in ipairs(datalist) do
        if self.slotList[i] == nil then
            self.slotList[i] = ItemSlot.New()
            self.dataList[i] = ItemData.New()
        end
        self.dataList[i]:SetBase(DataItem.data_get[v.assets])
        self.slotList[i]:SetAll(self.dataList[i], {inbag = false, nobutton = true})
        self.slotList[i]:SetNum(v.val)
        self.layout:AddCell(self.slotList[i].gameObject)
        self.slotList[i].gameObject:SetActive(true)
    end
    for i=#datalist + 1,#self.slotList do
        self.slotList[i].gameObject:SetActive(false)
    end
    self.descText.text = self.descString
end

--模性感逻辑
function MidAutumnSettleWindow:update_sh_model()
    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end

    local shdata = DataUnit.data_unit[74136]
    local setting = {
        name = "MidAutumnSettleWindow"
        ,orthographicSize = 1
        ,width = 321
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Pet, skinId = shdata.skin, modelId = shdata.res, animationId = shdata.animation_id, scale = 1.5}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function()
            if self.previewComp1 ~= nil then
                self.previewComp1:Hide()
            end
        end)
        self.OnOpenEvent:AddListener(function()
            if self.previewComp1 ~= nil then
                self.previewComp1:Show()
            end
        end)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--守护模型加载完成
function MidAutumnSettleWindow:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.modelContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end

