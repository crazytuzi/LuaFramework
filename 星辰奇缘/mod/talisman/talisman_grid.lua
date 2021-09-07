TalismanGrid = TalismanGrid or BaseClass()

function TalismanGrid:__init(gameObject, assetWrapper,parent)
    self.parent = parent
    self.gameObject = gameObject.gameObject
    self.assetWrapper = assetWrapper
    self.name = "TalismanGrid"

    self.clickCallback = function(data) self:OnClickItem(data) end
    self.pageList = {}

    self:InitPanel()
    self.step = 1
    self.guideEffect = nil
end

function TalismanGrid:__delete()
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    self.gameObject = nil
end

function TalismanGrid:InitPanel()
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    local t = self.transform
    self.container = t:Find("Container")
    self.tabbedPanel = TabbedPanel.New(self.gameObject, 0, 328, 0.6)
    self.tabbedPanel.MoveEndEvent:AddListener(function(page) self:OnDragEnd(page) end)

    for i=1,5 do
        local tab = {}
        tab.transform = self.container:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.items = {}
        for j=1,16 do
            tab.items[j] = TalismanGridItem.New(tab.transform:GetChild(j - 1), self.assetWrapper)
            tab.items[j].clickCallback = self.clickCallback
        end
        self.pageList[i] = tab
    end
end

function TalismanGrid:OnClickItem(data)
    self.step = 2
    self.parent:CheckGuidePoint()
    TipsManager.Instance:ShowTalisman({itemData = data})

end

function TalismanGrid:SetData(datalist, pageCount)
    if math.ceil(#datalist / 16) > pageCount then
        pageCount = math.ceil(#datalist / 16)
    end

    for i,page in ipairs(self.pageList) do
        page.gameObject:SetActive(i <= pageCount)
        for j,item in ipairs(page.items) do
            item:SetData(datalist[(i - 1) * 16 + j], (i - 1) * 16 + j)
        end
    end
    self.tabbedPanel:SetPageCount(pageCount)
    self.container.sizeDelta = Vector2(328 * pageCount, 324)
end

function TalismanGrid:TurnPage(index)
    self.tabbedPanel:TurnPage(index)
end

function TalismanGrid:GetPage()
    return self.tabbedPanel.pageCount
end

function TalismanGrid:OnDragEnd(page)
    if self.onDragEndListener ~= nil then
        self.onDragEndListener(page)
    end
end

function TalismanGrid:CheckGuidePoint()
    -- TipsManager.Instance:ShowGuide({gameObject = self.pageList[1].items[1].gameObject, data = TI18N("装备上宝物能让你更加强大"), forward = TipsEumn.Forward.Right})
    -- if self.guideEffect == nil then
    --     self.guideEffect = BibleRewardPanel.ShowEffect(20103,self.pageList[1].items[1].transform,Vector3(0.9,0.9,1), Vector3(0,0,-400))
    -- end
    -- self.guideEffect:SetActive(true)
end

function TalismanGrid:HideGuideEffect()
    -- if self.guideEffect ~= nil then
    --     self.guideEffect:SetActive(false)
    -- end
end
