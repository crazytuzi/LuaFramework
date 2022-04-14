LoopScrollView = LoopScrollView or class("LoopScrollView")
local LoopScrollView = LoopScrollView


local example =
{
    arrangement = "Vertical",			--Vertical竖排，Horizontal横排
    maxPerLine = 5,						--每排最大数量
    spacing = {x = 0, y = 0},   		--间距
    cellSize = {x = 108, y = 108},		--格子大小
    itemClass = BaseItem,			--item的class
    itemData = {},						--显示数据(数组)
    viewNumber = nil,                   --一屏显示列数
    scrollView = nil,
    content = nil,                      --ScrollView下content
}

function LoopScrollView:ctor(data, ...)
    self.data = data
    self.args = {...}
    self.transform = self.data.scrollView.transform
    self.rect = GetRectTransform(self.data.scrollView)
    self.content = GetRectTransform(self.data.content)
    self.scrollRect = GetScrollRect(self.data.scrollView)

    self:InitData()
    --self:AddEvent()
end

function LoopScrollView:InitData()
    --最多显示数量
    self.number = {x = self.data.maxPerLine,y = self.data.maxPerLine}
    if self.data.arrangement == "Vertical" then
        if self.data.viewNumber ~= nil then
            self.number.y = self.data.viewNumber
        else
            self.number.y = math.ceil((self.rect.sizeDelta.y - self.data.cellSize.y) / (self.data.cellSize.y + self.data.spacing.y)) + 1
        end
        self.viewCount = (self.number.y + 1) * self.number.x
    elseif self.data.arrangement == "Horizontal" then
        if self.data.viewNumber ~= nil then
            self.number.x = self.data.viewNumber
        else
            self.number.x = math.ceil((self.rect.sizeDelta.x - self.data.cellSize.x) / (self.data.cellSize.x + self.data.spacing.x)) + 1
        end
        self.viewCount = (self.number.x + 1) * self.number.y
    end

    self.itemDict = {}				-- 所有显示的格子
    self.disableList = {}           -- 未显示出来的itemClass
    self.arrange = -99999
    self.UpdateData = function()
        local arrange = self:GetArrangeNumber()
        if self.arrange ~= arrange then
            self.arrange = arrange
            local startIndex = arrange * self.number.x + 1
            if self.data.arrangement == "Horizontal" then
                startIndex = arrange * self.number.y + 1
            end
            local endIndex = startIndex + self.viewCount - 1
            endIndex = math.min(endIndex, #self.data.itemData)
            for index, itemClass in pairs(self.itemDict) do
                if index > endIndex or index < startIndex then
                   -- itemClass:OnDisable()
                    itemClass:SetVisible(false)
                    self.itemDict[index] = nil
                    self:BackPool(itemClass)
                end
            end
            startIndex = math.max(1, startIndex)
            if startIndex > endIndex then
                return
            end
            for i = startIndex, endIndex do
                if self.itemDict[i] == nil then
                    local itemClass = self:GetPool()
                   -- itemClass.transform.localPosition = self:GetPosition(i)
                    local pos = self:GetPosition(i)
                    itemClass:SetPosition(pos.x,pos.y)
                   -- itemClass:OnEnable(self.data.itemData[i])
                    itemClass:SetVisible(true)
                    itemClass:SetData(self.data.itemData[i],self.args)
                    self.itemDict[i] = itemClass
                end
            end
        end
    end

    self.scrollRect.onValueChanged:AddListener(self.UpdateData)
    self.UpdateData()
    self:SetDataCount()
end



--获取当前显示第几排（0开始）
function LoopScrollView:GetArrangeNumber()
    if self.data.arrangement == "Horizontal" then
        local posX = self.content.localPosition.x
        return math.floor((posX) / -(self.data.cellSize.x + self.data.spacing.x))
    end
    if self.data.arrangement == "Vertical" then
        local posY = self.content.localPosition.y
        return math.floor((posY) / (self.data.cellSize.y + self.data.spacing.y))
    end
    return 0
end


--交回(itemClass)
function LoopScrollView:BackPool(itemClass)
    itemClass:SetVisible(false)
    table.insert(self.disableList, itemClass)
end


--获取(itemClass)
function LoopScrollView:GetPool()
    local itemClass = nil
    if #self.disableList > 0 then
        itemClass = self.disableList[1]
        itemClass:SetVisible(true)
        table.remove(self.disableList, 1)
    else
        ----clone的还没写

        itemClass = self.data.itemClass(self.content.transform,self.args)
       -- local obj = itemClass.gameObject
        itemClass:SetVisible(true)
    end
    return itemClass
end



function LoopScrollView:GetPosition(i)
    i = i - 1
    if self.data.arrangement == "Horizontal" then
        return Vector3((self.data.spacing.x + self.data.cellSize.x) * math.floor(i / self.data.maxPerLine), -(self.data.cellSize.y + self.data.spacing.y) * (i % self.data.maxPerLine), 0)
    end
    if self.data.arrangement == "Vertical" then
        return Vector3((i % self.data.maxPerLine) * (self.data.spacing.x + self.data.cellSize.x), -(self.data.cellSize.y + self.data.spacing.y) * math.floor(i / self.data.maxPerLine), 0)
    end
    return Vector3.zero
end

--根据总数量设置底板大小
function LoopScrollView:SetDataCount()
    local lineCount = math.ceil(#self.data.itemData / self.data.maxPerLine)
    local width = self.content.sizeDelta.x
    local height = self.content.sizeDelta.y
    if self.data.arrangement == "Horizontal" then
        width = self.data.cellSize.x * lineCount + self.data.spacing.x * (lineCount - 1)
        width = math.max(width, self.rect.sizeDelta.x)
    end
    if self.data.arrangement == "Vertical" then
        height = self.data.cellSize.y * lineCount + self.data.spacing.y * (lineCount - 1)
        height = math.max(height, self.rect.sizeDelta.y)
    end
    self.content.sizeDelta = Vector2(width, height)
end

------------------刷新相关
--重置坐标
function LoopScrollView:ResetPos()
    self.content.localPosition = Vector3.zero
    self.UpdateData()
end



--itemData替换时调用
function LoopScrollView:OnUpdateData(itemData)
    self.data.itemData = itemData
    local arrange = self:GetArrangeNumber()
    self.arrange = arrange
    local startIndex = arrange * self.number.x + 1
    if self.data.arrangement == "Horizontal" then startIndex = arrange * self.number.y + 1 end
    local endIndex = startIndex + self.viewCount - 1
    endIndex = math.min(endIndex, #self.data.itemData)
    startIndex = math.max(1, startIndex)

    for index, itemClass in pairs(self.itemDict) do
        if index >= startIndex then
            itemClass:OnDisable()
            self.itemDict[index] = nil
            self:BackPool(itemClass)
        end
    end
    self:SetDataCount()
    if startIndex > endIndex then return end
    for i = startIndex, endIndex do
        if self.itemDict[i] == nil then
            local itemClass = self:GetPool()
           -- itemClass.transform.localPosition = self:GetPosition(i)
            local pos = self:GetPosition(i)
            itemClass:SetPosition(pos.x,pos.y)
            itemClass:OnEnable(self.data.itemData[i])
            self.itemDict[i] = itemClass
        end
    end
end


--删除

function LoopScrollView:destroy()
    for _, item in pairs(self.itemDict) do
        item:destroy()
    end
    self.itemDict = {}
    for _, item in pairs(self.disableList) do
        item:destroy()
    end
    self.disableList = {}
end




