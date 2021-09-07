-- @author 黄耀聪
-- @date 2017年5月16日

ClosenessRankItem = ClosenessRankItem or BaseClass()

function ClosenessRankItem:__init(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    local t = self.transform

    self.rankImage = t:Find("Rank/Image"):GetComponent(Image)
    self.rankText = t:Find("Rank/Text"):GetComponent(Text)

    self.headSlot1 = HeadSlot.New()
    NumberpadPanel.AddUIChild(t:Find("Husband/Icon"), self.headSlot1.gameObject)
    self.btn1 = t:Find("Husband"):GetComponent(Button)
    self.nameText1 = t:Find("Husband/Name"):GetComponent(Text)

    self.Husband = t:Find("Husband");
    self.Wife = t:Find("Wife");
    self.headSlot2 = HeadSlot.New()
    NumberpadPanel.AddUIChild(t:Find("Wife/Icon"), self.headSlot2.gameObject)

    self.btn2 = t:Find("Wife"):GetComponent(Button)
    self.nameText2 = t:Find("Wife/Name"):GetComponent(Text)
    self.ImgStart = t:Find("ImgStart")

    self.scoreText = t:Find("Score"):GetComponent(Text)
    t:Find("Score").anchoredPosition = Vector2(351,3)
    t:Find("Score").sizeDelta = Vector2(95,40)
    self.btn1.onClick:AddListener( function() self:OnClick1() end)
    self.btn2.onClick:AddListener( function() self:OnClick2() end)
end

function ClosenessRankItem:__delete()
    if self.headSlot1 ~= nil then
        self.headSlot1:DeleteMe()
        self.headSlot1 = nil
    end
    if self.headSlot2 ~= nil then
        self.headSlot2:DeleteMe()
        self.headSlot2 = nil
    end
    self.rankImage.sprite = nil
    self.gameObject = nil
    self.assetWrapper = nil
end

function ClosenessRankItem:update_my_self(data, index)
    self.data = data
    self.rankType = WorldLevManager.Instance.CurRankType

    if self.rankType ~= CampaignEumn.CampaignRankType.Intimacy then
        self.Husband.transform:GetComponent(RectTransform).anchoredPosition = Vector2(140, 3)
        self.Wife.gameObject:SetActive(false)
    else
        self.Husband.transform:GetComponent(RectTransform).anchoredPosition = Vector2(62, 3)
        self.Wife.gameObject:SetActive(true)
    end

    self.ImgStart.gameObject:SetActive(self.rankType == CampaignEumn.CampaignRankType.PlayerKill)
    self.nameText1.text = data.name
    self.nameText2.text = data.name2
    local valStr = nil
    if self.rankType == CampaignEumn.CampaignRankType.PlayerKill then
        local baseData = DataRencounter.data_info[data.val1]
        valStr = string.format("%s%s", baseData.title, data.val4)
    elseif self.rankType == CampaignEumn.CampaignRankType.WorldChampion then
       local baseData = DataTournament.data_list[data.val1]
       valStr = string.format("%s", baseData.name)
    else
        valStr = tostring(data.val1)
    end
    self.scoreText.text = valStr

    if index > 3 then
        self.rankImage.gameObject:SetActive(false)
        self.rankText.gameObject:SetActive(true)
        self.rankText.text = tostring(index)
    else
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, string.format("place_%s", tostring(index)))
        self.rankImage.gameObject:SetActive(true)
        self.rankText.gameObject:SetActive(false)
    end

    self.headSlot1:SetAll( {
        id = data.role_id,
        platform = data.platform,
        zone_id = data.zone_id,
        classes = data.classes,
        sex = data.sex,
    } )

    self.headSlot2:SetAll( {
        id = data.role_id2,
        platform = data.platform2,
        zone_id = data.zone_id2,
        classes = data.classes2,
        sex = data.sex2,
    } )

    if self.rankType ~= CampaignEumn.CampaignRankType.Intimacy then
        self.Husband.transform:GetComponent(RectTransform).anchoredPosition = Vector2(140, 3)
        self.Wife.gameObject:SetActive(false)
    else
        self.Husband.transform:GetComponent(RectTransform).anchoredPosition = Vector2(62, 3)
        self.Wife.gameObject:SetActive(true)
    end
end

function ClosenessRankItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ClosenessRankItem:OnClick1()
    if self.data ~= nil then
        local showData = { id = self.data.role_id, zone_id = self.data.zone_id, platform = self.data.platform, sex = self.data.sex, classes = self.data.classes, name = self.data.name, lev = self.data.lev }
        TipsManager.Instance:ShowPlayer(showData)
    end
end

function ClosenessRankItem:OnClick2()
    if self.data ~= nil then
        local showData = { id = self.data.role_id2, zone_id = self.data.zone_id2, platform = self.data.platform2, sex = self.data.sex2, classes = self.data.classes2, name = self.data.name2, lev = self.data.lev2 }
        TipsManager.Instance:ShowPlayer(showData)
    end
end


