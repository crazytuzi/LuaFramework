-- @author 黄耀聪
-- @date 2017年6月20日, 星期二

IngotCrashRankItem = IngotCrashRankItem or BaseClass()

function IngotCrashRankItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.transform = gameObject.transform

    local t = self.transform
    self.rankImage = t:Find("Rank/Image"):GetComponent(Image)
    self.rankText = t:Find("Rank/Text"):GetComponent(Text)
    self.headSlot = HeadSlot.New()
    NumberpadPanel.AddUIChild(t:Find("Player/Head"), self.headSlot.gameObject)
    self.nameText = t:Find("Player/Name"):GetComponent(Text)
    self.classesText = t:Find("Classes/Text"):GetComponent(Text)
    self.vicText = t:Find("Victory/Text"):GetComponent(Text)
    self.scoreText = t:Find("Score/Text"):GetComponent(Text)
    self.situationImage = t:Find("Situation/Image"):GetComponent(Image)
    self.situationText = t:Find("Situation/Text"):GetComponent(Text)
    self.bgImage = t:GetComponent(Image)
end

function IngotCrashRankItem:__delete()
    if self.rankImage ~= nil then
        self.rankImage.sprite = nil
    end
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    self.gameObject = nil
    self.assetWrapper = nil
    self.model = nil
end

function IngotCrashRankItem:update_my_self(data, index)
    self.data = data
    self.index = index

    if index < 4 then
        self.rankText.text = ""
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. index)
    else
        self.rankText.text = index
        self.rankImage.gameObject:SetActive(false)
    end

    if index % 2 == 1 then
        self.bgImage.color = ColorHelper.ListItem1
    else
        self.bgImage.color = ColorHelper.ListItem2
    end
    data.id = data.rid
    self.nameText.text = data.name
    self.classesText.text = KvData.classes_name[data.classes]
    self.headSlot:SetAll(data, {isSmall = true})
    self.scoreText.text = data.score
    self.vicText.text = data.win

    if data.is_rise == 0 then
        self.situationImage.gameObject:SetActive(false)
        if index <= self.model.canUpgradeNum then
            self.situationText.gameObject:SetActive(true)
        else
            self.situationText.gameObject:SetActive(false)
        end
    else
        self.situationText.gameObject:SetActive(false)
        self.situationImage.gameObject:SetActive(true)
        if data.is_rise == 1 then
            self.situationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ingotcrash_textures, "SuccGetInI18N")
        else
            self.situationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ingotcrash_textures, "CannotGetInI18N")
        end
    end
end

function IngotCrashRankItem:SetData(data, index)
    self:update_my_self(data, index)
end

function IngotCrashRankItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end


