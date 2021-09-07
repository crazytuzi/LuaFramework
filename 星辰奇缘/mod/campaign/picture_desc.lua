-- @author 黄耀聪
-- @date 2017年8月23日, 星期三

PictureDesc = PictureDesc or BaseClass(BasePanel)

function PictureDesc:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "PictureDesc"

    self.resList = {
        {file = AssetConfig.picture_desc, type = AssetType.Main}
    }

    self.campId = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PictureDesc:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function PictureDesc:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.picture_desc))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    if self.bg ~= nil then
        UIUtils.AddBigbg(self.transform:Find("Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    end

    local cfgData = DataCampaign.data_list[self.campId]
    self.transform:Find("Text"):GetComponent(Text).text = cfgData.cond_desc

    if self.transform:Find("Notice") ~= nil then
        self.transform:Find("Notice").gameObject:SetActive(false)
    end
end

function PictureDesc:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PictureDesc:OnOpen()
    self:RemoveListeners()
end

function PictureDesc:OnHide()
    self:RemoveListeners()
end

function PictureDesc:RemoveListeners()
end


