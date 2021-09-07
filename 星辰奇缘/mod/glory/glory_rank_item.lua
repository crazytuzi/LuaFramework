GloryItemType = GloryItemType or {}

GloryItemType.type = {
    All = 1,
    Recent = 2,
}

GloryRankItem = GloryRankItem or BaseClass()

function GloryRankItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.assetWrapper = assetWrapper

    local t = self.transform
    self.bgObj = t:Find("Bg").gameObject
    self.selectObj = t:Find("Select").gameObject
    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.jobText = t:Find("Job"):GetComponent(Text)
    self.timeText = t:Find("Time"):GetComponent(Text)
    self.videoBtn = t:Find("Video"):GetComponent(Button)
    self.button = gameObject:GetComponent(Button)
    self.timeText.gameObject:SetActive(true)

    self.videoBtn.onClick:AddListener(function() self:OnVideo() end)
    self.button.onClick:AddListener(function() self:OnSelect() end)
end

function GloryRankItem:__delete()
    self.assetWrapper = nil
    self.transform = nil
    self.gameObject = nil
end

function GloryRankItem:update_my_self(data, index, type)
    self.selectObj:SetActive(false)
    self.videoBtn.gameObject:SetActive(false)
    self.data = data
    self.index = index
    self:SetActive(true)
    self.type = type

    local minute = nil
    local second = nil

    self.bgObj:SetActive(index % 2 == 1)

    if type == GloryItemType.type.All then
        if index < 4 then
            self.rankImage.gameObject:SetActive(true)
            self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.glory_textures, "place_"..index)
        else
            self.rankImage.gameObject:SetActive(false)
        end

        minute = math.floor(data.time / 60)
        second = data.time % 60
        self.rankText.text = tostring(index)
        self.nameText.text = data.name
        self.jobText.text = KvData.classes_name[data.classes]
        self.timeText.text = TI18N(string.format(TI18N("%s分%s秒"), tostring(minute), tostring(second)))
    elseif type == GloryItemType.type.Recent then
        self.rankImage.gameObject:SetActive(false)

        minute = math.floor(data.time_r / 60)
        second = data.time_r % 60
        self.rankText.text = tostring(index)
        self.nameText.text = data.name_r
        self.jobText.text = KvData.classes_name[data.classes_r]
        self.timeText.text = TI18N(string.format(TI18N("%s分%s秒"), tostring(minute), tostring(second)))
    end
end

function GloryRankItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function GloryRankItem:OnVideo()
    if self.data ~= nil then
        if self.type == GloryItemType.type.All then
            GloryManager.Instance:send14407(self.data.rid, self.data.r_platform, self.data.r_zone_id, self.data.lev_id)
        elseif self.type == GloryItemType.type.Recent then
            GloryManager.Instance:send14408(self.data.rid_r, self.data.platform_r, self.data.zone_id_r, self.data.lev_id)
        end
    end
end

function GloryRankItem:OnSelect()
    if self.model.rankItem ~= nil then
        self.model.rankItem:Select(false)
    end
    self:Select(true)
    self.model.rankItem = self
end

function GloryRankItem:Select(bool)
    self.timeText.gameObject:SetActive(not bool)
    self.videoBtn.gameObject:SetActive(bool)
    self.selectObj:SetActive(bool)
end
