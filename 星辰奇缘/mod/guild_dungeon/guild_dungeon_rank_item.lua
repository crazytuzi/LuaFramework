GuildDungeonRankItem = GuildDungeonRankItem or BaseClass()

function GuildDungeonRankItem:__init(model, gameObject, assetWrapper)
    self.assetWrapper = assetWrapper
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    local t = self.transform
    self.img = self.gameObject:GetComponent(Image)
    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.rankCampImage = t:Find("RankValue/Camp"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.centernameText = t:Find("Character/CenterName"):GetComponent(Text)
    self.iconObj = t:Find("Character/Icon").gameObject
    self.characterImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    self.name2Text = t:Find("Character2/Name"):GetComponent(Text)
    self.centername2Text = t:Find("Character2/CenterName"):GetComponent(Text)
    self.character2Obj = t:Find("Character2").gameObject
    self.icon2Obj = t:Find("Character2/Icon").gameObject
    self.character2Image = t:Find("Character2/Icon/Image"):GetComponent(Image)
    self.jobText = t:Find("Job"):GetComponent(Text)
    self.scoreText = t:Find("Score"):GetComponent(Text)
    self.bgObj = t:Find("Bg").gameObject
    self.bgObj:SetActive(false)
    self.selectObj = t:Find("Select").gameObject
    self.button = self.gameObject:GetComponent(Button)
    self.Subbutton = self.transform:Find("Button"):GetComponent(Button)
    self.data = nil
end

function GuildDungeonRankItem:update_my_self(data, index)
    local model = self.model
    local color = nil
    local type = model.currentType

    if index < 4 then
        color = model.colorList[index]
    else
        color = ColorHelper.ListItem
    end
    self.data = data
    self.jobText.color = color
    self.nameText.color = color
    self.scoreText.color = color
    self.name2Text.color = color
    self.centernameText.color = color
    self.centername2Text.color = color

    self.character2Obj:SetActive(false)
    self.rankCampImage.gameObject:SetActive(false)
    self.Subbutton.gameObject:SetActive(false)
    self.selectObj:SetActive(model.selectIndex == index)

    if index % 2 == 1 then
        self.img.color = ColorHelper.ListItem1
    else
        self.img.color = ColorHelper.ListItem2
    end

    if index < 4 then
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..index)
        self.rankText.text = ""
    else
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = string.format(ColorHelper.ListItemStr, tostring(index))
    end

    self.centernameText.text = ""

    self.iconObj:SetActive(true)
    self.characterImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
    self.nameText.gameObject:SetActive(true)
    self.nameText.text = data.role_name
    self.jobText.text = KvData.classes_name[data.classes]
    self.scoreText.text = tostring(data.harm)

    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function()
        if model.currentSelectItem ~= nil then
            model.currentSelectItem:SetActive(false)
        end
        model.selectIndex = index
        self.selectObj:SetActive(true)
        model.currentSelectItem = self.selectObj

        local showData = {id = data.r_id, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.role_name}
        TipsManager.Instance:ShowPlayer(showData)
    end)
end

function GuildDungeonRankItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function GuildDungeonRankItem:__delete()
    self.rankImage.sprite = nil
    self.rankCampImage.sprite = nil
    self.characterImage.sprite = nil
    self.character2Image.sprite = nil

    self.assetWrapper = nil

    self.rankText = nil
    self.rankImage = nil
    self.nameText = nil
    self.centernameText = nil
    self.iconObj = nil
    self.characterImage = nil
    self.jobText = nil
    self.scoreText = nil
    self.bgObj = nil
    self.selectObj = nil
    self.button = nil
    self.gameObject = nil
    self.model = nil
end
