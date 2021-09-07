OpenServerPhotoPanel = OpenServerPhotoPanel or BaseClass(BasePanel)

function OpenServerPhotoPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = OpenServerManager.Instance

    self.resList = {
        {file = AssetConfig.open_server_photo_panel, type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.onReloadListener = function(sprite, roleid, platform, zoneid) self:ReloadPhoto(sprite, roleid, platform, zoneid) end

    self.OnOpenEvent:Add(self.openListener)
    self.OnHideEvent:Add(self.hideListener)
end

function OpenServerPhotoPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerPhotoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_photo_panel))
    self.gameObject.name = "PhotoPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.btn = t:Find("Panel"):GetComponent(Button)
    self.image = t:Find("Main/Image"):GetComponent(Image)

    self.btn.onClick:AddListener(function() self.model:ClosePhotoPanel() end)

    self.OnOpenEvent:Fire()
end

function OpenServerPhotoPanel:OnOpen()
    local index = 1
    if self.openArgs ~= nil then index = self.openArgs end
    self.data = self.mgr.guildBabyList[index]
    self.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)

    self:RemoveListeners()
    self.mgr.onUpdatePhoto:AddListener(self.onReloadListener)

    self.model:ToPhoto(self.data.male_id, self.data.male_platform, self.data.male_zone_id, self.data.photo)
end

function OpenServerPhotoPanel:OnHide()
    self:RemoveListeners()
end

function OpenServerPhotoPanel:RemoveListeners()
    self.mgr.onUpdatePhoto:RemoveListener(self.onReloadListener)
end

function OpenServerPhotoPanel:ReloadPhoto(sprite, roleid, platform, zoneid)
    -- print(sprite.length)
    if self.data.male_id == roleid and self.data.male_platform == platform and self.data.male_zone_id == zoneid then
        if sprite ~= nil then
            self.image.sprite = sprite
        else
            self.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
        end
    else
        self.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.data.classes.."_"..self.data.sex)
    end
end