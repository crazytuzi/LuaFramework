-- 可以指定在容器中是否对控件进行水平或者垂直放置
LuaBoxLayout = LuaBoxLayout or BaseClass(BaseLayout)

function LuaBoxLayout:__init(panel, setting)
    self.axis = setting.axis or BoxLayoutAxis.X
    self.border = setting.border or 0
    self.spacing = setting.cspacing or 5
    self.Left = setting.Left
    self.Top = setting.Top
    self.Dir = setting.Dir or 0
    self.panel = panel
    self.panelRect = self.panel:GetComponent(RectTransform)
    self.cellList = {}
    self.contentSize = 0

    self.scrollRect = setting.scrollRect or nil -- 传入scrollrect的Transform将启用自动隐藏
    if self.scrollRect ~= nil then
        local scrollSize = self.scrollRect.sizeDelta
        self.scrollRect:GetComponent(ScrollRect).onValueChanged:AddListener(
            function(value)
                self:OnScroll(scrollSize, value)
            end)
    end
end

function LuaBoxLayout:__delete()
end

function LuaBoxLayout:AddCell(cell)
    -- local id = cell.gameObject:GetInstanceID()

    local rect = cell:GetComponent(RectTransform)
    rect:SetParent(self.panelRect)
    cell.transform.localScale = Vector3.one
    cell:SetActive(true)
    self:SetCellAnchor(rect)
    local count = #self.cellList
    table.insert(self.cellList, cell)
    self:SetPosition(rect, count + 1)
end

function LuaBoxLayout:SetCellAnchor(rect)
    -- 左中
    if self.axis == BoxLayoutAxis.X then
        if self.Dir == BoxLayoutDir.Left then
            rect.anchorMin = Vector2 (1, 0.5)
            rect.anchorMax = Vector2 (1, 0.5)
            rect.pivot = Vector2 (1, 0.5);
        else
            rect.anchorMin = Vector2 (0, 0.5)
            rect.anchorMax = Vector2 (0, 0.5)
            rect.pivot = Vector2 (0, 0.5);
        end
    else
    -- 上中
        if self.Dir == BoxLayoutDir.Top then
            rect.anchorMin = Vector2 (0.5, 0)
            rect.anchorMax = Vector2 (0.5, 0)
            rect.pivot = Vector2 (0.5, 0);
        else
            rect.anchorMin = Vector2 (0.5, 1)
            rect.anchorMax = Vector2 (0.5, 1)
            rect.pivot = Vector2 (0.5, 1);
        end
    end
end

-- 设置位置，index从1开始
function LuaBoxLayout:SetPosition(rect, index)
    local sizeDelta = rect.sizeDelta
    local cellSize = 0
    if self.axis == BoxLayoutAxis.X then
        cellSize = sizeDelta.x
        rect.anchoredPosition3D = Vector2(self.contentSize + self.spacing, 0)
        self.contentSize = self.contentSize + cellSize + self.border
        if self.Left and index == 1 then
            self.contentSize = self.contentSize + self.Left
        end
        self.panelRect:SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, self.contentSize + self.spacing)
    else
        cellSize = sizeDelta.y
        if self.Top and index ~= 1 then
            self.contentSize = self.contentSize - self.Top
        end
        local x = self.Left == nil and 0 or (self.Left - (self.panelRect.sizeDelta.x/2 - sizeDelta.x/2))
        local y = self.Top == nil and (0 - self.contentSize - self.spacing) or (0 - self.contentSize - self.spacing - self.Top)
        if self.Dir == BoxLayoutDir.Top then
            y = -y - self.Top
        end
        rect.anchoredPosition3D = Vector2(x, y)
        self.contentSize = self.contentSize + cellSize + self.border
        if self.Top then
            self.contentSize = self.contentSize + self.Top
        end
        self.panelRect:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, self.contentSize + self.spacing)
    end
end

function LuaBoxLayout:ReSet()
    self.cellList = {}
    self.contentSize = 0
end

function LuaBoxLayout:ReSize()
    self.cellList = {}
    self.contentSize = 0
    local childnum = self.panelRect.childCount
    local childlist = {}
    for i = 0, childnum-1 do
        local child = self.panelRect:GetChild(i)
        table.insert(childlist, child.gameObject)
    end
    for i,v in ipairs(childlist) do
        self:AddCell(v)
    end
end

function LuaBoxLayout:OnScroll(scrollSizeDelta, value)
    if self.axis == BoxLayoutAxis.X then
        local contentSize = self.panelRect.sizeDelta.x
        local Left = (contentSize - scrollSizeDelta.x) * (1 - value.x)
        local Right = scrollSizeDelta.x + Left
        if Right > contentSize + self.spacing then
            Right = contentSize + self.spacing
        end
        for i,child in ipairs(self.cellList) do
            local show = child.transform.anchoredPosition3D.x+child.transform.sizeDelta.x > Left and child.transform.anchoredPosition3D.x < Right
            child:SetActive(show)
        end
    else
        local contentSize = self.panelRect.sizeDelta.y
        local top = (contentSize - scrollSizeDelta.y) * (1 - value.y)
        local bot = scrollSizeDelta.y + top
        if bot > contentSize + self.spacing then
            bot = contentSize + self.spacing
        end
        if self.Dir == BoxLayoutDir.Top then
            bot = (contentSize - scrollSizeDelta.y) * value.y
            top = scrollSizeDelta.y + bot
            for i,child in ipairs(self.cellList) do
                local show = child.transform.anchoredPosition3D.y < top and child.transform.anchoredPosition3D.y+child.transform.sizeDelta.y > bot
                child:SetActive(show)
            end
        else
            for i,child in ipairs(self.cellList) do
                local show = -child.transform.anchoredPosition3D.y+child.transform.sizeDelta.y > top and -child.transform.anchoredPosition3D.y < bot
                child:SetActive(show)
            end
        end
    end
end