IngotCrashWatch = IngotCrashWatch or BaseClass(BaseWindow)

function IngotCrashWatch:__init(model)
    self.model = model
    self.name = "IngotCrashWatch"
    self.windowId = WindowConfig.WinID.ingot_crash_watch

    self.resList = {
        {file = AssetConfig.ingotcrash_watch, type = AssetType.Main}
    }

    self.itemList = {}

    self.updateListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashWatch:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self:AssetClearAll()
end

function IngotCrashWatch:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_watch))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local main = t:Find("Main")

    self.cloner = main:Find("Scroll/Cloner").gameObject
    self.scroll = main:Find("Scroll"):GetComponent(ScrollRect)
    self.nothing = main:Find("Nothing").gameObject

    local layout = LuaBoxLayout.New(main:Find("Scroll/Container"), {border = 0, cspacing = 0, axis = BoxLayoutAxis.Y})

    self.setting_data = {
       item_list = self.itemList
       ,data_list = {}
       ,item_con = layout.panel
       ,single_item_height = self.cloner.transform.sizeDelta.y
       ,item_con_last_y = layout.panelRect.anchoredPosition.y
       ,scroll_con_height = self.scroll.transform.sizeDelta.y
       ,item_con_height = 0
       ,scroll_change_count = 0
       ,data_head_index = 0
       ,data_tail_index = 0
       ,item_head_index = 1
       ,item_tail_index = 0
    }

    for i=1,10 do
        self.itemList[i] = IngotCrashWatchItem.New(self.model, GameObject.Instantiate(self.cloner))
        layout:AddCell(self.itemList[i].gameObject)
        self.itemList[i].watchCallback = function() WindowManager.Instance:CloseWindow(self, false) end
    end
    layout:DeleteMe()

    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.button = main:Find("Button"):GetComponent(Button)

    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.button.onClick:AddListener(function() self:OnRandomWatch() end)

    self.cloner:SetActive(false)
end

function IngotCrashWatch:OnOpen()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateWatch:AddListener(self.updateListener)

    IngotCrashManager.Instance:send20022()
    self:Reload()
end

function IngotCrashWatch:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashWatch:OnHide()
    self:RemoveListeners()
end

function IngotCrashWatch:RemoveListeners()
    IngotCrashManager.Instance.onUpdateWatch:RemoveListener(self.updateListener)
end

function IngotCrashWatch:Reload()
    self.setting_data.data_list = self.model.watchList or {}
    BaseUtils.refresh_circular_list(self.setting_data)

    self.nothing:SetActive(#self.setting_data.data_list == 0)
end

function IngotCrashWatch:OnRandomWatch()
    WindowManager.Instance:CloseWindow(self, false)
    IngotCrashManager.Instance:send20025()
end
