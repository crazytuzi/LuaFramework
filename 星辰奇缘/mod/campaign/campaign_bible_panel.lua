-- @author 黄耀聪
-- @date 2016年5月24日

CampaignBiblePanel = CampaignBiblePanel or BaseClass(BasePanel)

function CampaignBiblePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "CampaignBiblePanel"

    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.may_textures, type = AssetType.Dep},
    }

    self.panelList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CampaignBiblePanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CampaignBiblePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t
end

function CampaignBiblePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CampaignBiblePanel:OnOpen()
    self:RemoveListeners()
end

function CampaignBiblePanel:OnHide()
    self:RemoveListeners()
end

function CampaignBiblePanel:RemoveListeners()
end

function CampaignBiblePanel:ChangeTab()
end


