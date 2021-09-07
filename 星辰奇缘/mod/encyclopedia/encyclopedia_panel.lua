EncyclopediaPanel = EncyclopediaPanel or BaseClass(BasePanel)

function EncyclopediaPanel:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.Mgr = EncyclopediaManager.Instance
    self.parent = parent
    self.resList = {
        {file = AssetConfig.encyclopedia_panel, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
        {file = AssetConfig.dropicon, type = AssetType.Dep},
        {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.lastSub = 1
    self.mainItemList = {}
    self.subItemList = {}
    self.subpanel = {}
    self.lastSeeItemId = nil

    self.OnOpenEvent:AddListener(function()
        -- local args = self.model.mainModel.openArgs
        -- if args ~= nil and #args == 2 and args[1] == 3 then
        --     self.lastSub = tonumber(args[2])
        -- end
        -- self.lastSub = self.model.mainModel.currentSub
        -- self:ChangeTab(self.model.mainModel.currentSub)

        if self.openArgs ~= nil and self.openArgs[2] ~= nil then
            self:ChangeTab(self.openArgs[2], {self.openArgs[3]})
        end
    end)
end

function EncyclopediaPanel:RemoveListener()
end

function EncyclopediaPanel:InitPanel()
    --Log.Error("EncyclopediaPanel:InitPanel")
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.encyclopedia_panel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.tabContainer = self.transform:Find("BrewListPanel")
    self.tabBtnTemplate = self.tabContainer:Find("TabItem").gameObject
    self.tabBtnTemplate:SetActive(false)

    self.tabObjList = {}
    self.redPointList = {}
    self.tabImageList = {}
    self.tabTextList = {}

    self.tabLayout = LuaBoxLayout.New(self.tabContainer.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5})
    self.subCon = self.transform:Find("MainPanel").gameObject

    local mainPanel = self.transform:Find("MainPanel")
    self.leftTypeList = self.model:GetTreeBtn()
    -- for i=1,#self.leftTypeList do
    for i=1, 7 do
        local v = self.leftTypeList[i]
        if v ~= nil then
            local obj = GameObject.Instantiate(self.tabBtnTemplate)
            obj.name = tostring(i)
            self.tabLayout:AddCell(obj)
            self.tabObjList[i] = obj
            obj:GetComponent(Button).onClick:AddListener(function()
                self:ChangeTab(i)
            end)
            self.tabImageList[i] = obj:GetComponent(Image)

            local t = obj.transform
            self.tabTextList[i] = t:Find("Text"):GetComponent(Text)
            self.tabTextList[i].text = v.name

            self.redPointList[i] = t:Find("RedPoint").gameObject
            self.redPointList[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "RedPoint")
            self.redPointList[i]:SetActive(false)
            local iconTemp = t:Find("Icon"):GetComponent(Image)
            local sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, tostring(v.icon))
            if sprite == nil then
                sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, tostring(v.icon))
            end
            if sprite == nil then
                sprite = self.assetWrapper:GetSprite(AssetConfig.dropicon, tostring(v.icon))
            end
            if sprite == nil then
                sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, tostring(v.icon))
            end
            iconTemp.sprite = sprite
            iconTemp:SetNativeSize()
            self.subpanel[i] = EncyclopediaSubPanel.New(self.subCon, i, v.sub)
        end
    end
    -- self.TabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end)


end


function EncyclopediaPanel:OnInitCompleted()
    if self.openArgs ~= nil and self.openArgs[2] ~= nil then
        self:ChangeTab(self.openArgs[2], {self.openArgs[3]})
    else
        self:ChangeTab(1)
    end
end

function EncyclopediaPanel:__delete()
    -- self.model:CloseWarmTipsUI()
    self:RemoveListener()
    if self.TabGroup ~= nil then
        self.TabGroup:DeleteMe()
    end
    if self.subpanel ~= nil then
        for k,v in pairs(self.subpanel) do
            v:DeleteMe()
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.transform = nil
    self.OnOpenEvent:RemoveAll()
end

function EncyclopediaPanel:ChangeTab(index, args)
    self:EnableTab(index)
    for i,v in pairs(self.subpanel) do
        if index == i then
            v:Show(args)
        else
            v:Hiden()
        end
    end
end

function EncyclopediaPanel:EnableTab(sub)
    self.tabImageList[self.lastSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
    self.tabTextList[self.lastSub].color = ColorHelper.DefaultButton8
    self.tabImageList[sub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton9")
    self.tabTextList[sub].color = ColorHelper.DefaultButton9

    self.lastSub = sub
end