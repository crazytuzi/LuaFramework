-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaWingsSkillOther = EncyclopediaWingsSkillOther or BaseClass(BasePanel)


function EncyclopediaWingsSkillOther:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaWingsSkillOther"

    self.resList = {
        {file = AssetConfig.wingskillabout, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaWingsSkillOther:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaWingsSkillOther:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wingskillabout))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local data = DataBrew.data_alldesc["wingskill"]
    self.content = t:Find("Mask/Text"):GetComponent(Text)
    if data ~= nil then
        self.content.text = data.desc1
    end
    t:Find("Mask/Text").sizeDelta = Vector2(527, self.content.preferredHeight)

end

function EncyclopediaWingsSkillOther:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaWingsSkillOther:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaWingsSkillOther:OnHide()
    self:RemoveListeners()
end

function EncyclopediaWingsSkillOther:RemoveListeners()
end