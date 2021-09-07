-- @author 黄耀聪
-- @date 2016年6月21日

RechargeExplainWindow = RechargeExplainWindow or BaseClass(BaseWindow)

function RechargeExplainWindow:__init(model)
    self.model = model
    self.name = "RechargeExplainWindow"
    self.windowId = WindowConfig.WinID.recharge_explain

    self.ios_help_step = {
        {"textures/ui/bigbg/ios_help_step_1.unity3d", "ios_help_step_1"},
        {"textures/ui/bigbg/ios_help_step_2.unity3d", "ios_help_step_2"},
        {"textures/ui/bigbg/ios_help_step_3.unity3d", "ios_help_step_3"},
        {"textures/ui/bigbg/ios_help_step_4.unity3d", "ios_help_step_4"},
        {"textures/ui/bigbg/ios_help_step_5.unity3d", "ios_help_step_5"},
        {"textures/ui/bigbg/ios_help_step_6.unity3d", "ios_help_step_6"},
    }

    self.resList = {
        {file = AssetConfig.recharge_explain_window, type = AssetType.Main},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
    }
    for _,v in pairs(self.ios_help_step) do
        table.insert(self.resList, {file = v[1], type = AssetType.Main})
    end

    self.steps = {
        {desc = TI18N("1.进入App Store"), res = 1},
        {desc = TI18N("2.点击页面底部的Apple ID"), res = 2},
        {desc = TI18N("3.点击查看Apple ID"), res = 3},
        {desc = TI18N("4.设置账户（注意必填）"), res = 4},
        {desc = TI18N("5.填写手机验证码"), res = 5},
        {desc = TI18N("6.完成后可在游戏内充值"), res = 6},
    }

    self.pageList = {}
    self.toggleList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RechargeExplainWindow:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.pageList ~= nil then
        for _,page in ipairs(self.pageList) do
            if page.steps ~= nil then
                for _,v in pairs(page.steps) do
                    v.image.sprite = nil
                end
            end
        end
        self.pageList = nil
    end
    if self.toggleLayout ~= nil then
        self.toggleLayout:DeleteMe()
        self.toggleLayout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RechargeExplainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.recharge_explain_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local main = t:FindChild("Main")
    main:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.scroll = main:FindChild("ScrollLayer"):GetComponent(ScrollRect)
    self.container = main:FindChild("ScrollLayer/Container")
    self.pageCloner = main:FindChild("ScrollLayer/Cloner").gameObject

    self.prePageEnable = main:Find("PrePageBtn/Enable").gameObject
    self.prePageDisable = main:Find("PrePageBtn/Disable").gameObject
    self.nextPageEnable = main:Find("NextPageBtn/Enable").gameObject
    self.nextPageDisable = main:Find("NextPageBtn/Disable").gameObject
    self.prePageBtn = main:FindChild("PrePageBtn"):GetComponent(Button)
    self.nextPageBtn = main:FindChild("NextPageBtn"):GetComponent(Button)

    self.toggleContainer = main:FindChild("ToggleGroup")
    self.toggleCloner = main:FindChild("ToggleGroup/Toggle").gameObject

    self.pageCloner:SetActive(false)
    self.toggleCloner:SetActive(false)

    self.prePageBtn.onClick:AddListener(function()
        if self.tabbedPanel.currentPage > 1 then
            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage - 1)
        end
    end)
    self.nextPageBtn.onClick:AddListener(function()
        if self.tabbedPanel.currentPage < math.ceil(#self.steps / 3) then
            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage + 1)
        end
    end)
end

function RechargeExplainWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RechargeExplainWindow:OnOpen()
    self:RemoveListeners()

    self:InitUI()
end

function RechargeExplainWindow:InitUI()
    local pageCount = math.ceil(#self.steps / 3)
    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.scroll.gameObject, pageCount, 720)
        self.tabbedPanel.MoveEndEvent:AddListener(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)
    end

    self.layout = self.layout or LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0})
    -- self.toggleLayout = self.toggleLayout or LuaBoxLayout.New(self.toggleContainer, {axis = BoxLayoutAxis.X, cspacing = 0})

    self.layout:ReSet()
    for i=1,pageCount do
        if self.pageList[i] == nil then
            local tab = {obj = nil, step = {nil, nil, nil}, trans = nil}
            tab.obj = GameObject.Instantiate(self.pageCloner)
            tab.obj.name = tostring(i)
            tab.trans = tab.obj.transform
            for j=1,3 do
                local tab1 = {obj = nil, trans = nil, descText = nil, image = nil}
                tab1.trans = tab.trans:FindChild("Item"..j)
                tab1.obj = tab1.trans.gameObject
                tab1.descText = tab1.trans:FindChild("Desc"):GetComponent(Text)
                tab1.image = tab1.trans:Find("Bg/Image"):GetComponent(Image)
                tab.step[j] = tab1
            end
            self.pageList[i] = tab
        end
        local tab = self.pageList[i]
        self.layout:AddCell(tab.obj)
        for j=1,3 do
            local data = self.steps[(i-1)*3+j]
            if data == nil then
                tab.obj:SetActive(false)
            else
                tab.obj:SetActive(true)
                tab.step[j].descText.text = data.desc
                tab.step[j].image.sprite = self.assetWrapper:GetSprite(self.ios_help_step[data.res][1], self.ios_help_step[data.res][2])
                tab.step[j].image.gameObject:SetActive(true)
            end
        end

        if self.toggleList[i] == nil then
            local tab = {obj = nil, toggle = nil, trans}
            tab.obj = GameObject.Instantiate(self.toggleCloner)
            tab.obj.name = tostring(i)
            tab.obj:SetActive(true)
            tab.trans = tab.obj.transform
            tab.toggle = tab.obj:GetComponent(Toggle)
            tab.trans:SetParent(self.toggleContainer)
            tab.trans.localScale = Vector3.one
            tab.toggle.enabled = false

            self.toggleList[i] = tab
        end
    end

    self:OnDragEnd(self.tabbedPanel.currentPage)
end

function RechargeExplainWindow:OnHide()
    self:RemoveListeners()
end

function RechargeExplainWindow:RemoveListeners()
end

function RechargeExplainWindow:OnClose()
    self.model:CloseRechargeExplain()
end

function RechargeExplainWindow:OnDragEnd(currentPage, direction)
    if currentPage < math.ceil(#self.steps / 3) then
        self.nextPageEnable:SetActive(true)
        self.nextPageDisable:SetActive(false)
    else
        self.nextPageEnable:SetActive(false)
        self.nextPageDisable:SetActive(true)
    end
    if currentPage > 1 then
        self.prePageEnable:SetActive(true)
        self.prePageDisable:SetActive(false)
    else
        self.prePageEnable:SetActive(false)
        self.prePageDisable:SetActive(true)
    end

    for i,v in ipairs(self.toggleList) do
        v.toggle.isOn = false
    end
    self.toggleList[currentPage].toggle.isOn = true

    self.isMoving = false
end






