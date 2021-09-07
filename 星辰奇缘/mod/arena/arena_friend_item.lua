ArenaFriendItem = ArenaFriendItem or BaseClass()

function ArenaFriendItem:__init(model, gameObject, assetWrapper)
    self.assetWrapper = assetWrapper
    self.gameObject = gameObject
    self.model = model

    local t = self.gameObject.transform

    self.img = self.gameObject:GetComponent(Image)
    self.bgObj = t:Find("Bg").gameObject
    self.bgObj:SetActive(false)
    self.rankValueText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.jobIconImage = t:Find("Character/JobIcon"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.scoreText = t:Find("Score"):GetComponent(Text)
end

function ArenaFriendItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ArenaFriendItem:SetData(data, index)
    if index % 2 == 1 then
        self.img.color = ColorHelper.ListItem1
    else
        self.img.color = ColorHelper.ListItem2
    end

    self.rankValueText.text = string.format(ColorHelper.ListItemStr, tostring(index))
    if index > 3 then
        self.rankImage.gameObject:SetActive(false)
    else
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..index)
        self.rankImage.gameObject:SetActive(true)
    end
    self.nameText.text = string.format(ColorHelper.ListItemStr, data.name)
    self.jobIconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.classes))
    self.scoreText.text = string.format(ColorHelper.ListItemStr, tostring(data.val1))
    self.gameObject:SetActive(true)
end

function ArenaFriendItem:__delete()
    self.rankImage.sprite = nil
    self.jobIconImage.sprite = nil
    self.rankImage = nil
    self.jobIconImage = nil
end