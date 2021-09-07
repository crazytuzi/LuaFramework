LuaGridLayout = LuaGridLayout or BaseClass(BaseLayout)

function LuaGridLayout:__init(panel, setting)
    self.column = setting.column or 1
    self.bordertop = setting.bordertop or 0
    self.borderleft = setting.borderleft or 0
    self.cspacing = setting.cspacing or 5
    self.rspacing = setting.rspacing or 5
    self.cellSizeX = setting.cellSizeX or 1
    self.cellSizeY = setting.cellSizeY or 1
    if setting.changeSize == nil then
        self.changeSize = true
    else
        self.changeSize = setting.changeSize
    end
    self.panel = panel
    self.panelRect = self.panel:GetComponent(RectTransform)
    self.cellList = {}
    self.allCellList = {}
    self.scrollRect = setting.scrollRect or nil -- 传入scrollrect的Transform将启用自动隐藏
    if self.scrollRect ~= nil then
        local scrollSize = self.scrollRect.sizeDelta
        self.scrollRect:GetComponent(ScrollRect).onValueChanged:AddListener(
            function(value)
                self:OnScroll(scrollSize, value)
            end)
    end
end

function LuaGridLayout:__delete()
    self.panel = nil
    self.panelRect = nil
    self.cellList = nil
end

function LuaGridLayout:Clear()
    for _, cell in ipairs(self.cellList) do
        GameObject.DestroyImmediate(cell)
    end
    self.cellList = {}
end

function LuaGridLayout:AddCell(cell)
    if BaseUtils.is_null(cell) then
        return
    end
    local rect = cell:GetComponent(RectTransform)
    rect:SetParent(self.panelRect)
    cell.transform.localScale = Vector3.one
    cell:SetActive(true)
    self:SetCellAnchor(rect)
    self:SetSize(rect)
    local count = #self.cellList
    table.insert(self.cellList, cell)
    self:SetPosition(rect, count + 1)
end

-- 更新用
function LuaGridLayout:UpdateCellIndex(cell, index)
    self.cellList = self.allCellList
    local rect = cell:GetComponent(RectTransform)
    rect:SetParent(self.panelRect)
    cell.transform.localScale = Vector3.one
    cell:SetActive(true)
    self:SetCellAnchor(rect)
    self:SetSize(rect)
    table.insert(self.cellList, index, cell)
    self.allCellList = self.cellList
    self:SetPosition(rect, index)
end

-- 左上角
function LuaGridLayout:SetCellAnchor(rect)
    rect.anchorMin = Vector2 (0, 1)
    rect.anchorMax = Vector2 (0, 1)
    rect.pivot = Vector2 (0, 1);
end

-- 设置大小
function LuaGridLayout:SetSize(rect)
    rect.sizeDelta = Vector2(self.cellSizeX, self.cellSizeY)
end

-- 设置位置，index从1开始
function LuaGridLayout:SetPosition(rect, index)
    local col = index % self.column
    if col == 0 then
        col = self.column
    end
    local row = math.ceil(index / self.column)
    local x = (col - 1) * self.cellSizeX + (col - 1) * self.cspacing + self.borderleft
    local y = 0 - ((row - 1) * self.cellSizeY + (row - 1) * self.rspacing) - self.bordertop
    rect.anchoredPosition3D = Vector2(x, y)
    -- 换行
    if col == 1 and self.changeSize then
        self.panelRect:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, math.abs(y) + self.rspacing + self.cellSizeY)
    end
end

function LuaGridLayout:ReSet()
    for k,child in pairs(self.cellList) do
        child:SetActive(false)
    end
    self.cellList = {}
end


function LuaGridLayout:OnScroll(scrollSizeDelta, value)
    if self.axis == BoxLayoutAxis.X then
        local contentSize = self.panelRect.sizeDelta.x
        local Left = (contentSize - scrollSizeDelta.x) * (1 - value.x)
        local Right = scrollSizeDelta.x + Left
        if Right > contentSize + self.cspacing then
            Right = contentSize + self.cspacing
        end
        for i,child in ipairs(self.cellList) do
            local show = child.transform.anchoredPosition3D.x+child.transform.sizeDelta.x > Left and child.transform.anchoredPosition3D.x < Right
            child:SetActive(show)
        end
    else
        local contentSize = self.panelRect.sizeDelta.y
        local top = (contentSize - scrollSizeDelta.y) * (1 - value.y)
        local bot = scrollSizeDelta.y + top
        if bot > contentSize + self.cspacing then
            bot = contentSize + self.cspacing
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

--只按列表中的保留位数来调整container大小
function LuaGridLayout:SetSizeForItemNum(num)
    local col = num % self.column
    if col == 1 and self.changeSize then
        self.panelRect:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, math.abs(y) + self.rspacing + self.cellSizeY)
    end
end