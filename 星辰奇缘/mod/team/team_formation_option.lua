-- ----------------------------
-- 组队阵法选择
-- hosr
-- ----------------------------
TeamFormationOptionPanel = TeamFormationOptionPanel or BaseClass(BasePanel)

function TeamFormationOptionPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = self.mainPanel.gameObject
    self.transform = nil
    self.upgradeBtn = nil
    self.panel = nil
    self.formationTab = {}

    self.resList = {
        {file = AssetConfig.formationoption, type = AssetType.Main}
    }
end

function TeamFormationOptionPanel:Show(arge)
    self.openArgs = arge
    if self.gameObject ~= nil then
        self:OnInitCompleted()
        self.gameObject:SetActive(true)
        self.OnOpenEvent:Fire()
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function TeamFormationOptionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.formationoption))
    self.gameObject.name = "TeamFormationOptionPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    self.upgradeBtn = self.transform:Find("Main/Upgrade"):GetComponent(Button)
    self.panel = self.transform:Find("Panel"):GetComponent(Button)
    for i = 1,6 do
        local id = i
        local tab = {}
        local item = self.transform:Find(string.format("Main/Button%s", i)).gameObject
        item:SetActive(false)
        tab["gameObject"] = item
        tab["id"] = id
        tab["label"] = item.transform:Find("Toggle/Label"):GetComponent(Text)
        tab["toggle"] = item.transform:Find("Toggle"):GetComponent(Toggle)
        tab["toggle"].isOn = false
        tab["tick"] = item.transform:Find("Toggle/Background/Checkmark").gameObject
        item:GetComponent(Button).onClick:AddListener(function() self:ClickToggle(id) end)
        table.insert(self.formationTab, tab)
    end
    self.panel.onClick:AddListener(function() self:Hiden() end)
    self.upgradeBtn.onClick:AddListener(function() self:ClickUpgrade() end)
    self:Show()
end

function TeamFormationOptionPanel:OnInitCompleted()
    for i = 1,6 do
        local fdata = DataFormation.data_list[string.format("%s_1", i)]
        if fdata ~= nil then
            local tab = self.formationTab[i]
            tab["enable"] = false
            tab["label"].text = string.format(TI18N("%s<color='#7eb9f7'>(未学习)</color>"), fdata.name)
            tab["toggle"].isOn = false
            tab["tick"]:SetActive(false)
            tab["gameObject"]:SetActive(true)
        end
    end

    for i,v in ipairs(FormationManager.Instance.formationList) do
        local fdata = DataFormation.data_list[string.format("%s_%s", v.id, v.lev)]
        if fdata ~= nil then
            local tab = self.formationTab[v.id]
            tab["enable"] = true
            tab["tick"]:SetActive(true)
            tab["toggle"].enabled = true
            tab["toggle"].isOn = (fdata.id == FormationManager.Instance.formationId)
            tab["label"].text = string.format("%s Lv.%s", fdata.name, v.lev)
        end
    end
    self.transform.gameObject:SetActive(true)
    self:EnableToggle()
end

function TeamFormationOptionPanel:Hiden()
    self.gameObject:SetActive(false)
    for i,v in ipairs(self.formationTab) do
        if v["toggle"].isOn then
            if v["id"] ~= FormationManager.Instance.formationId then
                FormationManager.Instance:Send12901(v["id"])
                return
            end
        end
    end
end

function TeamFormationOptionPanel:OnClose()
    self.mainPanel = nil
    self.transform = nil
    self.upgradeBtn = nil
    self.panel = nil
    self.formationTab = {}
end

function TeamFormationOptionPanel:EnableToggle()
    for i,v in ipairs(self.formationTab) do
        if not v["enable"] then
            v["tick"]:SetActive(false)
            v["toggle"].enabled = false
        end
    end
end

function TeamFormationOptionPanel:ClickToggle(id)
    local tab = self.formationTab[id]
    if tab["enable"] then
        self:Hiden()
    end
end

function TeamFormationOptionPanel:ClickUpgrade()
    self:Hiden()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.formation)
end