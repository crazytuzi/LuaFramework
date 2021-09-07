-- @author 黄耀聪
-- @date 2017年3月21日

CustomGrid = CustomGrid or BaseClass(BasePanel)

function CustomGrid:__init(parent, setting)
    self.parent = parent
    self.name = "CustomGrid"

    setting = setting or {}

    self.resList = {
        {file = AssetConfig.custom_grid, type = AssetType.Main}
    }

    -- 初始化完毕事件
    self.onInitCompleted = EventLib.New()
    self.onDragEnd = EventLib.New()

    self.itemList = {}

    -- 需要显示的数据，单个格式为{itemData = ItemData.New(), num = 0, slotSetting}
    self.datalist = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CustomGrid:__delete()
    self.OnHideEvent:Fire()
    if self.onInitCompleted ~= nil then
        self.onInitCompleted:DeleteMe()
        self.onInitCompleted = nil
    end
    if self.onDragEnd ~= nil then
        self.onDragEnd:DeleteMe()
        self.onDragEnd = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v:DeleteMe()
        end
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    self:AssetClearAll()
end

function CustomGrid:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.custom_grid))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.container = t:Find("Container")

    self.tabbedPanel = TabbedPanel.New(self.gameObject, 0, 350, 0.6)
    self.tabbedPanel.MoveEndEvent:AddListener(function(page, direction) self:OnDragEnd(page, direction) end)
end

function CustomGrid:OnInitCompleted()
    self.onInitCompleted:Fire()
    self.OnOpenEvent:Fire()
end

function CustomGrid:OnOpen()
    self:RemoveListeners()
end

function CustomGrid:OnHide()
    self:RemoveListeners()
end

function CustomGrid:RemoveListeners()
end

-- 玩家物品数据更新，背包仓库什么的
-- 还没想到怎么接
function CustomGrid:ReloadFromPlayer()
end

-- 外部更新接口
function CustomGrid:Reload(datalist)
    self.datalist = datalist
    if datalist == nil then
        self:ReloadFromPlayer()
    else
        self:ReloadFromCustom()
    end
end

-- 自定义数据更新
function CustomGrid:ReloadFromCustom()
    local datalist = self.datalist or {}
    for i,data in ipairs(datalist) do
        local slot = self.itemList[i] or self:AddCell()
        slot:SetAll(data.itemData, data.slotSetting or {inbag = false, nobutton = true})
        if data.num ~= nil then
            slot:SetNum(data.num)
        end
        slot.gameObject:SetActive(true)
    end

    local c = #datalist
    for i= c + 1, #self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    if c == 0 then c = 1 end
    self.container.sizeDelta = Vector2(350 * math.ceil(c / 25), 324)
    self.tabbedPanel:SetPageCount(math.ceil(c / 25))
end

-- 增加一个itemslot
function CustomGrid:AddCell(pos)
    local count = nil
    if pos == nil then
        count = #self.itemList
    else
        count = pos - 1
    end
    local tab = ItemSlot.New()
    tab.transform:SetParent(self.container)
    tab.transform.localScale = Vector3.one
    tab.transform.anchorMax = Vector2(0,1)
    tab.transform.anchorMin = Vector2(0,1)
    tab.transform.pivot = Vector2(0,1)

    -- 纵坐标只是为了校准位置加上1
    tab.transform.anchoredPosition = Vector2(350 * math.floor(count / 25) + 70 * (count % 5), 1 - 65 * math.floor((count % 25) / 5))
    self.itemList[count + 1] = tab

    return tab
end

-- 滚动停止
function CustomGrid:OnDragEnd(page, direction)
    self.onDragEnd:Fire(page, direction)
end

-- 翻页
function CustomGrid:GotoPage(index)
    self.tabbedPanel:TurePage(index)
end
