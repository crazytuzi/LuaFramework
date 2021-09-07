-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaPetLvupAttr = EncyclopediaPetLvupAttr or BaseClass(BasePanel)


function EncyclopediaPetLvupAttr:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaPetLvupAttr"

    self.resList = {
        {file = AssetConfig.petlvupandattr_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaPetLvupAttr:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaPetLvupAttr:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petlvupandattr_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("LvupCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("AttrCon/MaskScroll/Desc"):GetComponent(Text)
    local descData = DataBrew.data_alldesc["lvupattr"]
    if descData ~= nil then
        self.leftDesc.text = descData.desc1
        self.RightDesc.text = descData.desc2
    end
end

function EncyclopediaPetLvupAttr:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaPetLvupAttr:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaPetLvupAttr:OnHide()
    self:RemoveListeners()
end

function EncyclopediaPetLvupAttr:RemoveListeners()
end