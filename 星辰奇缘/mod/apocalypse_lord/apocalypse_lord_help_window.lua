-- @author 黄耀聪
-- @date 2016年8月24日

ApocalypseLordHelpWindow = ApocalypseLordHelpWindow or BaseClass(BaseWindow)

function ApocalypseLordHelpWindow:__init(model)
    self.model = model
    self.name = "ApocalypseLordHelpWindow"
    self.mgr = ApocalypseLordManager.Instance
    self.windowid = WindowConfig.WinID.ApocalypseLord_help_window

    self.resList = {
        {file = AssetConfig.dungeon_help_window, type = AssetType.Main},
    }

    self.itemData = {
        {21098, 1},
        {90007, 20},
    }

    self.itemList = {}
    self.key = 1
    self.descFormat = TI18N("天启预选赛帮助他人通关可获奖励，每日限一次(<color='#00ff00'>%s</color>/1)")
    self.reloadListener = function() self:ReloadTimes() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ApocalypseLordHelpWindow:__delete()
    for i,v in ipairs(self.itemList) do
        v.slot:DeleteMe()
        v.slot = nil
    end
    self.itemList = nil

    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ApocalypseLordHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dungeon_help_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main").anchoredPosition = Vector2(0, 0)

    self.closeBtn = t:Find("Main/Close"):GetComponent(Button)
    self.titleText = t:Find("Main/Title"):GetComponent(Text)
    self.descText = t:Find("Main/Bg/Title"):GetComponent(Text)

    self.container = t:Find("Main/Bg/Scroll/Container")
    self.scrollRect = self.container.parent
    self.cloner = t:Find("Main/Bg/Scroll/Item").gameObject

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0, border = 26})
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.cloner:SetActive(false)
end

function ApocalypseLordHelpWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ApocalypseLordHelpWindow:OnOpen()
    self:RemoveListeners()
    self.mgr.OnUpdateHelpGet:AddListener(self.reloadListener)

    self:ReloadTimes()
    self:ReloadItems()
end

function ApocalypseLordHelpWindow:OnHide()
    self:RemoveListeners()
end

function ApocalypseLordHelpWindow:RemoveListeners()
    self.mgr.OnUpdateHelpGet:RemoveListener(self.reloadListener)
end

function ApocalypseLordHelpWindow:ReloadTimes()
    -- local datalist = self.mgr.extraInfoDic[self.key] or {}
    -- local num = 0
    -- local currdungeonID = self.mgr.currdungeonID
    -- if SceneManager.Instance:CurrentMapId() == 42000 then
    --     currdungeonID = 10085
    -- end
    -- for _,v in ipairs(datalist) do
    --     if v ~= nil then
    --         if v.val_1 == currdungeonID then
    --             num = v.val_2 or 0
    --             break
    --         end
    --     end
    -- end
    -- if num > 4 then num = 4 end
    local num = 0
    num = self.mgr.model.helpGet
    self.descText.text = string.format(self.descFormat, tostring(num))
end

function ApocalypseLordHelpWindow:ReloadItems()
    self.layout:ReSet()
    for i,v in ipairs(self.itemData) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.cloner)
            tab.obj.name = tostring(i)
            tab.transform = tab.obj.transform
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            NumberpadPanel.AddUIChild(tab.obj, tab.slot.gameObject)
            self.itemList[i] = tab
        end
        tab.data:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        tab.slot:SetNum(v[2])
        self.layout:AddCell(tab.obj)
    end
    for i=#self.itemData + 1, #self.itemList do
        self.itemList[i].obj:SetActive(false)
    end

    local num = #self.itemData
    if num > 4 then
        num = 4
    end
    self.scrollRect.anchoredPosition = Vector2(0, -136)
    self.scrollRect.sizeDelta = Vector2(64 * num + 26 * (num - 1), 64)
end

