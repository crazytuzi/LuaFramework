-- 拖动翻页
-- 负责移动container的逻辑和触发翻页完成事件
-- 业务模块根据翻页事件来动态填充数据，一般是预先填充后一页的数据
-- 如果页数比较少，可以一次性创建完
-- @anthor huangyq

TabbedQuickPanel = TabbedQuickPanel or BaseClass()

function TabbedQuickPanel:__init(panel, pageCount, perWidth)
    self.panel = panel
    self.container = panel.transform:FindChild("Container").gameObject
    self.scrollbar = panel.transform:FindChild("Scrollbar"):GetComponent(Scrollbar)
    self.rectTransform = self.container:GetComponent(RectTransform)

    self.width = self.rectTransform.rect.width
    self.height = self.rectTransform.rect.height

    self:SetPageCount(pageCount)
    self.perWidth = perWidth
    self.currentPage = 1

    self.scrollbar.onValueChanged:AddListener(function(value) self:OnValueChanged(value) end)
    self.scrollbarValue = 0
    self.direction = LuaDirection.Left

    self.pageController  = self.panel:AddComponent(PageTabbedController)
    self.pageController.onEndDragEvent:AddListener(function() self:OnEndDragEvent() end)
    self.pageController.onDownEvent:AddListener(function() self:OnDownEvent() end)
    self.pageController.onUpEvent:AddListener(function() self:OnUpEvent() end)

    self.MoveEndEvent = EventLib.New()

    self.ltDescr = nil
end

function TabbedQuickPanel:__delete()
    if self.ltDescr ~= nil then
        Tween.Instance:Cancel(self.ltDescr)
        self.ltDescr = nil
    end
    self.tweenEdgeList = nil
    self.MoveEndEvent:DeleteMe()
    self.MoveEndEvent = nil
end

-- 如果总页数会变，就要重新修改这个值
function TabbedQuickPanel:SetPageCount(pageCount)
    self.pageCount = pageCount

    if self.tweenEdgeList == nil then
        self.tweenEdgeList = {}
    end

    if self.pageCount ~= nil and self.pageCount > 1 then
        for i=1,pageCount + 1 do
            self.tweenEdgeList[i] = (i - 0.5) / (self.pageCount - 1)
        end
    end
end

function TabbedQuickPanel:OnValueChanged(value)
    if self.pageCount ~= nil and self.pageCount > 1 then
        local oldValue = self.scrollbarValue
        local page = nil
        self.scrollbarValue = value
        if oldValue > value then
            self.direction = LuaDirection.Right
            page = math.ceil(value * (self.pageCount - 1) - 0.5) + 1
            if value < self.tweenEdgeList[page] and self.tweenEdgeList[page] <= oldValue then
                self.currentPage = page
                self.MoveEndEvent:Fire(self.currentPage, self.direction)
            end
        elseif oldValue < value then
            self.direction = LuaDirection.Left
            page = math.floor(oldValue * (self.pageCount - 1) + 0.5) + 1
            if value >= self.tweenEdgeList[page] and self.tweenEdgeList[page] > oldValue then
                self.currentPage = page + 1
                self.MoveEndEvent:Fire(self.currentPage, self.direction)
            end
        end
    end
end

function TabbedQuickPanel:OnEndDragEvent()
    if self.scrollbarValue ~= 0 and self.scrollbarValue ~= 1 then
        if self.ltDescr ~= nil then
            Tween.Instance:Cancel(self.ltDescr)
            self.ltDescr = nil
        end
        self.ltDescr = Tween.Instance:MoveX(self.rectTransform, self:GetTargetValue(), 0.6, function() self:OnMoveEnd() end, LeanTweenType.easeOutQuint).id
    end
end

function TabbedQuickPanel:OnDownEvent()
    if self.ltDescr ~= nil then
        Tween.Instance:Cancel(self.ltDescr)
        self.ltDescr = nil
    end
end

function TabbedQuickPanel:OnUpEvent()
    if self.scrollbarValue ~= 0 and self.scrollbarValue ~= 1 then
        if self.ltDescr ~= nil then
            Tween.Instance:Cancel(self.ltDescr)
            self.ltDescr = nil
        end
        self.ltDescr = Tween.Instance:MoveX(self.rectTransform, self:GetTargetValue(), 0.6, function() self:OnMoveEnd() end, LeanTweenType.easeOutQuint).id
    end
end

function TabbedQuickPanel:GetTargetValue()
    if self.pageCount <= 1 then
        self.currentPage = 1
        return 0
    end
    local aver = 1 / (self.pageCount - 1)
    local averPixel = self.perWidth
    if self.direction == LuaDirection.Left then
        local index = math.ceil(self.scrollbarValue / aver)
        self.currentPage = index + 1
        return 0 - index * averPixel
    else
        local index = math.ceil(self.scrollbarValue / aver)
        self.currentPage = index
        return 0 - (index - 1) * averPixel
    end
end

function TabbedQuickPanel:OnMoveEnd()
    self.ltDescr = nil
    -- self.MoveEndEvent:Fire(self.currentPage, self.direction)
end

-- 翻到指定页
function TabbedQuickPanel:TurnPage(pageIndex)
    if self.ltDescr ~= nil then
        Tween.Instance:Cancel(self.ltDescr)
        self.ltDescr = nil
    end
    self.currentPage = pageIndex
    local offsetX = 0 - (pageIndex - 1) * self.perWidth
    self.ltDescr = Tween.Instance:MoveX(self.rectTransform, offsetX, 0.6, function() self:OnMoveEnd() end, LeanTweenType.easeOutQuint).id
end

function TabbedQuickPanel:GotoPage(pageIndex)
    if self.ltDescr ~= nil then
        Tween.Instance:Cancel(self.ltDescr)
        self.ltDescr = nil
    end
    self.currentPage = pageIndex
    local offsetX = 0 - (pageIndex - 1) * self.perWidth
    self.ltDescr = Tween.Instance:MoveX(self.rectTransform, offsetX, 0, function() self:OnMoveEnd() end, LeanTweenType.easeOutQuint).id
end