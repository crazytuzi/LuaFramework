-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaGuardDesc = EncyclopediaGuardDesc or BaseClass(BasePanel)


function EncyclopediaGuardDesc:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaGuardDesc"

    self.resList = {
        {file = AssetConfig.guardabout_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaGuardDesc:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaGuardDesc:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guardabout_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local data = DataBrew.data_alldesc["guarddesc"]
    self.content = t:Find("Mask/Text"):GetComponent(Text)
    if data ~= nil then
        self.content.text = data.desc1
    end
    t:Find("Mask/Text").sizeDelta = Vector2(527, self.content.preferredHeight)
end

function EncyclopediaGuardDesc:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaGuardDesc:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaGuardDesc:OnHide()
    self:RemoveListeners()
end

function EncyclopediaGuardDesc:RemoveListeners()
end