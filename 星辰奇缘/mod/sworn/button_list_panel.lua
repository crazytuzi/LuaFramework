-- @author 黄耀聪
-- @date 2016年11月7日

ButtonListPanel = ButtonListPanel or BaseClass(BasePanel)

function ButtonListPanel:__init(parent)
    self.parent = parent
    self.name = "ButtonListPanel"

    self.resList = {
        {file = AssetConfig.button_list_panel, type = AssetType.Main},
    }

    self.buttonList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ButtonListPanel:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ButtonListPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.button_list_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    self.layout = LuaBoxLayout.New(main:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    self.cloner = main:Find("Scroll/Cloner").gameObject
    self.main = main

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.parent:CloseButtonList() end)
end

function ButtonListPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ButtonListPanel:OnOpen()
    self:RemoveListeners()

    self.main.anchoredPosition = self.openArgs.pos
    self:ReloadButtonList(self.openArgs.btnList)
end

function ButtonListPanel:OnHide()
    self:RemoveListeners()
end

function ButtonListPanel:RemoveListeners()
end

-- data = {
--     {label = "", callback = function() end}.
-- }
function ButtonListPanel:ReloadButtonList(data)
    self.layout:ReSet()
    for i,v in ipairs(data) do
        if self.buttonList[i] == nil then
            local tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.button = tab.transform:Find("Button"):GetComponent(Button)
            tab.label = tab.transform:Find("Button/Text"):GetComponent(Text)
            self.buttonList[i] = tab
        end
        self.buttonList[i].button.onClick:RemoveAllListeners()
        self.buttonList[i].label.text = v.label
        if v.callback ~= nil then
            self.buttonList[i].button.onClick:AddListener(v.callback)
        end
        self.layout:AddCell(self.buttonList[i].gameObject)
    end
    self.cloner:SetActive(false)
    local h = #data * 50 + 24
    if h > 190 then
        h = 190
    end
    self.main.sizeDelta = Vector2(150, h)
end
