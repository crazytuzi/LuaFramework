-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaWingsUpgradeReset = EncyclopediaWingsUpgradeReset or BaseClass(BasePanel)


function EncyclopediaWingsUpgradeReset:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaWingsUpgradeReset"

    self.resList = {
        {file = AssetConfig.wingupreset_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaWingsUpgradeReset:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaWingsUpgradeReset:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wingupreset_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("UpCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("ResetCon/MaskScroll/Desc"):GetComponent(Text)
    local descData = DataBrew.data_alldesc["wingsupgradereset"]
    if descData ~= nil then
        self.leftDesc.text = descData.desc1
        self.RightDesc.text = descData.desc2
    end
    self.leftDesc.transform.sizeDelta = Vector2(222, self.leftDesc.preferredHeight+46)
    self.RightDesc.transform.sizeDelta = Vector2(222, self.RightDesc.preferredHeight+46)
    self.leftDesc.transform:Find("Button").gameObject:SetActive(true)
    self.RightDesc.transform:Find("Button").gameObject:SetActive(true)
    self.leftDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        WindowManager:OpenWindowById(WindowConfig.WinID.backpack, {3,2})
    end)
    self.RightDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        WindowManager:OpenWindowById(WindowConfig.WinID.backpack, {3,3})
    end)
end

function EncyclopediaWingsUpgradeReset:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaWingsUpgradeReset:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaWingsUpgradeReset:OnHide()
    self:RemoveListeners()
end

function EncyclopediaWingsUpgradeReset:RemoveListeners()
end