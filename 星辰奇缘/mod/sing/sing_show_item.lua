-- ------------------------------
-- 好声音展示项
-- hosr
-- ------------------------------
SingShowItem = SingShowItem or BaseClass()

function SingShowItem:__init(gameObject, parent)
    self.parent = parent
    self.assetWrapper = parent.assetWrapper
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self:InitPanel()
end

function SingShowItem:__delete()
    self.parent = nil
    self.assetWrapper = nil
    self.gameObject = nil
    self.transform = nil
end

function SingShowItem:InitPanel()

    self.transform:Find("Heart"):GetComponent(Button).onClick:AddListener(function() self:OnFollow() end)
    self.bgImg = self.transform:GetComponent(Image)
    self.heartImg = self.transform:Find("Heart/Heart"):GetComponent(Image)
    self.num = self.transform:Find("Num"):GetComponent(Text)
    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.desc = self.transform:Find("Desc"):GetComponent(Text)
    self.goodsnum = self.transform:Find("GoodBum"):GetComponent(Text)
    self.goodsRect = self.transform:Find("GoodBum"):GetComponent(RectTransform)
    self.goodImg = self.transform:Find("GoodBum/Image").gameObject
    self.goodsnum2 = self.transform:Find("GoodBum2"):GetComponent(Text)
    self.goodsRect2 = self.transform:Find("GoodBum2"):GetComponent(RectTransform)
    self.goodImg2 = self.transform:Find("GoodBum2/Image").gameObject
    self.btn = self.transform:Find("Button"):GetComponent(Button)
    self.btn.gameObject:SetActive(true)
    self.select = self.transform:Find("Select").gameObject
    self.select:SetActive(false)
    self.stateTxt = self.transform:Find("State"):GetComponent(Text)
    self.stateTxt.gameObject:SetActive(false)
    self.stateTxt.text = ""
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
    self.btn.onClick:AddListener(function() self:OnPlay() end)
    self.name.horizontalOverflow = HorizontalWrapMode.Overflow

    self.btn.gameObject:SetActive(false)
    self.stateTxt.gameObject:SetActive(false)
end

function SingShowItem:Select(bool)
    self.select:SetActive(bool)
end

function SingShowItem:UpdateState(state)
    if self.data == nil then
        return
    end
    self.data.state = state
    -- if state == SingEumn.State.Normal then
    --     self.btn.gameObject:SetActive(true)
    --     self.stateTxt.gameObject:SetActive(false)
    -- elseif state == SingEumn.State.Downloading then
    --     self.btn.gameObject:SetActive(false)
    --     self.stateTxt.gameObject:SetActive(true)
    --     self.stateTxt.text = TI18N("加载中")
    -- elseif state == SingEumn.State.Playing then
    --     self.btn.gameObject:SetActive(false)
    --     self.stateTxt.gameObject:SetActive(true)
    --     self.stateTxt.text = TI18N("播放中")
    -- end
    if state == SingEumn.State.Normal then
        if self.data.sex == 0 then
            self.name.text = string.format("<color='#FF83FA'>♀</color>%s", self.data.name)
        else
            self.name.text = string.format("<color='#5CACEE'>♂</color>%s", self.data.name)
        end
    elseif state == SingEumn.State.Downloading then
        self.name.text = TI18N("<color='#ffff00'>加载中</color>")
    elseif state == SingEumn.State.Playing then
        self.name.text = TI18N("<color='#ffff00'>播放中</color>")
    end
end

function SingShowItem:update_my_self(data, item_index)
    self.data = data

    self.num.text = data.id
    if self.data.sex == 0 then
        self.name.text = string.format("<color='#FF83FA'>♀</color>%s", data.name)
    else
        self.name.text = string.format("<color='#5CACEE'>♂</color>%s", data.name)
    end
    self.desc.text = data.summary

    if SingManager.Instance.activeState ~= SingEumn.ActiveState.SignUp and SingManager.Instance.activeState ~= SingEumn.ActiveState.VotePre and SingManager.Instance.activeState ~= SingEumn.ActiveState.Vote then
        self.goodsnum.text = SingManager.Instance:ShowLiked(data.liked)
        self.goodImg:SetActive(true)
        self.goodsRect.anchoredPosition = Vector2(330, 0)
        self.goodsnum.alignment = TextAnchor.MiddleLeft

        self.goodsnum2.text = SingManager.Instance:ShowLiked(data.only_liked)
        self.goodImg2:SetActive(true)
        self.goodsRect2.anchoredPosition = Vector2(410, 0)
        self.goodsnum2.alignment = TextAnchor.MiddleLeft
    else
        self.goodImg:SetActive(false)
        self.goodsnum.text = data.caster_num
        self.goodsRect.anchoredPosition = Vector2(344, 0)
        self.goodsnum.alignment = TextAnchor.MiddleCenter
        self.goodImg2:SetActive(false)
        self.goodsnum2.text = ""
    end

    self.select:SetActive(false)
    self:UpdateFollow()
    self:UpdateState(self.data.state)
end

