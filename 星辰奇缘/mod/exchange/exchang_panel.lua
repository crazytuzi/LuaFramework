ExchangePanel = ExchangePanel or BaseClass(BasePanel)

function ExchangePanel:__init(model)
    self.model = model
    self.name = "ExchangePanel"

    self.resList = {
        {file = AssetConfig.exchange_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }

end

function ExchangePanel:OnInitCompleted()

end

function ExchangePanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function ExchangePanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exchange_panel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "ExchangePanel"
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() end)
    self.icon1 = self.transform:Find("Main/Assets1"):GetComponent(Image)
    self.icon2 = self.transform:Find("Main/Assets2"):GetComponent(Image)
    local setting11 = {
        axis = BoxLayoutAxis.Y
        ,cspacing = 10
        ,border = 10
    }
    self.btnClone = self.transform:Find("Main/Button")
    self.con = self.transform:Find("Main/ButtonCon")
    self.Layout1 = LuaBoxLayout.New(self.transform:Find("Main/MaskScroll/ButtonCon"), setting11)
    self:InitButton()
end

function ExchangePanel:InitButton()
    if self.openArgs == nil then

    else
        if type(self.openArgs) == "table" then
            self.openArgs = self.openArgs[1]
        end
    end
    if self.openArgs == 2 then
        self:SetIcon(2)
        for k,v in ipairs(DataExchange.data_get) do
            if v.type == "coin" then
                local btn = GameObject.Instantiate(self.btnClone.gameObject)
                btn.gameObject.name = v.name
                btn.transform:Find("Text"):GetComponent(Text).text = v.name
                btn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dropicon, v.icon)
                btn.transform:GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() if self:Special(v) then return end WindowManager.Instance:OpenWindowById(v.panelid, v.args) end)
                self.Layout1:AddCell(btn.gameObject)
            end
        end
    elseif self.openArgs == 1 then
        self:SetIcon(1)
        for k,v in pairs(DataExchange.data_get) do
            if v.type == "gold_bind" then
                local btn = GameObject.Instantiate(self.btnClone.gameObject)
                btn.gameObject.name = v.name
                btn.transform:Find("Text"):GetComponent(Text).text = v.name
                btn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dropicon, v.icon)
                btn.transform:GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() if self:Special(v) then return end WindowManager.Instance:OpenWindowById(v.panelid, v.args) end)
                self.Layout1:AddCell(btn.gameObject)
            end
        end
    elseif self.openArgs == 3 then
        self:SetIcon(3)
        for k,v in pairs(DataExchange.data_get) do
            if v.type == "stars_score" then
                local btn = GameObject.Instantiate(self.btnClone.gameObject)
                btn.gameObject.name = v.name
                btn.transform:Find("Text"):GetComponent(Text).text = v.name
                btn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dropicon, v.icon)
                btn.transform:GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() if self:Special(v) then return end WindowManager.Instance:OpenWindowById(v.panelid, v.args) end)
                self.Layout1:AddCell(btn.gameObject)
            end
        end
    end
end

function ExchangePanel:SetIcon(type)
    local sprite
    if type == 2 then
        sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[90000])
    elseif type == 1 then
        sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[90003])
    elseif type == 3 then
        sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[90012])
    end
    if sprite ~= nil then
        self.icon1.sprite = sprite
        self.icon2.sprite = sprite
    end
end

function ExchangePanel:Special(data)
    if data.panelid == 99999 then
        local normal = BackpackManager.Instance:GetItemByBaseid(20052)
        if #normal > 0 then
            --挖普通
            BackpackManager.Instance:Use(normal[1].id, normal[1].quantity, 20052)
            NoticeManager.Instance:FloatTipsByString(TI18N("开始挖宝咯{face_1,31}"))
        else
            local sp = BackpackManager.Instance:GetItemByBaseid(20053)
            if #sp > 0 then
                --挖远古
                BackpackManager.Instance:Use(sp[1].id, sp[1].quantity, 20052)
                NoticeManager.Instance:FloatTipsByString(TI18N("开始挖宝咯{face_1,31}"))
            else
                --做宝图任务
                QuestManager.Instance.model:DoTreasuremap()
            end
        end
        return true
    end
    return false
end