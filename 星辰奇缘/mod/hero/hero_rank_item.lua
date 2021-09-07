HeroRankItem = HeroRankItem or BaseClass()

function HeroRankItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.transform = gameObject.transform
    local t = self.transform

    self.bgObj = t:Find("Bg").gameObject
    self.highLightObj = t:Find("HighLight").gameObject
    self.campImage = t:Find("CampBox/Icon"):GetComponent(Image)
    self.rankText = t:Find("Rank"):GetComponent(Text)
    self.headImage = t:Find("Player/HeadBg/Image"):GetComponent(Image)
    self.nameText = t:Find("Player/Name"):GetComponent(Text)
    self.jobText = t:Find("Job"):GetComponent(Text)
    self.vicNumText = t:Find("VicNum"):GetComponent(Text)
    self.reviveText = t:Find("Revive"):GetComponent(Text)
    self.scoresText = t:Find("Scores"):GetComponent(Text)
    self.selectObj = t:Find("Select").gameObject
    self.button = gameObject:GetComponent(Button)

    self.button.onClick:AddListener(function() self:OnClick() end)
    self.highLightObj:SetActive(false)
    self.selectObj:SetActive(false)
end

function HeroRankItem:__delete()
end

function HeroRankItem:SetActive(bool)
    self:SetActive(bool)
end

function HeroRankItem:update_my_self(data, index)
    self.data = data
    self.index = index

    if data == nil then
        self:SetActive(false)
        return
    end

    self.bgObj:SetActive(index % 2 == 0)
    self.campImage.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "Camp"..tostring(data.group))
    self.rankText.text = tostring(index)
    self.nameText.text = data.name
    self.headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
    self.jobText.text = KvData.classes_name[data.classes]
    self.scoresText.text = tostring(data.score)
    self.reviveText.text = tostring(data.die)
    self.vicNumText.text = tostring(data.win)

    local roledata = RoleManager.Instance.RoleData
    local bool = ((roledata.id == data.rid) and (roledata.zone_id == data.r_zone_id) and (roledata.platform == data.platform))
    self.highLightObj:SetActive(bool)
    self.model.rankHasMe = self.model.rankHasMe or bool
    if bool then
        self.model.rank = index
        self.model.myInfo.score = data.score
    end
    self.selectObj:SetActive(self.model.lastIndex == index)
end

function HeroRankItem:OnClick()
    if self.model.currentSelectObj ~= nil then
        self.model.currentSelectObj:SetActive(false)
    end
    self.selectObj:SetActive(true)
    self.model.currentSelectObj = self.selectObj
    self.model.lastIndex = self.index
end


