-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaPetUpgradeOther = EncyclopediaPetUpgradeOther or BaseClass(BasePanel)


function EncyclopediaPetUpgradeOther:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaPetUpgradeOther"

    self.resList = {
        {file = AssetConfig.upgradeother_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaPetUpgradeOther:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaPetUpgradeOther:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.upgradeother_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("UpgradeCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("OtherCon/MaskScroll/Desc"):GetComponent(Text)
    local descData = DataBrew.data_alldesc["upgradeother"]
    if descData ~= nil then
        self.leftDesc.text = descData.desc1
        self.RightDesc.text = descData.desc2
    end
end

function EncyclopediaPetUpgradeOther:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaPetUpgradeOther:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaPetUpgradeOther:OnHide()
    self:RemoveListeners()
end

function EncyclopediaPetUpgradeOther:RemoveListeners()
end