function SingShowItem:OnClick()
    self.parent:SelectOne(self)
end

function SingShowItem:OnPlay()
    self.stateTxt.text = TI18N("加载中")
    self.stateTxt.gameObject:SetActive(true)
    self.parent:SelectAndPlay(self)
end

function SingShowItem:OnFollow()
    local key = string.format("%s_%s_%s", self.data.rid, self.data.platform, self.data.zone_id)
    local follow = SingManager.Instance:IsFollow(key)
    if follow then
        -- 已关注
        follow = 0
    else
        follow = 1
    end
    SingManager.Instance:Send16806(self.data.rid, self.data.platform, self.data.zone_id, follow)
end

function SingShowItem:UpdateFollow()
    if self.data == nil then
        return
    end
    local key = string.format("%s_%s_%s", self.data.rid, self.data.platform, self.data.zone_id)
    if SingManager.Instance:IsFollow(key) then
        self.heartImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingHeart1")
    else
        self.heartImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingHeart2")
    end
end


SingRankItem = SingRankItem or BaseClass()

function SingRankItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.parent = parent
    self.assetWrapper = parent.assetWrapper
    local t = self.transform

    self.bgImg = gameObject:GetComponent(Image)
    self.rankText = self.transform:Find("Rank"):GetComponent(Text)
    self.rankImg = self.transform:Find("Rank/Image"):GetComponent(Image)
    self.num = self.transform:Find("Num"):GetComponent(Text)
    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.desc = self.transform:Find("Desc"):GetComponent(Text)
    self.goodsnum = self.transform:Find("GoodBum"):GetComponent(Text)
    self.goodsRect = self.transform:Find("GoodBum"):GetComponent(RectTransform)
    self.goodImg = self.transform:Find("GoodBum/Image").gameObject
    self.goodImg2 = self.transform:Find("GoodBum/Image2").gameObject
    self.btn = self.transform:Find("Button"):GetComponent(Button)
    self.btn.gameObject:SetActive(true)
    self.select = self.transform:Find("Select").gameObject
    self.select:SetActive(false)
    self.stateTxt = self.transform:Find("State"):GetComponent(Text)
    self.stateTxt.gameObject:SetActive(false)
    self.stateTxt.text = ""
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
    self.btn.onClick:AddListener(function() self:OnPlay() end)
    self.name.horizontalOverflow = HorizontalWrapMode.Overflow
end

function SingRankItem:__delete()
    self.assetWrapper = nil
    self.rankImg.sprite = nil
end

function SingRankItem:update_my_self(data, index)
    self.data = data
    self.rankText.text = tostring(index)
    if index < 4 then
        self.rankImg.gameObject:SetActive(true)
        self.rankImg.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..index)
    else
        self.rankImg.gameObject:SetActive(false)
    end


    self.num.text = data.id
    if self.data.sex == 0 then
        self.name.text = string.format("<color='#FF83FA'>♀</color>%s", data.name)
    else
        self.name.text = string.format("<color='#5CACEE'>♂</color>%s", data.name)
    end
    self.desc.text = data.summary

    if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
        if self.parent.model.currentTab == 2 or self.parent.model.currentTab == 3 then
            self.goodsnum.text = SingManager.Instance:ShowLiked(data.liked)
            self.goodImg:SetActive(false)
            self.goodImg2:SetActive(true)
        else
            self.goodsnum.text = SingManager.Instance:ShowLiked(data.only_liked)
            self.goodImg:SetActive(true)
            self.goodImg2:SetActive(false)
        end
        self.goodsRect.anchoredPosition = Vector2(344, 0)
        self.goodsnum.alignment = TextAnchor.MiddleLeft
    else
        self.goodImg:SetActive(false)
        self.goodImg2:SetActive(false)
        self.goodsnum.text = data.caster_num
        self.goodsRect.anchoredPosition = Vector2(315, 0)
        self.goodsnum.alignment = TextAnchor.MiddleCenter
    end

    self.select:SetActive(false)
    self:UpdateState(self.data.state)
end

function SingRankItem:OnPlay()
    self.stateTxt.text = TI18N("加载中")
    self.stateTxt.gameObject:SetActive(true)
    self.parent:SelectAndPlay(self)
end

function SingRankItem:OnClick()
    self.parent:SelectOne(self)
end

function SingRankItem:UpdateState(state)
    if self.data == nil then
        return
    end
    
    self.data.state = state
    if state == SingEumn.State.Normal then
        self.btn.gameObject:SetActive(true)
        self.stateTxt.gameObject:SetActive(false)
    elseif state == SingEumn.State.Downloading then
        self.btn.gameObject:SetActive(false)
        self.stateTxt.gameObject:SetActive(true)
        self.stateTxt.text = TI18N("加载中")
    elseif state == SingEumn.State.Playing then
        self.btn.gameObject:SetActive(false)
        self.stateTxt.gameObject:SetActive(true)
        self.stateTxt.text = TI18N("播放中")
    end
end

function SingRankItem:Select(bool)
    self.select:SetActive(bool)
end