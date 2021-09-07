-- @author 黄耀聪
-- @date 2016年7月7日

StrategyUploadPanel = StrategyUploadPanel or BaseClass(BasePanel)

function StrategyUploadPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "StrategyUploadPanel"
    self.mgr = StrategyManager.Instance

    self.resList = {
        {file = AssetConfig.strategy_type_panel, type = AssetType.Main},
        {file = AssetConfig.strategy_textures, type = AssetType.Dep},
    }

    local tab = {}
    for _,v in pairs(model.tabData) do
        table.insert(tab, BaseUtils.copytab(v))
    end
    table.sort(tab, function(a,b) return a.index < b.index end)
    self.tabData = tab

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function StrategyUploadPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StrategyUploadPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_type_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.btn = t:GetComponent(Button)
    local main = t:Find("UploadTypeList")
    self.container = main:Find("ScrollLayer/Container")
    self.cloner = main:Find("ScrollLayer/Cloner").gameObject
    self.mainRect = main:GetComponent(RectTransform)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})

    self.btn.onClick:AddListener(function() self.model:CloseTypePanel() end)
end

function StrategyUploadPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StrategyUploadPanel:OnOpen()
    self:RemoveListeners()

    self.layout:ReSet()
    for i,v in ipairs(self.tabData) do
        v.obj = GameObject.Instantiate(self.cloner)
        v.obj.name = tostring(i)
        v.trans = v.obj.transform
        v.trans:Find("Text"):GetComponent(Text).text = v.name
        v.trans:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.strategy_textures, v.icon)
        v.obj:GetComponent(Button).onClick:AddListener(function()
            if self.openArgs.title_id == nil then
                self.mgr:send16602(v.key, self.openArgs.name, self.openArgs.content, self.openArgs.local_id)
            else
                self.mgr:send16608(self.openArgs.title_id, v.key, self.openArgs.name, self.openArgs.content, self.openArgs.local_id)
            end
            self.model:CloseTypePanel()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 1})
        end)
        self.layout:AddCell(v.obj)
    end
    local y = self.layout.panelRect.sizeDelta.y
    if y > 180 then
        y = 180
    end
    self.mainRect.sizeDelta = Vector2(self.mainRect.sizeDelta.x, y + 30)
    self.cloner:SetActive(false)
end

function StrategyUploadPanel:OnHide()
    self:RemoveListeners()
end

function StrategyUploadPanel:RemoveListeners()
end


