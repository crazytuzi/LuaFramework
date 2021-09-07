SellConfirmWindow  =  SellConfirmWindow or BaseClass(BasePanel)

function SellConfirmWindow:__init(model)
    self.name = "SellConfirmWindow"
    self.model = model
    self.windowId = WindowConfig.WinID.sell_confirm_window

    self.resList = {
        {file = AssetConfig.sell_confirm_window, type = AssetType.Main}
    }

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end


function SellConfirmWindow:__delete()
    self.OnHideEvent:Fire()

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end

function SellConfirmWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sell_confirm_window))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    local t = self.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform:GetComponent(RectTransform).localPosition = Vector3(0, 0, -310)

    local main = self.transform:FindChild("MainCon")

    self.mainLayout = LuaBoxLayout.New(main, {axis = BoxLayoutAxis.Y, cspacing = 20, border = 20})

    main:FindChild("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        if self.openArgs ~= nil and self.openArgs.cancelCallback ~= nil then
            self.openArgs.cancelCallback()
        end
        self.model:CloseConfirm()
    end)
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function()
        if self.openArgs ~= nil and self.openArgs.cancelCallback ~= nil then
            self.openArgs.cancelCallback()
        end
        self.model:CloseConfirm()
    end)

    self.titleArea = main:FindChild("TitleArea").gameObject
    self.titleMsg = MsgItemExt.New(main:FindChild("TitleArea/TxtTitle"):GetComponent(Text), 290, 18, 20)

    self.btnArea = main:FindChild("BtnArea").gameObject
    self.BtnCancel = main:FindChild("BtnArea/BtnCancel"):GetComponent(Button)
    self.BtnCreate = main:FindChild("BtnArea/BtnCreate"):GetComponent(Button)
    self.arrow = main:Find("Arrow").gameObject

    self.MaskCon = main:FindChild("MaskCon")
    self.ScrollCon = self.MaskCon:FindChild("ScrollCon")
    self.ItemCon = self.ScrollCon:FindChild("ItemCon")
    self.Item = self.ItemCon:FindChild("Item").gameObject
    self.layout = LuaBoxLayout.New(self.ItemCon, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 2})

    self.extraArea = main:Find("ExtraArea").gameObject
    self.extraMsg = MsgItemExt.New(main:Find("ExtraArea/Extra"):GetComponent(Text), 290, 18, 20)

    self.BtnCancel.onClick:AddListener(function()
        if self.openArgs ~= nil and self.openArgs.cancelCallback ~= nil then
            self.openArgs.cancelCallback()
        end
        self.model:CloseConfirm()
    end)
    self.BtnCreate.onClick:AddListener(function()
        if self.openArgs ~= nil and self.openArgs.sureCallback ~= nil then
            self.openArgs.sureCallback()
        end
        self.model:CloseConfirm()
    end)
end

function SellConfirmWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

-- openArgs = {
--     title = "",
--     items = {
--         {base_id = 11111, num = 1111, singlePrice = 1111}
--     },
--     extra = "",
--     sureCallback = function() end,
--     cancelCallback - function() end,
-- }
function SellConfirmWindow:OnOpen()
    self:Reload()
end

function SellConfirmWindow:Reload()
    self.mainLayout:ReSet()
    self.titleArea:SetActive(false)
    if self.openArgs.title ~= nil and self.openArgs.title ~= "" then
        self.titleMsg:SetData(self.openArgs.title)
        local size = self.titleMsg.contentRect.sizeDelta
        self.titleMsg.contentRect.anchoredPosition = Vector2(-size.x / 2, 0)
        self.titleArea.transform.sizeDelta = Vector2(size.x, size.y + 5)
        self.mainLayout:AddCell(self.titleArea)
    end

    self.MaskCon.gameObject:SetActive(false)
    local datalist = self.openArgs.items or {}
    local tab = nil
    self.layout:ReSet()
    for i,v in ipairs(datalist) do
        tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.Item)
            tab.transform = tab.gameObject.transform
            tab.nameText = tab.transform:Find("TxtName"):GetComponent(Text)
            tab.levText = tab.transform:Find("TxtLev"):GetComponent(Text)
            tab.classesText = tab.transform:Find("TxtClasses"):GetComponent(Text)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)

        tab.nameText.text = v.str1
        tab.classesText.text = v.str2
        tab.levText.text = v.str3
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(true)
    end
    if #datalist > 0 then
        self.mainLayout:AddCell(self.MaskCon.gameObject)
    end

    self.extraArea:SetActive(false)
    if self.openArgs.extra ~= nil and self.openArgs.extra ~= "" then
        self.extraMsg:SetData(self.openArgs.extra)
        local size = self.extraMsg.contentRect.sizeDelta
        self.extraMsg.contentRect.anchoredPosition = Vector2(-size.x / 2, 0)
        self.extraArea.transform.sizeDelta = Vector2(size.x, size.y)
        self.mainLayout:AddCell(self.extraArea)
    end

    self.arrow.transform.anchoredPosition = Vector2(0, self.MaskCon.transform.anchoredPosition.y - self.MaskCon.transform.sizeDelta.y)
    self.arrow:SetActive(self.layout.panelRect.sizeDelta.y > self.MaskCon.transform.sizeDelta.y)

    self.mainLayout:AddCell(self.btnArea)
end

function SellConfirmWindow:OnHide()
end
