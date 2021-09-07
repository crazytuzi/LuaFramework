-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaCombatDesc = EncyclopediaCombatDesc or BaseClass(BasePanel)


function EncyclopediaCombatDesc:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaCombatDesc"

    self.resList = {
        {file = AssetConfig.guardabout_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaCombatDesc:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaCombatDesc:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guardabout_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local data = DataBrew.data_alldesc["Combatabout"]
    self.content = t:Find("Mask/Text"):GetComponent(Text)
    if data ~= nil then
        self.content.text = data.desc1
    end
    t:Find("Mask/Text").sizeDelta = Vector2(527, self.content.preferredHeight)
end

function EncyclopediaCombatDesc:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaCombatDesc:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaCombatDesc:OnHide()
    self:RemoveListeners()
end

function EncyclopediaCombatDesc:RemoveListeners()
end