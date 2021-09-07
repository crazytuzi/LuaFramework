MultiItemPanel = MultiItemPanel or BaseClass(BasePanel)

function MultiItemPanel:__init(parent)
    self.parent = parent

    self.resList = {
        {file = AssetConfig.multi_item_panel, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.maxWidth = 400
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)
    self.lastTime = 0

    self.msgExtTab = {}
    self.levelList = {}

    self.OnHideEvent:Add(function() end)
    self.OnOpenEvent:Add(function() self:OnOpen() end)

    self.horDirectTab = {
        [LuaDirection.Left] = 0,
        [LuaDirection.Mid] = 1,
        [LuaDirection.Right] = 2,
    }
    self.verDirectTab = {
        [LuaDirection.Top] = 0,
        [LuaDirection.Mid] = 1,
        [LuaDirection.Buttom] = 2,
    }
end

function MultiItemPanel:__delete()
    self.OnHideEvent:Fire()
    if self.levelList ~= nil then
        for _,v in pairs(self.levelList) do
            if v.slotList ~= nil then
                for _,v1 in pairs(v.slotList) do
                    if v1 ~= nil then
                        v1:DeleteMe()
                    end
                end
                v.slotList = nil
            end
            if v.gridLayout ~= nil then
                v.gridLayout:DeleteMe()
            end
        end
        self.levelList = nil
    end
    if self.boxLayout ~= nil then
        self.boxLayout:DeleteMe()
        self.boxLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function MultiItemPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.multi_item_panel))
    self.gameObject.name = "MultiItemPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    local btn = self.transform:Find("Panel"):GetComponent(Button)
    btn.onClick:AddListener(function()
        self:Hiden()
    end)

    self.rect = self.transform:Find("Main"):GetComponent(RectTransform)
    self.scrollRect = self.transform:Find("Main/Scroll"):GetComponent(RectTransform)
    self.cloner = self.transform:Find("Main/Scroll/Cloner").gameObject
    self.itemCloner = self.transform:Find("Main/Scroll/ItemCloner").gameObject
    self.cloner:SetActive(false)
    self.itemCloner:SetActive(false)

    self.transform:Find("Main").sizeDelta = Vector2(600, 380)
    self.width = self.rect.sizeDelta.x
    self.height = self.rect.sizeDelta.y

    self.container = self.transform:Find("Main/Scroll/Container")
    self.boxLayout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 10})

    self.extraText = self.transform:Find("Main/Extra"):GetComponent(Text)
    self.extraRect = self.extraText.gameObject:GetComponent(RectTransform)


    self.scrollHeight = 363
    self.scrollWidth = 560
end

function MultiItemPanel:OnOpen()
    self:UpdateInfo(self.openArgs)
end

-- info = {
--     column = 5,
--     list = {
--         {
--              title = "",
--              items = {
--                  {
--                      base_id = 0000,
--                      num= 00,
--                  }
--               }
--        }
--     }
--     extra = {
--         horDirection = 0,
--         verDirection = 0,
--         context = "",
--     }
-- }

function MultiItemPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MultiItemPanel:UpdateInfo(info)
    -- self:Default()
    if info.column == nil then
        info.column = 6
    end
    self.boxLayout:ReSet()
    local setting = {
        column = info.column
        ,cspacing = 35
        ,rspacing = 10
        ,cellSizeX = 60
        ,cellSizeY = 80
        ,borderTop = 10
        ,borderLeft = 0
    }

    local gridWidth = info.column * setting.cellSizeX + (info.column - 1) * setting.cspacing

    local levelList = info.list
    for i,v in ipairs(levelList) do
        local tab = self.levelList[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.cloner)
            tab.obj.name = tostring(i)
            tab.trans = tab.obj.transform
            tab.titleText = tab.trans:Find("Title"):GetComponent(Text)
            tab.gridLayout = LuaGridLayout.New(tab.trans:Find("Grid"), setting)
            tab.gridLayout.panelRect.sizeDelta = Vector2(gridWidth, 0)
            tab.slotList = {}
            tab.dataList = {}
            tab.itemList = {}
            self.levelList[i] = tab
        end
        tab.titleText.text = v.title
        tab.titleText.transform.sizeDelta = Vector2(math.ceil(tab.titleText.preferredWidth) + 30, 30)
        tab.gridLayout:ReSet()
        for j,item in ipairs(v.items) do
            local slot = tab.slotList[j]
            if slot == nil then
                tab.itemList[j] = {}
                tab.itemList[j].obj = GameObject.Instantiate(self.itemCloner)
                tab.itemList[j].nameText = tab.itemList[j].obj.transform:Find("Name"):GetComponent(Text)
                tab.dataList[j] = ItemData.New()
                slot = ItemSlot.New()
                slot.transform.localScale = Vector3.one
                slot.transform.sizeDelta = Vector2(60, 60)
                tab.slotList[j] = slot
                NumberpadPanel.AddUIChild(tab.itemList[j].obj.transform:Find("Item").gameObject, slot.gameObject)
            end
            tab.dataList[j]:SetBase(DataItem.data_get[item.base_id])
            tab.itemList[j].nameText.text = BaseUtils.string_cut_utf8(DataItem.data_get[item.base_id].name, 5, 4)
            slot:SetAll(tab.dataList[j], {inbag = false, nobutton = true})
            slot:SetNum(item.num)
            tab.gridLayout:AddCell(tab.itemList[j].obj)
        end
        for j=#v.items + 1,#tab.slotList do
            tab.itemList[j].obj:SetActive(false)
        end
        tab.gridLayout.panelRect.anchoredPosition = Vector2(0, -40)
        tab.trans.sizeDelta = Vector2(tab.gridLayout.panelRect.sizeDelta.x, tab.gridLayout.panelRect.sizeDelta.y - tab.gridLayout.panelRect.anchoredPosition.y)

        local one_line_num = #v.items
        if one_line_num > info.column then
            one_line_num = info.column
        end
        tab.gridLayout.panelRect.anchoredPosition = Vector2((gridWidth - one_line_num * tab.gridLayout.cellSizeX - (one_line_num - 1) * tab.gridLayout.cspacing) / 2, -40)
        self.boxLayout:AddCell(tab.obj)
    end

    local y = self.boxLayout.panelRect.sizeDelta.y
    self.boxLayout.panelRect.sizeDelta = Vector2(gridWidth, y + 20)

    for i=#levelList + 1, #self.levelList do
        self.levelList[i].obj:SetActive(false)
    end

    if info.extra ~= nil then
        self.extraRect.gameObject:SetActive(true)
        self.extraText.text = info.extra.context
        self.extraText.alignment = self.verDirectTab[info.extra.verDirection] * 3 + self.horDirectTab[info.extra.horDirection]
        if info.extra.verDirection == LuaDirection.Mid then
            self.extraRect.sizeDelta = Vector2(gridWidth + 25, math.ceil(self.extraText.preferredHeight) + 20)
        else
            self.extraRect.sizeDelta = Vector2(gridWidth + 25, math.ceil(self.extraText.preferredHeight) + 10)
        end
        self.scrollRect.sizeDelta = Vector2(gridWidth + 35, self.scrollHeight - self.extraRect.sizeDelta.y)
    else
        self.extraRect.gameObject:SetActive(false)
        self.scrollRect.sizeDelta = Vector2(gridWidth + 35, self.scrollHeight)
    end

    self.rect.sizeDelta = Vector2(gridWidth + 65, 380)
end
