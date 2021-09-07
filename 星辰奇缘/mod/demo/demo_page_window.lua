DemoPageWindow = DemoPageWindow or BaseClass(BaseWindow)

function DemoPageWindow:__init(model)
    self.model = model
    self.name = "DemoPageWindow"

    -- 缓存
    -- self.cacheMode = CacheMode.Visible
    -- self.holdTime = 10

    self.resList = {
        {file = AssetConfig.demo_page_window, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.closeBut = nil

    self.tabbedPanel = nil
    self.page1 = nil
    self.page2 = nil
    self.page3 = nil
    self.page1Init = false
    self.page2Init = false
    self.page3Init = false
    self.cloner = nil

    self.gridPage1 = nil
    self.gridPage2 = nil
    self.gridPage3 = nil
end

function DemoPageWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    -- 销毁TabbedPanel
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end

    if self.gridPage1 ~= nil then
        self.gridPage1:DeleteMe()
        self.gridPage1 = nil
    end
    if self.gridPage2 ~= nil then
        self.gridPage2:DeleteMe()
        self.gridPage2 = nil
    end
    if self.gridPage3 ~= nil then
        self.gridPage3:DeleteMe()
        self.gridPage3 = nil
    end
    self:AssetClearAll()
end

function DemoPageWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo_page_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DemoPageWindow"
    self.transform = self.gameObject.transform

    self.closeBut = self.gameObject.transform:FindChild("Window/Close").gameObject
    self.closeBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseButtonClick() end)
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.gridPanel = self.gameObject.transform:FindChild("Window/GridPanel").gameObject
    self.tabbedPanel = TabbedPanel.New(self.gridPanel, 3, 340)
    -- 监控拖拉完成事件
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)
    self.container = self.gridPanel.transform:FindChild("Container").gameObject

    self.cloner = self.container.transform:FindChild("Cloner").gameObject
    -- 这里可以灵活一点，也可以跟BoxLayoutAxis一起使用，不用全部都做在prefab上
    self.page1 = self.container.transform:FindChild("Page1").gameObject
    self.page2 = self.container.transform:FindChild("Page2").gameObject
    self.page3 = self.container.transform:FindChild("Page3").gameObject

    self.setting = {
        column = 5
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 60
        ,cellSizeY = 60
        ,changeSize = false
    }
    self:InitDataPanel(1)
    self:InitDataPanel(2)
end

function DemoPageWindow:OnCloseButtonClick()
    self.model:ClosePageWindow()
end

function DemoPageWindow:OnMoveEnd(currentPage, direction)
    if direction == LuaDirection.Left then
        if (currentPage == 2 or currentPage == 3) and self.page3Init == false then
            self:InitDataPanel(3)
        end
    end
end

function DemoPageWindow:InitDataPanel(index)
    if index == 1 then
        if self.page1Init == false then
            self.gridPage1 = LuaGridLayout.New(self.page1, self.setting)
            for i = 1, 10 do
                local cell = GameObject.Instantiate(self.cloner)
                self.gridPage1:AddCell(cell)
            end
            self.page1Init = true
        end
    elseif index == 2 then
        if self.page2Init == false then
            self.gridPage2 = LuaGridLayout.New(self.page2, self.setting)
            for i = 1, 20 do
                local cell = GameObject.Instantiate(self.cloner)
                self.gridPage2:AddCell(cell)
            end
            self.page2Init = true
        end
    else
        if self.page3Init == false then
            self.gridPage3 = LuaGridLayout.New(self.page3, self.setting)
            for i = 1, 22 do
                local cell = GameObject.Instantiate(self.cloner)
                self.gridPage3:AddCell(cell)
            end
            self.page3Init = true
        end
    end
end

