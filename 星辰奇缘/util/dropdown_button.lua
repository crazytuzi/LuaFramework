-- 下拉列表按钮
DropDownButton = DropDownButton or BaseClass()

-- setting:
--     tab : 标签列表 格式 {{标签名字1}, {标签名字2}, ...}
--     maskBtn : 自定义遮罩按钮区域

function DropDownButton:__init(gameObject, callback, setting)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.MainButton = self.transform:Find("MainButton"):GetComponent(Button)
    self.Label = self.transform:Find("Label"):GetComponent(Text)
    self.ArrowBtn = self.transform:Find("ArrowBtn")
    self.Arrow = self.transform:Find("ArrowBtn/Arrow")
    self.bgMask = self.transform:Find("bgMask"):GetComponent(Button)
    self.List = self.transform:Find("List").gameObject
    self.MaskScroll = self.transform:Find("List/MaskScroll")
    self.ListCon = self.transform:Find("List/MaskScroll/ListCon")
    self.ItemButton = self.transform:Find("List/MaskScroll/ListCon/Button").gameObject
    self.I18NText = self.transform:Find("List/MaskScroll/ListCon/Button/I18NText"):GetComponent(Text)
    self.bgMask.onClick:AddListener(function()
        self:HideList()
    end)

    self.MainButton.onClick:AddListener(function()
        if self.listShow then
            self:HideList()
        else
            self:ShowList()
        end
    end)

    self.listShow = false
    self.tab = {}
    self.ItemList = {}
    if setting.tab ~= nil then
        self.tab = setting.tab
    end
    if callback ~= nil then
        self.callback = callback
    end
    if setting.autoselect ~= nil then
        self.autoselect = setting.autoselect
    else
        self.autoselect = true
    end
    if not BaseUtils.isnull(setting.maskBtn) then
        setting.maskBtn.onClick:AddListener(function()
            if self.listShow then
                self:HideList()
            else
                self:ShowList()
            end
        end)
    end
end

function DropDownButton:Init()
    self:RefreshList()
    if self.autoselect == true then
        self:ChangeTab(1)
        -- self.Label.text = tostring(self.tab[1])
    end
    self:HideList()
end

function DropDownButton:ShowList()
    self.listShow = true
    self.bgMask.gameObject:SetActive(true)
    self.Arrow.transform.localScale = Vector3(1, -1, 1)
    self.List:SetActive(true)
end

function DropDownButton:HideList()
    self.listShow = false
    self.bgMask.gameObject:SetActive(false)
    self.Arrow.transform.localScale = Vector3(1, 1, 1)
    self.List:SetActive(false)
end

function DropDownButton:RefreshList()
    for k,v in pairs(self.ItemList) do
        if not BaseUtils.isnull(v) then
            GameObject.DestroyImmediate(v.gameObject)
        end
    end
    self.Listlayout = LuaBoxLayout.New(self.ListCon.gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    for i,v in ipairs(self.tab) do
        local item = GameObject.Instantiate(self.ItemButton)
        item.transform:Find("I18NText"):GetComponent(Text).text = v
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self:ChangeTab(i)
        end)
        self.Listlayout:AddCell(item)
    end
end

function DropDownButton:ChangeTab(index)
    if self.callback ~= nil then
        self.callback(index)
    end
    self.Label.text = tostring(self.tab[index])
    self:HideList()
end