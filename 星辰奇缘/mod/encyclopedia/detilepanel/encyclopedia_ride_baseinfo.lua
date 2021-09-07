-- @author xjlong
-- @date 2016年8月17日
-- @坐骑基本信息

EncyclopediaRideBaseInfo = EncyclopediaRideBaseInfo or BaseClass(BasePanel)


function EncyclopediaRideBaseInfo:__init(parent)
    self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaRideBaseInfo"

    self.resList = {
        {file = AssetConfig.ridebaseinfo_peida, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil
    self.content = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaRideBaseInfo:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaRideBaseInfo:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridebaseinfo_peida))
    self.gameObject.name = self.name

    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local data = DataBrew.data_alldesc["ridebaseinfo"]
    self.content = t:Find("Mask/Text"):GetComponent(Text)
    self.TextEXT1 = MsgItemExt.New(self.content, 527, 17, 26)
    if data ~= nil then
        self.TextEXT1:SetData(data.desc1)
    end
    t:Find("Mask/Text").sizeDelta = Vector2(527, self.content.preferredHeight)
end

function EncyclopediaRideBaseInfo:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaRideBaseInfo:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaRideBaseInfo:OnHide()
    self:RemoveListeners()
end

function EncyclopediaRideBaseInfo:RemoveListeners()
end
