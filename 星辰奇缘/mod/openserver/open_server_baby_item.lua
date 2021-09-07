OpenServerBabyItem = OpenServerBabyItem or BaseClass()

function OpenServerBabyItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    local t = gameObject.transform

    self.btn = gameObject:GetComponent(Button)
    self.rankText = t:Find("Rank"):GetComponent(Text)
    self.rankImage = t:Find("Rank/Image"):GetComponent(Image)
    self.nameText = t:Find("InfoArea/Name"):GetComponent(Text)
    self.iconImage = t:Find("InfoArea/Icon/Image"):GetComponent(Image)
    self.iconBtn = t:Find("InfoArea/Icon"):GetComponent(Button)
    self.guildImage = t:Find("InfoArea/GuildIcon"):GetComponent(Image)
    self.guildNameText = t:Find("InfoArea/GuildIcon/Text"):GetComponent(Text)
    self.giftBtn = t:Find("GiftArea/Gift"):GetComponent(Button)
    self.rqText = t:Find("RQArea/Bg/Text"):GetComponent(Text)
    self.voteBtn = t:Find("VoteArea/Vote"):GetComponent(Button)
    self.bgImage = t:Find("Bg"):GetComponent(Image)

    self.btn.onClick:AddListener(function() self:OnPlayer() end)
    self.voteBtn.onClick:AddListener(function() self:OnVote() end)
    self.giftBtn.onClick:AddListener(function() self:OnGift() end)
    self.iconBtn.onClick:AddListener(function() self:OnPhoto() end)
end

function OpenServerBabyItem:__delete()
end

function OpenServerBabyItem:SetData(data, index)
    self.data = data
    self.rankImage.gameObject:SetActive(index < 4)
    if index < 4 then
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..tostring(index))
        self.bgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "BabyBg"..index)
    else
        self.bgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "BabyBg")
    end
    self.rankText.text = tostring(index)
    self:SetActive(true)
    self.iconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
    self.nameText.text = data.name
    self.guildNameText.text = data.guild_name
    self.rqText.text = data.score
end

function OpenServerBabyItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function OpenServerBabyItem:OnVote()
    self.confirmData = NoticeConfirmData.New()
    self.confirmData.type = ConfirmData.Style.Normal
    self.confirmData.content = TI18N("对TA赠送玫瑰或空间点赞可增加人气值")
    self.confirmData.sureLabel = TI18N("空间点赞")
    self.confirmData.cancelLabel = TI18N("赠送玫瑰")
    self.confirmData.showClose = 0

    local data = {
        id = self.data.male_id
        ,platform = self.data.male_platform
        ,zone_id = self.data.male_zone_id
        ,name = self.data.name
        ,lev = self.data.lev
        ,classes = self.data.classes
        ,sex = self.data.sex
    }
    self.confirmData.sureCallback = function() ZoneManager.Instance:OpenOtherZone(self.data.male_id, self.data.male_platform, self.data.male_zone_id) end
    self.confirmData.cancelCallback = function()
        GivepresentManager.Instance:OpenGiveWin(data) end
    NoticeManager.Instance:ConfirmTips(self.confirmData)
end

function OpenServerBabyItem:OnGift()
    self.model:OpenBabyGiftTips(self.data.rank)
end

function OpenServerBabyItem:OnPhoto()
    self.model:OpenPhotoPanel(self.data.rank)
end

function OpenServerBabyItem:OnPlayer()
    local showData = {id = self.data.male_id, zone_id = self.data.male_zone_id, platform = self.data.male_platform, sex = self.data.sex, classes = self.data.classes, name = self.data.name, lev = self.data.lev, guild = self.data.guild_name}
    TipsManager.Instance:ShowPlayer(showData)
end
