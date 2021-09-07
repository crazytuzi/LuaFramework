GloryFriendRankItem = GloryFriendRankItem or BaseClass()

function GloryFriendRankItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.assetWrapper = assetWrapper

    self.bgImage = gameObject:GetComponent(Image)
    self.rankImage = self.transform:Find("Rank"):GetComponent(Image)
    self.rankText = self.transform:Find("RankText"):GetComponent(Text)
    self.classesImage = self.transform:Find("Classes"):GetComponent(Image)
    self.nameText = self.transform:Find("Name"):GetComponent(Text)
    self.scoreText = self.transform:Find("Score"):GetComponent(Text)
    self.button = self.gameObject:GetComponent(Button)

    self.button.transition = 0
end

function GloryFriendRankItem:__delete()
    if self.rankImage ~= nil then
        self.rankImage.sprite = nil
    end
    if self.classesImage ~= nil then
        self.classesImage.sprite = nil
    end
    self.model = nil
    self.assetWrapper = nil
    self.gameObject = nil
end

function GloryFriendRankItem:SetData(data, index)
    if index % 2 == 1 then
        self.bgImage.color = ColorHelper.ListItem1
    else
        self.bgImage.color = ColorHelper.ListItem2
    end

    if index > 3 then
        self.rankText.gameObject:SetActive(true)
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = index
    else
        self.rankText.gameObject:SetActive(false)
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. index)
    end

    self.classesImage.sprite = PreloadManager.Instance:GetClassesSprite(data.classes)
    self.scoreText.text = data.val1
    self.nameText.text = data.name
end

function GloryFriendRankItem:update_my_self(data, index)
    self:SetData(data, index)
end


